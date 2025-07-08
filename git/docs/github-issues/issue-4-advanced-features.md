# Enhance git-setup with advanced features

## Description

Build upon the MVP to add advanced features that improve performance, usability, and flexibility of the git-setup command.

## Feature Requirements

### 1. Caching System
- [ ] Cache 1Password SSH key list (5-minute TTL)
- [ ] Cache individual key details
- [ ] Reduce API calls to 1Password
- [ ] Cache invalidation commands

### 2. Fuzzy Profile Matching
- [ ] Exact match (highest priority)
- [ ] Case-insensitive match
- [ ] Prefix match (e.g., 'gh' → 'github')
- [ ] Partial match as fallback

### 3. Enhanced UI/UX
- [ ] Colored output for better readability
- [ ] Search functionality in key selection
- [ ] Progress indicators for long operations
- [ ] Better error messages with suggestions

### 4. Profile Management
- [ ] Show current repo configuration
- [ ] Profile preview before applying
- [ ] Bulk operations support
- [ ] Import/export profiles

### 5. Custom Overrides
- [ ] Custom name/email per profile
- [ ] Environment-based defaults
- [ ] Profile templates
- [ ] Conditional configurations

## Implementation Details

### Cache Structure
```json
{
  "keys": {
    "item-id": {
      "title": "SSH Key Name",
      "vault": "Vault Name",
      "tags": ["tag1", "tag2"]
    }
  },
  "items": {
    "item-id": {
      "public_key": "ssh-ed25519...",
      "username": "cached-name",
      "email": "cached-email"
    }
  },
  "updated": 1234567890
}
```

### Fuzzy Matching Examples
```bash
git setup gh      # matches 'github'
git setup gl      # matches 'gitlab'
git setup work    # exact match
git setup WoRk    # case-insensitive match
```

## Acceptance Criteria

- [ ] Performance improved with caching
- [ ] Fuzzy matching works intuitively
- [ ] UI provides clear feedback
- [ ] Custom configurations persist
- [ ] Backward compatible with MVP

## Testing Requirements

- Cache expiration and refresh
- Fuzzy matching edge cases
- UI responsiveness
- Override persistence
- Performance benchmarks

## Labels

- `enhancement`
- `phase-2`
- `git`

## Milestone

Special Integrations

## Dependencies

- Issue #2 (MVP implementation) must be completed first
