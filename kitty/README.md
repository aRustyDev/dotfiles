# kitty

GPU-accelerated terminal emulator with extensive features and configurability.

## Current Configuration

- **Status**: Stub module (no config installed yet)

## TODOs

### Setup (Critical)

- [ ] **Create kitty.conf**: Main configuration file
  - Config location: `~/.config/kitty/kitty.conf`

### Configuration (High Priority)

- [ ] **Font settings**:
  ```conf
  font_family      JetBrainsMono Nerd Font
  bold_font        auto
  italic_font      auto
  bold_italic_font auto
  font_size        14.0
  ```

- [ ] **Window settings**:
  ```conf
  window_padding_width 10
  hide_window_decorations titlebar-only
  confirm_os_window_close 0
  background_opacity 0.95
  ```

- [ ] **Tab bar**:
  ```conf
  tab_bar_edge top
  tab_bar_style powerline
  tab_powerline_style slanted
  ```

- [ ] **Cursor**:
  ```conf
  cursor_shape block
  cursor_blink_interval 0.5
  ```

### Theme (Medium Priority)

- [ ] **Catppuccin Mocha theme**: Match other tools
  ```conf
  include themes/catppuccin-mocha.conf
  ```
  - Download from: https://github.com/catppuccin/kitty

### Keybindings (Medium Priority)

- [ ] **Tab management**:
  ```conf
  map cmd+t new_tab
  map cmd+w close_tab
  map cmd+[ previous_tab
  map cmd+] next_tab
  ```

- [ ] **Split management**:
  ```conf
  map cmd+d new_window_with_cwd
  map cmd+shift+d launch --cwd=current --location=hsplit
  ```

- [ ] **Scrollback**:
  ```conf
  scrollback_lines 10000
  map cmd+k clear_terminal scrollback active
  ```

### Features (Low Priority)

- [ ] **Shell integration**:
  ```conf
  shell_integration enabled
  ```

- [ ] **URL handling**:
  ```conf
  detect_urls yes
  open_url_with default
  ```

- [ ] **Kittens (plugins)**:
  - `icat` - Image display
  - `diff` - Side-by-side diff
  - `ssh` - SSH with kitty features

### Consideration

- [ ] **Terminal choice**: Multiple terminals configured
  - ghostty - Primary choice
  - alacritty - Minimal
  - kitty (this module) - Feature-rich
  - wezterm - Lua config

## References

- [Kitty Documentation](https://sw.kovidgoyal.net/kitty/)
- [Kitty Configuration](https://sw.kovidgoyal.net/kitty/conf/)
- [Catppuccin for Kitty](https://github.com/catppuccin/kitty)
