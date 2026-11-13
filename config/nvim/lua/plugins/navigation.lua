return {
	{
		"ibhagwan/fzf-lua",
		cmd = "FzfLua",
		keys = {
			{ "<leader>ff", "<Cmd>FzfLua files<CR>", desc = "Files" },
			{ "<leader>fg", "<Cmd>FzfLua live_grep<CR>", desc = "Search text" },
			{ "<leader>fb", "<Cmd>FzfLua buffers<CR>", desc = "Buffers" },
			{ "<leader>fr", "<Cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
			{ "<leader>fs", "<Cmd>FzfLua lsp_document_symbols<CR>", desc = "Symbols" },
			{ "<leader>fS", "<Cmd>FzfLua lsp_workspace_symbols<CR>", desc = "Workspace symbols" },
			{ "<leader>fd", "<Cmd>FzfLua diagnostics_document<CR>", desc = "Diagnostics" },
		},
		opts = {
			"max-perf",
			winopts = { border = "rounded", height = 0.82, width = 0.88, preview = { border = "rounded" } },
			keymap = {
				fzf = {
					["ctrl-n"] = "down",
					["ctrl-p"] = "up",
					["ctrl-space"] = "toggle",
				},
			},
			files = {
				keymap = {
					fzf = {
						h = "up",
						j = "down",
						k = "up",
						l = "down",
						start = "unbind(h)+unbind(j)+unbind(k)+unbind(l)",
						tab = "toggle-bind(h)+toggle-bind(j)+toggle-bind(k)+toggle-bind(l)",
					},
				},
				fd_opts = "--color=never --type f --hidden --exclude .git --exclude node_modules --exclude .venv --exclude .next",
			},
			grep = {
				keymap = {
					fzf = {
						h = "up",
						j = "down",
						k = "up",
						l = "down",
						start = "unbind(h)+unbind(j)+unbind(k)+unbind(l)",
						tab = "toggle-bind(h)+toggle-bind(j)+toggle-bind(k)+toggle-bind(l)",
					},
				},
				actions = require("user.search").actions(),
				rg_opts = "--column --line-number --no-heading --color=never --smart-case --hidden -g !.git -g !node_modules -g !.venv -g !.next",
			},
			lsp = {
				keymap = {
					fzf = {
						j = "down",
						k = "up",
						start = "unbind(j)+unbind(k)",
						tab = "toggle-bind(j)+toggle-bind(k)",
					},
				},
			},
		},
	},
	{
		"nvim-tree/nvim-tree.lua",
		lazy = false,
		dependencies = { { "nvim-tree/nvim-web-devicons", opts = { default = true } } },
		init = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("ExplorerAppearance", { clear = true }),
				callback = function()
					require("user.explorer").highlights()
				end,
			})
		end,
		keys = {
			{
				"<leader>ee",
				function()
					require("nvim-tree.api").tree.toggle()
				end,
				desc = "Toggle explorer",
			},
		},
		opts = {
			on_attach = function(buf)
				require("user.explorer").attach(buf)
			end,
			hijack_directories = { enable = true, auto_open = true },
			view = { width = 38, number = false, relativenumber = false, signcolumn = "no" },
			sort = { sorter = "name", folders_first = true },
			renderer = {
				group_empty = false,
				add_trailing = false,
				root_folder_label = function(path)
					return vim.fn.fnamemodify(path, ":~")
				end,
				indent_width = 2,
				indent_markers = {
					enable = true,
					icons = {
						corner = "│",
						edge = "│",
						item = "│",
						bottom = " ",
						none = " ",
					},
				},
				icons = {
					show = { file = true, folder = false, folder_arrow = true, git = false },
					glyphs = { folder = { arrow_closed = "", arrow_open = "" } },
				},
			},
			git = { enable = false },
			diagnostics = { enable = false },
			filters = { dotfiles = false, git_ignored = false },
			filesystem_watchers = { enable = false },
			actions = { open_file = { quit_on_open = true, window_picker = { enable = false } } },
		},
		config = function(_, opts)
			require("nvim-tree").setup(opts)
			require("user.explorer").highlights()
		end,
	},
}
