This repository contains many executable utilities, mostly written in Bash and Python.

Core rules for any agent working in this repository:

1. Before creating or modifying a Python executable script, read .env/bin/hd-create-script-template.py.
2. Before creating or modifying a Bash executable script, read .env/bin/hd-create-script-template.sh.
3. New executable scripts must follow the relevant template structure for argument parsing, validation, and overall organization.
4. Do not introduce a simplified custom CLI structure for new executable scripts unless the user explicitly asks for an exception.
5. These template requirements apply especially to scripts created under .env/bin.
6. If the target is a reusable module rather than an executable script, these CLI template requirements apply only if the module also exposes a command-line interface.
7. The language to be used across this project is English.