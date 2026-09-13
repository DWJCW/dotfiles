#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
usage: bootstrap-kitty.sh [--home PATH]

Link the shared Kitty configuration and select the Linux or macOS overlay.
The target may be changed safely by rerunning this command.

Options:
  --home PATH       Stow target (default: the current user's home directory)
  -h, --help        Show this help
EOF
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
dotfiles_root="$(cd -- "${script_dir}/.." && pwd -P)"
target_home="${HOME}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --home)
      if [[ $# -lt 2 || -z "$2" ]]; then
        echo "bootstrap-kitty.sh: --home requires a path" >&2
        usage >&2
        exit 64
      fi
      target_home="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "bootstrap-kitty.sh: unknown argument: $1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

# shellcheck source=platform.sh
source "${script_dir}/platform.sh"
platform="$(dotfiles_resolve_platform)"

if ! command -v stow >/dev/null 2>&1; then
  echo "bootstrap-kitty.sh: required command not found: stow" >&2
  exit 69
fi

mkdir -p "${target_home}"
target_home="$(cd -- "${target_home}" && pwd -P)"

kitty_config_dir="${target_home}/.config/kitty"
expected_kitty_dir="$(cd -- "${dotfiles_root}/kitty/.config/kitty" && pwd -P)"
if [[ -L "${kitty_config_dir}" ]]; then
  linked_kitty_dir=""
  if linked_target="$(readlink "${kitty_config_dir}" 2>/dev/null)"; then
    case "${linked_target}" in
      /*) ;;
      *) linked_target="$(dirname "${kitty_config_dir}")/${linked_target}" ;;
    esac
    if [[ -d "${linked_target}" ]]; then
      linked_kitty_dir="$(cd -- "${linked_target}" && pwd -P)"
    fi
  fi
  if [[ "${linked_kitty_dir}" == "${expected_kitty_dir}" ]]; then
    # Older Stow runs may have folded the whole Kitty directory into one
    # symlink. Convert that exact, repository-owned link before applying the
    # file-level shared/overlay layout; unrelated links remain protected.
    unlink "${kitty_config_dir}"
  else
    echo "bootstrap-kitty.sh: refusing to replace unrelated ${kitty_config_dir}" >&2
    exit 65
  fi
fi

# Remove a previously selected overlay before applying the new one. Delete
# each package separately because Stow aborts a multi-package delete when one
# of the packages has never been linked. Stow only removes links it owns, so
# an unrelated user file remains protected.
stow \
  --dir="${dotfiles_root}" \
  --target="${target_home}" \
  --delete \
  --no-folding \
  kitty-linux >/dev/null 2>&1 || true
stow \
  --dir="${dotfiles_root}" \
  --target="${target_home}" \
  --delete \
  --no-folding \
  kitty-macos >/dev/null 2>&1 || true

stow \
  --dir="${dotfiles_root}" \
  --target="${target_home}" \
  --restow \
  --no-folding \
  kitty "kitty-${platform}"

echo "Linked shared Kitty configuration with the ${platform} overlay into ${target_home}/.config/kitty"
