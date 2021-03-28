# Copyright 2000-2021 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this code.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html

# Difference between .bashrc and .bash_profile at:
# http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html

# Unsetting BASH_ENV because if set to ~/.bashrc (which is the default
# on many systems), bash scripts recursively call ~/.bashrc.
unset BASH_ENV

shopt -s expand_aliases

HD_SOURCE_COUNT=0
hd_source()
{
  #let HD_SOURCE_COUNT=HD_SOURCE_COUNT+1
  #date +"%S.%N HD_SOURCE_COUNT=${HD_SOURCE_COUNT}, FILE=$1"
  [ -r "$1" ] && source "$1"
}

if [ -z "${HDENVDIR}" ]; then
  echo "Error:  \${HDENVDIR} is not set.  Aborting loading of environment."
else
  export PATH="${HDENVDIR}/bin:${PATH}"
  export HDENVBASE=`dirname "${HDENVDIR}"`

  # Put calls of source files in double quotes, to account for spaces in
  # ${HDENVDIR} (this happens under cygwin).
  hd_source "${HDENVDIR}/sys.gen.noarch.dash"
  [ "${HD_OS_FAMILY}" = "Linux"  ] && hd_source "${HDENVDIR}/sys.gen.linux.dash"
  [ "${HD_OS_FAMILY}" = "Cygwin" -o "${HD_OS_FAMILY}" = "MinGW" ] && hd_source "${HDENVDIR}/os/windows/sys.gen.windows.bash"
  [ "${HD_OS_FAMILY}" = "Cygwin" ] && hd_source "${HDENVDIR}/os/windows/sys.gen.cygwin.bash"

  hd_source "${HDENVDIR}/sys.gen.noarch.bash"
  [ -r "${HDENVDIR}/personal/env.personal.sh" ] && hd_source "${HDENVDIR}/personal/env.personal.sh"

  #echo "\${MACHTYPE}=${MACHTYPE}"
  case ${MACHTYPE} in
    *linux*)
      hd_source "${HDENVDIR}/env.gen.linux.sh"
      ;;
    *cygwin*)  # Windows
      hd_source "${HDENVDIR}/os/windows/env.gen.cygwin.sh"
      ;;
    *darwin*)  # Mac OS X
      hd_source "${HDENVDIR}/os/macosx/env.gen.macosx.sh"
      ;;
    *aix*)     # IBM AIX
      hd_source "${HDENVDIR}/os/aix/env.gen.aix.sh"
      ;;
  esac

  # CORPORATION SETTINGS
  # ──────────────────────────────────────────────────────────────────
  #
  # Client environment definitions.  These two definitions are the only
  # one allowed under ${HDENVDIR}, for convenience.  Any other definition
  # should be in defined in a source file under ${HD_CORP_DIR}.
  #
  # HD_CORP_IDENTIFIER should be defined after calling
  # "${HDENVDIR}/personal/env.personal.sh".
  if [ ! -z "${HD_CORP_IDENTIFIER}" ]; then
    HD_CORP_DIR="${HDENVBASE}/.${HD_CORP_IDENTIFIER}"
    if [ -d "${HD_CORP_DIR}" ]; then
      export HD_CORP_DIR
      add2path PATH -b "${HD_CORP_DIR}/bin"
      alias cdcorp='cdprint "${HD_CORP_DIR}"'
      alias corp='gvim "${HD_CORP_DIR}/corp.txt"'
    fi
  fi

  # Order is important here.
  hd_source "${HDENVDIR}/env.gen.noarch.bash"
  hd_source "${HDENVDIR}/env.spec.noarch.sh"
  [ -f "${HDENVDIR}/env.${HOSTNAME}.sh" ] && \
  hd_source "${HDENVDIR}/env.${HOSTNAME}.sh"

  # *.home.*.sh files need to be sourced before calling env.devel.sh.  If
  # none is sourced, it is not critical, but if they do, the development
  # is adapted according to the value of ${DATA} and other variables.
  hd_source "${HDENVDIR}/env.gen.devel.sh"

  [ -d "${HOME}/Desktop" ] && hd_source "${HDENVDIR}/env.gen.desktop.bash"
  hd_source "${HDENVDIR}/env.gen.hadoop.sh"

  PATH="${PATH}:."

  if [ -e "${HDENVDIR}/bin/minpath" ]; then
    PATH=`${HDENVDIR}/bin/minpath "${PATH}"`  # For sh compatible shells
    if [ ! -z "${MANPATH}" ]; then
      MANPATH=`${HDENVDIR}/bin/minpath ${MANPATH}`  # For sh compatible shells

      # Default man path are included if MANPATH starts with ':'
      MANPATH=":${MANPATH}"
    fi

    PYTHONPATH=`${HDENVDIR}/bin/minpath "${PYTHONPATH}"`
    if [ "${HD_OS_FAMILY}" = "Cygwin" -o "${HD_OS_FAMILY}" = "MinGW" ]; then
      CLASSPATH=`${HDENVDIR}/bin/minpath -f -d ";" "${CLASSPATH}"`
    else
      CLASSPATH=`${HDENVDIR}/bin/minpath -f "${CLASSPATH}"`
    fi
  fi

  # which gpg-agent >/dev/null
  # if (( $? == 0 )); then
  #   gpg-agent --daemon > ~/.gpg-agent-info
  #  hd_source ~/.gpg-agent-info
  # fi

  export HDENV="Hans Deragon shell environment loaded."
  export PATH
  export MANPATH
  export LD_LIBRARY_PATH
  export INFOPATH
  export PYTHONPATH
  export CLASSPATH

  # Running hd_term_reset at the end gives the user the time to resize the
  # window during the sourcing of the scripts.
  hd_term_reset
  hd_term_title_auto
fi
