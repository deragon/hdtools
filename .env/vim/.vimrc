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

if($HDVIM != "")
  set rtp+=$HDVIM
  " echo "${HDVIM} set." $HDVIM
else
  echo "ERROR:  ${HDVIM} is not set.  'rtp' is missing that path."
  echo "rtp=" &rtp
endif

if has('nvim')


  source $HDVIM/commonrc

  "let mapleader = "\\"  " Actually, just type '\'
  lua <<EOF

-- require() does not make use of VIM's rtp setup.  It uses package.path to
-- which we must add ${HDVIM}.

local custom_path = os.getenv("HDVIM")
if custom_path then
    -- Append the custom path to package.path
    package.path = package.path .. ";" .. custom_path .. "/?.lua"
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
require('hdinit')  -- Hans Deragon's init.lua loaded.
EOF
else
  source $HDVIM/vimrc
  source $HDVIM/commonrc
endif
