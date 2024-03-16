" ─ Copyright Notice ───────────────────────────────────────────────────
"
" Copyright 2000-2024 Hans Deragon - AGPL 3.0 licence.
"
" Hans Deragon (hans@deragon.biz) owns the copyright of this work.  It is
" released under the GNU Affero General public Picense which can be found at:
"
"     https://www.gnu.org/licenses/agpl-3.0.en.html
"
" ─────────────────────────────────────────────────── Copyright Notice ─

" Aide:  \h

" VIM configuration written by Hans Deragon, hans@deragon.biz
"
" REGISTERS Named:
" ════════════════════════════════════════════════════════════════════
"
"   You copy items directly to named registers [a-z] by prepending your yank
"   command with the register name. For example, yanking a word to register a
"   use "ayw and then "ap to paste.
"
"   If you use a capital letter, [A-Z], the same corresponding named register
"   is used, but the content is appended to the register, not replaced.
"
"
" DEBUG:
" ════════════════════════════════════════════════════════════════════
"
"   :echo <variable>  -> echo v:version  " Print a vim variable's value.
"   :scriptnames " Shows all the files sourced in their respective order.
"
"
" CONFIG LIST OF FEATURES AVAILABLE WITHIN VIM:
" ════════════════════════════════════════════════════════════════════
"
"   List all features:      :version
"                           :h feature-list
"
"   Test specific feature:  :echo has('python')
"
"   See:  https://stackoverflow.com/questions/13294267/how-can-you-check-which-options-vim-was-compiled-with
"
"
" Section: Documentation {{{1
" ════════════════════════════════════════════════════════════════════
" Special notes for using Vim.
"
" ⬐──⬎
" ⬑──⬏
" ⎧ ⎫
" ⎮ ⎮
" ⎩ ⎭
" ╭───╮
" ╰───╯
"
"
" SELECTION
" ════════════════════════════════════════════════════════════════════
"
" BLOCK VISUAL:  CTRL-Q
"
" How to select block when last line is shorter than others
"
"  1) :set virtualedit=block
"  2) Start CTRL-V, then select end of line with $, then select the block.
"
" ════════════════════════════════════════════════════════════════════
" SPECIAL CHARACTERS:
"
" Use digraphs to generate special characters.  (:help digraph)
"
" :dig  # for list of digraphs.
"
" CTRL-K <digraph sequence> to generate a digraph.
"
" Interesting digraphs:
"
" Arrows:   → ->    ← <-    ↓ -v    ↑ -!
" Math:     ≈ 2?
" Misc:     ¢ c|    ℃  oC
" Bullets:  ∙ Sb    ▪ sB    ⚫ ??   ○ 0m   ● 0M
"
" ════════════════════════════════════════════════════════════════════
" USEFUL COMMANDS:
"
" help <keyword> <CTRL-D>
"
" gg=G   will reindent the code
"
" See :help feature-list
"
" OPTIONS:
"
"   For setting multiple format option and disabling things like
"   autocomment, see:
"
"   :set formatoptions
"
" ════════════════════════════════════════════════════════════════════
" PASTE:  To paste text properly:
"
"   :set paste
"   :set nopaste
"
" ════════════════════════════════════════════════════════════════════
" FOLDING:  (collapsed line), see |folding|
"
"   Unfolding / expanding / open all folds:  zR
"
"   zr   Reduce folding: Add |v:count1| to 'foldlevel'.
"   zM   Close all folds: set 'foldlevel' to 0.

" |fold-marker| marker      Markers are used to specify folds.
set foldmethod=marker

" foldlevel=99 == When opening a file, it is unfolded by default.
set foldlevel=99

" ════════════════════════════════════════════════════════════════════
" SEARCH AND REPLACE:
"
"   To reuse a pattern in the replacement, use &.
"   See :help sub-replace-special
"
"   Examples:
"
"      :g/\w\+/s//'&'/g     will replace >>one two<< with >>'one' 'two'<<
"      :s/.*"\(.*\)".*/\1/g will replace >>aa"bbb"cc<< with >>bbb<<
"
"   Escape slashes, use ":" instead of "/" as a separator:
"
"      s:/dir1/dir2/dir3/file:/dir4/dir5/file2:g
"
"  Delete all the lines not matching pattern:
"
"    :v/pattern/d
"
" ════════════════════════════════════════════════════════════════════
" STARTING GVIM AT A SPECIFIC DIRECTORY:
"
"   Starting gvim such that when browsing for files is initiated, it starts
"   at the desired directory:  gvim -c "cd <dir>"
"
" ════════════════════════════════════════════════════════════════════
" ENCODING: (convert)
"
"   To figure out the current file encoding:
"
"     :set fileencoding
"
"   To convert a file:
"
"     :set fileencoding=utf-8
"     :set fileencoding=latin1
"     :set fileencoding=iso-8859-1
"
"   To change encoding: (but not convert file)
"
"     :set encoding=utf-8
"     :set encoding=latin1
"     :set encoding=iso-8859-1
"
" ════════════════════════════════════════════════════════════════════
" CONFIGURING VIM:
"
"   Environment variables are accessible by simply calling them
"   like in bash:  $LS_COLORS, $HDVIM, etc..
"
"   Variables can be set:               let VARNAME="something"
"   Environment variables can be set:  let $VARNAME="something"
"
"   To use and environment variable in a mapping (imap, etc...), you
"   need to suround it with "<C-R>=$varname<CR>".  Search for "<C-R>" within
"   this file for examples.
"   See:  https://vi.stackexchange.com/questions/21825/how-to-insert-text-from-a-variable-at-current-cursor-position
"
"   DO NOT REFER ENVIRONMENT VARIABLES WITHIN {}.  It seams
"   to be buggy with Vim 7.1.
"
" ════════════════════════════════════════════════════════════════════
" GPG:
"
"   For gvim to work, you need to have 'pinentry' installed on the
"   system (generally, package name is 'pinentry-gtk2').  This package
"   allow gvim to ask for the passphrase.
"
"   For more details, search for 'gvim' in gnupg.vim plugin.
"
" ════════════════════════════════════════════════════════════════════
" Section: Code {{{1

