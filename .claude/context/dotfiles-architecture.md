# Dotfiles Architecture Overview

## Repository Structure

The dotfiles repository uses Nix-Darwin and Home Manager to manage macOS system configuration declaratively.

### Core Directories

```
dotfiles/
├── nix-darwin/           # Nix-Darwin configurations
│   ├── flake.nix        # Main flake entry point
│   ├── flake.lock       # Pinned dependencies
│   ├── configuration.nix # System-level settings
│   ├── hosts/           # Machine-specific configs
│   │   ├── base.nix     # Shared base configuration
│   │   └── users/       # User-specific configs
│   └── modules/         # Custom Nix modules
├── mcp/                 # MCP server configurations
├── git/                 # Git configuration and tools
├── scripts/             # Utility scripts
├── .claude/             # Claude AI context
└── <app-configs>/       # Individual app configurations
```

## Configuration Hierarchy

1. **flake.nix**: Entry point, defines all machine configurations
2. **configuration.nix**: System-wide settings (packages, services)
3. **hosts/base.nix**: Shared configuration for all users
4. **hosts/users/*.nix**: User-specific configurations
5. **modules/*.nix**: Reusable Nix modules

## Key Principles

### Declarative Configuration
- All system configuration defined in Nix files
- Reproducible builds across machines
- Version controlled with Git

### Modular Design
- Separate modules for different concerns
- Base configuration shared across users
- Machine-specific overrides supported

### Home Manager Integration
- User environment management
- Application configurations
- Dotfile management

## Configuration Flow

1. `darwin-rebuild` reads flake.nix
2. Loads machine-specific configuration
3. Imports base and user configurations
4. Applies all modules
5. Builds and activates configuration

## Important Files

### flake.nix
- Defines nixpkgs input
- Specifies Home Manager integration
- Lists all machine configurations

### hosts/base.nix
- Common packages for all users
- Shared shell aliases
- Base program configurations
- Module imports

### User Configurations
- Personal package selections
- User-specific environment variables
- Custom program settings
- Shell configurations

## Module System

Custom modules in `modules/` directory:
- `git-commands.nix`: Git setup system
- `mcp-servers.nix`: MCP server management
- Future modules for other tools

Each module follows the pattern:
- Options definition
- Configuration implementation
- Home Manager integration
