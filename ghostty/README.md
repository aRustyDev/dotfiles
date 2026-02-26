# ghostty

GPU-accelerated terminal emulator with native platform feel.

## Current Configuration

- `config` - Main configuration file
- `configs/` - Additional config snippets
- `themes/` - Color themes (Catppuccin Macchiato active)

### Features Enabled
- **Font**: JetBrains Mono, size 14, thickened
- **Theme**: Catppuccin Macchiato
- **Window**: 10px padding, native decorations, tabbed titlebar
- **Shell**: zsh with integration
- **Keybindings**: Cmd+D split, Cmd+K clear, Cmd+Shift+Enter fullscreen

## TODOs

### Cleanup (High Priority)

- [ ] **Review configs/ directory**: Check what config snippets exist
  - Determine if they're being used or should be consolidated

- [ ] **Review themes/ directory**: Check custom themes
  - Verify Catppuccin Macchiato is properly set up
  - Remove unused themes

### Keybindings (From TODO.md)

- [ ] **Equalize split sizes**: Add keybinding for `equalize_splits`
  ```
  keybind = cmd+shift+e=equalize_splits
  ```

- [ ] **Additional split keybindings to consider**:
  ```
  keybind = cmd+shift+d=new_split:down
  keybind = cmd+[=previous_tab
  keybind = cmd+]=next_tab
  keybind = cmd+w=close_tab
  keybind = cmd+t=new_tab
  ```

### Enhancements (Medium Priority)

- [ ] **Font ligatures**: If using a font that supports them
  ```
  font-feature = calt
  font-feature = liga
  ```

- [ ] **Adjust opacity/blur**: For transparency effect
  ```
  background-opacity = 0.95
  background-blur-radius = 20
  ```

- [ ] **Quick terminal shortcut**: Consider global hotkey
  ```
  keybind = global:cmd+`=toggle_quick_terminal
  quick-terminal-position = top
  quick-terminal-screen = mouse
  ```

- [ ] **URL handling**: Click to open URLs
  ```
  link-url = true
  ```

### Configuration (Low Priority)

- [ ] **Explore shell integration features**:
  ```
  shell-integration-features = cursor,sudo,title
  ```

- [ ] **Confirm paths**: Check that config, configs, themes are being loaded correctly

- [ ] **Image support**: Ghostty supports inline images
  ```
  image-storage-limit = 320000000
  ```

### Consideration

- [ ] **Terminal choice**: Multiple terminals configured
  - ghostty (this module) - Primary choice, modern
  - alacritty - Simple, fast
  - kitty - Feature-rich
  - wezterm - Lua config, multiplexer built-in

## References

- [Ghostty Website](https://ghostty.org/)
- [Ghostty Configuration](https://ghostty.org/docs/config)
- [Catppuccin for Ghostty](https://github.com/catppuccin/ghostty)
