# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Repo Controller

This repo is operated via `just` modules. Prefer `just <recipe>` over raw shell commands when a recipe exists. Run `just list` to see all available module groups, or `just --list <group>` to drill into a group.

## Session Completion

**When ending a work session**, all steps below are mandatory. Work is NOT complete until `git push` succeeds.

1. File issues for remaining work
2. Run quality gates if code changed — tests, linters, builds
3. Update issue status — close finished work, update in-progress items
4. Push to remote:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # Must show "up to date with origin"
   ```
5. Clean up — clear stashes, prune stale branches
6. Hand off — provide context for the next session

Never stop before pushing. If push fails, resolve and retry until it succeeds.
