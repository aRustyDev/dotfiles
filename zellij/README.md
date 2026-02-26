# zellij

A terminal workspace with batteries included - modern terminal multiplexer written in Rust.

## Current Configuration

- `config.kdl` - Full configuration with custom keybindings, themes, plugins
- `examples/` - Example configurations

### Features Enabled
- **Theme**: Catppuccin Mocha
- **Keybindings**: Vim-style with tmux compatibility layer (`Ctrl+b` prefix)
- **UI**: Simplified UI, no pane frames
- **On force close**: Detach (preserves session)

## TODOs

### Cleanup (Critical)

- [ ] **Fix hardcoded `theme_dir` path** (Line 320):
  ```kdl
  theme_dir "/Users/omerxx/dotfiles/zellij/themes"
  ```
  Should be relative or use environment variable

- [ ] **Fix commented `layout_dir` path** (Line 316):
  ```kdl
  // layout_dir "/Users/omerhamerman/dotfiles/zellij/layouts"
  ```
  Different username - clean up or fix

- [ ] **Remove or update commented Dracula theme** (Lines 230-244):
  Already using Catppuccin - remove unused theme definition

### Cleanup (Medium)

- [ ] **Duplicate `SwitchToMode "Normal"`** in tab bindings (Lines 55-56):
  ```kdl
  bind "n" { NewTab; SwitchToMode "Normal"; SwitchToMode "Normal"; }
  ```
  Remove duplicate

- [ ] **Duplicate `Ctrl x` binding** in session mode (Lines 113-114):
  ```kdl
  bind "Ctrl x" { SwitchToMode "Normal"; }
  bind "Ctrl x" { SwitchToMode "Scroll"; }
  ```
  Conflicting bindings - fix or remove one

### Enhancements

- [ ] **Add custom layouts**: Create reusable workspace layouts
  - `layouts/dev.kdl` - Development (editor + terminal + logs)
  - `layouts/k8s.kdl` - Kubernetes (k9s + logs + shell)
  - `layouts/monitoring.kdl` - System monitoring

- [ ] **Add themes directory**: Organize color schemes
  - Create `themes/` directory
  - Add alternative themes (Nord, Dracula, Tokyo Night)

- [ ] **Explore plugins**:
  - `strider` - Built-in file picker (already configured)
  - `session-manager` - Session switching (already configured)
  - `room` - Multiplayer collaboration
  - `zellij-forgot` - Command history/cheatsheet

- [ ] **Add floating pane shortcuts**: Quick access to common tools
  - Floating terminal for quick commands
  - Floating file picker
  - Floating git status

### Integration

- [ ] **Shell integration**: Add zellij auto-attach to shell config
  ```bash
  if [[ -z "$ZELLIJ" ]]; then
    zellij attach -c default
  fi
  ```

- [ ] **Neovim integration**: Configure for seamless navigation
  - Smart splits plugin compatibility
  - Unified keybindings across zellij/nvim

### Low Priority

- [ ] **Document keybinding cheatsheet**: Quick reference for custom bindings
- [ ] **Add session templates**: Named sessions for different projects
- [ ] **Configure scroll buffer size**: Currently using default 10000

## Keybinding Reference

| Mode | Key | Action |
|------|-----|--------|
| Normal | `Ctrl+a` | Pane mode |
| Normal | `Ctrl+t` | Tab mode |
| Normal | `Ctrl+n` | Resize mode |
| Normal | `Ctrl+s` | Scroll mode |
| Normal | `Ctrl+x` | Session mode |
| Normal | `Ctrl+b` | Tmux mode |
| Normal | `Ctrl+g` | Lock mode |
| Any | `Alt+n` | New pane |
| Any | `Alt+h/l` | Move focus left/right |

## References

- [Zellij Official Site](https://zellij.dev/)
- [Zellij GitHub](https://github.com/zellij-org/zellij)
- [Zellij Configuration Guide](https://zellij.dev/documentation/)
- [Zellij Workflow Guide](https://haseebmajid.dev/posts/2024-12-18-part-7-zellij-as-part-of-your-development-workflow/)
- [Zellij Setup Tips](https://srekubecraft.io/posts/zellij/)
