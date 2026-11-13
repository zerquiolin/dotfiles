# macOS development environment

A small, owned Lua configuration for Apple Silicon macOS: Ghostty with glassy Poimandres colors, Neovim, Zsh, fast file navigation, Python, JS/TS/React, LaTeX, Git, and debugging. No notebook integration is installed.

For the project objective, architecture, constraints and handoff status, start with [CONTEXT.md](CONTEXT.md).

## Install

Prerequisites: macOS on Apple Silicon, Apple's Command Line Tools (`xcode-select --install`), and [Homebrew](https://brew.sh). Keep the checkout at a permanent path: configuration links, the shell source line, and tool environments reference it.

Install from the published repository:

```sh
git clone https://github.com/zerquiolin/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run
./install.sh --all
```

The default command only previews changes. `--all` installs dependencies (including Maple Mono NF and Victor Mono Nerd Font), links configuration, restores locked plugins, installs syntax parsers, adds shell integration, and checks dependencies. Existing Neovim, Ghostty, or Starship files cause a stop before linking; the installer never replaces them. Move a conflicting configuration yourself after reviewing and backing it up. The shell integration appends one source line and saves a dated copy of an existing `.zshrc`.

Your existing TeX distribution is reused. On a Mac without LaTeX, the separate `Brewfile.latex` installs MacTeX without its bundled GUI; this is a large download. The built-in macOS Preview app displays PDFs.

Individual stages:

```sh
./install.sh --dependencies
./install.sh --link
./install.sh --plugins
./install.sh --shell
./install.sh --doctor
```

Open a new terminal to activate shell changes. Fully quit and reopen Ghostty after installing the font; later config edits can be reloaded with Cmd-Shift-comma. Some window appearance settings require a new window.

## Update an existing installation

Run these commands from your actual checkout (use `~/dotfiles` only if that is where you installed it):

```sh
cd ~/dotfiles
git status --short
```

If Git lists local edits or untracked files, review and preserve them before pulling. Do not reset, clean, or overwrite local work to make an update succeed. When the checkout is clean:

```sh
git pull --ff-only
./install.sh --dependencies
./install.sh --plugins
./install.sh --appearance
./install.sh --git
./install.sh --doctor
```

Stop if any command fails. If Git cannot fast-forward, reconcile the local and remote changes before continuing. `--dependencies` installs the Brewfile and language tools; Homebrew may update shared dependencies. `--plugins` restores the repository's locked plugin versions and parsers. The installer stages can be rerun. Existing configuration links already point into the checkout, so ordinary updates do not need `--link`. Run `--shell` only if shell integration is missing.

After updating, open a new terminal, restart Neovim after saving your work, and reload Ghostty with Cmd-Shift-comma. Font changes and some window settings require quitting/reopening Ghostty or creating a new window. Existing tmux servers keep their loaded settings; to refresh one, run this from the checkout:

```sh
tmux source-file "$PWD/config/tmux/tmux.conf"
```

If no tmux server is running, the next project workspace loads this file automatically.

Updates reach another device only after the changes have been committed and pushed to GitHub. Changes already made in this local linked checkout need only the appropriate reload/restart; they are not downloaded again. Only committed and pushed updates are available to other devices.

### Moving to another device

The installer targets Apple Silicon macOS and includes Ghostty styling/font, Neovim and its language tools, tmux, suite shell integration, AWS CLI, and shell suggestions/highlighting. A clean installation on a second Mac has not yet been verified.

Install Codex and Claude CLIs and the Antigravity CLI (`agy`) separately if wanted; they are not in the Brewfile. Authenticate Copilot and AI accounts yourself and configure AWS profiles/SSO on each device. Credentials are not copied by Git updates.

Project folders and registrations (`~/.config/workspaces/projects.json`), AI account directories (`~/.local/share/codex-accounts/`), AWS configuration, and saved workspaces (`.state/workspaces/` in the checkout) remain local. Neovim also stores project sessions under its local state directory. They are not transferred by cloning or pulling. Register project paths appropriate to the new machine. Project AGENTS.md and PROJECT_CONTEXT.md files transfer only with their own project repositories or a separate copy.

