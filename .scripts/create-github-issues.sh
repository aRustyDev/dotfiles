#!/bin/bash

# Script to create all GitHub issues for the Dotfiles Evolution project

echo "Creating GitHub issues for Dotfiles Evolution project..."

# Configuration Review Issues (Milestone 1)
echo "Creating Configuration Review issues..."

# Issue 1
gh issue create \
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
  --milestone 1 \
  --label "review,configuration"

# Issue 2
gh issue create \
  --title "Review: nix-darwin/configuration.nix" \
  --body "## Module: nix-darwin/configuration.nix

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
System-level configuration for nix-darwin. Manages system packages, services, and macOS defaults.

### Related Files
- nix-darwin/configuration.nix
- All imported modules

### Key Areas to Review
- System package management
- Service configurations
- macOS system defaults
- Module organization" \
  --milestone 1 \
  --label "review,configuration"

# Issue 3
gh issue create \
  --title "Review: hosts/personal.nix" \
  --body "## Module: hosts/personal.nix

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
Home Manager user configuration. Central point for user-level package and configuration management.

### Related Files
- nix-darwin/hosts/personal.nix
- All program modules imported

### Key Areas to Review
- User package management
- Module imports and organization
- Environment variables
- User services" \
  --milestone 1 \
  --label "review,configuration"

# Issue 4
gh issue create \
  --title "Review: programs/browser.nix" \
  --body "## Module: programs/browser.nix

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
Browser configuration module. Currently appears to be a skeleton that needs implementation.

### Key Areas to Review
- Define browser preferences
- Consider managing browser extensions declaratively
- Evaluate security settings management" \
  --milestone 1 \
  --label "review,configuration"

# Issue 5
gh issue create \
  --title "Review: programs/chat.nix" \
  --body "## Module: programs/chat.nix

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
Chat application configuration. Needs to include Slack configuration as mentioned in TODO.

### Key Areas to Review
- Slack integration
- Other chat tools (Discord, Teams, etc.)
- Notification settings
- Security considerations for chat apps" \
  --milestone 1 \
  --label "review,configuration"

# Issue 6
gh issue create \
  --title "Review: programs/coreutils.nix" \
  --body "## Module: programs/coreutils.nix

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
Core utilities configuration. Should manage essential command-line tools.

### Key Areas to Review
- GNU coreutils vs BSD utilities
- Additional CLI tools
- Shell integrations
- Performance tools" \
  --milestone 1 \
  --label "review,configuration"

# Issue 7
gh issue create \
  --title "Review: programs/fonts.nix" \
  --body "## Module: programs/fonts.nix

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
Font management module. Should handle system and programming fonts.

### Key Areas to Review
- Programming fonts (ligatures, powerline)
- System fonts
- Font rendering settings
- Terminal font configuration" \
  --milestone 1 \
  --label "review,configuration"

# Issue 8
gh issue create \
  --title "Review: programs/git.nix" \
  --body "## Module: programs/git.nix

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
Git configuration module. Currently uses custom git_setup.sh script.

### Related Files
- nix-darwin/hosts/programs/git.nix
- git/commands/git_setup.sh
- commitlint.config.js

### Key Areas to Review
- Integration with 1Password for signing
- Git aliases and custom commands
- Commit signing configuration
- Pre-commit hooks integration
- Multiple identity management" \
  --milestone 1 \
  --label "review,configuration,priority"

# Issue 9
gh issue create \
  --title "Review: programs/obsidian.nix" \
  --body "## Module: programs/obsidian.nix

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
Obsidian note-taking app configuration.

### Key Areas to Review
- Plugin management
- Vault locations
- Sync settings
- Theme configuration" \
  --milestone 1 \
  --label "review,configuration"

# Issue 10
gh issue create \
  --title "Review: programs/ssh.nix" \
  --body "## Module: programs/ssh.nix

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
SSH configuration module with 1Password integration.

### Related Files
- nix-darwin/hosts/programs/ssh.nix
- ssh/ssh_config
- 1Password/agent.toml

