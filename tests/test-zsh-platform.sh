#!/usr/bin/env bash

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "usage: $0 [dotfiles-root]" >&2
  exit 64
fi

if ! command -v zsh >/dev/null 2>&1; then
  echo "SKIP: zsh is required for zsh platform tests" >&2
  exit 0
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
dotfiles_root="${1:-$(cd -- "${script_dir}/.." && pwd -P)}"
zshrc="${dotfiles_root}/zsh/.zshrc"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/zsh-platform.XXXXXX")"
trap 'rm -rf "${tmp_dir}"' EXIT

mkdir -p "${tmp_dir}/oh-my-zsh"
printf 'print -r -- "${(j:,:)plugins}" > "${DOTFILES_ZSH_TEST_OUTPUT}"\n' \
  > "${tmp_dir}/oh-my-zsh/oh-my-zsh.sh"

run_zsh() {
  local platform="$1"
  local output_path="${tmp_dir}/${platform}.plugins"
  DOTFILES_PLATFORM="${platform}" \
  DOTFILES_ZSH_TEST_OUTPUT="${output_path}" \
  ZSH="${tmp_dir}/oh-my-zsh" \
    zsh -f -c "source '${zshrc}'"
  cat "${output_path}"
}

linux_plugins="$(run_zsh linux)"
if [[ "${linux_plugins}" == *macos* ]]; then
  echo "FAIL: Linux zsh configuration loaded the macos plugin" >&2
  exit 1
fi

macos_plugins="$(run_zsh macos)"
if [[ "${macos_plugins}" != *macos* ]]; then
  echo "FAIL: macOS zsh configuration did not load the macos plugin" >&2
  exit 1
fi

invalid_output="$(DOTFILES_PLATFORM=windows ZSH="${tmp_dir}/oh-my-zsh" zsh -f -c "source '${zshrc}'" 2>&1 || true)"
if [[ "${invalid_output}" != *"invalid DOTFILES_PLATFORM"* ]]; then
  echo "FAIL: invalid zsh DOTFILES_PLATFORM was not reported" >&2
  printf '%s\n' "${invalid_output}" >&2
  exit 1
fi

echo "PASS: zsh loads the macos plugin only for macOS"