## First use

Open a project directory and run `nvim .`. Authenticate Copilot once with `:Copilot auth`; the sign-in and subscription belong to your GitHub account. `:Copilot status` checks the connection. The plugin downloads its pinned native server on first initialization. Credentials are never included in this repository.

Use project `.venv` environments for Python. basedpyright discovers standard `.venv` layouts; set `venvPath`/`venv` in `pyrightconfig.json` for other layouts. The debugger uses the active `VIRTUAL_ENV`, then the project's `.venv`, then its own Python environment. Python language tools live in an isolated environment and do not replace Conda or project packages.

For JS/TS, install project dependencies normally. ESLint uses project configuration and the project's ESLint installation. Formatting prefers project-local binaries; Biome is chosen when a `biome.json`/`biome.jsonc` exists, otherwise Prettier. The TypeScript server uses its bundled compiler fallback; project TypeScript can be selected with vtsls settings. Next.js, React and Express editing use the TS/JS stack. React Native device tooling and Metro remain project responsibilities.

`Format` runs explicitly; formatting after save is asynchronous and writes the formatted result back to disk. `FormatToggle` disables/enables it for the current buffer. Regular and bold text use rounded Maple Mono NF; comments and language keywords retain Victor Mono's cursive italic face. Both fonts support the configured coding workflow and terminal icons. Ruff import fixes are available through LSP code actions; formatting does not silently organize imports.

For LaTeX, open the main document, use `,ll` to start/stop continuous compilation and `,lv` to open the PDF in macOS Preview. Preview does not provide source/PDF synchronization. VimTeX owns compilation; texlab's automatic builds are disabled to avoid duplicate build processes. `:Build`, `:Pdf`, and `:OpenPDF` are also available.

Custom commands: `:Project` chooses a saved project session; `:Run` runs a Python or JavaScript file (or `:Run <command>` runs a supplied command); `:MD` previews the current Markdown file in the terminal with Glow. `:Run` builds a LaTeX document through VimTeX.

## File names in each editor pane

Each split has its own filename header, showing only the file displayed in that pane, a modified dot and read-only state. The focused pane has a subtle theme-colored background; other pane headers stay transparent. The global buffer strip is removed. `tn`/`tp` and `]b`/`[b` switch the file in the focused pane; buffers remain shared across Neovim windows and tab pages. Space-tn still creates a real tab page, and the existing view-close behavior remains in place.

Scrolling uses native screen-line scrolling and small mouse-wheel steps; inactive panes do not draw a cursorline, and legacy syntax work on very long lines is capped. No scrolling animation or Ghostty restart is needed. Ghostty blur/transparency and OS keyboard repeat can also affect perceived motion; those settings were not changed. To apply only these changes in a running Neovim after saving work: `:lua require("user.windowbar").setup()` and `:set showtabline=0 smoothscroll mousescroll=ver:3,hor:2 scrolloff=3 synmaxcol=240`. An already-loaded bufferline plugin may redraw until that editor restarts. Ghostty terminal processes are unaffected.

## Shortcuts

Opening a file with Enter or a directional split shortcut closes the explorer and focuses the file. Directional shortcuts in the tree and grep split the editor window that launched the tool, even when several editor windows are open. New splits rebalance adjacent editor panes evenly; the explorer keeps its sidebar width. Space-= rebalances the current layout manually. Folder expansion leaves the tree open; preview remains a preview.

The explorer is an expandable project tree with file-type icons, regular-weight folder labels, chevrons and subtle vertical indentation guides. `Enter` expands or collapses the selected folder. On files, Ctrl-h/j/k/l open to the left/below/above/right. `l` expands a folder or opens a file; `h` collapses a folder or focuses its parent. `j`/`k` and arrow keys navigate rows. `-` changes the root to its parent. Empty folder chains remain separate so every level is visible.

