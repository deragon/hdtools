---
applyTo: "**/.env/bin/**"
description: "Use when creating or editing Bash executable scripts in .env/bin. Always read and follow hd-create-script-template.sh for argument parsing, validation, ANSI colors, and script structure."
---

When the target file in .env/bin is a Bash executable script:

- Read .env/bin/hd-create-script-template.sh before making changes.
- Follow the template's style for argument parsing, validation, ANSI color definitions, and overall script organization unless the user explicitly requests a different structure.
- Treat the template ANSI definitions and colored warning or error output as required parts of new script creation, not optional presentation.
- The ANSI mapping may be shortened to only the entries actually used by the script, provided the required colored output is still implemented.
- Do not replace the template approach with an ad hoc CLI pattern.
- Keep the script language in English.

If the file is not a Bash executable script, this instruction does not apply.