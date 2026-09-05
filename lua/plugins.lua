require("lazy").setup({

	-- ── Infrastructure ──────────────────────────────────────────────────────────
	{ "folke/lazy.nvim" },
	{ "nvim-lua/plenary.nvim", lazy = true },

	-- Mason
	{ "williamboman/mason.nvim", lazy = false, priority = 1000 },
	{ "williamboman/mason-lspconfig.nvim", dependencies = { "williamboman/mason.nvim" } },
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"rust-analyzer",
					"stylua",
					"prettier",
					"typescript-language-server",
					"svelte-language-server",
					"eslint-lsp",
					"eslint_d",
					"html-lsp",
					"css-lsp",
					"json-lsp",
					"emmet-language-server",
					"pyright",
					"ruff",
					"black",
					"codelldb",
					"clang-format",
					"lua-language-server",
					"gopls",
					"goimports",
					"gofumpt",
					"slint-lsp",
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},

	-- ── Completion ──────────────────────────────────────────────────────────────
	{
		"hrsh7th/nvim-cmp",
		lazy = false,
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},

	-- ── LSP ─────────────────────────────────────────────────────────────────────
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

			local exepath = function(name)
				local mason_tool = mason_bin .. "/" .. name
				if vim.fn.executable(mason_tool) == 1 then
					return mason_tool
				end
				return vim.fn.exepath(name)
			end

			local on_attach = function(_, bufnr)
				local opts = { buffer = bufnr, noremap = true, silent = true }
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<C-S-k>", vim.lsp.buf.signature_help, opts)
				vim.keymap.set("i", "<C-S-k>", vim.lsp.buf.signature_help, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
			end

			vim.lsp.config("pyright", {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
							typeCheckingMode = "basic",
						},
					},
				},
			})
			vim.lsp.enable("pyright")

			local clangd_bin = vim.fn.exepath("clangd")
			if clangd_bin ~= "" then
				vim.lsp.config("clangd", {
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = { clangd_bin, "--background-index", "--clang-tidy", "--completion-style=detailed" },
				})
				vim.lsp.enable("clangd")
			end

			local lua_ls_bin = vim.fn.exepath("lua-language-server")
			if lua_ls_bin ~= "" then
				vim.lsp.config("lua_ls", {
					capabilities = capabilities,
					on_attach = on_attach,
					settings = {
						Lua = {
							runtime = { version = "Lua 5.1" },
							workspace = { checkThirdParty = false },
							telemetry = { enable = false },
						},
					},
				})
				vim.lsp.enable("lua_ls")
			end

			local gopls_bin = exepath("gopls")
			if gopls_bin ~= "" then
				vim.lsp.config("gopls", {
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = { gopls_bin },
					settings = {
						gopls = {
							gofumpt = true,
							analyses = {
								nilness = true,
								unusedwrite = true,
								unusedparams = true,
								useany = true,
							},
							staticcheck = true,
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					},
				})
				vim.lsp.enable("gopls")
			end

			local ts_ls_bin = exepath("typescript-language-server")
			if ts_ls_bin ~= "" then
				vim.lsp.config("ts_ls", {
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = { ts_ls_bin, "--stdio" },
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "literal",
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
							},
						},
						javascript = {
							inlayHints = {
								includeInlayParameterNameHints = "literal",
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
							},
						},
					},
				})
				vim.lsp.enable("ts_ls")
			end

			local svelte_bin = exepath("svelteserver")
			if svelte_bin ~= "" then
				vim.lsp.config("svelte", {
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = { svelte_bin, "--stdio" },
				})
				vim.lsp.enable("svelte")
			end

			local eslint_bin = exepath("vscode-eslint-language-server")
			if eslint_bin ~= "" then
				vim.lsp.config("eslint", {
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = { eslint_bin, "--stdio" },
				})
				vim.lsp.enable("eslint")
			end

			local html_bin = exepath("vscode-html-language-server")
			if html_bin ~= "" then
				vim.lsp.config("html", {
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = { html_bin, "--stdio" },
				})
				vim.lsp.enable("html")
			end

			local css_bin = exepath("vscode-css-language-server")
			if css_bin ~= "" then
				vim.lsp.config("cssls", {
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = { css_bin, "--stdio" },
				})
				vim.lsp.enable("cssls")
			end

			local json_bin = exepath("vscode-json-language-server")
			if json_bin ~= "" then
				vim.lsp.config("jsonls", {
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = { json_bin, "--stdio" },
				})
				vim.lsp.enable("jsonls")
			end

			local emmet_bin = exepath("emmet-language-server")
			if emmet_bin ~= "" then
				vim.lsp.config("emmet_language_server", {
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = { emmet_bin, "--stdio" },
					filetypes = {
						"html",
						"css",
						"javascriptreact",
						"typescriptreact",
						"vue",
						"svelte",
					},
				})
				vim.lsp.enable("emmet_language_server")
			end

			local slint_lsp_bin = vim.fn.exepath("slint-lsp")
			if slint_lsp_bin ~= "" then
				vim.lsp.config("slint_lsp", {
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = { slint_lsp_bin },
				})
				vim.lsp.enable("slint_lsp")
			end
		end,
	},

	-- ── Rust (NixOS + rustaceanvim – fixed config) ──────────────────────────────
	{
		"mrcjkb/rustaceanvim",
		version = "^8",
		lazy = false,
		config = function()
			local on_attach = function(_, bufnr)
				local opts = { buffer = bufnr, noremap = true, silent = true }
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<C-S-k>", vim.lsp.buf.signature_help, opts)
				vim.keymap.set("i", "<C-S-k>", vim.lsp.buf.signature_help, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

				if vim.lsp.inlay_hint then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end

			vim.g.rustaceanvim = {
				server = {
					cmd = function()
						return { vim.fn.exepath("rust-analyzer") }
					end,
					on_attach = on_attach,
					capabilities = require("cmp_nvim_lsp").default_capabilities(),
					default_settings = {
						["rust-analyzer"] = {
							cargo = {
								allFeatures = true,
								loadOutDirsFromCheck = true,
							},
							procMacro = { enable = true },
							checkOnSave = true,
							check = { command = "clippy" },
							completion = {
								autoImport = { enable = true },
								callable = { snippets = "fill_arguments" },
							},
							inlayHints = {
								bindingModeHints = { enable = true },
								closingBraceHints = { enable = true, minLines = 0 },
								closureReturnTypeHints = { enable = true },
								lifetimeElisionHints = { enable = "always" },
								parameterHints = { enable = true },
								reborrowHints = { enable = "always" },
								typeHints = { enable = true },
							},
						},
					},
				},
			}
		end,
	},

	-- ── Colour scheme ───────────────────────────────────────────────────────────
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 900,
		config = function()
			vim.cmd("colorscheme rose-pine")
		end,
	},

	-- ── Treesitter (updated for main branch / 2026 refactor) ────────────────────
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			-- nvim-treesitter main branch: install parsers explicitly and let Neovim
			-- provide highlighting through vim.treesitter.start().
			local parsers = {
				"c", "cpp", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",
				"javascript", "typescript", "tsx", "svelte", "html", "css", "json", "yaml",
				"rust", "python", "go", "gomod", "gosum", "gowork", "slint",
			}
			require("nvim-treesitter").install(parsers)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},

	-- ── Formatter ───────────────────────────────────────────────────────────────
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				rust = { "rustfmt" },
				json = { "prettier" },
				jsonc = { "prettier" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				python = { "ruff_format", "black" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				go = { "goimports", "gofumpt" },
			},
				format_on_save = { timeout_ms = 500, lsp_fallback = true },
			})
		end,
	},

	-- ── Linter ──────────────────────────────────────────────────────────────────
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				python = { "ruff" },
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				svelte = { "eslint_d" },
			}
			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},

	-- ── Autopairs ───────────────────────────────────────────────────────────────
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},

	-- ── Hop ─────────────────────────────────────────────────────────────────────
	{
		"phaazon/hop.nvim",
		branch = "v2",
		config = function()
			require("hop").setup()
		end,
	},

	-- ── Smear Cursor ───────────────────────────────────────────────────────────
	-- Disabled: animated cursor redraws can make terminal Neovim feel delayed.

	-- ── Multi Cursor ───────────────────────────────────────────────────────────
	{
		"mg979/vim-visual-multi",
		branch = "master",
	},

	-- ── Harpoon ────────────────────────────────────────────────────────────────
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon"):setup()
		end,
	},

	-- ── Telescope ───────────────────────────────────────────────────────────────
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local rg = vim.fn.resolve(vim.fn.exepath("rg"))
			vim.notify("telescope rg: " .. rg, vim.log.levels.DEBUG)
			require("telescope").setup({
				defaults = {
					vimgrep_arguments = rg ~= "" and {
						rg,
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
					} or nil,
				},
			})
		end,
	},

	-- ── Mason setup ─────────────────────────────────────────────────────────────
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
})
