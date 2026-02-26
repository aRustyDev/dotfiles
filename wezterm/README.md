# wezterm

GPU-accelerated terminal emulator with Lua configuration.

## Current Configuration

- **Status**: Stub module (no config installed yet)
- `examples/` - Reference configurations

## TODOs

### Setup (Critical)

- [ ] **Create wezterm.lua**: Main configuration file
  - Config location: `~/.config/wezterm/wezterm.lua`
  - Lua-based configuration (powerful but more complex)

### Configuration (High Priority)

- [ ] **Basic config structure**:
  ```lua
  local wezterm = require 'wezterm'
  local config = wezterm.config_builder()

  -- Font
  config.font = wezterm.font 'JetBrainsMono Nerd Font'
  config.font_size = 14.0

  -- Window
  config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
  config.window_decorations = "RESIZE"

  return config
  ```

- [ ] **Color scheme**:
  ```lua
  config.color_scheme = 'Catppuccin Mocha'
  ```

- [ ] **Tab bar**:
  ```lua
  config.use_fancy_tab_bar = true
  config.tab_bar_at_bottom = false
  config.hide_tab_bar_if_only_one_tab = false
  ```

### Features (Medium Priority)

- [ ] **Built-in multiplexer**: Wezterm has tmux-like features
  ```lua
  config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
  config.keys = {
    { key = 'd', mods = 'LEADER', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 's', mods = 'LEADER', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  }
  ```

- [ ] **Workspaces**: Switch between different configurations
  ```lua
  config.default_workspace = "main"
  ```

- [ ] **SSH domains**: Direct SSH multiplexing
  ```lua
  config.ssh_domains = {
    { name = "server", remote_address = "server.example.com", username = "user" },
  }
  ```

### Theme (Medium Priority)

- [ ] **Custom status bar**: Wezterm allows Lua-based status bar
  ```lua
  wezterm.on('update-status', function(window, pane)
    -- Custom status logic
  end)
  ```

- [ ] **Background image/gradient**:
  ```lua
  config.window_background_gradient = {
    orientation = 'Vertical',
    colors = { '#0f0c29', '#302b63', '#24243e' },
  }
  ```

### Keybindings (Low Priority)

- [ ] **Custom key tables**: Modal keybindings
- [ ] **Quick select mode**: URL/path/word selection
- [ ] **Copy mode**: Vim-style selection

### Consideration

- [ ] **Terminal choice**: Wezterm is most feature-rich but complex
  - ghostty - Primary choice (simpler)
  - wezterm (this) - If needing multiplexer built-in
  - Consider if tmux/zellij already handles multiplexing needs

## References

- [Wezterm Website](https://wezfurlong.org/wezterm/)
- [Wezterm Configuration](https://wezfurlong.org/wezterm/config/files.html)
- [Catppuccin for Wezterm](https://github.com/catppuccin/wezterm)
- [Wezterm Multiplexing](https://wezfurlong.org/wezterm/multiplexing.html)
