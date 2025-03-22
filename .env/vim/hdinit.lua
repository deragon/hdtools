-- Sharing config between vim and Neovim
--
-- From:  https://vi.stackexchange.com/questions/12794/how-to-share-config-between-vim-and-neovim
-- vim.opt.rtp:prepend(os.getenv("HDVIM"))
-- vim.opt.rtp:append(os.getenv("HDVIM") .. "/after")

--vim.opt.packpath = vim.opt.rtp

--vim.cmd("source " .. os.getenv("HDVIMRC"))


-- Generated by Bing, 2024-09-11 10:10:00 EDT Function is not very helpful.
-- It prints the hexadecimal adress of the function, not the name.
-- Apparently, Lua does not save the name of functions..
-- local function print_mappings(mappings)
--   for key, value in pairs(mappings) do
--     if type(value) == "table" and value["i"] then
--       print(key .. " -> " .. tostring(value["i"]))
--     else
--       print(key .. " -> " .. tostring(value))
--     end
--   end
-- end


-- LSP - LANGUAGE SERVER PROTOCOL
-- ══════════════════════════════════════════════════════════════════════════════
--
--   List of languages available at:
--
--     Locally:   '${HDVIM}/plugged/nvim-lspconfig/doc/configs.md'
--     Web:       https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
local lspconfig = require 'lspconfig'
lspconfig.pyright.setup{}               -- Python
lspconfig.bashls.setup{}                -- Bash
-- lspconfig.java_language_server.setup{}  -- Java
lspconfig.sqlls.setup{}                 -- SQL
-- lspconfig.terraform_lsp.setup{}         -- Terraform


-- nvim-treesitter - https://github.com/nvim-treesitter/nvim-treesitter
-- ────────────────────────────────────────────────────────────────────────────
--
--  Tree-sitter is a parser generator tool and an incremental parsing library.
--  It can build a concrete syntax tree for a source file and efficiently
--  update the syntax tree as the source file is edited.
--
--  The goal of nvim-treesitter is both to provide a simple and easy way to
--  use the interface for tree-sitter in Neovim and to provide some basic
--  functionality such as highlighting based on it.
local treesitter = require 'nvim-treesitter.configs'
treesitter.setup {
  -- List of languages supported out-of-the-box at:
  --   https://github.com/nvim-treesitter/nvim-treesitter/?tab=readme-ov-file#supported-languages
  -- comment:  Highlight keywords in comments such as 'TODO', 'FIXME', 'BUG'.
  ensure_installed = { 'comment', 'bash', 'python', 'java', 'javascript', 'typescript', 'sql', 'terraform', 'lua', 'c_sharp' }, -- 'powershell' does not work!
  highlight = { enable = true }
}


-- nvim-cmp - Completion for code and command-line (CMP == completion)
-- ────────────────────────────────────────────────────────────────────────────
--   From:  https://github.com/hrsh7th/nvim-cmp
local cmp = require 'cmp'

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
  preselect = cmp.PreselectMode.FirstItem,
  mapping = cmp.mapping.preset.insert({
    -- ['<C-b>']     = cmp.mapping.scroll_docs(-4),
    -- ['<C-f>']     = cmp.mapping.scroll_docs(4),
    ['<C-<Up>']     = cmp.mapping.scroll_docs(-4),
    ['<C-<Down>']   = cmp.mapping.scroll_docs(4),
    ['<C-Space>']   = cmp.mapping.complete(),
    -- ['<C-e>']     = cmp.mapping.abort(),
    ['<Tab>']       = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    -- From:  https://www.reddit.com/r/neovim/comments/10x2ryc/how_to_prevent_enter_key_select_first_suggestion/
    -- ["<CR>"] = cmp.config.disable,
    -- ["<C-p>"] = cmp.mapping.select_prev_item(),
    -- ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-y>"] = cmp.mapping.confirm()

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

local cmp_custom_mappings = {
    -- ['<C-b>']     = cmp.mapping.scroll_docs(-4),
    -- ['<C-f>']     = cmp.mapping.scroll_docs(4),

    -- Code copied and adapted from nvim-cmp/lua/cmp/config/mapping.lua,
    -- mapping.preset.cmdline = function(override)
    ['<Down>'] = {
      c = function()
        local cmp = require('cmp')
        if cmp.visible() then
          cmp.select_next_item()
        -- else
        --   cmp.complete()
        end
      end,
    },
    ['<Up>'] = {
      c = function()
        local cmp = require('cmp')
        if cmp.visible() then
          cmp.select_prev_item()
        else
          cmp.complete()
        end
      end,
    }
}

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  -- Original code:  mapping = cmp.mapping.preset.cmdline(),
  mapping = cmp.mapping.preset.cmdline(cmp_custom_mappings),
  sources = cmp.config.sources(
    { { name = 'path'    } },
    { { name = 'cmdline' } }
  ),
  matching = { disallow_symbol_nonprefix_matching = false }
})

-- Print the current mapping configuration
-- local mappings = cmp.get_config().mapping
-- print(vim.inspect(mappings))
-- print_mappings(mappings)

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


-- NVIM OPTIONS
-- ══════════════════════════════════════════════════════════════════════════════
--
--  From:  https://www.reddit.com/r/neovim/comments/lf6zlb/setting_nvim_options_in_lua/

local go = vim.o
local bo = vim.bo --> buffer only use bo
local wo = vim.wo --> window only use wo

-- No need for a global function
local set_options = function(locality, options)
  for key, value in pairs(options) do
    locality[key] = value
  end
end

local options_global = {
  -- Setup the sign column.  From:
  --
  --   - https://www.reddit.com/r/neovim/comments/wceanu/how_do_i_stop_the_screen_from_shifting_when_the/
  --   - https://www.reddit.com/r/neovim/comments/neaeej/only_just_discovered_set_signcolumnnumber_i_like/
  signcolumn = "yes:1",

  --hlsearch = true, -- don't highlight matching search
  --cursorline = true, -- enable cursorline
}
set_options(go, options_global)

-- local options_buffer = {
-- }
-- set_options(bo, options_buffer)

-- local options_window = {
-- }
-- set_options(wo, options_window)