The tree loads at startup, so `nvim .` and Space-ee open the same explorer. In normal mode, `nf` creates a file and `nd` creates a folder inside the selected directory (or beside a selected file). Enter the name in the bottom prompt and press Enter. Creation refreshes the tree and expands the containing folder. `R` manually refreshes external changes; recursive filesystem watchers and Git scanning are disabled to keep background work low.

Space is the leader; comma is the LaTeX local leader. Sequences are consecutive keys, not simultaneous chords.

| Keys | Action |
|---|---|
| `sh`, `sj`, `sk`, `sl` | Focus left, down, up, right; deliberately replace native `s` behavior |
| Ctrl-h/l, Ctrl-j/k | Decrease/increase width, decrease/increase height |
| Space-ff / fg / fb / fr | Files / content search / buffers / recent files |
| Space-fs / fd | Document symbols / diagnostics |
| Space-fS | Workspace-wide symbols |
| Space-ld | Show diagnostics on the current line, otherwise preview definition/documentation without jumping |
| In `ff` / `fg` | Type to filter; Tab toggles `h/j/k/l` result navigation (`h/k` up, `j/l` down) |
| In `gr` references | Type to filter; Tab toggles `j/k` result navigation; Tab again returns to typing |
| In `fb` | Type to filter; use arrows or Ctrl-n/Ctrl-p to move through results |
| Ctrl-Space in a picker | Mark/unmark a result for multi-selection |
| Space-ee, Cmd-j | Toggle tree explorer |
| Space-ss / sv | New tab with two separate empty buffers, horizontal / vertical |
| Space-pv inside the tree | Preview selection |
| Space-osl / osh inside the tree | Open selection right / left and close explorer |
| Space-ovj / ovk inside the tree | Open selection below / above and close explorer |
| Enter inside the tree | Expand/collapse folder; open file |
| `l` / `h` inside the tree | Expand/open; collapse/focus parent |
| Ctrl-h / Ctrl-j / Ctrl-k / Ctrl-l on a tree file | Open left / below / above / right |
| Ctrl-h / Ctrl-j / Ctrl-k / Ctrl-l in grep | Open selected match left / below / above / right |
| `nf`, `nd` inside the tree | Create file / directory; existing paths are refused |
| Tab / Shift-Tab, with completion open | Next / previous suggestion |
| Enter, with a selected suggestion | Accept completion |
| Option-Enter | Accept Copilot suggestion |
| Option-[ / Option-] | Previous / next Copilot suggestion |
| Ctrl-] | Dismiss Copilot suggestion |
| `gd`, `gr`, `gi`, `gy`, `K` | Fuzzy definitions, references, implementations, type definitions, hover |
| Space-ws / wr / wS / wl | Save / restore current project / choose session / restore most recent session |
| Space-wd / we | Disable / re-enable automatic session saving for this Neovim run |
| Space-rn / ca / cd / cf | Rename / code action / diagnostic float / format |
| Option-j / Option-k | Add cursor below / above; Esc clears added cursors |
| Shift-Option-j / Shift-Option-k | Move line or selection down / up |
| Cmd-Option-j | Duplicate line or selection |
| Cmd-S | Save the current file in normal, insert or visual mode |
| `p` / Cmd-V | Paste Vim's last yank / paste the macOS clipboard |
| Cmd-/ | Toggle comments on the current line or visual selection; also works while typing |
| Cmd-semicolon, Space-ot | Toggle terminal (terminal buffer stays hidden from the file buffer bar) |
| Esc Esc in terminal | Return to normal mode |
| Space-gg | lazygit |
| Space-db, F5, F10, F11, F12 | Breakpoint, continue, step over, into, out |
| Space-du / dr | Debug UI / REPL |
| Cmd-Q / Space-q / Space-bd | Close current view; remove unused file name; prompt for unsaved changes |
| Space-Shift-Q | Close window |
| Space-= | Balance editor pane widths/heights |
| `tn` / `tp` | Next / previous file buffer in the top bar (normal mode) |
| Space-tn, `]b`, `[b` | New tab page, next buffer, previous buffer |

