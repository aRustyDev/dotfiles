# zsh

Z Shell configuration with XDG Base Directory compliance.

## Current Configuration

- `.zshenv` - Environment variables (sourced always)
- `.zshrc` - Interactive shell config
- `.zprofile` - Login shell config
- `.zlogin` - Login shell (after .zshrc)
- `init/` - Initialization scripts
- `plugins/` - Plugin configurations
- `functions/` - Custom zsh functions
- `completions/` - Completion definitions
- `etc/.zshenv` - System-wide zshenv for ZDOTDIR

## File Loading Order

1. `/etc/zshenv` - System (sets ZDOTDIR)
2. `~/.zshenv` - HOME (if exists)
3. `$ZDOTDIR/.zshenv` - Your config
4. `/etc/zprofile` - System (login shells)
5. `$ZDOTDIR/.zprofile` - Your profile
6. `/etc/zshrc` - System (interactive)
7. `$ZDOTDIR/.zshrc` - Your rc file
8. `$ZDOTDIR/.zlogin` - Login completion

## TODOs

### Cleanup (High Priority)

- [ ] **Review .zshenv size**: 12KB is large for zshenv
  - Consider moving non-critical exports to .zprofile
  - Environment variables should be minimal

- [ ] **Audit .zshrc**: 6KB - review for performance
  - Profile startup time: `time zsh -i -c exit`
  - Consider lazy loading with zsh-defer

### Configuration (From TODO.md)

- [ ] **Build Dotfiles**: Configure `$HISTFILE` properly

- [ ] **Build Dotdirs**: Ensure XDG directories are created
  - `$HOME_CONFIG` / `$XDG_CONFIG_HOME`
  - `$HOME_CACHE` / `$XDG_CACHE_HOME`
  - `$HOME_DATA` / `$XDG_DATA_HOME`
  - `$HOME_PKG`
  - `$HOME_LIB`
  - `$ZSH_EVALCACHE_DIR`

- [ ] **Performance optimization**:
  - zsh-defer for lazy loading
  - evalcache for caching slow evals

### System Integration

- [ ] **Manage /etc/shells**: Add Homebrew zsh
  ```bash
  /opt/homebrew/bin/zsh
  ```

- [ ] **Set default shell**:
  ```bash
  chsh -s /opt/homebrew/bin/zsh
  ```

- [ ] **1Password SSH agent**: Configure LaunchAgent
  ```bash
  mkdir -p ~/Library/LaunchAgents
  cp $HOME/nix/1Password/com.1password.SSH_AUTH_SOCK.plist ~/Library/LaunchAgents/
  launchctl load -w ~/Library/LaunchAgents/com.1password.SSH_AUTH_SOCK.plist
  ```

### Features (Medium Priority)

- [ ] **Teleport integration**: Agentless SSH support

- [ ] **Version management**: Track critical tool versions
  - Clang, Git, Curl, GCC
  - zsh, bash versions

- [ ] **Completions**: Ensure all tools have completions
  ```zsh
  compdef _op op  # 1Password
  ```

### Enhancements (Low Priority)

- [ ] **Consider alternative shells**:
  - `fish` - User-friendly
  - `nushell` - Structured data
  - `elvish` - Modern shell

- [ ] **Modularize configuration**:
  - `.aliasrc` - Aliases only
  - `.functions` - Functions only
  - `.profile` - Profile settings

## References

- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Zsh Lovers](https://grml.org/zsh/zsh-lovers.html)
- [XDG Base Directory](https://wiki.archlinux.org/title/XDG_Base_Directory)
- [zsh-defer](https://github.com/romkatv/zsh-defer)
- [evalcache](https://github.com/mroth/evalcache)
