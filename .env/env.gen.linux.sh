# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2023 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html
#
# ─────────────────────────────────────────────────── Copyright Notice ─

if ! which chkconfig >/dev/null 2>&1; then
  # For Ubuntu, sysv-rc-conf exist which replaces chkconfig with almost
  # the same CLI.
  if which sysv-rc-conf >/dev/null 2>&1; then
    # 'sudo apt-get install sysv-rc-conf' to install chkconfig like command
    # on debian.  See http://ubuntuforums.org/showthread.php?t=20583
    chkconfig()
    {
      echo "HD: sysv-rc-conf executed since chkconfig does not exist on this system."
      sysv-rc-conf $*
    }
    export -f chkconfig
  fi
fi

hd_syslog_print()
{
  for CMD in /usr/bin/logger /bin/logger /sbin/initlog; do
    if [ -x "${CMD}" ]; then
      ${CMD} $*
      return
    fi
  done

  echo "ERROR:  Could not find any tool to send a message to syslog."
}
exportfunction hd_syslog_print

hdkernellogger()
{
  logger $*
}
export -f hdkernellogger

hd_mount_media()
{
  # Using mapfile to fill the MOUNTMEDIAS as an array.  This way,
  # storage devices containging spaces within their names have no
  # problems.
  #
  # Using lsblk to fetch list of media that is mounted and removable.
  mapfile -t MOUNTMEDIAS < <(lsblk -l -p -o name,rm,hotplug,mountpoint | perl -ne "print if s/.*1\s+1\s(.+)/\1/g")
}
exportfunction hd_mount_media

hans()
{
  if [ -z "${*}" ]; then
    su - hans
  else
    ssh -l hans $*
  fi
}

alias hdjpggoodquality='mogrify -quality 66'  # Change inplace current file to 66% quality.
alias hdgalleryrecompress='ls -1 *jpg | fgrep -v sized | fgrep -v thumb | fgrep -v highlight | xargs mogrify -quality 66'
alias hdimage50all='ls -1 *jpg | egrep -v "(sized|thumb|highlight)" | xargs mogrify -quality 66 -resize 50%'
alias hdimage75all='ls -1 *jpg | egrep -v "(sized|thumb|highlight)" | xargs mogrify -quality 66 -resize 75%'
alias hdimage50='mogrify -quality 66 -resize 50%'

hd-rpm-searchpackage()    { rpm -qa | fgrep -i $*; }
hd-rpm-searchfile()       { rpm -qf `locate $*`; }
hd-rpm-searchexecutable() { rpm -qf `which $*`; }
hd-rpm-extract()          { rpm2cpio $* | cpio -i --make-directories --preserve-modification-time; }
alias hd-rmp-list='rpm -qa | sort | tee rpm.list'

alias lsd='find . -maxdepth 1 -type d -ls'  # List only directories
alias dwd='find . -maxdepth 1 -type d'      # List only directories

add2path PATH /usr/lib/git-core  # git-gui and other git commands.
add2path PATH -b "${HOME}/.local/bin"

alias hdupdate='sudo apt-get update'
alias hdupgrade='sudo snap refresh;sudo apt-get -y dist-upgrade; sudo apt-get -y autoremove'
alias hdmaj='hdupdate;hdupgrade;hdrebootrequired;hddate -n'

if ( type wmctrl >/dev/null 2>&1 ) then
  # Desktop environment detected.
  #
  # Strictly speaking, there might be no desktop running, but if wmctrl is
  # installed on a system, 99% sure that a desktop is running on it.

  alias cdfirefox='cd ${FIREFOX_ACCOUNT}'
  alias cdthunderbird='cd ${THUNDERBIRD_ACCOUNT}'

setX()
{
  # By setting XAUTHORITY to the generated X authority file, lmwu
  # will be able to access localhost:0:0.
  [ -r /var/gdm/:0.Xauth     ] && export XAUTHORITY=/var/gdm/:0.Xauth
  [ -r /var/lib/gdm/:0.Xauth ] && export XAUTHORITY=/var/lib/gdm/:0.Xauth
  export DISPLAY=:0

  if [ -z "${ZENITY}" ]; then
    for ZENITY in /usr/bin/zenity /opt/gnome/bin/zenity zenity; do
      [ -x ${ZENITY} ] && break
    done
  fi
}

hdmsgx()
{
  setX
  local TIME=`date +"%y/%m/%d %H:%M:%S"`
  local TITLE="Message de Hans Deragon, ${TIME}"
  local MESSAGE="${TITLE}\n\n${1}"

  ${ZENITY} --info --title "Message de Hans Deragon" --text "${MESSAGE}" &
  echo -e "Envoyé:\n\n${MESSAGE}"
}

# Apply a theme specifically to an application.
# See:  http://ubuntuforums.org/showthread.php?p=3109273
hd_gtk_theme_safe()
{
  env GTK2_RC_FILES=/usr/share/gdm/themes/Human/gtk-2.0/gtkrc "$@"
}
exportfunction hd_gtk_theme_safe

