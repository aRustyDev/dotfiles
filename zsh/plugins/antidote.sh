#!/usr/bin/env zsh

source $XDG_CONFIG_HOME/op/plugins.sh


# Wants:
# - Colored Man pages
# - Colored Info pages
# - Colored Less Output

# or lighter-weight ones like zsh-utils
belak/zsh-utils path:editor
belak/zsh-utils path:history
belak/zsh-utils path:prompt
belak/zsh-utils path:utility

# Command Line Interaction & History Enhancement
zsh-users/zsh-autosuggestions                       # TEST:
marlonrichert/zsh-autocomplete                      # TEST: Atuin based autocomplete? (feats: smart command/argument/file completion)
zdharma-continuum/fast-syntax-highlighting

fzf
zsh-bat

# Core Zsh Enhancements & Utilities
jeffreytse/zsh-vi-mode                              # Is there a keymap option for this?
MichaelAquilina/zsh-you-should-use                  # TEST:

# Completions
zsh-users/zsh-completions                           # Q: Can I tune out the overlapping completions? How can I compare them/Benchmark them?
# Development Tools: git (enhanced), docker, kubectl, npm, yarn, go, python, pip, node, ruby, gem, bundle, cmake, make, mvn, gradle, sbt, terraform, ansible, packer, vagrant, helm, minikube, gcloud, aws, az, heroku, firebase, pulumi, rustup, cargo, dart, flutter, tsc, ts-node, clang-format, clang-tidy, cppcheck.
# System Utilities: apt, brew, dnf, pacman, yum, systemctl, journalctl, ip, netstat, ss, mount, umount, fdisk, parted, rsync, ssh, scp, sftp, curl, wget, tmux, screen, htop, ncdu, du, df, find, xargs, grep, sed, awk, tar, zip, unzip, gzip, bzip2, xz, lsof, strace, chmod, chown, chgrp, useradd, groupadd, passwd, crontab, logrotate, ufw, iptables, nftables.
# Editors & Viewers: vim, emacs, nano, less, more.
# Miscellaneous: direnv, fzf, rg (ripgrep), fd, neofetch, grpcurl, mkcert, screencapture, sdkmanager, virtualbox.

# Environment & Tool (managers/integrators)
# - Manage versions
# - Activate Environments
# - Optimize Loading
# - Provide Commands
lukechilds/zsh-nvm
pyenv/pyenv-virtualenv

# Prompt & Theming
zsh-dircolors-solarized

# OhMyZsh plugins (Test ALL)
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/1password
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/ansible
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/argocd
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/autoenv
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/aws
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/azure
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/battery
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/bazel
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/bgnotify
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/brew
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/buf
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/colored-man-pages

https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/colorize
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/command-not-found
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/buf
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copybuffer
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dbt
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/cp
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copyfile
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copypath
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/buf
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/doctl
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker-compose
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dotenv
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/emacs
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/emoji
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/encode64

https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/extract
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/eza
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/exa
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fancy-ctrl-z
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/frontend-search
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fzf
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gas
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gcloud
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/genpass
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gh
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-auto-fetch
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-commit
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-prompt
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-lfs
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-hubflow
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-flow
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-flow-avh
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-extras
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-escape-magic
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gitfast
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/github
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gitignore
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/globalias
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gnu-utils
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/golang
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gpg-agent
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/grc
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/grunt
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/helm
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/httpie
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/ipfs
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/jj
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/jira
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/jfrog
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/juju
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/k9s
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/jump
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/keychain
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/kind
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/kn
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/kubectl
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/kubectx
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/localstack
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/lxd
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/magic-enter
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/man
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/microk8s
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/minikube
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/mise
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/mongo-atlas
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/mongocli
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/mosh
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/multipass
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/nats
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/ngrok
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/nmap
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/node
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/nodenv
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/npm
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/nvm
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/opentofu
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/operator-sdk
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/otp
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/per-directory-history
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/pip
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/pipenv
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/pj
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/please
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/pm2
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/pod
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/podman
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/poetry-env
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/poetry
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/postgres
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/pre-commit
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/procs
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/profiles
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/pyenv
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/pylint
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/python
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/qrcode
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rclone
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/react-native
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/redis-cli
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/repo
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rsync
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rust
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rvm
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/salt
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/safe-paste
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/shell-proxy
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/sigstore
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/ssh-agent
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/ssh
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/sudo
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/swiftpm
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/systemadmin
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/tailscale
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/taskwarrior
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/terraform
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/thefuck
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/tldr # Need Tealdeer
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/tmux-cssh
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/tmux
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/tmuxinator
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/toolbox
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/universalarchive
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/ufw
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/urltools
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/uv
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vagrant-prompt
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vagrant
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vault
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vi-mode
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vim-interaction
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/virtualenv
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/virtualenvwrapper
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/volta
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vscode
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vundle
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/wd
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/watson
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/web-search
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/xcode
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/zoxide
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/zsh-interactive-cd
https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/zsh-navigation-tools
