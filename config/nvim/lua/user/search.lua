local M = {}
M.directions = {
	h = "leftabove vsplit",
	j = "rightbelow split",
	k = "leftabove split",
	l = "rightbelow vsplit",
}
function M.actions()
	local actions = {}
	for key, command in pairs(M.directions) do
		actions["ctrl-" .. key] = function(selected, opts)
			local origin = require("user.windows").origin(opts.__CTX and opts.__CTX.winid)
			if origin then
				vim.api.nvim_set_current_win(origin)
			end
			require("fzf-lua.actions").vimcmd_entry(command, selected, opts, true)
			require("user.windows").equalize()
		end
	end
	return actions
end
return M
