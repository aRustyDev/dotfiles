# Standard Configs
LANG='en_US.UTF-8'
SSH_AUTH_SOCK='/Users/asmith/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'
GPG_TTY=$(tty)
VISUAL=""
# EDITOR='nvim'
EDITOR="/Applications/Zed.app/Contents/MacOS/cli -n --wait"
PAGER=""
TERM=""

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

# History Configs
HISTSIZE='10000'
SAVEHIST='10000'
HIST_STAMPS='mm/dd/yyyy'
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
XDG_CONFIG_DIRS=$XDG_CONFIG_PATH # Persistent Configs
XDG_DATA_DIRS=$XDG_DATA_PATH     # Persistent Data

# Convenience Envs
HOME_CACHE=$XDG_CACHE_HOME # Ephemeral Data
HOME_CONFIG=$XDG_CONFIG_HOME
HOME_DATA=$XDG_DATA_HOME
HOME_LIB='/Users/asmith/.local/lib' # Source Code Libraries
HOME_PKG='/Users/asmith/.local/pkg' # Managed User Local Packages

# Tool Configs
ANSIBLE_CONFIG="$XDG_CONFIG_HOME/ansible/config.ini"

# GOBIN=''
# GOCACHE='/Users/asmith/Library/Caches/go-build'
# GOENV='/Users/asmith/Library/Application Support/go/env'
# GOMODCACHE='/Users/asmith/go/pkg/mod'
# GOPATH='/Users/asmith/go'
# GOROOT='/opt/homebrew/Cellar/go/1.24.6/libexec'
# GOTELEMETRY='local'
# GOTELEMETRYDIR='/Users/asmith/Library/Application Support/go/telemetry'
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

_ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"
