# Changelog

All notable changes to the git-setup command will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Project restructuring with legacy directory
- Comprehensive documentation (Architecture, Migration guides)
- Multiple implementation options (v2, advanced, Python, SQLite)

## [2.0.0] - 2024-01-15

### Added
- Advanced version with caching support
- Fuzzy profile name matching
- Interactive search functionality
- Profile preview before configuration
- Custom name/email override support
- Cache management for better performance

### Changed
- Complete rewrite to eliminate agent.toml dependency
- Profile storage now uses local JSON files
- Improved error messages and user experience

## [1.0.0] - 2024-01-15

### Added
- MVP implementation (git-setup-v2)
- Basic profile management (add, list, delete)
- Direct 1Password integration via op CLI
- JSON-based profile storage
- Interactive profile selection
- SSH commit signing configuration

### Changed
- No longer requires modifying agent.toml
- Profiles stored separately from 1Password config
- Simplified dependency requirements

### Removed
- Dependency on yq for TOML parsing
- Hardcoded profile limitations
- agent.toml name field requirements

## [0.1.0] - Original

### Initial Implementation
- Required agent.toml modifications
- Limited to 4 predefined profiles (github, gitlab, work, home)
- Used yq for TOML parsing
- Integrated with 1Password CLI
- Set up git commit signing with SSH keys
- OS-specific configuration support
- Pre-commit hook installation

### Known Issues
- name fields in agent.toml had to be commented out
- Function called before definition (line 14)
- Limited profile flexibility
- No profile management capabilities
