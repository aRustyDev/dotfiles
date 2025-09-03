# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

rm -f ~/.zcompdump;
autoload -Uz compinit && compinit

# PATH will be configured after nix-daemon.sh is sourced

for profile in ${(z)NIX_PROFILES}; do
  fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
done

fpath=($ZDOTDIR/zsh/completions $fpath)
fpath="$(brew --prefix)/share/zsh/site-functions:${fpath}"

chmod -R go-w "$(brew --prefix)/share" # Make brew completions writable

eval "$(atuin init zsh)"
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
eval "$(brew shellenv)"
# eval "$(vault -autocomplete-install)"

complete -C '/opt/homebrew/bin/aws_completer' aws

alias ll="ls -l"
alias la="ls -Al"
alias pu="pushd"
alias po="popd"

# History options should be set in .zshrc and after oh-my-zsh sourcing.
# See https://github.com/nix-community/home-manager/issues/177.
HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
unsetopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
unsetopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
unsetopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY

echo "$(op completion zsh)" > $ZDOTDIR/completions/_op
# echo "$(opa completion zsh)" > $ZDOTDIR/completions/_opa
echo "$(helm completion zsh)" > $ZDOTDIR/completions/_helm
echo "$(syft completion zsh)" > $ZDOTDIR/completions/_syft
# echo "$(grype completion zsh)" > $ZDOTDIR/completions/_grype
# echo "$(falco completion zsh)" > $ZDOTDIR/completions/_falco
# echo "$(trivy completion zsh)" > $ZDOTDIR/completions/_trivy
echo "$(eksctl completion zsh)" > $ZDOTDIR/completions/_eksctl
echo "$(cosign completion zsh)" > $ZDOTDIR/completions/_cosign
echo "$(docker completion zsh)" > $ZDOTDIR/completions/_docker
# echo "$(cilium completion zsh)" > $ZDOTDIR/completions/_cilium
echo "$(templar completion zsh)" > $ZDOTDIR/completions/_templar
echo "$(kubectl completion zsh)" > $ZDOTDIR/completions/_kubectl

# Add any additional configurations here
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Configure PATH after nix-daemon.sh to ensure our paths take precedence
# Initialize path array from current PATH
path=(${(s/:/)PATH})

# Ensure darwin-rebuild is accessible by adding nix-darwin path first
if [[ -d /run/current-system/sw/bin ]]; then
    path=('/run/current-system/sw/bin' $path)
fi

# Add other important paths
path=("$HOME/.volta/bin" $path)
path=("$HOME/.cargo/bin" $path)

# Append additional paths
path+=('/Applications/VMware Fusion.app/Contents/Public')
path+=('/usr/local/share/dotnet')
path+=('~/.dotnet/tools')
path+=('/usr/local/go/bin')
path+=("$HOME/.pyenv/shims")
path+=("$HOME/.local/bin")

# Ensure unique paths
typeset -U path cdpath fpath manpath

# Export the constructed PATH
export PATH="${(j.:.)path}"

# Ensure /run/current-system/sw/bin is in PATH for darwin-rebuild
if [[ -d /run/current-system/sw/bin ]] && [[ ":$PATH:" != *":/run/current-system/sw/bin:"* ]]; then
    export PATH="/run/current-system/sw/bin:$PATH"
fi


# Aliases


# Named Directory Hashes

export EDITOR="code -w"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='code -w'
fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# === Apple SysCtl Configs ===
# defaults write com.apple.finder AppleShowAllFiles TRUE; killall Finder
