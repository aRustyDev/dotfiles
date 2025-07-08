#!/bin/bash
#
# Script to create GitHub issues for git-setup transformation
# Run from the dotfiles repository root

# Epic Issue
gh issue create \
  --title "Epic: Transform git-setup to modern 1Password integration" \
  --body-file git/docs/github-issues/epic-git-setup-transformation.md \
  --label "epic,enhancement,1password,git" \
  --milestone "Special Integrations"

# Issue 1: Archive Original
gh issue create \
  --title "Archive original git-setup implementation" \
  --body-file git/docs/github-issues/issue-1-archive-original.md \
  --label "task,documentation,git" \
  --milestone "Configuration Review"

# Issue 2: MVP Implementation
gh issue create \
  --title "Implement git-setup-v2 MVP" \
  --body-file git/docs/github-issues/issue-2-implement-mvp.md \
  --label "task,mvp,1password,git" \
  --milestone "Special Integrations"

# Issue 3: Documentation
gh issue create \
  --title "Create installation and setup documentation" \
  --body-file git/docs/github-issues/issue-3-documentation.md \
  --label "documentation,git" \
  --milestone "Documentation Suite"

# Issue 4: Advanced Features
gh issue create \
  --title "Enhance git-setup with advanced features" \
  --body-file git/docs/github-issues/issue-4-advanced-features.md \
  --label "enhancement,phase-2,git" \
  --milestone "Special Integrations"

# Issue 5: Testing Framework
gh issue create \
  --title "Add testing framework for git-setup" \
  --body-file git/docs/github-issues/issue-5-testing-framework.md \
  --label "testing,infrastructure,git" \
  --milestone "Testing Framework"

echo "All issues created successfully!"
echo "View them at: https://github.com/aRustyDev/dotfiles/issues"
