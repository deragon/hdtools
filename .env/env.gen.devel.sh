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

# ══════════════════════════════════════════════════════════════════════════════
# VS Code - Visiual Studio Code

# Starts VS Code of the root directory of a project if the user is
# currently under one or one of its sub-directories, or else starts with
# the current directory.
vsc()
{
  HD_PROJECT_DIR="$(hdprojectdir)"
  [[ -z "${HD_PROJECT_DIR}" ]] && HD_PROJECT_DIR="${PWD}"

  if [[ ! -z "${WSL_DISTRO_NAME}" ]]; then

    # WSL detected.  As of 2026-01-01, VS Code Linux version works badly in
    # WSL (GUI problems).  To get around this, run the Windows version with
    # remote WSL connection.
    #
    # The line below might call the 'code' alias instead
    # of the VS Code binary, which is a desired behavior.
    code --folder-uri "vscode-remote://wsl+${WSL_DISTRO_NAME}${HD_PROJECT_DIR}" $@
  else
    code "${HD_PROJECT_DIR}" $@ &
  fi

  echo "Visual Code started under directory:  '${HD_PROJECT_DIR}'"
}

alias ch='copilot --allow-all-paths --allow-all-tools'



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
type git >/dev/null 2>&1
if (( $? == 0 )); then
  alias hdgpull='git pull --all --prune; git branch -a'
  alias hdgstatus='git status --untracked-files=no'
  alias hdgitgvim='git difftool --tool=hdgvimdiff --no-prompt &'
  alias cdgroot='cdprint "$(git rev-parse --show-toplevel)"'  # Return root directory of current Git repo.

  # Aliases to switch branches very quickly.
  alias gdev='git switch develop'
  alias gmain='git switch main'
  alias gmaster='git switch master'

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
alias hdawsvarprint='printf "
export AWS_ACCESS_KEY_ID=\"${AWS_ACCESS_KEY_ID}\"
export AWS_SECRET_ACCESS_KEY=\"${AWS_SECRET_ACCESS_KEY}\"
export AWS_SESSION_TOKEN=\"${AWS_SESSION_TOKEN}\"
export AWS_REGION=\"${AWS_REGION}\"
"'
hdawsssh() { ssh "ec2-user@$1"; }; exportfunction hdawsssh

# Interesting reading about proxy* variables:
#
#   https://about.gitlab.com/blog/2021/01/27/we-need-to-talk-no-proxy/
#
# 169.254.0.0/16 is a Link-local address (https://en.m.wikipedia.org/wiki/Link-local_address)
# used by AWS and other services and must never have a proxy.
export no_proxy="localhost,127.0.0.0/8,169.254.0.0/16,172.29.154.0/8,${no_proxy}"
export no_proxy="$(echo "${no_proxy}" | tr ',' '\n' | grep -Ev '^\s*$' | sort -u | sed ':a;N;$!ba;s/\n/,/g')"  # Removing duplicate entries.

# export no_proxy="localhost,127.0.0.0/8,::1"  # Version with IPV6 does not work at all.

hdproxyunset()
{
  unset https_proxy
  unset http_proxy
  unset no_proxy
  unset ftp_proxy
  unset gohper_proxy

  unset HTTPS_PROXY
  unset HTTP_PROXY
  unset NO_PROXY
  unset FTP_PROXY
  unset GOHPER_PROXY
}
exportfunction hdproxyunset




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
HD_TMP_PYTHON_VIRTUALENVWRAPPER_PATH=$(type -p virtualenvwrapper.sh 2>/dev/null)
if [ ! -z "${HD_TMP_PYTHON_VIRTUALENVWRAPPER_PATH}" ]; then
  setVarIfDirsExist WORKON_HOME "${HOME}/.python/3/virtualenvs"
  export VIRTUALENVWRAPPER_PYTHON=$(type -p python3)
  unset VIRTUALENVWRAPPER_HOOK_DIR
  source virtualenvwrapper.sh >/dev/null 2>&1

  (( HDENVQUIET != 1 )) && echo -e "${HDANSI[GREEN]}Python virtualenvwrapper.sh loaded.${HDANSI[DEFAULT]}"
fi
unset HD_TMP_PYTHON_VIRTUALENVWRAPPER_PATH

# Python equivalent of 'bash -x'
# From:  https://stackoverflow.com/questions/15760381/what-is-the-python-equivalent-of-set-x-in-shell
# Does not work well.  Need work
#alias hdpyx='python -m trace --ignore-dir "\$\(python -c \'import os, sys; print\(os.pathsep.join\(sys.path[1:]\)\)\'\)" --trace'

hd_python_venv_activate() {
  # Optional parameter: starting directory for the search (defaults to $PWD)
  local start_dir
  start_dir="${1:-$PWD}"

  # Get the project root directory.
  project_root="$(hdprojectdir)"
  if [ -z "$project_root" ]; then
    echo "No project directory found upward from '$start_dir'.  Aborting."
    return
  fi

  # Search for an activation script under the project root
  # Look for paths that end with /bin/activate
  local -a candidates
  # Use find with a null delimiter and mapfile to safely handle paths with spaces
  mapfile -d '' -t candidates < <(find "$project_root" -type f -path '*/bin/activate' -print0 2>/dev/null)

  # If no results, check common venv directory names
  if [ ${#candidates[@]} -eq 0 ]; then
    for name in .venv venv env; do
      local try="$project_root/$name/bin/activate"
      if [ -f "$try" ]; then
        candidates+=("$try")
      fi
    done
  fi

  if [ ${#candidates[@]} -eq 0 ]; then
    echo "No activate script found under '$project_root'" >&2
    return 2
  fi

  # Prefer a candidate that is validated as a venv (presence of pyvenv.cfg or content in activate)
  local chosen=""
  for c in "${candidates[@]}"; do
    # Resolve symlink if necessary
    if [ -L "$c" ]; then
      c=$(readlink -f "$c")
    fi
    # Parent directory of 'bin' is the venv directory
    local venv_dir
    venv_dir=$(dirname "$(dirname "$c")")
    # Simple validation: check for pyvenv.cfg, or first lines of activate contain VIRTUAL_ENV
    if [ -f "$venv_dir/pyvenv.cfg" ]; then
      chosen="$c"
      break
    fi
    if sed -n '1,20p' "$c" 2>/dev/null | grep -q "VIRTUAL_ENV\|virtualenv"; then
      chosen="$c"
      break
    fi
  done

  # If none validated, select the first candidate
  if [ -z "$chosen" ]; then
    chosen="${candidates[0]}"
  fi

  # Verify readability
  if [ ! -r "$chosen" ]; then
    echo "Activation script '$chosen' is not readable" >&2
    return 3
  fi

  echo "Sourcing virtualenv activation script: $chosen"
  # shellcheck disable=SC1090
  . "$chosen"
  return $?
}

# DOCKER
# ══════════════════════════════════════════════════════════════════════════════

alias hddockerimagelist='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}"'


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
