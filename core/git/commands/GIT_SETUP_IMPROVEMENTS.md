---
id: 76b1e6cf-c209-4337-8d91-2f0c67946435
title: Git Setup Script Improvements
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
  - Git Setup Script Improvements
  - Git_Setup_Improvements
related: []
---

# Git Setup Script Improvements

## Overview

This document outlines the improvements made to the `git setup` script to remove the dependency on 1Password's agent.toml and the need for commented-out "name" fields.

## Solutions Provided

### 1. **SQLite-Based Bash Script** (`git-setup-sqlite.sh`)

A pure bash implementation using SQLite as the backend storage.

**Features:**
- Lightweight SQLite database for profile storage
- No external dependencies beyond SQLite (included in macOS)
- Compatible with existing git setup workflow
- Supports profile CRUD operations

**Usage:**
```bash
# Initialize and add profiles
git-setup init
git-setup add github "John Doe" "john@github.com" ~/.ssh/id_github
git-setup add work "John Doe" "john@company.com" ~/.ssh/id_work
git-setup add home "John Doe" "john@personal.com" ~/.ssh/id_personal

# Use a profile in current repo
git-setup use github
```

### 2. **Python-Based Multi-Backend Manager** (`git-setup-manager.py`)

A more flexible Python implementation supporting multiple storage backends.

**Features:**
- Multiple backend support (SQLite, JSON, YAML)
- Better error handling and validation
- Import functionality from 1Password
- Secure credential storage options
- Extensible architecture

**Backends:**
- **JSON** (default): Simple, human-readable, version-control friendly
- **SQLite**: Robust, queryable, good for many profiles
- **YAML**: Human-friendly, good for manual editing

**Usage:**
```bash
# Using JSON backend (default)
git-setup add github "John Doe" "john@github.com" ~/.ssh/id_github
git-setup use github

# Using different backends
git-setup --backend sqlite add work "John Doe" "john@work.com" ~/.ssh/id_work
git-setup --backend yaml list

# Import from 1Password (one-time migration)
git-setup import-1password
```

## Migration Path from 1Password

### Step 1: Export Current Configuration

The Python script includes an import function that reads your existing 1Password agent.toml:

```bash
# This will read your agent.toml and help you create profiles
./git-setup-manager.py import-1password
```

### Step 2: Manual Migration

If automatic import doesn't work, manually create profiles:

```bash
# For each SSH key in your agent.toml
git-setup add <profile-name> "<Your Name>" "email@example.com" ~/.ssh/keyfile
```

### Step 3: Update Git Aliases

Update your git aliases to use the new script:

```bash
# In ~/.gitconfig or ~/.config/git/config
[alias]
    setup = "!/path/to/git-setup-manager.py use"
```

## Advantages Over Current Implementation

1. **No 1Password Dependency**: Works offline and doesn't require 1Password CLI
2. **No agent.toml Parsing**: Eliminates the need for complex TOML parsing
3. **No Commented Fields**: No need for commented "name" fields that break 1Password
4. **Multiple Profiles per Registry**: Can have multiple GitHub accounts, work accounts, etc.
5. **Portable**: Database/config files can be synced across machines
6. **Extensible**: Easy to add new features like profile templates, inheritance, etc.

## Security Considerations

1. **SSH Keys**: Only public keys are stored; private keys remain in ~/.ssh/
2. **Database Security**:
   - JSON/YAML files should have 600 permissions
   - SQLite database should have 600 permissions
   - Consider encrypting sensitive data if needed
3. **Credential Storage**: Email and names are stored in plain text (like .gitconfig)

## Additional Features

### Profile Templates

You can create template profiles for common scenarios:

```python
# Add to git-setup-manager.py
PROFILE_TEMPLATES = {
    'opensource': {
        'display_name': 'Your Name',
        'email': 'opensource@example.com',
        'metadata': {'commit_style': 'conventional'}
    },
    'work': {
        'display_name': 'Your Name (Company)',
        'email': 'you@company.com',
        'metadata': {'sign_commits': True}
    }
}
```

### Environment-Based Selection

Add logic to automatically select profiles based on repository location:

```python
def auto_select_profile():
    cwd = os.getcwd()
    if '/work/' in cwd:
        return 'work'
    elif '/personal/' in cwd:
        return 'personal'
    return 'default'
```

### Integration with Shell

Add shell functions for easier usage:

```bash
# Add to ~/.zshrc or ~/.bashrc
gsp() {
    # Git Setup Profile
    git-setup use "$1"
}

# Auto-setup based on directory
cd() {
    builtin cd "$@"
    if [[ -d .git ]]; then
        if [[ "$PWD" == *"/work/"* ]]; then
            git-setup use work 2>/dev/null
        elif [[ "$PWD" == *"/personal/"* ]]; then
            git-setup use personal 2>/dev/null
        fi
    fi
}
```

## Comparison Table

| Feature | Current (1Password) | SQLite Bash | Python Manager |
|---------|-------------------|--------------|----------------|
| Dependencies | op, yq, jq | sqlite3 | python3 |
| Storage | 1Password Vault | Local SQLite | Multiple options |
| Offline Support | ❌ | ✅ | ✅ |
| Multiple Backends | ❌ | ❌ | ✅ |
| Import from 1Password | N/A | ❌ | ✅ |
| Profile Templates | ❌ | ❌ | ✅ (extensible) |
| Human-Readable Storage | ❌ | ❌ | ✅ (JSON/YAML) |
| Backward Compatible | N/A | ✅ | ✅ |

## Recommendations

1. **For Simple Use Cases**: Use the JSON backend with Python script
2. **For Many Profiles**: Use the SQLite backend
3. **For Team Sharing**: Use YAML backend with version control
4. **For Maximum Compatibility**: Use the bash SQLite script

## Next Steps

1. Choose your preferred implementation
2. Run the migration/import process
3. Update your shell aliases and git configuration
4. Test with a few repositories
5. Remove dependency on 1Password agent.toml
