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
SCRIPT_PATH_ABS="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" # Fetch real directory, not symlink.  Spaces are well handled.
# SCRIPT_PATH_ABS="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" # Fetch real directory, not symlink.  Spaces are well handled.

SCRIPT_NAME_BASE="${SCRIPT_NAME/.sh}"
SCRIPT_NAMEANDPATH_ABS="${SCRIPT_PATH_ABS}/${SCRIPT_NAME}"
SCRIPT_PATH_ABS_PARENT="$(dirname "${SCRIPT_PATH_ABS}")"

unset ANSI
if [ -t 1 ] ; then
  # STDOUT is a terminal.  Set ANSI.  If STDOUT is redirected, ANSI
  # remain unset and no ANSI codes are sent out.

  declare -Ag ANSI=(
    ["FG_WHITE_BG_GREEN"]="\e[1;37;42m"
    ["FG_BLACK_BG_YELLOW"]="\e[1;30;43m"
    ["FG_WHITE_BG_RED"]="\e[1;37;41m"
    ["FG_WHITE_BG_BLUE"]="\e[1;37;44m"
    ["FG_WHITE_BG_ORANGERED"]="\x1b[38;2;255;255;255m\x1b[48;2;255;69;0m"  # Requires True ANSI (24 bits) terminal.
    ["RESET"]="\e[0;00m"
    ["BOLD"]="\e[1m"
    ["ITALIC"]="\e[2m"
    ["UNDERLINE"]="\e[3m"
    ["REVERSE"]="\e[7m"
    ["STRIKETHROUGH"]="\e[9m"
    ["BOLD_OFF"]="\e[21m"
    ["ITALIC_OFF"]="\e[22m"
    ["UNDERLINE_OFF"]="\e[23m"
    ["REVERSE_OFF"]="\e[27m"
    ["STRIKETHROUGH_OFF"]="\e[29m"
    ["BLINK"]="\e[5m"
    ["BLACK"]="\e[30m"
    ["RED"]="\e[31m"
    ["GREEN"]="\e[32m"
    ["YELLOW"]="\e[33m"
    ["BLUE"]="\e[34m"
    ["MAGENTA"]="\e[35m"
    ["CYAN"]="\e[36m"
    ["WHITE"]="\e[37m"
    ["BG_RED"]="\e[41m"
    ["BG_GREEN"]="\e[42m"
    ["BG_YELLOW"]="\e[43m"
    ["BG_BLUE"]="\e[44m"
    ["BG_MAGENTA"]="\e[45m"
    ["BG_CYAN"]="\e[46m"
    ["BG_WHITE"]="\e[47m"
    ["BG_DEFAULT"]="\e[49m"
  )
fi


usage()
{
  echo -e "
${ANSI[FG_WHITE_BG_GREEN]} SAFE ${ANSI[RESET]}
${ANSI[FG_BLACK_BG_YELLOW]} SLIGHT DANGER ${ANSI[RESET]}
${ANSI[FG_WHITE_BG_RED]} DANGER ${ANSI[RESET]}

${ANSI[FG_WHITE_BG_GREEN]} SAUF ${ANSI[RESET]}
${ANSI[FG_BLACK_BG_YELLOW]} LÉGER DANGER ${ANSI[RESET]}
${ANSI[FG_WHITE_BG_RED]} DANGER ${ANSI[RESET]}

Usage:  ${SCRIPT_NAME} [-d] [-e] [-z] [-n <nom>] [-h] <file>+

  -d  Dry-run.
  -e  Execute command.  Default is dry-run.
  -e  Exécute la commande.  Le défault est 'dry-run'.
  -z  Debug logs enabled.
  -z  Traces de débuggage activées.
  -h  Display this help text.
  -h  Affiche ce texte d'aide.
"
}


run()
{
  if (( DRYRUN )); then
    echo "DRYRUN:  $@"
  else
    "$@"
    eval "$(printf \""%s\" " "$@")"
  fi
}


# ARGUMENT PARSING
# ════════════════════════════════════════════════════════════════════

DRYRUN=1
DEBUG=0

OPTIND=1 # Normally not required, except if the script is sourced.
         # Better be safe than sorry.
