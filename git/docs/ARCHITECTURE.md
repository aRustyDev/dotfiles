# Git Setup Architecture

## Overview

The git setup system provides a clean interface between git repositories and 1Password SSH key management without requiring modifications to 1Password's configuration files.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        User Interface                        │
│                    git setup <profile>                       │
└─────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Profile Management                        │
│                 ~/.config/git-setup/                         │
│                    profiles.json                             │
└─────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                   1Password Integration                      │
│                        op CLI                                │
│                 (fetch SSH public keys)                      │
└─────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Git Configuration                         │
│              git config --local user.*                       │
│                 SSH signing setup                            │
└─────────────────────────────────────────┘
```

## Components

### 1. Profile Storage

**Location:** `~/.config/git-setup/profiles.json`

**Structure:**
```json
{
  "profile-name": {
    "item_id": "1password-item-uuid",
    "vault": "vault-name",
    "title": "SSH Key Title",
    "username": "optional-cached-name",
    "email": "optional-cached-email",
    "updated": "timestamp"
  }
}
```

### 2. 1Password Integration

The system interacts with 1Password through the `op` CLI tool:

- **List SSH Keys:** `op item list --categories "SSH Key"`
- **Get Key Details:** `op item get <item-id>`
- **Extract Public Key:** From the `public key` field

### 3. Git Configuration

Sets the following git configurations:

```bash
git config --local user.name "<from-1password>"
git config --local user.email "<from-1password>"
git config --local user.signingkey "<ssh-public-key>"
git config --local commit.gpgsign true
git config --local tag.gpgsign true
git config --local gpg.format ssh
git config --local gpg.ssh.program "<os-specific>"
git config --local gpg.ssh.allowedSignersFile "<path>"
```

### 4. SSH Allowed Signers

Maintains `~/.config/git/allowed_signers` file:
```
email@example.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...
```

## Data Flow

1. **Profile Creation:**
   - User runs `git setup -add`
   - System lists all SSH keys from 1Password
   - User selects a key and names the profile
   - Profile mapping saved to profiles.json

2. **Profile Usage:**
   - User runs `git setup <profile>`
   - System reads profile from profiles.json
   - Fetches SSH key details from 1Password
   - Configures git repository

3. **Caching (Advanced Version):**
   - SSH key list cached for 5 minutes
   - Reduces 1Password API calls
   - Cache stored in `~/.config/git-setup/cache.json`

## Security Considerations

1. **No Private Keys:** Only public keys are stored or cached
2. **File Permissions:** Config files are chmod 600
3. **1Password Auth:** Relies on existing 1Password authentication
4. **Local Storage:** Profile mappings stored locally, not synced

## Extensibility

The architecture supports:

1. **Multiple Backends:** JSON, SQLite, YAML
2. **Plugin System:** Additional features via modules
3. **Custom Validators:** Profile validation rules
4. **Hook System:** Pre/post configuration hooks

## Error Handling

1. **Missing Profiles:** Clear error with available profiles listed
2. **1Password Errors:** Graceful fallback with helpful messages
3. **Git Errors:** Validation before applying configurations
4. **Permission Issues:** Clear guidance on fixing permissions
