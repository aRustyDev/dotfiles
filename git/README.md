# Git Configuration

This directory contains git-related configurations and custom commands for the dotfiles repository.

## Structure

```
git/
├── commands/           # Custom git commands
│   ├── git-setup      # Main command (symlink)
│   ├── git-setup-v2   # MVP implementation
│   ├── git-setup-advanced  # Enhanced version
│   └── legacy/        # Original implementation
├── config/            # Git configuration files
├── docs/              # Documentation
│   ├── ARCHITECTURE.md
│   ├── MIGRATION.md
│   └── github-issues/ # Issue templates
├── install.sh         # Installation helper
└── setup.sh          # Setup and configuration

```

## Git Setup Command

The `git setup` command configures git repositories with SSH keys from 1Password without requiring modifications to 1Password's configuration files.

### Quick Start

```bash
# Run setup
./setup.sh

# Add a profile
git setup -add

# Use a profile
git setup github
```

### Features

- **Direct 1Password Integration**: Works with your existing SSH keys
- **Multiple Profiles**: Unlimited custom profiles (github, work, client-abc)
- **Simple Interface**: Same `git setup <profile>` command you're used to
- **No agent.toml Changes**: Works with 1Password SSH agent as-is

### Documentation

- [Command Documentation](commands/README.md) - Full usage guide
- [Architecture](docs/ARCHITECTURE.md) - Technical design
- [Migration Guide](docs/MIGRATION.md) - Upgrading from original script

## Other Git Configurations

### SSH Configuration
- Managed through 1Password SSH agent
- See `../1Password/agent.toml` for SSH key definitions

### Git Aliases
- Defined in Nix configuration
- See `../nix-darwin/hosts/programs/git.nix`

## Installation

1. **Quick Install**:
   ```bash
   cd git
   ./setup.sh
   ```

2. **Manual Install**:
   ```bash
   ln -sf ~/dotfiles/git/commands/git-setup-v2 /usr/local/bin/git-setup
   ```

3. **Nix-Darwin** (future):
   Will be integrated into the Nix configuration

## Development

### Adding New Git Commands

1. Create script in `commands/` directory
2. Make it executable: `chmod +x commands/git-newcommand`
3. Optionally symlink to PATH or create git alias

### Testing

See `docs/github-issues/issue-5-testing-framework.md` for testing plans.

## Issues and Roadmap

Track progress on the [GitHub Project Board](https://github.com/users/aRustyDev/projects/16).

Key issues:
- Transform git-setup to modern 1Password integration (Epic)
- Implement MVP version
- Add advanced features
- Create comprehensive documentation
- Build testing framework
