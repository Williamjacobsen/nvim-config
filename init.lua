-- global settings
vim.g.mapleader = " "

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

-- Load plugins first
require("plugins")

-- Mason Setup
require("mason").setup({
	ui = {
		icons = {
			package_installed = "",
			package_pending = "",
			package_uninstalled = "",
		},
	},
})
require("mason-lspconfig").setup()

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
sign({ name = "DiagnosticSignWarn", text = "" })
sign({ name = "DiagnosticSignHint", text = "h" })
sign({ name = "DiagnosticSignInfo", text = "" })

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
