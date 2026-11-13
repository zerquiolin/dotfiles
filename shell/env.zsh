# Source this from ~/.zshrc; existing shell configuration remains yours.
export PATH="/opt/homebrew/bin:/Library/TeX/texbin:$PATH"
_dotfiles_root="${${(%):-%x}:A:h:h}"
export PATH="$_dotfiles_root/bin:$_dotfiles_root/.tools/node/node_modules/.bin:$_dotfiles_root/.tools/python/bin:$PATH"
export STARSHIP_CONFIG="$_dotfiles_root/config/starship.toml"
if [[ -o interactive ]]; then
  command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
  if [[ "$TERM" != dumb ]]; then
    command -v starship >/dev/null && eval "$(starship init zsh)"
  fi
fi
source "$_dotfiles_root/shell/productivity.zsh"
unset _dotfiles_root
