#!/usr/bin/env zsh

if [[ ! -f "_$CMD" ]]; then
    echo "Adding completion"
fi

# Command Line Interaction & History Enhancement
zsh-users/zsh-autosuggestions                       # TEST:
marlonrichert/zsh-autocomplete                      # TEST: Atuin based autocomplete? (feats: smart command/argument/file completion)
zdharma-continuum/fast-syntax-highlighting

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
