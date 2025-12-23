vim.opt.relativenumber = true
vim.opt.showmatch = true
vim.opt.ignorecase = true
vim.opt.mouse=v
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.tabstop=4
vim.opt.softtabstop=4
vim.opt.expandtab = true
vim.opt.shiftwidth=4
vim.opt.autoindent = true
vim.opt.number = true
vim.opt.wildmode=longest,list
-- filetype plugin indent on 
-- syntax on = true
vim.opt.mouse=a
vim.opt.clipboard=unnamedplus 
-- filetype plugin on
vim.opt.cursorline = true
vim.opt.ttyfast = true
vim.opt.cmdheight = 0
vim.cmd [[set clipboard=unnamedplus]]
vim.api.nvim_create_user_command('WQ', 'wq', {})
vim.api.nvim_create_user_command('Wq', 'wq', {})
vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('Qa', 'qa', {})
vim.api.nvim_create_user_command('Q', 'q', {})
-- Remap Tab/Shift-Tab to Intend/De-Intend
vim.keymap.set("n", "<tab>", ">>")
vim.keymap.set("n","<s-tab>","<<")
vim.keymap.set("v","<tab>","> gv")
vim.keymap.set("v","<s-tab>","< gv")
-- End

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
     "Mofiqul/dracula.nvim",
     "williamboman/mason.nvim",
     "williamboman/mason-lspconfig.nvim",
     "neovim/nvim-lspconfig",
     "hrsh7th/cmp-nvim-lsp",
     "hrsh7th/cmp-buffer",
     "hrsh7th/cmp-path",
     "hrsh7th/cmp-cmdline",
     "hrsh7th/nvim-cmp",
     "L3MON4D3/LuaSnip",
         "nvim-treesitter/nvim-treesitter",

  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  -- install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = false },
})

require("nvim-treesitter.configs").setup({

ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "go", "python", "heex", "javascript", "html" },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },  
})

require("mason").setup()
require("mason-lspconfig").setup()
require'lspconfig'.gopls.setup{
settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
}
require'lspconfig'.pylsp.setup{}
local cmp = require("cmp")
local cmp_lsp = require("cmp_nvim_lsp")
        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                ["<C-y>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, 
            {
                { name = 'buffer' },
            })
        })

vim.cmd [[colorscheme dracula]]

-- format golang imports on write
local autocmd = vim.api.nvim_create_autocmd
 autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want longer. Add an additional
    -- argument after params if you find that you have to write the file
    -- twice for changes to be saved.
    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({async = false})
  end
})

