---
id: 3a4b5c6d-7e8f-9a0b-1c2d-3e4f5a6b7c8d
title: Stow Improved
created: 2025-12-13T00:00:00
updated: 2025-12-13T17:04
project: dotfiles
scope:
  - tools
  - configuration
type: reference
status: 📝 draft
publish: false
tags:
  - stow
  - rust
  - dotfiles
aliases:
  - stow-rust
related: []
---

# Stow Improved

## Ideas

```toml
[default]
# type : inferred by default
sudo = false
dest = "${XDG_CONFIG_HOME:-$HOME}"

[[pkg]]
name = "foo"
type = "dir|file"
dot = true
sudo = false
dest = "path/to/.foo"
src = "path/to/pkg/foo/"
```

- `.stow.local.ignore`: ignore file, not checked into version control
- `.stow.ignore`: ignore file, checked into version control
- `stow.toml`: configuration file
- Need some way to "uninstall" the stowed packages too
- Integrate with `atuin` to sync dotfiles across devices
