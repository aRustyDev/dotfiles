# NPM Tools Configuration

This directory contains configuration files for managing npm/node packages via Volta in the nix-darwin setup.

## Overview

The system uses [Volta](https://volta.sh/) as a Node.js version manager, similar to how rustup manages Rust toolchains. This allows:

- Nix manages the Volta installation
- Volta manages Node.js versions and global npm packages
- Packages can be upgraded without modifying nix configurations
- Different machines can have different sets of tools

## Configuration Files

### `default.json`
Contains npm packages that should be installed on ALL machines:
- npm (package manager)
- prettier (code formatter)
- eslint (JavaScript linter)
- typescript (TypeScript compiler)

### Machine-specific files
Each machine type has its own configuration file:
- `cfs.json` - Tools for CFS work machine
- `cisco-mbp.json` - Tools for Cisco work machine
- `admz-mbp.json` - Tools for personal machine

## Configuration Format

Each JSON file contains an array of tool objects:

```json
{
  "tools": [
    {
      "name": "@google/gemini-cli",    // npm package name
      "version": "latest",              // version or "latest"
      "enabled": true,                  // whether to install
      "description": "Google Gemini CLI tool"  // optional description
    }
  ]
}
```

## Adding New Tools

1. Edit the appropriate JSON file for your machine type
2. Add a new tool object with the npm package name
3. Set `enabled: true` to install it
4. Run `darwin-rebuild switch` to apply changes

## Manual Package Management

After initial setup, you can manage packages directly with Volta:

```bash
# Install a package globally
volta install <package-name>

# Install a specific version
volta install <package-name>@<version>

# List installed packages
volta list

# Uninstall a package
volta uninstall <package-name>
```

## Troubleshooting

### Package installation fails
- Check the package name is correct (some packages are scoped like `@org/package`)
- Verify the package exists on npm: `npm search <package-name>`
- Check Volta logs for detailed errors

### Volta command not found
- Ensure `~/.volta/bin` is in your PATH
- Source your shell configuration: `source ~/.zshrc`
- The volta binary should be at `~/.volta/bin/volta`

### Tools not available after installation
- Check if the tool was installed: `volta list`
- Verify the tool's binary is in `~/.volta/bin/`
- Restart your shell or source your configuration
