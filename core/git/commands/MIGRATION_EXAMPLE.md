---
id: f739aac7-dcdf-4708-bf6a-d61368334e84
title: Git Setup Migration Example
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:38
project: dotfiles
scope: git
type: guide
status: 📝 draft
publish: false
tags:
  - git
aliases:
  - Git Setup Migration Example
  - Migration_Example
related: []
---

# Git Setup Migration Example

This example shows how to migrate from the 1Password-based system to the new local storage system.

## Current Setup (1Password agent.toml)

Your current `~/.config/1Password/ssh/agent.toml` might look like this:

```toml
[[ssh-keys]]
vault = "Development"
item = "GitHub SSH Key"
# name = "github"  # This had to be commented out!

[[ssh-keys]]
vault = "Work"
item = "GitLab Work Key"
# name = "work"    # This had to be commented out!

[[ssh-keys]]
vault = "Personal"
item = "Home Server Key"
# name = "home"    # This had to be commented out!
```

## Migration Steps

### 1. Quick Migration (Recommended)

```bash
# Navigate to your dotfiles repo
cd ~/repos/code/personal/dotfiles

# Run the import command
./git/commands/git-setup import-1password

# This will:
# - Read your agent.toml
# - Try to fetch details from 1Password
# - Prompt you for any missing information
# - Create local profiles
```

### 2. Manual Migration

If automatic import doesn't work, manually add each profile:

```bash
# Add your GitHub profile
./git/commands/git-setup add github "Your Name" "you@github.com" ~/.ssh/id_ed25519_github

# Add your work profile
./git/commands/git-setup add work "Your Name" "you@company.com" ~/.ssh/id_ed25519_work

# Add your home profile
./git/commands/git-setup add home "Your Name" "you@personal.com" ~/.ssh/id_ed25519_home

# Add additional profiles as needed
./git/commands/git-setup add cisco "Your Name" "you@cisco.com" ~/.ssh/id_ed25519_cisco
./git/commands/git-setup add cfs "Your Name" "you@cfs.com" ~/.ssh/id_ed25519_cfs
```

### 3. Verify Migration

```bash
# List all profiles
./git/commands/git-setup list

# Output should show:
# 📋 Available Git Profiles:
# --------------------------------------------------------------------------------
#   github          Your Name                 you@github.com                [SSH Key]
#   work            Your Name                 you@company.com               [SSH Key]
#   home            Your Name                 you@personal.com              [SSH Key]
#   cisco           Your Name                 you@cisco.com                 [SSH Key]
#   cfs             Your Name                 you@cfs.com                   [SSH Key]
# --------------------------------------------------------------------------------
```

## Using the New System

### Configure a Repository

```bash
# Clone a repo
git clone git@github.com:yourusername/project.git
cd project

# Configure it with your GitHub profile
git setup github

# Or for work projects
git setup work

# Or for Cisco projects
git setup cisco
```

### Update Git Aliases

Add to your `~/.gitconfig`:

```gitconfig
[alias]
    # Keep your existing setup alias working
    setup = "!f() { git-setup use \"$@\"; }; f"

    # Or if you prefer the full path
    setup = "!/Users/analyst/repos/code/personal/dotfiles/git/commands/git-setup use"
```

### Shell Integration (Optional)

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Auto-detect git profile based on directory
cd() {
    builtin cd "$@"
    if [[ -d .git ]]; then
        case "$PWD" in
            */work/*) git setup work 2>/dev/null ;;
            */cisco/*) git setup cisco 2>/dev/null ;;
            */personal/*) git setup home 2>/dev/null ;;
            */github.com/*) git setup github 2>/dev/null ;;
        esac
    fi
}

# Quick profile switching
alias gsp='git setup'
alias gsp-github='git setup github'
alias gsp-work='git setup work'
alias gsp-home='git setup home'
```

## Benefits of the New System

1. **No More Commented Fields**: The new system doesn't interfere with 1Password's agent.toml
2. **Works Offline**: No need for 1Password CLI or internet connection
3. **Multiple Profiles per Service**: Can have multiple GitHub accounts (personal, work, opensource)
4. **Portable**: Easy to backup and sync across machines
5. **Extensible**: Easy to add new features without breaking 1Password

## Data Storage

Your profiles are stored in:
- **Default (JSON)**: `~/.local/share/git-setup/profiles.json`
- **SQLite**: `~/.local/share/git-setup/profiles.db`
- **YAML**: `~/.local/share/git-setup/profiles.yaml`

You can backup these files or add them to your dotfiles repo (be careful with email addresses if your dotfiles are public).

## Troubleshooting

### Profile Not Found
```bash
# Check if profile exists
git setup show github

# List all profiles
git setup list

# Re-add if missing
git setup add github "Your Name" "you@github.com" ~/.ssh/id_ed25519_github
```

### SSH Key Issues
```bash
# Verify SSH key exists
ls -la ~/.ssh/id_ed25519_github*

# Test SSH connection
ssh -T git@github.com -i ~/.ssh/id_ed25519_github
```

### Permission Issues
```bash
# Fix script permissions
chmod +x ~/repos/code/personal/dotfiles/git/commands/git-setup*

# Fix data directory permissions
chmod 700 ~/.local/share/git-setup
chmod 600 ~/.local/share/git-setup/profiles.json
```
