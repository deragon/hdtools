#!/bin/bash

# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2022 Hans Deragon - GPL 3.0 licence.
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

SCRIPT_NAME_BASE="${SCRIPT_NAME/.sh}"
SCRIPT_NAMEANDPATH_ABS="${SCRIPT_PATH_ABS}/${SCRIPT_NAME}"
SCRIPT_PATH_ABS_PARENT=`dirname "${SCRIPT_PATH_ABS}"`

usage()
{
  cat <<EOM
Usage:  ${SCRIPT_NAME} -d <info bd> [-h] <table1> <table2> ...

  Perform Oracle export operation on tables passed as argument.
  These are dumps generated from the 'exp' command.

  -d <URL>  URL for the database targeted by the action.

            Format:   <usager>/<password>@<server>:<port>/<schema>
            Exemple:  ${USER}/----------/@orasvr1.company.com:1521/SCHEMA1

EOM
}

OPTIND=1 # Normally not required, except if the script is sourced.
         # Better be safe than sorry.

while getopts "d:h" OPTCMD; do
  case "${OPTCMD}" in
    "d")    DB_INFO="${OPTARG}";;
    "h"|*)  usage; exit 1;;
  esac
done

shift $((${OPTIND} - 1))  # Remove options from $@
IFS=$(echo -en "\n\b")    # Set IFS so if entries in $@ have spaces,
                          # we separate entries properly.

TABLES=("$@") # If you want the number of elements of $@, use $#
ERRORS=""

if [ ! -d "${ORACLE_HOME}" ]; then
  ERRORS="${ERRORS} - ORACLE_HOME n'est pas bien configuré. Valeur actuelle:  >>${ORACLE_HOME}<<\n"
fi

if [ -z "${DB_INFO}" ]; then
  ERRORS="${ERRORS} - L'information de la BD doit être fournie.\n"
fi

if ((${#TABLES[*]} == 0)); then
  ERRORS="${ERRORS} - Au moins le nom d'une table doit être fournie sur la ligne de commande.\n"
fi

if [ ! -z "${ERRORS}" ]; then
  echo -e "ERREUR:  Les erreurs suivantes se sont produites.\n"
  echo -e "${ERRORS}"
  usage
  echo -e "Commande avortée."
  exit 1
fi

DB_ID="${DB_INFO/*\//}-${DB_INFO/\/*}"

# Code to run code in parallel, but with a limit of number of processes at a time.

TIMESTAMP_LOG=`date +"%Y%m%d.%H%M%S"` 
TIMESTAMP_FORMAT_HUMAN="%Y-%m-%d %H:%M:%S %N"

OUTPUT_DIR="${DB_ID}-${TIMESTAMP_LOG}"
mkdir -p "${OUTPUT_DIR}"

# Maximum number of processes to run in parallel.  Here, reading the number
# of processor (co-processors) available on the system.
PROCESS_MAX=$(egrep -E 'processor' /proc/cpuinfo | wc -l)
for (( INDEX = 0; INDEX < ${#TABLES[*]}; INDEX ++ )); do

  TABLE="${TABLES[${INDEX}]}"
  OUTPUT_FILE="${OUTPUT_DIR}/${DB_ID}-${TABLE}.DMP"
  LOGFILE="${OUTPUT_FILE/.DMP/.log}"
  (
    #sleep $INDEX
    echo -en "Started:  ";date -d @"${TIMESTAMP_START}" +"${TIMESTAMP_FORMAT_HUMAN}"
    CMD="exp \"${DB_INFO}\" \"TABLES=(${TABLE})\" \"FILE=${OUTPUT_FILE}\""
    echo "${CMD/\/*@/\/<mdp>@/}"  # Mot de passe caché
    eval "${CMD}"
  ) 2>&1 | tee "${LOGFILE}" &

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
