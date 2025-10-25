-- From:  https://jdhao.github.io/2020/09/22/highlight_groups_cleared_in_nvim/

-- augroup custom_highlight
--   autocmd!
--   #au ColorScheme * highlight YankColor ctermfg=59 ctermbg=41 guifg=#34495E guibg=#2ECC71
--   au ColorScheme * highlight  Todo         guifg=white     guibg=red    gui=bold   ctermfg=white   ctermbg=red
-- augroup END
--

-- Color table
-- ────────────────────────────────────────────────────────────────────────────
-- Here is a breakdown of the standard 16 ANSI colors and their corresponding numbers:
--
--   Number   Color         Bright Color
--   0        Black         8
--   1        Red           9
--   2        Green         10
--   3        Yellow        11
--   4        Blue          12
--   5        Magenta       13
--   6        Cyan          14
--   7        White/Gray    15

vim.api.nvim_create_augroup("custom_highlight", { clear = true })

-- VimEnter is the point when the editor has loaded everything, is fully
-- initialize and is about to receive input from the user.  It is the best
-- place to override some of the plugins defaults.

-- Creating the custom group that is specific to this file.
vim.api.nvim_create_augroup("hd_final_override_with_vimenter", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  -- group = "custom_highlight",
  group = "hd_final_override_with_vimenter",
  callback = function()
    -- LazyVim is annoying with comments.  Sometimes when indenting with '>',
    -- the code follows but not the comments.  The commands below force
    -- indentation for everything that is selected.
    vim.opt.autoindent = true
    vim.opt.smartindent = true
    vim.opt.cindent = true

    -- Color settings
    vim.api.nvim_set_hl(0, "YankColor", {
      fg = "#34495E",
      bg = "#2ECC71",
      ctermfg = 59,
      ctermbg = 41,
    })

    -- NormalFloat for popup showing function signatures.
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#282C34" }) -- Example: set background to a dark grey
    -- Not sure what a FloatBorder is.
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#282C34", fg = "#61AFEF" }) -- Example: same background for border, with blue foreground

    vim.api.nvim_set_hl(0, "Todo", {
      --   au ColorScheme * highlight  Todo         guifg=white     guibg=red    gui=bold   ctermfg=white   ctermbg=red
      fg = "white",
      bg = "red",
      ctermfg = "white",
      ctermbg = "red",
    })
    vim.api.nvim_set_hl(0, "@comment.todo", {
      --   au ColorScheme * highlight  Todo         guifg=white     guibg=red    gui=bold   ctermfg=white   ctermbg=red
      fg = "white",
      bg = "red",
      ctermfg = "white",
      ctermbg = "red",
    })

    -- Override Snacks plugin highlights because the plugin's default has poor
    -- contrast making it hard to read with dark themes.
    vim.api.nvim_set_hl(0, "SnacksPickerDir", { link = "Normal" })
    vim.api.nvim_set_hl(0, "SnacksPickerFile", { link = "Normal" })
    vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { link = "Special" })

    -- If a dark theme is used, I want the background to be totally black, not
    -- some dark gray which they seam all to use.
    if vim.o.background == "dark" then
      vim.api.nvim_set_hl(0, "Normal", { bg = "black" })
    end

    -- Keymaps settings.
    vim.keymap.set("n", "<Esc>v", function()
      -- Temporarily store the original formatexpr
      local original_formatexpr = vim.opt.formatexpr:get()

      -- Unset formatexpr so gq uses native Vim formatting
      vim.opt.formatexpr = ""

      -- Set textwidth and other options
      vim.cmd("set textwidth=78")
      vim.cmd("set ai")

      -- Execute the formatting command
      vim.cmd("normal! gqap")

      -- Restore the original options
      vim.cmd("set noai")
      vim.cmd("set textwidth=0")
      vim.opt.formatexpr = original_formatexpr
    end, {
      desc = "Format current paragraph",
    })

    vim.opt.title = true

    -- require() does not make use of VIM's rtp setup.  It uses package.path to
    -- which we must add ${HDVIM}.

    local hdvim_path = os.getenv("HDVIM")
    if hdvim_path then
      -- Append the custom path to package.path
      package.path = package.path .. ";" .. hdvim_path .. "/?.lua"
      --                .. ";" .. hdvim_path .. "/nvim/plugins/?.lua"
      -- print(package.path)
      vim.cmd("source " .. hdvim_path .. "/commonrc.vim")
    else
      print("ERROR:  ${HDVIM} is not set.  'package.path' is missing that path:  " .. package.path)
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
  end,
})

return {}
