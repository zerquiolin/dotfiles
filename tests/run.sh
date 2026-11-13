#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
cd "$ROOT"
mkdir -p .state
shellcheck install.sh scripts/*.sh tests/*.sh
zsh -n shell/env.zsh
stylua --check config/nvim tests/*.lua scripts/parsers.lua
./tests/installer.sh
explorer_fixture="$(mktemp -d)"
trap 'rm -rf "$explorer_fixture"' EXIT
./scripts/preview.sh --headless "$explorer_fixture" '+lua vim.api.nvim_create_autocmd("VimEnter",{once=true,nested=true,callback=function() local ok,err=pcall(dofile,vim.g.dotfiles_root.."/tests/explorer.lua"); if not ok then print(err); vim.cmd("cquit 1") end end})'
./scripts/preview.sh --headless '+lua vim.api.nvim_create_autocmd("VimEnter",{once=true,nested=true,callback=function()local ok,err=pcall(dofile,vim.g.dotfiles_root.."/tests/directional.lua"); if not ok then print(err); vim.cmd("cquit 1") end end})'
./scripts/preview.sh --headless '+lua local ok,err=pcall(dofile,vim.g.dotfiles_root.."/tests/bufferbar.lua"); if not ok then print(err); vim.cmd("cquit 1") end'
./scripts/preview.sh --headless '+lua local ok,err=pcall(dofile,vim.g.dotfiles_root.."/tests/sessions.lua"); if not ok then print(err); vim.cmd("cquit 1") end'
./.tools/python/bin/python tests/terminal-keys.py
./scripts/preview.sh --headless '+lua local ok,err=pcall(dofile,vim.g.dotfiles_root.."/tests/close-view.lua"); if not ok then print(err); vim.cmd("cquit 1") end'
./scripts/preview.sh --headless '+lua local ok,err=pcall(dofile,vim.g.dotfiles_root.."/tests/search-close.lua"); if not ok then print(err); vim.cmd("cquit 1") end'
./scripts/preview.sh --headless '+lua local ok,err=pcall(dofile,vim.g.dotfiles_root.."/tests/save.lua"); if not ok then print(err); vim.cmd("cquit 1") end'
./scripts/preview.sh --headless '+lua local ok,err=pcall(dofile,vim.g.dotfiles_root.."/tests/paste.lua"); if not ok then print(err); vim.cmd("cquit 1") end'
./scripts/preview.sh --headless '+lua local ok,err=pcall(dofile,vim.g.dotfiles_root.."/tests/comments.lua"); if not ok then print(err); vim.cmd("cquit 1") end'
./scripts/doctor.sh
# A separate disposable project supplies project-local ESLint for the test.
npm ci --prefix tests --ignore-scripts --no-audit --no-fund
mkdir -p .state/test-workspace
if [[ ! -e .state/test-workspace/node_modules && ! -L .state/test-workspace/node_modules ]]; then
  ln -s "$ROOT/tests/node_modules" .state/test-workspace/node_modules
fi
./scripts/preview.sh --headless '+lua vim.api.nvim_create_autocmd("VimEnter",{once=true,nested=true,callback=function()local ok,err=pcall(dofile,vim.g.dotfiles_root.."/tests/smoke.lua"); if not ok then print(err); vim.cmd("cquit 1") end end})'
./scripts/preview.sh --headless '+lua local ok,err=pcall(dofile,vim.g.dotfiles_root.."/tests/dap.lua"); if not ok then print(err); vim.cmd("cquit 1") end'
/Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config --config-file="$ROOT/config/ghostty/config" > .state/ghostty-validation.log 2>&1
echo 'PASS automated verification'
