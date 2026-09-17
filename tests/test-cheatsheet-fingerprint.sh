#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(cd -- "${script_dir}/.." && pwd -P)"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/cheatsheet-fingerprint.XXXXXX")"
trap 'rm -rf "${tmp_dir}"' EXIT
for location in first second; do
  mkdir -p "${tmp_dir}/${location}"
  cp -R "${root}/nvim/.config/nvim" "${tmp_dir}/${location}/nvim"
done
fingerprint() {
  XDG_CONFIG_HOME="${tmp_dir}/$1" NVIM_APPNAME=nvim \
    nvim --clean --headless -u NONE -i NONE \
    --cmd "set rtp^=${tmp_dir}/$1/nvim" \
    '+lua local ok, result = pcall(function() return require("config.cheatsheet").fingerprint() end); if not ok then vim.api.nvim_err_writeln(result); vim.cmd("cquit 1") end; io.write(result)' +qa
}
first="$(fingerprint first)"
second="$(fingerprint second)"
[[ "$first" == "$second" ]] || { echo 'FAIL: fingerprint depends on configuration location'; exit 1; }
printf '\n-- fingerprint regression fixture\n' >> "${tmp_dir}/second/nvim/lua/config/options.lua"
changed="$(fingerprint second)"
[[ "$first" != "$changed" ]] || { echo 'FAIL: fingerprint ignores configuration changes'; exit 1; }
echo 'PASS: cheat-sheet fingerprint is portable and detects content changes'
