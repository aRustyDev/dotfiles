# ghostty

GPU-accelerated terminal emulator with native platform feel.

## Current Configuration

- `config` - Main configuration file
- `brewfile` - Ghostty cask
- `configs/` - Seasonal theme overrides (halloween, christmas, etc.)
- `themes/` - Custom themes directory

### Features Enabled

- **Font**: JetBrains Mono, size 14, thickened, with ligatures
- **Theme**: Catppuccin Mocha
- **Window**: 10px padding, native decorations, tabbed titlebar
- **Shell**: zsh with full integration (cursor, sudo, title)
- **Quick Terminal**: Global hotkey `Ctrl+`` for dropdown terminal
- **URL Handling**: Click to open URLs

## Installation

```bash
just -f ghostty/justfile install
```

## Keybindings

### General

| Key | Action |
|-----|--------|
| `Ctrl+`` | Toggle quick terminal (global) |
| `Cmd+K` | Clear screen |
| `Cmd+Shift+,` | Reload config |
| `Cmd+Shift+Enter` | Toggle fullscreen |

### Tabs

| Key | Action |
|-----|--------|
| `Cmd+T` | New tab |
| `Cmd+W` | Close tab/split |
| `Cmd+[` | Previous tab |
| `Cmd+]` | Next tab |
| `Cmd+Opt+Left/Right` | Previous/next tab |

### Splits

| Key | Action |
|-----|--------|
| `Cmd+D` | Split right |
| `Cmd+Shift+D` | Split down |
| `Cmd+Shift+E` | Equalize splits |

### Split Navigation (Vim-style)

| Key | Action |
|-----|--------|
| `Ctrl+H` | Go to left split |
| `Ctrl+J` | Go to bottom split |
| `Ctrl+K` | Go to top split |
| `Ctrl+L` | Go to right split |

### Split Resizing

| Key | Action |
|-----|--------|
| `Ctrl+Shift+H` | Resize left |
| `Ctrl+Shift+J` | Resize down |
| `Ctrl+Shift+K` | Resize up |
| `Ctrl+Shift+L` | Resize right |

## Quick Terminal

The quick terminal is a dropdown terminal accessible from anywhere with `Ctrl+``:

- Position: Top of screen
- Screen: Follows mouse
- Animation: 0.1s

## TODOs

### Enhancements (Medium Priority)

- [ ] **Background blur/opacity**: For transparency effect
  ```
  background-opacity = 0.95
  background-blur-radius = 20
  ```

- [ ] **Image support**: Inline image display
  ```
  image-storage-limit = 320000000
  ```

- [ ] **Seasonal configs**: Set up config includes for holidays
  - `config-file = configs/halloween` during October
  - Could automate with shell profile

### Cleanup (Low Priority)

- [ ] **Review configs/ directory**: Seasonal theme overrides
  - halloween → Cobalt Neon theme
  - christmas, november → Empty, need content

- [ ] **Custom themes**: Add themes to themes/ directory
  - Currently using built-in catppuccin-mocha

### Integration

- [ ] **tmux/zellij navigation**: Coordinate Ctrl+hjkl with multiplexer
  - May need to disable split navigation if using tmux

## File Structure

```
ghostty/
├── config           # Main config (symlinked to ~/.config/ghostty/)
├── brewfile         # Ghostty cask
├── justfile         # Installation recipes
├── data.yml         # Module config
├── README.md        # This file
├── configs/         # Seasonal theme overrides
│   ├── halloween    # Cobalt Neon theme
│   ├── christmas    # (empty)
│   └── november     # (empty)
└── themes/          # Custom themes
    └── README.md    # Theme locations reference
```

## References

- [Ghostty Website](https://ghostty.org/)
- [Ghostty Configuration](https://ghostty.org/docs/config)
- [Ghostty Keybindings](https://ghostty.org/docs/config/keybind)
- [Catppuccin for Ghostty](https://github.com/catppuccin/ghostty)
