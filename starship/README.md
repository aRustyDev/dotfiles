# starship

Cross-shell prompt with minimal, blazing-fast configuration.

## Current Configuration

- `starship.toml` - Minimal left prompt, right-aligned modules, Catppuccin Mocha theme

### Prompt Layout
- **Left**: `$directory$character` (minimal)
- **Right**: `$all` (git, aws, k8s, etc.)

### Theme
- Catppuccin Mocha palette (fully defined)

## TODOs

### Cleanup (High Priority)

- [ ] **Template hardcoded AWS ARN**: Kubernetes context has hardcoded EKS ARN
  ```toml
  context_pattern = "arn:aws:eks:us-west-2:577926974532:cluster/zd-pvc-omer"
  ```
  Should use templating or move to per-machine config

- [ ] **Review disabled modules**: Currently disabled:
  - `kubernetes` - Consider enabling with proper context aliases
  - `docker_context` - Enable if using Docker contexts

### Enhancements

- [ ] **Add more kubernetes contexts**: Only one context alias defined
  - Add contexts for other clusters (personal, work profiles)

- [ ] **Add directory substitutions**: Only one substitution defined
  ```toml
  [directory.substitutions]
  '~/tests/starship-custom' = 'work-project'
  ```
  Consider adding more for common project paths

- [ ] **Configure additional modules**:
  - `terraform` - Show workspace/version
  - `python` - Show virtualenv
  - `nodejs` - Show version
  - `rust` - Show version
  - `nix_shell` - Show nix environment

- [ ] **Add custom commands**: Use `custom` module for project-specific info

### Low Priority

- [ ] **Add alternative palettes**: Consider Nord, Dracula, Gruvbox
- [ ] **Document keybindings**: If using transient prompt
- [ ] **Add continuation prompt**: Style for multi-line commands

## References

- [Starship Documentation](https://starship.rs/)
- [Configuration Options](https://starship.rs/config/)
- [Catppuccin for Starship](https://github.com/catppuccin/starship)
