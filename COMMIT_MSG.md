feat(git): transform git-setup command to eliminate agent.toml dependency

- Archive original git_setup.sh to legacy directory with documentation
- Create comprehensive project structure for git command management
- Add documentation: architecture, migration guide, and changelog
- Prepare GitHub issue templates for tracking transformation progress
- Add setup and installation scripts for easy deployment
- Maintain backward compatibility with simple 'git setup <profile>' interface

This transformation allows git-setup to work directly with 1Password without
requiring modifications to agent.toml that break the SSH agent functionality.

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
