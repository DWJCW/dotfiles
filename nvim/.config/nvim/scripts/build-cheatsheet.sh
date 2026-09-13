#!/bin/zsh
set -euo pipefail

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
html="$config_dir/LazyVim-Cheatsheet-iPadPro.html"
png="$config_dir/LazyVim-Cheatsheet-iPadPro.png"
png_11="$config_dir/LazyVim-Cheatsheet-iPadPro-11inch.png"

find_browser() {
  local candidate candidate_path

  if [[ -n "${CHEATSHEET_BROWSER:-}" ]]; then
    if [[ "${CHEATSHEET_BROWSER}" == */* ]]; then
      [[ -x "${CHEATSHEET_BROWSER}" ]] && printf '%s\n' "${CHEATSHEET_BROWSER}"
    else
      command -v "${CHEATSHEET_BROWSER}" 2>/dev/null || true
    fi
    return 0
  fi

  for candidate in google-chrome google-chrome-stable chromium chromium-browser chrome; do
    if candidate_path="$(command -v "${candidate}" 2>/dev/null)"; then
      printf '%s\n' "${candidate_path}"
      return 0
    fi
  done
  return 0
}

browser="$(find_browser)"
if [[ -z "${browser}" ]]; then
  echo "build-cheatsheet.sh: Google Chrome or Chromium was not found on PATH" >&2
  echo "Set CHEATSHEET_BROWSER to an executable path or install a Chromium-based browser" >&2
  exit 69
fi

CHEATSHEET_AUDIT_PROCESS=1 nvim --headless -i NONE \
  --cmd 'let g:cheatsheet_audit_process=1' \
  -c "luafile $config_dir/scripts/cheatsheet-build.lua"

"$browser" --headless=new --hide-scrollbars --disable-gpu \
  --force-device-scale-factor=1 --window-size=2420,1668 \
  --run-all-compositor-stages-before-draw --virtual-time-budget=1000 \
  --screenshot="$png" "file://$html"

cp "$png" "$png_11"
magick identify "$png"

return 0
