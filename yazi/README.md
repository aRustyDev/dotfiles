# yazi

Blazing fast terminal file manager written in Rust, based on async I/O.

## Current Configuration

**Status**: Stub module - no config files yet

## TODOs

### Setup (High Priority)

- [ ] **Create `yazi.toml`**: Main configuration file
  - File sorting preferences
  - Preview settings
  - Opener rules (how to open different file types)
  - Task manager settings

- [ ] **Create `keymap.toml`**: Custom keybindings
  - Vim-style navigation (already default)
  - Custom shortcuts for common operations
  - Use `prepend_keymap` or `append_keymap` to extend defaults

- [ ] **Create `theme.toml`**: Color scheme
  - Consider Catppuccin to match starship/k9s
  - Or use flavors system for themes

### Plugins (Medium Priority)

- [ ] **Install essential plugins** via `ya pack`:
  - `command-palette.yazi` - Fuzzy search keybinds
  - `mediainfo.yazi` - Detailed media file preview
  - `mime-preview.yazi` - Enhanced preview with theme colors
  - `git.yazi` - Git status in file list
  - `fzf.yazi` - Fuzzy file search integration

- [ ] **Create `init.lua`**: Plugin initialization and custom Lua functions

### Flavors/Themes

- [ ] **Install flavor**: Use `ya pack` to install themes
  - Catppuccin Mocha (to match other tools)
  - Tokyo Night
  - Dracula

### XDG Compliance

From existing TODO.md:
- [ ] Ensure logs go to `~/.local/state/yazi/`
- [ ] Config in `~/.config/yazi/`
- [ ] Plugins in `~/.config/yazi/plugins/`
- [ ] Flavors in `~/.config/yazi/flavors/`

### Integration

- [ ] **Shell integration**: Add `yy` function for cd-on-exit
  ```bash
  function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
  ```

- [ ] **Neovim integration**: Consider yazi.nvim plugin

### Data Files

- [ ] **Document expected structure**:
  ```
  ~/.config/yazi/
  ├── yazi.toml      # Main config
  ├── keymap.toml    # Keybindings
  ├── theme.toml     # Colors (or use flavors)
  ├── init.lua       # Lua initialization
  ├── plugins/       # Installed plugins
  └── flavors/       # Installed themes
  ```

## References

- [Yazi Documentation](https://yazi-rs.github.io/docs/configuration/overview/)
- [Yazi GitHub](https://github.com/sxyazi/yazi)
- [Awesome Yazi - Plugins & Flavors](https://github.com/AnirudhG07/awesome-yazi)
- [5 Essential Yazi Plugins](https://nerdpress.org/2025/11/08/5-essential-plugins-for-yazi-file-manager/)
- [Yazi Setup Guide](https://www.josean.com/posts/how-to-use-yazi-file-manager)