Project files, splits, and working directory are saved automatically when Neovim exits. Use Space-wr to restore the session for the current project, Space-wS to choose another, or Space-wl to restore the most recent one. Sessions live in Neovim's state directory; terminal processes are not saved.

Cmd-Q is forwarded to Neovim to close a view; use Ghostty’s app menu to quit the terminal application. Cmd mappings are translated by Ghostty to F13/F14/F15/F16/F17/F18 terminal sequences. Option is configured as Alt. Physical key delivery and macOS shortcut conflicts must be checked on your keyboard. Cmd-Option-v has no equivalent Vim-extension toggle: Neovim is the editor, with normal/insert modes built in. Cmd-j toggles the filesystem UI because there is no VS Code activity bar.

Run/debug project scripts through the terminal. `:Build` only auto-selects LaTeX; it does not guess and execute arbitrary package scripts. The debugger provides current-file Python/Node launches and Node process attachment. For TypeScript launch, configure your project's build or runtime loader; Node launch does not automatically supply tsx/ts-node. Browser and React Native debugging need project-specific adapter settings.

## Layout and customization

- `config/nvim/lua/config`: options, mappings, autocmds, plugin bootstrap.
- `config/nvim/lua/plugins`: one file per feature; add plugin specs here.
- `config/nvim/lua/user`: custom commands, terminal and explorer helpers.
- `config/ghostty/config`: translucent Poimandres palette, bundled galaxy background, Victor Mono Nerd Font Mono with programming ligatures, and terminal key translation.
- `shell/env.zsh`: lightweight prompt and navigation, appended after your existing shell setup.
- `tooling`: npm lockfile, hashed Python lockfile, official debugger URL and SHA-256.
- `tests`: actual server, formatter, PDF compilation, debugger and installer checks.

Plugins are locked by commit, including lazy.nvim. Python packages are hash-locked, with Python 3.14.6 requested through uv. npm dependencies are installed with `npm ci`. The JS debugger archive is checksum-verified. Homebrew packages/casks follow current Homebrew releases; this is repeatable configuration installation, not a byte-for-byte frozen operating system. Record tested system versions before planned upgrades. Node 22+ and Neovim 0.12+ are required.

There are no startup update checks, dashboards, AI chat integrations, notebook packages ; tmux is used only by the optional workspace launcher. Syntax uses native Neovim Treesitter with installed parsers; files over 1 MiB skip Treesitter, autoformat and Copilot and detach LSPs. Search respects ignore files and explicitly excludes generated dependency/build directories. Git status is omitted from the shell prompt to avoid scanning large projects on every prompt.

For an isolated preview:

```sh
./scripts/preview.sh
```

## Verify and update

```sh
./tests/run.sh
./scripts/benchmark.sh
```

The test suite uses disposable files under `.state`, including deliberately invalid source to check diagnostics. It does not open your projects. Initial verification needs network access and local process/socket permissions. Native Ghostty validation is included, but visual appearance, physical shortcut delivery, authenticated Copilot suggestions need interactive checks.

Review updates deliberately: use `:Lazy update`, install parser updates, rerun the suite, inspect `lazy-lock.json`, and then commit. To upgrade JS tools, change exact versions in `tooling/package.json`, regenerate its npm lockfile, and run `--dependencies`. For Python, regenerate `tooling/python.lock` with `uv pip compile --python 3.14.6 --generate-hashes tooling/python.in -o tooling/python.lock`, review the diff and rerun dependencies/tests. Do not run unattended upgrades before important work.

## Roll back

