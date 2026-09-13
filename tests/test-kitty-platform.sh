#!/usr/bin/env bash

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "usage: $0 [dotfiles-root]" >&2
  exit 64
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
dotfiles_root="${1:-$(cd -- "${script_dir}/.." && pwd -P)}"
bootstrap="${dotfiles_root}/scripts/bootstrap-kitty.sh"

if ! command -v stow >/dev/null 2>&1; then
  echo "SKIP: stow is required for Kitty overlay tests" >&2
  exit 0
fi

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/kitty-platform.XXXXXX")"
trap 'rm -rf "${tmp_dir}"' EXIT

DOTFILES_PLATFORM=linux "${bootstrap}" --home "${tmp_dir}/home"
linux_overlay="${tmp_dir}/home/.config/kitty/kitty-platform.conf"
if grep -q '^macos_option_as_alt' "${linux_overlay}"; then
  echo "FAIL: Linux Kitty overlay contains a macOS-only setting" >&2
  exit 1
fi

DOTFILES_PLATFORM=macos "${bootstrap}" --home "${tmp_dir}/home"
macos_overlay="${tmp_dir}/home/.config/kitty/kitty-platform.conf"
if ! grep -q '^macos_option_as_alt left$' "${macos_overlay}"; then
  echo "FAIL: macOS Kitty overlay did not enable Option-as-Alt" >&2
  exit 1
fi

DOTFILES_PLATFORM=linux "${bootstrap}" --home "${tmp_dir}/home"
if grep -q '^macos_option_as_alt' "${tmp_dir}/home/.config/kitty/kitty-platform.conf"; then
  echo "FAIL: switching back to Linux left the macOS Kitty overlay active" >&2
  exit 1
fi

echo "PASS: Kitty shared configuration selects the correct platform overlay"
