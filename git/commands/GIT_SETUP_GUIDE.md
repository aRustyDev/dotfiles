# Git Setup Comprehensive Guide

## Overview and Purpose

`git-setup` is a command-line tool for managing multiple Git identities and SSH configurations. It solves the common problem of managing different Git configurations (name, email, SSH keys) across various projects and organizations.

> **Additional Documentation:**
> - [ARCHITECTURE.md](../docs/ARCHITECTURE.md) - Technical deep dive and extensibility details
> - [MIGRATION.md](../docs/MIGRATION.md) - Detailed migration guide from 1Password-based system

### Key Features
- **Multiple Profile Management**: Easily switch between different Git identities (work, personal, different organizations)
- **SSH Commit Signing**: Automatic configuration of SSH-based commit signing
- **No External Dependencies**: Works without requiring 1Password or other password managers
- **Offline Support**: All configurations stored locally for offline access
- **Flexible Storage**: Support for JSON, SQLite, and YAML backends

### Problem It Solves
Originally, the tool relied on 1Password's agent.toml file which had limitations:
- Required commenting out "name" fields that broke 1Password functionality
- Limited to predefined profiles
- Required online access to 1Password vault
- Complex TOML parsing dependencies

## Architecture and Design

### Core Architecture

```
┌─────────────────────────────────────────┐
│           Core Components               │
├─────────────────────────────────────────┤
│ • Profile Storage (JSON/SQLite/YAML)    │
│ • Git Configuration Logic               │
│ • SSH Signing Setup                     │
│ • Interactive UI                        │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│        git-setup-v2 (MVP)               │
├─────────────────────────────────────────┤
│ ✓ Basic profile CRUD operations         │
│ ✓ Direct configuration management       │
│ ✓ Simple selection UI                   │
│ ✓ Core git configuration               │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│    git-setup-advanced (Enhanced)        │
├─────────────────────────────────────────┤
│ + Caching layer                        │
│ + Fuzzy matching                       │
│ + Search functionality                 │
│ + Profile preview                      │
│ + Custom overrides                     │
│ + Better error handling                │
└─────────────────────────────────────────┘
```

### Data Storage Format

Profiles are stored in a simple JSON format (or SQLite/YAML depending on backend choice):

```json
{
  "github": {
    "display_name": "John Doe",
    "email": "john@github.com",
    "ssh_key_path": "/Users/john/.ssh/id_ed25519_github",
    "created": "2024-01-15T10:30:00Z",
    "updated": "2024-01-15T10:30:00Z"
  },
  "work": {
    "display_name": "John Doe",
    "email": "john@company.com",
    "ssh_key_path": "/Users/john/.ssh/id_ed25519_work",
    "created": "2024-01-15T10:31:00Z",
    "updated": "2024-01-15T10:31:00Z"
  }
}
```

### Implementation Options

1. **Bash + JSON** (git-setup-v2): Lightweight, minimal dependencies
2. **Bash + SQLite** (git-setup-sqlite): Robust storage, better for many profiles
3. **Python Multi-Backend** (git-setup-manager.py): Most flexible, supports multiple storage formats
4. **Bash Advanced** (git-setup-advanced): Enhanced UI with caching and fuzzy matching

## Usage Guide and Examples

### Basic Commands

```bash
# Add a new profile
git setup add github "John Doe" "john@github.com" ~/.ssh/id_ed25519_github

# List all profiles
git setup list

# Use a profile in current repository
git setup use github

# Show profile details
git setup show github

# Delete a profile
git setup delete github

# Edit an existing profile
git setup edit github
```

### Repository Configuration

```bash
# Clone a repository
git clone git@github.com:username/project.git
cd project

# Configure with your GitHub profile
git setup use github

# Verify configuration
git config user.name     # Should show "John Doe"
git config user.email    # Should show "john@github.com"
```

### Advanced Usage

