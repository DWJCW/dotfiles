# Keep personal commands available to Oh My Zsh and its plugins. Zsh's unique
# path array prevents duplicate entries when starting a nested shell.
typeset -U path PATH
path=("$HOME/.local/bin" $path)

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

# A colorful built-in theme that works without a patched terminal font.
ZSH_THEME="robbyrussell"

# Check for updates occasionally, but leave installation under user control.
zstyle ':omz:update' mode reminder

plugins=(
  git
  macos
  colored-man-pages
)

source "$ZSH/oh-my-zsh.sh"
