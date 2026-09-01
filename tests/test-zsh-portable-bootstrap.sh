#!/usr/bin/env bash

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "usage: $0 [dotfiles-root]" >&2
  exit 64
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
dotfiles_root="${1:-$(cd -- "${script_dir}/.." && pwd -P)}"
bootstrap="${dotfiles_root}/scripts/bootstrap-zsh.sh"
tracked_zshrc="${dotfiles_root}/zsh/.zshrc"

for file in "${bootstrap}" "${tracked_zshrc}"; do
  if [[ ! -f "${file}" ]]; then
    echo "FAIL: missing file: ${file}" >&2
    exit 1
  fi
done

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/zsh-portable-bootstrap.XXXXXX")"
trap 'rm -rf "${tmp_dir}"' EXIT
target_home="${tmp_dir}/home"
mkdir -p "${target_home}"

"${bootstrap}" --home "${target_home}" --skip-install

if [[ ! "${tracked_zshrc}" -ef "${target_home}/.zshrc" ]]; then
  echo "FAIL: active .zshrc is not managed by the dotfiles tree" >&2
  exit 1
fi

zsh -n "${target_home}/.zshrc"

# Refreshing links after a pull must remain idempotent.
"${bootstrap}" --home "${target_home}" --skip-install

if [[ ! "${tracked_zshrc}" -ef "${target_home}/.zshrc" ]]; then
  echo "FAIL: second bootstrap did not preserve the managed link" >&2
  exit 1
fi

echo "PASS: Zsh dotfiles bootstrap is portable and idempotent"
