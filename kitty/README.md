# kitty

GPU-accelerated terminal emulator with extensive features and configurability.

## Current Configuration

- `kitty.conf` - Main configuration with Catppuccin Mocha theme
- `brewfile` - Kitty cask

### Features Enabled

- **Font**: JetBrainsMono Nerd Font, size 14
- **Theme**: Catppuccin Mocha (embedded)
- **Window**: 10px padding, titlebar-only decorations, 95% opacity
- **Tab bar**: Powerline style, slanted
- **Shell integration**: Enabled
- **macOS**: Option as Alt, quit on last window close

## Installation

```bash
just -f kitty/justfile install
```

## Keybindings

### Tabs

| Key | Action |
|-----|--------|
| `Cmd+T` | New tab |
| `Cmd+W` | Close tab |
| `Cmd+[` | Previous tab |
| `Cmd+]` | Next tab |
| `Cmd+1-9` | Go to tab N |

### Windows (Splits)

| Key | Action |
|-----|--------|
| `Cmd+D` | Split vertical |
| `Cmd+Shift+D` | Split horizontal |
| `Cmd+Shift+W` | Close window |

### Navigation (Vim-style)

| Key | Action |
|-----|--------|
| `Ctrl+H` | Focus left |
| `Ctrl+J` | Focus down |
| `Ctrl+K` | Focus up |
| `Ctrl+L` | Focus right |

### Resizing

| Key | Action |
|-----|--------|
| `Ctrl+Shift+H` | Narrower |
| `Ctrl+Shift+J` | Shorter |
| `Ctrl+Shift+K` | Taller |
| `Ctrl+Shift+L` | Wider |

### Other

| Key | Action |
|-----|--------|
| `Cmd+Enter` | Toggle fullscreen |
| `Cmd+K` | Clear scrollback |
| `Cmd+Shift+,` | Reload config |
| `Cmd++/-/0` | Font size |

## Kittens (Built-in Plugins)

Kitty includes powerful "kittens":

```bash
# Display images in terminal
kitty +kitten icat image.png

# Side-by-side diff
kitty +kitten diff file1 file2

# SSH with kitty features
kitty +kitten ssh user@host

# Unicode input
kitty +kitten unicode_input

# View clipboard
kitty +kitten clipboard
```

## Recipes

```bash
# Reload config
just -f kitty/justfile reload

# Show info
just -f kitty/justfile info

# Edit config
just -f kitty/justfile edit
```

## TODOs

### Enhancements (Low Priority)

- [ ] **Session files**: Predefined window layouts
- [ ] **Custom kittens**: Project-specific tools
- [ ] **Remote control**: Enable for scripting

## File Structure

```
kitty/
├── kitty.conf    # Main config (symlinked to ~/.config/kitty/)
├── brewfile      # Kitty cask
├── justfile      # Installation recipes
├── data.yml      # Module config
└── README.md     # This file
```

## References

- [Kitty Documentation](https://sw.kovidgoyal.net/kitty/)
- [Kitty Configuration](https://sw.kovidgoyal.net/kitty/conf/)
- [Kitty Keybindings](https://sw.kovidgoyal.net/kitty/actions/)
- [Catppuccin for Kitty](https://github.com/catppuccin/kitty)
- [Kittens](https://sw.kovidgoyal.net/kitty/kittens_intro/)
