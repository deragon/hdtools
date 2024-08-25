-- Sharing config between vim and Neovim
--
-- From:  https://vi.stackexchange.com/questions/12794/how-to-share-config-between-vim-and-neovim
-- vim.opt.rtp:prepend(os.getenv("HDVIM"))
-- vim.opt.rtp:append(os.getenv("HDVIM") .. "/after")

--vim.opt.packpath = vim.opt.rtp

--vim.cmd("source " .. os.getenv("HDVIMRC"))



-- LSP - LANGUAGE SERVER PROTOCOL
-- ══════════════════════════════════════════════════════════════════════════════

require 'lspconfig'.pyright.setup{}
--require 'lspconfig'.bash.setup{}
--require 'lspconfig'.java.setup{}

local ts = require 'nvim-treesitter.configs'
ts.setup {
  -- List of languages supported out-of-the-box at:
  --   https://github.com/nvim-treesitter/nvim-treesitter/?tab=readme-ov-file#supported-languages
  ensure_installed = { 'bash', 'python', 'java', 'javascript', 'typescript', 'sql', 'terraform', 'lua', 'c_sharp' }, -- 'powershell' does not work!
  highlight = { enable = true }
}

-- Setup the sign column
-- vim.cmd [[ autocmd User LspDiagnosticsChanged set signcolumn=yes:2 ]]

-- From:  https://www.reddit.com/r/neovim/comments/lf6zlb/setting_nvim_options_in_lua/

local go = vim.o
local bo = vim.bo --> buffer only use bo
local wo = vim.wo --> window only use wo

-- no need for a global function
local set_options = function(locality, options)
  for key, value in pairs(options) do
    locality[key] = value
    end
end

-- define our options
local options_global = {
  -- From:
  --   - https://www.reddit.com/r/neovim/comments/wceanu/how_do_i_stop_the_screen_from_shifting_when_the/
  --   -  https://www.reddit.com/r/neovim/comments/neaeej/only_just_discovered_set_signcolumnnumber_i_like/
  signcolumn = "yes:1",

  --hlsearch = true, -- don't highlight matching search
  --cursorline = true, -- enable cursorline
}

local options_buffer = {
}

local options_window = {
}

--set locally. no need to call elsewhere
set_options(go, options_global)
set_options(bo, options_buffer)
set_options(wo, options_window)
