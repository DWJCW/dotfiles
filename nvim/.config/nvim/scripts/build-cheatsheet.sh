#!/bin/zsh
set -euo pipefail

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
html="$config_dir/LazyVim-Cheatsheet-iPadPro.html"
png="$config_dir/LazyVim-Cheatsheet-iPadPro.png"
png_11="$config_dir/LazyVim-Cheatsheet-iPadPro-11inch.png"

CHEATSHEET_AUDIT_PROCESS=1 nvim --headless -i NONE \
  --cmd 'let g:cheatsheet_audit_process=1' \
  -c "luafile $config_dir/scripts/cheatsheet-build.lua"

"$chrome" --headless=new --hide-scrollbars --disable-gpu \
  --force-device-scale-factor=1 --window-size=2420,1668 \
  --run-all-compositor-stages-before-draw --virtual-time-budget=1000 \
  --screenshot="$png" "file://$html"

cp "$png" "$png_11"
magick identify "$png"
