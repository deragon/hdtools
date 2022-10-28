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

# Eclipse
# ══════════════════════════════════════════════════════════════════════════════

# ${ECLIPSE_WORKSPACE} need to be setup in another file dependant of the
# environment being executed.  Potential files are:
#
#   - "${HD_CORP_DIR}/env.noarch.pre.sh  # For business environment.

if [ ! -z "${ECLIPSE_WORKSPACE}" ]; then
  alias cdworkspace='cdprint "${ECLIPSE_WORKSPACE}"'

  # ANT not really used anymore.

  # ECLIPSE_ANT_PREF_FILE="${ECLIPSE_WORKSPACE}/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.ant.core.prefs"
  # if [ -f "${ECLIPSE_ANT_PREF_FILE}" ]; then
  #   export ECLIPSE_ANT_CLASSPATH=`perl -ne "s/^\s*ant_home_entries=(.+)/\1/g;s%,%${CLASSPATH_SEPARATOR}%g and print" "${ECLIPSE_ANT_PREF_FILE}"`
  #   export ECLIPSE_ANT_PREF_FILE
  # else
  #   unset ECLIPSE_ANT_PREF_FILE
  # fi

  # ${ECLIPSE_EXE} can be already set from another configuration file, particularly one
  # that is loaded for a particular business, like Vidéotron.
  for ECLIPSE_EXE in ${ECLIPSE_EXE} ${HD_SOFTWARE_NODIST_ARCH_DIR}/eclipse/eclipse ${HDDEVELTOOLS}/eclipse/eclipse /usr/bin/eclipse null; do
    [ -x ${ECLIPSE_EXE} ] && break
    if [ "${ECLIPSE_EXE}" = null ]; then
      unset ECLIPSE_EXE
      break
    fi
  done
  if [ ! -z "${ECLIPSE_EXE}" ]; then
    alias eclipse='runbg "${ECLIPSE_EXE}" -data "${ECLIPSE_WORKSPACE}"'
    alias cdeclipse='cdprint "${ECLIPSE_EXE}"'
  fi
fi



# ══════════════════════════════════════════════════════════════════════════════
# Subversion / SVN - Not used anymore, but we keep it if one day it is needed.

# alias diffxsvn='diff -r --exclude ".svn"'
# svnv() { svn diff --diff-cmd hd-svn-gvimdiff-wrapper $@ & }
# svnl() { svn log $* | less; }


# ══════════════════════════════════════════════════════════════════════════════
# Git
which git >/dev/null 2>&1
if (( $? == 0 )); then
  alias hdgpull='git pull --all --prune'
  alias hdgstatus='git status --untracked-files=no'
  alias hdgitgvim='git difftool --tool=hdgvimdiff --no-prompt &'
  alias cdgroot='cdprint "$(git rev-parse --show-toplevel)"'  # Return root directory of current Git repo.

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
  alias mvnnotest='mvn -Dmaven.test.skip=true -DskipTests'
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


# SDK MAN! - https://sdkman.io/
# ══════════════════════════════════════════════════════════════════════════════
#
#   SDKMAN! is a tool for managing parallel versions of multiple Software
#   Development Kits on most Unix based systems. It provides a convenient
#   Command Line Interface (CLI) and API for installing, switching, removing
#   and listing Candidates. Formerly known as GVM the Groovy enVironment
#   Manager, it was inspired by the very useful RVM and rbenv tools, used at
#   large by the Ruby community.
#
#   Installation:  curl -s "https://get.sdkman.io" | bash

if [ -e "${HOME}/.sdkman/bin/sdkman-init.sh" ]; then
  source "${HOME}/.sdkman/bin/sdkman-init.sh"
fi
