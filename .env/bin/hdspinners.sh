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

# From:  https://stackoverflow.com/questions/2685435/cooler-ascii-spinners


# SPINNER CODE
# ══════════════════════════════════════════════════════════════════════════════


#spin_graph="▁▂▃▄▅▆▇█▇▆▅▄▃▂"
spin_graph="▉▊▋▌▍▎▏▎▍▌▋▊▉"
#spin_graph="▖▘▝▗"
#spin_graph="▞▚"
#spin_graph="←↖↑↗→↘↓↙"
#spin_graph="┤┘┴└├┌┬┐"
#spin_graph="◢◣◤◥"
#spin_graph="◰◳◲◱"
#spin_graph="◴◷◶◵"
#spin_graph="◐◓◑◒"
#spin_graph="◡◡⊙⊙◠◠"
#spin_graph="⣾⣽⣻⢿⡿⣟⣯⣷"  # Braille
#spin_graph="⠁⠂⠄⡀⢀⠠⠐⠈"

spin_index=-1

tput civis # Hide cursor

spin_update()
{
  (( spin_index=spin_index+1 ))
  (( spin_index >= ${#spin_graph} )) && spin_index=0

  #echo -en "${spin_graph:${spin_index}:1}"
  printf '%s' "${spin_graph:${spin_index}:1}"
  tput cub 1
}

signalExitHandler()
{
  tput cvvis # Show cursor
}

trap signalExitHandler EXIT



# PROCESSING CODE
# ══════════════════════════════════════════════════════════════════════════════

while ((1)); do

  spin_update

  # Put processing code here.
  sleep 0.1
done
