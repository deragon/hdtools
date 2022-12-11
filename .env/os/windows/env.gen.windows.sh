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

# PROBLÈME BIZARRES
# ======================================================================
#
#   Si toute sorte de problèmes bizarres se produisent, comme:
#
#   - bash: cannot create temp file for here document: Permission denied
#   - Bad file descriptor
#
#   Il faut refaire les fichiers suivant:
#
#     mkdir -p /etc/vieux
#     mv /etc/passwd /etc/vieux/.
#     mv /etc/group  /etc/vieux/.
#     mkpasswd -l >/etc/passwd
#     mkgroup  -l >/etc/group
#
#   Réf:  http://www.mail-archive.com/cygwin@cygwin.com/msg29741.html
#
#
#
# MAN PAGES QUI N'AFFICHENT PAS CORRECTEMENT
# ======================================================================
#
#   Si les man pages présentent des codes ESC, suivre les instructions
#   de:
#
#   http://sourceware.org/ml/cygwin/2006-11/msg00552.html
#
#   Voici une copie:
#
#     Change the following line in /usr/share/misc/man.conf:
#
#     NROFF       /usr/bin/nroff -Tlatin1 -mandoc
#
#     to
#
#     NROFF        /usr/bin/nroff -c -mandoc 2>/dev/null
#
#
#
# LOGICIELS INTERESSANTS POUR WINDOWS
# ======================================================================
#
#   "MultiRes" can run at start up. MultiRes - system tray utility
#   allowing quick access to changing desktop resolutions and has the
#   ability to lock the screen refresh rate in WinNT/2K/XP




add2path PATH "${HDENVDIR}/os/windows/bin"


classpathToWindows()
{
  export CLASSPATH=`"${HDENVDIR}/os/windows/bin/hdlinux2windowspaths" "${CLASSPATH}"`
}
exportfunction classpathToWindows
export CLASSPATH_SEPARATOR=";"
classpathToWindows

hd_application_run_executable_windows()
{
  local WIN_PATH

  local SUFFIX=$1;        shift
  local TEXT="$1";        shift
  local EXECUTABLES="$1"; shift
  local ARGS

  declare -a ARGS=()

  for ARG in "$@"; do
    if [ -z "${ARG}" ]; then
      ARGS+=("${ARG}")
    else
      if [[ "${HD_OS_FAMILY,,}" == *"cygwin"* ]]; then
        ARGS+=("$(cygpath -w "$(readlink -f "${ARG}")")")
      else
        ARGS+=("$(wslpath -a -w "$(readlink -f "${ARG}")")")
      fi
    fi
  done

  hd_application_run_executable "${SUFFIX}" "${TEXT}" "${EXECUTABLES}" "${ARGS[@]}"
}

acroread()
{
  hd_application_run_executable_windows ACROREAD "Acrobat reader" "Acrobat.exe|AcroRd32.exe" "$@"
}

alias e='acroread'  # Same alias as under Linux, used to call 'evince'.

word()
{
  hd_application_run_executable_windows MSWORD "Microsoft Word" "WINWORD.EXE" "$@"
}

excel()
{
  hd_application_run_executable_windows MSEXCEL "Microsoft Excel" "EXCEL.EXE" "$@"
}

chrome()
{
  # IMPORTANT:  DO NO APPEND '&' AT THE END BECAUSE IT WILL SPAWN A NEW PROCESS
  #             AND THEREFORE THE VARIABLE HD_APPL_* WILL NOT BE SET.
  #
  #             This will cause a long delay each time this function is called,
  #             instead of only the first time.
  hd_application_run_executable_windows CHROME "Google Chrome" "CHROME.EXE" "$@"
}

meld-win()
{
  hd_application_run_executable_windows MELD "Meld" "MELD.EXE" "$@"
}


for MOUNT_DIR in "/mnt" "/cygdrive" "null"; do
  [ -d "${MOUNT_DIR}" ] && break
done

for LETTER in {a..z}; do
  # The aliases are created only if the drives are available.  This is
  # done to minimize the size of the environment used by not creating
  # useless aliases.
  if [ -d "${MOUNT_DIR}/${LETTER}" ]; then
    eval "alias cd${LETTER}='cdprint /${MOUNT_DIR}/${LETTER}'"
    #eval "alias ${LETTER}:='cdprint /${MOUNT_DIR}/${LETTER}'"
  fi
done

# Remove 'WARNING **: Couldn't connect to accessibility bus' when starting
# GTK apps (such as gvim).
#
# If you do not make use of accessibility features, you can get ride of
# the warning by setting NO_AT_BRIDGE=1.
#
# See:  https://unix.stackexchange.com/questions/230238/x-applications-warn-couldnt-connect-to-accessibility-bus-on-stderr
export NO_AT_BRIDGE=1


# WSLTTY:  MINTTY for WSL https://github.com/mintty/wsltty
if [ -e "${HOME}/AppData/Local/wsltty/bin/mintty.exe" ]; then
  # WSLTTY installed.
  alias cdwslttyconfig='cdprint "${HOME}/AppData/Roaming/wsltty"'
  alias hdterm='"${HOME}/AppData/Local/wsltty/bin/mintty.exe" -w max --WSL= --configdir="C:\Users\derah\AppData\Roaming\wsltty" -~ -'
fi


# FILE MANAGERS
# ════════════════════════════════════════════════════════════════════════════

f()
{
  DIRECTORY="$1"
  [ -z "${DIRECTORY}" ] && DIRECTORY="."

  explorer.exe "${DIRECTORY}" &
}
exportfunction f

set +x
