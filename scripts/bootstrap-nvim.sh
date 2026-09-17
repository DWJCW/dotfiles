#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
usage: bootstrap-nvim.sh [--home PATH] [--skip-restore] [--check-deps]

Install the complete tracked Neovim configuration with GNU Stow. By default,
LazyVim and every plugin are then installed/restored to lazy-lock.json.

Options:
  --home PATH       Stow target (default: the current user's home directory)
  --skip-restore    Link configuration only; do not start Neovim or fetch plugins
  --check-deps      Check core and optional dependencies, then exit
  -h, --help        Show this help
EOF
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
dotfiles_root="$(cd -- "${script_dir}/.." && pwd -P)"
target_home="${HOME}"
restore_plugins=1
check_deps=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --home)
      if [[ $# -lt 2 || -z "$2" ]]; then
        echo "bootstrap-nvim.sh: --home requires a path" >&2
        usage >&2
        exit 64
      fi
      target_home="$2"
      shift 2
      ;;
    --skip-restore)
      restore_plugins=0
      shift
      ;;
    --check-deps)
      check_deps=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "bootstrap-nvim.sh: unknown argument: $1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

# shellcheck source=platform.sh
if ! source "${script_dir}/platform.sh"; then
  echo "bootstrap-nvim.sh: failed to load the platform resolver" >&2
  exit 70
fi

if ! platform="$(dotfiles_resolve_platform)"; then
  exit 64
fi

missing_core=0
missing_optional=0

check_core_command() {
  local command_name="$1"
  if command -v "${command_name}" >/dev/null 2>&1; then
    echo "OK   core: ${command_name}"
  else
    echo "FAIL core: ${command_name} (required)" >&2
    missing_core=1
  fi
}

check_optional_command() {
  local label="$1"
  local command_name="$2"
  if command -v "${command_name}" >/dev/null 2>&1; then
    echo "OK   optional: ${label} (${command_name})"
  else
    echo "WARN optional: ${label} is unavailable (${command_name})" >&2
    missing_optional=1
  fi
}

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

skim_available() {
  if command -v skim >/dev/null 2>&1; then return 0; fi
  if [[ -d "${HOME}/Applications/Skim.app" || -d "/Applications/Skim.app" ]]; then return 0; fi
  if command -v osascript >/dev/null 2>&1 \
    && osascript -l JavaScript -e 'Application("Skim").id()' >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

check_pdf_viewer() {
  local candidate
  if [[ "${platform}" == "macos" ]]; then
    if skim_available; then
      echo "OK   optional: PDF viewer (Skim)"
    elif command -v open >/dev/null 2>&1; then
      echo "OK   optional: PDF viewer fallback (open); Skim is unavailable" >&2
      missing_optional=1
    else
      echo "WARN optional: no macOS PDF viewer (Skim or open)" >&2
      missing_optional=1
    fi
    return 0
  fi

  for candidate in zathura okular xdg-open; do
    if command -v "${candidate}" >/dev/null 2>&1; then
      echo "OK   optional: PDF viewer (${candidate})"
      return 0
    fi
  done
  echo "WARN optional: no Linux PDF viewer (tried zathura, okular, xdg-open)" >&2
  missing_optional=1
}

check_fonts() {
  local matched_font
  if command -v fc-match >/dev/null 2>&1; then
    matched_font="$(fc-match -f '%{family}\n' 'Noto Sans CJK SC' 2>/dev/null || true)"
    if [[ -n "${matched_font}" ]]; then
      echo "OK   optional: CJK font fallback (${matched_font%%$'\n'*})"
    else
      echo "WARN optional: no fontconfig CJK font match; cheat-sheet glyphs may fall back poorly" >&2
      missing_optional=1
    fi
  elif [[ "${platform}" == "macos" ]]; then
    echo "OK   optional: macOS system font fallback (fontconfig not required)"
  else
    echo "WARN optional: fc-match is unavailable; CJK font support was not checked" >&2
    missing_optional=1
  fi
}

check_compiler() {
  local compiler
  for compiler in cc gcc clang c++; do
    if command -v "${compiler}" >/dev/null 2>&1; then
      echo "OK   optional: C/C++ compiler (${compiler})"
      return 0
    fi
  done
  echo "WARN optional: no C/C++ compiler was found (Treesitter/CMake builds may fail)" >&2
  missing_optional=1
}

check_dependencies() {
  echo "Detected platform: ${platform}"
  check_core_command stow
  if [[ "${restore_plugins}" -eq 1 || "${check_deps}" -eq 1 ]]; then
    check_core_command git
    check_core_command nvim
    if command -v nvim >/dev/null 2>&1; then
      if ! nvim --clean --headless -u NONE -i NONE \
        '+if !has("nvim-0.12") | cquit 1 | endif' +qa; then
        echo "FAIL core: Neovim 0.12 or newer is required; check PATH (selected $(command -v nvim))" >&2
        missing_core=1
      fi
    fi
  fi

  check_pdf_viewer
  check_optional_command "fd for Python virtualenv selection" fd
  check_optional_command "lazygit" lazygit
  check_optional_command "ImageMagick" magick
  check_optional_command "Ghostscript for PDF previews" gs
  check_optional_command "XeLaTeX" xelatex
  check_optional_command "latexmk" latexmk
  check_optional_command "tree-sitter CLI" tree-sitter
  check_optional_command "CMake" cmake
  check_compiler
  check_fonts

  if [[ -n "$(find_browser)" ]]; then
    echo "OK   optional: Chrome/Chromium browser"
  else
    echo "WARN optional: Chrome/Chromium browser is unavailable (needed only to rebuild the cheat sheet)" >&2
    missing_optional=1
  fi

  if [[ "${missing_core}" -ne 0 || "${missing_optional}" -ne 0 ]]; then
    if [[ "${missing_core}" -ne 0 ]]; then
      echo "Required dependencies are missing; bootstrap cannot continue." >&2
    else
      echo "Optional features are incomplete; bootstrap will continue." >&2
    fi
    if [[ "${platform}" == "macos" ]]; then
      echo "Install suggestions (not executed): brew install neovim stow fd lazygit imagemagick ghostscript cmake tree-sitter; brew install --cask skim google-chrome" >&2
    else
      echo "Install suggestions (not executed): sudo apt install git neovim stow fd-find lazygit imagemagick ghostscript latexmk texlive-xetex cmake build-essential; or use the equivalent pacman packages." >&2
    fi
  fi

  [[ "${missing_core}" -eq 0 ]]
}

if ! check_dependencies; then
  echo "bootstrap-nvim.sh: one or more core dependencies are missing" >&2
  exit 69
fi

if [[ "${check_deps}" -eq 1 ]]; then
  echo "Dependency check complete; no packages were installed."
  exit 0
fi

mkdir -p "${target_home}"
target_home="$(cd -- "${target_home}" && pwd -P)"

stow \
  --dir="${dotfiles_root}" \
  --target="${target_home}" \
  --restow \
  --no-folding \
  nvim

echo "Linked the complete Neovim configuration into ${target_home}/.config/nvim"

if [[ "${restore_plugins}" -eq 0 ]]; then
  echo "Skipped plugin restore"
  exit 0
fi

mkdir -p \
  "${target_home}/.local/share" \
  "${target_home}/.local/state" \
  "${target_home}/.cache"

lockfile="${target_home}/.config/nvim/lazy-lock.json"
lazy_root="${target_home}/.local/share/nvim/lazy"
lazy_path="${lazy_root}/lazy.nvim"
lazyvim_path="${lazy_root}/LazyVim"
lazy_commit="$(
  NVIM_LOCKFILE="${lockfile}" \
  NVIM_LAZY_PLUGIN=lazy.nvim \
    nvim --clean --headless -l "${script_dir}/read-lazy-lock-commit.lua"
)"
lazyvim_commit="$(
  NVIM_LOCKFILE="${lockfile}" \
  NVIM_LAZY_PLUGIN=LazyVim \
    nvim --clean --headless -l "${script_dir}/read-lazy-lock-commit.lua"
)"

