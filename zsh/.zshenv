# shellcheck disable=SC2034
# export ZSH_TRACE_FILE="/tmp/zsh-trace-$$"
# echo "=== ZSH Startup Trace $(date) ===" > $ZSH_TRACE_FILE
# set -x
# exec 2>>$ZSH_TRACE_FILE

# Standard Configs
export LANG='en_US.UTF-8'
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
export GPG_TTY=$(tty)
# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#     export EDITOR='nvim'
#     export VISUAL='nvim'
# else
#     export EDITOR="nvim"
#     export VISUAL="/Applications/Zed.app/Contents/MacOS/cli -n --wait"
# fi
export PAGER="most"
export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"
export TERM="xterm-256color"
export ARCHFLAGS="-arch x86_64"

export TmpDir=$(realpath "${(Q)$(mktemp -d)}")

# module_path # Specifies the directories to search for Zsh modules.
# fpath # Specifies the directories to search for Zsh function files.

# XDG Configs
export XDG_DATA_HOME="$HOME/.local/share"  # Desc:
export XDG_CONFIG_HOME="$HOME/.config"     # Desc:
export XDG_STATE_HOME="$HOME/.local/state" # Desc:
export XDG_CACHE_HOME="$HOME/.local/cache" # Desc:
export XDG_BIN_HOME="$HOME/.local/bin"     # Desc:
export XDG_DESKTOP_DIR="$HOME/Desktop"     # Desc:
export XDG_DOCUMENTS_DIR="$HOME/Documents" # Desc:
export XDG_DOWNLOAD_DIR="$HOME/Downloads"  # Desc:
# export XDG_RUNTIME_DIR

# export XDG_DATA_DIRS
# export XDG_CONFIG_DIRS

# History options should be set in .zshrc and after oh-my-zsh sourcing.
# See https://github.com/nix-community/home-manager/issues/177.
# History Configs
export HISTSIZE='10000'
export SAVEHIST='10000'
export HIST_STAMPS="mm/dd/yyyy" # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
export HISTFILE=${XDG_CACHE_HOME:-$HOME/.local/cache}/zsh/history              # Set History File Location for Zsh

# === === === === === === === === === === === === === === === === === === === === ===
# ||   MacOS Configs                                                               ||
# === === === === === === === === === === === === === === === === === === === === ===

# https://superuser.com/questions/82123/mac-whats-cfusertextencoding-for
# https://apple.stackexchange.com/questions/308744/safe-to-remove-rnd-and-cfusertextencoding
# __CF_USER_TEXT_ENCODING=

# === === === === === === === === === === === === === === === === === === === === ===
# ||   Shell Configs                                                               ||
# === === === === === === === === === === === === === === === === === === === === ===

# --- [ Zsh ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
export ANTIDOTE_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins"
export ZCOMPDUMP="${XDG_CACHE_HOME:-$HOME/.local/cache}/zsh/compdump"
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"                         # Set ZSH Config Dir
export ZSH_COMPDUMP="$ZCOMPDUMP"
export ZSH_DOTDIR="$ZDOTDIR"                                                   # Set ZSH Config Dir
export ZSH_COMPLETE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/completions"
export ZSH_ENV="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zshenv"
export ZSH_FUNCS="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/functions"
export ZSH_PLUGINS="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins"
export ZSH_DISABLE_COMPFIX='true'
export ZSH_EVALCACHE_DIR="${XDG_CACHE_HOME:-$HOME/.local/cache}/zsh/evalcache"
export SHELL_SESSION_DIR="${XDG_CACHE_HOME:-$HOME/.local/cache}/zsh/sessions"  # Set Session Storage Location for Zsh

# --- [ ShEnv ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# export SHENV_VERSION
export SHENV_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/shenv"
# export SHENV_DEBUG
# export SHENV_HOOK_PATH
# export SHENV_DIR
# export SHELL_BUILD_ARIA2_OPTS

# === === === === === === === === === === === === === === === === === === === === ===
# ||   PATH Configs                                                                ||
# === === === === === === === === === === === === === === === === === === === === ===

# Managed by path_master (custom rewrite of /usr/libexec/path_helper)
export MANPATH='/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/opt/homebrew/Cellar/antidote/1.9.10/share/antidote/man:/usr/local/man:/usr/share/man:/usr/local/share/man:/Applications/Ghostty.app/Contents/Resources/man:'
# MANPATH="/usr/local/man:$MANPATH"
export XDG_CONFIG_DIRS=${XDG_CONFIG_PATH:-""} # Persistent Configs
export XDG_DATA_DIRS=${XDG_DATA_PATH:-""}     # Persistent Data

# === === === === === === === === === === === === === === === === === === === === ===
# ||   Tool Configs                                                                ||
# === === === === === === === === === === === === === === === === === === === === ===

# Convenience Envs
export HOME_CACHE=$XDG_CACHE_HOME # Ephemeral Data
export HOME_CONFIG=$XDG_CONFIG_HOME
export HOME_DATA=$XDG_DATA_HOME
export HOME_LIB="$HOME/.local/lib" # Source Code Libraries
export HOME_PKG="$HOME/.local/pkg" # Managed User Local Packages
export THEMES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/themes"

# === === === === === === === === === === === === === === === === === === === === ===
# ||   Tool Configs                                                                ||
# === === === === === === === === === === === === === === === === === === === === ===

# --- [ 1PW ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export OP_SIGN="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
export OP_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/op"
export OP_AGENT_TOML="${XDG_CONFIG_HOME:-$HOME/.config}/1Password/ssh/agent.toml"

# --- [ Ansible ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export ANSIBLE_CONFIG="$XDG_CONFIG_HOME/ansible/config.ini"

