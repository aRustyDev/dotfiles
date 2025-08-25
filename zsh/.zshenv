if command -v cargo; then . "$HOME/.cargo/env"; fi
if command -v go; then . "$(go env GOENV)"; fi

HOME_LIB=$HOME/.local/lib        # Source Code Libraries
HOME_PKG=$HOME/.local/pkg        # Managed User Local Packages
HOME_DATA=$HOME/.local/data      # Persistent Data
HOME_CACHE=$HOME/.local/cache    # Ephemeral Data
HOME_CONFIG=$HOME/.config        # Persistent Configs

ZDOTDIR=$HOME_CONFIG/zsh/                # Set ZSH Config Dir
HISTFILE=$HOME_CACHE/zsh/history         # Set History File Location for Zsh
SHELL_SESSION_DIR=$HOME_CACHE/sessions   # Set Session Storage Location for Zsh
