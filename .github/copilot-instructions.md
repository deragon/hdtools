This project contains multiples scripts mostly written in Bash and Python.
The very vast majority of the scripts are based from the following scripts:

  hd-create-script-template.py for Python scripts.
  hd-create-script-template.sh for Bash scripts.

New scripts should be based on the code found there, particularly any
new script must make use of the argument parsing and validation of these
arguments found in these templates.

Before creating or modifying any executable script, always read the relevant
template first.

For new Python executable scripts, especially under .env/bin:
  - Read .env/bin/hd-create-script-template.py before editing.
  - Reuse its structure for argument parsing, validation, logging, ANSI
    color definitions, main(), and main_wrapper().
  - Treat the template ANSI constants and colored status/error formatting as
    required parts of the script structure, not optional presentation.
  - The ANSI mapping may be reduced to only the entries actually used by the
    script, as long as the required colored output remains implemented.
  - Do NOT implement dry-run (-d) and execution (-e) options unless the user
    explicitly requests them. These options should only be added when the user
    specifically asks for this functionality.
  - Do not replace that structure with a simplified custom CLI pattern unless
    the user explicitly asks for an exception.

For new Bash executable scripts, especially under .env/bin:
  - Read .env/bin/hd-create-script-template.sh before editing.
  - Reuse its structure for argument parsing, validation, ANSI color
    definitions, and general script organization.
  - Treat the template ANSI definitions and colored warning/error output as
    required parts of the script structure, not optional presentation.
  - The ANSI mapping may be reduced to only the entries actually used by the
    script, as long as the required colored output remains implemented.
  - Do NOT implement dry-run (-d) and execution (-e) options unless the user
    explicitly requests them. These options should only be added when the user
    specifically asks for this functionality.
  - Do not replace that structure with a simplified custom CLI pattern unless
    the user explicitly asks for an exception.

When a script is a reusable Python module rather than an executable command,
these template requirements do not apply unless the module also exposes a CLI.

The language to be used across this project is English.