### Key Areas to Review
- 1Password SSH agent integration
- Host configurations
- Security hardening
- Key management
- Known hosts management" \
  --milestone 1 \
  --label "review,configuration,security,priority"

# Issue 11
gh issue create \
  --title "Review: programs/starship.nix" \
  --body "## Module: programs/starship.nix

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
Starship prompt configuration with Catppuccin Mocha theme.

### Related Files
- nix-darwin/hosts/programs/starship.nix
- starship/config.toml

### Key Areas to Review
- Theme management
- Performance optimizations
- Custom modules
- Integration with shell" \
  --milestone 1 \
  --label "review,configuration"

# Issue 12
gh issue create \
  --title "Review: programs/terraform.nix" \
  --body "## Module: programs/terraform.nix

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
Terraform and infrastructure as code tools configuration.

### Key Areas to Review
- Provider management
- Plugin cache configuration
- Workspace management
- Integration with cloud CLIs" \
  --milestone 1 \
  --label "review,configuration"

# Issue 13
gh issue create \
  --title "Review: programs/todo.nix" \
  --body "## Module: programs/todo.nix

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
Todo/task management tool configuration.

### Key Areas to Review
- Which todo tool to standardize on
- Integration with other tools
- Sync capabilities
- CLI vs GUI considerations" \
  --milestone 1 \
  --label "review,configuration"

# Issue 14
gh issue create \
  --title "Review: programs/vscode.nix" \
  --body "## Module: programs/vscode.nix

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
VSCode configuration and extension management.

### Key Areas to Review
- Extension management via Nix
- Settings sync
- Workspace configurations
- Integration with development tools" \
  --milestone 1 \
  --label "review,configuration"

# Issue 15
gh issue create \
  --title "Review: programs/xcode.nix" \
  --body "## Module: programs/xcode.nix

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
Xcode and iOS development tools configuration.

### Key Areas to Review
- Command line tools management
- Simulator configurations
- Build settings
- Integration with other dev tools" \
  --milestone 1 \
  --label "review,configuration"

# Issue 16
gh issue create \
  --title "Review: programs/yabai.nix" \
  --body "## Module: programs/yabai.nix

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
Yabai window manager configuration.

### Key Areas to Review
- Window management rules
- Keyboard shortcuts
- Integration with skhd
- Performance settings
- SIP requirements" \
  --milestone 1 \
  --label "review,configuration"

# Issue 17
gh issue create \
  --title "Review: programs/zsh.nix" \
  --body "## Module: programs/zsh.nix

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
Zsh shell configuration with oh-my-zsh.

### Related Files
- nix-darwin/hosts/programs/zsh.nix
- zsh/.zshrc

### Key Areas to Review
- Plugin management
- Theme configuration
- Performance optimizations
- Completion system
- History management" \
  --milestone 1 \
  --label "review,configuration,priority"

# Issue 18
gh issue create \
  --title "Review: terminal/editor.nix" \
  --body "## Module: terminal/editor.nix

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
Terminal editor configurations (Neovim, Helix, etc.).

### Key Areas to Review
- Editor selection and configuration
- Plugin management approach
- Language server integration
- Keybinding consistency" \
  --milestone 1 \
  --label "review,configuration"

# Issue 19
gh issue create \
  --title "Review: terminal/emulator.nix" \
  --body "## Module: terminal/emulator.nix

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
Terminal emulator configurations (WezTerm, Alacritty, etc.).

### Key Areas to Review
- Emulator selection
- Theme consistency
- Font configuration
- Performance settings
- Keybinding standardization" \
  --milestone 1 \
  --label "review,configuration"

# Issue 20
gh issue create \
  --title "Review: terminal/multiplexer.nix" \
  --body "## Module: terminal/multiplexer.nix

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
Terminal multiplexer configurations (tmux, Zellij).

### Related Files
- tmux configuration (missing main config)
- zellij/config.kdl

### Key Areas to Review
- Multiplexer selection (tmux vs Zellij)
- Session management
- Keybinding conflicts
- Plugin ecosystem
- Performance considerations" \
  --milestone 1 \
  --label "review,configuration"

