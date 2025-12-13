---
id: 0f1a2b3c-4d5e-6f7a-8b9c-0d1e2f3a4b5c
title: Zsh Configuration
created: 2025-12-13T00:00:00
updated: 2025-12-13T17:04
project: dotfiles
scope:
  - shell
  - zsh
type: reference
status: ✅ active
publish: false
tags:
  - zsh
  - shell
  - configuration
aliases:
  - zsh-config
related: []
---

# Zsh

1. `/etc/zshenv` : System
2. `~/.zshenv` : HOME (if exists)
3. `$ZDOTDIR/.zshenv` : Your intended one
4. `/etc/zprofile` : System (login shells)
5. `~/.zprofile` or `$ZDOTDIR/.zprofile`
6. `/etc/zshrc` : System (interactive)
7. `~/.zshrc` : HOME (if ZDOTDIR not set!)
8. `$ZDOTDIR/.zshrc` : Your intended one

### Ideas

```
- .Xdefaults
- .aliasrc
- .functions
- .profile
- .shellrc
```
