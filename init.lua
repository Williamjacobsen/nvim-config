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

-- Then set up telescope-dependent keymaps
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

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
