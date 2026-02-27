# karabiner

Karabiner-Elements - powerful keyboard customizer for macOS.

## Current Configuration

- `karabiner.json` - Main configuration with Hyper key and vim navigation
- `brewfile` - Karabiner-Elements cask
- `examples/` - Reference configurations

### Features Enabled

- **Hyper Key**: Caps Lock acts as Escape (tap) or Hyper (hold)
  - Hyper = Ctrl + Option + Cmd + Shift
- **Vim Navigation**: Hyper + hjkl for arrow keys
- **Right Cmd Navigation**: Right Command + hjkl for arrows
- **App Launchers**: Hyper + key for quick app access
- **Function Keys**: Standard macOS function key behavior

## Installation

```bash
just -f karabiner/justfile install
```

**Important**: Grant Input Monitoring permission in System Preferences → Privacy & Security → Input Monitoring

## Keybindings

### Hyper Key (Caps Lock)

| Key | Action |
|-----|--------|
| `Caps Lock` (tap) | Escape |
| `Caps Lock` (hold) | Hyper modifier |

### Navigation (Vim-style)

| Key | Action |
|-----|--------|
| `Hyper + h` | Left arrow |
| `Hyper + j` | Down arrow |
| `Hyper + k` | Up arrow |
| `Hyper + l` | Right arrow |
| `Right Cmd + h/j/k/l` | Arrow keys (alternative) |

### App Launchers

| Key | Action |
|-----|--------|
| `Hyper + Return` | Open Ghostty (terminal) |
| `Hyper + B` | Open Zen Browser |
| `Hyper + E` | Open VS Code |

### Reserved for Custom Use

| Key | Maps to |
|-----|---------|
| `Hyper + 1` | F11 |
| `Hyper + 2` | F12 |
| `Hyper + 3` | F13 |
| `Hyper + 4` | F14 |
| `Hyper + 5` | F15 |

Use these F-keys in other apps (like Aerospace) for custom shortcuts.

## Recipes

```bash
# Install config (copies to ~/.config/karabiner/)
just -f karabiner/justfile install

# Pull changes made in Karabiner GUI back to dotfiles
just -f karabiner/justfile pull

# Show diff between dotfiles and installed config
just -f karabiner/justfile diff
```

## Notes

- Karabiner modifies its config file in-place, so we use **copy** instead of symlink
- Use `just pull` to sync changes made in Karabiner GUI back to dotfiles
- Config is backed up before overwriting (karabiner.json.bak.TIMESTAMP)

## TODOs

### Enhancements (Medium Priority)

- [ ] **Add more app launchers**:
  - `Hyper + S` → Slack
  - `Hyper + N` → Notes
  - `Hyper + F` → Finder
  - `Hyper + M` → Mail

- [ ] **Device-specific rules**: Different settings for:
  - Internal MacBook keyboard
  - External mechanical keyboard
  - Configure by vendor_id/product_id

- [ ] **Text navigation**:
  - `Hyper + w` → Option + Right (word forward)
  - `Hyper + b` → Option + Left (word backward)
  - `Hyper + 0` → Cmd + Left (line start)
  - `Hyper + $` → Cmd + Right (line end)

### Integration (Low Priority)

- [ ] **Aerospace integration**: Use Hyper + 1-9 for workspace switching
  - Configure Aerospace to use F11-F19 as workspace keys

- [ ] **Goku migration**: Consider migrating to Goku for easier config
  - Write rules in EDN instead of JSON
  - https://github.com/yqrashawn/GokuRakuJoudo

### Community Rules

- [ ] **Import useful rules** from https://ke-complex-modifications.pqrs.org/
  - "Quit application by pressing Cmd+Q twice"
  - "Mouse Keys Mode"

## File Structure

```
karabiner/
├── karabiner.json    # Main config (copied to ~/.config/karabiner/)
├── brewfile          # Karabiner-Elements cask
├── justfile          # Installation recipes
├── data.yml          # Module config
├── README.md         # This file
└── examples/
    └── omerxx.karabiner.json
```

## References

- [Karabiner-Elements Website](https://karabiner-elements.pqrs.org/)
- [Complex Modifications Gallery](https://ke-complex-modifications.pqrs.org/)
- [Goku - EDN Config](https://github.com/yqrashawn/GokuRakuJoudo)
- [Karabiner God Mode](https://medium.com/@nikitavoloboev/karabiner-god-mode-7407a5ddc8f6)
