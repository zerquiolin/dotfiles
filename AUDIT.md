# macOS development environment

A small, owned Lua configuration for Apple Silicon macOS: Ghostty with glassy Poimandres colors, Neovim, Zsh, fast file navigation, Python, JS/TS/React, LaTeX, Git, and debugging. No notebook integration is installed.

## Install

Prerequisites: macOS on Apple Silicon, Apple's Command Line Tools (`xcode-select --install`), and [Homebrew](https://brew.sh). Keep the checkout at a permanent path: configuration links, the shell source line, and tool environments reference it.

After this repository has been reviewed and pushed:

```sh
git clone https://github.com/zerquiolin/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run
./install.sh --all
```

The default command only previews changes. `--all` installs dependencies, links configuration, restores locked plugins, installs syntax parsers, adds shell integration, and checks dependencies. Existing Neovim, Ghostty, or Starship files cause a stop before linking; the installer never replaces them. Move a conflicting configuration yourself after reviewing and backing it up. The shell integration appends one source line and saves a dated copy of an existing `.zshrc`.

Your existing TeX distribution is reused. On a Mac without LaTeX, the separate `Brewfile.latex` installs MacTeX without its bundled GUI; this is a large download. The built-in macOS Preview app displays PDFs.

Individual stages:

```sh
./install.sh --dependencies
./install.sh --link
./install.sh --plugins
./install.sh --shell
./install.sh --doctor
```

Open a new terminal to activate shell changes. Reload Ghostty configuration with Cmd-Shift-comma; some window appearance settings require a new window.

## First use

Open a project directory and run `nvim .`. Authenticate Copilot once with `:Copilot auth`; the sign-in and subscription belong to your GitHub account. `:Copilot status` checks the connection. The plugin downloads its pinned native server on first initialization. Credentials are never included in this repository.

Use project `.venv` environments for Python. basedpyright discovers standard `.venv` layouts; set `venvPath`/`venv` in `pyrightconfig.json` for other layouts. The debugger uses the active `VIRTUAL_ENV`, then the project's `.venv`, then its own Python environment. Python language tools live in an isolated environment and do not replace Conda or project packages.

For JS/TS, install project dependencies normally. ESLint uses project configuration and the project's ESLint installation. Formatting prefers project-local binaries; Biome is chosen when a `biome.json`/`biome.jsonc` exists, otherwise Prettier. The TypeScript server uses its bundled compiler fallback; project TypeScript can be selected with vtsls settings. Next.js, React and Express editing use the TS/JS stack. React Native device tooling and Metro remain project responsibilities.

`Format` runs explicitly; formatting after save is asynchronous and writes the formatted result back to disk. `FormatToggle` disables/enables it for the current buffer. Ruff import fixes are available through LSP code actions; formatting does not silently organize imports.

For LaTeX, open the main document, use `,ll` to start/stop continuous compilation and `,lv` to open the PDF in macOS Preview. Preview does not provide source/PDF synchronization. VimTeX owns compilation; texlab's automatic builds are disabled to avoid duplicate build processes. `:Build` and `:OpenPDF` are also available.

## File names across the top

The top buffer bar lists loaded file buffers with type icons and an unsaved `●` indicator. `tn` and `tp` switch the buffer displayed in the current editor pane. Buffer names are shared across Neovim tab pages, reflecting Neovim's shared-buffer model; they are not separate copies of files. Space-tn still creates a real tab page. The bar hides destructive close buttons so it cannot delete shared buffers accidentally; Cmd-Q / Space-q close the current view and remove its name once no other view uses that buffer. The last unsaved view prompts Save / Discard / Cancel; a failed save leaves it open. A file still visible in another split or tab keeps its name.

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
| In `ff` / `fg` | Type to filter; Tab toggles `h/j/k/l` result navigation (`h/k` up, `j/l` down) |
| In `fb` | Type to filter; use arrows or Ctrl-n/Ctrl-p to move through results |
| Ctrl-Space in a picker | Mark/unmark a result for multi-selection |
| Space-ee, Cmd-j | Toggle tree explorer |
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
| `gd`, `gr`, `K` | Definition, references, hover |
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

