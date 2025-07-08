fix(nix-darwin): update agent.toml and fix dotfiles paths

- Updated 1Password/agent.toml with improved formatting and Nix management header
- Fixed case-sensitive path references (1password → 1Password) in nix configs
- Corrected all dotfiles paths from ~/repos/code/personal/dotfiles to ~/dotfiles
- Changed from absolute paths with builtins.toPath to relative paths to avoid pure evaluation issues
- Updated flake.lock with latest dependencies
- Modified flake.nix to properly pass inputs to home-manager configuration

These changes ensure the agent.toml file is properly managed by Nix and all
dotfiles are correctly sourced from the actual repository location.

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>