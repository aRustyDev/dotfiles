# Archive original git-setup implementation

## Description

Move the original `git_setup.sh` script to a legacy directory and document its behavior for reference during the transformation.

## Tasks

- [ ] Create `git/commands/legacy/` directory structure
- [ ] Move `git_setup.sh` to `legacy/git_setup_original.sh` preserving git history
- [ ] Create comprehensive documentation of original behavior
- [ ] Document all dependencies and requirements
- [ ] List known issues and limitations
- [ ] Create migration notes for users

## Acceptance Criteria

- Original script is preserved with full git history
- Documentation clearly explains how the original worked
- Known issues are documented
- Migration path is clear

## Technical Details

The original script:
- Located at `git/commands/git_setup.sh`
- Requires: op, yq, jq, npm, pip
- Reads from `~/.config/1Password/ssh/agent.toml`
- Supports profiles: github, gitlab, work, home

## Labels

- `task`
- `documentation`
- `git`

## Milestone

Configuration Review
