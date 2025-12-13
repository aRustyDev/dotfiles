---
id: f324c9ff-4917-4792-b965-b2b56b01dd98
title: Legacy Git Setup Implementation
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:38
project: dotfiles
scope: git
type: reference
status: ✅ active
publish: false
tags:
  - git
aliases:
  - Legacy Git Setup Implementation
  - Readme
related: []
---

# Legacy Git Setup Implementation

This directory contains the original `git setup` implementation that relied on 1Password's agent.toml file.

## Original Script

- **File:** `git_setup_original.sh`
- **Author:** aRustyDev
- **Dependencies:** 1Password CLI, yq, jq, npm, pip

## How It Worked

The original implementation:

1. Read SSH key configurations from `~/.config/1Password/ssh/agent.toml`
2. Required adding `name = "profile"` fields to agent.toml
3. These name fields had to be commented out for 1Password to function properly
4. Used `op` CLI to fetch SSH key details from 1Password vaults

## Usage

```bash
git setup <registry>
```

Where `<registry>` was one of: `github`, `gitlab`, `work`, `home`

## Known Issues

1. **agent.toml Conflict**: The `name` fields required by the script had to be commented out, breaking 1Password's SSH agent functionality
2. **Limited Profiles**: Only supported predefined registry names
3. **OS Detection Bug**: `set_os_specific_stuff` was called before being defined (line 14)
4. **No Profile Management**: No way to add/edit/delete profiles without modifying agent.toml

## Migration

To migrate to the new system, see the [Migration Guide](../MIGRATION_EXAMPLE.md).

## Why It Was Replaced

The new implementation:
- Doesn't require modifying agent.toml
- Supports unlimited custom profiles
- Works seamlessly with 1Password SSH agent
- Provides better error handling and user experience
