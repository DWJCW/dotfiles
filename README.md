# Dotfiles

This repository manages local terminal and editor configuration with GNU Stow.

Managed packages:

- `zsh` (Oh My Zsh with a colorful, font-independent prompt)
- `tmux`
- `kitty`
- `nvim` (the complete LazyVim configuration, including the generated
  iPad cheat sheet and its source/audit scripts)

## Dependencies

Core tools on `PATH`: `zsh`, `nvim`, `tmux`, `kitty`, `stow`, `git`.

Additional binaries the Neovim configuration and its tooling expect:

- `fd` — required by `venv-selector.nvim` (loaded by the LazyVim python
  extra, backing `Space c v` / `:VenvSelect`). Without it, opening a python
  buffer errors and `:NvimCheatsheetAudit` never completes.
- `lazygit` — LazyVim only defines `<leader>gg` when this binary exists.
- A C/C++ compiler and the `tree-sitter` CLI — compile the configured Treesitter
  parsers. LazyVim can obtain the CLI through Mason when it is not on `PATH`.
- `cmake` and optionally `ninja` — configure and build C/C++ projects from the
  CMake integration.
- `magick` (ImageMagick) and Google Chrome — `scripts/build-cheatsheet.sh`
  renders the iPad cheat-sheet PNG from HTML and verifies it.
- `gs` (Ghostscript) — Snacks image preview for PDFs (`:edit *.pdf`).
- Skim — VimTeX viewer and SyncTeX inverse search for LaTeX.

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
stow -t "$HOME" zsh tmux kitty nvim
```

Remove links without deleting tracked files:

```sh
stow -D -t "$HOME" zsh tmux kitty nvim
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

Run the slower network integration test, which restores every plugin into an
isolated HOME, checks all 40-character commits against `lazy-lock.json`, waits
for all configured Mason tools and Treesitter parsers, and starts LazyVim
headlessly:

```sh
./tests/test-nvim-locked-bootstrap.sh
```
