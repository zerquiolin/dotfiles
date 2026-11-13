#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd -P)"
mode="${1:---dry-run}"
case "$mode" in
  --dry-run|--link) exec "$ROOT/scripts/link.sh" "$mode" ;;
  --dependencies) command -v brew >/dev/null || { echo "Install Homebrew from https://brew.sh first" >&2; exit 1; }; brew bundle --file="$ROOT/Brewfile"; if [[ ! -x /Library/TeX/texbin/latexmk || ! -x /Library/TeX/texbin/pdflatex ]]; then brew bundle --file="$ROOT/Brewfile.latex"; fi; exec "$ROOT/scripts/tools.sh" ;;
  --appearance) exec "$ROOT/bin/suite-settings" init ;;
  --git) exec "$ROOT/scripts/git.sh" --apply ;;
  --shell) exec "$ROOT/scripts/shell.sh" --apply ;;
  --plugins) exec "$ROOT/scripts/plugins.sh" ;;
  --doctor) exec "$ROOT/scripts/doctor.sh" ;;
  --all) "$0" --dry-run; "$0" --dependencies; "$0" --appearance; "$0" --link; "$0" --plugins; "$0" --shell; "$0" --git; "$0" --doctor ;;
  *) echo "Usage: ./install.sh [--dry-run|--dependencies|--link|--plugins|--appearance|--git|--shell|--doctor|--all]" >&2; exit 2 ;;
esac
