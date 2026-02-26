# tmux

Terminal multiplexer for managing multiple terminal sessions.

## Current Configuration

- `tmux.conf` - Main configuration with Catppuccin theme
- `tmux.reset.conf` - Clean keybinding reset
- `brewfile` - Dependencies (tmux, fzf, reattach-to-user-namespace)
- `examples/` - Reference configurations
- `scripts/cal.sh` - Calendar meeting integration script (optional)

### Features Enabled

- **Prefix**: `Ctrl+a` (instead of default `Ctrl+b`)
- **Theme**: Catppuccin Mocha
- **Vi mode**: Vim keybindings in copy mode
- **Mouse**: Full mouse support enabled
- **Status bar**: Top position with session, directory, time
- **Clipboard**: System clipboard integration (macOS)

### Plugins (via TPM)

- `tmux-sensible` - Sensible defaults
- `tmux-yank` - Copy to system clipboard
- `tmux-resurrect` - Save/restore sessions
- `tmux-continuum` - Auto-save sessions (every 15 min)
- `catppuccin/tmux` - Theme
- `tmux-fzf` - Fuzzy finder integration
- `fzf-url` - URL picker

## Installation

```bash
just -f tmux/justfile install
```

Then in tmux, press `prefix + I` to install plugins.

## Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+a` | Prefix (instead of Ctrl+b) |
| `prefix + r` | Reload config |
| `prefix + \|` | Split pane vertically |
| `prefix + -` | Split pane horizontally |
| `prefix + h/j/k/l` | Navigate panes (vim-style) |
| `prefix + Ctrl+h/j/k/l` | Resize panes |
| `prefix + Tab` | Switch to last window |
| `prefix + c` | New window (in current path) |
| `prefix + I` | Install plugins (TPM) |
| `prefix + U` | Update plugins (TPM) |

### Copy Mode (vi)

| Key | Action |
|-----|--------|
| `prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `y` | Copy selection |
| `Enter` | Copy and exit |

## TODOs

### Enhancements (Medium Priority)

- [ ] **Add vim-tmux-navigator**: Seamless navigation between vim and tmux
  ```
  set -g @plugin 'christoomey/vim-tmux-navigator'
  ```

- [ ] **Add sessionx**: Enhanced session management with fzf
  ```
  set -g @plugin 'omerxx/tmux-sessionx'
  ```

- [ ] **Add floax**: Floating panes
  ```
  set -g @plugin 'omerxx/tmux-floax'
  ```

- [ ] **Add thumbs**: Quick copy mode
  ```
  set -g @plugin 'fcsonline/tmux-thumbs'
  ```

### Scripts (Low Priority)

- [ ] **Review cal.sh script**: Uses icalBuddy for macOS calendar integration
  - Add icalBuddy to brewfile if using
  - Update hardcoded calendar exclusions
  - Integrate with catppuccin status bar

- [ ] **Add session templates**: Project-specific session launchers
  - Development environment
  - DevOps/k8s environment

### Integration (Low Priority)

- [ ] **Neovim integration**: Configure vim-tmux-navigator on nvim side

- [ ] **Shell auto-attach**: Add to shell config
  ```bash
  if [[ -z "$TMUX" ]]; then
    tmux attach -t default || tmux new -s default
  fi
  ```

- [ ] **Zellij consideration**: Evaluate if both tmux and zellij are needed
  - zellij already configured in this dotfiles repo

## File Structure

```
tmux/
├── tmux.conf          # Main config (symlinked to ~/.config/tmux/)
├── tmux.reset.conf    # Keybinding reset
├── brewfile           # Dependencies
├── justfile           # Installation recipes
├── data.yml           # Module config
├── README.md          # This file
├── examples/          # Reference configs
│   ├── omerxx.tmux.conf
│   └── mathiasbynens.tmux.conf
└── scripts/
    └── cal.sh         # Calendar integration (optional)
```

## References

- [Tmux GitHub](https://github.com/tmux/tmux)
- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Catppuccin for Tmux](https://github.com/catppuccin/tmux)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
- [Dreams of Code - Tmux Setup](https://www.youtube.com/watch?v=DzNmUNvnB04)
- [omerxx/dotfiles](https://github.com/omerxx/dotfiles)
