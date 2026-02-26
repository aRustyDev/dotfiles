# tenv

Version manager for Terraform, OpenTofu, Terragrunt, Terramate, and Atmos.

## Current Configuration

- `brewfile` - tenv and cosign for verification
- `.env` - Environment variable reference

### Features

- **Multi-tool support**: Terraform, OpenTofu, Terragrunt, Terramate, Atmos
- **Auto-install**: Automatically install versions from `.terraform-version` files
- **Constraint support**: Use version constraints like `~> 1.5.0`
- **Signature verification**: Verify downloads with cosign/PGP

## Installation

```bash
just -f tenv/justfile install
```

Add to your shell config:

```bash
export TENV_ROOT="$HOME/.tenv"
export TENV_AUTO_INSTALL=true
export PATH="$TENV_ROOT/bin:$PATH"
```

## Usage

### Terraform

```bash
# Install latest
just -f tenv/justfile tf-latest

# Install specific version
just -f tenv/justfile tf-install 1.5.7

# List installed versions
just -f tenv/justfile tf-list

# Set default version
just -f tenv/justfile tf-use 1.5.7
```

### OpenTofu

```bash
just -f tenv/justfile tofu-latest
just -f tenv/justfile tofu-install 1.6.0
just -f tenv/justfile tofu-use 1.6.0
```

### Terragrunt

```bash
just -f tenv/justfile tg-latest
just -f tenv/justfile tg-install 0.55.0
just -f tenv/justfile tg-use 0.55.0
```

### All Tools

```bash
# Install latest of all tools
just -f tenv/justfile install-all

# Show all installed versions
just -f tenv/justfile list-all

# Update all to latest
just -f tenv/justfile update-all

# Show current versions
just -f tenv/justfile info
```

## Version Files

tenv automatically detects version requirements from files:

| File | Tool |
|------|------|
| `.terraform-version` | Terraform |
| `.opentofu-version` | OpenTofu |
| `.terragrunt-version` | Terragrunt |
| `.tfswitchrc` | Terraform (tfswitch compat) |
| `required_version` in `*.tf` | Terraform/OpenTofu |

## Environment Variables

### Global

| Variable | Description |
|----------|-------------|
| `TENV_ROOT` | Installation directory (default: `~/.tenv`) |
| `TENV_AUTO_INSTALL` | Auto-install missing versions |
| `TENV_GITHUB_TOKEN` | GitHub token for API rate limits |
| `TENV_LOG` | Log level (debug, info, warn, error) |

### Tool-Specific

See `.env` file for complete list of variables for:
- Terraform (`TFENV_*`)
- OpenTofu (`TOFUENV_*`)
- Terragrunt (`TG_*`)
- Terramate (`TM_*`)
- Atmos (`ATMOS_*`)

## TODOs

### Configuration (Medium Priority)

- [ ] **Default versions**: Set up `.terraform-version` in home directory
- [ ] **Shell integration**: Add version display to starship prompt

### Integration (Low Priority)

- [ ] **Pre-commit hooks**: Auto-switch versions in git hooks
- [ ] **CI/CD**: Document GitHub Actions usage

## File Structure

```
tenv/
├── .env          # Environment variable reference
├── brewfile      # tenv package
├── justfile      # Version management recipes
├── data.yml      # Module config
└── README.md     # This file
```

## References

- [tenv GitHub](https://github.com/tofuutils/tenv)
- [tenv Documentation](https://tofuutils.github.io/tenv/)
- [Terraform Downloads](https://releases.hashicorp.com/terraform/)
- [OpenTofu Downloads](https://github.com/opentofu/opentofu/releases)
