#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
target="${ZDOTDIR:-$HOME}/.zshrc"
line="source \"$ROOT/shell/env.zsh\""
if [[ -f "$target" ]] && /usr/bin/grep -Fqx "$line" "$target"; then echo 'Shell already configured'; exit 0; fi
[[ "${1:---dry-run}" == --apply ]] || { echo "Would append to $target: $line"; exit 0; }
if [[ -e "$target" ]]; then cp -p "$target" "$target.dotfiles-backup-$(date +%Y%m%d%H%M%S)"; fi
printf '\n# Personal dotfiles environment\n%s\n' "$line" >> "$target"
echo 'Shell integration added; previous contents preserved and backed up.'
