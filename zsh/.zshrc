# Keep personal commands available to Oh My Zsh and its plugins. Zsh's unique
# path array prevents duplicate entries when starting a nested shell.
typeset -U path PATH
path=("$HOME/.local/bin" $path)

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

# Oh My Zsh ships a macOS-only plugin. Resolve the same platform contract as
# the bootstrap scripts, while keeping Linux/WSL on the shared plugin set.
dotfiles_platform="${DOTFILES_PLATFORM:-auto}"
if [[ "${dotfiles_platform}" == "" ]]; then
  dotfiles_platform="auto"
fi
if [[ "${dotfiles_platform}" == "auto" ]]; then
  case "${OSTYPE:-}" in
    darwin*) dotfiles_platform="macos" ;;
    linux*) dotfiles_platform="linux" ;;
    *)
      print -u2 "dotfiles: cannot detect the operating system for zsh; set DOTFILES_PLATFORM=linux or macos"
      return 64
      ;;
  esac
elif [[ "${dotfiles_platform}" != "linux" && "${dotfiles_platform}" != "macos" ]]; then
  print -u2 "dotfiles: invalid DOTFILES_PLATFORM='${dotfiles_platform}'; expected auto, linux, or macos"
  return 64
fi

# A colorful built-in theme that works without a patched terminal font.
ZSH_THEME="robbyrussell"

# Check for updates occasionally, but leave installation under user control.
zstyle ':omz:update' mode reminder

plugins=(
  git
  colored-man-pages
)

if [[ "${dotfiles_platform}" == "macos" ]]; then
  plugins+=(macos)
fi
unset dotfiles_platform

source "$ZSH/oh-my-zsh.sh"
