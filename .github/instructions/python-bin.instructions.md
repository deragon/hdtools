---
applyTo: "**/.env/bin/**"
description: "Use when creating or editing Python executable scripts in .env/bin. Always read and follow hd-create-script-template.py for argument parsing, validation, logging, ANSI colors, main(), and main_wrapper()."
---

When the target file in .env/bin is a Python executable script:

- Read .env/bin/hd-create-script-template.py before making changes.
- Follow the template structure for parse_arguments(), report_error(), setup_logging(), ANSI color definitions unless the user explicitly requests a different structure.  Ignore main_wrapper().
- Treat the template ANSI constants and colored status or error formatting as required parts of new script creation, not optional presentation.
- The ANSI mapping may be shortened to only the entries actually used by the script, provided the required colored output is still implemented.
- Reuse the template's style for argument parsing and parameter validation.
- **IMPORTANT: Do NOT implement dry-run (-d) and execution (-e) options unless the user explicitly requests them.** These options should only be added when the user specifically asks for this functionality.
- Keep the script language in English.
- The scripts should never need a virtual Python environment.  They must solely depend on the system's python interpreter and the modules it has.  You could suggest modules that can be installed
  with the system software installer (apt, dnf, etc..).

If the file is not a Python executable script, this instruction does not apply.
