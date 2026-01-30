-- global settings
vim.g.mapleader = " "

-- IMPORTANT: Reduce delay for CursorHold autocmd
vim.opt.updatetime = 300  -- Show diagnostics after 300ms instead of 4000ms

-- line count settings
vim.opt.number = true
vim.opt.relativenumber = true

-- remap settings
vim.keymap.set("n", "<leader>ex", vim.cmd.Ex)

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true

vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.mouse = "a" -- Enable mouse in all modes

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("plugins")

-- Mason Setup
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

require("mason-lspconfig").setup()

-- Auto-install formatters and LSPs using mason-tool-installer
local status_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
if status_ok then
  mason_tool_installer.setup({
    ensure_installed = {
      "stylua",      -- Lua formatter
      "rustfmt",     -- Rust formatter
      "prettier",    -- JSON/JS/TS formatter
      "pyright",     -- Python LSP
      "ruff",        -- Python linter & formatter (fast!)
      "black",       -- Python formatter (alternative)
    },
    auto_update = false,
    run_on_start = true,
  })
end

-- LSP Configuration
local lspconfig = require("lspconfig")

-- Python LSP setup (Pyright)
lspconfig.pyright.setup({
  on_attach = function(client, bufnr)
    -- Enable completion
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- Keybindings for LSP
    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
})

-- Then set up telescope-dependent keymaps
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})

-- Hop navigation (easymotion alternative)
vim.keymap.set("", "f", "<cmd>lua require'hop'.hint_char1()<cr>", {})
vim.keymap.set("", "F", "<cmd>lua require'hop'.hint_char2()<cr>", {})
vim.keymap.set("", "t", "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<cr>", {})
vim.keymap.set("", "T", "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<cr>", {})

-- Quick access to Hop commands
vim.keymap.set("n", "<leader>s", "<cmd>HopWord<cr>", {})
vim.keymap.set("n", "<leader>l", "<cmd>HopLine<cr>", {})

-- Better vertical movement
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep cursor centered when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Diagnostic/Lint error navigation - THESE SHOULD WORK NOW
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic in floating window" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic (alternative)" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Show all diagnostics in location list" })

-- Debug command to check if diagnostics exist
vim.keymap.set("n", "<leader>dd", function()
  local diagnostics = vim.diagnostic.get(0)
  if #diagnostics == 0 then
    print("No diagnostics found in current buffer")
  else
    print("Found " .. #diagnostics .. " diagnostics")
    vim.diagnostic.open_float()
  end
end, { desc = "Debug diagnostics" })

local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})

-- LSP Diagnostics Options Setup
local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = "",
  })
end

sign({ name = "DiagnosticSignError", text = "x" })
sign({ name = "DiagnosticSignWarn", text = "!" })
sign({ name = "DiagnosticSignHint", text = "h" })
sign({ name = "DiagnosticSignInfo", text = "i" })

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  update_in_insert = true,
  underline = true,
  severity_sort = false,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])