" ════════════════════════════════════════════════════════════════════
" These options must be set first thus must be found at the beginning of the
" script, because some will reset values and otions if they were set before.

set nocompatible " Use Vim defaults (much better!)
set nobackup

" ════════════════════════════════════════════════════════════════════
" Setting the RunTime Path.
"
" Code necessary to get VIM to lookup for colorscheme, plugins, etc where this
" script actually resides.
"
" See:
" http://stackoverflow.com/questions/3377298/how-can-i-override-vim-and-vimrc-paths-but-no-others-in-vim

" set default 'runtimepath' (without ~/.vim folders)
let &runtimepath = printf('%s/vimfiles,%s,%s/vimfiles/after', $VIM, $VIMRUNTIME, $VIM)

" what is the name of the directory containing this file?
let s:portable = expand('<sfile>:p:h')

" add the directory to 'runtimepath'
let &runtimepath = printf('%s,%s,%s/after', s:portable, &runtimepath, s:portable)

if($HDVIM != "")
  set rtp+=$HDVIM
  "echo "${HDVIM} set." $HDVIM


  " VIM-PLUG - Plugin manager / packager
  " ════════════════════════════════════════════════════════════════════
  "
  "   https://github.com/junegunn/vim-plug
  "
  "   Installation:
  "
  "      curl -fLo "${HDVIM}/autoload/plug.vim" --create-dirs \
  "        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  "
  "   To install all plugins from scratch on a new computer:  PlugInstall
  "   To update all plugins:                                  PlugUpdate

  " Set Git URI format to 'git' instead of default 'http'.
  let g:plug_url_format = 'git@github.com:%s.git'

  " silent! is used here to avoid native gvim on Windows to display the
  " following error message:
  "
  "   [vim-plug] `git` executable not found. Most commands will not be
  "   available. To suppress this message, prepend `silent!` to `call
  "   plug#begin(...)`.
  silent! call plug#begin('$HDVIM/plugged')
  Plug 'rickhowe/diffchar.vim'
  Plug 'AndrewRadev/linediff.vim'
  Plug 'chrisbra/csv.vim'
  Plug 'elzr/vim-json'
  Plug 'godlygeek/tabular'
  Plug 'jamessan/vim-gnupg'
  Plug 'plasticboy/vim-markdown'
  Plug 'scrooloose/nerdtree'
  Plug 'skywind3000/quickmenu.vim'
  Plug 'thinca/vim-fontzoom'
  Plug 'tomtom/tcomment_vim'
  Plug 'tpope/vim-abolish'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-sensible'
  Plug 'tpope/vim-unimpaired'
  Plug 'vim-scripts/SQLUtilities'
  Plug 'hashivim/vim-terraform'

  " Only one mapping (or one command) provides all features of this plugin.
  " Briefly, move cursor to the position and run :GitMessenger or <Leader>gm.
  " If you see an error message, please try health check.
  "
  " More options documented at:  https://github.com/rhysd/git-messenger.vim
  Plug 'rhysd/git-messenger.vim'

  Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
  "Plug 'vim-textobj-comment'   " Bug; runs deprecated code.  Had to comment out.
  "Plug 'vim-textobj-user'      " Bug; runs deprecated code.  Had to comment out.

  " On-demand loading
  call plug#end()
else
  echo "ERROR:  ${HDVIM} is not set.  'rtp' is missing that path:"
  echo "rtp=" &rtp
endif


" ════════════════════════════════════════════════════════════════════

let g:GPGDebugLevel=200
let g:GPGUseAgent=1

" ════════════════════════════════════════════════════════════════════
let mapleader = "\\"  " Actually, just type '\'

" HELP FILES
map <S-F3> :sp $HDVIM/doc/hdvim.md<CR>
map <Leader>h :sp $HDVIM/doc/hdvim.md<CR>zR<CR>


" SEPARATORS
" ════════════════════════════════════════════════════════════════════
map <Leader>1 <esc>078i═<esc>a<CR>
map <Leader>2 <esc>02i <esc>76a─<esc>a<CR>
map <Leader>3 <esc>04i <esc>74a‑<esc>a<CR>
map <Leader>4 <esc>06i <esc>72a⚋<esc>a<CR>
map <Leader>6 <esc>078i=<esc>a<CR>
map <Leader>7 <esc>02i <esc>76a-<esc>a<CR>


" Alignment
" ════════════════════════════════════════════════════════════════════

