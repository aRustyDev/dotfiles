# ripgrep

Fast line-oriented search tool (rg).

## Current Configuration

- `.ripgreprc` - Search defaults, custom types, color settings

## TODOs

### Cleanup (High Priority)

- [ ] **Remove documentation lines from config**: Lines 21-31 contain CLI help text, not actual config
  ```
  -i, --ignore-case               Case insensitive search.
  --ignore-file=PATH              Specify additional ignore files.
  ...
  ```
  These should be removed or moved to this README

- [ ] **Fix duplicate glob syntax**: Config has both inline and multi-line glob patterns
  ```
  --glob=!.git/*
  # and
  --glob
  !.git/*
  ```
  Should use consistent syntax

### Enhancements

- [ ] **Add more custom types**: Consider adding project-specific file types
  - `--type-add=config:*.{yaml,yml,toml,json}`
  - `--type-add=tf:*.{tf,tfvars}`
  - `--type-add=k8s:*.{yaml,yml}` (for manifests)
  - `--type-add=justfile:justfile`

- [ ] **Add ignore patterns**: Common directories to skip
  - `node_modules`, `vendor`, `.terraform`
  - Build output directories

- [ ] **Consider XDG compliance**: Use `$RIPGREP_CONFIG_PATH` pointing to XDG location
  - Set in shell profile: `export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"`

### Low Priority

- [ ] **Add context defaults**: Consider `--context=2` for better matches
- [ ] **Document color scheme**: Current colors use bold lines

## References

- [ripgrep User Guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
- [Configuration File](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file)
