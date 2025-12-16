# Git Workflow Rules

## Branch Strategy
- Use feature branches for all development
- Never commit directly to main/master

## Issue Management
- Issues should only be closed via Pull Request, not manually
- Link PRs to issues using "Closes #X" or "Fixes #X" in PR description

## Commit Format

### Header (Conventional Commit)
```
<type>(<scope>): <description>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

### Body (Keep-a-Changelog Format)
```
### Added
- New features

### Changed
- Changes to existing functionality

### Fixed
- Bug fixes

### Removed
- Removed features
```

### Example
```
feat(auth): add OAuth2 login support

### Added
- OAuth2 authentication flow with Google and GitHub providers
- Token refresh mechanism for expired sessions

### Changed
- Login page now shows social login buttons
```
