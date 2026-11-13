#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
export PATH="$ROOT/.tools/node/node_modules/.bin:$ROOT/.tools/python/bin:/Library/TeX/texbin:/opt/homebrew/bin:$PATH"
failed=0
for tool in glow delta tmux aws python3 nvim node tree-sitter rg fd fzf uv basedpyright-langserver ruff vtsls vscode-eslint-language-server prettier biome texlab latexindent latexmk pdflatex stylua lua-language-server lazygit; do
  if command -v "$tool" >/dev/null; then echo "OK $tool"; else echo "MISSING $tool"; failed=1; fi
done
/opt/homebrew/bin/latexindent --version >/dev/null 2>&1 || { echo "BROKEN latexindent (Perl dependencies)"; failed=1; }
apps=(Ghostty)
for app in "${apps[@]}"; do
  if [[ -d "/Applications/$app.app" || -d "$HOME/Applications/$app.app" ]]; then echo "OK $app"; else echo "MISSING $app"; failed=1; fi
done
if [[ -f "$ROOT/config/nvim/lazy-lock.json" ]]; then echo "OK plugin lockfile"; else echo "MISSING plugin lockfile"; failed=1; fi
"$ROOT/.tools/python/bin/python" -c 'import debugpy' || failed=1
[[ -f "$ROOT/.tools/debugger/js-debug/src/dapDebugServer.js" ]] || failed=1
echo "Interactive checks: :Copilot auth; terminal shortcuts and visual appearance."
exit "$failed"