Remove only symlinks that still point to this checkout. Remove the added `source ".../shell/env.zsh"` line from your `.zshrc`, or restore the dated `.zshrc.dotfiles-backup-*` after comparing any subsequent edits. Installed Homebrew applications remain available; uninstall them individually only if you no longer need them. `.tools` and `.state` are generated and ignored; recreate them after moving the checkout. No installation step pushes or publishes this repository.

See `AUDIT.md` for the evidence and remaining interactive checks from this machine.


## Productive workspace suite

Open a new terminal and run `suite`. Home contains Projects, Codex → Personal/Work, Antigravity, Claude → Personal/Work, Git → Lazygit, and AWS. Tab switches between typing and navigation; j/k move, l/Enter selects, and h/Escape goes back. Navigation mode persists between suite folders. Pickers inherit Ghostty's background, with a subtle selected-row highlight.

### Projects

```sh
work add my-app ~/DEV/my-app --group Development
work add x .                 # Register the current directory; path also defaults to .
work list
cproj my-app                 # Change this shell's directory
work favorite my-app         # Add --off to unpin
work remove my-app           # Remove registration only; files stay intact
```

Suite → Projects shows registered projects directly:

| Shortcut | Action on selected project |
|---|---|
| Enter / l | Change the current terminal's directory only |
| Ctrl-W | Resume its workspace; if empty or first use, change directory only |
| Ctrl-N | Create/register a project; existing directories are reused |
| Ctrl-F | Toggle favorite |
| Ctrl-U | Update name, folder and category |
| Ctrl-D | Confirm removal of registration; project files stay intact |
| Ctrl-S | Confirm stopping its running workspace |

For explicit workspace creation, use `work open my-app`; it starts with a shell. `work open my-app --layout code` launches/restores Neovim explicitly. Existing live workspaces always resume unchanged. Ctrl-W considers multiple panes/windows, named editor files or an active command meaningful workspace content.

### Saving, leaving and stopping

Inside a tmux project workspace, Ctrl-b then v makes a side-by-side terminal and Ctrl-b then s makes a stacked terminal. Ctrl-b then n creates a terminal window; Ctrl-b then P opens the project chooser.

- `work checkpoint` saves the terminal layout.
- `work leave` or Ctrl-b then d checkpoints the layout and detaches, keeping terminals, editors, unsaved edits and processes running. `:ProjectLeave` is available in workspace-aware Neovim.
- `work stop NAME`, Ctrl-b then Shift-Q, or Ctrl-S in the project list confirms, refuses unsaved editor changes, saves the terminal/editor layout, and ends the session and its processes. Close older editors without workspace protection normally first.

Each editor pane keeps an independent snapshot; workspace-aware Neovim checkpoints every 30 seconds. Saved terminal windows/panes, directories, focus and zoom state restore when opening a stopped workspace. `--layout code` also restores editor snapshots; the default shell layout does not launch Neovim. Arbitrary commands and terminal scrollback are not restored. A reboot ends live processes; session snapshots do not contain unsaved file contents. Stop keeps the saved layout; it does not reset or delete the project. Cmd-Q retains its editor-view shortcut.

Ghostty splits created with Cmd-D are separate from tmux splits. Project-specific Ghostty layout restoration has been discussed but is not implemented. Ghostty's app-wide `window-save-state = always` is also not enabled by this configuration.

### Editor and shell

In Neovim, Space-Space or `:Commands` opens the command palette. Pickers and text inputs use rounded borders. Task output remains in terminals; diagnostics and quickfix are available through the palette.

The shell supplies searchable history with Ctrl-r, directory search with Alt-c, history suggestions, command highlighting, AWS completion and `z` directory jumping. The prompt shows the selected AWS profile/region and elapsed time for longer commands.

### AI accounts and project continuity

After installing Codex, run `gpt personal login` and `gpt work login` once. Launch with `gpt personal` or `gpt work`. Personal maps to the existing primary account directory, and Work to secondary, under `~/.local/share/codex-accounts/`. Each keeps separate file-based credentials, configuration and history. Existing default Codex credentials are not copied. These commands do not switch accounts in the ChatGPT app or website. Antigravity runs the terminal CLI `agy` in the current directory (with `~/.local/bin/agy` as a fallback path); it does not launch the IDE. Claude launches its installed CLI. Missing tools are reported without installing them.

