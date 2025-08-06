#!/bin/bash

# Script to assign milestones to issues using milestone titles

echo "Assigning milestones to issues..."

# Configuration Review Issues (2-30) -> Milestone "Configuration Review"
for i in {2..30}; do
    gh issue edit $i --milestone "Configuration Review" 2>/dev/null && echo "✓ Issue #$i assigned to Configuration Review" || echo "✗ Failed #$i"
done

# Special Feature Issues (31-33) -> Milestone "Special Integrations"
for i in {31..33}; do
    gh issue edit $i --milestone "Special Integrations" 2>/dev/null && echo "✓ Issue #$i assigned to Special Integrations" || echo "✗ Failed #$i"
done

# Infrastructure Issues
# mkOutOfStoreSymlink (34) -> Milestone "mkOutOfStoreSymlink Implementation"
gh issue edit 34 --milestone "mkOutOfStoreSymlink Implementation" 2>/dev/null && echo "✓ Issue #34 assigned" || echo "✗ Failed #34"

# Hybrid Framework (35) -> Milestone "Hybrid Approach Analysis"
gh issue edit 35 --milestone "Hybrid Approach Analysis" 2>/dev/null && echo "✓ Issue #35 assigned" || echo "✗ Failed #35"

# Nix Secrets (36) -> Milestone "Special Integrations"
gh issue edit 36 --milestone "Special Integrations" 2>/dev/null && echo "✓ Issue #36 assigned" || echo "✗ Failed #36"

# Module Structure, Build Opt, Pre-commit, Backup, Dev Env (37-40, 43) -> "mkOutOfStoreSymlink Implementation"
for i in 37 38 39 40 43; do
    gh issue edit $i --milestone "mkOutOfStoreSymlink Implementation" 2>/dev/null && echo "✓ Issue #$i assigned" || echo "✗ Failed #$i"
done

# Multi-machine (41) -> "Hybrid Approach Analysis"
gh issue edit 41 --milestone "Hybrid Approach Analysis" 2>/dev/null && echo "✓ Issue #41 assigned" || echo "✗ Failed #41"

# CI/CD (42) -> "Testing Framework"
gh issue edit 42 --milestone "Testing Framework" 2>/dev/null && echo "✓ Issue #42 assigned" || echo "✗ Failed #42"

# Documentation Issues (44-51) -> "Documentation Suite"
for i in {44..51}; do
    gh issue edit $i --milestone "Documentation Suite" 2>/dev/null && echo "✓ Issue #$i assigned to Documentation Suite" || echo "✗ Failed #$i"
done

# Testing Issues (52-56) -> "Testing Framework"
for i in {52..56}; do
    gh issue edit $i --milestone "Testing Framework" 2>/dev/null && echo "✓ Issue #$i assigned to Testing Framework" || echo "✗ Failed #$i"
done

echo ""
echo "✅ Milestone assignment complete!"
