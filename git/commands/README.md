# Git Setup - 1Password Integration Solutions

This directory contains improved versions of the git setup script that work directly with 1Password without requiring modifications to `agent.toml`.

## The Problem

The original `git setup` script required adding `name = "profile"` fields to 1Password's `agent.toml` file, but these had to be commented out for 1Password to work properly. This created a maintenance burden and potential for errors.

## The Solution

Three new implementations that maintain simple `git setup <target>` usage while storing profile mappings separately:

### 1. `git-setup-v2` - Simple & Direct

The simplest solution that maintains a JSON mapping between profile names and 1Password items.

**Features:**
- Minimal dependencies (bash, jq, op)
- Simple JSON storage for profile mappings
- Interactive profile setup
- Direct 1Password integration

**Usage:**
```bash
# Add a new profile interactively
git setup -add
# Profile name: github
# [Select SSH key from list]
# ✓ Profile 'github' saved

# Use the profile
git setup github

# List all profiles
git setup -list
```

### 2. `git-setup-advanced` - Smart & Fast

An enhanced version with caching, fuzzy matching, and better UX.

**Features:**
- Smart caching reduces 1Password API calls
- Fuzzy profile name matching (`git setup gh` matches "github")
- Search functionality when selecting SSH keys
- Custom name/email overrides
- Shows current repo configuration

**Usage:**
```bash
# Fuzzy matching
git setup gh     # Matches "github"
git setup wo     # Matches "work"

# Interactive search
git setup -add
# Select key: s
# Search term: github
# [Shows filtered results]

# Check current configuration
git setup -current
```

### 3. Original Solutions (Alternative Approaches)

- `git-setup-sqlite.sh` - SQLite-based storage (bash only)
- `git-setup-manager.py` - Python with multiple backend options
- `git-setup` - Wrapper script for backward compatibility

## Installation

1. Make scripts executable:
```bash
chmod +x git-setup-v2 git-setup-advanced
```

2. Create symlink or alias:
```bash
# Symlink (recommended)
ln -sf git-setup-advanced /usr/local/bin/git-setup

# Or add to your shell config
alias git-setup='/path/to/git-setup-advanced'
```

3. Ensure 1Password CLI is installed:
```bash
brew install --cask 1password-cli
```

## Migration from Original Script

### Quick Start

```bash
# List your SSH keys in 1Password
git setup -add

# For each profile you had (github, work, home, etc.):
# 1. Enter profile name
# 2. Select corresponding SSH key from 1Password
# 3. Done!
```

### Example Migration

If your `agent.toml` had these entries:
```toml
[[ssh-keys]]
vault = "Development"
item = "GitHub Personal"
# name = "github"  # Had to be commented!

[[ssh-keys]]
vault = "Work"
item = "Company GitLab"
# name = "work"    # Had to be commented!
```

Set them up in the new system:
```bash
git setup -add
# Profile name: github
# Select: GitHub Personal [Development]

git setup -add
# Profile name: work
# Select: Company GitLab [Work]
```

## How It Works

1. **Profile Storage**: Maintains a mapping file at `~/.config/git-setup/profiles.json`:
```json
{
  "github": {
    "item_id": "abc123...",
    "vault": "Development",
    "title": "GitHub Personal",
    "username": "John Doe",
    "email": "john@example.com"
  }
}
```

2. **1Password Integration**: When you run `git setup github`:
   - Looks up the profile configuration
   - Fetches SSH public key from 1Password
   - Configures git with proper signing settings
   - Updates allowed signers file

3. **No agent.toml Conflicts**: Your profiles are stored separately, so 1Password's agent.toml remains unmodified and functional.

## Advanced Features

### Fuzzy Matching (git-setup-advanced)
```bash
git setup gh     # Matches "github"
git setup gl     # Matches "gitlab"
git setup wo     # Matches "work"
```

### Custom Git Config
```bash
git setup -add
# ...select SSH key...
# Use custom name/email? (y/N): y
# Git name: John Doe (Work)
# Git email: john@company.com
```

### Profile Management
```bash
# List all profiles with details
git setup -list

# Show current repo configuration
git setup -current

# Refresh 1Password cache
git setup -refresh
```

## Troubleshooting

### "Profile not found"
```bash
# List available profiles
git setup -list

# Add the missing profile
git setup -add
```

### 1Password CLI Issues
```bash
# Ensure you're signed in
op signin

# Refresh the cache
git setup -refresh
```

### Permission Errors
```bash
# Fix permissions
chmod 700 ~/.config/git-setup
chmod 600 ~/.config/git-setup/*.json
```

## Security

- Only SSH public keys are fetched from 1Password
- Profile mappings contain only references to 1Password items
- Cache files have restricted permissions (600)
- No private keys are ever stored locally

## Comparison with Original

| Feature | Original | New Solutions |
|---------|----------|---------------|
| Simple `git setup <target>` | ✅ | ✅ |
| No agent.toml modification | ❌ | ✅ |
| Works with 1Password SSH agent | ❌ | ✅ |
| Interactive setup | ❌ | ✅ |
| Fuzzy matching | ❌ | ✅ |
| Performance caching | ❌ | ✅ |
| Multiple profiles per service | ❌ | ✅ |

## Tips

1. **Naming Conventions**: Use consistent profile names
   - `github`, `github-work`, `github-personal`
   - `gitlab`, `gitlab-self`, `gitlab-company`

2. **Shell Integration**: Add to your `.zshrc`:
   ```bash
   # Quick profile switching
   alias gsp='git setup'
   alias gsp-gh='git setup github'
   alias gsp-work='git setup work'
   ```

3. **Debugging**: Run with DEBUG=1 for verbose output:
   ```bash
   DEBUG=1 git setup github
   ```
