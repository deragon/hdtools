#!/bin/bash

# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2021 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html
#
# ─────────────────────────────────────────────────── Copyright Notice ─

SCRIPT_NAME="${BASH_SOURCE[0]/*\/}" # Basename, efficient form.
SCRIPT_PATH_ABS="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" # Fetch real directory, not symlink.  Spaces are well handled.
# SCRIPT_PATH_ABS="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" # Fetch real directory, not symlink.  Spaces are well handled.

SCRIPT_NAME_BASE="${SCRIPT_NAME/.sh}"
SCRIPT_NAMEANDPATH_ABS="${SCRIPT_PATH_ABS}/${SCRIPT_NAME}"
SCRIPT_PATH_ABS_PARENT=$(dirname "${SCRIPT_PATH_ABS}")

usage()
{
  echo -e "
\e[1;37;42m SAFE \e[0m
\e[1;30;43m SLIGHT DANGER \e[0m
\e[1;37;41m DANGER \e[0m

\e[1;37;42m SAUF \e[0m
\e[1;30;43m LÉGER DANGER \e[0m
\e[1;37;41m DANGER \e[0m

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
    $@
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

ERRORS=""

if ((${#FILES[*]} == 0)); then
  ERRORS="${ERRORS} - You must provide at least one argument.\n"
fi

if [ -z "${ENV}" ]; then
  ERRORS="${ERRORS} - Environment must be provided.  Example: '-e acc'.\n"
fi

if [ ! -z "${ERRORS}" ]; then
  echo -e "\e[1;37;41mERROR:\e[0m  The following errors where detected.\n"
  echo -e "\e[1;37;41mERREUR:\e[0m  Les erreurs suivantes furent détectées.\n"
  echo -e "${ERRORS}"
  echo -e "Command aborted."
  echo -e "Commande avortée."
  exit 1
fi

TIMESTAMP_FILE="$(date +"%Y%m%dT%H%M%S")" # ISO 8601 format.
TIMESTAMP_START="$(date +"%s")" # Seconds since epoch.
TIMESTAMP_FORMAT_HUMAN="%Y-%m-%d %H:%M:%S %N"



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

\e[1;37;41mERROR:\e[0m  The previous command failed.  Script aborted.
         Following the command that failed:
\e[1;37;41mERREUR:\e[0m  La commande précédente a échouée.  script avorté.
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
  echo -e "\e[1;30;43m WARNING \e[0m  SDTIN being used for input."
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
  if [ "${EXTENSION}" == ${FILE} ]; then
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


# Directory is 'log', not 'logs', to follow Linux standard '/var/log'.
LOGDIR="${HOME}/log/${SCRIPT_NAME_BASE}"
mkdir -p "${LOGDIR}"
LOGFILE="${LOGDIR}/${SCRIPT_NAME_BASE}.${TIMESTAMP_FILE}.PID-$$.log"

{
  echo -en "Started:  ";date -d @"${TIMESTAMP_START}" +"${TIMESTAMP_FORMAT_HUMAN}"

  trap "" HUP  # Detach from terminal; same as nohup.

  <CODE HERE>

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

${SCRIPT_NAME} roule en background.  Le fichier de log est affiché avec la
commande suivante.

  tail -f "${LOGFILE}" &

CTRL-C pour avorter.

EOM

tail -f "${LOGFILE}"


# DRY RUN / EXECUTION WARNING
# ════════════════════════════════════════════════════════════════════
echo
if (( DRYRUN )); then
  echo -en "\e[1;37;44mCommand was executed in dry mode; nothing was executed.\e[0;00m\n\e[1;37;44mRerun with -e to execute the action.\e[0;00m"
  echo -en "\e[1;37;44mCommande fut exécutée en 'dry mode'; rien n'a vraiment été exécuté.\e[0;00m\n\e[1;37;44mRerouler avec l'option -e pour exécuter l'action.\e[0;00m"
else
  echo -en "\e[1;37;42mCommand was executed.\e[0;00m"
  echo -en "\e[1;37;42mCommande fut exécutée.\e[0;00m"
fi
