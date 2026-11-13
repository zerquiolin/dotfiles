#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
export HOME="$fixture/home" XDG_CONFIG_HOME="$fixture/config"
mkdir -p "$HOME" "$XDG_CONFIG_HOME"
"$ROOT/scripts/link.sh" --dry-run >/dev/null
[[ ! -e "$XDG_CONFIG_HOME/nvim" ]]
printf 'existing\n' > "$XDG_CONFIG_HOME/nvim"
if "$ROOT/scripts/link.sh" --link >/dev/null 2>&1; then echo 'FAIL conflict accepted'; exit 1; fi
[[ "$(cat "$XDG_CONFIG_HOME/nvim")" == existing && ! -e "$XDG_CONFIG_HOME/ghostty" ]]
rm "$XDG_CONFIG_HOME/nvim"
"$ROOT/scripts/link.sh" --link >/dev/null
"$ROOT/scripts/link.sh" --link >/dev/null
[[ "$(readlink "$XDG_CONFIG_HOME/nvim")" == "$ROOT/config/nvim" ]]
echo 'PASS installer dry run, conflict protection, and repeat installation'