# Issue 21-29: Remaining configuration reviews
gh issue create \
  --title "Review: terminal/shell.nix" \
  --body "## Module: terminal/shell.nix

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
Shell tools and utilities configuration." \
  --milestone 1 \
  --label "review,configuration"

gh issue create \
  --title "Review: terminal/ui.nix" \
  --body "## Module: terminal/ui.nix

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
Terminal UI tools configuration (lazygit, k9s, etc.)." \
  --milestone 1 \
  --label "review,configuration"

gh issue create \
  --title "Review: homebrew/cask.nix" \
  --body "## Module: homebrew/cask.nix

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
Homebrew cask management for GUI applications." \
  --milestone 1 \
  --label "review,configuration"

gh issue create \
  --title "Review: nvim configuration" \
  --body "## Module: Neovim Configuration

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
Complex Neovim setup with Lazy.nvim plugin manager.

### Related Files
- nvim/ directory
- Lua configuration files
- Plugin specifications

### Key Areas to Review
- Plugin management strategy
- LSP configuration
- Keybinding organization
- Performance optimizations" \
  --milestone 1 \
  --label "review,configuration,priority"

gh issue create \
  --title "Review: tmux configuration" \
  --body "## Module: tmux Configuration

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
Tmux configuration appears to be missing main config file." \
  --milestone 1 \
  --label "review,configuration"

gh issue create \
  --title "Review: zellij configuration" \
  --body "## Module: Zellij Configuration

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

### Related Files
- zellij/config.kdl" \
  --milestone 1 \
  --label "review,configuration"

gh issue create \
  --title "Review: k9s configuration" \
  --body "## Module: k9s Configuration

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

### Related Files
- k9s/config.yml
- k9s/skin.yml

### Key Areas to Review
- Cluster configurations
- Custom skins
- Keybindings
- Plugin integrations" \
  --milestone 1 \
  --label "review,configuration"

gh issue create \
  --title "Review: 1Password configuration" \
  --body "## Module: 1Password Configuration

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

### Related Files
- 1Password/agent.toml

### Key Areas to Review
- SSH agent configuration
- Git signing integration
- Security best practices" \
  --milestone 1 \
  --label "review,configuration,security,priority"

gh issue create \
  --title "Review: VPN configurations" \
  --body "## Module: VPN Configurations

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

### Related Files
- vpn/ directory
- WireGuard configurations

### Key Areas to Review
- Split tunnel implementation
- Security configurations
- Connection management" \
  --milestone 1 \
  --label "review,configuration,security"

echo "Created all 29 configuration review issues!"

# Special Feature Issues (Milestone 6)
echo "Creating special feature issues..."

gh issue create \
  --title "Feature: External Claude Config Loading" \
  --body "## Feature: External Claude Config Loading

### Requirements
- [ ] Load .claude configs from external GitHub repository
- [ ] Implement secure fetching mechanism
- [ ] Add update automation
- [ ] Handle authentication securely

### Acceptance Criteria
- Claude configurations can be loaded from a specified GitHub repository
- Updates can be triggered manually or automatically
- Configuration is validated before applying
- Sensitive data is handled securely

### Implementation Plan
1. Create fetching mechanism using nix-prefetch-git or similar
2. Implement configuration validation
3. Add update automation (systemd timer or launchd)
4. Create secure authentication method
5. Document usage and configuration

### Security Considerations
- Authentication tokens must be stored securely
- Downloaded configurations must be validated
- Consider signing/verification mechanism

### Documentation Requirements
- Setup guide for external repo
- Configuration format specification
- Security best practices" \
  --milestone 6 \
  --label "enhancement,feature,security"

gh issue create \
  --title "Feature: 1Password CLI Integration" \
  --body "## Feature: 1Password CLI Integration

### Requirements
- [ ] Audit all password/secret usage in configurations
- [ ] Integrate op CLI throughout the system
- [ ] Document security model
- [ ] Create helper functions for common operations

