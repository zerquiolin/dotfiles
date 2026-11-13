return {
	{
		"jake-stewart/multicursor.nvim",
		branch = "main",
		keys = {
			{
				"<M-j>",
				function()
					require("multicursor-nvim").lineAddCursor(1)
				end,
				mode = { "n", "x" },
				desc = "Cursor below",
			},
			{
				"<M-k>",
				function()
					require("multicursor-nvim").lineAddCursor(-1)
				end,
				mode = { "n", "x" },
				desc = "Cursor above",
			},
		},
		config = function()
			local mc = require("multicursor-nvim")
			mc.setup()
			mc.addKeymapLayer(function(map)
				map("n", "<Esc>", function()
					if not mc.cursorsEnabled() then
						mc.enableCursors()
					else
						mc.clearCursors()
					end
				end)
			end)
		end,
	},
}
