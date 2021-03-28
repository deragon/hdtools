# Copyright 2000-2021 Hans Deragon - GPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this code.
#
# It is released under the GPL 3 licence which can be found at:
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html

alias ls "ls ${LS_OPTIONS}"
alias dir "ls -l"
alias x exit
alias dw ls
alias xrd 'rm -r -f'
alias rm "rm -i"
alias del "rm -i"
alias d 'dir'
alias psg 'ps ax | grep'
alias md 'mkdir'
alias rd 'rmdir'
alias cl 'clear'
alias vi 'vim'
alias pu 'pushd .'
alias po 'popd'
alias path 'echo $PATH'
alias manpath 'echo $MANPATH'
alias devices 'cat /proc/devices'
alias normprompt='export PROMPT "%/  "'
alias shortprompt='export PROMPT ">  "'
#alias telix 'minicom'


# cd aliases

alias c1 'cd ..'
alias c2 'cd ../..'
alias c3 'cd ../../..'
alias c4 'cd ../../../..'
alias c5 'cd ../../../../..'
alias c6 'cd ../../../../../..'
