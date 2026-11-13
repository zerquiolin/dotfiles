#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
[[ -L "$config" && "$(readlink "$config")" == "$ROOT/config/nvim" ]] || { echo "Run --link first, or set XDG_CONFIG_HOME to an isolated preview directory" >&2; exit 1; }
nvim --headless "+Lazy! restore" +qa
nvim --headless "+lua local ok,err=pcall(dofile, '$ROOT/scripts/parsers.lua'); if not ok then print(err); vim.cmd('cquit 1') end" +qa
