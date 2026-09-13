#!/usr/bin/env bash

# Shared platform resolver for bootstrap scripts.
#
# The Neovim platform module implements the same contract for Lua callers.
# Keep this file side-effect free when sourced: callers decide what to do with
# the resolved platform and whether to print diagnostics.

dotfiles_resolve_platform() {
  local requested="${DOTFILES_PLATFORM:-auto}"

  case "${requested}" in
    ""|auto)
      local system_name
      if ! system_name="$(uname -s 2>/dev/null)"; then
        echo "dotfiles: cannot detect the operating system; set DOTFILES_PLATFORM=linux or macos" >&2
        return 64
      fi
      case "${system_name}" in
        Linux)
          printf '%s\n' linux
          ;;
        Darwin)
          printf '%s\n' macos
          ;;
        *)
          echo "dotfiles: unsupported operating system '${system_name}'; only Linux and macOS are supported" >&2
          return 64
          ;;
      esac
      ;;
    linux|macos)
      printf '%s\n' "${requested}"
      ;;
    *)
      echo "dotfiles: invalid DOTFILES_PLATFORM='${requested}'; expected auto, linux, or macos" >&2
      return 64
      ;;
  esac
}
