# This is a GLOBAL ZSH Env file

if command -v cargo; then . "$HOME/.cargo/env"; fi
if command -v go; then . "$(go env GOENV)"; fi


HOME_LIB=$HOME/.local/lib        # Source Code Libraries
HOME_PKG=$HOME/.local/pkg        # Managed User Local Packages
HOME_DATA=$HOME/.local/data      # Persistent Data
HOME_CACHE=$HOME/.local/cache    # Ephemeral Data
HOME_CONFIG=$HOME/.config        # Persistent Configs

ZDOTDIR=$HOME_CONFIG/zsh/

CARGO_HOME=$HOME_LIB/cargo
RUSTUP_HOME=$HOME_PKG/rustup
RUSTUP_LOG=$HOME_CACHE/rustup/logs
RUSTUP_TRACE_DIR=$HOME_CACHE/rustup/traces
# RUSTUP_DIST_SERVER="https://rs.admz.blvd" # root URL for downloading static resources related to Rust
# RUSTUP_UPDATE_ROOT="https://rs.admz.blvd" # root URL for downloading self-update.

VOLTA_HOME=$HOME_PKG/volta

GOPATH=$HOME_LIB/go              # location of your workspace for Go
GOBIN=$HOME_PKG/go/bin
# GOPROXY="https://go.admz.blvd"
# GOSUMDB
# GOTMPDIR
# GOTOOLCHAIN
# GOCOVERDIR
# GOTELEMETRYDIR=$HOME_CACHE/go/traces
# GOTOOLDIR=$HOME_PKG/go/bin

ZDOTDIR=$HOME_CONFIG/zsh

STARSHIP_CONFIG=$HOME_CONFIG/starship/config.toml
STARSHIP_CACHE=$HOME_CACHE/starship
STARSHIP_SHELL=zsh

TENV_ROOT=$HOME_PKG/tenv
TF_PLUGIN_CACHE_DIR=$HOME_PKG/terraform/plugins

AWS_CONFIG_FILE=$HOME_CONFIG/aws/credentials
AWS_SHARED_CREDENTIALS_FILE=$HOME_CONFIG/aws/config