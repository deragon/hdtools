" ─ Copyright Notice ───────────────────────────────────────────────────
"
" Copyright 2000-2022 Hans Deragon - GPL 3.0 licence.
"
" Hans Deragon (hans@deragon.biz) owns the copyright of this work.
"
" It is released under the GPL 3 licence which can be found at:
"
"     https://www.gnu.org/licenses/gpl-3.0.en.html
"
" ─────────────────────────────────────────────────── Copyright Notice ─

" local syntax file - set colors on a per-machine basis:
" vim: tw=0 ts=4 sw=4
" Vim color file
" Maintainer:   Steven Vertigan <steven@vertigan.wattle.id.au>
" Last Change:  2003 May 11
" Revision #4: Support for new "Underline" group. Removed superfluous html
"              formatting.

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "hdblue"

" Nice dark blue.
"let background_color="#0000ac"



" Cursor
" ══════════════════════════════════════════════════════════════════════════════
" 
"  The color of the terminal cursor cannot be changed here.  The parameters
"  'cterm*' are being ignored.
"
"  From:  https://unix.stackexchange.com/questions/72797/how-do-i-highlight-the-current-line-and-the-cursor-in-vimrc/72800#72800
"
"    You have to change the color of your cursor line to a color other than
"    the color of your cursor. If you're in a terminal emulator like st or
"    rxvt, Vim cannot change the color of your cursor; it will always be the
"    color your terminal application decides to make it. Only the graphical
"    version of Vim is able to change the color of your cursor.
"
"    You can change your cursor color through your terminal configuration
"    though.
hi Cursor       guifg=black     guibg=white
hi Cursor       ctermfg=black   ctermbg=white



" THE REST
" ══════════════════════════════════════════════════════════════════════════════
hi Normal       guifg=white     guibg=darkBlue
hi Normal       ctermfg=white   ctermbg=darkBlue
hi NonText      guifg=magenta   ctermfg=lightMagenta
"hi comment     guifg=gray      gui=bold
"hi comment     ctermfg=gray
hi constant     guifg=cyan      ctermfg=cyan
"hi identifier  guifg=gray      ctermfg=gray
"hi statement   guifg=yellow    gui=none    ctermfg=yellow
hi preproc      guifg=green     ctermfg=green
"hi type            guifg=orange    ctermfg=darkYellow
hi special      guifg=magenta   ctermfg=lightMagenta
hi Underlined   guifg=cyan      ctermfg=cyan
hi Underlined   gui=underline   cterm=underline

hi ErrorMsg     guifg=orange    guibg=darkBlue
hi ErrorMsg     ctermfg=white   ctermbg=red
"hi ErrorMsg        ctermfg=white
"hi ErrorMsg        ctermfg=lightRed
hi WarningMsg   guifg=cyan      guibg=darkBlue  gui=bold
hi WarningMsg   ctermfg=cyan
"hi ModeMsg     guifg=yellow    gui=NONE
"hi ModeMsg     ctermfg=yellow
"hi MoreMsg     guifg=yellow    gui=NONE
"hi MoreMsg     ctermfg=yellow
hi Error        guifg=red       guibg=darkBlue  gui=underline
hi Error        ctermfg=white   ctermbg=red

hi Todo         guifg=black     guibg=orange
hi Todo         ctermfg=black   ctermbg=darkYellow
hi Search       guifg=black     guibg=orange
hi Search       ctermfg=black   ctermbg=darkYellow
hi IncSearch    guifg=black     guibg=yellow
hi IncSearch    ctermfg=black   ctermbg=darkYellow
hi LineNr       guifg=pink      ctermfg=lightMagenta
hi title        guifg=white gui=bold    cterm=bold

hi StatusLineNC gui=NONE      guifg=black guibg=blue
hi StatusLineNC ctermfg=black   ctermbg=blue
hi StatusLine   gui=bold        guifg=cyan  guibg=blue
hi StatusLine   ctermfg=cyan    ctermbg=blue

"hi label       guifg=yellow    ctermfg=yellow
"hi operator    guifg=orange    gui=bold    ctermfg=darkYellow
hi clear Visual
hi Visual       term=reverse
hi Visual       ctermfg=black   ctermbg=darkCyan
hi Visual       guifg=black     guibg=darkCyan

hi diffChange   guibg=darkblue    ctermbg=blue       guifg=white  ctermfg=white
hi diffText     guibg=darkred     ctermbg=red        guifg=white  ctermfg=white
hi diffAdd      guibg=darkgreen   ctermbg=darkgreen  guifg=white  ctermfg=white
hi diffDelete   guibg=red         ctermbg=darkred    guifg=black  ctermfg=black

hi Folded       guibg=orange        guifg=black
hi Folded       ctermbg=yellow      ctermfg=black
hi FoldColumn   guibg=gray30        guifg=black
hi FoldColumn   ctermbg=gray        ctermfg=black
"hi cIf0            guifg=gray          ctermfg=gray