```bash
# Using fuzzy matching (advanced version)
git setup gh      # Matches "github"
git setup work    # Exact match

# Search for profiles (advanced version)
git setup -search  # Interactive search mode

# Preview before applying
git setup -preview github

# Custom name/email override
git setup use github --name "John Q. Doe" --email "jqdoe@github.com"
```

### Git Aliases

Add to your `~/.gitconfig`:

```gitconfig
[alias]
    # Simple alias
    setup = "!/path/to/git-setup use"
    
    # With auto-completion support
    setup = "!f() { /path/to/git-setup use \"$@\"; }; f"
```

### Shell Integration

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Auto-detect git profile based on directory
cd() {
    builtin cd "$@"
    if [[ -d .git ]]; then
        case "$PWD" in
            */work/*) git setup work 2>/dev/null ;;
            */personal/*) git setup home 2>/dev/null ;;
            */github.com/*) git setup github 2>/dev/null ;;
        esac
    fi
}

# Quick profile switching aliases
alias gsp='git setup'
alias gsp-github='git setup github'
alias gsp-work='git setup work'
```

## Migration Instructions

### From 1Password agent.toml

> **Note**: For more detailed migration instructions including special cases and troubleshooting, see [MIGRATION.md](../docs/MIGRATION.md)

If you're migrating from the old 1Password-based system:

#### Step 1: Quick Migration (Recommended)

```bash
# Navigate to your dotfiles repo
cd ~/dotfiles/git/commands

# Run the import command (Python version only)
./git-setup-manager.py import-1password
```

#### Step 2: Manual Migration

If automatic import doesn't work:

```bash
# For each profile in your agent.toml, add it manually
git setup add github "Your Name" "you@github.com" ~/.ssh/id_ed25519_github
git setup add work "Your Name" "you@company.com" ~/.ssh/id_ed25519_work
git setup add home "Your Name" "you@personal.com" ~/.ssh/id_ed25519_home
```

#### Step 3: Verify Migration

```bash
# List all profiles
git setup list

# Test a profile
cd /tmp && mkdir test-repo && cd test-repo
git init
git setup use github
git config --list | grep user
```

### Progressive Enhancement Path

If starting with the MVP (v2) and want to upgrade to advanced features:

1. **Phase 1**: Deploy MVP
   ```bash
   cp git-setup-v2 /usr/local/bin/git-setup
   ```

2. **Phase 2**: Add caching (reduces repeated operations)
   - Update script with cache functions
   - Add cache file alongside profiles.json

3. **Phase 3**: Add fuzzy matching
   - Add fuzzy_match_profile() function
   - Update selection logic

4. **Phase 4**: Add search & enhanced UI
   - Add interactive search option
   - Improve display formatting

5. **Phase 5**: Add custom overrides
   - Allow temporary name/email overrides
   - Add preview functionality

## Changelog/Version History

### [2.0.0] - 2024-01-15
**Major rewrite eliminating 1Password dependency**

#### Added
- Advanced version with caching support
- Fuzzy profile name matching
- Interactive search functionality
- Profile preview before configuration
- Custom name/email override support
- Cache management for better performance
- Multiple backend support (JSON, SQLite, YAML)
- Import functionality from 1Password

#### Changed
- Complete rewrite to eliminate agent.toml dependency
- Profile storage now uses local JSON files
- Improved error messages and user experience
- No longer requires modifying agent.toml
- Profiles stored separately from 1Password config
- Simplified dependency requirements

#### Removed
- Dependency on yq for TOML parsing
- Hardcoded profile limitations
- agent.toml name field requirements

### [1.0.0] - 2024-01-15
**MVP Implementation (git-setup-v2)**

#### Added
- Basic profile management (add, list, delete)
- Direct 1Password integration via op CLI
- JSON-based profile storage
- Interactive profile selection
- SSH commit signing configuration

### [0.1.0] - Original Implementation
**Initial 1Password-based version**

#### Features
- Required agent.toml modifications
- Limited to 4 predefined profiles (github, gitlab, work, home)
- Used yq for TOML parsing
- Integrated with 1Password CLI
- Set up git commit signing with SSH keys
- OS-specific configuration support
- Pre-commit hook installation

#### Known Issues
- name fields in agent.toml had to be commented out
- Function called before definition (line 14)
- Limited profile flexibility
- No profile management capabilities

### [Unreleased]
**Future enhancements under consideration**

#### Planned
- Project restructuring with legacy directory
- Comprehensive documentation (Architecture, Migration guides)
- Multiple implementation options (v2, advanced, Python, SQLite)
- Profile templates for common scenarios
- Environment-based automatic selection
- Team sharing capabilities with version control

## Comparison of Implementations

| Feature | Original (1Password) | Bash+JSON (v2) | Bash+SQLite | Python Manager | Bash Advanced |
|---------|---------------------|----------------|-------------|----------------|---------------|
| Dependencies | op, yq, jq | bash, jq | sqlite3 | python3 | bash, jq |
| Storage | 1Password Vault | Local JSON | Local SQLite | Multiple options | Local JSON |
| Offline Support | ❌ | ✅ | ✅ | ✅ | ✅ |
| Multiple Backends | ❌ | ❌ | ❌ | ✅ | ❌ |
| Import from 1Password | N/A | ❌ | ❌ | ✅ | ❌ |
| Profile Templates | ❌ | ❌ | ❌ | ✅ (extensible) | ❌ |
| Fuzzy Matching | ❌ | ❌ | ❌ | ✅ | ✅ |
| Caching | ❌ | ❌ | ❌ | ✅ | ✅ |
| Human-Readable Storage | ❌ | ✅ | ❌ | ✅ (JSON/YAML) | ✅ |

## Security Considerations

1. **SSH Keys**: Only SSH key paths are stored; private keys remain in ~/.ssh/
2. **File Permissions**:
   ```bash
   chmod 700 ~/.local/share/git-setup
   chmod 600 ~/.local/share/git-setup/profiles.json
   ```
3. **Credential Storage**: Email and names are stored in plain text (similar to .gitconfig)
4. **Backup**: Consider encrypting profile data if syncing to cloud services

## Troubleshooting

### Common Issues

**Profile Not Found**
```bash
# Check if profile exists
git setup show github

# List all profiles
git setup list

# Re-add if missing
git setup add github "Your Name" "you@github.com" ~/.ssh/id_ed25519_github
```

**SSH Key Issues**
```bash
# Verify SSH key exists
ls -la ~/.ssh/id_ed25519_github*

# Test SSH connection
ssh -T git@github.com -i ~/.ssh/id_ed25519_github
```

**Permission Issues**
```bash
# Fix script permissions
chmod +x ~/dotfiles/git/commands/git-setup*

# Fix data directory permissions
chmod 700 ~/.local/share/git-setup
chmod 600 ~/.local/share/git-setup/profiles.json
```

**Git Configuration Not Applied**
```bash
# Check current git config
git config --list --show-origin

# Force re-apply profile
git setup use github --force

# Verify SSH signing config
git config commit.gpgsign
git config gpg.format
```

## Recommendations

1. **For Simple Use Cases**: Use the JSON backend with bash script (v2)
2. **For Many Profiles**: Use the SQLite backend
3. **For Team Sharing**: Use YAML backend with version control
4. **For Maximum Features**: Use the Python implementation
5. **For Gradual Migration**: Start with v2 and progressively enhance

## Benefits Over 1Password System

1. **No More Commented Fields**: Doesn't interfere with 1Password's agent.toml
2. **Works Offline**: No need for 1Password CLI or internet connection
3. **Multiple Profiles per Service**: Can have multiple GitHub accounts
4. **Portable**: Easy to backup and sync across machines
5. **Extensible**: Easy to add new features without breaking existing functionality
6. **Version Control Friendly**: Can store profiles in dotfiles repo

## Next Steps

1. Choose your preferred implementation based on needs
2. Run the migration/import process
3. Update shell aliases and git configuration
4. Test with a few repositories
5. Remove dependency on 1Password agent.toml (if applicable)
6. Consider adding to your dotfiles for easy setup on new machines