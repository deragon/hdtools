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

hd_SetVariableIfNotAlreadySet()
{
  VARIABLE=$1
  VALUE=$2
  eval "export RESULT=\$${1}"
  if [ -z "${RESULT}"  ]; then
    eval "export ${VARIABLE}='${VALUE}'"
    #[ "${HD_OUTPUT_SUPPRESS}" != "0" ] && \
      #echo "${VARIABLE} set to value '${VALUE}'"
  #else
  #  echo "$VARIABLE already set to ${RESULT}"
  fi
}
export -f hd_SetVariableIfNotAlreadySet

# $1 is the variable name to set
# $2-* are the directories to test existance.
hd_setVarToExistingDir()
{
  VARNAME=$1
  eval ${VARNAME}=""
  shift

  for DIR in $*; do
    if [ -d "${DIR}" ]; then
      eval export ${VARNAME}="${DIR}"
      return 0
    fi
  done
  return 1
}
export -f hd_setVarToExistingDir

hd_term_title() {

  printf "\033]0;$@\007"

  # From 'man bash'
  #
  # PROMPT_COMMAND - If set, the value is executed as a command prior to
  # issuing each primary prompt.
  #
  # Certains environments configurent cette variable avec une commande
  # qui réassigne le titre du terminal, allant à l'encontre de cette
  # fonction.  Pour éviter le problème, il faut le déconfigurer.
  unset PROMPT_COMMAND
}
exportfunction hd_term_title

hd_term_title_auto()
{
  local TITLE_PREFIX
  if (( ! ${HD_IS_REMOTE} )) && [ "${PWD}" == "${HOME}" ]; then
    TITLE_PREFIX="🏠"
  else
    TITLE_PREFIX="${HD_TITLE}${PWD/*\/}"
  fi

  hdisroot && TITLE_PREFIX="⚠ ${TITLE_PREFIX}"
  hd_term_title "${TITLE_PREFIX} - ${USER}@${HOSTNAME_FQDN} - ${PWD}"
}
exportfunction hd_term_title_auto

# If bash is called recursively when a bash script is called, comment out
# in .bash_profile:
#hd_Replace "s%^(\s*BASH_ENV\s*=.*)%#\1 # Commented out by HD to avoid bash being recalled recusively.%g" ${HOME}/.bash_profile

hd_setHardware

