---
id: 89290073-7f81-47af-9c37-e24c35111f40
title: Migration Guide: From Original to New Git Setup
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope: git
type: guide
status: 📝 draft
publish: false
tags:
  - git
  - documentation
aliases:
  - Migration Guide: From Original to New Git Setup
  - Migration
related: []
---

# Migration Guide: From Original to New Git Setup

This guide helps you migrate from the original `git_setup.sh` to the new profile-based system.

## What's Changing

### Old System
- Required modifying `~/.config/1Password/ssh/agent.toml`
- Added `name = "profile"` fields that broke 1Password
- Limited to predefined profiles (github, gitlab, work, home)
- Complex dependencies (yq for TOML parsing)

### New System
- No modifications to 1Password files
- Unlimited custom profiles
- Simple JSON storage
- Better error handling
- Works with 1Password SSH agent

## Migration Steps

### Step 1: Identify Your Current Profiles

Check your `~/.config/1Password/ssh/agent.toml` for entries like:

```toml
[[ssh-keys]]
vault = "Development"
item = "GitHub SSH Key"
# name = "github"  # This line you had to comment out

[[ssh-keys]]
vault = "Work"
item = "Company GitLab"
# name = "work"    # This line you had to comment out
```

### Step 2: Install the New System

```bash
# Make new scripts executable
chmod +x git/commands/git-setup-v2
chmod +x git/commands/git-setup-advanced

# Create symlink (choose one)
ln -sf ~/repos/code/personal/dotfiles/git/commands/git-setup-v2 /usr/local/bin/git-setup
# OR for advanced version
ln -sf ~/repos/code/personal/dotfiles/git/commands/git-setup-advanced /usr/local/bin/git-setup
```

### Step 3: Create Your Profiles

For each profile you had in the old system:

```bash
# Interactive setup
git setup -add

# You'll see:
# Profile name: github
# [List of SSH keys from 1Password]
# Select: GitHub SSH Key
```

Repeat for all your profiles (work, home, cisco, cfs, etc.)

### Step 4: Verify Migration

```bash
# List all migrated profiles
git setup -list

# Test a profile
cd ~/some-git-repo
git setup github

# Check configuration
git config --local --list | grep user
```

### Step 5: Clean Up (Optional)

Once you're confident the new system works:

1. Remove commented `name` fields from `agent.toml`
2. Remove the old script from your PATH
3. Update any shell aliases

## Handling Special Cases

### Custom Profile Names

The new system supports any profile name:

```bash
# Old system: Limited to github, gitlab, work, home
git setup github

# New system: Any name you want
git setup github-personal
git setup github-work
git setup client-acme
git setup opensource
```

### Multiple Keys for Same Service

```bash
# Create distinct profiles
git setup -add
# Profile name: github-personal
# Select: Personal GitHub Key

git setup -add
# Profile name: github-work
# Select: Work GitHub Key
```

### Different Email/Name Per Repository

The advanced version supports overrides:

```bash
git setup -add
# Select SSH key
# Use custom name/email? y
# Git name: John Doe (Work)
# Git email: john@company.com
```

## Troubleshooting Migration

### "Profile not found"
Your old profile names need to be recreated:
```bash
git setup -add  # Create the profile first
```

### "1Password key not found"
Ensure the SSH key still exists in 1Password:
```bash
op item list --categories "SSH Key"
```

### "Command not found"
Add to your PATH or create an alias:
```bash
alias git-setup='~/repos/code/personal/dotfiles/git/commands/git-setup-v2'
```

## Benefits After Migration

1. **No More Conflicts:** 1Password agent works normally
2. **Unlimited Profiles:** Not limited to 4 hardcoded names
3. **Better UX:** Interactive selection, fuzzy matching
4. **Cached Performance:** Faster operations (advanced version)
5. **Custom Configurations:** Override name/email per profile

## Rollback Plan

If you need to rollback:

1. The original script is preserved at `git/commands/legacy/git_setup_original.sh`
2. Re-add commented `name` fields to `agent.toml`
3. Update your PATH/aliases to point to the original

## Next Steps

- Review the [README](../commands/README.md) for full feature documentation
- Try the advanced version for better performance
- Set up shell integration for automatic profile switching
