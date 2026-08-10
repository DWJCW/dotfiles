# Dotfiles

This repository manages local terminal and editor configuration with GNU Stow.

Managed packages:

- `tmux`
- `kitty`
- `nvim` (the complete LazyVim configuration, including the generated
  iPad cheat sheet and its source/audit scripts)

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
