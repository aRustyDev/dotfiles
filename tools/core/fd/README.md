# fd

Fast and user-friendly alternative to `find`, written in Rust.

## Current Configuration

- `.fdignore` - Global ignore patterns (symlinked to `$XDG_CONFIG_HOME/fd/ignore`)

## TODOs

### Cleanup (High Priority)

- [ ] **Populate `.fdignore`**: Currently empty, consider adding patterns
  ```
  # Common directories to ignore
  .git/
  node_modules/
  vendor/
  .terraform/
  __pycache__/
  .mypy_cache/
  .pytest_cache/
  target/
  dist/
  build/

  # Common files to ignore
  *.pyc
  *.pyo
  .DS_Store
  Thumbs.db
  ```

- [ ] **Remove `.env` file**: Contains path reference, not actually used by fd
  - fd doesn't use .env files for configuration

### Configuration (Medium Priority)

- [ ] **Consider fdignore vs global gitignore**:
  - fd respects `.gitignore` by default
  - Use `.fdignore` only for patterns specific to fd searches
  - Consider if patterns should go in global gitignore instead

### Integration (Low Priority)

- [ ] **fzf integration**: fd is commonly used with fzf
  ```bash
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  ```
  - Check if these are set in shell config

## Notes

fd automatically respects:
- `.gitignore` patterns
- `.ignore` patterns (for all tools)
- `.fdignore` patterns (fd-specific)
- Global ignore file at `$XDG_CONFIG_HOME/fd/ignore`

## References

- [fd GitHub](https://github.com/sharkdp/fd)
- [fd Documentation](https://github.com/sharkdp/fd#how-to-use)
