# Dotfiles

This repository manages local terminal and editor configuration with GNU Stow.

Managed packages:

- `tmux`
- `kitty`
- `nvim` (the complete LazyVim configuration, including the generated
  iPad cheat sheet and its source/audit scripts)

## Dependencies

Core tools on `PATH`: `nvim`, `tmux`, `kitty`, `stow`, `git`.

Additional binaries the Neovim configuration and its tooling expect:

- `fd` — required by `venv-selector.nvim` (loaded by the LazyVim python
  extra, backing `Space c v` / `:VenvSelect`). Without it, opening a python
  buffer errors and `:NvimCheatsheetAudit` never completes.
- `lazygit` — LazyVim only defines `<leader>gg` when this binary exists.
- `magick` (ImageMagick) and Google Chrome — `scripts/build-cheatsheet.sh`
  renders the iPad cheat-sheet PNG from HTML and verifies it.
- `gs` (Ghostscript) — Snacks image preview for PDFs (`:edit *.pdf`).
- Skim — VimTeX viewer and SyncTeX inverse search for LaTeX.

Language servers are installed automatically by Mason on first start
(`lua/plugins/workflow.lua`): pyright, ruff, texlab, marksman, json-lsp,
lua-language-server, bash-language-server, yaml-language-server, taplo,
shellcheck.

Install or refresh links from the repository root:

```sh
stow -t "$HOME" tmux kitty nvim
```

Remove links without deleting tracked files:

```sh
stow -D -t "$HOME" tmux kitty nvim
```

Repository layout follows Stow's target-relative structure, so files inside
each package mirror their final path under `$HOME`.

Verify that the active Neovim configuration is byte-for-byte identical to
the tracked configuration and is linked to this repository:

```sh
./tests/test-nvim-dotfiles-sync.sh
```
