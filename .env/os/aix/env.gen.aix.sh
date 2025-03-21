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

# From:  https://serverfault.com/questions/100875/how-do-i-tell-which-aix-version-am-i-running

function hdisroot()
{
  # 1 == root
  (( HD_USERID == 0 ))
  return $?
}
exportfunction hdisroot

function aixversion {
  OSLEVEL=$(oslevel -s)
  AIXVERSION=$(echo "scale=1; $(echo $OSLEVEL | cut -d'-' -f1)/1000" | bc)
  AIXTL=$(echo $OSLEVEL | cut -d'-' -f2 | bc)
  AIXSP=$(echo $OSLEVEL | cut -d'-' -f3 | bc)
  echo "AIX ${AIXVERSION} - Technology Level ${AIXTL} - Service Pack ${AIXSP}"
}
exportfunction aixversion