# Set ${HD_LMW_MACHINE_EMULATELAPTOP} to "on" to emulate a laptop.
# This is usefull for testing laptop features on a desktop machines,
# for debugging purposes.
hd_IsLaptop()
{
  [ "${HD_LMW_MACHINE_EMULATELAPTOP}" == "on" ] && return 0

  # 646066U == Lenovo T61
  case "${HD_HARDWARE}" in
    *9470m*|*4318CTO*|*nc6000*|*nc8000*|*nw8240*|*nw8440*|*8510w*|*646066U*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
export -f hd_IsLaptop

if hd_IsLaptop; then
  export LAPTOPUSERNAME="${USER}"
  export LAPTOPHOME="${HOME}"
  export LAPTOPHOSTNAME="${HOSTNAME}"
fi

if [ ! -z "${SSH_CLIENT}" ]; then
  #export HD_SSH_CLIENT_IP=`echo $SSH_CLIENT | cut -f1 -d" "`
  export HD_SSH_CLIENT_IP="${SSH_CLIENT/ *}"
  if [ "${HD_OS_FAMILY}" = "Linux" ]; then
    export HD_SSH_CLIENT_FQDN=$(dig +noall +short -x "${HD_SSH_CLIENT_IP}" | head -n 1)
    HD_SSH_CLIENT_FQDN="${HD_SSH_CLIENT_FQDN%.}"
  else
    export HD_SSH_CLIENT_FQDN="Not implemented."
  fi
fi

set show-all-if-ambiguous on

# For codes, see:
#
#   https://en.wikipedia.org/wiki/ANSI_escape_code
#   http://misc.flogisoft.com/bash/tip_colors_and_formatting
#   https://github.com/robertknight/konsole/blob/master/developer-doc/old-documents/More/villanova-vt100-esc-codes.txt
export HD_SCREEN_EFFECT_REVERSE="\e[07m"
export HD_SCREEN_COLOR_RED="\e[1;31m"
export HD_SCREEN_COLOR_YELLOW="\e[1;33m"
export HD_SCREEN_COLOR_GREEN="\e[1;32m"
export HD_SCREEN_COLOR_BLUE="\e[1;34m"
export HD_SCREEN_COLOR_DEFAULT="\e[0;00m"
export HD_SCREEN_ATTRIBUTES_BLINK="\e[5m"
export HD_SCREEN_ATTRIBUTES_OFF="\e[0m"
export HD_SCREEN_COLOR_WHITE_ON_RED="\e[1;37;41m"

export HD_SCREEN_BG_COLOR_RED="\e]11;#440000\a"
export HD_SCREEN_BG_COLOR_GREEN="\e]11;#003300\a"
export HD_SCREEN_BG_COLOR_BLUE="\e]11;#000033\a"
export HD_SCREEN_BG_COLOR_BLACK="\e]11;#000000\a"

alias redbg='echo -ne "${HD_SCREEN_BG_COLOR_RED}"'
alias greenbg='echo -ne "${HD_SCREEN_BG_COLOR_GREEN}"'
alias bluebg='echo -ne "${HD_SCREEN_BG_COLOR_BLUE}"'
alias blackbg='echo -ne "${HD_SCREEN_BG_COLOR_BLACK}"'

hd_term_color_bg()
{
  # For description of '\e]11;#XXXXXX\a' code, see:
  #
  #   https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
  #
  # Search for 'ESC]11;' within the page.  This works for Cygwin's mintty.
  if [[ "${HD_PRD_HOSTNAMES[@]}" =~ "${HOSTNAME}" ]]; then
    #echo -ne '\e]11;#440000\a' # Red background
    redbg
  elif [[ "${HD_QA_HOSTNAMES[@]}" =~ "${HOSTNAME}" ]]; then
    #echo -ne '\e]11;#000033\a' # Blue background
    bluebg
  elif [[ "${HD_DEV_HOSTNAMES[@]}" =~ "${HOSTNAME}" ]]; then
    #echo -ne '\e]11;#003300\a' # Green background
    greenbg
  else
    #echo -ne '\e]11;#000000\a' # Black background
    blackbg
  fi
}
exportfunction hd_term_color_bg

hdwarning()
{
  echo -e "${HD_SCREEN_COLOR_YELLOW}WARNING:${HD_SCREEN_COLOR_DEFAULT}  $*"
}

hderror()
{
  echo -e "${HD_SCREEN_COLOR_RED}ERROR:${HD_SCREEN_COLOR_DEFAULT}  $*"
}



# Overwriting commands that are dangerous on some Unix systems such as
# Solaris, AIX, HP-UX and others.
#
# - 'hostname', when called with arguments, will actually set the hostname
#   as the parameter.  For instance, calling 'hostname -f' on Solaris will
#   set the hostname to '-f' instead of returning the FQDN like under Linux.
#
# - 'killall' is dangerous on any other platform than does not uses the GNU
#   version.  It actually kills all processes, thus killing the OS.
if ! [[ "${HD_OS_FAMILY}" =~ "Linux"  ||
        "${HD_OS_FAMILY}" =~ "Cygwin" ||
        "${HD_OS_FAMILY}" =~ "Darwin"    ]]; then

  alias hostname="${HDENVDIR}/bin/hdhostname"
  alias killall="echo -e \"killall is dangerous on any other platform than Linux.\nIt is disabled here.  Escape it if you really want to use this command.\""
fi

# When performing an su command without the '-', the variable USER is not
# set properly.  We are fixing this here.

# PROMPT
#
# From Google Groups:
#
# The problem is that bash is counting the characters that it
# outputs when emitting the prompt so that it can know when the
# line wraps (for the sake of command-editing).  You can use the
# \[ \] escapes to delimit a control sequence which has an
# effective width of zero.

# ${USER} is usually defined by the OS, thus no point in setting it here.
if [ "${HD_OS_FAMILY}" = "SunOS" ]; then
  #export USER=`id | sed "s/[^ ]*(\([a-z]*\)).*/\1/"`
  export HD_USERID=`id | sed "s/uid=\([0-9]*\).*/\1/"`
else
  #export USER=`id -un`
  export HD_USERID=`id -u`
fi

export MAIL="/var/mail/${USER}"

# Comment by Hans Deragon, 2008/07/03, 12:52 EDT (CA)
# On AIX, ${LOGNAME} variable is readonly, causing an error to show on
# the screen if assigned.  This said, what tools make use of this?
# None of the scripts in ${HDENVBASE} do.  ${USER} is preferred.
#export LOGNAME=${USER}

export HD_IS_REMOTE=0  # 1 = true, 0 = false
if (( ${HD_BASH_INTERACTIVE} )); then

  if [ "${HD_OS_FAMILY}" = "Linux" ]; then
    # Absolutely need to use pstree here so that when we 'su' or 'sudo', we
    # still detect that we are remote.  SSH_CLIENT is not set for subshells.
    #
    # See (search for 'Deragon'):
    # http://serverfault.com/questions/187712/how-to-determine-if-im-logged-in-via-ssh/773890#773890

    pstree -p | egrep --quiet --extended-regexp ".*sshd.*\($$\)"
    export HD_IS_REMOTE=$((! $?))  # 1 = true, 0 = false
  else
    # pstree on Mac OS X is different, thus we use the less reliable way to
    # figure out if we are remote using SSH_CLIENT.  SSH_CLIENT is not set for
    # subshells, thus in these scenarios, it is not reliable.
    #
    # On AIX, pstree is not even available.
    [ -z "${SSH_CLIENT}" ]
    export HD_IS_REMOTE=$?  # 1 = true, 0 = false
  fi

  # To figure out if the USER is root, we must compare with
  # ${HD_USERID}.  Do not check ${USER} because some other root
  # users (users with a username other than "root" but
  # with a HD_USERID of 0) would not be catched.
  if hdisroot ; then
    HD_SCREEN_COLORSET_USER="\[${HD_SCREEN_COLOR_WHITE_ON_RED}\]"
  elif [[ "${HD_USERS_EQUIVALENCE[@]}" =~ "${USER,,}" ]]; then
    # ${USER} matches one of the userids that are related to the current person.
    # We show the userid in green in this circumstance.
    HD_SCREEN_COLORSET_USER="\[${HD_SCREEN_COLOR_GREEN}\]"
  else
    HD_SCREEN_COLORSET_USER="\[${HD_SCREEN_COLOR_YELLOW}\]"
  fi
  unset HD_TMP_USERNAME

  HD_SCREEN_COLORSET_HOST="\[${HD_SCREEN_COLOR_GREEN}\]"

  if [[ "${HD_PRD_HOSTNAMES[@]}" =~ "${HOSTNAME}" ]]; then
    # If production server, we set the host color to red.
    HD_SCREEN_COLORSET_HOST="\[${HD_SCREEN_COLOR_WHITE_ON_RED}\]"
  else
    # If remote, we set the host color to yellow.
    (( ${HD_IS_REMOTE} )) && \
          HD_SCREEN_COLORSET_HOST="\[${HD_SCREEN_COLOR_YELLOW}\]"
  fi

  HD_BASH_PS_USER="${HD_SCREEN_COLORSET_USER}\u\[${HD_SCREEN_COLOR_DEFAULT}\]"
  HD_BASH_PS_HOST="${HD_SCREEN_COLORSET_HOST}\h\[${HD_SCREEN_COLOR_DEFAULT}\]"

  # Under ubuntu, if PS1 is set, it might not be possible to set it
  # again here, i.e. the following command will simply fail.  You
  # need to comment out any PS1 setting in the default .bashrc.
  if [ -z "${STY}" ]; then
    export HD_BASH_PS1="[${HD_BASH_PS_USER}@${HD_BASH_PS_HOST} \W] "
  else
    # We are under a 'screen' session.  Changing brackets.
    export HD_BASH_PS1="•${HD_BASH_PS_USER}@${HD_BASH_PS_HOST} \W• "
  fi
  export PS1="${HD_BASH_PS1}"
  alias hd-bash-prompt-normal='export PS1="${HD_BASH_PS1}"'
  alias hd-bash-prompt-short='export PS1="> "'

  hd_term_color_bg
fi

# ----------------------------------------------------------------------
# Bash
#export BASH_ENV=${HDENVDIR}/env.sh

# Options pour mettre en service les alias lorsque le shell est appelé
# non interactivement.  Nécessaire pour pouvoir appeler des alias à partir
# de commande appelées à partir de VIM.
shopt -s expand_aliases >/dev/null 2>&1

# Add a key only if it does already loaded in ssh-agent.
hdsshadd()
{
  SSH_KEY_FILE="$1"
  if [ -r "${SSH_KEY_FILE}" ]; then
    if ! ssh-add -l | fgrep -q "${SSH_KEY_FILE}"; then
      ssh-add "${SSH_KEY_FILE}"
    fi
  else
    echo "Could not read file:  '${SSH_KEY_FILE}'."
  fi
}
exportfunction hdsshadd

sshenv()
{
  "${HDENVDIR}/bin/ssh-agent-setup" -q

  # HOSTNAME may actually contain the domain name (it happens under Mac OS X).
  # Thus we truncate it at the '.', if any.
  export SSH_ENV="${HOME}/.ssh/env/${HOSTNAME/.*}"
  source ~/.ssh/env/${HOSTNAME/.*}.sh

  # Check if any production key is in used, and warn the USER if such
  # is the case.
  ssh-add -L | egrep -q ".*?prd$"
  if (($? == 0 )); then
    echo -e "${HD_SCREEN_COLOR_RED}${HD_SCREEN_ATTRIBUTES_BLINK}WARNING:  SSH production key in use.${HD_SCREEN_COLOR_DEFAULT}"
  fi
}
exportfunction sshenv

ssh()
{
  local QUIET=0
  local TITLE=""

  declare -a SSH_ARGS  # Arrays are local by default, so no problem here.

  while [ -n "${1}" ]; do
    case "${1}" in
      --hd-ssh-quiet)  QUIET=1;            shift;;
      --hd-title)      TITLE="${2}";       shift 2;;
      *)               SSH_ARGS+=("${1}"); shift;;
    esac
  done

  (( ! QUIET )) && echo "SSH - Connecting args:  ${SSH_ARGS[*]}"
  sshenv

  [ -z "${TITLE}" ] && TITLE=`echo "${SSH_ARGS[*]}$" | perl -pe "s%(\S+)@(\S+)%\1 - \2%g"`

  hd_term_title "${TITLE}"


  # Using XMODIFIERS to signal that HD (Hans Deragon) is connecting.
  #
  # This variable is 99% of the time accepted by the sshd server.  On the
  # server, search for 'AcceptEnv' in /etc/ssh/sshd_config for the list of
  # variables that are allowed to be passed.
  #
  # See:  https://superuser.com/questions/163167/when-sshing-how-can-i-set-an-environment-variable-on-the-server-that-changes-f

  XMODIFIERS_BACKUP="${XMODIFIERS}"
  export XMODIFIERS="HDCONNECTION"
  /usr/bin/ssh -o SendEnv="XMODIFIERS" -Y "${SSH_ARGS[@]}"
  XMODIFIERS="${XMODIFIERS_BACKUP}"
  hd_term_title_auto        # Restore terminal title.
  hd_term_color_bg          # Restore terminal color background.
}
exportfunction ssh

