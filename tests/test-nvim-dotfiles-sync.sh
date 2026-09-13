#!/usr/bin/env bash

set -euo pipefail

if [[ $# -gt 2 ]]; then
  echo "usage: $0 [dotfiles-root] [active-nvim-config]" >&2
  exit 64
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
dotfiles_root="${1:-$(cd -- "${script_dir}/.." && pwd -P)}"
active_config="${2:-${HOME}/.config/nvim}"
tracked_config="${dotfiles_root}/nvim/.config/nvim"

for directory in "${tracked_config}" "${active_config}"; do
  if [[ ! -d "${directory}" ]]; then
    echo "missing configuration directory: ${directory}" >&2
    exit 66
  fi
done

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/nvim-dotfiles-sync.XXXXXX")"
trap 'rm -rf "${tmp_dir}"' EXIT

manifest() {
  local root="$1"
  (
    cd "${root}"
    find -L . -type f -print \
      | LC_ALL=C sort \
      | while IFS= read -r path; do
          shasum -a 256 "${path}"
        done
  )
}

manifest "${tracked_config}" > "${tmp_dir}/tracked.sha256"
manifest "${active_config}" > "${tmp_dir}/active.sha256"

if ! diff -u "${tmp_dir}/tracked.sha256" "${tmp_dir}/active.sha256"; then
  echo "FAIL: tracked and active Neovim configurations differ" >&2
  exit 1
fi

while IFS= read -r -d '' tracked_file; do
  relative_path="${tracked_file#${tracked_config}/}"
  active_file="${active_config}/${relative_path}"

  if [[ ! -e "${active_file}" ]]; then
    echo "FAIL: active configuration is missing ${relative_path}" >&2
    exit 1
  fi

  if [[ ! "${tracked_file}" -ef "${active_file}" ]]; then
    echo "FAIL: ${relative_path} is not managed by the dotfiles tree" >&2
    exit 1
  fi
done < <(find -L "${tracked_config}" -type f -print0)

echo "PASS: active Neovim configuration exactly matches and is managed by dotfiles"
