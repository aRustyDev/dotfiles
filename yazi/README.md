# yazi

Blazing fast terminal file manager written in Rust, based on async I/O.

## Current Configuration

- `yazi.toml` - Main configuration file
- `keymap.toml` - Custom keybindings
- `brewfile` - Yazi and preview dependencies

### Features Enabled

- **Sorting**: Natural sort, directories first, case-insensitive
- **Display**: Show symlinks, hide hidden files (toggle with `.`)
- **Preview**: Full image/video/PDF preview with generous limits
- **Openers**: Smart file type detection with sensible defaults
- **Theme**: Catppuccin Mocha (via flavor)

## Installation

```bash
just -f yazi/justfile install
```

This installs:
1. Yazi and preview dependencies via Homebrew
2. Config symlinks to `~/.config/yazi/`
3. Catppuccin Mocha flavor
4. fzf and git plugins

## Keybindings

### Navigation

| Key | Action |
|-----|--------|
| `h/j/k/l` | Navigate (vim-style, default) |
| `g h` | Go to home |
| `g c` | Go to ~/.config |
| `g d` | Go to ~/Downloads |
| `g D` | Go to ~/Documents |
| `g p` | Go to ~/Projects |
| `g t` | Go to /tmp |
| `g .` | Go to dotfiles |

### File Operations

| Key | Action |
|-----|--------|
| `Ctrl+n` | Create file/directory |
| `Ctrl+r` | Rename (cursor before extension) |
| `Ctrl+y` | Copy absolute path |
| `Y` | Copy parent directory path |
| `.` | Toggle hidden files |
| `Ctrl+f` | Fuzzy find with fzf |

### General

| Key | Action |
|-----|--------|
| `Enter` | Open file |
| `o` | Open with picker |
| `y` | Yank (copy) |
| `p` | Paste |
| `d` | Delete to trash |
| `D` | Delete permanently |
| `Space` | Toggle selection |
| `q` | Quit |

## Plugins Installed

- **catppuccin-mocha.yazi** - Catppuccin Mocha theme
- **fzf.yazi** - Fuzzy file finder
- **git.yazi** - Git status indicators

## Shell Integration

Add this to your shell config for cd-on-exit functionality:

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

## TODOs

### Plugins (Medium Priority)

- [ ] **Additional plugins** to consider:
  - `mediainfo.yazi` - Detailed media file info
  - `lazygit.yazi` - Lazygit integration
  - `compress.yazi` - Archive creation

### Integration (Low Priority)

- [ ] **Neovim integration**: Consider `yazi.nvim` plugin
- [ ] **Add yy function**: To zsh/bash config for cd-on-exit

### Advanced (Low Priority)

- [ ] **Custom init.lua**: For advanced customization
  - Custom status line elements
  - Custom previewers

## File Structure

```
yazi/
├── yazi.toml     # Main config (symlinked to ~/.config/yazi/)
├── keymap.toml   # Keybindings (symlinked to ~/.config/yazi/)
├── brewfile      # Yazi and dependencies
├── justfile      # Installation recipes
├── data.yml      # Module config
└── README.md     # This file
```

## References

- [Yazi Documentation](https://yazi-rs.github.io/docs/configuration/overview/)
- [Yazi GitHub](https://github.com/sxyazi/yazi)
- [Awesome Yazi - Plugins & Flavors](https://github.com/AnirudhG07/awesome-yazi)
- [Catppuccin for Yazi](https://github.com/catppuccin/yazi)
