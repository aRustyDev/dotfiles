# Dotfiles Documentation Index

Welcome to the dotfiles repository documentation. This index provides a comprehensive overview of all documentation available in this repository.

## 🏠 Core Documentation

### Project Overview
- **[README.md](../README.md)** - Main repository documentation explaining the Nix-Darwin dotfiles system
- **[CLAUDE.local.md](CLAUDE.local.md) ⭐** - Local Claude configuration and repository context
- **[PROJECT.md](PROJECT.md)** - Project management context and development workflow

### System Architecture
- **[Dotfiles Architecture Overview](context/dotfiles-architecture.md) ⭐** - Repository structure and configuration hierarchy
- **[Nix-Darwin Patterns](context/nix-darwin-patterns.md) ⭐** - Common patterns and best practices
- **[Repository Workflows](context/repository-workflows.md) ⭐** - Development procedures and maintenance
- **[Dotfiles Evolution Roadmap](context/dotfiles-evolution-roadmap.md)** - Strategic plan for repository evolution

### Module Documentation
- **[MCP Server Configuration](context/mcp-servers.md) ⭐** - MCP server management system
- **[Git Commands Module](context/git-commands.md)** - Git setup command system

## 📚 Development Guides

### Nix Development on macOS
- **[Nix Development Guide](guides/nix-development-macos.md) ⭐** - Essential concepts and workflow
- **[Nix Troubleshooting Guide](guides/nix-troubleshooting.md) ⭐** - Common issues and solutions
- **[Nix Module Development](guides/nix-module-development.md) ⭐** - Creating custom Nix modules
- **[Lessons Learned](guides/lessons-learned-nix.md) ⭐** - Real-world experiences and solutions
- **[Nix Quick Reference](guides/nix-quick-reference.md) ⭐** - Command reference and common patterns

## 🛠️ Nix-Darwin Configuration

### Core Documentation
- **[nix-darwin/MACHINES.md](../nix-darwin/MACHINES.md)** - Multi-machine configuration guide
- **[nix-darwin/SETUP-ANALYST.md](../nix-darwin/SETUP-ANALYST.md)** - Analyst user profile setup instructions
- **[nix-darwin/hosts/npm-tools/README.md](../nix-darwin/hosts/npm-tools/README.md)** - Volta-based npm package management

### Task Tracking
- **[nix-darwin/TODO.md](../nix-darwin/TODO.md)** - Nix-Darwin configuration tasks
- **[nix-darwin/hosts/TODO.md](../nix-darwin/hosts/TODO.md)** - Packages to be added to nix configuration

## 🔧 Git Configuration

### Main Documentation
- **[git/README.md](../git/README.md)** - Git configuration overview
- **[git/commands/README.md](../git/commands/README.md)** - Git-setup command documentation
- **[git/commands/GIT_SETUP_GUIDE.md](../git/commands/GIT_SETUP_GUIDE.md)** - Comprehensive git-setup guide

### Technical Documentation
- **[git/docs/ARCHITECTURE.md](../git/docs/ARCHITECTURE.md)** - Technical architecture deep dive
- **[git/docs/MIGRATION.md](../git/docs/MIGRATION.md)** - Detailed migration guide from 1Password

### Legacy Documentation
- **[git/commands/legacy/README.md](../git/commands/legacy/README.md)** - Original implementation documentation

## 📚 Personal References

### Notes
- **[data/notes/app-ideas.md](../data/notes/app-ideas.md)** - Application ideas and concepts

### Bookmarks
- **Education**
  - [data/bookmarks/edu/nvim.md](../data/bookmarks/edu/nvim.md) - Neovim learning resources
- **Research**
  - [data/bookmarks/research/ai.md](../data/bookmarks/research/ai.md) - AI research links
  - [data/bookmarks/research/reverse-engineering.md](../data/bookmarks/research/reverse-engineering.md) - Reverse engineering resources
- **Blogs**
  - [data/bookmarks/blogs/reverse-engineering.md](../data/bookmarks/blogs/reverse-engineering.md) - RE blog collection
  - [data/bookmarks/blogs/windows.md](../data/bookmarks/blogs/windows.md) - Windows development blogs
- **Other**
  - [data/bookmarks/meetups/raw.md](../data/bookmarks/meetups/raw.md) - Meetup information
  - [data/bookmarks/projects/ecad.md](../data/bookmarks/projects/ecad.md) - ECAD project resources

## 🎯 Quick Reference by Task

### Setting Up a New Machine
1. [Nix-Darwin Machines Guide](../nix-darwin/MACHINES.md)
2. [Repository Workflows](context/repository-workflows.md)
3. [Nix Troubleshooting Guide](guides/nix-troubleshooting.md)

### Developing Nix Modules
1. [Nix Module Development](guides/nix-module-development.md)
2. [Nix-Darwin Patterns](context/nix-darwin-patterns.md)
3. [Nix Development Guide](guides/nix-development-macos.md)

### Working with MCP Servers
1. [MCP Server Configuration](context/mcp-servers.md)
2. [MCP README](../mcp/README.md)
3. [MCP Examples](../mcp/examples/)

### Troubleshooting Issues
1. [Nix Troubleshooting Guide](guides/nix-troubleshooting.md)
2. [Repository Workflows](context/repository-workflows.md) - See Troubleshooting Workflow
3. [Git Architecture](../git/docs/ARCHITECTURE.md) - For git-setup issues

## 📋 Documentation Standards

### File Organization
- **`.claude/`** - Claude AI context and guides
  - `context/` - System state and configuration documentation
  - `guides/` - How-to guides and learning resources
- **Module directories** - Module-specific documentation
- **`docs/` subdirectories** - Technical deep-dives
- **`data/`** - Personal references and bookmarks

### Documentation Types
1. **README.md** - Overview and getting started guides
2. **GUIDE.md** - Comprehensive usage documentation
3. **ARCHITECTURE.md** - Technical implementation details
4. **TODO.md** - Task tracking (consider converting to GitHub issues)
5. **SETUP-*.md** - Installation and configuration instructions
6. **Context files** - System state for AI assistance

### Best Practices
- Keep documentation close to the code it describes
- Use clear, descriptive titles
- Include examples where appropriate
- Cross-reference related documentation
- Update documentation when making code changes
- Mark essential docs with ⭐ in the index

## 🔍 Quick Links

### Essential Reading
1. [Main README](../README.md) - Start here
2. [Nix-Darwin Machines Guide](../nix-darwin/MACHINES.md) - For multi-machine setup
3. [Git Setup Guide](../git/commands/GIT_SETUP_GUIDE.md) - For git configuration

### For Contributors
1. [PROJECT.md](PROJECT.md) - Development workflow
2. [Git Architecture](../git/docs/ARCHITECTURE.md) - For extending git-setup

### For Migration
1. [Git Migration Guide](../git/docs/MIGRATION.md) - Migrating from 1Password git setup

---

*Last updated: December 2024*
