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

# Not used.
#alias citrix='wfica'

# On first call, will set the variable passed as name with
# the result of a search with "locate".  Next call, the content
# of the variable will already contain the executable, speeding
# things up.
hd_application_run_executable()
{
  local SUFFIX=$1;        shift
  local TEXT="$1";        shift
  local EXECUTABLES="$1"; shift

  local VARNAME="HD_APPL_${SUFFIX}"

  if [ -e "${!VARNAME}" ]; then
    echo "Executing ${TEXT}:  ${!VARNAME}"
    if [ -z "$@" ]; then
      ("${!VARNAME}" &)
    else
      ("${!VARNAME}" "$@" &)
    fi
  else
    local IFS="|"
    for EXECUTABLE in ${EXECUTABLES}; do
      eval "export ${VARNAME}='"`locate -i --regex "[/|\\]${EXECUTABLE}\$" | egrep -v "(obs|Download/PackageFiles)" | head -1`"'"
      export ${VARNAME}
      if [ -e "${!VARNAME}" ]; then
        hd_application_run_executable "${SUFFIX}" "${TEXT}" "${EXECUTABLE}" "$@"
        return
      fi
    done
    echo "Could not find ${TEXT}."
  fi
}
exportfunction hd_application_run_executable

# Call hd_loop -h for instructions
hd_loop()
{
  local DELAY # in seconds
  perl -e "\$_='${1}';if(/^\d+$/) { exit 1 } else { exit 0}"
  if (($?)); then
    DELAY=${1}
    shift
  elif [ "${1}" = "-h" ]; then
    cat <<HELP
Usage:    hd_loop [<delay in seconds>] <cmd>

Example:  hd_loop 1 "date;ls"
          hd_loop date
HELP
    return
  else
    DELAY=5
  fi

  while ((1)); do
    eval $@
    sleep ${DELAY}
  done
}
exportfunction hd_loop

# Aliases cannot be expanded within compound statements such as "if, while"
# hd_term_reset has to be function since bashrc.gen is calling it within
# a compound statement.
#
# See http://www.linuxtopia.org/online_books/advanced_bash_scripting_guide/aliases.html
hd_term_reset()
{
  kill -s SIGWINCH $$
}
exportfunction hd_term_reset

hd_bash_replace_newline()
{
  local VARIABLE_NAME=$1
  local REPLACEMENT=$2

  local TMP1="\${${VARIABLE_NAME}//\$'\x0a'/${REPLACEMENT}}"
  echo "TMP1=>>${TMP1}<<"
  eval "${VARIABLE_NAME}=${TMP1}"
}
exportfunction hd_bash_replace_newline

hd_bash_array_output_newline()
{
  local array=($@)
  local index
  for index in ${!array[*]}
  do
    printf "%4d: %s\n" $index ${array[$index]}
  done
}
exportfunction hd_bash_array_output_newline

# Usage:  sshsite [user@][hostname] <default hostname> <domain>
#
# If first argument is "" (not nothing, but empty string), then
# connection as root is attempted at <default hostname>.<domain>
#
# Depending what the first argument is composed of, connection
# to a different machine than <default hostname> and/or to a different
# user than root (defined by [user@]) is attempted.
#
# Example:  home            # connects to root@server1.mydomain.com
#           home john@      # connects to john@server1.mydomain.com
#           home john@world # connects to john@world.mydomain.com
sshsite()
{
  local USERANDHOSTNAME=$1; shift
  local DEFAULTHOSTNAME=$1; shift
  local DOMAINNAME=$1; shift

  if [ "${USERANDHOSTNAME/*@*/detected}" != "detected" ]; then
    USERANDHOSTNAME="root@${USERANDHOSTNAME}"
  fi

  if [ "${USERANDHOSTNAME/*@/detected}" = "detected" ]; then
    USERANDHOSTNAME="${USERANDHOSTNAME}${DEFAULTHOSTNAME}"
  fi

  #echo ${USERANDHOSTNAME}
  if [ "${USERANDHOSTNAME/*${DOMAINNAME}/detected}" = "detected" ]; then
    local SSHCOMMAND=${USERANDHOSTNAME}
  else
    local SSHCOMMAND=${USERANDHOSTNAME}.${DOMAINNAME}
  fi

  ssh $@ ${SSHCOMMAND}
}
exportfunction sshsite

hd_html_cleanup()
{
  local files
  files=`hd_FetchWordsFromArgs $*`
  hd_BackupFile ${files}
  hd_Execute tidy -utf8 -icu -asxml ${HD_LAST_BACKUP_FILENAME} >${files}
}
exportfunction hd_html_cleanup

