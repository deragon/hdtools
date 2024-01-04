#!/bin/bash

# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2024 Hans Deragon - AGPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.  It is
# released under the GNU Affero General public Picense which can be found at:
#
#     https://www.gnu.org/licenses/agpl-3.0.en.html
#
# ─────────────────────────────────────────────────── Copyright Notice ─

SCRIPT_NAME="${BASH_SOURCE[0]/*\/}" # Basename, efficient form.
SCRIPT_PATH_ABS="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" # Fetch real directory, not symlink.  Spaces are well handled.

SCRIPT_NAME_BASE="${SCRIPT_NAME/.sh}"
SCRIPT_NAMEANDPATH_ABS="${SCRIPT_PATH_ABS}/${SCRIPT_NAME}"
SCRIPT_PATH_ABS_PARENT=`dirname "${SCRIPT_PATH_ABS}"`

TIMESTAMP_LOG=`date +"%Y%m%d.%H%M%S"`
TIMESTAMP_START=`date +"%s"` # Seconds since epoch.
TIMESTAMP_FORMAT_HUMAN="%Y-%m-%d %H:%M:%S %N"

BATTERY_ID="$(cat /sys/class/power_supply/BAT0/manufacturer)-$(cat /sys/class/power_supply/BAT0/model_name)-$(cat /sys/class/power_supply/BAT0/serial_number)"
BATTERY_ID="${BATTERY_ID/ /}"

LOGDIR="${HOME}/log"
LOGFILE="${LOGDIR}/${SCRIPT_NAME_BASE}.${BATTERY_ID}.${TIMESTAMP_LOG}.log"

usage()
{
  cat <<EOM
Usage:  ${SCRIPT_NAME} [-h]

Loops indefinitely, reporting the time at each 1s interval, on
stdout and in the logfile:

  ${LOGFILE}

When the battery dies, obviously this script would cease running.
Next reboot, compare the start timestamp and the last one in the logfile
to determine how long the battery lasted.
EOM
}

OPTIND=1 # Normally not required, except if the script is sourced.
         # Better be safe than sorry.
while getopts "h" OPTCMD; do
  case "${OPTCMD}" in
    "h"|*)  usage; exit 1;;
  esac
done

shift $((${OPTIND} - 1))  # Remove options from $@
IFS=$(echo -en "\n\b")    # Set IFS so if entries in $@ have spaces,
                          # we separate entries properly.

ERRORS=""

# if (( "$#" == 0 )); then
#   ERRORS="${ERRORS} - You must provide at least one argument.\\n"
# fi

if [ ! -z "${ERRORS}" ]; then
  echo -e "ERROR:  The following errors where detected.\n"
  echo -e "${ERRORS}"
  echo -e "Command aborted."
  exit 1
fi

mkdir -p "${LOGDIR}"

echo -e "Log file located at:\n\n  ${LOGFILE}\n"

{
  echo -en "Started:  ";date -d @"${TIMESTAMP_START}" +"${TIMESTAMP_FORMAT_HUMAN}"

  trap "" HUP  # Detach from terminal; same as nohup.

  while (( 1 )); do
    sleep 1
    echo "Still alive"
  done

  TIMESTAMP_END=`date +"%s"` # Seconds since epoch.
  TIMESTAMP_DIFF=$((${TIMESTAMP_END}-${TIMESTAMP_START}))

  echo -en "Started:    ";date -d @"${TIMESTAMP_START}" +"${TIMESTAMP_FORMAT_HUMAN}"
  echo -en "Ended:      ";date -d @"${TIMESTAMP_END}"   +"${TIMESTAMP_FORMAT_HUMAN}"

  TIMESTAMP_DIFF_DAYS=`printf '% 8d' $(($(date -u -d @"${TIMESTAMP_DIFF}" +'%j')-1))`

  echo -en "Timelapse:  ${TIMESTAMP_DIFF_DAYS} ";date -u -d @"${TIMESTAMP_DIFF}" +'%H:%M:%S'

} 2>&1 | \
while read LINE; do
  # Showing time to the milliseconds
  NOW=`date +"${TIMESTAMP_FORMAT_HUMAN}"`
  NOW="${NOW:0:23}"  # The remaining nanoseconds are removed.
  echo "${NOW} ${LINE}" | tee -a "${LOGFILE}"
done
