#!/usr/bin/env bash

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "usage: $0 [dotfiles-root]" >&2
  exit 64
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
dotfiles_root="${1:-$(cd -- "${script_dir}/.." && pwd -P)}"
bootstrap="${dotfiles_root}/scripts/bootstrap-nvim.sh"
tracked_config="${dotfiles_root}/nvim/.config/nvim"

if [[ ! -x "${bootstrap}" ]]; then
  echo "FAIL: missing executable bootstrap: ${bootstrap}" >&2
  exit 1
fi

required_cheatsheet_files=(
  "CHEATSHEET.zh-CN.md"
  "CHEATSHEET-AUDIT.md"
  "cheatsheet-audit.json"
  "LazyVim-Cheatsheet-iPadPro.html"
  "LazyVim-Cheatsheet-iPadPro.png"
  "LazyVim-Cheatsheet-iPadPro-11inch.html"
  "LazyVim-Cheatsheet-iPadPro-11inch.png"
  "lua/config/cheatsheet.lua"
  "scripts/build-cheatsheet.sh"
  "scripts/cheatsheet-audit.lua"
  "scripts/cheatsheet-build.lua"
  "templates/cheatsheet-ipad.html"
)

for relative_path in "${required_cheatsheet_files[@]}"; do
  if [[ ! -f "${tracked_config}/${relative_path}" ]]; then
    echo "FAIL: cheat sheet file is not tracked in the nvim package: ${relative_path}" >&2
    exit 1
  fi
done

if find "${tracked_config}" -type l -print -quit | grep -q .; then
  echo "FAIL: the tracked nvim package contains a machine-specific symlink" >&2
  exit 1
fi

if command -v rg >/dev/null 2>&1; then
  machine_path_matches="$(rg --hidden '/Users/[^/]+|/home/[^/]+' "${tracked_config}" || true)"
else
  machine_path_matches="$(
    find "${tracked_config}" -type f \
      \( -name '*.lua' -o -name '*.json' -o -name '*.md' -o -name '*.sh' -o -name '*.toml' -o -name '*.html' \) \
      -exec grep -E '/Users/[^/]+|/home/[^/]+' {} + || true
  )"
fi

if [[ -n "${machine_path_matches}" ]]; then
  echo "FAIL: the tracked nvim package contains a machine-specific home path" >&2
  exit 1
fi

NVIM_LOCKFILE="${tracked_config}/lazy-lock.json" nvim --clean --headless -l "${script_dir}/validate-lazy-lock.lua"

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/nvim-portable-bootstrap.XXXXXX")"
trap 'rm -rf "${tmp_dir}"' EXIT
target_home="${tmp_dir}/home"
mkdir -p "${target_home}"

"${bootstrap}" --home "${target_home}" --skip-restore
"${dotfiles_root}/tests/test-nvim-dotfiles-sync.sh" "${dotfiles_root}" "${target_home}/.config/nvim"

# A bootstrap must be safe to rerun while refreshing links after a pull.
"${bootstrap}" --home "${target_home}" --skip-restore
"${dotfiles_root}/tests/test-nvim-dotfiles-sync.sh" "${dotfiles_root}" "${target_home}/.config/nvim"

echo "PASS: Neovim dotfiles bootstrap is complete, portable, and idempotent"