while getopts "n:dezh" OPTCMD; do
  case "${OPTCMD}" in
    # "-" Does not work.  Commenting it until it is fixed or figured out
    # what is wrong with it.
    # In the 'while getopts' above, add "-:" to try this again one day.
    #
    # "-")
    #     # Long options here.
    #     case "${OPTARG}" in
    #       name=)
    #         val=${OPTARG#*=}
    #         NAME=${OPTARG%=$val}
    #     esac;;
    "n")    NAME="${OPTARG}";;
    "d")    DRYRUN=1;;  # Run in dry-run mode.
    "e")    DRYRUN=0;;  # Run in execute mode.
    "z")    DEBUG=1;;
    "h"|*)  usage; exit 1;;
  esac
done

shift $((${OPTIND} - 1))  # Remove options from $@
IFS=$(echo -en "\n\b")    # Set IFS so if FILES in $@ have spaces,
                          # we separate FILES properly.

FILES=("$@") # If you want the number of elements of $@, use $#



# VALIDATION
# ════════════════════════════════════════════════════════════════════

printErrorsAndExitIfAny()
{
  printWarnings
  if [ ! -z "${ERRORS}" ]; then
    echo -e "${ANSI[FG_WHITE_BG_RED]}ERROR:${ANSI[RESET]}  The following errors where detected.\n"
    echo -e "${ANSI[FG_WHITE_BG_RED]}ERREUR:${ANSI[RESET]}  Les erreurs suivantes furent détectées.\n"
    echo -e "${ERRORS}"
    echo -e "Command aborted."
    echo -e "Commande avortée."
    exit 1
  fi
}

printWarnings()
{
  if [ ! -z "${WARNINGS}" ]; then
    echo -e "${ANSI[FG_BLACK_BG_YELLOW]}WARNING:${ANSI[RESET]}  The following warnings were thrown.\n"
    echo -e "${ANSI[FG_BLACK_BG_YELLOW]}AVERTISSEMENT:${ANSI[RESET]}  Les avertissement suivants furent lancés.\n"
    echo -e "${WARNINGS}"
  fi
}

WARNINGS=""
ERRORS=""

