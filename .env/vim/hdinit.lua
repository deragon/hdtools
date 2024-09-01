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


-- nvim-treesitter - https://github.com/nvim-treesitter/nvim-treesitter
-- ────────────────────────────────────────────────────────────────────────────
--
--  The goal of nvim-treesitter is both to provide a simple and easy way to
--  use the interface for tree-sitter in Neovim and to provide some basic
--  functionality such as highlighting based on it.
--
--  Tree-sitter is a parser generator tool and an incremental parsing library.
--  It can build a concrete syntax tree for a source file and efficiently
--  update the syntax tree as the source file is edited.
local ts = require 'nvim-treesitter.configs'
ts.setup {
  -- List of languages supported out-of-the-box at:
  --   https://github.com/nvim-treesitter/nvim-treesitter/?tab=readme-ov-file#supported-languages
  ensure_installed = { 'bash', 'python', 'java', 'javascript', 'typescript', 'sql', 'terraform', 'lua', 'c_sharp' }, -- 'powershell' does not work!
  highlight = { enable = true }
}



-- nvim-cmp - Code completion
-- ────────────────────────────────────────────────────────────────────────────
--   From:  https://github.com/hrsh7th/nvim-cmp
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
-- Set configuration for specific filetype.
--[[ cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' },
  }, {
    { name = 'buffer' },
  })
})
require("cmp_git").setup() ]]--

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

-- Set up lspconfig.
local nvim_cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
--   capabilities = nvim_cmp_capabilities
-- }
-- nvim-cmp - Code completion - END
-- ────────────────────────────────────────────────────────────────────────────


-- mason.nvim
-- ────────────────────────────────────────────────────────────────────────────
--
--   Portable package manager for Neovim that runs everywhere Neovim runs.
--   Easily install and manage LSP servers, DAP servers, linters, and formatters.
--
--   https://github.com/williamboman/mason.nvim
require("mason").setup()

require("mason-lspconfig").setup({
    ensure_installed = { "pyright" },
    capabilities = nvim_cmp_capabilities
})




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
