#!/usr/bin/env zsh

alias ll='ls -l'
alias ll='lsd -lF --group-dirs=first'
alias ls='lsd'
alias tree='lsd --tree'
alias la="ls -Al"
alias python=python3
alias pip=pip3
alias pu="pushd"
alias po="popd"
alias cat='bat'
alias ku='kubectl'
alias kua='kubectl --all-namespaces'
alias zshbench='time ZSH_PROFILE=1 zsh -i -c exit && unset ZSH_PROFILE'
alist zplug="antidote bundle <~/.zsh_plugins.txt >~/.zsh_plugins.zsh"
