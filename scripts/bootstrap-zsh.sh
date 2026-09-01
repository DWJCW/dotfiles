#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
usage: bootstrap-zsh.sh [--home PATH] [--skip-install]

Install Oh My Zsh and link the tracked Zsh configuration with GNU Stow.
An existing untracked .zshrc is never overwritten.

Options:
  --home PATH       Stow target (default: the current user's home directory)
  --skip-install    Link configuration only; do not clone Oh My Zsh
  -h, --help        Show this help
EOF
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
dotfiles_root="$(cd -- "${script_dir}/.." && pwd -P)"
target_home="${HOME}"
install_oh_my_zsh=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --home)
      if [[ $# -lt 2 || -z "$2" ]]; then
        echo "bootstrap-zsh.sh: --home requires a path" >&2
        usage >&2
        exit 64
      fi
      target_home="$2"
      shift 2
      ;;
    --skip-install)
      install_oh_my_zsh=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "bootstrap-zsh.sh: unknown argument: $1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "bootstrap-zsh.sh: required command not found: $1" >&2
    exit 69
  fi
}

require_command stow
if [[ "${install_oh_my_zsh}" -eq 1 ]]; then
  require_command git
fi

mkdir -p "${target_home}"
target_home="$(cd -- "${target_home}" && pwd -P)"
oh_my_zsh_dir="${target_home}/.oh-my-zsh"

if [[ "${install_oh_my_zsh}" -eq 1 && ! -d "${oh_my_zsh_dir}" ]]; then
  if [[ -e "${oh_my_zsh_dir}" ]]; then
    echo "bootstrap-zsh.sh: ${oh_my_zsh_dir} exists but is not a directory" >&2
    exit 65
  fi
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "${oh_my_zsh_dir}"
fi

if [[ "${install_oh_my_zsh}" -eq 1 && ! -f "${oh_my_zsh_dir}/oh-my-zsh.sh" ]]; then
  echo "bootstrap-zsh.sh: ${oh_my_zsh_dir} is not an Oh My Zsh installation" >&2
  exit 65
fi

stow \
  --dir="${dotfiles_root}" \
  --target="${target_home}" \
  --restow \
  --no-folding \
  zsh

echo "Linked the Zsh configuration into ${target_home}/.zshrc"
if [[ "${install_oh_my_zsh}" -eq 0 ]]; then
  echo "Skipped Oh My Zsh installation"
else
  echo "Oh My Zsh is installed in ${oh_my_zsh_dir}"
fi
