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

usage()
{
  cat <<EOM
Usage:  ${SCRIPT_NAME} [-d] [-p] [-h] <src dir> <dst dir>

  -d  Dry-run.
  -p  LibreOffice Writer documents converted to PDF (instead of MS Word).
  -z  Debug logs enabled.
  -h  Display this help text.

Convert files of a directory into compatible files for use with a 
Microsoft Office based PC.

All LibreOffice files are ignored, since they will be converted to 
Microsoft Office format or PDF.

Files starting with "hd" or "HD" are assumed to be files reserved
exclusively for the eyes of Hans Deragon and therefore are exluded too.

EOM
}

# ARGUMENT PARSING
# ════════════════════════════════════════════════════════════════════

DRYRUN=0
DEBUG=0
WRITER_FORMAT="docx"

OPTIND=1 # Normally not required, except if the script is sourced.
         # Better be safe than sorry.
while getopts "pdeh" OPTCMD; do
  case "${OPTCMD}" in
    "p")    WRITER_FORMAT="pdf"
            echo "PDF files will be generated for LibreOffice Writer documents.";;
    "d")    DRYRUN=1    # Run in dry-run mode.
            echo "Dry-run mode enabled.  Nothing will be executed.";;
    "h"|*)  usage; exit 1;;
  esac
done

shift $((${OPTIND} - 1))  # Remove options from $@
IFS=$(echo -en "\n\b")    # Set IFS so if FILES in $@ have spaces,
                          # we separate FILES properly.

FILES=("$@") # If you want the number of elements of $@, use $#
SRC_DIR="${FILES[0]}"
DST_DIR="${FILES[1]}"

# COMMANDLINE VALIDATION
# ════════════════════════════════════════════════════════════════════

ERRORS=""

if [ ! -d "${SRC_DIR}" ]; then
  ERRORS="${ERRORS} - Source directory not available at:  ${SRC_DIR}\n"
fi

if [ -z "${DST_DIR}" ]; then
  ERRORS="${ERRORS} - Destination directory not provided.\n"
fi

if [ ! -z "${ERRORS}" ]; then
  echo -e "ERROR:  The following errors where detected.\n"
  echo -e "${ERRORS}"
  echo -e "Command aborted."
  exit 1
fi

TIMESTAMP_FILE=`date +"%Y%m%dT%H%M%S"` # ISO 8601 format.
TIMESTAMP_START=`date +"%s"` # Seconds since epoch.
TIMESTAMP_FORMAT_HUMAN="%Y-%m-%d %H:%M:%S %N"

# PROCESSING
# ════════════════════════════════════════════════════════════════════

SRC_DIR=$(echo "${SRC_DIR}" | sed --regexp-extended 's%/\.*$%%g')
DST_DIR=$(echo "${DST_DIR}" | sed --regexp-extended 's%/\.*$%%g')

SRC_DIR_BASENAME=$(basename "${SRC_DIR}")
# Removing trailing "/." if any
!((DRYRUN)) && mkdir -p "${DST_DIR}/${SRC_DIR_BASENAME}"

# All LibreOffice files are ignored, since they will be converted to 
# Microsoft Office format or PDF.
#
# Files starting with "hd" or "HD" are assumed to be files reserved
# exclusively for the eyes of Hans Deragon and therefore are exluded too.
unset RSYNC_DRYRUN
(( DRYRUN )) && RSYNC_DRYRUN="--dry-run"

rsync ${RSYNC_DRYRUN} -arv \
  --exclude='*.ods' \
  --exclude='*.odt' \
  --exclude='hd*' \
  --exclude='HD*' \
  "${SRC_DIR}" \
  "${DST_DIR}/."
  #"${DST_DIR}/${SRC_DIR_BASENAME}/."

SRC_DIR=$(readlink -f "${SRC_DIR}") # Fetch real directory, not symlink.  Spaces are well handled.

# Create directory structure as the original
SRC_DIR_TO_CUT="${SRC_DIR/${SRC_DIR/*\/}}"
!((DRYRUN)) && find ${SRC_DIR} -type d | sed "s%${SRC_DIR_TO_CUT}%${DST_DIR}/%g" | xargs --delimiter="\n" mkdir -p


IFS="
"

# Convert LibreOffice Calc -> Microsoft Excel
FILES_ODS=$(find "${SRC_DIR}" -name "*.ods")
for FILE in ${FILES_ODS}; do
  DST_FILE_DIR=$(dirname "${DST_DIR}/${FILE/${SRC_DIR_TO_CUT}/}")
  # echo "${FILE} -> ${FILE_DST}"
  ! ((DRYRUN)) && libreoffice --convert-to xlsx --outdir "${DST_FILE_DIR}" "${FILE}"
  sleep 10
done

# Convert LibreOffice Writer -> Microsoft Word
FILES_ODT=$(find "${SRC_DIR}" -name "*.odt")
for FILE in ${FILES_ODT}; do
  DST_FILE_DIR=$(dirname "${DST_DIR}/${FILE/${SRC_DIR_TO_CUT}/}")
  # echo "${FILE} -> ${FILE_DST}"
  ! ((DRYRUN)) && libreoffice --convert-to "${WRITER_FORMAT}" --outdir "${DST_FILE_DIR}" "${FILE}"
  sleep 10
done