### Acceptance Criteria
- All secrets are managed through 1Password
- No plaintext secrets in configuration files
- Easy-to-use interface for secret retrieval
- Comprehensive documentation

### Implementation Plan
1. Audit current secret usage across all configurations
2. Install and configure op CLI via nix
3. Create Nix functions for secret retrieval
4. Migrate existing secrets to 1Password
5. Update all configurations to use op CLI
6. Create documentation and examples

### Security Considerations
- Minimize secret exposure in memory
- Implement proper session management
- Consider secret rotation strategies

### Areas to Integrate
- SSH keys and configurations
- API tokens and keys
- Database credentials
- Cloud provider credentials
- Git signing keys" \
  --milestone 6 \
  --label "enhancement,feature,security,priority"

gh issue create \
  --title "Feature: Split Tunnel VPN Configuration" \
  --body "## Feature: Split Tunnel VPN Configuration

### Requirements
- [ ] Implement split tunnel for WireGuard configurations
- [ ] Create per-application routing rules
- [ ] Document network architecture
- [ ] Ensure security is maintained

### Acceptance Criteria
- Specific applications can bypass VPN
- Routing rules are declaratively configured
- Network performance is optimized
- Security posture is maintained

### Implementation Plan
1. Research WireGuard split tunnel options on macOS
2. Design routing rule system
3. Implement per-application configurations
4. Create network namespace management
5. Test with various applications
6. Document configuration and usage

### Security Considerations
- Ensure no DNS leaks
- Validate routing rules
- Monitor for unexpected traffic
- Implement kill switch functionality

### Documentation Requirements
- Network architecture diagram
- Configuration examples
- Troubleshooting guide
- Security implications" \
  --milestone 6 \
  --label "enhancement,feature,security,networking"

echo "Created 3 special feature issues!"

# Infrastructure Issues
echo "Creating infrastructure issues..."

gh issue create \
  --title "Infra: mkOutOfStoreSymlink Helper Functions" \
  --body "## Infrastructure: mkOutOfStoreSymlink Helper Functions

### Requirements
- [ ] Create reusable helper functions for symlink management
- [ ] Support both file and directory symlinks
- [ ] Handle edge cases gracefully
- [ ] Provide clear error messages

### Implementation Plan
1. Create lib/symlinks.nix module
2. Implement mkOutOfStoreSymlink wrapper
3. Add validation and error handling
4. Create convenience functions
5. Document usage patterns

### Testing Strategy
- Unit tests for helper functions
- Integration tests with real configs
- Edge case testing" \
  --milestone 2 \
  --label "infrastructure,enhancement"

# Remaining Infrastructure Issues
gh issue create \
  --title "Infra: Hybrid Configuration Framework" \
  --body "## Infrastructure: Hybrid Configuration Framework

### Requirements
- [ ] Design framework for hybrid nix + traditional configs
- [ ] Support gradual migration paths
- [ ] Maintain consistency across approaches
- [ ] Enable easy switching between methods

### Implementation Plan
1. Create hybrid configuration patterns
2. Design migration utilities
3. Implement configuration validators
4. Create examples for common use cases
5. Document best practices

### Key Considerations
- Minimize duplication
- Clear separation of concerns
- Easy rollback capabilities" \
  --milestone 3 \
  --label "infrastructure,enhancement"

gh issue create \
  --title "Infra: Nix Secrets Management" \
  --body "## Infrastructure: Nix Secrets Management

### Requirements
- [ ] Implement secure secret handling in Nix
- [ ] Integrate with 1Password where possible
- [ ] Support multiple secret backends
- [ ] Ensure secrets never hit the Nix store

### Implementation Plan
1. Research nix-secrets and alternatives
2. Design secret management architecture
3. Implement secret providers
4. Create usage examples
5. Document security model

### Security Considerations
- Secrets must not be in Nix store
- Support runtime secret injection
- Implement access controls
- Enable secret rotation" \
  --milestone 6 \
  --label "infrastructure,security,priority"

gh issue create \
  --title "Infra: Module Structure Standardization" \
  --body "## Infrastructure: Module Structure Standardization

