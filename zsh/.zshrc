#!/usr/bin/env zsh
echo "Shell init started: $(date +%s.%N)" >&2
# [[ -n $ZSH_PROFILE ]] && zmodload zsh/zprof
# [[ -n $ZSH_DEBUG ]] && set -x
[[ -n $ZSH_DEBUG ]] && rm -f "$ZCOMPDUMP"
# export ZSH_DEFER_DEBUG=1
# zmodload zsh/zprof
# set -x
# https://www.joshyin.cc/blog/speeding-up-zsh
# ----------------------------------------
# === === === === BREW REQ === === === ===
# ----------------------------------------
casks=(
    antidote ffmpeg sevenzip poppler ripgrep \
    resvg imagemagick helm kubectl atuin jq \
    starship zoxide yazi lsd bat fzf nvim yq fd \
    ansible just helm-ls 1password-cli@beta \
    font-symbols-only-nerd-font tealdeer texinfo \
    mise eza archiver pyenv k9s turbot/tap/steampipe \
    zsh gawk grep gnu-sed coreutils shfmt \
    shellcheck tenv kubectx
)
# brew install $casks

# [doc](https://rhymeswithdiploma.com/2020/07/10/macos-is-at-least/)
autoload -Uz is-at-least
autoload -Uz antidote
autoload -Uz compinit

ZDOTDIR=${ZDOTDIR:-$HOME/.config/zsh}
ZFUNCS=$ZDOTDIR/functions
ZPLUGINS=$ZDOTDIR/plugins
ZCOMPDUMP=${ZCOMPDUMP:-$ZDOTDIR/compdump}
ACTUAL=$(sw_vers -productVersion)

# Source get_fpaths(), initialize(), & generate_completions()
echo "Loading functions..." >&2
source $ZDOTDIR/functions/*
echo "Functions loaded: $(date +%s.%N)" >&2

# --------------------------------------
# === === === === fpaths === === === ===
# --------------------------------------

get_fpaths()
fpath=(/usr/local/opt/antidote/share/antidote/functions $fpath)
for fp in $fpath; do
    if [[ ! -d "$fp" ]]; then
        if [[ "$fp" == *"$HOME"* ]]; then
            # Make any fpath dirs that nest in $HOME
            mkdir -p $fp
        fi
    fi
done

# ---------------------------------------
# === === === === Zsh Opt === === === ===
# ---------------------------------------
# [doc](https://zsh.sourceforge.io/Doc/Release/Options.html)

setopt HIST_FCNTL_LOCK
unsetopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
unsetopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
unsetopt HIST_EXPIRE_DUPS_FIRST
setopt INC_APPEND_HISTORY
unsetopt EXTENDED_HISTORY

# ---------------------------------------
# === === === === Aliases === === === ===
# ---------------------------------------
init_aliases

# -----------------------------------------
# === === === === Functions === === === ===
# -----------------------------------------

# Load functions from external, compile if needed
for func in $ZFUNCS/*.zsh(N); do
    source "$func"
    [[ ! -f "$func.zwc" || "$func" -nt "$func.zwc" ]] && zcompile "$func"
done

# -----------------------------------------------
# === === === load plugins (antidote) === === ===
# -----------------------------------------------
# Ensure the manifest file exists so you can add plugins.
# TODO: Log & panic vs create
init_antidote

# autoload -Uz $ZDOTDIR/zsh-defer

# 1password plugins
# zsh-defer source ${XDG_CONFIG_HOME:-$HOME/.config}/op/plugins.sh

# ---------------------------------------
# === === === Initializations === === ===
# ---------------------------------------
echo "Starting initialize..." >&2
initialize starship
initialize brew
initialize zoxide
initialize direnv
initialize atuin
initialize fzf
echo "Initialize done: $(date +%s.%N)" >&2

# Add any additional configurations here
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# # Lazy load brew
# command -v brew >/dev/null 2>&1 && lazyload brew -- 'eval "$(brew shellenv)"'

# -----------------------------------
# === === === Completions === === ===
# -----------------------------------

# Defer completion generation to speed up startup
# (( $+functions[zsh-defer] )) && zsh-defer -c 'generate_completions()'
# zsh-defer -c 'echo "Starting completions: $(date +%s.%N)"; generate_completions(); echo "Done completions: $(date +%s.%N)"'

# Enable completions (deferred for faster startup)
# (( $+functions[zsh-defer] )) && zsh-defer -c '
#     if [[ ! -f "$ZCOMPDUMP" || "$ZPLUGINS/manifest" -nt "$ZCOMPDUMP" ]]; then
#         compinit -d $ZCOMPDUMP
#         # Compile the dump file for faster loading
#         [[ ! -f "$ZCOMPDUMP.zwc" || "$ZCOMPDUMP" -nt "$ZCOMPDUMP.zwc" ]] && zcompile "$ZCOMPDUMP"
#     else
#         compinit -C -d "$ZCOMPDUMP"  # -C skips security check
#     fi
# '

echo "Starting compinit..." >&2
time {
    if [[ ! -f "$ZCOMPDUMP" ]] || [[ "$ZPLUGINS/manifest" -nt "$ZCOMPDUMP" ]]; then
        compinit -d $ZCOMPDUMP
        [[ ! -f "$ZCOMPDUMP.zwc" ]] && zcompile "$ZCOMPDUMP"
    else
        compinit -C -d "$ZCOMPDUMP"
    fi
}
echo "Compinit done: $(date +%s.%N)" >&2

# --------------------------------------------
# === === === Apple SysCtl Configs === === ===
# --------------------------------------------
# defaults write com.apple.finder AppleShowAllFiles TRUE; killall Finder

# # Configure PATH after nix-daemon.sh to ensure our paths take precedence
# # Initialize path array from current PATH
# path=(${(s/:/)PATH})

# # Ensure darwin-rebuild is accessible by adding nix-darwin path first
# if [[ -d /run/current-system/sw/bin ]]; then
#     path=('/run/current-system/sw/bin' $path)
# fi

# # Add other important paths
# path=("$HOME/.volta/bin" $path)
# path=("$HOME/.cargo/bin" $path)

# # Append additional paths
# path+=('/Applications/VMware Fusion.app/Contents/Public')
# path+=("/usr/local/share/dotnet")
# path+=("$HOME/.dotnet/tools")
# path+=("/usr/local/go/bin")
# path+=("$HOME/.pyenv/shims")
# path+=("$HOME/.local/bin")

# Ensure unique paths
typeset -U path cdpath fpath manpath
# zprof

echo "Shell ready: $(date +%s.%N)" >&2

source ${XDG_CONFIG_HOME:-$HOME/.config}/op/plugins.sh

# set +x
echo "Check trace at: $ZSH_TRACE_FILE"
# source /Users/adamsm/.config/op/plugins.sh
