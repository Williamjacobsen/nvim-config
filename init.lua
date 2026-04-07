-- global settings
vim.g.mapleader = " "
-- NixOS PATH (not needed on Fedora)
-- vim.env.PATH = "/run/current-system/sw/bin:/run/wrappers/bin:" .. vim.env.PATH

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

-- Keymaps

vim.keymap.set("n", "<leader>ex", function()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local cfg = vim.api.nvim_win_get_config(win)
		if cfg.relative > "" then
			pcall(vim.api.nvim_win_close, win, false)
		end
	end
	vim.cmd.Explore()
end, { desc = "Netrw" })

-- Harpoon
local harpoon = require("harpoon")
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add file" })
vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon 1" })
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon 2" })
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon 3" })
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon 4" })

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})

-- Hop  (use <leader> prefix so f/t stay as normal Vim motions)
vim.keymap.set("n", "<leader>hw", "<cmd>HopWord<cr>", { desc = "Hop word" })
vim.keymap.set("n", "<leader>hl", "<cmd>HopLine<cr>", { desc = "Hop line" })
vim.keymap.set("n", "<leader>hc", "<cmd>HopChar1<cr>", { desc = "Hop char" })

-- Jump to paren and enter insert mode (works from any position)
vim.keymap.set("n", "(", function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local after = line:sub(col + 2)
	if after:find("%(") then
		vim.cmd("normal! f(")
	else
		vim.cmd("normal! F(")
	end
	vim.api.nvim_feedkeys("a", "n", false)
end, { noremap = true, silent = true })
vim.keymap.set("n", ")", function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local after = line:sub(col + 2)
	if after:find("%)") then
		vim.cmd("normal! f)")
	else
		vim.cmd("normal! F)")
	end
	vim.api.nvim_feedkeys("i", "n", false)
end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>hl", "<cmd>HopLine<cr>", { desc = "Hop line" })
vim.keymap.set("n", "<leader>hc", "<cmd>HopChar1<cr>", { desc = "Hop char" })

-- Better vertical movement
vim.keymap.set("n", "<C-d>", function()
	local count = math.floor(vim.api.nvim_win_get_height(0) / 4)
	vim.cmd("normal! " .. count .. "jzz")
end, { silent = true })
vim.keymap.set("n", "<C-u>", function()
	local count = math.floor(vim.api.nvim_win_get_height(0) / 4)
	vim.cmd("normal! " .. count .. "kzz")
end, { silent = true })

-- Smart Enter: split {} if on same line, otherwise append ;
vim.keymap.set("n", "<CR>", function()
	local line = vim.api.nvim_get_current_line()
	if line:find("{%s*}") then
		local col = vim.api.nvim_win_get_cursor(0)[2]
		local char = line:sub(col + 1, col + 1)
		-- if cursor is on }, go back to { first
		if char == "}" then
			vim.cmd("normal! F{")
		end
		vim.cmd("normal! f}x")
		vim.cmd("normal! o}")
		vim.cmd("normal! k")
		vim.api.nvim_feedkeys("o", "n", false)
	else
		vim.api.nvim_feedkeys("A;\x1b", "n", false)
	end
end, { noremap = true, silent = true })

-- 8 to start of line, 9 to end of line
vim.keymap.set("n", "8", "^")
vim.keymap.set("n", "9", "$")

-- Keep cursor centred when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>d", function()
	if vim.g.diagnostic_float_win and vim.api.nvim_win_is_valid(vim.g.diagnostic_float_win) then
		vim.api.nvim_win_close(vim.g.diagnostic_float_win, false)
		vim.g.diagnostic_float_win = nil
	else
		vim.g.diagnostic_float_win = vim.diagnostic.open_float(nil, { focusable = false })
	end
end, { desc = "Show/hide diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic list" })

-- Diagnostic display

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
