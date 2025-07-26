-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- ORG

print("lazypath = " .. lazypath)
-- local lazypath = os.getenv("HDVIM") .. "/nvim/plugins/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
-- vim.g.mapleader = "\\"
-- vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({

  -- dev = {
  --   path = os.getenv("HDVIM") .. "/nvim",
  -- },
  debug = true,


  -- { import = os.getenv("HDVIM") .. "/nvim/plugins" },

  -- root = os.getenv("HDVIM") .. "/nvim/plugins",

  spec = {
    -- import your plugins
    { import = "plugins" }, -- ORG
    -- { import = os.getenv("HDVIM") .. "/nvim" },
    -- { import = os.getenv("HDVIM") .. "/nvim/plugins" },
  },

  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },

  -- Added by Hans Deragon (hans@deragon.biz), 2025-06-14 14:37:23 EDT
  --
  -- Setting reset to false prevents lazy.vim to reset rtp, allowing rtp to
  -- keep the paths of plugins loaded with the 'vim-plug' plugin manager for
  -- Vim.
  --
  -- Found the syntaxe about this by looking at the code found at:
  --   https://github.com/folke/lazy.nvim/blob/main/lua/lazy/core/config.lua
  performance = { rtp = { reset = false } },

  rocks = {
    enabled = false,
  }

})
