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

# GIT
# ══════════════════════════════════════════════════════════════════════════════
#
# IMPORTANT:
#
#   Under Windows, many application require the official git for Windows found
#   at:  https://git-scm.com/download/win.  That version uses Windows format
#   paths under its <repository>/.git/ directories.
#
#   If one uses Cygwin's git, the git repositories extracted are formated with
#   Linux paths, not Windows path.  Application that make use of the official
#   Git for Windows such as IntelliJ IDEA will then fail to work properly
#   (often, without error messages; it just grays out menu options).
#
#   Thus, avoid using the Cygwin's version of Git.  Git for Windows works well
#   under Cygwin's environment.  Stick to this tool and conflicts will be
#   avoided.

# Path to Git for Windows executables.
setVarIfDirsExist HD_GIT_EXEC_PATH "${PROGRAMFILES}\Git\mingw64\libexec\git-core"
if [ -d "${HD_GIT_EXEC_PATH}" ]; then

  # No need to configure GIT_EXEC_PATH because git.exe can determine by itself
  # where its binaries are located.  We leave the next line in comment for
  # historical reasons, but we do not activate it.
  # export GIT_EXEC_PATH = "${HD_GIT_EXEC_PATH}"

  alias git="\"$(cygpath "${HD_GIT_EXEC_PATH}")/git.exe\""
fi