Cmd-Q is forwarded to Neovim to close a view; use Ghostty’s app menu to quit the terminal application. Cmd mappings are translated by Ghostty to F13/F14/F15/F16/F17/F18 terminal sequences. Option is configured as Alt. Physical key delivery and macOS shortcut conflicts must be checked on your keyboard. Cmd-Option-v has no equivalent Vim-extension toggle: Neovim is the editor, with normal/insert modes built in. Cmd-j toggles the filesystem UI because there is no VS Code activity bar.

Run/debug project scripts through the terminal. `:Build` only auto-selects LaTeX; it does not guess and execute arbitrary package scripts. The debugger provides current-file Python/Node launches and Node process attachment. For TypeScript launch, configure your project's build or runtime loader; Node launch does not automatically supply tsx/ts-node. Browser and React Native debugging need project-specific adapter settings.

## Layout and customization

- `config/nvim/lua/config`: options, mappings, autocmds, plugin bootstrap.
- `config/nvim/lua/plugins`: one file per feature; add plugin specs here.
- `config/nvim/lua/user`: custom commands, terminal and explorer helpers.
- `config/ghostty/config`: opacity, blur, palette, font and terminal key translation.
- `shell/env.zsh`: lightweight prompt and navigation, appended after your existing shell setup.
- `tooling`: npm lockfile, hashed Python lockfile, official debugger URL and SHA-256.
- `tests`: actual server, formatter, PDF compilation, debugger and installer checks.

Plugins are locked by commit, including lazy.nvim. Python packages are hash-locked, with Python 3.14.6 requested through uv. npm dependencies are installed with `npm ci`. The JS debugger archive is checksum-verified. Homebrew packages/casks follow current Homebrew releases; this is repeatable configuration installation, not a byte-for-byte frozen operating system. Record tested system versions before planned upgrades. Node 22+ and Neovim 0.12+ are required.

There are no startup update checks, dashboards, AI chat integrations, notebook packages or tmux dependency. Syntax uses native Neovim Treesitter with installed parsers; files over 1 MiB skip Treesitter, autoformat and Copilot and detach LSPs. Search respects ignore files and explicitly excludes generated dependency/build directories. Git status is omitted from the shell prompt to avoid scanning large projects on every prompt.

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


## Productivity suite update

Implemented a machine-local categorized project registry, favorites, saved/active session labels, branch metadata, tmux sidebar and shell/editor launch templates. Added shell palette, project directory shortcuts, isolated Codex account wrappers, non-overwriting context templates, AWS profile/SSO/identity helpers, shell suggestions/highlighting/completion, prompt context, editor command palette, and consistent pickers/input floats. Installation Brewfile and doctor cover the new dependencies. Animations and Docker remain deferred.

Validation: existing regression suite passed (language services, formatting, PDF build, debugger continuation, explorer, windows, search, clipboard and saves); dependency doctor passed; disposable real tmux creation/resume/layout checks passed; project registry paths containing spaces, duplicate prevention and template preservation passed; palette and floating input cancellation passed. Ghostty configuration validation was also run by the regression suite. Visual appearance and actual account/SSO authentication still require an interactive user session. The sidebar is a searchable terminal list with categories, not a native draggable/collapsible Ghostty tab tree. Running processes persist while tmux runs, not through reboot.

Homebrew installed tmux, AWS CLI, shell highlighting and suggestions, and updated their shared dependencies. In particular, Homebrew linked Python 3.15 as its default; existing isolated editor Python tools and debugger checks passed afterward. Homebrew reports backups of overwritten links under its cache Backup directory.

Project-opening lifecycle: verified disposable first-use opens without a sidebar; live resume retains the editor process; stop/reopen restores terminal window count, active window, and editor tabs. Editor panes now use independent snapshots, with periodic checkpoints and terminal-layout capture on leave. Layout checkpoints do not preserve arbitrary running processes or unsaved text through reboot.