mkdir -p "${lazy_root}"
if [[ ! -d "${lazy_path}/.git" ]]; then
  if [[ -e "${lazy_path}" ]]; then
    echo "bootstrap-nvim.sh: ${lazy_path} exists but is not a Git checkout" >&2
    exit 65
  fi
  git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "${lazy_path}"
fi

if ! git -C "${lazy_path}" cat-file -e "${lazy_commit}^{commit}" 2>/dev/null; then
  git -C "${lazy_path}" fetch --filter=blob:none origin "${lazy_commit}"
fi
git -C "${lazy_path}" checkout --detach "${lazy_commit}"

# LazyVim owns most imported plugin specs. Restore it before Neovim starts so
# lazy.nvim sees the complete spec on its first install pass and cannot prune
# unseen entries from the lockfile.
if [[ ! -d "${lazyvim_path}/.git" ]]; then
  if [[ -e "${lazyvim_path}" ]]; then
    echo "bootstrap-nvim.sh: ${lazyvim_path} exists but is not a Git checkout" >&2
    exit 65
  fi
  git clone --filter=blob:none https://github.com/LazyVim/LazyVim.git "${lazyvim_path}"
fi

if ! git -C "${lazyvim_path}" cat-file -e "${lazyvim_commit}^{commit}" 2>/dev/null; then
  git -C "${lazyvim_path}" fetch --filter=blob:none origin "${lazyvim_commit}"
fi
git -C "${lazyvim_path}" checkout --detach "${lazyvim_commit}"

env \
  HOME="${target_home}" \
  XDG_CONFIG_HOME="${target_home}/.config" \
  XDG_DATA_HOME="${target_home}/.local/share" \
  XDG_STATE_HOME="${target_home}/.local/state" \
  XDG_CACHE_HOME="${target_home}/.cache" \
  NVIM_APPNAME=nvim \
  DOTFILES_PLATFORM="${platform}" \
  NVIM_DOTFILES_ROOT="${dotfiles_root}" \
  nvim --headless \
    "+Lazy! restore" \
    "+lua dofile(assert(os.getenv('NVIM_DOTFILES_ROOT')) .. '/scripts/bootstrap-mason.lua')" \
    "+lua dofile(assert(os.getenv('NVIM_DOTFILES_ROOT')) .. '/scripts/bootstrap-treesitter.lua')" \
    "+if v:errmsg !=# '' | cquit 1 | endif" \
    "+qa"

echo "Restored locked plugins, Mason tools, and Treesitter parsers without changing the lockfile"
