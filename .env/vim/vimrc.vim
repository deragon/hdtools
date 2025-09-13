" ─ Copyright Notice ───────────────────────────────────────────────────
"
" Copyright 2000-2025 Hans Deragon - AGPL 3.0 licence.
"
" Hans Deragon (hans@deragon.biz) owns the copyright of this work.  It is
" released under the GNU Affero General Public License which can be found at:
"
"     https://www.gnu.org/licenses/agpl-3.0.en.html
"
" ─────────────────────────────────────────────────── Copyright Notice ─

" This file is specific to Vim.  Neovim must not load this file.

" Help:  \h

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


" RunTime Path - Setup
" ════════════════════════════════════════════════════════════════════
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
else
  echo "ERROR:  ${HDVIM} is not set.  'rtp' is missing that path:"
  echo "rtp=" &rtp
endif


" Various setup.
" ════════════════════════════════════════════════════════════════════

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
" Section: Code {{{1

" ════════════════════════════════════════════════════════════════════
" These options must be set first thus must be found at the beginning of the
" script, because some will reset values and otions if they were set before.

set nocompatible " Use Vim defaults (much better!)

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


" Neural plugin - https://github.com/dense-analysis/neural
" ════════════════════════════════════════════════════════════════════
"
"   A ChatGPT Vim plugin, an OpenAI Neovim plugin, and so much more! Neural
"   integrates various machine learning tools so you can let AI write code for
"   you in Vim/Neovim, among other helpful things.
"
" MUST PAY A SUBSCRIPTION TO USE THE API.
let g:neural = {
\   'source': {
\       'openai': {
\           'api_key': $OPENAI_API_KEY_SECRET,
\       },
\   },
\}
" ════════════════════════════════════════════════════════════════════


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



" NVIM / NEOVIM
" ══════════════════════════════════════════════════════════════════════════════
"
" Loading of nvim 'hdinit.lua' file needs to be performed after all the
" plugins have been loaded within this .vimrc because it hdinit.lua'
" depends on some plugins.

" Fetch first character of the comment string, to get the comment character.
" Does not exists in Nvim.
" Commented out because not being used.
" let commentcharacter=split(&commentstring, '%s')[0]

"if($HD_OS_FAMILY != "AIX")
colorscheme hdblue
"else
"  colorscheme <put here an AIX compatible color scheme>
"endif

" There is no printer facility in Nvim.  There use to be the 'hardcopy'
" command, but that has been removed.
"
" http://vim.wikia.com/wiki/Printing_using_kprinter
" kprinter non disponible pour Ubuntu >=11.04.  gtklp est l'alternative.
"set printexpr=system('kprinter'\ .\ '\ '\ .\ v:fname_in)\ .\ delete(v:fname_in)\ +\ v:shell_error
set printexpr=system('gtklp'\ .\ '\ '\ .\ v:fname_in)\ .\ delete(v:fname_in)\ +\ v:shell_error

if($HDVIM != "")
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

  " silent! is used here to avoid native gvim on Windows to display the
  " following error message:
  "
  "   [vim-plug] `git` executable not found. Most commands will not be
  "   available. To suppress this message, prepend `silent!` to `call
  "   plug#begin(...)`.

  silent! call plug#begin('$HDVIM/plugged')
  Plug 'rickhowe/diffchar.vim'
  Plug 'AndrewRadev/linediff.vim'

  " CSV Plugin
  " CSVArrangeColumn <-> UnArrangeColumn (to undo)
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

  " On-demand loading
  call plug#end()
else
  echo "ERROR:  ${HDVIM} is not set.  'rtp' is missing that path:"
  echo "rtp=" &rtp
endif


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
