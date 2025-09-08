# shellcheck disable=SC2034
# export ZSH_TRACE_FILE="/tmp/zsh-trace-$$"
# echo "=== ZSH Startup Trace $(date) ===" > $ZSH_TRACE_FILE
# set -x
# exec 2>>$ZSH_TRACE_FILE

# Standard Configs
LANG='en_US.UTF-8'
SSH_AUTH_SOCK="$HOME/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock"
GPG_TTY=$(tty)
# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    EDITOR='nvim'
    VISUAL='nvim'
else
    EDITOR="/Applications/Zed.app/Contents/MacOS/cli -n --wait"
    VISUAL='zed'
fi
PAGER=""
MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"
TERM="xterm-256color"
ARCHFLAGS="-arch x86_64"

TmpDir=$(realpath "${(Q)$(mktemp -d)}")

# module_path # Specifies the directories to search for Zsh modules.
# fpath # Specifies the directories to search for Zsh function files.

# XDG Configs
XDG_DATA_HOME="$HOME/.local/share"  # Desc:
XDG_CONFIG_HOME="$HOME/.config"     # Desc:
XDG_STATE_HOME="$HOME/.local/state" # Desc:
XDG_CACHE_HOME="$HOME/.local/cache" # Desc:
XDG_BIN_HOME="$HOME/.local/bin"     # Desc:
XDG_DESKTOP_DIR="$HOME/Desktop"     # Desc:
XDG_DOCUMENTS_DIR="$HOME/Documents" # Desc:
XDG_DOWNLOAD_DIR="$HOME/Downloads"  # Desc:
# XDG_RUNTIME_DIR

# XDG_DATA_DIRS
# XDG_CONFIG_DIRS

# History options should be set in .zshrc and after oh-my-zsh sourcing.
# See https://github.com/nix-community/home-manager/issues/177.
# History Configs
HISTSIZE='10000'
SAVEHIST='10000'
HIST_STAMPS="mm/dd/yyyy" # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HISTFILE=${XDG_CACHE_HOME:-$HOME/.local/cache}/zsh/history              # Set History File Location for Zsh

# ZSH Configs
ANTIDOTE_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins"
ZCOMPDUMP="${XDG_CACHE_HOME:-$HOME/.local/cache}/zsh/compdump"
ZCOMPLETE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/completions"
ZDOTDIR=${XDG_CONFIG_HOME:-$HOME/.config}/zsh                           # Set ZSH Config Dir
ZENV="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zshenv"
ZFUNCS="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/functions"
ZPLUGINS="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins"
ZSH_DISABLE_COMPFIX='true'
ZSH_EVALCACHE_DIR="${XDG_CACHE_HOME:-$HOME/.local/cache}/zsh/evalcache"
SHELL_SESSION_DIR="${XDG_CACHE_HOME:-$HOME/.local/cache}/zsh/sessions"  # Set Session Storage Location for Zsh

# Managed by path_master (custom rewrite of /usr/libexec/path_helper)
MANPATH='/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/usr/local/man:/opt/homebrew/Cellar/antidote/1.9.10/share/antidote/man:/usr/local/man:/usr/share/man:/usr/local/share/man:/Applications/Ghostty.app/Contents/Resources/man:'
# MANPATH="/usr/local/man:$MANPATH"
XDG_CONFIG_DIRS=$XDG_CONFIG_PATH # Persistent Configs
XDG_DATA_DIRS=$XDG_DATA_PATH     # Persistent Data

# Convenience Envs
HOME_CACHE=$XDG_CACHE_HOME # Ephemeral Data
HOME_CONFIG=$XDG_CONFIG_HOME
HOME_DATA=$XDG_DATA_HOME
HOME_LIB="$HOME/.local/lib" # Source Code Libraries
HOME_PKG="$HOME/.local/pkg" # Managed User Local Packages
THEMES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/themes"

# Tool Configs
ANSIBLE_CONFIG="$XDG_CONFIG_HOME/ansible/config.ini"

ATUIN_CONFIG_DIR="$XDG_CONFIG_HOME/atuin"
ATUIN_THEME_DIR="$THEMES_DIR/atuin"

# GOBIN=''
# GOCACHE='$HOME/Library/Caches/go-build'
# GOENV='$HOME/Library/Application Support/go/env'
# GOMODCACHE='$HOME/go/pkg/mod'
# GOPATH='$HOME/go'
# GOROOT='/opt/homebrew/Cellar/go/1.24.6/libexec'
# GOTELEMETRY='local'
# GOTELEMETRYDIR='$HOME/Library/Application Support/go/telemetry'
# GOTMPDIR=''
# GOTOOLDIR='/opt/homebrew/Cellar/go/1.24.6/libexec/pkg/tool/darwin_arm64'
# GOVCS=''
# GOWORK=''
# PKG_CONFIG='pkg-config'
GOBIN="${XDG_BIN_HOME:-$HOME/.local/bin}/go"
GOPATH="${XDG_CONFIG_HOME:-$HOME/.config}/go"

OP_SIGN="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
OP_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/op"

CARGO_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/cargo"
CARGO_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/cargo"
CARGO_BIN="${XDG_BIN_HOME:-$HOME/.local/bin}/cargo"
CARGO_CACHE="${XDG_CACHE_HOME:-$HOME/.local/cache}/cargo"
CARGO_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/cargo"
# RUSTUP_LOG=INFO # [ERROR, WARN, INFO, DEBUG, TRACE]
# RUSTUP_TERM_COLOR
# RUSTUP_AUTO_INSTALL=1

KUBECONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/kube"
KUBE_EDITOR=$EDITOR
# KREW_DEFAULT_INDEX_URI="git@github.com:foo/custom-index.git"
KREW_ROOT="${XDG_BIN_HOME:-$HOME/.local/bin}/krew/bin"
KREW_NO_UPGRADE_CHECK=0

GHOSTTY_RESOURCES_DIR="/Applications/Ghostty.app/Contents/Resources/ghostty"

AWS_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/cloud/aws/config"
AWS_SHARED_CREDENTIALS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/cloud/aws/creds"
AWS_DATA_PATH="${XDG_DATA_HOME:-$HOME/.config}/cloud/aws"
AWS_DEFAULT_REGION="us-east-1"
# AWS_PROFILE=
EKSCTL_ENABLE_CREDENTIAL_CACHE=1

# VAULT_HTTP_PROXY
# VAULT_PROXY_ADDR
# VAULT_REDIRECT_ADDR
# VAULT_TLS_SERVER_NAME
# VAULT_TOKEN
# VAULT_WRAP_TTL
# VAULT_CLUSTER_ADDR
# VAULT_CLIENT_KEY
# VAULT_CLIENT_CERT
# VAULT_CAPATH
# VAULT_CACERT
# VAULT_AGENT_ADDR
# VAULT_ADDR
# VAULT_LOG_FORMAT
# VAULT_LOG_LEVEL
# VAULT_MFA
# VAULT_NAMESPACE

STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/config.toml"
STARSHIP_CACHE="${XDG_CACHE_HOME:-$HOME/.local/cache}/starship/cache"

YAZI_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/yazi"
# ~/.local/state/yazi/yazi.log
# YAZI_LOG

_ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"
# _ZO_EXCLUDE_DIRS

# CUSTOM_PAGES_DIR # https://tealdeer-rs.github.io/tealdeer/usage_custom_pages.html#custom-pages
