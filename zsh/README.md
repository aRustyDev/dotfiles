# Zsh

1. `/etc/zshenv` : System
2. `~/.zshenv` : HOME (if exists)
3. `$ZDOTDIR/.zshenv` : Your intended one
4. `/etc/zprofile` : System (login shells)
5. `~/.zprofile` or `$ZDOTDIR/.zprofile`
6. `/etc/zshrc` : System (interactive)
7. `~/.zshrc` : HOME (if ZDOTDIR not set!)
8. `$ZDOTDIR/.zshrc` : Your intended one

### Ideas

```
- .Xdefaults
- .aliasrc
- .functions
- .profile
- .shellrc
```