export HDDOCSDIR="${HDENVDIR}/docs"
alias cddocs='cdprint "${HDDOCSDIR}"'
alias docs='f "${HDDOCSDIR}"'
alias cdbd='cdprint ${HDDOCSDIR}/programming/bigdata'
alias cdprg='cdprint ${HDDOCSDIR}/programming'
alias cdvim='cdprint "${HDVIM}"'

eval $(hddocsaliascreate)  # Generate documents aliases.
alias todo='gvim ${HDSLDIR}/todo.txt'

ff()
{
  find . -iname "${1}" -follow -print | egrep -i --color=auto "${1//\*/.*}"
}

hdreadman()
{
  if [ "${1/*.gz/x}" = "x" ]; then
    gunzip --to-stdout ${1} | nroff -man | less
  else
    nroff -man "$*" | "${PAGER}"
  fi
}

hdxman()
{
  gnome-terminal --command="man $@"
}

alias hdseafileconflicts='find . -name "*(SFConflict *"'
alias hdseafileconflictsrm='hdseafileconflicts -print0 | xargs --null rm'
alias psw='psg -w'
alias hg='history | egrep'

[ -d "${TOMCAT_HOME}" ] && alias cdtomcat='cdprint "${TOMCAT_HOME}"'


# Small function that allows a user to edit the path on the fly.
editpath()
{
  local TMP="/tmp/editpath.$$.txt"
  splitpath PATH >"${TMP}"
  eval ${EDITOR} "${TMP}"
  export PATH=$(cat "${TMP}" | unsplitpath)
  rm -f "${TMP}"
}


# Whenever the scrollbar disappears / is missing on a terminal, call
# the following alias:
alias hdresetscrollbar='tput rmcup'



# Configuration management
# ══════════════════════════════════════════════════════════════════════════════
#
#   Subversion / SVN
#   ────────────────────────────────────────────────────────────────────────────

alias diffxsvn='diff -r --exclude ".svn"'
svnv() { svn diff --diff-cmd hd-svn-gvimdiff-wrapper $@ & }
svnl() { svn log $* | less; }


#   Git
#   ────────────────────────────────────────────────────────────────────────────
which git >/dev/null 2>&1
if (( $? == 0 )); then
  alias hdgpull='git pull --all --prune'
  alias hdgstatus='git status --untracked-files=no'

  hdgvarclear()
  {
    unset \
      GIT_AUTHOR_NAME     \
      GIT_AUTHOR_EMAIL    \
      GIT_AUTHOR_DATE     \
      GIT_COMMITTER_NAME  \
      GIT_COMMITTER_EMAIL \
      GIT_COMMITTER_DATE  \
      HD_GIT_DATE_OFFSET  \
      GIT_BACKUP_USERNAME \
      GIT_BACKUP_EMAIL

    hdgconfigprint
  }

  hdgrestore()
  {
    [ ! -z "${GIT_BACKUP_USERNAME}" ] && \
      git config --global user.name  "${GIT_BACKUP_USERNAME}"

    [ ! -z "${GIT_BACKUP_EMAIL}" ] && \
      git config --global user.email "${GIT_BACKUP_EMAIL}"

    hdgvarclear
  }

  hdgdate()
  {
    #  https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables

    if [ -z "${HD_GIT_DATE_OFFSET}" -o "$1" == "-r" ]; then
      echo -en "Enter offset (in hours):  "
      read HD_GIT_DATE_OFFSET
      echo
    fi

    if [ -z "${GIT_BACKUP_USERNAME}" ]; then
      GIT_BACKUP_USERNAME=$(git config --global user.name)
    fi
    #git config --global user.name "Hans Deragon"

    if [ -z "${GIT_BACKUP_EMAIL}" ]; then
      GIT_BACKUP_EMAIL=$(git config --global user.email)
    fi
    #git config --global user.email hans@deragon.biz

    export GIT_AUTHOR_NAME="Hans Deragon"
    export GIT_AUTHOR_EMAIL="hans@deragon.biz"
    export GIT_AUTHOR_DATE=$(date -d "+${HD_GIT_DATE_OFFSET} hours" +"%Y-%m-%d %H:%M:%S%z")

    # Copy GIT_AUTHOR_* to GIT_COMMITTER_*.
    export GIT_COMMITTER_NAME="${GIT_AUTHOR_NAME}"
    export GIT_COMMITTER_EMAIL="${GIT_AUTHOR_EMAIL}"
    export GIT_COMMITTER_DATE="${GIT_AUTHOR_DATE}"

    export HD_GIT_DATE_OFFSET

    hdgconfigprint
  }
fi

alias cdgroot='cdprint "$(git rev-parse --show-toplevel)"'

