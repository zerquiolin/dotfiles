# Project context

Last reviewed: 2026-11-13. This document is a handoff summary; verify details against the code before making changes. README.md contains the operational guide. AUDIT.md includes historical material and may describe superseded behavior.

## Objective

Build a reproducible, fast, keyboard-driven development suite for Apple Silicon macOS. The primary machine is a MacBook M3 Pro with 38 GB RAM running Tahoe. Support research and software development with Python, LaTeX, JavaScript/TypeScript, React/Next.js and related tools. Favor clear, minimal interfaces, low background work and configuration owned by the user.

Repository remote: https://github.com/zerquiolin/dotfiles.git.

## User preferences and constraints

- Preserve custom Vim navigation: sh/sj/sk/sl focus editor panes, intentionally replacing native s behavior.
- Preserve Cmd-S saving and Cmd-/ commenting, including while typing. Ghostty sends special key sequences to Neovim.
- Regular/bold text uses rounded Maple Mono NF; italic/bold-italic text uses VictorMono Nerd Font Mono. Keep ligatures and italic keywords/comments.
- Preserve the dark galaxy wallpaper, subtle glass/blur and readable, mostly solid background. User recently reported the wallpaper missing: the file existed but the local image setting was empty; it has been restored.
- Never restart Ghostty, terminate sessions, kill workspaces or interrupt terminal jobs merely to apply configuration. The user may have long-running processes. Use isolated tests and communicate any required reload.
- Preserve existing configuration and credentials. Do not push, publish or overwrite unrelated local work without authorization.
- Notebook integration, Docker setup and animations are intentionally excluded/deferred.
- SQL formatting is not implemented; the user's preferred dialect is still unknown.

## Architecture and source of truth

- install.sh dispatches dependency, links, plugins, shell, Git, appearance and doctor stages. Brewfile supplies system dependencies; tooling/ holds isolated language-tool manifests/locks.
- config/ghostty/config supplies terminal appearance and keybindings. An optional include loads generated local appearance overrides.
- config/nvim is a custom Lua configuration using lazy.nvim, native LSP, Treesitter, Conform, Copilot, fzf-lua, nvim-tree, Gitsigns, debugging and VimTeX. The plugin lockfile should remain reproducible; avoid indiscriminate updates.
- shell/env.zsh initializes tools and sources shell/productivity.zsh. bin/ contains work, suite-settings, git-ui and latex-format.
- scripts/ implements installer stages; tests/ contains regression checks. sources/ in the enclosing ChatGPT project is read-only synced reference material, not an implementation directory.
- Configuration links point into this checkout. Keep it at a permanent location. Native configuration locations can override linked files; inspect them when behavior differs from expectations.

## Implemented behavior

### Suite and projects

`suite` has Projects, Codex → Personal/Work, Antigravity, Claude → Personal/Work, Git, Settings and AWS. Antigravity runs the `agy` CLI, never the IDE. Tab toggles typing/navigation; j/k move, l enters and h goes back. Navigation mode persists between suite folders.

Projects are grouped under collapsible category headings, with favorites first within each category. Shortcuts appear in the footer. Enter/l on a project changes the current shell's directory only: no new window, workspace, file or editor. Ctrl-W resumes meaningful workspace content; first-time/empty workspaces instead change directory. Ctrl-N creates/registers, Ctrl-U updates, Ctrl-F favorites, Ctrl-D removes registration with confirmation, and Ctrl-S stops a selected workspace with confirmation. Removal never deletes project files.

`work add NAME .` registers the current folder. `work open NAME` explicitly creates/resumes a tmux workspace, defaulting to a shell; `--layout code` explicitly launches/restores Neovim. Live sessions resume unchanged. New workspaces have no permanent sidebar. Legacy sidebar panes may be hidden on resumption.

`work leave` checkpoints terminal layout and detaches, keeping processes, scrollback and unsaved edits live. `work stop NAME` checks for unsaved editor changes, saves layout/editor snapshots and terminates the tmux session only after confirmation. It retains saved layout, not live processes or scrollback. Older unregistered editors must be closed normally first. Workspace-aware editors checkpoint every 30 seconds and use separate snapshots per pane. Saved layouts do not preserve running processes or unsaved text through a reboot.

Ghostty Cmd-D splits and tmux splits are different layers. Project-specific Ghostty window/tab/split restoration was discussed but is NOT implemented. App-wide `window-save-state = always` was discussed but is NOT enabled. Do not describe either proposal as shipped behavior.

### Editor, preview and formatting

