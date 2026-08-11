#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
usage: bootstrap-nvim.sh [--home PATH] [--skip-restore]

Install the complete tracked Neovim configuration with GNU Stow. By default,
LazyVim and every plugin are then installed/restored to lazy-lock.json.

Options:
  --home PATH       Stow target (default: the current user's home directory)
  --skip-restore    Link configuration only; do not start Neovim or fetch plugins
  -h, --help        Show this help
EOF
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
dotfiles_root="$(cd -- "${script_dir}/.." && pwd -P)"
target_home="${HOME}"
restore_plugins=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --home)
      if [[ $# -lt 2 || -z "$2" ]]; then
        echo "bootstrap-nvim.sh: --home requires a path" >&2
        usage >&2
        exit 64
      fi
      target_home="$2"
      shift 2
      ;;
    --skip-restore)
      restore_plugins=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "bootstrap-nvim.sh: unknown argument: $1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "bootstrap-nvim.sh: required command not found: $1" >&2
    exit 69
  fi
}

require_command stow
if [[ "${restore_plugins}" -eq 1 ]]; then
  require_command git
  require_command nvim
fi

mkdir -p "${target_home}"
target_home="$(cd -- "${target_home}" && pwd -P)"

stow \
  --dir="${dotfiles_root}" \
  --target="${target_home}" \
  --restow \
  --no-folding \
  nvim

echo "Linked the complete Neovim configuration into ${target_home}/.config/nvim"

if [[ "${restore_plugins}" -eq 0 ]]; then
  echo "Skipped plugin restore"
  exit 0
fi

mkdir -p \
  "${target_home}/.local/share" \
  "${target_home}/.local/state" \
  "${target_home}/.cache"

lockfile="${target_home}/.config/nvim/lazy-lock.json"
lazy_root="${target_home}/.local/share/nvim/lazy"
lazy_path="${lazy_root}/lazy.nvim"
lazy_commit="$(
  NVIM_LOCKFILE="${lockfile}" \
  NVIM_LAZY_PLUGIN=lazy.nvim \
    nvim --clean --headless -l "${script_dir}/read-lazy-lock-commit.lua"
)"

mkdir -p "${lazy_root}"
if [[ ! -d "${lazy_path}/.git" ]]; then
  if [[ -e "${lazy_path}" ]]; then
    echo "bootstrap-nvim.sh: ${lazy_path} exists but is not a Git checkout" >&2
    exit 65
  fi
  git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "${lazy_path}"
fi

if ! git -C "${lazy_path}" cat-file -e "${lazy_commit}^{commit}" 2>/dev/null; then
  git -C "${lazy_path}" fetch --filter=blob:none origin "${lazy_commit}"
fi
git -C "${lazy_path}" checkout --detach "${lazy_commit}"

env \
  HOME="${target_home}" \
  XDG_CONFIG_HOME="${target_home}/.config" \
  XDG_DATA_HOME="${target_home}/.local/share" \
  XDG_STATE_HOME="${target_home}/.local/state" \
  XDG_CACHE_HOME="${target_home}/.cache" \
  NVIM_APPNAME=nvim \
  NVIM_DOTFILES_ROOT="${dotfiles_root}" \
  nvim --headless \
    "+Lazy! restore" \
    "+lua dofile(assert(os.getenv('NVIM_DOTFILES_ROOT')) .. '/scripts/bootstrap-mason.lua')" \
    "+lua dofile(assert(os.getenv('NVIM_DOTFILES_ROOT')) .. '/scripts/bootstrap-treesitter.lua')" \
    "+qa"

echo "Restored locked plugins, Mason tools, and Treesitter parsers without changing the lockfile"
