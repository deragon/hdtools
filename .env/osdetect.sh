#!/bin/dash

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

#############################################################
# DESCRIPTION:
#
#   This script sets numerous variables that identifies precisely the
#   distribution.
#
#   This script runs under bash and dash.
#
# WARNING:
#
#   Site administrators should not modify this script!  If you have any
#   problems with the script, please contact LMW administrators at:
#
#   tsg.gde.linux.core@hp.com
#############################################################

# This file is a generic script used to identify the current operating system.
# in a normalized way.
unset HD_OS_PATCHLEVEL

# WARNING:  You cannot call `basename $0` here because this script gets
#           sourced and for an interactive shell, $0 == "-bash", causing the
#           error 'basename: invalid option -- b' to occur.  We avoid this
#           by hardcoding the name here.

BASENAME="osdetect"

if [ -e /etc/fedora-release ]; then
  export HD_OS_CODE="fedora"
  export HD_OS_VERSION=`cat /etc/fedora-release | awk '{print $4}'`
  export HD_OS_NAME="Fedora Core ${HD_OS_VERSION}"
  export HD_OS_ARCH=`uname -i`
elif [ -e /etc/redhat-release ]; then
  export HD_OS_CODE="redhat"
  export HD_OS_ARCH=`uname -i`
  export HD_OS_VERSION="$(cat /etc/redhat-release | grep -oP '(?<=release ).*(?= \()')"
  export HD_OS_PATCHLEVEL=`fgrep Update /etc/redhat-release | perl -pe "s/.*?Update ([\d|\.]+).*/\1/g"`
  export HD_OS_NAME="$(cat /etc/redhat-release)"
elif [ -e /etc/novell-release ]; then
  export HD_OS_CODE="suse"
  if fgrep -q "SUSE Linux Enterprise" /etc/novell-release; then
    DATA=`head -1 /etc/novell-release | sed "s/ Beta.*$//"`
    VERSION=`fgrep VERSION /etc/novell-release | perl -pe "s/^VERSION\s+=\s+(.*)/\1/g"`
    export HD_OS_PATCHLEVEL=`fgrep PATCHLEVEL /etc/novell-release | perl -pe "s/^PATCHLEVEL\s+=\s+(.*)/\1/g"`
    case "${DATA}" in
      "SUSE Linux Enterprise Desktop"*)
         PREFIX="SLED"
         export HD_OS_NAME="SuSE Enterprise Desktop"
      ;;
      "SUSE Linux Enterprise Server"*)
         PREFIX="SLES"
         export HD_OS_NAME="SuSE Enterprise Server"
      ;;
    esac
    export HD_OS_VERSION="${PREFIX}${VERSION}"
    export HD_OS_ARCH=`uname -i`
    export HD_OS_NAME="${HD_OS_NAME} ${VERSION}"
  else
    TMPVERSION=`perl -pe 's%Novell Linux Desktop (\w+) \(.*%$1%g' /etc/novell-release | head -n 1`
    export HD_OS_VERSION="NLD${TMPVERSION}"
    export HD_OS_NAME="Novell Linux Desktop ${TMPVERSION}"
    export HD_OS_ARCH=`uname -i`
  fi
elif [ -e /etc/SuSE-release ]; then
  DATA=`head -1 /etc/SuSE-release`
  export HD_OS_CODE="suse"
  export HD_OS_PATCHLEVEL=`fgrep PATCHLEVEL /etc/SuSE-release | perl -pe "s/^PATCHLEVEL\s+=\s+(.*)/\1/g"`
  [ ! -z "${HD_OS_PATCHLEVEL}" ] && \
    export HD_OS_NAME="${HD_OS_NAME} SP${HD_OS_PATCHLEVEL}"
  case "${DATA}" in
    "SuSE SLES-8 (i386)")
       export HD_OS_VERSION="SLES8"
       export HD_OS_NAME="SuSE Enterprise 8"
       export HD_OS_ARCH=`cat /etc/SuSE-release | head -1 | sed "s/.*(\(.*\))/\1/"`
    ;;
    "SUSE LINUX Enterprise Server 9 (i586)")
       export HD_OS_VERSION="SLES9"
       export HD_OS_NAME="SuSE Enterprise 9"
       export HD_OS_ARCH=`uname -i`
    ;;
  esac
elif [ -r /etc/lsb-release ]; then
  . /etc/lsb-release
  export HD_OS_NAME="${DISTRIB_DESCRIPTION}"
  export HD_OS_VERSION="${DISTRIB_RELEASE}"
  export HD_OS_ARCH=`uname -i`
  export HD_OS_CODE=`echo ${DISTRIB_ID} | tr "[A-Z]" "[a-z]"`
else
  export HD_OS_CODE="not detected"
  export HD_OS_VERSION="not detected"
  export HD_OS_ARCH="not detected"
  export HD_OS_NAME="not detected"
fi

if [ "${HD_OS_ARCH}" = "unknown" ]; then
  # "uname -i" returned "unknown".  Trying some other way to figure the
  # hardware platform.
  MACHINEPLATFORM=`uname -m`
  case "${MACHINEPLATFORM}" in
    "i386" | "i486" | "i586" | "i686")
       export HD_OS_ARCH="i386"
    ;;
    "sun4v")
      TMP_PLATFORM=`uname -i`
      export HD_OS_ARCH=`/usr/platform/${TMP_PLATFORM}/sbin/prtdiag | perl -ne "print if s/^System Configuration:\s+(Sun Microsystems\s+)(.*)/\2/g"`
    ;;
    *)
      export HD_OS_ARCH="not detected"
    ;;
  esac
fi

[ ! -z "${HD_OS_PATCHLEVEL}" ] && \
  export HD_OS_NAME="${HD_OS_NAME} SP${HD_OS_PATCHLEVEL}"

export HD_OS_FAMILY=`uname`

HD_OS_ID="${HD_OS_CODE}-${HD_OS_VERSION}-${HD_OS_ARCH}"
[ -z "${HD_OS_PATCHLEVEL}" ] && HD_OS_PATCHLEVEL="0"
if [ "${HD_OS_PATCHLEVEL}" != "0" ]; then
  HD_OS_ID="${HD_OS_ID}-${HD_OS_PATCHLEVEL}"
fi

if [[ "$(uname -a)" =~ "microsoft" ]]; then
  export HD_OS_FAMILY="Windows Subsystem for Linux (WSL)"
fi

if [ -z "${HD_OS_FAMILY%%*CYGWIN*}" ]; then
  export HD_OS_ARCH=$(uname -m)
  export HD_OS_FAMILY="Cygwin"
  export HD_OS_NAME=$(uname)
  export HD_OS_VERSION=$(uname -r)
  export HD_OS_CODE="cygwin"
elif [ -z "${HD_OS_FAMILY%%*MINGW*}" ]; then
  export HD_OS_ARCH=$(uname -m)
  export HD_OS_FAMILY="MinGW"
  export HD_OS_NAME="Minimalist GNU for Windows"
  export HD_OS_VERSION=$(uname -r)
  export HD_OS_CODE="mingw"
fi

osdetect_usage()
{
  cat <<EOM
usage:  ${BASENAME} [-p] [-h]

  -p    Print Values of variables set.
  -h    Print this help text.
EOM
  exit 1
}

while getopts ":ph" OPTCMD; do
  case ${OPTCMD} in
    p) env | egrep "^HD_OS_" | sort
       shift;;
    h) osdetect_usage;;
    *) echo -e "ERROR:  -${OPTARG} option not supported.\n"; osdetect_usage;;
  esac
done
