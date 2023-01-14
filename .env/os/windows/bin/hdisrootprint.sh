#!/bin/bash

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

# From:  http://superuser.com/questions/660191/how-to-check-if-cygwin-mintty-bash-is-run-as-administrator
net session >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "admin"
else
  echo "user";
fi
