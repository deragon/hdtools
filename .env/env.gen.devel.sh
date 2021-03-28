# Copyright 2000-2021 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this code.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html

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



# Git
# ══════════════════════════════════════════════════════════════════════════════

# From:   http://usevim.com/2012/03/21/git-and-vimdiff/
alias gitdiff='git difftool --tool=gvimdiff --no-prompt'


# Other
# ══════════════════════════════════════════════════════════════════════════════
alias mvnnotest='mvn -Dmaven.test.skip=true -DskipTests'


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
