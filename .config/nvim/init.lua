-- ========================================================================== --
--  1. BOOTSTRAP LAZY.NVIM
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
--  2. GENERAL SETTINGS
-- ========================================================================== --
vim.g.mapleader = " "             -- Space is the leader key
vim.g.maplocalleader = " "
vim.opt.number = true             -- Show line numbers
vim.opt.relativenumber = true     -- Relative line numbers
vim.opt.mouse = "a"               -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard (Hyprland)
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true

-- ========================================================================== --
--  3. PLUGINS
-- ========================================================================== --
require("lazy").setup({
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
	},
	{
		"folke/mini.nvim",
		lazy = true,
		config = function()
			require("mini.starter").setup()
		end
	},
	-- THEME: Catppuccin Mocha
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({ flavour = "mocha" })
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- UI: Telescope (Fuzzy Finder)
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require('telescope.builtin')
			vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
			vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Grep Files' })
		end
	},

	-- UI: Status Line (Lualine)
	{
		"nvim-lualine/lualine.nvim",
		opts = { options = { theme = "catppuccin" } }
	},

	-- SYNTAX: Treesitter (Better Highlighting)
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "go", "gomod", "python", "lua", "vim", "bash", "markdown" },
				auto_install = true,
				highlight = { enable = true },
			})
		end,
	},

	-- LSP: Mason (Installer) & LSP Config
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp", -- Integration with autocomplete
			"j-hui/fidget.nvim", -- UI for LSP progress
		},
		config = function()
			require("mason").setup()
			require("fidget").setup({})

			local lspconfig = require("lspconfig")
			local cmp_nvim_lsp = require('cmp_nvim_lsp')

			require("mason-lspconfig").setup({
				ensure_installed = { "gopls", "pyright", "lua_ls", "jsonls" },
				handlers = { -- Corrected function name and logic
					function(server_name)
						lspconfig[server_name].setup({
							capabilities = cmp_nvim_lsp.default_capabilities(),
						})
					end,
				},
			})
		end,
	},

	-- AUTOCOMPLETE: Cmp
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
				mapping = cmp.mapping.preset.insert({
					['<C-n>'] = cmp.mapping.select_next_item(),
					['<C-p>'] = cmp.mapping.select_prev_item(),
					['<C-d>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<CR>'] = cmp.mapping.confirm({ select = true }),
				}),
				sources = {
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'buffer' },
					{ name = 'path' },
				},
			})
		end
	},

	-- FORMATTING: Conform (Auto-format on save)
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			preset = "helix",
			plugins = {
				marks = true,
				registers = true,
				motions = false,
			},
			win = {
				border = "rounded",
				position = "bottom",
				padding = { 2, 2, 2, 2 },
			},
			ignore_modes = { "c", "r", "R" },
		},
		config = function(_, opts)
			require("which-key").setup(opts)
			require("which-key").register({
				f = { name = "[F]ile", _ = "which_key_ignore" },
				l = { name = "[L]SP", _ = "which_key_ignore" },
				t = { name = "[T]elescope", _ = "which_key_ignore" },
				w = { name = "[Window]", _ = "which_key_ignore" },
			}, { prefix = "<leader>" })
		end
	},
	{
		"stevearc/conform.nvim",
		opts = {
			notify_on_error = false,
			format_on_save = { timeout_ms = 500, lsp_fallback = true },
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				go = { "goimports", "gofmt" },
				json = { "jq" },
			},
		},
	},
})
