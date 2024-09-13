# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# If you come from bash you might have to change your $PATH.
PATH="/System/Cryptexes/App/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin"

# prepend to default path
path=('/Users/greymatter/.nix-profile/bin' $PATH)
path=('/nix/var/nix/profiles/default/bin' $PATH)

# append to default path
path+=('/Applications/VMware Fusion.app/Contents/Public')
path+=('/usr/local/share/dotnet')
path+=('~/.dotnet/tools')
path+=('/usr/local/go/bin')
path+=('/Users/greymatter/.pyenv/shims')
path+=('/Users/greymatter/.cargo/bin')
export PATH=$PATH

typeset -U path cdpath fpath manpath

for profile in ${(z)NIX_PROFILES}; do
  fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
done

# Oh-My-Zsh/Prezto calls compinit during initialization,
# calling it twice causes slight start up slowdown
# as all $fpath entries will be traversed again.
autoload -U compinit && compinit


eval "$(starship init zsh)"

plugins=(git gh gcloud aws docker docker-compose man golang helm kubectl minikube command-not-found colored-man-pages sigstore azure terraform macos)
# https://github.com/unixorn/awesome-zsh-plugins
# antidote-use-omz anyframe arduino asciidoctor nohup plugin-vscode presenter-mode ssh-* vagrant-box-wrapper web-search yazi-zoxide
# asdf-* auto-notify evalcache gpg gpg-crypt hooks learn packer zman zredis ztouch
# [osx] : osx-autoproxy osx-dev osx tumult
# [terraform] : tfenv terraform-* tfswitch
# [tmux] : tmux-*
# [history] : histdb historikeeper history-filter passwordless-history
# [lookuplater] : dirstack exa-* eza-* fzf-* git-* lsd-* oath ollama
# [docs] : cheatsheet colored-man-pages command-note
# [kube] : k3d kctl kubecolor kubectl kubectlenv kubectx
# [QoL] : autocomplete autosuggestions case colorize-functions colorize deepx abbr alt-and-select emojji-cli emoji-fzf emojis jq
# [.env] : autodotenv (Can it unload too?) autoenv direnv zenv
# [node] : auto-nvm auto-venv
# [python] : auto-venv poetry pip-*
# [aws] : aws-mfa aws-upload aws-vault-profiles aws-vault aws2
# [azure] : azcli azure-keyvault azure-subscription
# [docker] : appup docker-compose
# [commands] : bat atuin
# [glitter] : ansimotd ansiweather battery_state
# [nvim] : bob compe evil-registers nvim-*
# [completions] : 1password-op aircrack aws-completions brew-completions cargo complete-mac completions ctop docker etcdctl fzf-* gcloud git-* github-cli helmfile inshellisense ipfs kitty keybase kubeadm kubectl-* mcfly mac msfvenom nix ollama packer pandoc-completion poetry rustup xcode yabai zoxide

# Bundle & Load ZSH Plugins
# antidote bundle <.plugins.txt >.plugins.zsh
# source ~/.zsh_plugins.zsh
# antidote load


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


# Add any additional configurations here
export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi


# Aliases


# Named Directory Hashes

# Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"
export VISUAL="code"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.


# source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

export EDITOR="code -w"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='code -w'
fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