alias sshforcepasswd='ssh -o PubkeyAuthentication=no'

scp()
{
  # IMPORTANT:  Do not print anything in this function, because it disrupts
  #             the scp process on the remote machine when running.
  sshenv
  env scp -p "$@"
}
exportfunction scp

alias hd-ssh-prd-add='hdsshadd "${HOME}/.ssh/id_rsa_prd"'
alias hd-ssh-prd-rm='ssh-add -d "${HOME}/.ssh/id_rsa_prd"'
alias hd-ssh-unset='unset SSH_AGENT_PID SSH_AUTH_SOCK; unalias ssh'
alias hd-ssh-all='sshenv; hd-ssh-prd-add'

# Command 'host' is deprecated.  Need to use dig, but with the option
# '+short' to have the same output as 'host'
alias hdhost='dig +short'

# gpgenv()
# {
#   ${HDENVDIR}/bin/gpg-agent-setup -q
#   . ~/.gpg/env/${HOSTNAME}.sh
# }
# exportfunction gpgenv
#
# gpg()
# {
#   echo "gpg - Connecting args:  $*"
#   gpgenv
#   env gpg $*
# }
# exportfunction gpg

alias rsyncdeep='rsync --copy-links --partial --sparse --delete-after --times --delete-after -vv --compress --recursive'

