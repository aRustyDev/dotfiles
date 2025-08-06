#!/bin/bash

# Script to create all GitHub issues for the Dotfiles Evolution project
# This version includes error handling and continues on failure

echo "Creating GitHub issues for Dotfiles Evolution project..."

# Keep track of created issues
created=0
failed=0

# Function to create an issue and track success/failure
create_issue() {
    if gh issue create "$@" 2>/dev/null; then
        ((created++))
        echo "✓ Created issue: $(echo "$@" | grep -o '"[^"]*"' | head -1 | tr -d '"')"
    else
        ((failed++))
        echo "✗ Failed to create issue: $(echo "$@" | grep -o '"[^"]*"' | head -1 | tr -d '"')"
    fi
}

# Test issue creation first
echo "Testing issue creation..."
create_issue \
  --title "Review: nix-darwin/flake.nix" \
  --body "## Module: nix-darwin/flake.nix

### Current State
- [ ] Configuration location identified
- [ ] Dependencies documented
- [ ] Current functionality verified

### Analysis
- [ ] Pain points identified
- [ ] Improvement opportunities noted
- [ ] Security concerns addressed

### Recommendations
- [ ] mkOutOfStoreSymlink candidacy evaluated
- [ ] Hybrid approach considered
- [ ] Documentation needs identified

### Implementation Notes
Core flake configuration that drives the entire nix-darwin setup. This is the entry point for all system configuration.

### Related Files
- nix-darwin/flake.nix
- nix-darwin/flake.lock

### Key Areas to Review
- Input management and versioning
- System configuration integration
- Home-manager module inclusion
- Output structure and organization" \
  --milestone 1

echo ""
echo "Summary:"
echo "✓ Created: $created issues"
echo "✗ Failed: $failed issues"
echo ""
echo "If issues were created successfully, you can now link them to the project."
