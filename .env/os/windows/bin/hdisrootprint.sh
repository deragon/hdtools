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

# From:  http://superuser.com/questions/660191/how-to-check-if-cygwin-mintty-bash-is-run-as-administrator
net session >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "admin"
else
  echo "user";
fi