# LS_COLORS
# ======================================================================
#
# Lire:  man dir_colors
#
# On combine les options, i.e. on ajoute autant de ';' au besoin.
#
# Par exemple:  *.txt=01;04;31;44
#
#               01 = Bright
#               04 = Underline
#               31 = Red foreground
#               44 = Blue background
#
#               *.txt=01;33
#
#               01 = Bright
#               31 = Yellow foreground
#
# De http://chl.be/glmf/www.linuxmag-france.org/old/lm6/lscoul.html :
#
#   Le codage des attributs et des couleurs est simple. Nous avons, tout
#   d'abord, les codes d'attributs :
#
#   00=aucun, 01=gras, 04=souligné, 05=clignotant, 07=inversé, 08=caché
#
#   Voyons maintenant les différentes couleurs d'avant plan :
#
#   30=noir, 31=rouge, 32=vert, 33=jaune, 34=bleu, 35=magenta, 36=cyan,
#   37=blanc
#
#   Enfin, à une dizaine près, les codes de couleurs d'arrière plan sont
#   identiques:
#
#   40=noir, 41=rouge, 42=vert, 43=jaune, 44=bleu, 45=magenta, 46=cyan,
#   47=blanc
#
#   Il est possible de combiner plusieurs de ces codes comme dans notre
#   exemple pour obtenir plus de couleurs (gras + couleur).
#
#   Quelques limitations matérielles empêchent, cependant, certaines
#   combinaisons. Par exemple, il est impossible d'obtenir un arrière plan
#   en gras.
#
# Executez ${HDENVDIR}/bin/lscolortable pour une table avec toute les couleurs.

