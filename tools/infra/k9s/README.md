# k9s

Kubernetes CLI to manage clusters in style.

## Current Configuration

- **config.yml**: Main configuration with refresh rate, logger settings, thresholds
- **skin.yml**: Dracula theme skin

## TODOs

### High Priority

- [ ] **Add `plugins.yaml`**: Extend k9s with custom commands
  - Log streaming to external tools
  - Quick exec into containers with specific shells
  - Integration with kubectl plugins (e.g., stern, kubens)
  - Custom pod debug commands

- [ ] **Add `hotkeys.yaml`**: Custom keyboard shortcuts
  - Quick namespace switching
  - Common resource navigation (pods, deployments, services)
  - Log view shortcuts

- [ ] **Add `aliases.yaml`**: Resource shortcuts
  - Short aliases for common GVRs
  - Project-specific resource shortcuts

### Medium Priority

- [ ] **Template cluster configs**: Current config has hardcoded AWS EKS ARNs
  - Move cluster-specific settings to `data.yml`
  - Use templating for `currentContext` and `currentCluster`
  - Consider per-profile cluster configurations

- [ ] **Fix `screenDumpDir`**: Currently hardcoded to user-specific temp path
  - Should use `$XDG_STATE_HOME/k9s/screens` or similar

### Low Priority

- [ ] **Additional skins**: Consider adding alternative color schemes
  - Catppuccin, Nord, Gruvbox variants
  - Organize in `skins/` directory

- [ ] **Document keybindings**: Add quick reference for custom hotkeys

## References

- [k9s Official Site](https://k9scli.io/)
- [k9s GitHub](https://github.com/derailed/k9s)
- [Hotkeys and Aliases Documentation](https://deepwiki.com/derailed/k9s/6.2-hotkeys-and-aliases)