### Requirements
- [ ] Define standard module structure
- [ ] Create module templates
- [ ] Establish naming conventions
- [ ] Implement validation tools

### Implementation Plan
1. Analyze current module patterns
2. Define standard structure
3. Create module generator
4. Refactor existing modules
5. Document standards

### Module Standards
- Consistent option naming
- Clear documentation requirements
- Test requirements
- Example usage requirements" \
  --milestone 2 \
  --label "infrastructure,enhancement"

gh issue create \
  --title "Infra: Build Optimization" \
  --body "## Infrastructure: Build Optimization

### Requirements
- [ ] Optimize Nix build times
- [ ] Implement caching strategies
- [ ] Reduce unnecessary rebuilds
- [ ] Profile performance bottlenecks

### Implementation Plan
1. Profile current build times
2. Implement build caching
3. Optimize module dependencies
4. Create build performance metrics
5. Document optimization techniques

### Target Metrics
- Build time under 30 seconds
- Incremental rebuilds under 10 seconds
- Minimal network fetches" \
  --milestone 2 \
  --label "infrastructure,performance"

gh issue create \
  --title "Infra: Pre-commit Hooks for Nix" \
  --body "## Infrastructure: Pre-commit Hooks for Nix

### Requirements
- [ ] Add Nix formatting checks
- [ ] Implement Nix linting
- [ ] Add configuration validation
- [ ] Ensure fast execution

### Implementation Plan
1. Configure nixpkgs-fmt
2. Add statix for linting
3. Implement custom validators
4. Integrate with existing pre-commit
5. Document hook usage

### Hooks to Implement
- Nix formatting
- Nix linting
- Dead code detection
- Security scanning" \
  --milestone 2 \
  --label "infrastructure,quality"

gh issue create \
  --title "Infra: Backup/Restore Procedures" \
  --body "## Infrastructure: Backup/Restore Procedures

### Requirements
- [ ] Create backup strategies for configurations
- [ ] Implement restore procedures
- [ ] Support multiple backup destinations
- [ ] Enable automated backups

### Implementation Plan
1. Design backup architecture
2. Implement backup scripts
3. Create restore procedures
4. Add backup validation
5. Document recovery processes

### Backup Targets
- Configuration files
- Secret references
- System state
- User data references" \
  --milestone 2 \
  --label "infrastructure,reliability"

gh issue create \
  --title "Infra: Multi-machine Profile System" \
  --body "## Infrastructure: Multi-machine Profile System

### Requirements
- [ ] Support multiple machine configurations
- [ ] Share common configurations
- [ ] Handle platform differences
- [ ] Easy profile switching

### Implementation Plan
1. Design profile architecture
2. Create profile inheritance system
3. Implement platform detection
4. Add profile management tools
5. Document profile usage

### Profile Types
- Personal laptop
- Work machine
- Linux systems
- Minimal installations" \
  --milestone 3 \
  --label "infrastructure,enhancement"

gh issue create \
  --title "Infra: CI/CD Pipeline Setup" \
  --body "## Infrastructure: CI/CD Pipeline Setup

### Requirements
- [ ] Automated testing on commits
- [ ] Configuration validation
- [ ] Build verification
- [ ] Security scanning

### Implementation Plan
1. Configure GitHub Actions
2. Implement test runners
3. Add build verification
4. Create deployment workflows
5. Document CI/CD processes

### Pipeline Stages
- Syntax validation
- Unit tests
- Integration tests
- Security scans
- Documentation builds" \
  --milestone 5 \
  --label "infrastructure,automation"

gh issue create \
  --title "Infra: Development Environment" \
  --body "## Infrastructure: Development Environment

### Requirements
- [ ] Easy setup for contributors
- [ ] Consistent development experience
- [ ] Fast feedback loops
- [ ] Good debugging tools

### Implementation Plan
1. Create development shell
2. Add development utilities
3. Implement hot reloading
4. Create debugging helpers
5. Document development workflow

### Development Features
- Auto-completion for Nix
- Fast rebuild commands
- Configuration validators
- Testing utilities" \
  --milestone 2 \
  --label "infrastructure,developer-experience"