LS_COLORS=""
LS_COLORS="${LS_COLORS}:*.csr=01;31;44:*.crt=01;31;44:*.key=01;31;44:*.p12=01;31;44:*.pem=01;31;44:*.pfx=01;31;44:*.txt.gpg=01;31;44"
LS_COLORS="${LS_COLORS}:*.deb=0;35:*.rpm=0;35:*.pkg=0;35:*.jar=0;35:*.war=0;35:*.tgz=0;35:*.tar=0;35:*.zip=0;35:*.arg=0;35:*.lzh=0;35:*.arc=0;35:*.gz=0;35:*.Z=0;35:*.iso=0;35:*.bz2=0;35:*.iso=0;35"
LS_COLORS="${LS_COLORS}:*.php=1;32:*.py=1;32:*.ph=1;32:*.h=1;32:*.c=1;32:*.cc=1;32:*.cpp=1;32:*.pas=1;32:*.asm=1;32:*.bas=1;32:*.java=1;32:*.groovy=1;32:*.scala=1;32:*.jsp=1;32:*.js=1;32:*.vim=1;32"
LS_COLORS="${LS_COLORS}:*.pif=1;34:*.sys=1;34"
LS_COLORS="${LS_COLORS}:*.gif=1;36:*.jpg=1;36:*.ras=1;36:*.cdr=1;36:*.bmp=1;36:*.pcx=1;36:*.eps=1;36:*.cgm=1;36:*.svg=1;36:*.svgz=1;36:*.png=1;36:*.avi=1;36:*.xcf=1;36:*.pbm=1;36:*.pnm=1;36:*.mp4=1;36:*.mkv=1;36:*.webm=1;36:*.webp=1;36:*.ico=1;36"
LS_COLORS="${LS_COLORS}:*.ogg=2;36:*.mp3=2;36:*.3gp=2;36:*.flv=2;36:*.wav=2;36"
LS_COLORS="${LS_COLORS}:*.bak=31:*.tmp=31:*.org=31:*.orig=31:*.obsolete=31:*.class=1;31"
LS_COLORS="${LS_COLORS}:di=1;37:ex=3;33:*.bat=3;33:*.com=3;33:*.exe=3;33"
LS_COLORS="${LS_COLORS}:*.in=1;33:*.sh=1;33:*.bash=1;33:*.dash=1;33:*.csh=1;33:*.pig=1;33:*.css=1;33:*.sgm=1;33:*.dsl=1;33:*.rtf=1;33:*.sgml=1;33:*.shtml=1;33:*.html=1;33:*.xhtml=1;33:*.htm=1;33:*.php=1;33:*.faq=1;33:*.pdf.bz2=1;33:*.pdf=1;33:*.ps=1;33:*.properties=1;33:*.xml=1;33:*.txt=1;33:*.eml=1;33:*.cfg=1;33:*.conf=1;33:*.rpmnew=1;33:*.rpmsave=1;33:*.xls=1;33:*.xlsx=1;33:*.xlsm=1;33:*.doc=1;33:*.docx=1;33:*.vsd=1;33:*.vsdx=1;33:*.pps=133;:*.ppsx=1;33:*.ppt=1;33:*.pptx=1;33:*.ini=1;33:*.me=1;33:*.w51=1;33:*.sam=1;33:*.frm=1;33:*.sxw=1;33:*.sxc=1;33:*.odt=1;33:*.ods=1;33:*.odp=1;33:*.odg=1;33:*.docbook=1;33:*.sql=1;33:*.hql=1;33:*.out=1;33:*.lst=1;33:*.ldif=1;33:*.log=1;33:*.csv=1;33:*.tsv=1;33:*.md=1;33:*.json=1;33:*.yaml=1;33:*.yml=1;33:*.avsc=1;33:*.avro=1;33:*.epub=1;33:*.mobi=1;33:*.iml=1;33:*.rst=1;33:*.xopp=1;33:*.tf=1;33:*.tfvars=1;33"
export LS_COLORS

