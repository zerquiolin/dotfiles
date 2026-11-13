#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
mode="${1:---dry-run}"
[[ "$mode" == --dry-run || "$mode" == --link ]] || exit 2
sources=("$ROOT/config/nvim" "$ROOT/config/ghostty" "$ROOT/config/starship.toml")
targets=("$CONFIG/nvim" "$CONFIG/ghostty" "$CONFIG/starship.toml")
conflict=0
for i in "${!sources[@]}"; do
  target="${targets[$i]}"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -L "$target" && "$(readlink "$target")" == "${sources[$i]}" ]]; then
      echo "Already linked: $target"
    else
      echo "CONFLICT (untouched): $target" >&2
      conflict=1
    fi
  else echo "Would link: $target -> ${sources[$i]}"; fi
done
# Ghostty also reads the native macOS location; never silently shadow it.
native="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
if [[ -e "$native" || -L "$native" ]]; then
  echo "CONFLICT (untouched): Ghostty native config $native" >&2
  conflict=1
fi
[[ "$conflict" == 0 ]] || exit 1
if [[ "$mode" == --link ]]; then
  mkdir -p "$CONFIG"
  for i in "${!sources[@]}"; do
    [[ -L "${targets[$i]}" ]] || ln -s "${sources[$i]}" "${targets[$i]}"
  done
fi
printf '\nShell opt-in (add once to ~/.zshrc):\nsource "%s/shell/env.zsh"\n' "$ROOT"
