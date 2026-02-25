-- global settings
vim.g.mapleader = " "

vim.opt.updatetime = 300
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.signcolumn = "yes"

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

-- Load plugins (everything is configured inside plugins.lua)
require("plugins")

-- ── Keymaps ───────────────────────────────────────────────────────────────────

vim.keymap.set("n", "<leader>ex", vim.cmd.Ex)

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})

-- Hop  (use <leader> prefix so f/t stay as normal Vim motions)
vim.keymap.set("n", "<leader>hw", "<cmd>HopWord<cr>", { desc = "Hop word" })
vim.keymap.set("n", "<leader>hl", "<cmd>HopLine<cr>", { desc = "Hop line" })
vim.keymap.set("n", "<leader>hc", "<cmd>HopChar1<cr>", { desc = "Hop char" })

-- Better vertical movement
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep cursor centred when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic list" })

-- ── Diagnostic display ────────────────────────────────────────────────────────

local sign = function(opts)
	vim.fn.sign_define(opts.name, { texthl = opts.name, text = opts.text, numhl = "" })
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
	severity_sort = true,
	float = { border = "rounded", source = "always", header = "", prefix = "" },
})

vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, { focusable = false })
	end,
})
