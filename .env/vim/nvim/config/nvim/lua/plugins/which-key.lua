-- which-key.lua - which-key plugin configuration for Hans Deragon's Neovim setup
-- Adds descriptions for custom keymaps defined in commonrc.vim

return {
  "folke/which-key.nvim",
  opts = {},
  config = function()
    local wk = require("which-key")

    -- Register descriptions for wrap commands from commonrc.vim
    wk.add({
      { "<leader>w",  group = "Wrap text" },
      { "<leader>wc", desc = "Center for 80 cols" },
      { "<leader>wg", desc = "Wrap to 72 cols (Git)" },
      { "<leader>w5", desc = "Wrap to 50 cols" },
      { "<leader>w6", desc = "Wrap to 60 cols" },
      { "<leader>w8", desc = "Wrap to 80 cols" },
    })
  end,
}
