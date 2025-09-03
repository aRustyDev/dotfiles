[[ -n $ZSH_PROFILE ]] && zmodload zsh/zprof
# https://www.joshyin.cc/blog/speeding-up-zsh
# ----------------------------------------
# === === === === BREW REQ === === === ===
# ----------------------------------------
casks=(
    antidote ffmpeg sevenzip poppler ripgrep \
    resvg imagemagick helm kubectl atuin jq \
    starship zoxide yazi lsd bat fzf nvim yq \
    ansible just helm-ls 1password-cli@beta \
    font-symbols-only-nerd-font tealdeer info \
    mise eza archive pyenv k9s turbot/tap/steampipe \
    zsh gawk grep gnu-sed coreutils
)
# brew install $casks

mypath=(
    "/usr/share/zsh/$ZSH_VERSION/functions" \
    "/usr/share/zsh/site-functions" \
    "$HOME/.config/zsh/functions" \
    "$HOME/.config/zsh/completions" \
    "/usr/local/share/zsh/site-functions" \
    "/usr/share/zsh/functions"
)

# Add brew paths if brew exists
if command -v brew >/dev/null 2>&1; then
    BREW_PREFIX="$(brew --prefix)"
    fpath=(
        $mypath \
        "$BREW_PREFIX/share/zsh-completions" \
        "$BREW_PREFIX/share/zsh/site-functions" \
        $fpath
    )
else
    fpath=(
        $mypath \
        $fpath
    )
fi

for profile in ${(z)NIX_PROFILES}; do
  fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
done

for fp in $fpath; do
    if [[ ! -d "$fp" ]]; then
        if [[ "$fp" == *"$HOME"* ]]; then
            # Make any fpath dirs that nest in $HOME
            mkdir -p $fp
        fi
    fi
done

# setopt HIST_FCNTL_LOCK
# unsetopt APPEND_HISTORY
# setopt HIST_IGNORE_DUPS
# unsetopt HIST_IGNORE_ALL_DUPS
# setopt HIST_IGNORE_SPACE
# unsetopt HIST_EXPIRE_DUPS_FIRST
# setopt SHARE_HISTORY
# unsetopt EXTENDED_HISTORY

# ---------------------------------------
# === === === === ENV VAR === === === ===
# ---------------------------------------


export STARSHIP_CONFIG=~/.config/starship.toml
export ANSIBLE_CONFIG=~/.config/ansible/config.ini
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8
export HIST_STAMPS="mm/dd/yyyy" # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
  export VISUAL='vim'
else
  export EDITOR='code -w'
  export VISUAL='zed'
fi
export ARCHFLAGS="-arch x86_64"
export HISTSIZE="10000"
export SAVEHIST="10000"
export HOME_CACHE="$HOME/.local/cache"
export HOME_CONFIG="$HOME/.config"
export HOME_DATA="$HOME/.local/data"
export HOME_PKG="$HOME/.local/pkg"
export HOME_LIB="$HOME/.local/lib"
export HISTFILE="$HOME_CACHE/zsh/history"
export SHELL_SESSION_DIR=$HOME_CACHE/sessions
export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"
export ZCOMPDUMP="$HOME_CACHE/zsh/compdump"
export ZSH_DISABLE_COMPFIX=true
export ANTIDOTE_HOME="$HOME_CACHE/antidote"
export ZDOTDIR="$HOME_CONFIG/zsh"
export ZFUNCS="$ZDOTDIR/functions"
export ZPLUGINS="$ZDOTDIR/plugins"
export ZSH_EVALCACHE_DIR="$HOME_CACHE/zsh/evalcache"


# ----------------------------------------
# === === === === DOTFILES === === === ===
# ----------------------------------------

mkdir -p "$(dirname "$HISTFILE")"
mkdir -p "$(dirname "$HOME_CONFIG")"
mkdir -p "$(dirname "$HOME_CACHE")"
mkdir -p "$(dirname "$HOME_DATA")"
mkdir -p "$(dirname "$HOME_PKG")"
mkdir -p "$(dirname "$HOME_LIB")"
mkdir -p "$(dirname "$ZSH_EVALCACHE_DIR")"

