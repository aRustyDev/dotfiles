---
id: 272e72cd-1d7b-4013-85a0-770c318c0502
title: Implement git-setup-v2 MVP
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:38
project: dotfiles
scope: git
type: issue
status: 📝 draft
publish: false
tags:
  - git
  - github-issue
  - documentation
aliases:
  - Implement git-setup-v2 MVP
  - Issue 2 Implement Mvp
related: []
---

# Implement git-setup-v2 MVP

## Description

Create the minimum viable implementation of the new git-setup command that eliminates the agent.toml dependency while maintaining core functionality.

## Requirements

### Core Features
- [ ] Profile storage using JSON format
- [ ] CRUD operations for profiles (add, list, delete, use)
- [ ] Direct 1Password integration via `op` CLI
- [ ] Git configuration with SSH signing
- [ ] Interactive profile selection UI
- [ ] Backward-compatible command interface

### Implementation Details

```bash
# Commands to support
git setup -add          # Interactive profile creation
git setup -list         # List all profiles
git setup -delete NAME  # Remove a profile
git setup NAME          # Configure repo with profile
git setup -help         # Show usage
```

### Profile Storage Format

Location: `~/.config/git-setup/profiles.json`

```json
{
  "profile-name": {
    "item_id": "1password-uuid",
    "vault": "vault-name",
    "title": "SSH Key Title",
    "updated": "timestamp"
  }
}
```

## Technical Requirements

- Bash script (portable, minimal dependencies)
- Dependencies: bash, jq, op, git
- Error handling for common scenarios
- Secure file permissions (600)

## Acceptance Criteria

- [ ] Can add new profiles interactively
- [ ] Can list all configured profiles
- [ ] Can delete existing profiles
- [ ] Can configure git repo with `git setup <name>`
- [ ] No modifications to agent.toml required
- [ ] Clear error messages
- [ ] Help documentation included

## Testing Scenarios

1. Add profile with valid 1Password SSH key
2. Use profile in git repository
3. List profiles when empty and populated
4. Delete profile (with confirmation)
5. Handle missing profile gracefully
6. Handle 1Password authentication errors

## Labels

- `task`
- `mvp`
- `1password`
- `git`

## Milestone

Special Integrations

## Dependencies

- Issue #1 (Archive original implementation) should be completed first
