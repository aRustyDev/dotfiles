---
id: 9e0f1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b
title: Zsh Configuration TODO
created: 2025-12-13T00:00:00
updated: 2025-12-13T17:04
project: dotfiles
scope:
  - shell
  - zsh
type: plan
status: 🚧 in-progress
publish: false
tags:
  - zsh
  - shell
  - configuration
aliases:
  - zsh-tasks
related: []
---

# TODO

## Shells: Zsh

| status | Task                                          | notes |
| ------ | --------------------------------------------- | ----- |
| `todo` | [teleport][teleport]: Implement Agentless SSH |       |

- Build Dotfiles
  - $HISTFILE
- Build Dotdirs
  - $HOME_CONFIG
  - $HOME_CACHE
  - $HOME_DATA
  - $HOME_PKG
  - $HOME_LIB
  - $ZSH_EVALCACHE_DIR
- zsh-defer
- evalcache
- path
- aliases
- symlinks
- .zshenv
- completions

```zsh
# mkdir -p ~/Library/LaunchAgents
# cp $HOME/nix/1Password/com.1password.SSH_AUTH_SOCK.plist > ~/Library/LaunchAgents/com.1password.SSH_AUTH_SOCK.plist
# launchctl load -w ~/Library/LaunchAgents/com.1password.SSH_AUTH_SOCK.plis
# compdef _op op
```

- manage /etc/shells, as well as default shell (/opt/homebrew/bin/zsh)

```bash
# List of acceptable shells for chpass(1).
# Ftpd will not allow users to connect who are not using
# one of these shells.

/bin/bash
/bin/csh
/bin/dash
/bin/ksh
/bin/sh
/bin/tcsh
/bin/zsh
/opt/homebrew/bin/zsh
# /opt/homebrew/bin/bash
# nushell
# fish
# elvish
# xonsh
# powershell?
```

- manage install and versioning of critical packages
  Clang: 17.0.0 build 1700
  Git: 2.39.5 => /Library/Developer/CommandLineTools/usr/bin/git
  Curl: 8.7.1 => /usr/bin/curl
  CLT: 16.4.0.0.1.1747106510
  Xcode: N/A
  Rosetta 2: false
  gcc
  cc
  zsh
  bash
