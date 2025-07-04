# nix-darwin Setup for analyst Profile

## Created Files

1. **flake-analyst.nix** - Modified flake configuration for analyst user
2. **hosts/personal-analyst.nix** - Home-manager configuration for analyst
3. **makefile-analyst** - Build commands for analyst configuration
4. **backup-configs.sh** - Script to backup existing configurations

## Key Changes Made

### User Configuration
- Changed user from "greymatter" to "analyst"
- Updated home directory paths to `/Users/analyst`
- Updated dotfiles paths to `/Users/analyst/repos/code/personal/dotfiles`
- Changed darwin configuration name to "analyst-mac"

### Setup Steps

1. **Run Pre-flight Checks**:
   ```bash
   # Check architecture (should be x86_64 for this config)
   uname -m

   # Check shell (config assumes zsh)
   echo $SHELL

   # List existing Homebrew packages
   brew list
   brew list --cask
   ```

2. **Backup Existing Configurations**:
   ```bash
   cd /Users/analyst/repos/code/personal/dotfiles/nix-darwin
   ./backup-configs.sh
   ```

3. **Initial nix-darwin Setup**:
   ```bash
   # First time setup - installs nix-darwin
   nix run nix-darwin -- switch --flake .#analyst-mac --impure
   ```

4. **Subsequent Updates**:
   ```bash
   # Use the makefile commands
   make -f makefile-analyst build  # Test build
   make -f makefile-analyst switch # Apply configuration
   ```

## Important Notes

- The configuration will auto-migrate your existing Homebrew installation
- Your current shell configs will be backed up with `.nix.bak` extension
- The `.claude` directory will be linked from the prompts repository
- Experimental features (nix-command, flakes) will be enabled

## Troubleshooting

If you encounter issues:

1. Check the backup directory created by backup-configs.sh
2. Verify all required dotfiles exist in the expected locations
3. Run `darwin-rebuild check --flake .#analyst-mac` to validate config
4. Check `/etc/nix/nix.conf` for proper configuration

## Reverting Changes

To revert to pre-nix-darwin state:
1. Restore backed up files from the backup directory
2. Use `make -f makefile-analyst uninstall` (careful - this removes Nix entirely)
