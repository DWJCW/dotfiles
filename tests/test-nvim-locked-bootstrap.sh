#!/usr/bin/env bash

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "usage: $0 [dotfiles-root]" >&2
  exit 64
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
dotfiles_root="${1:-$(cd -- "${script_dir}/.." && pwd -P)}"

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/nvim-locked-bootstrap.XXXXXX")"
trap 'rm -rf "${tmp_dir}"' EXIT
fixture_root="${tmp_dir}/dotfiles"
target_home="${tmp_dir}/home"

# Lazy may rewrite its lockfile after an install. Test against an isolated copy
# so a failed integration test can never alter the developer's working tree.
mkdir -p "${fixture_root}" "${target_home}"
cp -R \
  "${dotfiles_root}/nvim" \
  "${dotfiles_root}/scripts" \
  "${dotfiles_root}/tests" \
  "${fixture_root}/"

"${fixture_root}/scripts/bootstrap-nvim.sh" --home "${target_home}"

if ! cmp -s \
  "${dotfiles_root}/nvim/.config/nvim/lazy-lock.json" \
  "${fixture_root}/nvim/.config/nvim/lazy-lock.json"; then
  echo "FAIL: clean bootstrap changed lazy-lock.json" >&2
  exit 1
fi

NVIM_LOCKFILE="${target_home}/.config/nvim/lazy-lock.json" \
NVIM_LAZY_ROOT="${target_home}/.local/share/nvim/lazy" \
  nvim --clean --headless -l "${fixture_root}/tests/validate-installed-lazy-lock.lua"

env \
  HOME="${target_home}" \
  XDG_CONFIG_HOME="${target_home}/.config" \
  XDG_DATA_HOME="${target_home}/.local/share" \
  XDG_STATE_HOME="${target_home}/.local/state" \
  XDG_CACHE_HOME="${target_home}/.cache" \
  NVIM_APPNAME=nvim \
  NVIM_DOTFILES_ROOT="${fixture_root}" \
  nvim --headless \
    "+lua assert(require('lazy.core.config').plugins.LazyVim, 'LazyVim spec is missing')" \
    "+lua assert(vim.g.colors_name == 'tokyonight-moon', 'unexpected colorscheme: ' .. tostring(vim.g.colors_name))" \
    "+lua dofile(assert(os.getenv('NVIM_DOTFILES_ROOT')) .. '/tests/validate-installed-mason.lua')" \
    "+lua dofile(assert(os.getenv('NVIM_DOTFILES_ROOT')) .. '/tests/validate-installed-treesitter.lua')" \
    "+qa"

"${fixture_root}/tests/test-nvim-dotfiles-sync.sh" \
  "${fixture_root}" \
  "${target_home}/.config/nvim"

echo "PASS: clean bootstrap preserves the lock and restores all plugins, tools, and parsers"