# setxauth sets the ${XAUTHORITY} variable to the magic cookie file of X.
# If the user has read privileges, the user then can access the X session
# even if the session does not belong to him.  This works well for the
# root user.
setxauth()
{
  if [ -r /var/gdm/:0.Xauth ]; then
    # Usually Red Hat and Fedora distro have the file there.
    export XAUTHORITY="/var/gdm/:0.Xauth"
  elif [ -r /var/lib/gdm/:0.Xauth ]; then
    # Usually SuSE distro have the file there.
    export XAUTHORITY="/var/lib/gdm/:0.Xauth"
  else
    echo "Could not set XAUTHORITY."
    return
  fi

  echo "\${XAUTHORITY} set to ${XAUTHORITY}"
}

  alias hdchromestop='pkill --signal SIGSTOP chrome'
  alias hdchromecont='pkill --signal SIGCONT chrome'

  alias hdstoptb='pkill --signal SIGSTOP thunderbird'
  alias hdconttb='pkill --signal SIGCONT thunderbird'
  alias hdstopff='pkill --signal SIGSTOP firefox'
  alias hdcontff='pkill --signal SIGCONT firefox'

  alias cdconfig='cdprint "${HOME}/.config"'
  alias cdautostart='cdprint "${HOME}/.config/autostart"'
  alias cdterminator='cdprint "${HOME}/.config/terminator"'

  #alias hd-xclock='xclock -digital -update 1 &'

  add2path PATH /opt/cxoffice/bin  # Crossover
  add2path PATH -b "${HD_SOFTWARE_BASE_DIR}/nodist/i386/citrix"
  add2path PATH -b "${HD_SOFTWARE_BASE_DIR}/nodist/i386/acroread/bin"

  alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
  alias cdbattery='cdprint "/sys/devices/platform/smapi/BAT0"; echo "You may use the \"tlp stat\" command for full status."'

  #alias ur='unity --replace &' # Hopefully, temporary alias.

  e()
  {
    ( evince --fullscreen "$@" >/tmp/hd-evince.$$.log ) &
  }
  export -f e


  # FILE MANAGERS
  # ════════════════════════════════════════════════════════════════════════════

  alias n='nautilus . >/dev/null 2>&1 &'
  alias d='dolphin4 . >/dev/null 2>&1 &'
  alias t='thunar . >/dev/null 2>&1 &'
  alias ne='nemo . >/dev/null 2>&1 &'

  f()
  {
    DIRECTORY="$@"
    [ -z "${DIRECTORY}" ] && DIRECTORY="."

    if [ -x "/usr/bin/nautilus" ]; then
      nautilus --new-window "${DIRECTORY}" >/dev/null 2>&1 &
    elif [ -x "/usr/bin/nemo" ]; then
      nemo "${DIRECTORY}" >/dev/null 2>&1 &
    elif [ -x "/usr/bin/dolphin*" ]; then
      dolphin* --new-window "${DIRECTORY}" >/dev/null 2>&1 &
    elif [ -x "/usr/bin/thunar" ]; then
      thunar --new-window "${DIRECTORY}" >/dev/null 2>&1 &
    else
      echo "Sorry, could not identify a suitable filemanager for this platform."
    fi
  }
  exportfunction f

  if [ -e /proc/acpi/ibm/fan ]; then
    # Fan settings for Lenovo T61p and probably other models
    # hdfan is a script found under "${HDENVDIR}/bin"
    alias hdfanmax='hdfan disengaged'
    alias hdfan7='hdfan 7'
    alias hdfanmed='hdfan 4'
    alias hdfanauto='hdfan auto'
  fi

  # Xorg related aliases
  # ════════════════════════════════════════════════════════════════════════════

  disp()
  {
    if [ -z "${1}" ]; then
      echo "\${DISPLAY} value is currently:  ${DISPLAY}"
    else
      export DISPLAY="${1}:0"
      echo "\${DISPLAY} value now set to:  ${DISPLAY}"
    fi
  }

  alias displocal='export DISPLAY=127.0.0.1:0.0;disp'
  alias disp:0='export DISPLAY=:0.0;disp'
  alias dispunset='unset DISPLAY'
  alias dispssh='export DISPLAY=`echo $SSH_CLIENT | sed "s/\([0-9|.]\\+\).*/\1/g"`:0'

  [ -z "${DISPLAY}" ] && export DISPLAY=:0

  # Stupid Gnome 3.26 thinks my laptop is a tablet and upon resume, change the
  # orientation of the screen.  Following are aliases to return the screen to
  # normal.
  alias hdscreenorientationnormal='xrandr -o normal'

fi

alias cddownloads='cdprint "${HOME}/Downloads"'
alias bashr='sudo XMODIFIERS=HDCONNECTION bash --init-file "${HD_CORP_DIR}/gohd" -i'  # bashr == Bash as root

add2path PATH /var/lib/flatpak/exports/bin


# MUSÉE
# ══════════════════════════════════════════════════════════════════════════════

# CD Burning
#alias mountisoimage='mount -t iso9660 -o ro,loop=/dev/loop0'
#alias hd-mountisoimage='mount -t iso9660 -o ro,loop'
#alias hd-mountdvdimage='mount -t udf -o ro,loop'
#alias hd-mountloop='mount -o rw,loop'
#alias hd-burnisoimage='cdrecord -v dev=/dev/sr0 -eject -data'
#alias hd-burnisoimagefedora='cdrecord -v dev=ATA:1,0,0 -eject -data'
#alias hd-burnisoimageold='cdrecord -v speed=8 -isosize dev=0,0,0 -data'
# makeisoimage <ISOFILENAME> <DIRECTORY>
#alias hd-makeisoimage='mkisofs -graft-points -f -J -r -o'
#alias hd-mountcdrom='mount -t iso9660 /dev/cdrom /cdrom'

# Floppy drive mounting.  Since no more floppy drives, we uncomment
# the commandds
#alias hd-mountfloppy='mount -t msdos /dev/fd0 /mnt/floppy'
#alias hd-umountfloppy='umount /mnt/floppy'
