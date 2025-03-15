#!/bin/bash

# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2025 Hans Deragon - AGPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.  It is
# released under the GNU Affero General Public License which can be found at:
#
#     https://www.gnu.org/licenses/agpl-3.0.en.html
#
# ─────────────────────────────────────────────────── Copyright Notice ─

SCRIPT_NAME="${BASH_SOURCE[0]/*\/}" # Basename, efficient form.

usage()
{
  cat <<EOM
Usage:  ${SCRIPT_NAME} [-h] <string>+

Simply take the strings as input and output them with double quotes around them.

  -h  Display this help text.
EOM
}

# ARGUMENT PARSING
# ════════════════════════════════════════════════════════════════════

OPTIND=1 # Normally not required, except if the script is sourced.
         # Better be safe than sorry.
while getopts "h" OPTCMD; do
  case "${OPTCMD}" in
    "h"|*)  usage; exit 1;;
  esac
done

shift $((${OPTIND} - 1))  # Remove options from $@
IFS=$(echo -en "\n\b")    # Set IFS so if STRINGS in $@ have spaces,
                          # we separate STRINGS properly.

STRINGS=("$@") # If you want the number of elements of $@, use $#

# COMMANDLINE VALIDATION
# ════════════════════════════════════════════════════════════════════

ERRORS=""

if ((${#STRINGS[*]} == 0)); then
  ERRORS="${ERRORS} - You must provide at least one argument.\n"
fi

if [ ! -z "${ERRORS}" ]; then
  echo -e "ERROR:  The following errors where detected.\n"
  echo -e "${ERRORS}"
  echo -e "Comand aborted."
  exit 1
fi

# PROCESSING
# ════════════════════════════════════════════════════════════════════

RESULT=""
for STRING in ${STRINGS[@]}; do
  RESULT="${RESULT}\"${STRING}\" "
done

echo "${RESULT::-1}"  # Remove last space and print.
