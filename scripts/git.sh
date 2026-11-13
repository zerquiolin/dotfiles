#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
include="$ROOT/config/git/delta.gitconfig"
# Give direct `lazygit` the same UI as the suite. Preserve nonempty user configs.
lazygit_dir="$(lazygit --print-config-dir)"
target="$lazygit_dir/config.yml"
source_config="$ROOT/config/lazygit/config.yml"
if [[ -L "$target" && "$(readlink "$target")" == "$source_config" ]]; then
  :
elif [[ -s "$target" || -L "$target" ]]; then
  echo "Existing Lazygit config preserved; git-ui still applies suite styling." >&2
elif [[ "${1:---dry-run}" == --apply ]]; then
  mkdir -p "$lazygit_dir"
  if [[ -e "$target" ]]; then mv "$target" "$target.dotfiles-backup-$(date +%Y%m%d%H%M%S)"; fi
  ln -s "$source_config" "$target"
else
  echo "Would link Lazygit styling: $target"
fi
if git config --global --get-all include.path | /usr/bin/grep -Fxq "$include"; then
  echo 'Git diff styling already configured'
  exit 0
fi
[[ "${1:---dry-run}" == --apply ]] || { echo "Would add Git include: $include"; exit 0; }
# Preserve the existing identity, credentials, aliases and configuration.
config="${GIT_CONFIG_GLOBAL:-$HOME/.gitconfig}"
[[ ! -e "$config" ]] || cp -p "$config" "$config.dotfiles-backup-$(date +%Y%m%d%H%M%S)"
git config --global --add include.path "$include"
echo 'Git diff styling added; existing configuration preserved'
