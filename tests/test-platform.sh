#!/usr/bin/env bash

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "usage: $0 [dotfiles-root]" >&2
  exit 64
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
dotfiles_root="${1:-$(cd -- "${script_dir}/.." && pwd -P)}"
config_dir="${dotfiles_root}/nvim/.config/nvim"
nvim_bin="$(command -v nvim || true)"

if [[ -z "${nvim_bin}" ]]; then
  echo "FAIL: nvim is required for platform tests" >&2
  exit 69
fi

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-platform.XXXXXX")"
trap 'rm -rf "${tmp_dir}"' EXIT

make_command() {
  local directory="$1"
  local command_name="$2"
  mkdir -p "${directory}"
  printf '#!/bin/sh\nexit 0\n' > "${directory}/${command_name}"
  chmod +x "${directory}/${command_name}"
}

run_lua() {
  local platform="$1"
  local path="$2"
  local code="$3"
  DOTFILES_PLATFORM="${platform}" PATH="${path}" "${nvim_bin}" \
    --clean --headless -u NONE \
    --cmd "set rtp^=${config_dir}" \
    -c "lua local ok, err = xpcall(function() vim.fn.isdirectory = function() return 0 end; ${code} end, debug.traceback); if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit 1') end" \
    -c 'qa!'
}

linux_bin="${tmp_dir}/linux-bin"
make_command "${linux_bin}" zathura
make_command "${linux_bin}" okular
make_command "${linux_bin}" xdg-open
run_lua linux "${linux_bin}" \
  "local p=require('config.platform'); assert(p.name == 'linux'); assert(p.pdf_viewer().id == 'zathura')"
rm -f "${linux_bin}/zathura"
run_lua linux "${linux_bin}" \
  "local p=require('config.platform'); assert(p.pdf_viewer().id == 'okular')"
rm -f "${linux_bin}/okular"
run_lua linux "${linux_bin}" \
  "local p=require('config.platform'); assert(p.pdf_viewer().id == 'xdg-open')"
rm -f "${linux_bin}/xdg-open"
run_lua linux "${linux_bin}" \
  "local p=require('config.platform'); assert(p.pdf_viewer().id == 'none'); assert(not p.skim_available())"

defaults_marker="${tmp_dir}/defaults-called"
printf '#!/bin/sh\n: > "${DOTFILES_TEST_DEFAULTS_MARKER}"\n' > "${linux_bin}/defaults"
chmod +x "${linux_bin}/defaults"
export DOTFILES_TEST_DEFAULTS_MARKER="${defaults_marker}"
run_lua linux "${linux_bin}" \
  "local p=require('config.platform'); local result=p.skim_inverse_search(); assert(result.ok); assert(not result.applicable)"
if [[ -e "${defaults_marker}" ]]; then
  echo "FAIL: Linux platform capability invoked defaults" >&2
  exit 1
fi

macos_bin="${tmp_dir}/macos-bin"
make_command "${macos_bin}" skim
run_lua macos "${macos_bin}" \
  "local p=require('config.platform'); assert(p.name == 'macos'); assert(p.skim_available()); assert(p.pdf_viewer().id == 'skim'); local s=dofile('${config_dir}/lua/plugins/workflow.lua'); s[7].init(); assert(vim.g.vimtex_view_method == 'skim')"
rm -f "${macos_bin}/skim"
run_lua macos "${macos_bin}" \
  "local p=require('config.platform'); assert(not p.skim_available()); assert(p.pdf_viewer().id == 'none'); local s=dofile('${config_dir}/lua/plugins/workflow.lua'); s[7].init(); assert(vim.g.vimtex_view_method == 'general')"

case "$(uname -s 2>/dev/null || true)" in
  Linux)
    run_lua auto "${linux_bin}" "local p=require('config.platform'); assert(p.name == 'linux')"
    ;;
  Darwin)
    run_lua auto "${macos_bin}" "local p=require('config.platform'); assert(p.name == 'macos')"
    ;;
esac

invalid_output="$(DOTFILES_PLATFORM=windows PATH="${tmp_dir}" "${nvim_bin}" \
  --clean --headless -u NONE \
  --cmd "set rtp^=${config_dir}" \
  -c "lua require('config.platform')" \
  -c 'qa!' 2>&1 || true)"
if [[ "${invalid_output}" != *"invalid DOTFILES_PLATFORM"* ]]; then
  echo "FAIL: invalid DOTFILES_PLATFORM was not reported" >&2
  printf '%s\n' "${invalid_output}" >&2
  exit 1
fi

if DOTFILES_PLATFORM=windows PATH="${tmp_dir}" "${nvim_bin}" \
  --clean --headless -u "${config_dir}/init.lua" -c 'qa!' \
  >/dev/null 2>&1; then
  echo "FAIL: invalid DOTFILES_PLATFORM did not fail Neovim startup" >&2
  exit 1
fi

echo "PASS: Linux/macOS platform overrides and PDF viewer fallback are valid"
