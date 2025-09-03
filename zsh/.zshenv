# Standard Configs
HISTSIZE='10000'
HIST_STAMPS='mm/dd/yyyy'
LANG='en_US.UTF-8'
SAVEHIST='10000'
SSH_AUTH_SOCK='/Users/asmith/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'

# XDG Configs
XDG_CACHE_HOME="/Users/asmith/.local/cache"
XDG_CONFIG_HOME="/Users/asmith/.config"
XDG_DATA_HOME="/Users/asmith/.local/data"
XDG_STATE_HOME="/Users/asmith/.local/state"
XDG_RUNTIME_DIR='/Users/asmith/.local/share'

<<<<<<< Updated upstream
# Tool Configs
ANSIBLE_CONFIG="$XDG_CONFIG_HOME/ansible/config.ini"
ANTIDOTE_HOME="$XDG_CONFIG_HOME/zsh/plugins"
HISTFILE="$XDG_CACHE_HOME/zsh/history"
STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"
_ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"

# ZSH Configs
ZCOMPDUMP="$XDG_CACHE_HOME/zsh/compdump"
ZCOMPLETE="$XDG_CONFIG_HOME/zsh/completions"
ZDOTDIR="$XDG_CONFIG_HOME/zsh"
ZENV="$XDG_CONFIG_HOME/zsh/.zshenv"
ZFUNCS="$XDG_CONFIG_HOME/zsh/functions"
ZPLUGINS="$XDG_CONFIG_HOME/zsh/plugins"
ZSH_DISABLE_COMPFIX='true'
ZSH_EVALCACHE_DIR="$XDG_CACHE_HOME/zsh/evalcache"
SHELL_SESSION_DIR="$XDG_CACHE_HOME/zsh/sessions"

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
=======
ZDOTDIR=$HOME_CONFIG/zsh/                # Set ZSH Config Dir
HISTFILE=$HOME_CACHE/zsh/history         # Set History File Location for Zsh
SHELL_SESSION_DIR=$HOME_CACHE/sessions   # Set Session Storage Location for Zsh
GOBIN=$XDG_BIN_DIR/go
GOPATH=$HOME_CACHE/go
GPG_TTY=$(tty)
>>>>>>> Stashed changes