# 2010/02/25:
#
# --show-control-chars    To show Unicode characters.
#                         Useful for Cygwin, not necessary for Linux
export LS_OPTIONS="--color=auto --show-control-chars"

HD_BINARY_LS="/bin/ls"

if [ "${HD_OS_FAMILY}" != "Linux" ]; then

  # gnubin/ls         --> Mac OSX
  # /usr/linux/bin/ls --> AIX
  for HD_BINARY_LS in \
    $(echo /usr/local/Cellar/coreutils/*/libexec/gnubin/ls) \
    /usr/linux/bin/ls \
    ${HD_BINARY_LS} \
    ; do
    [ -x "${HD_BINARY_LS}" ] && break
  done
fi

# if [ "${HD_OS_FAMILY}" = "Darwin" ]; then
#   HD_BINARY_LS_MAC=$(echo /usr/local/Cellar/coreutils/*/libexec/gnubin/ls)
#   if [ -x "${HD_BINARY_LS_MAC}" ]; then
#     # Mac machine with gnu tools installled using brew detected.
#     HD_BINARY_LS="${HD_BINARY_LS_MAC}"
#   fi
# elif [ "${HD_OS_FAMILY}" = "AIX" ]; then
#
# fi

alias ls="${HD_BINARY_LS} ${LS_OPTIONS}"
alias dir="${HD_BINARY_LS} ${LS_OPTIONS} -l"
alias dirt="${HD_BINARY_LS} ${LS_OPTIONS} -lrt"
alias d='dir'
alias dw="ls"

unset HD_BINARY_LS HD_BINARY_LS_MAC # Reduce bash environment memory.

if [ "${MACHTYPE/*solaris*/x}" = "x" ]; then
  export LS_OPTIONS=""
  alias manpath='echo $MANPATH'
  #export MACHOS="solaris"
  alias disphost='export DISPLAY=`hostname`:0.0;disp'
elif [ "${MACHTYPE/*aix*/x}" = "x" ]; then
  export LS_OPTIONS=""
  alias disphost='export DISPLAY=`hostname`:0.0;disp'
elif [ "${MACHTYPE/*cygwin*/x}"  = "x" ]; then
  #export MACHOS="cygwin"
  alias disphost='export DISPLAY=`hostname`:0.0;disp'
elif [ "${MACHTYPE/*linux*/x}"  = "x" -o \
       "${MACHTYPE/*redhat*/x}" = "x" -o \
       "${MACHTYPE/*suse*/x}"   = "x" -o \
       "${MACHTYPE/*i386*/x}"   = "x" ]; then
  #export MACHOS="linux"
  alias disphost='export DISPLAY=`hostname -f`:0.0;disp'
fi

if [ -e /usr/bin/less ]; then
  export PAGER=/usr/bin/less
else
  # Crappy OS such as HP-UX does not even have 'less'...
  export PAGER=more
fi

alias maillog='tail -f /var/log/maillog | logcolorise.pl'

# alias rpm686build="rpmbuild --rebuild --target=i686"
# alias rpm586build="rpmbuild --rebuild --target=i586"
# alias rpm386build="rpmbuild --rebuild --target=i386"
# alias rpmatlhonbuild="rpmbuild --rebuild --target=athlon"
# alias rpmlist="rpm -qa | sort | tee ~/rpm.list";

