#!/bin/bash

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

# Comment by Hans Deragon (hans@deragon.biz), 2020-07-17 12:46:47 EDT
# Le script hdsvg2png pourrait aussi être utilisé, mais j'ai décidé autrement.

for DIR in hans generic; do
  cd "${DIR}"
  for FILE in *.svg; do
    #FILENAME="${FILE/.svg/}"
    echo "Processing ${FILE}"
    for RES in 64 256; do
      set -x
      hdsvg2png -x "${RES}" -y "${RES}" -o png "${FILE}"
      set +x
    done
  done
  cd - >/dev/null 2>&1
done
