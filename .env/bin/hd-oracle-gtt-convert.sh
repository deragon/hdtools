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

SCRIPT_NAME_BASE="${SCRIPT_NAME/.sh}"
SCRIPT_NAMEANDPATH_ABS="${SCRIPT_PATH_ABS}/${SCRIPT_NAME}"
SCRIPT_PATH_ABS_PARENT=`dirname "${SCRIPT_PATH_ABS}"`

usage()
{
  cat <<EOM
Usage:  ${SCRIPT_NAME} -d <info bd> [-h] <table1> <table2> ...

  Converts Global Temporary Tables (GTT) to Normal tables and vice versa.
  Default is to convert GTT -> Normal.

  -d <URL>  URL for the database targeted by the action.

            Format:   <usager>/<password>@<server>:<port>/<schema>
            Exemple:  ${USER}/----------/@orasvr1.company.com:1521/SCHEMA1

  -n        Convert to normal table (default).
  -g        Convert to GTT table.
  -e        Execute the command.  Default is dry run.
EOM
}

OPTIND=1 # Normally not required, except if the script is sourced.
         # Better be safe than sorry.

CONVERT_DIR="GTT->Normal"
EXECUTE=0
while getopts "d:engh" OPTCMD; do
  case "${OPTCMD}" in
    "d")    DB_INFO="${OPTARG}";;
    "e")    EXECUTE=1;;
    "n")    CONVERT_DIR="GTT->Normal";;
    "g")    CONVERT_DIR="Normal->GTT";;
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

# OUTPUT_DIR="${DB_ID}-${TIMESTAMP_LOG}"
# mkdir -p "${OUTPUT_DIR}"

for TABLE in ${TABLES[@]}; do

  echo "Traitement de:  ${TABLE}"
  DDL_TABLE_ORG=$(cat <<EOF | sqlplus -S "${DB_INFO}" | tr -d '\r' | perl -pe "s/\t/  /g"
set long 1000000 longc 32000 lin 32000 trims on hea off pages 0 newp none emb on tab off feed off echo off;
select to_char(dbms_metadata.get_ddl('TABLE', upper('${TABLE}'))) from dual;
quit;
EOF
)

  if [ "${CONVERT_DIR}" = "GTT->Normal" ]; then
    CREATE_REGEX="s/^\s+CREATE.*TABLE\s+(\S+)/DROP TABLE \1;\n\nCREATE TABLE \1/g"
    DELETE_ROWS_REGEX="s/\s*ON COMMIT DELETE ROWS/;/g"
  else
    CREATE_REGEX="s/^\s+CREATE.*TABLE\s+(\S+)/DROP TABLE \1;\n\nCREATE GLOBAL TEMPORARY TABLE \1/g"
    DELETE_ROWS_REGEX="s/^(\s*\))/\1 ON COMMIT DELETE ROWS;\n/g"
  fi

  #echo -e "DDL_TABLE_ORG:  >>${DDL_TABLE_ORG}<<"
  DDL_TABLE_NEW=$(echo "${DDL_TABLE_ORG}" | perl -pe "${CREATE_REGEX};${DELETE_ROWS_REGEX}" | sed '/ON COMMIT DELETE ROWS/q')
  #echo -e "DDL_TABLE_NEW:  >>${DDL_TABLE_NEW}<<"

  ID=$(echo -e "${DDL_TABLE_ORG}" | perl -ne 'print if s/.*TABLE\s+"(\w+)"\."(\w+)"/\1.\2/g')
  SCHEMA="${ID/.*/}"
  TABLE="${ID/*./}"

  # Need to separate Perl invocation here because the first one uses'
  # the global 'g' flag, and unfortunately, it applies to the next one if
  # the statements are within the same instance.  Since the n

  #INDEX_ORG=$(cat <<EOF | sqlplus -S "${DB_INFO}" | tr -d '\r' | paste -sd "  " | perl -pe 's/\s+CREATE/\nCREATE/g' | perl -ne 'print if s/(\S+)$/\1;/'
  INDEX_ORG=$(cat <<EOF | sqlplus -S "${DB_INFO}" | tr -d '\r' | paste -sd "  " | perl -pe 's/\s+CREATE/\nCREATE/g' |  perl -pe 's/\s+PCTFREE.*//g' | perl -ne 'print if s/^(.+)$/\1;/g'
set long 1000000 longc 32000 lin 32000 trims on hea off pages 0 newp none emb on tab off feed off echo off;
select to_char(dbms_metadata.get_ddl('INDEX', index_name, owner))
from all_indexes
where TABLE_NAME = '${TABLE}' and owner = '${SCHEMA}';
quit;
EOF
)

  # echo -e "INDEX_ORG:  >>${INDEX_ORG}<<"

  CMD="${DDL_TABLE_NEW}\n\n${INDEX_ORG}\n"
  echo -e "${CMD}"

  if ((EXECUTE)); then
    echo -e "Executing command.\n"
    echo -e "${CMD}" | sqlplus -S "${DB_INFO}"
  else
    echo "DRY-RUN mode.  Nothing was executed.  Rerun with -e to execute."
  fi

done