alias hdsource='. "${HDENVDIR}/bashrc.gen"'
alias x=exit
alias grep='\grep --color=auto'
alias fgrep='\fgrep --color=auto'
alias egrep='\egrep --color=auto'
alias md='mkdir -p'
alias hdmd='eval "$(hdbackup -d)";hdcanonical -n; echo "cd $(hdcanonical)"'
alias rd='rmdir'
alias xrd='rm -r -f'
alias cl='clear'
alias po='popd;hdtermtitleauto'
alias pu='pushd .'
alias path='echo $PATH'
alias spath='splitpath PATH'
alias classpath='splitpath CLASSPATH ${CLASSPATH_SEPARATOR}'
alias cwd='cd `pwd`'
alias delbak="rm *.bak *~"
alias dirtext="ls -l --ignore-backups *.txt *.pdf *.od? *.sd? *.doc* *.xls* 2>/dev/null"
alias hdperlpath='perl -e "print @INC, \"\n\";"'
alias devices='cat /proc/devices'
alias hdcertificatedesc='openssl x509 -text -in'

alias mirrorwget='wget -p --convert-links --mirror --no-parent --no-host-directories --cut-dirs=99'

runbg()
{
  local CMD="${@}"
  echo "Starting:  ${CMD} &"
  eval "${CMD}" &
}

runx()        { X -query $1 :1; }

# CD aliases - Create 'c<n>' aliases such as c1, c2, etc...
unset TMP_DIR
for (( TMP_INDEX=1; TMP_INDEX<=9; TMP_INDEX++ )); do
  TMP_DIR="${TMP_DIR}../"
  alias c${TMP_INDEX}="cdprint '${TMP_DIR}'"
done
unset TMP_INDEX TMP_DIR

alias cp='cp -p'

cdup()
{
  local DEEP=$1
  local DIR
  LOCAL INDEX

  [ -z "${DEEP}" ] && DEEP=1

  for(( INDEX=0; INDEX < DEEP; INDEX++)); do
    DIR="${DIR}../"
  done

  cdprint "${DIR}"
}

alias cdinit='cd /etc/init.d'
alias cdlog='cd /var/log'
#alias locateupdate='/usr/bin/updatedb -f "nfs,smbfs,ncpfs,proc,devpts" -e "/tmp,/var/tmp,/usr/tmp,/afs,/net"'

alias hd-firewall-list-nat='iptables -t nat --list -n -v'
alias hd-firewall-list='iptables --list -n -v'
alias hd-find-executables='find . -name "*" -perm +111 -type f'
alias hd-vinfo='info --vi-keys'
alias hd-utf2iso8859-1='recode -v UTF-8..ISO-8859-1'
alias hd-iso8859-12utf='recode -v ISO-8859-1..UTF-8'
alias addcurpath='export PATH=`pwd`:$PATH;export PATH="$("${HDENVDIR}/bin/minpath" "${PATH}")"'
alias hup='killall -HUP'
alias hd-dns-test='ping www.toile.qc.ca'
alias surf='hd-decompose'

alias netosdetect='nmap -A -T aggressive -p "[-65535]" -P0'

alias cdenv='cdprint "${HDENVDIR}"'
alias cdbin='cdprint "${HDENVDIR}/bin"'

# WARNING:
#
#   An actual 'gtar' command exist under Linux!  No function or alias must be
#   created with the name 'gtar'.  This is why 'hdgtar' is being used here.
function hdgtar
{
  tar cvzf "`basename ${1}`.tar.gz" "${1}"
}
exportfunction hdgtar

function btar
{
  tar cvjf "`basename "${1}"`.tar.bz2" "${1}"
}
exportfunction btar

tarDecompress()
{
  filename="$1"
  # --atime-preserve=replace est nécessaire car sinon les répertoires
  # sont créer avec la date actuelle et non pas la date originale se
  # trouvant dans le fichier tar.
  parameters="--atime-preserve=replace -$2"

  if [ -z "${filename%%*bz2*}" ]; then
    tar ${parameters}vjf "${filename}"
  elif [ -z "${filename%%*gz*}" ]; then
    tar ${parameters}vzf "${filename}"
  elif [ -z "${filename%%*tar*}" ]; then
    tar ${parameters}vf "${filename}"
  else
    echo "Sorry, cannot figure out what type of tar file it is."
  fi
}
exportfunction tarDecompress

tart()
{
  tarDecompress "$1" "t$2"
}
exportfunction tart

tarx()
{
  tarDecompress "$1" "x$2"
}
exportfunction tarx

finddircontaining()
{
  echo $1
  find . -name "$1" -print | xargs -n1 dirname | sort | uniq
}
exportfunction finddircontaining

