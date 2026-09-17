# Dotfiles

This repository manages local terminal and editor configuration with GNU Stow
on Linux and macOS.

Managed packages:

- `zsh` (Oh My Zsh with a colorful, font-independent prompt)
- `tmux`
- `kitty` (shared config plus a platform-selected overlay)
- `nvim` (the complete LazyVim configuration, including the generated
  iPad cheat sheet and its source/audit scripts)

## Platform and dependencies

The platform defaults to automatic detection: Linux (including WSL) or macOS.
Set `DOTFILES_PLATFORM=linux`, `DOTFILES_PLATFORM=macos`, or `DOTFILES_PLATFORM=auto`
to override or test the choice. Unsupported values fail immediately. The
bootstrap scripts only inspect dependencies and print installation suggestions;
they never invoke `brew`, `apt`, `pacman`, or another package manager.

The Neovim bootstrap requires `stow`, `git`, and Neovim 0.12 or newer when
restoring plugins (`stow` alone is enough for `--skip-restore`). The complete
shell setup also uses `zsh`, `tmux`, and `kitty`.

Additional binaries the Neovim configuration and its tooling expect:

- `fd` — required by `venv-selector.nvim` (loaded by the LazyVim python
  extra, backing `Space c v` / `:VenvSelect`). Without it, opening a python
  buffer errors and `:NvimCheatsheetAudit` never completes.
- `lazygit` — LazyVim only defines `<leader>gg` when this binary exists.
- A C/C++ compiler and the `tree-sitter` CLI — compile the configured Treesitter
  parsers. LazyVim can obtain the CLI through Mason when it is not on `PATH`.
- `cmake` and optionally `ninja` — configure and build C/C++ projects from the
  CMake integration.
- `magick` (ImageMagick) and a Chrome/Chromium executable on `PATH` —
  `scripts/build-cheatsheet.sh`
  renders the iPad cheat-sheet PNG from HTML and verifies it.
- `gs` (Ghostscript) — Snacks image preview for PDFs (`:edit *.pdf`).
- macOS: Skim is preferred for VimTeX and SyncTeX inverse search; `open` is a
  startup-safe fallback when Skim is not installed.
- Linux: VimTeX selects `zathura`, then `okular`, then `xdg-open`; if none is
  available, Neovim starts normally and emits a warning when the capability is
  configured.

Check the environment without linking files or installing anything:

```sh
./scripts/bootstrap-nvim.sh --check-deps
```

Missing core dependencies make this command fail. Missing viewers, browsers,
fonts, and other feature dependencies only produce warnings and platform-
appropriate suggestions.

The bootstrap waits for the Mason toolchain declared by
`lua/plugins/workflow.lua`: clangd, neocmakelsp, cmakelang, cmakelint, pyright,
ruff, texlab, marksman, json-lsp, lua-language-server, bash-language-server,
yaml-language-server, taplo, shellcheck, plus LazyVim's configured formatters
and Markdown tools.

## New-machine setup

Clone the repository to any location, install the core dependencies above,
then install the shell configuration:

```sh
./scripts/bootstrap-zsh.sh
```

The Zsh bootstrap clones Oh My Zsh into `~/.oh-my-zsh` and links the tracked
`.zshrc`. It does not overwrite an existing untracked `.zshrc`; move that file
aside or merge it into `zsh/.zshrc` first. The configuration uses the built-in
`robbyrussell` theme, so its colored prompt and Git status do not require a
Nerd Font.

Link Kitty and select its overlay with:

```sh
./scripts/bootstrap-kitty.sh
```

The shared Kitty file is always linked. Linux selects an empty platform file;
macOS selects the file containing `macos_option_as_alt left`. Rerunning the
bootstrap is safe, including after changing `DOTFILES_PLATFORM`.

Install the Neovim configuration with:

```sh
./scripts/bootstrap-nvim.sh
```

The bootstrap is location-independent. It uses Stow to link every tracked file
under `nvim/.config/nvim`, starts Neovim headlessly so Lazy installs or restores
all plugins to the exact commits in `lazy-lock.json`, and waits until every
configured Mason tool and Treesitter parser is installed. It is safe to rerun
after pulling dotfile changes. Stow stops on a conflicting untracked file
instead of overwriting it. The bootstrap pins `lazy.nvim` and `LazyVim` before
startup, and the integration test rejects any lockfile rewrite during first
startup.

