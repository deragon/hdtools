return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  { "rebelot/kanagawa.nvim" },
  { "catppuccin/nvim", name = "catppuccin", lazy = false },
  { "rose-pine/neovim", name = "rose-pine" },
  { "sainnhe/everforest" },
  { "bluz71/vim-nightfly-colors" },
  { "NLKNguyen/papercolor-theme" },
  { "romainl/Apprentice" },
  { "dasupradyumna/midnight.nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "hdblue",
      colorscheme = "midnight",
    },
  },
}