"  Align columns: :'<,'>Tabularize / /
"
" From: https://stackoverflow.com/questions/11497593/vim-tabular-only-on-the-first-match-on-the-line
map <Leader>ac :Tabularize /^[^:]*\zs:\zs/<CR><CR>
map <Leader>ae :Tabularize /^[^=]*\zs=\zs/<CR><CR>
map <Leader>a= :Tabularize /=/<CR><CR>
map <Leader>a/ :Tabularize /\//<CR><CR>
map <Leader>a\ :Tabularize /\\/<CR><CR>
"Align on [ with 2 spaces at its left, 0 spaces at its right.  Ex:  '  [<text>'
map <Leader>a[ :Tabularize /^[^\[]*\zs\[/l2l0<CR><CR>
map <Leader>at :Tabularize /\t/<CR><CR>
map <Leader>a# :Tabularize /#/<CR><CR>
map <Leader>a, :Tabularize /^[^,]*\zs,\zs/<CR><CR>
" map <Leader>aa <Leader>acgv<Leader>a=gv<Leader>a# " Needs some work.

" Align on spaces ->  Visually select and type:  \tsp
"
"   1st separator only:    AlignCtrl l:
"   2nd separator only:    AlignCtrl -l:
"   3rd separator only:    AlignCtrl --l:
"


" <Leader>f1l - Fields on 1 line
"
" Takes a list of fields, one per line, and bring them together into one
" single line, each field double quotes and separated with a coma.
" Useful for creating CSV files.
"
" Example:
"
"   TRANSACTIONID,
"   CREDITEDCONTENTKEYEVENT,
"   EQUIPMENTID,
"
"   becomes:
"
"     "TRANSACTIONID","CREDITEDCONTENTKEYEVENT","EQUIPMENTID"
"
" Explanation of the macro:
"
"  ...     Format fields with double quotes and remove fluffy stuff.
"   gv     Re-select the last selected visual area with.
"    J     Join the lines together
"    V     Visually select the line
"  ...     Next search and replace spaces and trailing coma.
"  <S-F6>  Reset highlight of search.  See macro associated with <S-F6>.
"
map <Leader>f1l :s/\(\w\+\).*/"\1",/g<CR>gvJV:s/ //g<CR>V:s/,*$//g<CR><S-F6>

" Unicode codepoint converter.  Replaces with actual character.
" Does the function of unicodeswitch.vim
map <Leader>unicode :s/\(<[uU]\\|\\u\)\(\x\{4}\)>*/\=nr2char(str2nr(submatch(2),16))/g<CR>

" Visually select the text that must be base64 encoded/decoded and
" call the proper command below.
:vnoremap <leader>b64d c<c-r>=system('base64 --decode', @")<cr><esc>
:vnoremap <leader>b64e c<c-r>=system('base64', @")<cr><esc>

" Visually select the text that must be base64 encoded/decoded and
" call the proper command below.
:vnoremap <leader>uudecode c<c-r>=system('uudecode', @")<cr><esc>
:vnoremap <leader>uuencode c<c-r>=system('uuencode', @")<cr><esc>

" Hardspaces replaced with normal spaces.
" Need to use <Bar> here instead of | since | is used to separate vim
" commands in .vimrc.
map <Leader>hardspaces :s/\( \<Bar>☠\)/ /g<cr><esc>

" 'set noic' to not ignore case.  Default is to ignore case when searching.
" It is easier that way.
set ic
set report=1


" Tab & Indentation settings
let tabsizehd=2
"set tabstop=$tabsizehd
execute "set tabstop=".tabsizehd
set cinoptions=>2  "The 'cinoptions' affect the way 'cindent' reindents lines in a C program
set shiftwidth=2   "Number of spaces to use for each step of (auto)indent.

" ════════════════════════════════════════════════════════════════════
" TABS:
"
"   To re-indent a file, do in command mode:  :gg=G
"   To convert tabs to spaces:                :retab
"   Key "tab" express as spaces:              :set expandtab / set et
"   Key "tab" express as a true tab:          :set noet
"Typing key "tab" is represented with spaces instead of actual tabs.
"To disable this:  set noet
set et

" For retab:  to insert space characters whenever the tab key is pressed, set
" the 'expandtab' option.
set expandtab


set timeout
set timeoutlen=20000
set autowrite
set ruler
"set makprg=compile

function! HDClipboardSetup()
  " Copy <C-c> / Cut <C-x> / Paste <C-v>
  " ════════════════════════════════════════════════════════════════════
  "
  "   Definitions:
  "
  "     System clipboard:   Gnome like clipboard.
  "     Primary clipboard:  X11 clipboard, working with visual selection in
  "                         terminal.
  "
  "   Fix copy function under Linux
  "
  "   From:  https://stackoverflow.com/questions/30691466/what-is-difference-between-vims-clipboard-unnamed-and-unnamedplus-settings
  "
  "   Using only unnamedplus on Linux, Windows and Mac OS X allows you to:
  "
  "     - CtrlC in other programs and put in Vim with p on all three platforms,
  "     - Yank in Vim with y and CtrlV in other programs on all three platforms.
  "  ^= vs +=

  "   @ryanpcmcquen, Vim as three types of options: "string", "number", and "boolean". ^= multiplies only in the context of "number" options but 'clipboard' is a "string" option where ^= prepends the value and += appends the value.

  set clipboard^=unnamed,unnamedplus

  " CTRL-C Copy into all Linux clipboard, only when something is actually
  "        selected, thus when in visual mode ('vnoremap').
  vnoremap <C-c> "+y

  " CTRL-V Paste the the System's clipboard.
  "        This overwrite's the visual block selection!  Use CTRL-Q for that!
  "
  inoremap <C-v> <esc>"+gPi

  " CTRL-X Cut
  map <C-x> "+x

endfunction

if has("win32")
  call HDClipboardSetup()

  if has("gui_running")
    map <S-F1> :sp $HDDOCSDIR_WIN/unicode.txt<CR>
    map <Leader>unidoc :sp $HDDOCSDIR_WIN/unicode.txt<CR>

    let g:GPGExecutable="c:/Program Files/GNU/GnuPG/gpg.exe"
    let g:GPGExecutable="c:\\Program Files\\GNU\\GnuPG\\gpg.exe"
    "let yres=system("c:\cygwin\bin\bash.exe /cygdrive/c/cygwin/home/deragh01/.hans.deragon/.env/windows/bin/hd-screen-resolution-win y")
    "let yres=system("c:\912839561\home\deragonh\.hans.deragon\.env\bin.dos\QRes.exe /S")

    "let yres=system("C:\Users\dzz5328\Projets\Outils\cygwin64\bin\bash.exe

    let yres=1080
    "echo "yres=>>".yres."<<"

    " For font dialog, do             >> :set guifont=*
    " For name of font being used, do >> :set guifont

    "let font_name="Lucida_Console"
    "let font_name="Consolas"
    let font_name="DejaVu_Sans_Mono"
    let font_style="b"
    let font_charset="cDEFAULT"

    " For font dialog, do             >> :set guifont=*
    " For name of font being used, do >> :set guifont
    if yres >= 1080
      let font_size="h13"
    elseif yres >= 768
      let font_size="h11"
    endif

    let font=font_name.":".font_size.":".font_style.":".font_charset
    "echo "font = >>".font."<<"
    let &guifont=font
    map <esc>1 :let &guifont=font_name. ":h8:".font_style.":".font_charset<CR>
    map <esc>2 :let &guifont=font_name.":h10:".font_style.":".font_charset<CR>
    map <esc>3 :let &guifont=font_name.":h12:".font_style.":".font_charset<CR>
    map <esc>4 :let &guifont=font_name.":h14:".font_style.":".font_charset<CR>
    map <esc>5 :let &guifont=font_name.":h64:".font_style.":".font_charset<CR>
  endif

  " It is preferrable not to load mswin.vim to keep the same behavior
  " as in Unix.  CTRL-V remains the selection of a block.
  " source $VIMRUNTIME/mswin.vim

  " Reseting keymodel, so that when we select a visual block then perform
  " a CTRL-F, the visual block persist, i.e. does not disappear.
  set keymodel=
  let HIDEPREFIX="_"

elseif has("mac")

  if has("gui_running")
    " For font dialog, do             >> :set guifont=*
    " For name of font being used, do >> :set guifont

    let font_name="DejaVu Sans Mono"
    let font_style=":h"
    let font_size="14"

    let font=font_name.font_style.font_size
    "echo "font = >>".font."<<"
    let &guifont=font

    map <esc>1 :let &guifont=font_name.font_style."9"<CR>
    map <esc>2 :let &guifont=font_name.font_style."11"<CR>
    map <esc>3 :let &guifont=font_name.font_style."14"<CR>
    map <esc>4 :let &guifont=font_name.font_style."16"<CR>
  endif
  let HIDEPREFIX="."
else
  " Linux!!! Or Cygwin!!!
  " Or another type of Unix system.

  call HDClipboardSetup()

  set shell=/bin/bash
  map <S-F1> :sp $HDDOCSDIR/unicode.txt<CR>
  map <Leader>unidoc :sp $HDDOCSDIR/unicode.txt<CR>

  " Ideally, this should be set only if we detect we are under AIX.
  " Under Linux, it should be left to be set automatically by reading
  " the environment variable "TERM".
  " TODO:  Put in comment once I have no more need for AIX, as this test
  "        forks a call to the 'uname' command (costly).
  if $HD_OS_FAMILY == 'AIX'
  "if system('uname') =~ 'AIX'
    " This terminal is not the best for AIX.  It renders the colors
    " correctly, but the functions keys do not work anymore and
    " the bottom bar blinks.
    set term=builtin_pcansi
  endif

  let HIDEPREFIX="."

  if has("gui_running")

    " Fix temporaire pour problème décrit à:
    " https://groups.google.com/forum/#!topic/vim_dev/wzrb9g5zIhA
    "set guiheadroom=80

    " For font dialog, do             >> :set guifont=*
    " For name of font being used, do >> :set guifont

    let font_name="DejaVu Sans Mono"
    let font_style="Bold"

    let yres=system("${HDENVDIR}/bin/hd-screen-resolution y")
    "echo "yres == >>>" yres "<<<>>>" $HDENVDIR $HDVIM"<<<<"

    "if yres >= 1200
    "  let font_size="12"
    "elseif yres >= 1000
    "  let font_size="11"
    if yres >= 768
      let font_size="12"
    else
      let font_size="14"
    endif

    let font=font_name." ".font_style." ".font_size
    "echo "font = >>".font."<<"
    let &guifont=font

    map <esc>1 :let &guifont=font_name." ".font_style. " 9 "<CR>
    map <esc>2 :let &guifont=font_name." ".font_style." 11 "<CR>
    map <esc>3 :let &guifont=font_name." ".font_style." 12 "<CR>
    map <esc>4 :let &guifont=font_name." ".font_style." 14 "<CR>
    map <esc>5 :let &guifont=font_name." ".font_style." 28 "<CR>
    map <esc>6 :let &guifont=font_name." ".font_style." 64 "<CR>
  endif
endif



" Added by Hans Deragon (hans@deragon.biz), 2018-02-02 11:46:55 EST
"
" To enter special escaped characters, <C-q> is by default configured, but
" terminals actually catch the <C-q> and <C-s> sequences as flow control
" signals STOP and RESUME.
"
" To go around this issue, we assign <C-w> for this function.  Thus, to
" enter the escape character, simply type <C-w><C-]>.
imap <C-w> <C-q>

" Encoding described at:
"   http://blog.wensheng.com/2007/05/vim-gvim-utf8-and-chinese-in-windows-xp.html
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,latin1

" Generic GUI configuration
if has("gui_running")
  if &foldmethod == 'diff'
    " Running gvimdiff here.  Let the system determine the number of columns.
    "
    " NOTE:  If gvimdiff is run from a RHEL 4 machine to display remotely
    "        on a FC4 machine, a "set columns=999" will screw up X and you
    "        will need to kill the process manually (kill command) and wait
    "        for X to give you back
    set columns=999
  else
    set columns=80
  endif
  set lines=999 " 999 = take all the vertical space.
  set guiheadroom=120  " 2022-08-05 does not work under WSL2, Ubuntu 22.04 LTS

  " Bug:  https://github.com/vim/vim/issues/1510
  "
  "       gVim under Linux starts too low when it is configured to take all
  "       vertical space.
  "
  " Bug:  Under Cygwin, when winpos is called during a mintty (terminal) session
  "       by 'vim' and not 'gvim', the terminal window can be moved out of the
  "       screen.  'winpos' must be always wrapped around a 'if
  "       has("gui_running")' statement.
  winpos 0 30


  " Get <S-Insert> working.
  " From:  https://superuser.com/questions/322947/gvim-shift-insert-dump-s-insert-instead-of-the-clipboard-text
  " and: https://gist.github.com/thomd/8470834
  map  <S-Insert>  "+p
  imap <S-Insert>  <Esc>"+pa
  cmap <S-Insert>  <C-R>+
endif

" Sets the backspace and delete keys correctly for xterm and rxvt.
" See :fix[del] in help of vim.
"
" Comment by Hans Deragon (hans@deragon.biz), 2018-03-14 16:26:11 EDT
" Not useful anymore.  Modern vim works fine.
"
"if &term == "xterm" || &term == "cygwin"
"  set t_kb=
"  set t_kD=[3~
"endif

" Include this command in your .vimrc if you always want syntax highlighting, or
" put it in your .gvimrc if you only want it in the GUI.  If you don't want it
" for B&W terminals, but you do want it for color terminals, put this in your
" .vimrc
"
" WARNING:  On AIX systems, syntax must be set prior colorscheme or else
"           the colors are all wrong and psychedelic.
syntax on

"if($HD_OS_FAMILY != "AIX")
  colorscheme hdblue
"else
"  colorscheme <put here an AIX compatible color scheme>
"endif

" K is map to perform "man" on the command right under the cursor.  This is
" annoying since I often mistakenly tip K instead of k to move the cursor up.
" So I redefine it for the same functionality.
map K k

" Mapping F1 to <esc> because some keyboards, such as the one of Lenevo
" Thinkpad, have the <esc> key too far.  Beside, F1 was originaly used for
" :help, which can be accessed by typing that command.
"
" WARNING:  This mapping works for gvim, but not for the console vim running
"           under gterm; the keycode is intercepted by the window manager
"           before it gets to Vim.
"map <F1> <esc>
"imap <F1> <esc>

" F4 COULD BE REUSED.  It was used for indentation, but I never use it.
"vmap <F4> :s/^/  /g<CR>:nohlsearch<CR>
"nmap <F4>a :g/^/s//  /g<CR>:nohlsearch<CR>
"nmap <F4>p vap:s/^/  /g<CR>:nohlsearch<CR>
"In scripts, one most double the ^V to escape ^M.

" F5:  - Remove trailing spaces and carriage returns (\r, ^M, CR).
map  <F5> mz:g/\r$/s///g<CR>:g/\s\+$/s///g<CR>:nohlsearch<CR>`z:echoerr ""<CR>
map  <F6> :nohlsearch<CR>:set nospell<CR>
map  <S-F6> :g/}\n\n\/\//s//}\r\r\/\//g<CR>

" F7 mapped to 'go to mark' ` or ' which are dead keys on US-INTERNATIONAL
" keyboards.
nmap <F7> `

" Defining F8 as CTRL-".  Double quotes are used to access registers, but on
" US-INTERNATIONAL keyboard maps, double quotes are a dead key and is very
" annoying to use.  Thus we use <F8> instead of the double quotes to perform
" the operation.
"
" Usage:
"
"   - <F8>ayy  -> Yank full line in register 'a'.
"   - v<F8>ay  -> For yanking a visual selection, the selection must be
"                 performed first, and then select the register (here 'a')
"                 and finally, yank the selection into it.
" See:
"
"   - https://stackoverflow.com/questions/35279859/vim-cmap-lhs-only-at-the-beginning
"   - https://stackoverflow.com/questions/21849105/vim-how-to-yank-a-visual-block-to-a-register/21849236
map <F8> <C-">

map  <S-F8> :set columns=80<CR>
" Hexadecimal editor
" See:  http://nion.modprobe.de/blog/archives/628-vim-as-hex-editor.html
map ,hon :%!xxd<CR>
map ,hof :%!xxd -r<CR>

" From http://vim.wikia.com/wiki/Page_up/down_and_keep_cursor_position
map <PageDown> :set scroll=0<CR>:set scroll^=2<CR>:set scroll-=1<CR><C-D>:set scroll=0<CR>
map <PageUp> :set scroll=0<CR>:set scroll^=2<CR>:set scroll-=1<CR><C-U>:set scroll=0<CR>

" Comments/uncomments selected lines.
vmap <F9>   gc<CR>

" Execute Python scripts with CTRL-F9
" From:  https://stackoverflow.com/questions/18948491/running-python-code-in-vim
autocmd FileType python  map <buffer> <C-F9> :w<CR>:exec      '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <C-F9> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>

map <esc>e :setlocal spell spelllang=en_us<CR>
map <esc>f :setlocal spell spelllang=fr<CR>
map <esc>s :set nospell<CR>

" Non breaking spaces now show as: ☠ (dead skull)
"                    Tabs show as: ↳↳
"         Trailing spaces show as: ␣
set listchars=nbsp:☠,tab:↳↳,trail:␣
set list

set noautoindent " if autoindent is on, this causes problems with cut&paste
                 " feature of X (at least, on Sun machines).
" Following filetype commands set up some special features that allow
" gg=G to properly indent bash scripts for instance.
"
" https://vi.stackexchange.com/questions/10124/what-is-the-difference-between-filetype-plugin-indent-on-and-filetype-indent

" From:  https://vi.stackexchange.com/questions/11696/what-does-filetype-plugin-on-really-do
"
"   Because local options have priority over global ones your .vimrc settings
"   might be ignored. In that case you need to create a file
"   ~/.vim/after/ftplugin/javascript.vim (with the name of the filetype you
"   wish to change) and set your own setlocal options in there.
"
filetype plugin on
filetype indent on



" PARAGRAPH FORMATING/WRAPPING WITH INDENTATION
" ══════════════════════════════════════════════════════════════════════════════
"
" For tips:  https://stackoverflow.com/questions/7338214/nicely-formatting-long-comments-in-vim
"
"   <esc>v -> formats the current paragraph to 78 cols
"   <esc>g -> formats the current paragraph to 72 cols (Git commit format)
"   <esc>p -> formats the current paragraph to 60 cols
"   <esc>o -> formats the current paragraph to 50 cols
set formatoptions=tcql2
map <esc>v :set textwidth=78<CR>:set ai<CR>gqap<CR>:set noai<CR>:set textwidth=0<CR>
" <esc>g 'g' stands for 'git', to follow convention documented at:
"        http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
map <esc>g :set textwidth=72<CR>:set ai<CR>gqap<CR>:set noai<CR>:set textwidth=0<CR>
map <esc>p :set textwidth=60<CR>:set ai<CR>gqap<CR>:set noai<CR>:set textwidth=0<CR>
map <esc>o :set textwidth=50<CR>:set ai<CR>gqap<CR>:set noai<CR>:set textwidth=0<CR>
" Old - not all systems have "par", thus cannot call this external tool to do
" the job.
" V -> formats the file to 72 cols
"map <esc>V :1,$!par w72<CR>
"map <esc>P {!}par w60<CR>

" Center for 80 char screen
map <esc>c :ce 80<CR>



" LINE RELATED COMMANDS
" ══════════════════════════════════════════════════════════════════════════════

" Line - Delete - Empty lines, pure ones.
map <esc>lde :g/^$/d<CR>

" Line - Delete - Empty lines containing spaces.
map <esc>lds :g/^\s*$/d<CR>



" Extended commands (starts with <esc>x)
" ══════════════════════════════════════════════════════════════════════════════
map <esc>xd :g/\d\+-\d\+-\d\+\s\+\d\+:\d\+:\d\+/s//<timestamp>/g<CR>

" See:  http://vim.wikia.com/wiki/Format_your_xml_document_using_xmllint
map <esc>xx :silent 1,$!xmllint --format --recover - 2>/dev/null<CR>



" Date commands
" ══════════════════════════════════════════════════════════════════════════════
if($HD_TIMESTAMP_FORMAT_HUMAN != "")
  let g:hd_timestamp_format_human = $HD_TIMESTAMP_FORMAT_HUMAN
else
  " Under Windows's gvim, $HD_TIMESTAMP_FORMAT_HUMAN is not set.
  " We thus hardcode it here.
  let g:hd_timestamp_format_human = "%Y-%m-%d %H:%M:%S %Z"
endif

if($HD_USER_NAME_FULL == "")
  let s:HD_USER_NAME_FULL="Hans Deragon"
  let s:HD_USER_EMAIL="hans@deragon.biz"
else
  let s:HD_USER_NAME_FULL=$HD_USER_NAME_FULL
  let s:HD_USER_EMAIL=$HD_USER_EMAIL
endif

let s:HD_USER_ID_FULL=s:HD_USER_NAME_FULL." (".s:HD_USER_EMAIL.")"

if !has('nvim')
  " Fetch first character of the comment string, to get the comment character.
  " Does not exists in Nvim.
  let commentcharacter=split(&commentstring, '%s')[0]

  " There is no printer facility in Nvim.  There use to be the 'hardcopy'
  " command, but that has been removed.
  "
  " http://vim.wikia.com/wiki/Printing_using_kprinter
  " kprinter non disponible pour Ubuntu >=11.04.  gtklp est l'alternative.
  "set printexpr=system('kprinter'\ .\ '\ '\ .\ v:fname_in)\ .\ delete(v:fname_in)\ +\ v:shell_error
  set printexpr=system('gtklp'\ .\ '\ '\ .\ v:fname_in)\ .\ delete(v:fname_in)\ +\ v:shell_error
endif

function! HDSignature(prefix)

  let l:comment = a:prefix .
                  \ s:HD_USER_ID_FULL .
                  \ ", " .
                  \ strftime(g:hd_timestamp_format_human) .
                  \ "\n"

  if &filetype == 'vim'
    " Vim filetype have '&commentstring=#%s', i.e. no space.  However,
    " the following command to set the commentstring does not work because
    " for Vim filetype, the commentstring is hardcoded.
    "
    "   autocmd FileType vim setlocal commentstring='" %s'  " Does not work.
    "
    " To get around this limitation, we simply do not use &commentstring
    " below.
    let l:comment_to_insert = '" ' . l:comment
  elseif &filetype == 'text'
    let l:comment_to_insert = l:comment
  else
    let l:comment_to_insert = substitute(&commentstring, '%s', l:comment, '')
  endif
  "echo l:comment
  "echo l:comment_to_insert

  execute "normal! i" . l:comment_to_insert

endfunction

map <esc>da :call HDSignature("Added by ")<CR>
map <esc>dc :call HDSignature("Comment by ")<CR>
map <esc>dr :call HDSignature("Created by ")<CR>
map <esc>dm :call HDSignature("Modified by ")<CR>
map <esc>dfa :call HDSignature("Ajouté par ")<CR>
map <esc>dfc :call HDSignature("Commentaire de ")<CR>
map <esc>dfr :call HDSignature("Créé par ")<CR>
map <esc>dfm :call HDSignature("Modifié par ")<CR>
map <esc>dh :call HDSignature("")<CR>
map <esc>ds :call HDSignature("--")<CR>
map <esc>dd O<C-R>=strftime(g:hd_timestamp_format_human)<CR>
map <esc>dl I* <C-R>=strftime($HD_TIMESTAMP_FORMAT_CHANGELOG)<CR>, Hans Deragon<CR>

map m1 ddpkA:  J0j
" Assemble all lines of a paragraph into a single line.
"map <esc>z VapjJi<CR><esc><Down>0
map <esc>z VapKJ0<Down><Down>
set hlsearch

" mru.vim script settings (script use for storing opened file history)
" let MRU_num=10
" if has("win32")
"   let MRU="$HOME/_vimmru"
" else
"   let MRU="$HOME/.vimmru"
" endif

"----------------------------------------------------------------------
"Code for sourcing .vimrc
"----------------------------------------------------------------------
let vimrc          = expand("<sfile>:p")        " current .vimrc

map ,v  :  if (!exists("vimrc") \|\| vimrc == '')
         \  |     echo "Cannot determine current " . ".vimrc"
         \  | else
         \  |     exe "e " . expand(vimrc)
         \  |
         \ endif<CR>
                                "# ,gv  - 'edit' .gvimrc
map ,gv :  if (!exists("gvimrc") \|\| gvimrc == '')
         \  |     echo "Cannot determine current " . ".gvimrc"
         \  | else
         \  |     exe "e " . expand(gvimrc)
         \  |
         \ endif<CR>
                                "# ,u   - 'source' ~/.vimrc
map ,u  :  if (!exists("vimrc") \|\| vimrc == '')
         \  |     echo "Cannot determine current .vimrc"
         \  | else
         \  |     exe "so " . expand(vimrc)
         \  |
         \ endif<CR>
                                "# ,gu  - 'source' .gvimrc
map ,gu :  if (!exists("gvimrc") \|\| gvimrc == '')
         \  |     echo "Cannot determine current " . ".gvimrc"
         \  | else
         \  |     exe "so " . expand(gvimrc)
         \  |
         \ endif<CR>

" automatically source in current '.vimrc'/'.gvimrc'
" if changed in the same session
augroup vimrc
  au!
  autocmd BufWritePost *
                    \ if exists("vimrc") && vimrc == expand("<afile>:p")
                    \  | source <afile>
                    \  |
                    \ endif
  autocmd BufWritePost *
                    \ if exists("gvimrc") && gvimrc == expand("<afile>:p")
                    \  | source <afile>
                    \  |
                    \ endif
augroup END

" De:  http://vim.wikia.com/wiki/Faster_loading_of_large_files
"
" Large files are > 10M
" Set options:
" eventignore+=FileType (no syntax highlighting etc
" assumes FileType always on)
" noswapfile (save copy of file)
" bufhidden=unload (save memory when other file is viewed)
" buftype=nowritefile (is read-only)
" undolevels=-1 (no undo possible)
let g:LargeFile = 1024 * 1024 * 10
augroup LargeFile
  autocmd BufReadPre * let f=expand("<afile>") | if getfsize(f) > g:LargeFile | set eventignore+=FileType | setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1 | else | set eventignore-=FileType | endif
augroup END

" De:  http://vim.wikia.com/wiki/Pretty-formatting_XML
function! DoPrettyXML()
  " save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  1s/<?xml .*?>//e
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format -
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  " back to home
  1
  " restore the filetype
  exe "set ft=" . l:origft
endfunction
command! XMLPretty call DoPrettyXML()

"autocmd BufNewFile,BufReadPre,FileReadPre      *todo* call s:nowrap

" Plugins settings.
let g:miniBufExplSplitToEdge = 0



" STATUS LINE / STATUS BAR AT THE BOTTOM
" ────────────────────────────────────────────────────────────────────────────
"
"   Show the character itself is not easily possible.
"   See:  https://stackoverflow.com/questions/40508385/vim-statusline-show-the-character-itself
"
" Setting status line / bar format.
"set statusline='%F%m%r%h%w\ %{&encoding}/%{&fileencoding}/%{&ff}/%Y\ [\%05.5b\ x\%04.4B]\ C%03v\ L%04l\ %L\/%p\%%'
let &statusline="%F%m%r%h%w %{&encoding}/%{&fileencoding}/%{&ff}/%Y "

" Showing the current character and value in decimal and hexadecimal.
let &statusline .= "◄"
let &statusline .= "%2.2(%{matchstr(getline('.'), '\\%' . col('.') . 'c.')}%)"
let &statusline .= " %04.6b x%04.6B ►"

" Show column number, line number, total lines and % of the document.
let &statusline .= " C%03v\ L%04l\ %L\/%p\%%'"

set laststatus=2  " Always show the status line in every window.



" nostartofline
"
" When "on" the commands listed below move the cursor to the first
" non-blank of the line.  When off the cursor is kept in the same column
" (if possible).
set nostartofline

let corpfile=expand("$HDVIM/../../.$HD_ENV_CORP_IDENTIFIER/vimrc")
if filereadable(corpfile)
  execute "source" corpfile
endif

"let g:ucs_encode_locale=1


" From:  https://github.com/tpope/vim-markdown
"
" One difference between this repository and the upstream files in Vim is that
" the former forces *.md as Markdown, while the latter detects it as Modula-2,
" with an exception for README.md. If you'd like to force Markdown without
" installing from this repository, add the following to your vimrc:
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" Fix YAML indent problem when commenting.
" From:  https://stackoverflow.com/questions/51059357/vim-wrong-indent-when-comment-lines-of-yaml-file
autocmd FileType yaml,yaml.ansible setlocal indentkeys-=0#

" From:  http://vim.wikia.com/wiki/Quick_generic_option_toggling
" Map key to toggle opt
function! MapToggle(key, opt)
  let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
  exec 'nnoremap '.a:key.' '.cmd
  " Comment by Hans Deragon (hans@deragon.biz), 2017-02-22 15:31:56 Est
  " For \w to work in insert mode normally instead of toggling between
  " wrap and no wrap, we must not set inoremap.
  "exec 'inoremap '.a:key." \<C-O>".cmd
endfunction
command! -nargs=+ MapToggle call MapToggle(<f-args>)

MapToggle <Leader>w wrap

" Search for non-ascii/unicode characters
map <Leader>c /[^\x00-\x7F]\+<CR>

" Search for null character
map <Leader>n /[\x00]<CR>

" From: http://superuser.com/questions/271471/vim-macro-to-convert-camelcase-to-lowercase-with-underscores
" Change selected text from NameLikeThis to name_like_this.
vnoremap ,u :s/\C\(\U\&\S\)\([A-Z]\)/\1_\l\2/g<CR>
" Change selected text from name_like_this to NameLikeThis.
vnoremap ,c :s/_\([a-z]\)/\u\1/g<CR>gUl



" VIM-JSON PLUGIN OPTIONS
" ══════════════════════════════════════════════════════════════════════════════

" Disabling concealing of quotes (").
let g:vim_json_syntax_conceal = 0

fun! JsonPretty( arg ) "{{{
  " Call external command 'hdjsonpretty'.
  execute '!hdjsonpretty -i '.expand(shellescape('%:p'))
endfunction "}}}
command! -nargs=* JsonPretty call JsonPretty( '<args>' )

fun! JsonPrettyWithSortedKeys( arg ) "{{{
  " Call external command 'hdjsonpretty'.
  execute '!hdjsonpretty -i -s '.expand(shellescape('%:p'))
endfunction "}}}
command! -nargs=* JsonPrettyWithSortedKeys call JsonPrettyWithSortedKeys( '<args>' )

" From:  https://stackoverflow.com/questions/21708814/can-vim-diff-use-the-patience-algorithm
" Set algorithm:patience.  See:  https://vimways.org/2018/the-power-of-diff/
if has("patch-8.1.0360")
  set diffopt+=internal,algorithm:patience
endif

" Diff function to ignore empty lines
" ══════════════════════════════════════════════════════════════════════════════
"   From:  http://tiebing.blogspot.ca/2013/02/vimdiff-ignore-empty-lines.html
"
"   ATTENTION:  C'est un override de la fonction diff par défaut!!!!
"               S'il y a un problème avec vimdiff, peut-être faut il essayer
"               de mettre 'set diffexpr=MyDiff()' en commentaire.
set diffopt+=iwhite
"set diffexpr=HdDiff()
function! HdDiff()
    let opt = ""
    if &diffopt =~ "icase"
        let opt = opt . "-i "
    endif
    if &diffopt =~ "iwhite"
        let opt = opt . "-w -B " " vim uses -b by default
    endif
    "silent execute "!diff -a --binary " . opt .
    silent execute "!diff -a " . opt .
                \ v:fname_in . " " . v:fname_new .  " > " . v:fname_out
endfunction



" TEMPORARY COMMANDS - COULD BE DELETED ONCE NOT USEFUL ANYMORE
" ══════════════════════════════════════════════════════════════════════════════

" Call generate.sh.  Thus in any project, create a 'generate.sh' script and
" this mapping will allow to call it quickly from VIM.
" map <Leader>g :w<CR>:silent !clear;./generate.sh<CR>



" QUICKMENU (plugin setup)
" ══════════════════════════════════════════════════════════════════════════════
"
"   The Quickmenu plugin does not work with version 7.4.
if v:version > 800
  " Other options that only work with vim 8+
  set belloff=all " Disable all bells/sounds.

  "source $HDVIM/hd-quickmenu.vim
endif

" CSV Plugin
" CSVArrangeColumn <-> UnArrangeColumn (to undo)
