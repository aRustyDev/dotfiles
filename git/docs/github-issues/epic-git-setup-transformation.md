---
id: b0757a3d-e2c0-42a3-92b7-25e9831d2d5e
title: Epic: Transform git-setup to modern 1Password integration
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope: git
type: issue
status: 📝 draft
publish: false
tags:
  - git
  - documentation
aliases:
  - Epic: Transform git-setup to modern 1Password integration
  - Epic Git Setup Transformation
related: []
---

# Epic: Transform git-setup to modern 1Password integration

## Overview

Transform the existing `git setup` command from a script that requires modifying 1Password's agent.toml to a modern implementation with standalone profile management.

## Problem Statement

The current `git_setup.sh` implementation has several issues:

1. **agent.toml Conflict**: Requires adding `name` fields to 1Password's agent.toml that must be commented out for 1Password to function
2. **Limited Profiles**: Only supports 4 hardcoded profiles (github, gitlab, work, home)
3. **Poor UX**: No way to add/edit/delete profiles without editing configuration files
4. **Maintenance Burden**: Complex dependencies and TOML parsing requirements

## Solution

Create a new implementation that:
- Stores profile mappings separately from 1Password configuration
- Provides interactive profile management
- Maintains the simple `git setup <target>` interface
- Works seamlessly with 1Password SSH agent

## Success Criteria

- [ ] Original functionality preserved in legacy directory
- [ ] MVP implementation completed and tested
- [ ] Advanced features implemented
- [ ] Comprehensive documentation available
- [ ] Migration path documented and tested
- [ ] No modifications to agent.toml required
- [ ] All existing workflows supported

## Implementation Phases

### Phase 1: MVP (git-setup-v2)
- Basic profile CRUD operations
- Direct 1Password integration
- JSON-based storage
- Core git configuration

### Phase 2: Advanced Features
- Caching for performance
- Fuzzy profile matching
- Enhanced UI/UX
- Custom overrides

### Phase 3: Integration
- Nix-Darwin packaging
- Testing framework
- CI/CD integration

## Related Issues

- #XX - Archive original git-setup implementation
- #XX - Implement git-setup-v2 MVP
- #XX - Create installation and setup documentation
- #XX - Enhance git-setup with advanced features
- #XX - Add testing framework for git-setup

## Labels

- `epic`
- `enhancement`
- `1password`
- `git`

## Milestone

Special Integrations
