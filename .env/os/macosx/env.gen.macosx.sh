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

# FILE MANAGERS
# ════════════════════════════════════════════════════════════════════════════

f()
{
  DIRECTORY="$1"
  [ -z "${DIRECTORY}" ] && DIRECTORY="."

  open "${DIRECTORY}" &
}
exportfunction f

# if [ -x "/Applications/MacVim.app/contents/MacOS/MacVim" ]; then
# fi

gvim()
{
  open -a "/Applications/MacVim.app/contents/MacOS/MacVim" "$@"
}
exportfunction gvim

hd_mount_media()
{
  # Using mapfile to fill the MOUNTMEDIAS as an array.  This way,
  # storage devices containging spaces within their names have no
  # problems.
  #
  # Using lsblk to fetch list of media that is mounted and removable.
  IFS=$'\n' MOUNTMEDIAS=($(mount | perl -ne 's/.*read-only.*//g;print if s%.* on (/Volumes.*?) \(.*%\1%g'))
}
exportfunction hd_mount_media