# --- [ Atuin ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export ATUIN_CONFIG_DIR="$XDG_CONFIG_HOME/atuin"
export ATUIN_THEME_DIR="$THEMES_DIR/atuin"

# --- [ Bat ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export BAT_PAGER=$PAGER
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/bat/config"
export BAT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bat"

# --- [ CARGO ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export CARGO_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/cargo"
export CARGO_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/cargo"
export CARGO_BIN="${XDG_BIN_HOME:-$HOME/.local/bin}/cargo"
export CARGO_CACHE="${XDG_CACHE_HOME:-$HOME/.local/cache}/cargo"
export CARGO_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/cargo"
# export RUSTUP_LOG=INFO # [ERROR, WARN, INFO, DEBUG, TRACE]
# export RUSTUP_TERM_COLOR
# export RUSTUP_AUTO_INSTALL=1

# --- [ Cloud: AWS ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export AWS_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/cloud/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/cloud/aws/creds"
export AWS_DATA_PATH="${XDG_DATA_HOME:-$HOME/.config}/cloud/aws"
if [[ $(hostname) == "ADAMSM-M-7L95" ]]; then
    export AWS_DEFAULT_REGION="us-east-1"
    export AWS_PROFILE="c4p-ite-devops-admin"
else
    export AWS_DEFAULT_REGION="us-gov-west-1"
fi
export EKSCTL_ENABLE_CREDENTIAL_CACHE=1

# --- [ Ghostty ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export GHOSTTY_RESOURCES_DIR="/Applications/Ghostty.app/Contents/Resources/ghostty"

# --- [ GIT ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export GIT_CONFIG_GLOBAL="${XDG_CONFIG_HOME:-$HOME/.config}/git/config" # path to the global (per-user) configuration file
# GIT_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/git/config" # Should only be set for --local
# export GIT_CONFIG_SYSTEM= # path to the system-level configuration file
# export GIT_CONFIG_NOSYSTEM= # disables the use of the system-wide configuration file
# export GIT_DIR= # The location of the .git folder.
export GIT_EDITOR=$EDITOR # The editor Git will launch for commit messages, etc.
export GIT_PAGER=$PAGER # The pager used for multi-page output.
# export GIT_EXEC_PATH= # Where Git looks for its sub-programs.

# --- [ GO ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
export GOBIN="${XDG_BIN_HOME:-$HOME/.local/bin}/go/bin"
# export GOCACHE='$HOME/Library/Caches/go-build'
# export GOENV='$HOME/Library/Application Support/go/env'
# export GOMODCACHE='$HOME/go/pkg/mod'
export GOPATH="${XDG_CONFIG_HOME:-$HOME/.config}/go"
# export GOROOT='/opt/homebrew/Cellar/go/1.24.6/libexec'
# export GOTELEMETRY='local'
# export GOTELEMETRYDIR='$HOME/Library/Application Support/go/telemetry'
# export GOTMPDIR=''
# export GOTOOLDIR='/opt/homebrew/Cellar/go/1.24.6/libexec/pkg/tool/darwin_arm64'
# export GOVCS=''
# export GOWORK=''
# export PKG_CONFIG='pkg-config'

# --- [ Kube: Configs ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export KUBECONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/kube/config"
export KUBE_EDITOR=$EDITOR

# --- [ Kube: Plugins ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# export KREW_DEFAULT_INDEX_URI="git@github.com:foo/custom-index.git"
export KREW_ROOT="${XDG_BIN_HOME:-$HOME/.local/bin}/krew/bin"
export KREW_NO_UPGRADE_CHECK=0

# --- [ NODE: Volta ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export VOLTA_HOME=$XDG_CONFIG_HOME/volta
export VOLTA_FEATURE_PNPM=1

# --- [ PyEnv ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export PYENV_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/pyenv"
export PYENV_SHELL=zsh

# --- [ RipGrep ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/ripgrep/config"

# --- [ SSH: Teleport ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# export TELEPORT_DOMAIN=teleport.example.com:443
# export TELEPORT_VERSION="$(curl -s https://$TELEPORT_DOMAIN/v1/webapi/find | jq -r '.server_version')"

# --- [ Starship ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/config.toml"
export STARSHIP_CACHE="${XDG_CACHE_HOME:-$HOME/.local/cache}/starship/cache"

# --- [ Stow ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# export STOW_DIR=$HOME

# --- [ TLDR ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# export CUSTOM_PAGES_DIR # https://tealdeer-rs.github.io/tealdeer/usage_custom_pages.html#custom-pages

# --- [ Vault ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# export VAULT_HTTP_PROXY
# export VAULT_PROXY_ADDR
# export VAULT_REDIRECT_ADDR
# export VAULT_TLS_SERVER_NAME
# export VAULT_TOKEN
# export VAULT_WRAP_TTL
# export VAULT_CLUSTER_ADDR
# export VAULT_CLIENT_KEY
# export VAULT_CLIENT_CERT
# export VAULT_CAPATH
# export VAULT_CACERT
# export VAULT_AGENT_ADDR
# export VAULT_ADDR
# export VAULT_LOG_FORMAT
# export VAULT_LOG_LEVEL
# export VAULT_MFA
# export VAULT_NAMESPACE

# --- [ Vim: Neovim ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# export NVIM_LOG_FILE=$XDG_CACHE_HOME/nvim/log
# export VIM=$XDG_DATA_HOME/nvim
# export VIMRUNTIME=$XDG_RUNTIME_DIR/nvim

# --- [ Yazi ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export YAZI_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/yazi"
# ~/.local/state/yazi/yazi.log
# export YAZI_LOG

# --- [ Zoxide ] --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export _ZO_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zoxide"
# export _ZO_EXCLUDE_DIRS
