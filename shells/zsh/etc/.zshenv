# XDG Configs
export XDG_DATA_HOME="$HOME/.local/share"  # Desc:
export XDG_CONFIG_HOME="$HOME/.config"     # Desc:
export XDG_STATE_HOME="$HOME/.local/state" # Desc:
export XDG_CACHE_HOME="$HOME/.local/cache" # Desc:
export XDG_BIN_HOME="$HOME/.local/bin"     # Desc:
export XDG_DESKTOP_DIR="$HOME/Desktop"     # Desc:
export XDG_DOCUMENTS_DIR="$HOME/Documents" # Desc:
export XDG_DOWNLOAD_DIR="$HOME/Downloads"  # Desc:

export ZDOTDIR=${XDG_CONFIG_HOME:-$HOME/.config}/zsh                           # Set ZSH Config Dir
export ZENV="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zshenv"
export SHELL_SESSION_DIR="${XDG_CACHE_HOME:-$HOME/.local/cache}/zsh/sessions"  # Set Session Storage Location for Zsh
