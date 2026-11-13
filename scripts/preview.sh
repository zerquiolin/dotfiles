#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
export XDG_CONFIG_HOME="$ROOT/.state/preview/config"
export XDG_DATA_HOME="$ROOT/.state/preview/data"
export XDG_STATE_HOME="$ROOT/.state/preview/state"
export XDG_CACHE_HOME="$ROOT/.state/preview/cache"
mkdir -p "$XDG_CONFIG_HOME"
if [[ ! -e "$XDG_CONFIG_HOME/nvim" && ! -L "$XDG_CONFIG_HOME/nvim" ]]; then ln -s "$ROOT/config/nvim" "$XDG_CONFIG_HOME/nvim"; fi
exec nvim "$@"
