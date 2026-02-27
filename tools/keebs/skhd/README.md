# skhd

Simple hotkey daemon for macOS - bind arbitrary commands to keyboard shortcuts.

## Current Configuration

- `skhdrc` - Main hotkey configuration
- `applescripts/` - AppleScript helpers for system actions
- `examples/` - Reference configurations
- `brewfile` - skhd package

### Features Enabled

- **App launchers**: Alt + key to open common apps
- **System actions**: Lock screen, screenshots
- **AppleScript integration**: Notification clearing
- **Extensible**: Ready for yabai/aerospace integration

## Installation

```bash
just -f skhd/justfile install
```

**Important**: Grant Accessibility permission in System Settings → Privacy & Security → Accessibility

## Keybindings

### App Launchers

| Key | App |
|-----|-----|
| `Alt + Return` | Ghostty (terminal) |
| `Alt + B` | Zen Browser |
| `Alt + E` | VS Code |
| `Alt + S` | Slack |
| `Alt + O` | Obsidian |
| `Alt + F` | Finder |

### System Actions

| Key | Action |
|-----|--------|
| `Cmd + Shift + L` | Lock screen |
| `Alt + N` | Close notifications |

## Service Management

```bash
# Start skhd service
just -f skhd/justfile start

# Stop service
just -f skhd/justfile stop

# Restart service
just -f skhd/justfile restart

# Reload config (after editing)
just -f skhd/justfile reload

# Check config syntax
just -f skhd/justfile check
```

## Syntax Reference

### Basic Format

```
<modifier> - <key> : <command>
```

### Modifiers

| Modifier | Key |
|----------|-----|
| `alt` | Option |
| `shift` | Shift |
| `cmd` | Command |
| `ctrl` | Control |
| `fn` | Function |
| `lalt` / `ralt` | Left/Right Option |
| `lshift` / `rshift` | Left/Right Shift |

### Examples

```bash
# Open app
alt - t : open -a "Terminal"

# Run shell command
alt - d : osascript -e 'display notification "Hello"'

# Chained modifiers
cmd + shift - l : pmset displaysleepnow

# Application-specific (only in Safari)
alt - r [
    "Safari" : osascript -e 'tell app "Safari" to do JavaScript "location.reload()" in current tab of window 1'
]
```

## TODOs

### Integration (Medium Priority)

- [ ] **yabai integration**: Window management keybindings
- [ ] **aerospace integration**: Alternative tiling WM support

### Enhancements (Low Priority)

- [ ] **More app launchers**: Add commonly used apps
- [ ] **Media controls**: Custom media key handling
- [ ] **Clipboard manager**: Quick clipboard actions

## File Structure

```
skhd/
├── skhdrc              # Main config (symlinked to ~/.config/skhd/)
├── applescripts/       # AppleScript helpers
│   ├── calendar.scpt   # Calendar integration
│   ├── menu.scpt       # Menu bar actions
│   ├── notifications.scpt  # Notification clearing
│   └── pop.scpt        # Popup dialogs
├── examples/
│   └── .skhdrc         # Reference config
├── brewfile            # skhd package
├── justfile            # Installation recipes
├── data.yml            # Module config
└── README.md           # This file
```

## References

- [skhd GitHub](https://github.com/koekeishiya/skhd)
- [skhd Wiki](https://github.com/koekeishiya/skhd/wiki)
- [yabai + skhd Setup](https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release))
