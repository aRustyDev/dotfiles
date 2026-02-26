# tmux

Terminal multiplexer for managing multiple terminal sessions.

## Current Configuration

- **Status**: Stub module (no config installed yet)
- `examples/` - Reference configurations
- `scripts/cal.sh` - Calendar meeting integration script

## TODOs

### Setup (Critical)

- [ ] **Create tmux.conf**: Build configuration from examples
  - Base on `examples/omerxx.tmux.conf` (comprehensive setup)
  - Review `examples/mathiasbynens.tmux.conf` for additional ideas

- [ ] **Install TPM (Tmux Plugin Manager)**:
  ```bash
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ```
  - Add TPM installation to brewfile or setup script

- [ ] **Create reset.conf**: For clean keybinding state
  - Referenced in example: `source-file ~/.config/tmux/tmux.reset.conf`

### Configuration (High Priority)

- [ ] **Core settings to include**:
  ```tmux
  set -g prefix ^A                 # Change prefix from Ctrl+b to Ctrl+a
  set -g base-index 1              # Start window numbering at 1
  set -g detach-on-destroy off     # Don't exit when closing session
  set -g escape-time 0             # No escape delay
  set -g history-limit 1000000     # Large scrollback
  set -g renumber-windows on       # Auto-renumber windows
  set -g set-clipboard on          # System clipboard
  set -g status-position top       # macOS style
  setw -g mode-keys vi             # Vim keybindings
  ```

- [ ] **Terminal/color settings**:
  ```tmux
  set -g default-terminal 'screen-256color'
  set -g terminal-overrides ',xterm-256color:RGB'
  ```

### Plugins (Medium Priority)

- [ ] **Essential plugins to configure**:
  - `tmux-plugins/tpm` - Plugin manager
  - `tmux-plugins/tmux-sensible` - Sensible defaults
  - `tmux-plugins/tmux-yank` - Copy to system clipboard
  - `tmux-plugins/tmux-resurrect` - Save/restore sessions
  - `tmux-plugins/tmux-continuum` - Auto-save sessions

- [ ] **Enhanced navigation**:
  - `christoomey/vim-tmux-navigator` - Seamless vim/tmux navigation
  - `omerxx/tmux-sessionx` - Session management with fzf

- [ ] **Productivity plugins**:
  - `sainnhe/tmux-fzf` - Fuzzy finder integration
  - `wfxr/tmux-fzf-url` - URL picker
  - `fcsonline/tmux-thumbs` - Quick copy mode
  - `omerxx/tmux-floax` - Floating panes

### Theme (Medium Priority)

- [ ] **Catppuccin theme**: Already using in other tools
  - Use `catppuccin/tmux` or fork
  - Configure status bar modules: session, directory, date/time
  - Match pane border colors with theme

### Scripts (Low Priority)

- [ ] **Review cal.sh script**: Uses icalBuddy for macOS
  - Add icalBuddy to brewfile if using
  - Update hardcoded calendar exclusions
  - Consider generalizing or removing if not needed

- [ ] **Add session management scripts**:
  - Project-specific session launchers
  - Dev environment templates

### Integration

- [ ] **Neovim integration**: Seamless navigation
  - vim-tmux-navigator on both sides
  - Unified keybindings

- [ ] **Shell integration**: Auto-attach to sessions
  ```bash
  if [[ -z "$TMUX" ]]; then
    tmux attach -t default || tmux new -s default
  fi
  ```

- [ ] **Zellij consideration**: Evaluate if tmux or zellij or both
  - zellij already configured in this dotfiles repo

## References

- [Tmux GitHub](https://github.com/tmux/tmux)
- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Catppuccin for Tmux](https://github.com/catppuccin/tmux)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
- [Omerxx Tmux Guide](https://github.com/omerxx/dotfiles)