# ══════════════════════════════════════════════════════════════════════════════
# Maven
#
# Variables used here are the official names as suggested by the 'mvn'
# script.

setVarIfDirsExist M2_HOME                      \
  "${HD_LOGICIELS}/nodist/noarch/maven/latest" \
  "${M2_HOME}"                                 \
  ApacheMavenNotAvailable

if [ -d "${M2_HOME}" ]; then
  export MAVEN_OPTS="-Xms256m -Xmx512m"
  add2path PATH "${M2_HOME}/bin"

  alias cdmaven='cdprint "${M2_HOME}"'
  alias cdm2='cdprint "${HOME}/.m2"'
fi


# ══════════════════════════════════════════════════════════════════════════════
# icdiff
if [ -d "/vol/data/base/software/nodist/noarch/icdiff/src" ]; then
  alias icdiff="/vol/data/base/software/nodist/noarch/icdiff/src/icdiff"
fi


# ══════════════════════════════════════════════════════════════════════════════
# AWS
#
#   Pour installer AWSCLI (en date du 2018-11-09)
#
#     pip install awscli --upgrade --user
#
#   Ils ont par la suite installés sous "${HOME}/.local/bin"
#
#   Voir:  https://docs.aws.amazon.com/cli/latest/userguide/installing.html
add2path PATH "${HOME}/.local/bin"
alias hdawsvarunset='unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN;blackbg'
hdawsssh() { ssh "ec2-user@$1"; }; exportfunction hdawsssh

alias hdhistoryclear='cat /dev/null >"${HOME}/.bash_history" && history -c'

# 169.254.0.0/16 is a Link-local address (https://en.m.wikipedia.org/wiki/Link-local_address)
# used by AWS and other services and must never have a proxy.
export no_proxy="localhost,127.0.0.0/8,169.254.0.0/16,${no_proxy}"

# export no_proxy="localhost,127.0.0.0/8,::1"  # Version avec IPV6 qui ne marche pas partout.


# KERBEROS
# ════════════════════════════════════════════════════════════════════════════
#
#   Detect if the environment support Kerberos and configure then accordingly.
if [ -e "/etc/krb5.conf" ]; then
  # Creating alias for often used scripts.
  alias hdkc='hdkerberos-keytab-create'
  alias hdku='hdkerberos-keytab-use'
  alias u='hdku'
fi


# PYTHON - Development environment
# ════════════════════════════════════════════════════════════════════════════
#
#   New development is meant for Python 3 (thus the 3 in the directory of
#   WORKON_HOME.
HD_TMP_PYTHON_VIRTUALENVWRAPPER_PATH=$(which virtualenvwrapper.sh 2>/dev/null)
if [ ! -z "${HD_TMP_PYTHON_VIRTUALENVWRAPPER_PATH}" ]; then
  setVarIfDirsExist WORKON_HOME "${HOME}/.python/3/virtualenvs"
  export VIRTUALENVWRAPPER_PYTHON=$(which python3)
  unset VIRTUALENVWRAPPER_HOOK_DIR
  source virtualenvwrapper.sh >/dev/null 2>&1
fi
unset HD_TMP_PYTHON_VIRTUALENVWRAPPER_PATH

add2path PATH "/usr/local/bin"

# hdat() is a substitute for the at command.  'at' has the following
# shortcommings which hdat fixes:
#
#  - /bin/sh is used to execute the command, not /bin/bash, nor ${SHELL} or
#    the current terminal's shell being used.
#
#  - The at command does not inherit variables that have not been exported.
#
# Test:
#
#   AT_COMMAND_TEST_VAR="This is a test"
#   hdat $(date -d "+7 seconds" +"%H:%M:%S") 'echo $AT_COMMAND_TEST_VAR'
hdat()
{
  local TIME_TARGET="$1"
  shift
  sshenv
  (
    shopt -s expand_aliases      # Inherit aliases from parent Bash.
    hdsleep "${TIME_TARGET}"
    if [ "${1}" == "-m" ]; then
      # Message/reminder option found.  Printing text.
      shift
      zenity --info --text "$@"
    else
      eval $@
    fi
  ) &
  disown
}

alias hdgroups='id -a | sed -r "s/[, ]/\n/g"'  # Shows groups, one group per liene.

# Using ${WSL_DISTRO_NAME} or any other variable does not work under WSL
# if you switch to another account, such as root with 'su - '.  root will
# not have the variable ${WSL_...} set.  Thus the only reliable way is to
# check for the kernel name with 'uname -a'.
if [[ "$(uname -a)" =~ "microsoft" ]]; then
  export DISPLAY=$(/mnt/c/Windows/system32/route.exe print | grep 0.0.0.0 | head -1 | awk '{print $4}'):0.0
fi
