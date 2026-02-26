# zellij

A terminal workspace with batteries included - modern terminal multiplexer written in Rust.

## Current Configuration

- `config.kdl` - Full configuration with custom keybindings and plugins
- `brewfile` - Zellij package
- `examples/` - Example configurations (Catppuccin themes)

### Features Enabled

- **Theme**: Catppuccin Mocha
- **Keybindings**: Vim-style with tmux compatibility layer (`Ctrl+b` prefix)
- **UI**: Simplified UI, no pane frames
- **On force close**: Detach (preserves session)
- **Plugins**: tab-bar, status-bar, strider (file picker), compact-bar

## Installation

```bash
just -f zellij/justfile install
```

## Keybindings

### Mode Switching

| Key | Mode |
|-----|------|
| `Ctrl+a` | Pane mode |
| `Ctrl+t` | Tab mode |
| `Ctrl+n` | Resize mode |
| `Ctrl+s` | Scroll mode |
| `Ctrl+x` | Session mode |
| `Ctrl+b` | Tmux mode |
| `Ctrl+g` | Lock mode |

### Pane Mode (`Ctrl+a`)

| Key | Action |
|-----|--------|
| `h/j/k/l` | Move focus |
| `n` | New pane |
| `d` | New pane down |
| `x` | Close pane |
| `z` | Toggle fullscreen |
| `f` | Toggle pane frames |
| `w` | Toggle floating panes |
| `r` | Rename pane |

### Tab Mode (`Ctrl+t`)

| Key | Action |
|-----|--------|
| `h/l` | Previous/next tab |
| `n` | New tab |
| `x` | Close tab |
| `r` | Rename tab |
| `1-9` | Go to tab N |
| `a` | Toggle last tab |

### Tmux Mode (`Ctrl+b`)

| Key | Action |
|-----|--------|
| `"` | Split horizontal |
| `%` | Split vertical |
| `c` | New tab |
| `,` | Rename tab |
| `p/n` | Previous/next tab |
| `h/j/k/l` | Move focus |
| `z` | Toggle fullscreen |
| `d` | Detach |
| `x` | Close pane |

### Global (Any Mode)

| Key | Action |
|-----|--------|
| `Alt+n` | New pane |
| `Alt+h/l` | Move focus left/right |
| `Alt+j/k` | Move focus down/up |
| `Alt+=/-` | Resize increase/decrease |
| `Alt+[/]` | Previous/next layout |

## Recipes

```bash
# List active sessions
just -f zellij/justfile sessions

# Attach to session (creates if not exists)
just -f zellij/justfile attach myproject

# Kill a session
just -f zellij/justfile kill myproject

# Kill all sessions
just -f zellij/justfile kill-all

# Show info
just -f zellij/justfile info
```

## Shell Integration

Add to your shell config for auto-attach:

```bash
# Auto-attach to zellij session
if [[ -z "$ZELLIJ" ]]; then
    zellij attach -c default
fi
```

## TODOs

### Enhancements (Medium Priority)

- [ ] **Add custom layouts**: Create reusable workspace layouts
  - `layouts/dev.kdl` - Development (editor + terminal + logs)
  - `layouts/k8s.kdl` - Kubernetes (k9s + logs + shell)

- [ ] **Explore plugins**:
  - `room` - Multiplayer collaboration
  - `zellij-forgot` - Command history/cheatsheet

### Integration (Low Priority)

- [ ] **Neovim integration**: Smart splits plugin compatibility
- [ ] **Session templates**: Named sessions for different projects

## File Structure

```
zellij/
├── config.kdl    # Main config (symlinked to ~/.config/zellij/)
├── brewfile      # Zellij package
├── justfile      # Installation recipes
├── data.yml      # Module config
├── README.md     # This file
└── examples/
    ├── catppuccin.kdl   # Catppuccin theme example
    └── catppuccin.yaml  # Catppuccin YAML format
```

## References

- [Zellij Official Site](https://zellij.dev/)
- [Zellij GitHub](https://github.com/zellij-org/zellij)
- [Zellij Configuration Guide](https://zellij.dev/documentation/)
- [Zellij Keybindings](https://zellij.dev/documentation/keybindings.html)
- [Catppuccin for Zellij](https://github.com/catppuccin/zellij)
