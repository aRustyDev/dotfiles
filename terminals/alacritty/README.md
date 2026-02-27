# alacritty

GPU-accelerated terminal emulator written in Rust.

## Current Configuration

- **Status**: Stub module (no config installed yet)

## TODOs

### Setup (Critical)

- [ ] **Create alacritty.toml**: New TOML format (v0.13+)
  - YAML format deprecated in v0.12, removed in v0.13
  - Config location: `~/.config/alacritty/alacritty.toml`

### Configuration (High Priority)

- [ ] **Font settings**:
  ```toml
  [font]
  size = 14.0

  [font.normal]
  family = "JetBrainsMono Nerd Font"
  style = "Regular"

  [font.bold]
  family = "JetBrainsMono Nerd Font"
  style = "Bold"
  ```

- [ ] **Window settings**:
  ```toml
  [window]
  decorations = "buttonless"  # Clean look on macOS
  opacity = 0.95
  blur = true
  padding = { x = 10, y = 10 }
  dynamic_padding = true

  [window.dimensions]
  columns = 120
  lines = 40
  ```

- [ ] **Cursor settings**:
  ```toml
  [cursor]
  style = { shape = "Block", blinking = "On" }
  vi_mode_style = { shape = "Block", blinking = "Off" }
  ```

- [ ] **Scrolling**:
  ```toml
  [scrolling]
  history = 10000
  multiplier = 3
  ```

### Theme (Medium Priority)

- [ ] **Catppuccin Mocha theme**: Match other tools
  ```toml
  [general]
  import = ["~/.config/alacritty/catppuccin-mocha.toml"]
  ```
  - Download from: https://github.com/catppuccin/alacritty

- [ ] **Alternative themes to consider**:
  - Tokyo Night
  - Nord
  - Dracula

### Keybindings (Medium Priority)

- [ ] **Custom keybindings**:
  ```toml
  [[keyboard.bindings]]
  key = "N"
  mods = "Command"
  action = "SpawnNewInstance"

  [[keyboard.bindings]]
  key = "Return"
  mods = "Command|Shift"
  action = "ToggleFullscreen"
  ```

- [ ] **Vi mode bindings**: If using vi mode

### Shell Integration (Low Priority)

- [ ] **Shell**: Set default shell
  ```toml
  [shell]
  program = "/opt/homebrew/bin/zsh"
  args = ["-l"]
  ```

- [ ] **Environment variables**: If needed
  ```toml
  [env]
  TERM = "xterm-256color"
  ```

### Hints (Low Priority)

- [ ] **URL hints**: Click to open URLs
  ```toml
  [[hints.enabled]]
  regex = "(https?://)[^\s]+"
  hyperlinks = true
  command = "open"
  ```

### Consideration

- [ ] **Evaluate terminal choice**: Consider which terminal to use as primary
  - `ghostty` - Already configured in this repo
  - `kitty` - Also available
  - `wezterm` - Lua configuration, feature-rich
  - `alacritty` - Fast, simple

## References

- [Alacritty GitHub](https://github.com/alacritty/alacritty)
- [Configuration Reference](https://alacritty.org/config-alacritty.html)
- [Catppuccin for Alacritty](https://github.com/catppuccin/alacritty)
- [TOML Migration Guide](https://github.com/alacritty/alacritty/blob/master/CHANGELOG.md)