# On ne peut pas nommer la fonction 'altcd' comme 'cd', car sinon, \cd
# fait toujours référence a cette fonction et non pas la commande
# builtin de bash.  Donc la fonction s'appelle recursivement si elle est
# nommé 'cd'.  Pour contourner ce problème, on l'appel 'altcd' et on
# créer un alias 'cd'.  '\cd' n'appelera pas l'alias, mais bien la
# commande builtin.
altcd()
{
  local rv
  local directory="${1/file:\/\/}"

  # Flags are optional.  Current value supported:
  #
  #   [-l|l]  Do not run readlink on symlink
  local flags="${2}"

  #echo "altcd(${directory}) called."

  if [ -f "${directory}" ]; then
    directory=`dirname "${directory}"`
  fi

  case "${directory}" in

    '')

      # Going to the home directory.  Performing 'cd ""' does not work.
      \cd;;

    '-'|'.'|'..'|'../'*)

      # For these directory to work, we must not pass it through readlink.
      \cd "${directory}";;

    *)

      # Fetching canonical directory.  This is to go to the real directory
      # when there is a symlink.  Thus going then to the parent does not bring
      # you back, but to the actual parent of the linked directory.

      [[ "${flags}" != *"l"* ]] && directory=`readlink -f "${directory}"`;
      \cd "${directory}";;

  esac

  rv=$?
  hdtermtitleauto
  return ${rv}
}

alias cd='altcd'

cdprint()
{
  altcd "$1"
  (( $? != 0 )) && return  # Error occured.

  echo "Changed to ${PWD}"
  [ "${HD_OS_FAMILY/CYGWIN*/x}" = "x" ] && \
    echo "           "`cygpath -w "${PWD}"`
}
exportfunction cdprint

catw()     { cat "$(which "$@")"; }
cdwhich()  { cd "$(dirname "$(which "$@")")"; }

alias delsar='echo "delsar est remplacé par hd-sar-rm."'
alias hd-sar-rm='find . -name "*.sar" -print -exec rm {} \;'
alias hd-del-class='find . -name "*.class" -exec rm {} \;'

alias hd-spell-fr='aspell --encoding=utf-8 --lang=fr -c'
alias hd-spell-en='aspell --encoding=utf-8 --lang=fr -c'

alias hd-smime-desc='openssl x509 -text -in'

readinfo()
{
  info --subnodes --no-raw-escapes -o - $* | less
}

fflush_stdin()
{
  local ffs_originalSettings
  local ffs_dummy
  ffs_originalSettings=`stty -g`
  stty -icanon min 0 time 0
  while read ffs_dummy; do :; done
  stty "$ffs_originalSettings"
}
exportfunction fflush_stdin

hd_trim_variable()
{
  local VARIABLE=$1
  export ${VARIABLE}="`echo "${!VARIABLE}" | perl -pe 's%^\s*(.+?)\s*$%\1%g;'`"
}
exportfunction hd_trim_variable



# ════════════════════════════════════════════════════════════════════════════
# TIME
export HD_TIMESTAMP_FORMAT_ISO8601="%Y%m%dT%H%M%S"
export HD_TIMESTAMP_FORMAT_HUMAN="%Y-%m-%d %H:%M:%S %Z"
export HD_TIMESTAMP_FORMAT_CHANGELOG="%Y-%m-%d %H:%M %Z"
export HD_TIMESTAMP_FORMAT_CHANGELOG_RPM="%a %b %d %Y" # Mon Nov 17 2014, no choice, that is the only format that would work.

hd_timestamp_display()
{
  HDTIMESTAMPDISPLAY=`date +"${HD_TIMESTAMP_FORMAT_HUMAN}"`
}
exportfunction hd_timestamp_display

hd_timestamp_filename()
{
  HDTIMESTAMPFILENAME=`date +"${HD_TIMESTAMP_FORMAT_ISO8601}"`
}
exportfunction hd_timestamp_filename

hdproxyunset()
{
  unset gohper_proxy
  unset https_proxy
  unset http_proxy
  unset no_proxy
  unset ftp_proxy
}


# Libreoffice system wide setup to force it to run with GTK 3 instead with
# KDE.
#
# From:  https://ask.libreoffice.org/en/question/3078/choose-gui-toolkit-for-lo-session/
export SAL_USE_VCLPLUGIN=gtk3



# BASH HISTORY MANAGEMENT
# ════════════════════════════════════════════════════════════════════════════

export HISTSIZE=500

# Start your command with a space and it won't be included in the history if
# variable HISTCONTROL is set to 'ignorespace'.
#
# Example:
#
# $   echo "not remembered in history"
export HISTCONTROL=ignorespace