Inside a project, `work context-init` creates AGENTS.md and PROJECT_CONTEXT.md only when absent. Keep lasting instructions in AGENTS.md and current objectives, decisions, next steps and validation in PROJECT_CONTEXT.md. Ask the agent to update the handoff before switching accounts; this does not transfer chat history. Keep credentials out of these files.

### AWS

`awsprofile` selects a configured profile for this shell and clears credential variables that could override it. `awslogin` runs SSO login, `awsidentity` checks the active identity, and `awsclear` clears profile and credential overrides. Configure profiles with `aws configure sso`. Docker and animations remain deferred.

The Projects picker groups projects under category headings with counts and indented project rows. Enter/l on a heading expands or collapses it; h folds the selected category in navigation mode, and Escape returns to the suite. Favorites sort first within each category. Project actions apply to project rows, while Ctrl-N remains available everywhere.


## Git review

Suite → Git → Lazygit, `git-ui` in a shell, or Space-gg in Neovim opens the themed Git interface. Files are organized as a tree with change counts, rounded borders and restrained Poimandres colors. Unified diffs use Delta syntax highlighting, old/new line numbers, plus/minus markers and word-level change emphasis. Context lines retain the terminal background; only changes get muted red/mint backgrounds. Press `|` in Lazygit to cycle Unified / Side by side / Raw Git renderers. Existing local Lazygit configuration is loaded before the suite's visual overrides.

`git diff`, `git show` and `git log -p` use Delta when Git opens a pager. Pipe raw Git output with `git --no-pager diff` when needed. Neovim Space-gp previews the current hunk in a rounded float; Space-gD opens a native diff against the index. Existing Space-gr references remains unchanged.

`./install.sh --git` adds an idempotent include for the repository's Git styling and backs up the existing Git config first. It preserves identity, credential helpers and aliases. `--all` includes this step; updates should run it once to enable the include. Delta is installed through the Brewfile. These settings affect Git views, not AI CLI conversation rendering.


### Claude personal and work

Suite → Claude contains Personal and Work, preserving the same Tab navigation behavior. `claude-account personal` uses the existing default `~/.claude` configuration and login; `claude-account work` uses the separate `~/.claude-work` directory. Authenticate Work once using `claude-account work auth login` (or `/login` inside that session). Personal can be authenticated with `claude-account personal auth login` if needed. Settings, credentials and history stay separate through Claude's supported `CLAUDE_CONFIG_DIR` setting. Existing credentials are not copied or removed. API/auth token and alternate-provider environment overrides are removed for these account launches; project and managed policies still apply. Both run in the current project directory. The directories stay local and are not committed or installed on other devices.

Lazygit now defaults to a minimal review layout: a file tree, a compact branches/commits/stash panel, subtle selection, and a wide diff view. Command logs, random tips, panel numbers and persistent footer hints are hidden; `?` still opens help. The Review renderer uses side-by-side diffs in wide panels and unified diffs in narrow ones; `|` cycles modes. `--git` links the theme for direct `lazygit` when its default config is absent or empty (backing up an empty file); nonempty custom configs are preserved. Suite `git-ui` and Space-gg apply the same styling.


## Appearance settings

Suite → Settings provides independent Coding theme, Background and Font controls, plus Current settings and Restore defaults. Coding themes: Poimandres, Tokyo Night Moon, Catppuccin Mocha, Rosé Pine Moon, Kanagawa Wave and Dragon. They change Neovim syntax and its buffer/status colors. Font selection lists installed Ghostty font families and lets you set size and thickening. Ligatures and syntax italics remain enabled; choose a Nerd Font family to keep icons. Background supports the bundled galaxy, plain color, or a local wallpaper, with independent color, opacity, blur and wallpaper opacity.

