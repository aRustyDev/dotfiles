#!/bin/bash

# Create all 55 issues for the Dotfiles Evolution project
# This version creates issues without milestones first, then we'll assign them

echo "Creating all 55 GitHub issues..."
echo "Note: We'll assign milestones after creation"
echo ""

# Counter
count=0

# Configuration Review Issues (29 total)
echo "=== Creating Configuration Review Issues (29) ==="

gh issue create --title "Review: nix-darwin/flake.nix" --body "Core flake configuration review"
((count++))

gh issue create --title "Review: nix-darwin/configuration.nix" --body "System-level configuration review"
((count++))

gh issue create --title "Review: hosts/personal.nix" --body "Home Manager user configuration review"
((count++))

gh issue create --title "Review: programs/browser.nix" --body "Browser configuration module review"
((count++))

gh issue create --title "Review: programs/chat.nix" --body "Chat applications configuration review"
((count++))

gh issue create --title "Review: programs/coreutils.nix" --body "Core utilities configuration review"
((count++))

gh issue create --title "Review: programs/fonts.nix" --body "Font management module review"
((count++))

gh issue create --title "Review: programs/git.nix" --body "Git configuration module review"
((count++))

gh issue create --title "Review: programs/obsidian.nix" --body "Obsidian configuration review"
((count++))

gh issue create --title "Review: programs/ssh.nix" --body "SSH configuration with 1Password integration review"
((count++))

gh issue create --title "Review: programs/starship.nix" --body "Starship prompt configuration review"
((count++))

gh issue create --title "Review: programs/terraform.nix" --body "Terraform configuration review"
((count++))

gh issue create --title "Review: programs/todo.nix" --body "Todo management tool configuration review"
((count++))

gh issue create --title "Review: programs/vscode.nix" --body "VSCode configuration review"
((count++))

gh issue create --title "Review: programs/xcode.nix" --body "Xcode configuration review"
((count++))

gh issue create --title "Review: programs/yabai.nix" --body "Yabai window manager configuration review"
((count++))

gh issue create --title "Review: programs/zsh.nix" --body "Zsh shell configuration review"
((count++))

gh issue create --title "Review: terminal/editor.nix" --body "Terminal editor configurations review"
((count++))

gh issue create --title "Review: terminal/emulator.nix" --body "Terminal emulator configurations review"
((count++))

gh issue create --title "Review: terminal/multiplexer.nix" --body "Terminal multiplexer configurations review"
((count++))

gh issue create --title "Review: terminal/shell.nix" --body "Shell tools configuration review"
((count++))

gh issue create --title "Review: terminal/ui.nix" --body "Terminal UI tools configuration review"
((count++))

gh issue create --title "Review: homebrew/cask.nix" --body "Homebrew cask management review"
((count++))

gh issue create --title "Review: nvim configuration" --body "Neovim configuration review"
((count++))

gh issue create --title "Review: tmux configuration" --body "Tmux configuration review"
((count++))

gh issue create --title "Review: zellij configuration" --body "Zellij configuration review"
((count++))

gh issue create --title "Review: k9s configuration" --body "K9s configuration review"
((count++))

gh issue create --title "Review: 1Password configuration" --body "1Password configuration review"
((count++))

gh issue create --title "Review: VPN configurations" --body "VPN configurations review"
((count++))

echo "Created $count configuration review issues"

# Special Feature Issues (3 total)
echo ""
echo "=== Creating Special Feature Issues (3) ==="

gh issue create --title "Feature: External Claude Config Loading" --body "Load .claude configs from external GitHub repository"
((count++))

gh issue create --title "Feature: 1Password CLI Integration" --body "Integrate op CLI throughout the system"
((count++))

gh issue create --title "Feature: Split Tunnel VPN Configuration" --body "Implement split tunnel for WireGuard"
((count++))

echo "Created 3 special feature issues (Total: $count)"

# Infrastructure Issues (10 total)
echo ""
echo "=== Creating Infrastructure Issues (10) ==="

gh issue create --title "Infra: mkOutOfStoreSymlink Helper Functions" --body "Create reusable helper functions for symlink management"
((count++))

gh issue create --title "Infra: Hybrid Configuration Framework" --body "Design framework for hybrid nix + traditional configs"
((count++))

gh issue create --title "Infra: Nix Secrets Management" --body "Implement secure secret handling in Nix"
((count++))

gh issue create --title "Infra: Module Structure Standardization" --body "Define standard module structure"
((count++))

gh issue create --title "Infra: Build Optimization" --body "Optimize Nix build times"
((count++))

gh issue create --title "Infra: Pre-commit Hooks for Nix" --body "Add Nix formatting and linting hooks"
((count++))

gh issue create --title "Infra: Backup/Restore Procedures" --body "Create backup strategies for configurations"
((count++))

gh issue create --title "Infra: Multi-machine Profile System" --body "Support multiple machine configurations"
((count++))

gh issue create --title "Infra: CI/CD Pipeline Setup" --body "Automated testing and validation"
((count++))

gh issue create --title "Infra: Development Environment" --body "Easy setup for contributors"
((count++))

echo "Created 10 infrastructure issues (Total: $count)"

# Documentation Issues (8 total)
echo ""
echo "=== Creating Documentation Issues (8) ==="

gh issue create --title "Docs: Main README Overhaul" --body "Clear project overview and quick start"
((count++))

gh issue create --title "Docs: MDBook Setup and Structure" --body "Configure MDBook for documentation"
((count++))

gh issue create --title "Docs: Module Documentation Standards" --body "Define documentation requirements"
((count++))

gh issue create --title "Docs: Inline Documentation Guidelines" --body "Define inline documentation standards"
((count++))

gh issue create --title "Docs: Setup Guide (Fresh Install)" --body "Step-by-step installation guide"
((count++))

gh issue create --title "Docs: Migration Guide (From Other Systems)" --body "Migration paths from common tools"
((count++))

gh issue create --title "Docs: Troubleshooting Guide" --body "Common issues and solutions"
((count++))

gh issue create --title "Docs: Security Best Practices" --body "Security guidelines and procedures"
((count++))

echo "Created 8 documentation issues (Total: $count)"

# Testing Issues (5 total)
echo ""
echo "=== Creating Testing Issues (5) ==="

gh issue create --title "Test: Testing Tool Evaluation" --body "Evaluate Nix testing frameworks"
((count++))

gh issue create --title "Test: Core Module Test Suite" --body "Create tests for critical modules"
((count++))

gh issue create --title "Test: Integration Test Framework" --body "Test multi-module interactions"
((count++))

gh issue create --title "Test: Configuration Validation" --body "Validate configuration syntax"
((count++))

gh issue create --title "Test: Performance Benchmarks" --body "Measure and track performance"
((count++))

echo "Created 5 testing issues (Total: $count)"

echo ""
echo "================================"
echo "✅ Total issues created: $count"
echo "================================"
echo ""
echo "Next step: Link these issues to milestones and the project"
