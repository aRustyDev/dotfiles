#!/bin/bash

# Script to assign milestones to issues based on their numbers

echo "Assigning milestones to issues..."

# Configuration Review Issues (2-30) -> Milestone 1
for i in {2..30}; do
    gh issue edit $i --milestone 1
    echo "✓ Issue #$i assigned to Configuration Review"
done

# Special Feature Issues (31-33) -> Milestone 6
for i in {31..33}; do
    gh issue edit $i --milestone 6
    echo "✓ Issue #$i assigned to Special Integrations"
done

# Infrastructure Issues need to be split across milestones
# mkOutOfStoreSymlink (34) -> Milestone 2
gh issue edit 34 --milestone 2
echo "✓ Issue #34 assigned to mkOutOfStoreSymlink Implementation"

# Hybrid Framework (35) -> Milestone 3
gh issue edit 35 --milestone 3
echo "✓ Issue #35 assigned to Hybrid Approach Analysis"

# Nix Secrets (36) -> Milestone 6
gh issue edit 36 --milestone 6
echo "✓ Issue #36 assigned to Special Integrations"

# Module Structure, Build Opt, Pre-commit, Backup, Dev Env (37-40, 43) -> Milestone 2
for i in 37 38 39 40 43; do
    gh issue edit $i --milestone 2
    echo "✓ Issue #$i assigned to mkOutOfStoreSymlink Implementation"
done

# Multi-machine (41) -> Milestone 3
gh issue edit 41 --milestone 3
echo "✓ Issue #41 assigned to Hybrid Approach Analysis"

# CI/CD (42) -> Milestone 5
gh issue edit 42 --milestone 5
echo "✓ Issue #42 assigned to Testing Framework"

# Documentation Issues (44-51) -> Milestone 4
for i in {44..51}; do
    gh issue edit $i --milestone 4
    echo "✓ Issue #$i assigned to Documentation Suite"
done

# Testing Issues (52-56) -> Milestone 5
for i in {52..56}; do
    gh issue edit $i --milestone 5
    echo "✓ Issue #$i assigned to Testing Framework"
done

echo ""
echo "✅ All milestones assigned successfully!"
