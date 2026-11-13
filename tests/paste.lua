assert(not vim.o.clipboard:match("unnamedplus"), "Vim p must remain separate from the system clipboard")
assert(vim.fn.maparg("p", "n") == "", "Plain p must keep its native Vim behavior")
assert(vim.fn.maparg("<D-v>", "n", false, true).rhs == '"+p', "Forwarded Cmd-V must paste from the system clipboard")
assert(
	vim.fn.maparg("<D-c>", "n", false, true).rhs == '"+yy',
	"Cmd-C should copy the current line to the system clipboard"
)
assert(
	vim.fn.maparg("<D-c>", "x", false, true).rhs == '"+y',
	"Cmd-C should copy a visual selection to the system clipboard"
)
assert(vim.fn.maparg("<D-c>", "i", false, true).rhs == '<C-o>"+yy', "Cmd-C should copy the current line in insert mode")
assert(
	vim.fn.maparg("<D-v>", "x", false, true).rhs == '"+P',
	"Cmd-V should replace a visual selection from the system clipboard"
)
assert(
	vim.fn.maparg("<D-v>", "i", false, true).rhs == "<C-r>+",
	"Cmd-V should insert the system clipboard in insert mode"
)
assert(vim.fn.maparg("<F19>", "n") == "", "Cmd-V should keep Ghostty's native paste key")
print("PASS p remains native; forwarded Cmd-V uses system clipboard; Ghostty keeps native paste")
vim.cmd("qa!")
