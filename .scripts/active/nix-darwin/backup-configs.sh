#!/bin/bash

# Backup script for existing configurations before applying nix-darwin
# Run this before applying the new configuration

BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

echo "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Function to backup a file or directory if it exists
backup_if_exists() {
    local source="$1"
    local dest_name="$2"

    if [ -e "$source" ]; then
        echo "Backing up: $source"
        cp -R "$source" "$BACKUP_DIR/$dest_name"
    else
        echo "Skipping (not found): $source"
    fi
}

# Backup shell configurations
backup_if_exists "$HOME/.zshrc" "zshrc"
backup_if_exists "$HOME/.zprofile" "zprofile"
backup_if_exists "$HOME/.zshenv" "zshenv"
backup_if_exists "$HOME/.bashrc" "bashrc"
backup_if_exists "$HOME/.bash_profile" "bash_profile"

# Backup config directory items
backup_if_exists "$HOME/.config/zsh" "config-zsh"
backup_if_exists "$HOME/.config/starship.toml" "starship.toml"
backup_if_exists "$HOME/.config/1Password" "config-1Password"
backup_if_exists "$HOME/.config/nvim" "config-nvim"
backup_if_exists "$HOME/.config/tmux" "config-tmux"
backup_if_exists "$HOME/.config/zellij" "config-zellij"

# Backup nix-related configs if they exist
backup_if_exists "$HOME/.config/nix" "config-nix"
backup_if_exists "$HOME/.config/nix-darwin" "config-nix-darwin"

# List current Homebrew packages for reference
if command -v brew &> /dev/null; then
    echo "Saving Homebrew package list..."
    brew list > "$BACKUP_DIR/brew-packages.txt"
    brew list --cask > "$BACKUP_DIR/brew-casks.txt"
fi

echo ""
echo "Backup completed to: $BACKUP_DIR"
echo ""
echo "To restore a specific file later:"
echo "  cp $BACKUP_DIR/<filename> <original-location>"
echo ""
echo "Keep this backup until you've verified the new configuration works correctly."
