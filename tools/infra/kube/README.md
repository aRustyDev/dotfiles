# kube

Kubernetes CLI tools and configuration management.

## Current Configuration

- `configs/` - Kubeconfig templates with 1Password secret references
- `shell/aliases.zsh` - kubectl aliases
- `plugin/` - Krew plugin documentation and manifests
- `brewfile` - kubectl, krew, helm, and supporting tools

### Features Enabled

- **Kubeconfig Templates**: Secure configs with 1Password integration
- **Krew Plugins**: Curated list of essential kubectl plugins
- **Shell Aliases**: Common kubectl shortcuts
- **Context Management**: kubectx/kubens for fast switching

## Installation

```bash
just -f kube/justfile install
```

This installs:
1. kubectl, krew, helm, and other tools via Homebrew
2. Recommended krew plugins (ctx, ns, neat, tree, etc.)
3. Creates `~/.kube/` directory

## Kubeconfig Management

Kubeconfig templates in `configs/` use 1Password secret references for security.

### Inject Secrets

```bash
# Inject a specific config
just -f kube/justfile inject orbstack

# Inject all configs
just -f kube/justfile inject-all

# Merge all configs into single file
just -f kube/justfile merge
```

### Available Configs

| Config | Description |
|--------|-------------|
| `orbstack` | Local OrbStack Kubernetes |
| `blvd` | BLVD cluster |
| `cisco.ite-devops` | Cisco ITE DevOps |

## Shell Aliases

Add to your shell config:

```bash
source /etc/dotfiles/adam/kube/shell/aliases.zsh
```

| Alias | Command |
|-------|---------|
| `k` | `kubectl` |
| `ka` | `kubectl --all-namespaces` |
| `kg` | `kubectl get` |
| `kag` | `kubectl get --all-namespaces` |
| `kgp` | `kubectl get pods` |
| `kagp` | `kubectl get pods --all-namespaces` |
| `kgs` | `kubectl get services` |
| `kags` | `kubectl get services --all-namespaces` |
| `k9` | `k9s` |

## Krew Plugins

### Installed by Default

| Plugin | Description |
|--------|-------------|
| `ctx` | Switch contexts quickly |
| `ns` | Switch namespaces quickly |
| `neat` | Remove clutter from YAML output |
| `tree` | Show resource ownership hierarchy |
| `whoami` | Show current user/serviceaccount |
| `who-can` | Show who can perform an action |
| `get-all` | Get all resources in namespace |
| `status` | Show rollout status overview |
| `stern` | Multi-pod log tailing |

### Managing Plugins

```bash
# Update plugin index
just -f kube/justfile krew-update

# List installed plugins
just -f kube/justfile krew-list

# Install additional plugin
kubectl krew install <plugin>
```

### Plugin Categories

See `plugin/lists/` for categorized plugin recommendations:
- `debug.md` - Debugging and troubleshooting
- `context.md` - Context and namespace management
- `kubeconfig.md` - Kubeconfig utilities
- `output.md` - Output formatting
- `volumes.md` - Volume management
- `certificates.md` - Certificate management

## Recipes

```bash
# Show current context
just -f kube/justfile current

# Show config info
just -f kube/justfile info

# List available kubeconfig templates
just -f kube/justfile list-configs
```

## TODOs

### Enhancements (Medium Priority)

- [ ] **Add more aliases**: exec, logs, describe shortcuts
- [ ] **Kubecolor integration**: Alias kubectl to kubecolor
- [ ] **FZF integration**: Fuzzy context/namespace switching

### Integration (Low Priority)

- [ ] **Starship segment**: Show current context/namespace
- [ ] **Teleport integration**: Agentless SSH setup

## File Structure

```
kube/
├── configs/              # Kubeconfig templates (1Password refs)
│   ├── orbstack.yaml
│   ├── blvd.yaml
│   └── cisco.ite-devops.yaml
├── shell/
│   └── aliases.zsh       # kubectl aliases
├── plugin/
│   ├── manifest.yaml     # Plugin inventory
│   ├── indexes.yaml      # Custom krew indexes
│   ├── install.sh        # Krew installer
│   └── lists/            # Plugin documentation by category
├── brewfile              # CLI tools
├── justfile              # Installation recipes
├── data.yml              # Module config
└── README.md             # This file
```

## References

- [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)
- [Krew Plugin Manager](https://krew.sigs.k8s.io/)
- [kubectx/kubens](https://github.com/ahmetb/kubectx)
- [1Password CLI](https://developer.1password.com/docs/cli/)
- [Stern - Multi-pod Logging](https://github.com/stern/stern)