To link only the configuration without network access:

```sh
./scripts/bootstrap-nvim.sh --skip-restore
```

For an alternate target (including isolated tests), pass `--home PATH`.

The Neovim platform capability module is available as
`lua/config/platform.lua`. It owns platform detection, executable checks, PDF
viewer selection, and macOS/Skim probing so plugin specs do not call `uname`,
`defaults`, or other platform commands directly.

## What is portable

The complete personal configuration is tracked, including LazyVim specs,
enabled extras, plugin overrides, `lazyvim.json`, `lazy-lock.json`, and all
cheat-sheet sources, audit scripts, templates, HTML, Markdown, JSON, and PNG
artifacts.

`~/.local/share/nvim/lazy/` is intentionally not copied into dotfiles. It is a
generated checkout cache of upstream projects, including LazyVim itself. The
tracked lockfile plus the bootstrap reproduce that cache byte-for-byte at the
Git commit level on another machine. Mason packages, Treesitter parsers, cache,
state, logs, swap, and undo files are likewise generated data rather than
personal configuration.

## Manual Stow usage

Install or refresh links from the repository root:

```sh
stow -t "$HOME" zsh tmux nvim
./scripts/bootstrap-kitty.sh
```

Remove links without deleting tracked files:

```sh
stow -D -t "$HOME" zsh tmux nvim
stow -D -t "$HOME" kitty-linux kitty-macos kitty
```

Repository layout follows Stow's target-relative structure, so files inside
each package mirror their final path under `$HOME`.

Verify that the active Neovim configuration is byte-for-byte identical to
the tracked configuration and is linked to this repository:

```sh
./tests/test-nvim-dotfiles-sync.sh
```

Test an offline installation into an empty temporary HOME, including a second
idempotent bootstrap:

```sh
./tests/test-nvim-portable-bootstrap.sh
```

Exercise platform overrides, Linux PDF viewer fallback, Kitty overlays, and the
Darwin-only zsh plugin (the zsh test skips when zsh is not installed):

```sh
./tests/test-platform.sh
./tests/test-kitty-platform.sh
./tests/test-zsh-platform.sh
```

Run the slower network integration test, which restores every plugin into an
isolated HOME, checks all 40-character commits against `lazy-lock.json`, waits
for all configured Mason tools and Treesitter parsers, and starts LazyVim
headlessly:

```sh
./tests/test-nvim-locked-bootstrap.sh
```

## Updating existing machines

Use the same `main` branch on each machine. Update the repository first, then
let Stow refresh the links (do not copy edited configurations into `$HOME`):

```sh
git pull --ff-only
export PATH="$HOME/.local/bin:$PATH"  # prefer a user-installed Neovim over old system packages
stow --restow --no-folding -t "$HOME" tmux
./scripts/bootstrap-kitty.sh
./scripts/bootstrap-nvim.sh
./tests/test-nvim-dotfiles-sync.sh
```

On machines using Zsh, also run `./scripts/bootstrap-zsh.sh`. When migrating an
existing `.zshrc`, back it up and move machine-specific aliases, Conda setup,
paths, and credentials into `~/.zshrc.local` before linking. The managed `.zshrc`
loads that optional, untracked file after Oh My Zsh. Do not commit credentials
or machine-specific overrides. Installing the config does not change the
account's login shell.

In the Snacks file explorer, `y` copies selected file paths. Over SSH it also
sends those paths to the client terminal's clipboard through OSC 52, including
inside tmux. Kitty permits clipboard writes; tmux enables clipboard forwarding.
Normal editing registers and paste behavior are unchanged. Restart Neovim after
updating; reload existing tmux sessions with `tmux source-file ~/.tmux.conf`.

To validate the installed editor without a UI:

```sh
nvim --headless -i NONE \
  '+lua dofile("tests/validate-explorer-clipboard.lua")' \
  '+lua dofile("tests/validate-cpp-toolchain.lua")' \
  '+lua dofile("tests/validate-installed-mason.lua")' \
  '+lua dofile("tests/validate-installed-treesitter.lua")' \
  '+if v:errmsg !=# "" | cquit 1 | endif' '+qa'
```
