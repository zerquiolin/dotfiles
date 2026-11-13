# Loaded by env.zsh. Functions change only the current shell's environment.
function cproj() {
  local project_path
  project_path=$(work path "$1") || return
  builtin cd -- "$project_path"
}
function gpt() {
  local account=${1:-primary}
  case "$account" in personal) account=primary ;; work) account=secondary ;; primary|secondary) ;; *) print -u2 'Usage: gpt personal|work [Codex arguments] (primary/secondary also supported)'; return 2;; esac
  (( $# )) && shift
  local account_dir="${XDG_DATA_HOME:-$HOME/.local/share}/codex-accounts/$account"
  (umask 077; mkdir -p -- "$account_dir") || return
  print -P "%F{cyan}Codex account: $account%f"
  # File storage makes each account independent of a shared system keychain entry.
  env -u OPENAI_API_KEY -u CODEX_API_KEY -u CODEX_ACCESS_TOKEN CODEX_HOME="$account_dir" codex -c 'cli_auth_credentials_store="file"' "$@"
}
function claude-account() {
  local account=${1:-personal}
  local account_dir
  case "$account" in
    personal) account_dir="$HOME/.claude" ;;
    work) account_dir="$HOME/.claude-work" ;;
    *) print -u2 'Usage: claude-account personal|work [Claude arguments]'; return 2 ;;
  esac
  (( $# )) && shift
  command -v claude >/dev/null || { print -u2 'Claude CLI is not installed.'; return 127; }
  (umask 077; mkdir -p -- "$account_dir") || return
  print -P "%F{cyan}Claude account: $account%f"
  env -u ANTHROPIC_API_KEY -u ANTHROPIC_AUTH_TOKEN -u CLAUDE_CODE_OAUTH_TOKEN \
    -u CLAUDE_CODE_USE_BEDROCK -u CLAUDE_CODE_USE_VERTEX -u CLAUDE_CODE_USE_FOUNDRY \
    CLAUDE_CONFIG_DIR="$account_dir" claude "$@"
}
function awsprofile() {
  command -v aws >/dev/null || { print -u2 'Install awscli first'; return 1; }
  local selected
  selected=$(aws configure list-profiles | fzf --no-scrollbar --gutter=' ' --pointer='›' --marker='✓' --color='bg:-1,gutter:-1,bg+:#303340,fg:#a6accd,fg+:#e4f0fb,border:#767c9d,pointer:#89ddff,marker:#5de4c7,hl:#5de4c7,hl+:#5de4c7,header:#767c9d,info:#767c9d,prompt:#89ddff,spinner:#89ddff' --bind='h:up,k:up,j:down,l:down,start:unbind(h)+unbind(j)+unbind(k)+unbind(l),tab:toggle-search+toggle-bind(h)+toggle-bind(j)+toggle-bind(k)+toggle-bind(l)' --header='Tab: type / navigate · h/k up · j/l down' --prompt='AWS profile ❯ ' --height=40% --border=rounded) || return
  [[ -n "$selected" ]] || return
  export AWS_PROFILE="$selected"
  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_DEFAULT_PROFILE
  print "AWS profile: $AWS_PROFILE"
}
function awslogin() { aws sso login "${@}"; }
function awsidentity() { aws sts get-caller-identity; }
function awsclear() {
  unset AWS_PROFILE AWS_DEFAULT_PROFILE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
}
if [[ -o interactive ]]; then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --no-scrollbar --gutter=' ' --pointer='›' --marker='✓' --color=bg:-1,gutter:-1,preview-bg:-1,bg+:#303340,pointer:#89ddff,marker:#5de4c7,hl:#5de4c7,hl+:#5de4c7,header:#767c9d,info:#767c9d,prompt:#89ddff,spinner:#89ddff"
  autoload -Uz compinit
  (( $+functions[compdef] )) || compinit
  if command -v aws_completer >/dev/null; then
    autoload -Uz bashcompinit; bashcompinit
    complete -C "$(command -v aws_completer)" aws
  fi
  if command -v fzf >/dev/null; then source <(fzf --zsh); fi
  [[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  [[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
# The account labels map to the existing credential directories; no login is moved.
function _suite_launch() {
  local tool=$1
  shift
  if ! command -v "$tool" >/dev/null; then
    print -u2 "$tool is not installed. Install its CLI, then select it here again."
    return 127
  fi
  "$tool" "$@"
}
function suite() {
  local folder=root action result mode=Type start_bind tab_bind accept_bind project_path
  local -a output
  local -a entries
  while true; do
    case "$folder" in
      root) entries=('Projects  ›' 'Codex  ›' 'Antigravity' 'Claude  ›' 'Git  ›' 'Settings  ›' 'AWS  ›') ;;
      Settings) entries=('‹ Back' 'Coding theme' 'Background' 'Font' 'Current settings' 'Restore defaults') ;;
      Claude) entries=('‹ Back' 'Personal' 'Work') ;;
      Codex) entries=('‹ Back' 'Personal' 'Work') ;;
      Git) entries=('‹ Back' 'Lazygit') ;;
      AWS) entries=('‹ Back' 'Choose profile' 'SSO login' 'Current identity' 'Clear profile') ;;
    esac
    if [[ "$mode" == Navigate ]]; then
      start_bind='start:disable-search'
    else
      start_bind='start:unbind(h)+unbind(j)+unbind(k)+unbind(l)'
    fi
    tab_bind='tab:transform:case "$FZF_PROMPT" in *Navigate*) printf "toggle-search+toggle-bind(h)+toggle-bind(j)+toggle-bind(k)+toggle-bind(l)+change-prompt(Type ❯ )" ;; *) printf "toggle-search+toggle-bind(h)+toggle-bind(j)+toggle-bind(k)+toggle-bind(l)+change-prompt(Navigate ❯ )" ;; esac'
    accept_bind='enter:transform:case "$FZF_PROMPT" in *Navigate*) printf "print(Navigate)+accept" ;; *) printf "print(Type)+accept" ;; esac'
    if ! result=$(printf '%s\n' "${entries[@]}" | fzf --layout=reverse --no-scrollbar --gutter=' ' --pointer='›' --marker='✓' --height=50% --border=rounded \
      --color='bg:-1,gutter:-1,bg+:#303340,fg:#a6accd,fg+:#e4f0fb,border:#767c9d,pointer:#89ddff,marker:#5de4c7,hl:#5de4c7,hl+:#5de4c7,header:#767c9d,info:#767c9d,prompt:#89ddff,spinner:#89ddff' \
      --prompt="$mode ❯ " --border-label=" Suite / ${folder/root/Home} " \
      --header='Tab: type / navigate · j/k move · h back · l/Enter open' \
      --bind="h:print(Navigate)+print(__suite_back__)+accept,k:up,j:down,l:print(Navigate)+accept,$start_bind" \
      --bind="$tab_bind" --bind="$accept_bind" \
      --bind='esc:transform:case "$FZF_PROMPT" in *Navigate*) printf "print(Navigate)+print(__suite_back__)+accept" ;; *) printf "print(Type)+print(__suite_back__)+accept" ;; esac' ); then
      [[ "$folder" == root ]] && return 0
      folder=root
      continue
    fi
    output=("${(@f)result}")
    mode=${output[1]}
    action=${output[2]}
    if [[ "$action" == __suite_back__ || "$action" == '‹ Back' ]]; then
      [[ "$folder" == root ]] && return 0
      folder=root
      continue
    fi
    case "$folder/$action" in
      'root/Codex  ›') folder=Codex ;;
      'root/Settings  ›') folder=Settings ;;
      'Settings/Coding theme') SUITE_MODE="$mode" suite-settings theme ;;
      Settings/Background) SUITE_MODE="$mode" suite-settings background ;;
      Settings/Font) SUITE_MODE="$mode" suite-settings font ;;
      'Settings/Current settings') suite-settings show; read '?Press Enter to return' ;;
      'Settings/Restore defaults') suite-settings reset ;;
      'root/Git  ›') folder=Git ;;
      'root/AWS  ›') folder=AWS ;;
       'root/Projects  ›')
        project_path=$(SUITE_MODE="$mode" work projects --select-path) || return
        if [[ -n "$project_path" ]]; then
          builtin cd -- "$project_path"
          return $?
        fi
        ;;
      root/Antigravity)
        if command -v agy >/dev/null; then
          agy
        elif [[ -x "$HOME/.local/bin/agy" ]]; then
          "$HOME/.local/bin/agy"
        else
          print -u2 'Antigravity CLI (agy) is not installed or available on PATH.'
          return 127
        fi
        return $? ;;
      'root/Claude  ›') folder=Claude ;;
      Claude/Personal) claude-account personal; return $? ;;
      Claude/Work) claude-account work; return $? ;;
      Codex/Personal) gpt personal; return $? ;;
      Codex/Work) gpt work; return $? ;;
      Git/Lazygit) _suite_launch git-ui; return $? ;;
      'AWS/Choose profile') awsprofile; return $? ;;
      'AWS/SSO login') awslogin; return $? ;;
      'AWS/Current identity') awsidentity; return $? ;;
      'AWS/Clear profile') awsclear; return $? ;;
    esac
  done
}
