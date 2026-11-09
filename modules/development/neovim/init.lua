-- Options --
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.o.clipboard = "unnamedplus"

vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded"

vim.o.expandtab = true

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.inccommand = "split"
vim.o.confirm = true

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  virtual_text = true,
  virtual_lines = false,

  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      })
    end,
  },
})

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>w", "<C-w>", { desc = "Better C-w" })
vim.keymap.set("n", "<leader>v", "<cmd>vsplit<cr>", { desc = "split vertically" })
vim.keymap.set("n", "<leader>h", "<cmd>split<cr>", { desc = "split horizontally" })

-- Colors are configured by Stylix in the generated Home Manager init.lua.
-- Change modules/desktop/theme.nix rather than loading a separate colorscheme.
vim.opt.termguicolors = true

-- Flash --
vim.pack.add({ "https://github.com/folke/flash.nvim" })

local f = require("flash")
vim.keymap.set({ "n", "x", "o" }, "<leader>s", f.jump, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "<leader>S", f.treesitter, { desc = "Flash Treesitter" })
vim.keymap.set({ "o" }, "r", f.remote, { desc = "Remote Flash" })
vim.keymap.set({ "o", "x" }, "R", f.treesitter_search, { desc = "Treesitter Search" })
vim.keymap.set({ "c" }, "<c-s>", f.toggle, { desc = "Toggle Flash Search" })

-- Which key --
vim.pack.add({ "https://github.com/folke/which-key.nvim" })
local wk = require("which-key")
vim.keymap.set("n", "<leader>?", wk.show, { desc = "Buffer Local Keymaps (which-key)" })

-- Markdown --
vim.pack.add({ "https://github.com/iamcco/markdown-preview.nvim" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>pr", "<cmd>MarkdownPreview<CR>", {
      desc = "Markdown Preview",
    })
  end,
})

-- LSP --
vim.pack.add({
  "https://github.com/saghen/blink.cmp",
  "https://github.com/saghen/blink.lib",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/DrKJeff16/wezterm-types",
})

require("lazydev").setup({
  library = {
    { path = "wezterm-types", mods = { "wezterm" } },
  },
})

require("blink.cmp").setup({
  keymap = { preset = "super-tab" },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
  },
  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },
  },
  fuzzy = { implementation = "lua" },
  signature = { enabled = true },
})

vim.lsp.enable({
  "gopls",
  "lua_ls",
  "nil_ls",
  "basedpyright",
  "rust_analyzer",
  "clangd",
  "cmake",
})

-- Formatting --
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    nix = { "nixfmt" },
    python = { "isort", "black" },
    rust = { "rustfmt", lsp_format = "fallback" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
  },
})

vim.keymap.set("n", "<leader>lf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

vim.pack.add({
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/braam-76/mini-in-one.nvim",
})

-- Mini --
---@type MiniInOne
local mini_in_one = require("mini-in-one")
mini_in_one.setup({
  icons = "defaults",
  pairs = "defaults",
  surround = "defaults",
  diff = "defaults",
  notify = "defaults",
  indentscope = "defaults",

  ai = {
    mappings = {
      around_next = "aa",
      inside_next = "ii",
    },
    n_lines = 500,
  },

  statusline = {
    use_icons = vim.g.have_nerd_font,
  },

  pick = {
    window = {
      config = { border = "rounded" },
    },
  },
})

local pick = mini_in_one.pick.builtin
vim.keymap.set("n", "<leader> ", pick.files, { desc = "Mini files" })
vim.keymap.set("n", "<leader>mg", pick.grep_live, { desc = "Mini grep live" })
vim.keymap.set("n", "<leader>mb", pick.buffers, { desc = "Mini buffers" })
vim.keymap.set("n", "<leader>mh", pick.help, { desc = "Mini help" })

-- Git --
vim.pack.add({ "https://github.com/NeogitOrg/neogit" })

vim.keymap.set("n", "<leader>g", "<cmd>Neogit<CR>", { desc = "Open Neogit" })

vim.pack.add({ "https://github.com/stevearc/oil.nvim" })
require("oil").setup({
  default_file_explorer = true,
  columns = {
    "icon",
    "permissions",
    "size",
    "mtime",
  },
})
vim.keymap.set("n", "<leader>-", "<cmd>Oil<CR>", { desc = "Open netrw" })

vim.pack.add({ "https://github.com/tpope/vim-abolish" })
