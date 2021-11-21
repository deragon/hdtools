# Copyright 2000-2021 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html

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



# SETTING 'CYGWIN' VARIABLE TO AVOID THE FOLLOWING WARNING
# ══════════════════════════════════════════════════════════════════════════════
#
#   cygwin warning:
#
#     MS-DOS style path detected: \Program Files (x86)\Java\jre7\lib\ext\QTJava.zip
#     Preferred POSIX equivalent is: /cygdrive/c/Program Files (x86)/Java/jre7/lib/ext/QTJava.zip
#     CYGWIN environment variable option "nodosfilewarning" turns off this warning.
#     Consult the user's guide for more details about POSIX paths:
#       http://cygwin.com/cygwin-ug-net/using.html#using-pathnames
# 
# UPDATE by Hans Deragon (hans@deragon.biz), 2020-05-11 11:58:31 EDT
#
# According to:   https://cygwin.com/cygwin-ug-net/using-cygwinenv.html
# This option is now obsolete.  This paragraph should be deleted after being commented out for a while.
#
#export CYGWIN="nodosfilewarning"


setVarIfDirsExistCygwin()
{
  local VARIABLE_NAME="${1}"
  local DIRECTORY

  shift;
  for DIRECTORY in "$@"; do
    setVarIfDirsExist "${VARIABLE_NAME}" "$(cygpath "${DIRECTORY}")"
    [ ! -z "${!VARIABLE_NAME}" ] && return 1
  done
  return 0
}
export -f setVarIfDirsExistCygwin

# https://stackoverflow.com/questions/4090301/root-user-sudo-equivalent-in-cygwin
alias hdadmin='cygstart --action=runas mintty /bin/bash -il'

setVarIfDirsExistCygwin WIN_DIR_PROGRAMFILES     "/cygdrive/c/Program Files" "/cygdrive/c/Program Files (x86)"
setVarIfDirsExistCygwin WIN_DIR_PROGRAMFILES64   "/cygdrive/c/Program Files"
setVarIfDirsExistCygwin WIN_DIR_PROGRAMFILES32   "/cygdrive/c/Program Files (x86)"
setVarIfDirsExistCygwin WIN_DIR_CYGWIN           "/cygdrive/c/cygwin"
setVarIfDirsExistCygwin WIN_DIR_USER_HOME        $(cygpath "${USERPROFILE}")
setVarIfDirsExistCygwin WIN_DIR_USER_DESKTOP     "${WIN_DIR_USER_HOME}/Bureau"
setVarIfDirsExistCygwin WIN_DIR_USER_DESKTOP     "${WIN_DIR_USER_HOME}/Desktop"
setVarIfDirsExistCygwin WIN_DIR_USER_DOWNLOADS   "${WIN_DIR_USER_HOME}/Downloads"
setVarIfDirsExistCygwin WIN_DIR_USER_FAVORITES   "${WIN_DIR_USER_HOME}/Favoris"
setVarIfDirsExistCygwin WIN_DIR_USER_FAVORITES   "${WIN_DIR_USER_HOME}/Favorites"
setVarIfDirsExistCygwin WIN_DIR_USER_APPLDATA    "${WIN_DIR_USER_HOME}/Application Data"
setVarIfDirsExistCygwin WIN_DIR_USER_STARTUP     "${WIN_DIR_USER_HOME}/Menu Démarrer"
setVarIfDirsExistCygwin WIN_DIR_USER_SENDTO      "${WIN_DIR_USER_HOME}/SendTo"
setVarIfDirsExistCygwin WIN_DIR_USER_MYDOCUMENTS "${WIN_DIR_USER_HOME}/Mes documents"
setVarIfDirsExistCygwin WIN_DIR_USER_MYDOCUMENTS "${WIN_DIR_USER_HOME}/My documents"
setVarIfDirsExistCygwin WIN_DIR_TEMP             "${WIN_DIR_USER_HOME}/AppData/Local/Temp"

export DOWNLOADS_DIR="${WIN_DIR_USER_DOWNLOADS}"

alias cdhome='cdwinhome'
alias cdwinhome='cdprint "${WIN_DIR_USER_HOME}"'
alias cddownloads='cdprint "${WIN_DIR_USER_DOWNLOADS}"'
alias cdprogramfiles='cdprint "${WIN_DIR_PROGRAMFILES}"'
alias cdprogramfiles32='cdprint "${WIN_DIR_PROGRAMFILES32}"'
alias cdprogramfiles64='cdprint "${WIN_DIR_PROGRAMFILES64}"'
alias cddesk='cdprint "${WIN_DIR_USER_DESKTOP}"'
alias cdwinfavorites='cdprint "${WIN_DIR_USER_FAVORITES}"'
alias cdwinappldata='cdprint "${WIN_DIR_USER_APPLDATA}"'
alias cdwinstartup='cdprint "${WIN_DIR_USER_STARTUP}"'
alias cdwinsendto='cdprint "${WIN_DIR_USER_SENDTO}"'
alias cdwindocs='cdprint "${WIN_DIR_USER_MYDOCUMENTS}"'
alias cdwintemp='cdprint "${WIN_DIR_TEMP}"'

alias cdwindows='cdprint /cygdrive/c/WINDOWS'

add2path PATH "${WIN_DIR_PROGRAMFILES}/Mozilla Firefox"
add2path PATH "${WIN_DIR_PROGRAMFILES}/WinZip"
add2path PATH "${WIN_DIR_PROGRAMFILES}/7-Zip"
add2path PATH "$(ls -d1 "${WIN_DIR_PROGRAMFILES}/Microsoft Office/"* 2>/dev/null)"

add2path PATH "/cygdrive/c/Windows/System32"
add2path PATH "/cygdrive/c/Windows"

alias ifconfig='ipconfig'
alias gvim="hdgvim"


hd_application_run_executable_windows()
{
  hd_application_run_executable "$1" "$2" "$3" \
    "$(cygpath -w "$(readlink -f "${4}")")"
}

acroread()
{
  hd_application_run_executable_windows ACROREAD "Acrobat reader" "Acrobat.exe|AcroRd32.exe" "$@"
}

meld()
{
  hd_application_run_executable MELD "Meld" Meld.exe \
    "$(cygpath -w "$(readlink -f "${1}")")" \
    "$(cygpath -w "$(readlink -f "${2}")")"
}


# Comment by Hans Deragon (hans@deragon.biz), 2020-04-08 13:50:07 ric
# Not sure if this is still relevant.  Cygwin sesams to handle UTF-8 pretty well
# these days and all default input configuration work well out of the box.
#[ -e "${HOME}/inputrc-cygwin" ] && cp -p "${HDENVDIR}/os/windows/inputrc-cygwin" "${HOME}/."

alias traceroute='tracert'


# POWERSHELL ═══════════════════════════════════════════════════════════════════
# Adding path of Powershell, latest version.
add2path PATH "$(ls -d1 "/cygdrive/c/WINDOWS/system32/WindowsPowerShell"/* | tail -1)"


# HADOOP ═══════════════════════════════════════════════════════════════════════
if which hadoop >/dev/null 2>&1 ;then
  export HADOOP_CLASSPATH=$(cygpath -pw $(hadoop classpath))
fi

# GIT ══════════════════════════════════════════════════════════════════════════
add2path PATH /usr/libexec/git-core