Settings show pending values and require Apply confirmation. Preferences persist locally in `.state/appearance/settings.json`; generated Ghostty overrides are loaded through an optional config include. The installer initializes them without resetting existing preferences (`./install.sh --appearance`). Coding themes are plugin-locked and installed by `--plugins`. Reload Ghostty with Cmd-Shift-comma after applying; font/window changes may require a new window. Restart Neovim for a coding-theme change. Restore defaults returns to Maple Mono with Victor Mono italics, Poimandres and the original glassy galaxy appearance. Wallpapers and font settings are independent of coding themes. Suite, shell, tmux and Git retain their current coordinated palette; these are coding-theme controls, not a global palette switch for every application.

Definition insight uses a compact theme-aware popup with a shortened source path, quiet headings and a bounded implementation excerpt. Python previews omit a leading docstring already supplied by hover and stop before adjacent definitions. Press Space-l-d again to focus the preview, then j/k or Ctrl-d/Ctrl-u to scroll; q/Escape closes it. Line diagnostics still take precedence.

The default font pairing uses Maple Mono NF for regular/bold text and VictorMono Nerd Font Mono for italic/bold-italic text. Both font packages are included in the Brewfile. Settings → Font stores the regular and italic families independently; selecting a new regular family keeps the current italic family unless explicitly changed. Ghostty font-family lists are reset before overrides so earlier defaults cannot take precedence. Ligatures, size and thickening remain independently configurable.


## Markdown preview

Glow is a required dependency in the Brewfile and is checked by `./install.sh --doctor`. New installations get it through `./install.sh --all`; existing installations can run `./install.sh --dependencies` or `brew install glow`.

In Neovim, save the Markdown file with Cmd-S and run `:MD` to open one reusable floating preview. In a shell, use `glow README.md`, or `glow` to browse Markdown files. If Neovim reports Glow missing after installation, open a new terminal and restart Neovim so it inherits Homebrew's PATH. The preview reads the saved file, not unsaved editor contents. It stays open in a pager: j/k and Ctrl-d/Ctrl-u scroll; q or Escape closes only the preview and returns to the editor. Repeating :MD focuses an existing preview instead of creating another one.

LaTeX PDFs open in macOS Preview via `:Pdf`, `:OpenPDF`, or `,lv`. `:Build` / `,ll` starts compilation and opens the viewer when the PDF is ready. Source-to-PDF and PDF-to-source jumps are unavailable in Preview. If the displayed PDF does not refresh after a rebuild, run `:Pdf` again. No separate PDF viewer is installed or configured.


## LaTeX formatting rules

LaTeX formatting uses Homebrew latexindent (with managed Perl dependencies), replacing tex-fmt. `:Format`, Space-cf and the existing asynchronous save formatter apply `config/latexindent/.latexindent.yaml`: four-space environment/heading/list indentation, preamble indentation, conservative structural line breaks, 100-column prose wrapping, alignment, verbatim protection and trailing-whitespace cleanup. `bin/latex-format` enforces the final newline and keeps logs/scratch files out of projects.

The shared rules load first; the nearest project `.latexindent.yaml`, `latexindent.yaml`, `.localSettings.yaml` or `localSettings.yaml` overrides them, searching up to the Git root. Homebrew's executable is used explicitly to avoid a TeX Live script with missing Perl modules. Updates need `./install.sh --dependencies`; the doctor checks that latexindent actually starts.

The supplied policy was normalized to latexindent's supported syntax: heading `lookForThis` replaces its deprecated alias; heading commands have individual line-break settings; alignment regex captures and retains `&`; wrapping uses a newline separator and runs after indentation; document indentation overrides latexindent's default exemption. Heading indentation stops before the document end. Final-newline enforcement is implemented by the wrapper rather than an unsupported YAML key. Long unbreakable words may exceed 100 columns; math is not blindly split to fit.
