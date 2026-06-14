#!/usr/bin/env python3

import shutil
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUTS_DIR = SCRIPT_DIR / "output"
INPUT_DIR = SCRIPT_DIR / "input"
COMMONRC = Path("/home/derah/.hans.deragon/.env/vim/commonrc.vim")
RTP_ROOT = Path("/home/derah/.hans.deragon/.env/vim")

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None


class WrapUnitTests(unittest.TestCase):
    maxDiff = None

    @classmethod
    def setUpClass(cls):
        cls.nvim = shutil.which("nvim")
        cls.vim = shutil.which("vim")
        if cls.nvim is None or cls.vim is None:
            raise unittest.SkipTest("Both vim and nvim are required for wrap unit tests.")

    def run_case_in_editor(self, editor: str, file_name: str, content: str, steps: list):
        with tempfile.TemporaryDirectory(prefix="wrap-unit-") as temp_dir:
            file_path = Path(temp_dir) / file_name
            file_path.write_text(content, encoding="utf-8")

            # Write all steps into a single helper script to stay within
            # nvim/vim's limit of 10 "+command" arguments.
            script_lines = []
            for step in steps:
                n = step['cursor_line']
                w = step['width']
                # Skip the step silently if the cursor line is beyond the
                # current buffer end (can happen when earlier steps shift
                # fewer lines than anticipated).
                script_lines.append(f"if {n} <= line('$')")
                script_lines.append(f"  call cursor({n}, 1)")
                script_lines.append(f"  call HDWrapWithPar({w})")
                script_lines.append(f"endif")
            script_lines.append("wq")
            script_path = Path(temp_dir) / "wrap_steps.vim"
            script_path.write_text("\n".join(script_lines) + "\n", encoding="utf-8")

            if editor == "nvim":
                cmd = [
                    self.nvim,
                    "--headless",
                    "-n",
                    "-u", "NONE",
                    "-i", "NONE",
                    "-N",
                    f"+set rtp^={RTP_ROOT}",
                    f"+source {COMMONRC}",
                    str(file_path),
                    f"+source {script_path}",
                ]
            else:
                cmd = [
                    self.vim,
                    "-Es",
                    "-n",
                    "-u", "NONE",
                    "-U", "NONE",
                    "-N",
                    f"+set rtp^={RTP_ROOT}",
                    f"+source {COMMONRC}",
                    str(file_path),
                    f"+source {script_path}",
                ]

            run = subprocess.run(cmd, text=True, capture_output=True)
            self.assertEqual(
                run.returncode,
                0,
                msg=(
                    f"{editor} failed\n"
                    f"command: {' '.join(cmd)}\n"
                    f"stdout:\n{run.stdout}\n"
                    f"stderr:\n{run.stderr}\n"
                ),
            )

            return file_path.read_text(encoding="utf-8").splitlines()

    def save_case_output(self, case_name: str, editor: str, out):
        """Persist the transformed buffer for a test case."""
        OUTPUTS_DIR.mkdir(parents=True, exist_ok=True)
        output_path = OUTPUTS_DIR / f"{case_name}.{editor}.txt"
        output_path.write_text("\n".join(out) + ("\n" if out else ""), encoding="utf-8")

    def load_case_input(self, case_name: str):
        """Load test input text from input/<case_name>.txt."""
        INPUT_DIR.mkdir(parents=True, exist_ok=True)
        input_path = INPUT_DIR / f"{case_name}.txt"
        if not input_path.exists():
            self.fail(f"Missing input file for test: {input_path}")
        return input_path.read_text(encoding="utf-8")

    def load_case_expected(self, case_name: str):
        """Load expected output text from expected/<case_name>.txt."""
        expected_path = SCRIPT_DIR / "expected" / f"{case_name}.txt"
        if not expected_path.exists():
            self.fail(f"Missing expected file for test: {expected_path}")
        return expected_path.read_text(encoding="utf-8").splitlines()

    def _parse_simple_yaml(self, text: str, metadata_path: Path):
        """Parse minimal YAML (top-level scalars + 'steps' list) when PyYAML is unavailable."""

        def parse_scalar(raw: str) -> object:
            v = raw.strip()
            if (v.startswith('"') and v.endswith('"')) or (v.startswith("'") and v.endswith("'")):
                return v[1:-1]
            try:
                return int(v)
            except ValueError:
                return v

        data: dict = {}
        lines = text.splitlines()
        i = 0
        while i < len(lines):
            raw_line = lines[i]
            stripped = raw_line.strip()
            i += 1
            if not stripped or stripped.startswith("#"):
                continue
            if ":" not in stripped:
                self.fail(f"Invalid metadata line at {metadata_path}:{i}: {raw_line!r}")
            key, value = stripped.split(":", 1)
            key = key.strip()
            value = value.strip()
            if not key:
                self.fail(f"Empty metadata key at {metadata_path}:{i}")
            if key == "steps" and not value:
                steps: list = []
                current: dict | None = None
                while i < len(lines):
                    sl = lines[i]
                    ss = sl.strip()
                    if not ss or ss.startswith("#"):
                        i += 1
                        continue
                    indent = len(sl) - len(sl.lstrip())
                    if indent == 0:
                        break  # back to top level
                    if ss.startswith("- "):
                        if current is not None:
                            steps.append(current)
                        current = {}
                        kv = ss[2:]
                        if ":" in kv:
                            k, v = kv.split(":", 1)
                            current[k.strip()] = parse_scalar(v)
                    else:
                        if current is None:
                            self.fail(f"Unexpected indented line outside a step at {metadata_path}:{i+1}")
                        if ":" in ss:
                            k, v = ss.split(":", 1)
                            current[k.strip()] = parse_scalar(v)
                    i += 1
                if current is not None:
                    steps.append(current)
                data["steps"] = steps
            else:
                data[key] = parse_scalar(value)

        return data

    def load_case_metadata(self, case_name: str):
        """Load case metadata from input/<case_name>-metadata.yaml."""
        metadata_path = INPUT_DIR / f"{case_name}-metadata.yaml"
        if not metadata_path.exists():
            self.fail(f"Missing metadata file for test: {metadata_path}")

        metadata_text = metadata_path.read_text(encoding="utf-8")
        if yaml is not None:
            metadata = yaml.safe_load(metadata_text) or {}
        else:
            metadata = self._parse_simple_yaml(metadata_text, metadata_path)

        if not isinstance(metadata, dict):
            self.fail(f"Metadata file must define a key/value mapping: {metadata_path}")

        if "file_name" not in metadata or not isinstance(metadata["file_name"], str) or not metadata["file_name"]:
            self.fail(f"Missing or invalid 'file_name' in {metadata_path}: expected non-empty string")

        if "steps" not in metadata or not isinstance(metadata["steps"], list) or not metadata["steps"]:
            self.fail(f"Missing or empty 'steps' list in {metadata_path}")

        validated_steps = []
        for idx, step in enumerate(metadata["steps"], start=1):
            if not isinstance(step, dict):
                self.fail(f"Step {idx} in {metadata_path} is not a mapping")
            for key in ("cursor_line", "width"):
                if key not in step:
                    self.fail(f"Step {idx} in {metadata_path} is missing required key: {key!r}")
            try:
                cursor_line = int(step["cursor_line"])
                width = int(step["width"])
            except (TypeError, ValueError):
                self.fail(f"Step {idx} in {metadata_path}: cursor_line and width must be integers")
            if cursor_line < 1 or width < 1:
                self.fail(f"Step {idx} in {metadata_path}: cursor_line and width must be >= 1")
            validated_steps.append({"cursor_line": cursor_line, "width": width})

        return {
            "file_name": metadata["file_name"],
            "steps": validated_steps,
        }

    def run_dynamic_case(self, case_name: str, editor: str):
        cfg = self.load_case_metadata(case_name)
        content = self.load_case_input(case_name)
        out = self.run_case_in_editor(
            editor,
            cfg["file_name"],
            content,
            steps=cfg["steps"],
        )
        expected = self.load_case_expected(case_name)
        self.save_case_output(case_name, editor, out)
        self.assertEqual(
            out,
            expected,
            msg=f"Unexpected output for case: {case_name} (editor={editor})",
        )