echo "Created 10 infrastructure issues!"

# Documentation Issues (Milestone 4)
echo "Creating documentation issues..."

gh issue create \
  --title "Docs: Main README Overhaul" \
  --body "## Documentation: Main README Overhaul

### Requirements
- [ ] Clear project overview
- [ ] Quick start guide
- [ ] Feature highlights
- [ ] Contribution guidelines

### Sections to Include
1. Project Overview
2. Features
3. Requirements
4. Quick Start
5. Architecture
6. Contributing
7. License

### Key Points
- Focus on user value
- Include screenshots/demos
- Clear installation steps
- Link to detailed docs" \
  --milestone 4 \
  --label "documentation,priority"

gh issue create \
  --title "Docs: MDBook Setup and Structure" \
  --body "## Documentation: MDBook Setup and Structure

### Requirements
- [ ] Configure MDBook for documentation
- [ ] Design documentation structure
- [ ] Implement search functionality
- [ ] Create deployment pipeline

### Book Structure
1. Introduction
2. Getting Started
3. Configuration Guide
4. Module Reference
5. Cookbook
6. Troubleshooting
7. Contributing

### Implementation Plan
1. Install and configure MDBook
2. Create initial structure
3. Set up GitHub Pages deployment
4. Add search and navigation
5. Create documentation templates" \
  --milestone 4 \
  --label "documentation,infrastructure"

gh issue create \
  --title "Docs: Module Documentation Standards" \
  --body "## Documentation: Module Documentation Standards

### Requirements
- [ ] Define documentation requirements
- [ ] Create documentation templates
- [ ] Implement documentation linting
- [ ] Ensure consistency

### Documentation Requirements
- Module purpose and overview
- Configuration options
- Usage examples
- Troubleshooting section
- Related modules

### Implementation Plan
1. Define documentation standards
2. Create module doc template
3. Add documentation linting
4. Update existing modules
5. Create style guide" \
  --milestone 4 \
  --label "documentation,standards"

gh issue create \
  --title "Docs: Inline Documentation Guidelines" \
  --body "## Documentation: Inline Documentation Guidelines

### Requirements
- [ ] Define inline documentation standards
- [ ] Create comment templates
- [ ] Ensure meaningful documentation
- [ ] Support doc generation

### Guidelines to Define
- When to add comments
- Comment formatting
- Documentation strings
- Type annotations
- Example requirements

### Implementation Plan
1. Research Nix documentation tools
2. Define comment standards
3. Create documentation snippets
4. Add linting rules
5. Generate API documentation" \
  --milestone 4 \
  --label "documentation,standards"

gh issue create \
  --title "Docs: Setup Guide (Fresh Install)" \
  --body "## Documentation: Setup Guide (Fresh Install)

### Requirements
- [ ] Step-by-step installation guide
- [ ] Platform-specific instructions
- [ ] Troubleshooting section
- [ ] Video walkthrough

### Guide Sections
1. Prerequisites
2. Installation Steps
3. Initial Configuration
4. Verification
5. Common Issues
6. Next Steps

### Platforms to Cover
- macOS (Intel)
- macOS (Apple Silicon)
- Linux variants
- WSL considerations" \
  --milestone 4 \
  --label "documentation,onboarding"

gh issue create \
  --title "Docs: Migration Guide (From Other Systems)" \
  --body "## Documentation: Migration Guide (From Other Systems)

### Requirements
- [ ] Migration paths from common tools
- [ ] Data preservation strategies
- [ ] Rollback procedures
- [ ] Comparison tables

### Migration Sources
- Homebrew-only setup
- GNU Stow
- Chezmoi
- Manual dotfiles
- Fresh macOS install

### Guide Components
1. Pre-migration checklist
2. Backup procedures
3. Migration steps
4. Verification process
5. Rollback instructions" \
  --milestone 4 \
  --label "documentation,migration"

gh issue create \
  --title "Docs: Troubleshooting Guide" \
  --body "## Documentation: Troubleshooting Guide