if ((${#FILES[*]} == 0)); then
  ERRORS="${ERRORS} - You must provide at least one argument.\n"
fi

if [ -z "${ENV}" ]; then
  ERRORS="${ERRORS} - Environment must be provided.  Example: '-e acc'.\n"
fi

printErrorsAndExitIfAny

# Blinking warning.
#echo -e "${ANSI[FG_WHITE_BG_RED]}${ANSI[BLINK]} WARNING ${ANSI[RESET]}"


# Display format of timestamps.
TIMESTAMP_FORMAT_HUMAN_WITHNANO="%Y-%m-%d %H:%M:%S %N"
TIMESTAMP_FORMAT_HUMAN="%Y-%m-%d %H:%M:%S"
TIMESTAMP_FORMAT_FILE="%Y%m%dT%H%M%S" # ISO 8601 format.

# All timestamps below start with exactly the same time.
TIMESTAMP_START="$(date +"%s")" # Seconds since epoch.
TIMESTAMP_HUMAN="$(date -d @"${TIMESTAMP_START}" +"${TIMESTAMP_FORMAT_HUMAN}")"
TIMESTAMP_FILE="$( date -d @"${TIMESTAMP_START}" +"${TIMESTAMP_FORMAT_FILE}")"


# Fetch yes or no answer from STDIN.
# ────────────────────────────────────────────────────────────────────────────
read -n 1 -p "Désiréz vous exécuter l'image ${DOCKER_IMAGE_ID}? (o/n) " -e ANSWER
#read -p "Enter a value:  " -i "<default value>" -e ANSWER
echo
if [[ "(o|O|y|Y)" =~ "${ANSWER}" ]]; then
  echo "<yes selected>"
fi


# title()
# ────────────────────────────────────────────────────────────────────────────
#
#  call:  title "Test #1"
#  stdout:  ═ Test #1 2020-02-21 11:22:51 ════════════════════════════════════════════════════
title()
{
  local LINE="═══════════════════════════════════════════════════════════════════════════════"
  local TITLE="${1} "$(date "+${TIMESTAMP_FORMAT_HUMAN}")
  local SEPARATOR=$(printf "%s %s %s\n" "${LINE:1:1}" "${TITLE}" "${LINE:${#TITLE}}")
  echo "${SEPARATOR}"
}



# printLineWithSpacesToEnd()
# ────────────────────────────────────────────────────────────────────────────
#
#   This function is used to print a line over an already existing line.  This
#   is to show quickly, on the same line, activity such as a script that
#   searches through many files.  The filenames can then be shown quickly on
#   the same line as the files are being scanned one after the other one.

TERM_COLS_NB=$(tput cols)  # Get once the number of colomns of the current
                           # terminal window.

printLineWithSpacesToEnd()
{
  printf "%- ${TERM_COLS_NB}s\r" "${1}"
}


# TRAPPING AN ERROR
# ────────────────────────────────────────────────────────────────────────────

# When 'set -e' is configured, upon an error the function 'signalerrorhandler'
# gets called.
signalerrorhandler()
{
  #set -x
  last_command="$(fc -l 0)"
  LINENO_ERR=$1
  echo -e "$(cat <<EOM

${ANSI[FG_WHITE_BG_RED]}ERROR:${ANSI[RESET]}  The previous command failed.  Script aborted.
         Following the command that failed:
${ANSI[FG_WHITE_BG_RED]}ERREUR:${ANSI[RESET]}  La commande précédente a échouée.  script avorté.
         Voici la commande qui a échouée:
EOM
)"
  echo

  # From:  https://unix.stackexchange.com/questions/39623/trap-err-and-echoing-the-error-line
  awk 'NR>L-4 && NR<L+4 { printf "             %-5d%3s%s%s\n",NR,(NR==L?">>>":""),$0,(NR==L?"<<<":"") }' L=${LINENO_ERR} $0
}

# IMPORTANT:  ' must be used, not " to ensure that ${LINENO} is not being
#             evaluated during the declaration of the trap.
trap 'signalerrorhandler ${LINENO}' ERR



# PROCESSING
# ════════════════════════════════════════════════════════════════════

# STDIN OR FILES
#
# If no file has been provided, set one file as STDIN (-).  This way,
# either files passed as arguments are processed or STDIN.
if (( ${#FILES[*]} == 0 )); then
  echo -e "${ANSI[FG_BLACK_BG_YELLOW]} WARNING ${ANSI[RESET]} SDTIN being used for input." >&2
  FILES[0]="-"

  # Or as an alternative, to catch all STDIN into a variable named STDIN:
  #STDIN="$(</dev/stdin)"
fi

# Another method to get list of files into the array ${FILES}:
# FILES=($(ls -1d *))

# Running through remaining arguments
index=0
for FILE in ${FILES[@]}; do

  # Print title only if more than one file is being processed.
  (( ${#FILES[*]} > 1 )) && title "Processing ${FILE}"

  printLineWithSpacesToEnd "Searching in ${FILE}"

  EXTENSION="${FILE##*.}"
  if [ "${EXTENSION}" == "${FILE}" ]; then
    # No extension found.
    EXTENSION=""
    FILENAME="${FILE}"
  else
    # An extension was found.  Stripping it from ${FILE}.
    FILENAME="${FILE%.*}"
  fi

  # Activity indicator
  (( index=index+1 ))
  if (( index % 200 == 0 )); then
    echo -n "▚"
    tput cub 1  # Move cursor 1 character to the left.
  elif (( index % 100 == 0 )); then
    echo -n "▞"
    tput cub 1  # Move cursor 1 character to the left.
  fi

  echo "${FILE}"
  while IFS='' read -r LINE || [[ -n "${LINE}" ]]; do
    LINE="${LINE/\#*}"                       # Remove comment.

    # From:  https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
    LINE="${LINE#"${LINE%%[![:space:]]*}"}"  # Left trim.
    [ -z "${LINE}" ] && continue             # Skip empty line (which could have been contained comments.)

    echo "Text processed from file:  ${LINE}"
  done <"${FILE}"
  # done < <( <command> )
done

# Pass all arguments to a command, all quotes so spaces are well handled.
<command> "${FILES[@]}"



# Code to run code in parallel, but with a limit of number of processes at a time.

OUTPUT_DIR="${SCRIPT_NAME}-${TIMESTAMP_FILE}"
mkdir -p "${OUTPUT_DIR}"

# Maximum number of processes to run in parallel.  Here, reading the number
# of processor (co-processors) available on the system.
PROCESS_MAX=$(egrep -E 'processor' /proc/cpuinfo | wc -l)
for (( INDEX = 0; INDEX < 100; INDEX ++ )); do

  FILE="${FILES[${INDEX}]}"
  OUTPUT_FILE="${OUTPUT_DIR}/${FILE}.out"
  LOG_FILE="${OUTPUT_FILE/.DMP/.log}"

  (
    sleep ${INDEX}

    # <Processing code here>
    echo "${FILE} will output into '${OUTPUT_FILE}'"
  ) 2>&1 | tee "${LOG_FILE}" &

  PAUSE_MSG_NEEDTOSHOW=1
  while (( $(jobs -p | wc -l) >= ${PROCESS_MAX} )); do
    if (( ${PAUSE_MSG_NEEDTOSHOW} == 1 )); then
      echo "Parallel limit of ${PROCESS_MAX} reached.  Pausing."
      PAUSE_MSG_NEEDTOSHOW=0
    fi
    sleep 1
  done
  (( ! ${PAUSE_MSG_NEEDTOSHOW} )) && \
    echo "Parallel limit of ${PROCESS_MAX} not reached anymore.  Resuming."
done


logWrapper()
{
  # Directory is 'log', not 'logs', to follow Linux standard '/var/log'.
  LOGDIR="${HOME}/log/${SCRIPT_NAME_BASE}"
  mkdir -p "${LOGDIR}"
  LOGFILE="${LOGDIR}/${SCRIPT_NAME_BASE}.log"

  {
    echo -en "Started:  ";date -d @"${TIMESTAMP_START}" +"${TIMESTAMP_FORMAT_HUMAN}"

    $@

    TIMESTAMP_END=$(date +"%s") # Seconds since epoch.
    TIMESTAMP_DIFF=$((${TIMESTAMP_END}-${TIMESTAMP_START}))

    echo -en "Started:    ";date -d @"${TIMESTAMP_START}" +"${TIMESTAMP_FORMAT_HUMAN}"
    echo -en "Ended:      ";date -d @"${TIMESTAMP_END}"   +"${TIMESTAMP_FORMAT_HUMAN}"

    TIMESTAMP_DIFF_DAYS=$(printf '% 8d' $(($(date -u -d @"${TIMESTAMP_DIFF}" +'%j')-1)))

    echo -en "Timelapse:  ${TIMESTAMP_DIFF_DAYS} ";date -u -d @"${TIMESTAMP_DIFF}" +'%H:%M:%S'

  } 2>&1 | \
  while IFS= read -r LINE; do
    # From:  http://mywiki.wooledge.org/BashFAQ/001#Trimming
    #
    # The read command modifies each line read; by default it removes all leading
    # and trailing whitespace characters (spaces and tabs, or any whitespace
    # characters present in IFS). If that is not desired, the IFS variable has to
    # be cleared.
    #
    # -r instructions 'read' to not consider backslashes as an escape character.

    # If Cygwin, choose 'printf', else use 'date' since it is more accurate (to the nano)

    # Cygwin solution
    printf -v NOW '%(%F %T)T'  # ISO 8601 Format, to the seconds.  For Cygwin (faster, no fork)
                               # Nanoseconds is not available, unfortunately.

    # Linux solution.
    NOW=$(date +"${TIMESTAMP_FORMAT_HUMAN}")  # ISO 8601 Format, to the nano seconds.  For Linux.
    NOW="${NOW:0:23}"  # The remaining nanoseconds are removed.  Milliseconds remain.

    echo "${NOW} ${LINE}" | tee -a "${LOGFILE}"
  done

  # ) >"${LOGFILE}" &

  sleep 1 # Pause to give a chance for the newly created process to start
          # in the background.

  cat <<EOM

  ${SCRIPT_NAME} is running in the background.
  The content of the log file can be displayed with the following command:

      tail -f "${LOGFILE}" &

  <CTRL-C> to abort.
EOM

  tail -f "${LOGFILE}"
}


# DRY RUN / EXECUTION WARNING
# ════════════════════════════════════════════════════════════════════
echo
if (( DRYRUN )); then
  echo -en "${ANSI[FG_WHITE_BG_BLUE]}Command was executed in dry mode; nothing was executed.${ANSI[RESET]}\n${ANSI[FG_WHITE_BG_BLUE]}Rerun with -e to execute the action.${ANSI[RESET]}\n"
  echo -en "${ANSI[FG_WHITE_BG_BLUE]}Commande fut exécutée en 'dry mode'; rien n'a vraiment été exécuté.${ANSI[RESET]}\n${ANSI[FG_WHITE_BG_BLUE]}Rerouler avec l'option -e pour exécuter l'action.${ANSI[RESET]}\n"
else
  echo -en "${ANSI[FG_WHITE_BG_GREEN]}Command was executed.${ANSI[RESET]}\n"
  echo -en "${ANSI[FG_WHITE_BG_GREEN]}Commande fut exécutée.${ANSI[RESET]}\n"
fi
