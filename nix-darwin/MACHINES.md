# Nix-Darwin Machine Configurations

This repository contains nix-darwin configurations for multiple machines.

## Available Configurations

### 1. CFS (cfs)
- **User**: analyst
- **Build**: `sudo darwin-rebuild switch --flake .#cfs`
- **Purpose**: CFS work machine

### 2. Cisco (cisco-mbp)
- **User**: asmith
- **Build**: `sudo darwin-rebuild switch --flake .#cisco-mbp`
- **Purpose**: Cisco work machine

### 3. Personal (admz-mbp)
- **User**: adam
- **Build**: `sudo darwin-rebuild switch --flake .#admz-mbp`
- **Purpose**: Personal machine

### 4. Legacy (nw-mbp)
- **User**: analyst
- **Build**: `sudo darwin-rebuild switch --flake .#nw-mbp`
- **Purpose**: Legacy configuration for backward compatibility

## Architecture

The configuration uses a shared base configuration to avoid duplication:

- `hosts/base-home.nix` - Shared home-manager configuration for all users
- `hosts/users/cfs.nix` - User-specific config for analyst (CFS)
- `hosts/users/seneca.nix` - User-specific config for asmith (Cisco/Seneca)
- `hosts/users/personal.nix` - User-specific config for adam (Personal)
- `hosts/npm-tools/` - NPM package configurations per machine type
  - `default.json` - Common npm tools for all machines
  - `cfs.json` - CFS-specific npm tools
  - `cisco-mbp.json` - Cisco-specific npm tools
  - `admz-mbp.json` - Personal machine npm tools

## Adding a New Machine

1. Create a new user configuration in `hosts/users/username.nix`:
```nix
# User configuration for username
{ lib, pkgs, ... }:
(import ../base-home.nix {
  username = "username";
  homeDirectory = "/Users/username";
}) { inherit lib pkgs; }
```

2. Add the machine configuration to `flake.nix`:
```nix
darwinConfigurations."machine-name" = mkDarwinConfiguration {
  hostname = "machine-name";
  username = "username";
  userConfig = ./hosts/users/username.nix;
};
```

## Notes

- All machines share the same packages and dotfiles configurations
- The only differences are the username, home directory paths, and npm tools
- The base configuration is in `hosts/base-home.nix`
- NPM/Node.js packages are managed via Volta
- See `hosts/npm-tools/README.md` for npm package management details