# ---------------------------------------
# === === === === Aliases === === === ===
# ---------------------------------------
alias python=python3
alias pip=pip3
alias ll='lsd -lF --group-dirs=first'
alias ls='lsd'
alias tree='lsd --tree'
alias cat='bat'
alias ku='kubectl'
alias kua='kubectl --all-namespaces'
alias zshbench='time ZSH_PROFILE=1 zsh -i -c exit && unset ZSH_PROFILE'

# ----------------------------------------------
# === === === antidote: load plugins === === ===
# ----------------------------------------------
# Set the root name of the plugins files (.txt and .zsh) antidote will use.
zsh_plugins=${ZPLUGINS}/.zsh_plugins

# Ensure the manifest file exists so you can add plugins.
[[ -f ${ZPLUGINS}/manifest ]] || touch ${ZPLUGINS}/manifest

# Load required zsh functions first
autoload -Uz is-at-least

# Lazy-load antidote from its functions directory.
fpath=(/usr/local/opt/antidote/share/antidote/functions $fpath)
autoload -Uz antidote

# Generate a new static file whenever manifest is updated.
if [[ ! ${ZPLUGINS}/antidote.zsh -nt ${ZPLUGINS}/manifest ]]; then
    antidote load ${ZPLUGINS}/manifest
    antidote bundle <${ZPLUGINS}/manifest >|${ZPLUGINS}/antidote.zsh
fi

# Source your static plugins file.
source ${ZPLUGINS}/antidote.zsh
# -----------------------------------------------
# === === === 1password: load plugins === === ===
# -----------------------------------------------
export DOT1PW="$HOME_CONFIG/op"
# [[ -f ${DOT1PW}/plugins.zsh ]] || source ${DOT1PW}/plugins.zsh

# ---------------------------------------
# === === === Initializations === === ===
# ---------------------------------------

# Critical initializations (needed immediately for prompt and PATH)
_evalcache starship init zsh
_evalcache brew shellenv
_evalcache zoxide init zsh

# Defer non-critical initializations (load after prompt is shown)
zsh-defer _evalcache atuin init zsh
zsh-defer _evalcache fzf --zsh
zsh-defer tldr --update

# Add any additional configurations here
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'

  # source <(cat $HOME/.config/nix/zsh/path)
  # source <(cat $HOME/.config/nix/zsh/aliases)
  # source <(cat $HOME/.config/nix/zsh/symlinks)
  # source <(cat $HOME/.config/nix/zsh/.zshenv)
  # source <(cat $HOME/.config/nix/zsh/completions)
fi

# # Lazy load brew
# command -v brew >/dev/null 2>&1 && lazyload brew -- 'eval "$(brew shellenv)"'

# -----------------------------------
# === === === Completions === === ===
# -----------------------------------

# Defer completion generation to speed up startup
(( $+functions[zsh-defer] )) && zsh-defer -c '
    # Ensure completion directory exists
    COMPLETION_DIR="$HOME/.config/zsh/completions"
    mkdir -p "$COMPLETION_DIR"

    # Generate completions only if commands exist and file is outdated
    kubectl completion zsh > "$COMPLETION_DIR/_kubectl"
    helm completion zsh > "$COMPLETION_DIR/_helm"
    op completion zsh > "$COMPLETION_DIR/_op"
    rg --generate complete-zsh > "$COMPLETION_DIR/_rg"
    just --completions zsh > "$COMPLETION_DIR/_just"
    yq completion zsh > "$COMPLETION_DIR/_yq"
    volta completions > "$COMPLETION_DIR/_volta"
    gh completion --shell zsh > "$COMPLETION_DIR/_gh"
    docker completion zsh > "$COMPLETION_DIR/_docker"
    k9s completion zsh > "$COMPLETION_DIR/_k9s"
'

# Enable completions (deferred for faster startup)
(( $+functions[zsh-defer] )) && zsh-defer -c '
    if [[ ! -f "$ZCOMPDUMP" || "$ZPLUGINS/manifest" -nt "$ZCOMPDUMP" ]]; then
        autoload -Uz compinit && compinit -d $ZCOMPDUMP
    else
        autoload -Uz compinit && compinit -C -d $ZCOMPDUMP
    fi
'

# Only run zprof if explicitly enabled
[[ -n $ZSH_PROFILE ]] && zprof