def _build_dynamic_test(case_name: str, editor: str):
    def test_method(self):
        self.run_dynamic_case(case_name, editor)

    test_method.__name__ = f"{case_name}_{editor}"
    return test_method


def _register_dynamic_tests():
    INPUT_DIR.mkdir(parents=True, exist_ok=True)
    for input_path in sorted(INPUT_DIR.glob("*.txt")):
        case_name = input_path.stem
        base_name = case_name if case_name.startswith("test_") else f"test_{case_name}"
        for editor in ("vim", "nvim"):
            method_name = f"{base_name}_{editor}"
            setattr(WrapUnitTests, method_name, _build_dynamic_test(case_name, editor))


_register_dynamic_tests()


class DualStreamResult(unittest.TextTestResult):
    """Custom result class that writes to both console and file."""

    def __init__(self, stream, descriptions, verbosity, file_stream=None):
        super().__init__(stream, descriptions, verbosity)
        self.file_stream = file_stream

    def startTest(self, test):
        super().startTest(test)
        if self.file_stream:
            self.file_stream.write(f"Running {test}...\n")
            self.file_stream.flush()

    def addSuccess(self, test):
        super().addSuccess(test)
        if self.file_stream:
            self.file_stream.write(f"  ✓ PASS\n")
            self.file_stream.flush()

    def addError(self, test, err):
        super().addError(test, err)
        if self.file_stream:
            self.file_stream.write(f"  ✗ ERROR: {err[0].__name__}: {err[1]}\n")
            self.file_stream.flush()

    def addFailure(self, test, err):
        super().addFailure(test, err)
        if self.file_stream:
            self.file_stream.write(f"  ✗ FAIL: {err[1]}\n")
            self.file_stream.flush()


class DualStreamRunner(unittest.TextTestRunner):
    """Custom runner that writes results to both console and file."""

    def __init__(self, file_stream=None, **kwargs):
        super().__init__(**kwargs)
        self.file_stream = file_stream

    def _makeResult(self):
        return DualStreamResult(
            self.stream, self.descriptions, self.verbosity, file_stream=self.file_stream
        )


if __name__ == "__main__":
    OUTPUTS_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = time.strftime("%Y%m%d-%H%M%S")
    output_file = OUTPUTS_DIR / f"wrap_tests_{timestamp}.txt"

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(f"Wrap Unit Tests\n")
        f.write(f"Run: {timestamp}\n")
        f.write(f"="*70 + "\n\n")
        f.flush()

        loader = unittest.TestLoader()
        suite = loader.loadTestsFromTestCase(WrapUnitTests)
        runner = DualStreamRunner(
            stream=sys.stdout, verbosity=2, file_stream=f
        )
        result = runner.run(suite)

        f.write(f"\n" + "="*70 + "\n")
        f.write(f"Results: {result.testsRun} tests, "
                f"{len(result.failures)} failures, "
                f"{len(result.errors)} errors\n")
        if result.wasSuccessful():
            f.write(f"Status: ✓ ALL TESTS PASSED\n")
        else:
            f.write(f"Status: ✗ TESTS FAILED\n")

    print(f"\nTest output saved to: {output_file}")
    sys.exit(0 if result.wasSuccessful() else 1)
