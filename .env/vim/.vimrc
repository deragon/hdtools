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

if($HDVIM != "")
  set rtp+=$HDVIM
  " echo "${HDVIM} set." $HDVIM
else
  echo "ERROR:  ${HDVIM} is not set.  'rtp' is missing that path."
  echo "rtp=" &rtp
endif

if has('nvim')

  lua <<EOF

  -- require() does not make use of VIM's rtp setup.  It uses package.path to
  -- which we must add ${HDVIM}.

  local hdvim_path = os.getenv("HDVIM")
  if hdvim_path then
      -- Append the custom path to package.path
      package.path = package.path
                     .. ";" .. hdvim_path .. "/?.lua"
      --                .. ";" .. hdvim_path .. "/nvim/plugins/?.lua"
      -- print(package.path)
  else
      print("ERROR:  ${HDVIM} is not set.  'package.path' is missing that path.")
      print(package.path)
  end

  -- NvChad
  --
  --package.path = package.path .. ";" .. os.getenv("HDVIM") .. '/?.lua' .. ";" .. os.getenv("HOME") .. '/.config/nvim/?.lua'
  --print(package.path)
  --print(package.searchpath('init', package.path))
  --require(os.getenv("HOME") .. '/.config/nvim/init')
  --
  --require('init')  -- NvChad init.lua loaded.


  -- print(vim.o.runtimepath)
  --require('hdnvim')  -- Hans Deragon's init.lua loaded.
  --dofile(hdvim_path .. '/nvim/config/nvim/lua/hdnvim.lua')  -- Hans Deragon's init.lua loaded.
  dofile(hdvim_path .. '/nvim/config/nvim/init.lua')  -- Hans Deragon's init.lua loaded.
EOF

  set rtp+=$HDVIM/nvim

  "echo "NVIM detected."
  cmap ,u :source $HDVIM/.vimrc<CR>:echo "Sourced " . $HDVIM . "/.vimrc"<CR>

  "let mapleader = "\\"  " Actually, just type '\'
else
  source $HDVIM/vimrc.vim
endif

source $HDVIM/commonrc.vim
