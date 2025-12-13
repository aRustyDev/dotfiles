---
id: 4c9e2f8b-3a7d-4e6a-9f1b-5d8c2e4a7b3f
title: Commit Message Hook Enhancements
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:34
project: dotfiles
scope: git
type: plan
status: 🚧 in-progress
publish: false
tags:
  - git
  - hooks
  - commit-msg
  - conventional-commits
  - feature-requests
aliases:
  - Commit Message Hook
  - Conventional Commits Enhancement
related: []
---

# Commit Message Related Tooling

## Feature Requests / Ideas

- Make "scope" declarative and vet-able
  - `feat(isScope)` would be valid
  - `feat(notDeclared)` would be invalid
- Make "Conventional Commits" user friendly and declarative, so when the error
  occurs its easy to debug. ie `new(scope)` would be wrong, but instead of
  having to go to the conventional commit site, it would just output all
  "VALID" scopes and types.