### Requirements
- [ ] Common issues and solutions
- [ ] Debugging procedures
- [ ] Error message explanations
- [ ] Recovery procedures

### Topics to Cover
- Build failures
- Configuration errors
- Performance issues
- Compatibility problems
- Recovery procedures

### Format
- Problem description
- Symptoms
- Root cause
- Solution steps
- Prevention tips" \
  --milestone 4 \
  --label "documentation,support"

gh issue create \
  --title "Docs: Security Best Practices" \
  --body "## Documentation: Security Best Practices

### Requirements
- [ ] Security guidelines
- [ ] Secret management guide
- [ ] Audit procedures
- [ ] Incident response

### Topics to Cover
- Secret management
- SSH key handling
- Git signing setup
- VPN configuration
- Security updates

### Documentation Goals
- Clear security model
- Practical examples
- Regular audit checklist
- Emergency procedures" \
  --milestone 4 \
  --label "documentation,security"

echo "Created 8 documentation issues!"

# Testing Issues (Milestone 5)
echo "Creating testing issues..."

gh issue create \
  --title "Test: Testing Tool Evaluation" \
  --body "## Testing: Testing Tool Evaluation

### Requirements
- [ ] Evaluate Nix testing frameworks
- [ ] Compare features and complexity
- [ ] Create proof of concepts
- [ ] Make recommendation

### Tools to Evaluate
- runTests (built-in)
- nix-unit
- NixTest
- namaka
- Custom solutions

### Evaluation Criteria
- Ease of use
- Feature completeness
- Performance
- Documentation
- Community support" \
  --milestone 5 \
  --label "testing,research"

gh issue create \
  --title "Test: Core Module Test Suite" \
  --body "## Testing: Core Module Test Suite

### Requirements
- [ ] Create tests for critical modules
- [ ] Ensure high coverage
- [ ] Test edge cases
- [ ] Performance benchmarks

### Modules to Test
- flake.nix configuration
- Core system modules
- Security modules
- Package installations
- Service configurations

### Test Types
- Unit tests
- Integration tests
- Configuration validation
- Performance tests" \
  --milestone 5 \
  --label "testing,quality"

gh issue create \
  --title "Test: Integration Test Framework" \
  --body "## Testing: Integration Test Framework

### Requirements
- [ ] Test multi-module interactions
- [ ] Verify system state
- [ ] Test upgrade paths
- [ ] Cross-platform testing

### Test Scenarios
- Fresh installation
- Configuration updates
- Module interactions
- Platform differences
- Rollback procedures

### Framework Features
- Automated test runs
- State verification
- Cleanup procedures
- Result reporting" \
  --milestone 5 \
  --label "testing,infrastructure"

gh issue create \
  --title "Test: Configuration Validation" \
  --body "## Testing: Configuration Validation

### Requirements
- [ ] Validate configuration syntax
- [ ] Check for conflicts
- [ ] Verify dependencies
- [ ] Security validation

### Validation Types
- Syntax checking
- Type validation
- Dependency resolution
- Security scanning
- Performance impact

### Implementation
- Pre-commit validation
- CI/CD integration
- Runtime checks
- Error reporting" \
  --milestone 5 \
  --label "testing,quality"

gh issue create \
  --title "Test: Performance Benchmarks" \
  --body "## Testing: Performance Benchmarks

### Requirements
- [ ] Measure build times
- [ ] Profile memory usage
- [ ] Track startup times
- [ ] Monitor system impact

### Metrics to Track
- Initial build time
- Rebuild time
- Memory usage
- Disk usage
- Network usage

### Benchmark Goals
- Establish baselines
- Track regressions
- Identify bottlenecks
- Optimize performance" \
  --milestone 5 \
  --label "testing,performance"

echo "Created 5 testing issues!"
echo "Total: 55 issues created successfully!"
echo ""
echo "To create all issues in GitHub, run:"
echo "  ./scripts/create-github-issues.sh"
echo ""
echo "Note: This will create 55 issues, so you may want to run it in batches"
echo "or modify the script to add delays between issue creation."
