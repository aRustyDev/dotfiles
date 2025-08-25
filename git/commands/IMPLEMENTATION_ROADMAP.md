# Git Setup Implementation Roadmap

## Architecture Overview

Both `git-setup-v2` and `git-setup-advanced` share the same core architecture:

```
┌─────────────────────────────────────────┐
│           Core Components               │
├─────────────────────────────────────────┤
│ • Profile Storage (JSON)                │
│ • 1Password Integration (op CLI)        │
│ • Git Configuration Logic               │
│ • SSH Signing Setup                     │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│        git-setup-v2 (MVP)               │
├─────────────────────────────────────────┤
│ ✓ Basic profile CRUD                   │
│ ✓ Direct 1Password fetching            │
│ ✓ Simple selection UI                  │
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

## Shared Code & Data Structures

Both versions use the **same profile storage format**:

```json
{
  "github": {
    "item_id": "abc123...",
    "vault": "Development",
    "title": "GitHub SSH Key",
    "updated": "2024-01-15 10:30:00"
  }
}
```

The advanced version adds optional fields but remains backward compatible:
```json
{
  "github": {
    "item_id": "abc123...",
    "vault": "Development",
    "title": "GitHub SSH Key",
    "username": "John Doe",      // Optional cache
    "email": "john@example.com",  // Optional cache
    "updated": "2024-01-15 10:30:00"
  }
}
```

## Progressive Enhancement Path

### Phase 1: Deploy MVP (git-setup-v2)
```bash
# Core features working
git setup -add     # Basic interactive add
git setup github   # Simple profile usage
git setup -list    # Basic listing
```

### Phase 2: Add Caching
```diff
+ # Add cache file alongside profiles.json
+ CACHE_FILE="$CONFIG_DIR/cache.json"
+
+ # Add caching logic to reduce 1Password calls
+ is_cache_valid() { ... }
+ update_cache() { ... }
```

### Phase 3: Add Fuzzy Matching
```diff
+ # Add fuzzy match function
+ fuzzy_match_profile() {
+   # Try exact, case-insensitive, prefix, partial matches
+ }

  # Update main configure function
- local profile=$(get_profile "$1")
+ local matched=$(fuzzy_match_profile "$1")
+ local profile=$(get_profile "$matched")
```

### Phase 4: Add Search & Enhanced UI
```diff
+ # Add search to selection
+ read -p "Select (1-N, or 's' to search): " selection
+ if [[ "$selection" == "s" ]]; then
+   # Filter and re-display
+ fi
```

### Phase 5: Add Custom Overrides
```diff
  # After fetching from 1Password
+ read -p "Use custom name/email? (y/N): " custom
+ if [[ "$custom" =~ ^[Yy]$ ]]; then
+   # Allow overrides
+ fi
```

## Migration Strategy

### Option 1: In-Place Evolution (Recommended)

Start with `git-setup-v2` and gradually add features:

```bash
# Week 1: Deploy MVP
cp git-setup-v2 /usr/local/bin/git-setup

# Week 2: Add caching
# Update the script with caching logic

# Week 3: Add fuzzy matching
# Update with fuzzy match function

# Week 4: Full advanced features
# Script has evolved to advanced version
```

### Option 2: Parallel Deployment

Run both versions during transition:

```bash
# Deploy both
cp git-setup-v2 /usr/local/bin/git-setup
cp git-setup-advanced /usr/local/bin/git-setup-beta

# Shell alias for testing
alias gst='git-setup-beta'

# After validation, replace
mv /usr/local/bin/git-setup-beta /usr/local/bin/git-setup
```

## Code Diff Analysis

Here's what changes between v2 and advanced:

### 1. Cache Management (New Functions)
```bash
# Advanced adds these functions
is_cache_valid() { ... }
update_cache() { ... }
get_ssh_keys() {  # Modified to use cache
  if ! is_cache_valid; then
    update_cache
  fi
  # Return from cache
}
```

### 2. Fuzzy Matching (New Function)
```bash
# Advanced adds
fuzzy_match_profile() {
  # 50 lines of matching logic
}

# V2 has simple exact match
configure_repo() {
  local profile=$(get_profile "$1")  # v2
  # vs
  local matched=$(fuzzy_match_profile "$1")  # advanced
}
```

### 3. Enhanced UI (Modified Functions)
```bash
# V2: Simple selection
select_ssh_key() {
  # Display and basic numeric selection
}

# Advanced: Search + better display
select_ssh_key_interactive() {
  # Search functionality
  # Colored output
  # Tag display
}
```

### 4. Data Storage (Compatible)
- Same `profiles.json` format
- Advanced adds optional `cache.json`
- No data migration needed

## Incremental Implementation Example

Here's how you could modify v2 incrementally:

```bash
#!/usr/bin/env bash
# git-setup-v2-enhanced

# Start with v2 code...

# Step 1: Add version flag for gradual rollout
VERSION="2.1"
ENABLE_CACHE=${GIT_SETUP_CACHE:-false}
ENABLE_FUZZY=${GIT_SETUP_FUZZY:-false}

# Step 2: Conditionally add features
if [[ "$ENABLE_CACHE" == "true" ]]; then
  source git-setup-cache-module.sh
fi

if [[ "$ENABLE_FUZZY" == "true" ]]; then
  source git-setup-fuzzy-module.sh
fi

# Rest of v2 code with hooks for new features
```

## Benefits of Progressive Approach

1. **No Breaking Changes**: Data format stays compatible
2. **Gradual Rollout**: Test features incrementally
3. **Easy Rollback**: Can revert to simpler version
4. **Same Core Logic**: Main algorithms unchanged
5. **User Familiarity**: Interface evolves gradually

## Testing Strategy

```bash
# Test v2 first
./test-git-setup.sh v2

# Add features one by one
./test-git-setup.sh v2 --with-cache
./test-git-setup.sh v2 --with-fuzzy
./test-git-setup.sh v2 --with-all

# Validate data compatibility
diff ~/.config/git-setup/profiles.json profiles.json.backup
```

## Conclusion

The progression from v2 to advanced is:
- **70% shared code** (core logic, data structures)
- **30% new features** (caching, fuzzy match, UI)
- **0% breaking changes** (fully compatible)

You can absolutely start with v2 as MVP and enhance it over time without any significant rewrites!