Each Neovim pane has its own filename header, modified/read-only indication and focused styling. The global buffer strip was removed. tn/tp and ]b/[b cycle files in the focused pane; buffers remain shared between views. View-close shortcuts must not destroy another pane showing the same file.

Space-ff/fg retain Tab-to-hjkl navigation. Ctrl-h/j/k/l in search/tree opens relative to the originating editor pane. Space-l-d shows current-line diagnostics first, otherwise a compact definition/documentation/implementation popup, styled from the selected theme.

`:MD` uses Glow in one reusable floating pager, with j/k scrolling and q/Escape closing only that preview. A scratch terminal buffer prevents replacing the source Markdown buffer. Preview uses the saved file.

LaTeX uses VimTeX/latexmk continuous builds (`:Build` or ,ll). macOS Preview opens PDFs (`:Pdf`, :OpenPDF or ,lv); Skim was removed/uninstalled. Preview does not provide source/PDF jumps. A successful compile updates the PDF on disk; the viewer may need reopening if its display is stale.

LaTeX Conform formatting uses bin/latex-format and shared config/latexindent/.latexindent.yaml, with nearest project overrides. It invokes Homebrew latexindent explicitly, uses temporary scratch storage, enables -m, preserves alignment delimiters/verbatim blocks and enforces a final newline. The user's supplied YAML needed supported heading/command syntax, a capturing delimiter regex and newline wrapping separator. Formatting is asynchronous after save; :Format is also available. Large files/disabled buffers skip it. Python uses Ruff; web formatting chooses project Biome or Prettier.

### Appearance and Git

Settings separates coding theme, background and font. Themes: Poimandres, Tokyo Night Moon, Catppuccin Mocha, Rosé Pine Moon, Kanagawa Wave/Dragon. Coding themes affect Neovim, not every tool's palette. Fonts, wallpaper, blur and opacity are independent and require Apply confirmation. Settings stores local preferences; do not reset them during upgrades. Ghostty font-family lists must be cleared before overriding to prevent the prior family taking precedence.

Git uses Delta plus a minimalist Lazygit layout with file tree, compact branches/commits/stash panel and adaptive side-by-side/unified diffs. `|` cycles renderers, `?` shows help. Stage with Space, stage-all with a, commit with c, and use Ctrl-B to filter staged/unstaged. Native simultaneous staged/unstaged file groups are not supported. Git setup adds a backed-up include without replacing identities/credentials. Direct Lazygit styling is linked only when its existing config is empty/absent; git-ui layers suite styling over custom settings.

## Local state and accounts

- `.state/appearance/settings.json` and generated ghostty.conf: machine-local appearance preferences.
- `.state/workspaces/`: saved terminal layouts, editor snapshots and live editor registration metadata. Never commit socket/credential state.
- `~/.config/workspaces/projects.json`: local project registry; WORKSPACE_REGISTRY can override it.
- Neovim's own state directory: generic project sessions and undo data.
- `~/.local/share/codex-accounts/primary` and secondary: independent Codex homes. gpt personal/work map to these directories; no default credentials are copied. Auth environment overrides are cleared for launches.
- `~/.claude` (Personal) and `~/.claude-work` (Work): independent Claude configuration directories selected with claude-account personal/work. Personal preserves the existing default login; authenticate Work separately.
- AWS profiles/authentication remain local. awsprofile, awslogin, awsidentity and awsclear are shell helpers. Never include secrets in documentation or Git.

AGENTS.md and PROJECT_CONTEXT.md templates can be created in other projects with `work context-init`, preserving existing files. They provide instructions and explicit handoff state; they do not transfer chat transcripts. AI orchestration tools were researched but NOT installed or integrated.

## Installation, updates and verification

For a new Mac: install Command Line Tools/Homebrew, clone to a permanent path, review `./install.sh --dry-run`, then run `./install.sh --all`. Conflicting configuration is preserved. Codex, Claude and Antigravity CLIs/account sign-ins and AWS SSO require separate setup. Project folders, registries, credentials and workspace state do not transfer through Git.

For updates: review `git status --short`; preserve local changes, then `git pull --ff-only` and run --dependencies, --plugins, --appearance, --git and --doctor. Open a new shell/restart only the editor when convenient. Reload Ghostty only deliberately; never quit it while the user has active jobs. Existing tmux servers need an explicit config reload to adopt new bindings.

Validation available: tests/run.sh, tests/installer.sh, tests/workspace-opening.py, installer doctor, shellcheck, stylua and Ghostty config validation. Run tests in disposable files/sessions. Existing editor regression checks have passed, including language tools, formatting, PDF compilation, debugger continuation, file/search navigation and pane headers. A clean installation on a second Mac has not been verified. Passing automated checks does not establish subjective scrolling smoothness or GUI appearance.

## Current unfinished work and cautions

- Scrolling lag was reported in Codex CLI, not just Neovim. Pane-header and editor scrolling changes do not fix terminal-wide rendering. Trackpad versus mouse and direct Ghostty versus tmux remain unanswered. No confirmed root cause; do not claim wallpaper/blur is responsible. Test separately without interrupting the active session. Codex --no-alt-screen was suggested as a comparison, not a universal fix.
- Potential next additions: project task runner, SQL formatter after dialect selection, Settings health view, and optional AI orchestration evaluation. These are proposals, not implemented features.
- The user authorized the initial commit and push on 2026-11-13. This document is included in that publication. Check `git status` and `git log` for subsequent local changes; continue to obtain authorization for future pushes.

## Handoff maintenance

Update this document after meaningful architecture or behavior changes. Record what is actually implemented, what was verified and what remains proposed. Keep README.md aligned with the user-facing commands, and never put credentials, tokens or private conversation transcripts here.
