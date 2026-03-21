# Dotfiles

## Repository

Personal dotfiles managed via `just` modules. Each tool, shell, editor, and service has its own justfile with `install`, `config`, and `mktree` recipes. The root justfile registers all modules and provides a cascading `just install` that fans out to every registered module.

Platform: macOS (Darwin). Shell: zsh. Package manager: Homebrew. Secrets: 1Password CLI (`op inject`, `op read`). Config hydration: `envsubst` + `op inject` from templates. XDG directory conventions throughout.

## Justfile Module Strategy

The repo is organized as a tiered module tree. Modules are accessed via `just <group> <module> <recipe>` or `just <group>:<module>:<recipe>`. Max depth is 3 tiers; prefer brevity.

### Core (direct modules)
```
git          # Git version control with 1Password signing
ssh          # SSH client configuration
op           # 1Password CLI
```

### Groups
```
shell        zsh, bash, starship
term         alacritty, ghostty, kitty, wezterm, mux:{tmux,zellij}
editor       nvim, vscode, zed
db           meilisearch, dolt
svc          ntfy, n8n
infra        docker, helm, k9s, kube, terraform
os           macos, cron, pam, paths
vpn          wireguard
wm           aerospace, amethyst
browser      zen
ver          mise, tenv, volta
tool         fzf, zoxide, fd, ripgrep, direnv, jq, yazi
             design:{sketch,gimp} lint:{codebook,shellcheck}
             agent:{adrs,beads,gastown} font keeb:{karabiner,skhd}
             other:{glab,sourcebot,stow,...}
```

### Conventions
- **Group justfiles** are aggregators: they declare `mod` entries and provide an `install` recipe that cascades to children via `just -f`
- **Leaf justfiles** follow: `set shell`, `import lib.just`, `dotdir := shell("yq '.dotdir' data.yml | envsubst")`, then `install`, `config`, `mktree` recipes
- **Shared library** at `.build/just/lib.just` provides `root`, XDG paths (`xdg_bin`, `xdg_data`, `xdg_cache`, `xdg_state`, `xdg_config`), data file references, and helpers (`op_id`, `_lib_install`)
- Adding a module: create `<dir>/justfile` + `data.yml`, register `mod` in the parent group justfile, the parent's `install` recipe handles cascading
- `just install` at root runs every registered module's install
- `just list` shows the full module map

### Self-Update
When adding a new tool or service to this repo:
1. Create `<dir>/justfile` (follow leaf justfile conventions) and `data.yml`
2. Register `mod <name> '<path>/justfile'` in the appropriate group justfile
3. Add the module to the group's `install` recipe loop
4. Update the module tree in this file and in `ai/claude/context.md`
5. If a new group is created, register it in the root justfile and update `just list`

## Workflow Tools

### bd (beads) — Issue Tracking
```bash
bd ready                              # Find available work
bd show <id>                          # View issue details
bd update <id> --status in_progress   # Claim work
bd close <id>                         # Complete work
bd sync                               # Sync with git
```
All work must be tracked in bd. Create issues for remaining work before ending a session.

### adrs — Architecture Decision Records
```bash
adrs new -C docs/src/adrs/<subcategory> --format madr --no-edit --status proposed "<Title>"
adrs status -C docs/src/adrs/<subcategory> <N> accepted
adrs link -C docs/src/adrs/<subcategory> <SOURCE> Amends <TARGET>
```
Write an ADR for: repo boundary decisions, tool/technology selections, security architecture, state management. Do not write ADRs for routine config, version bumps, or bug fixes. Location: `docs/src/adrs/<subcategory>/<nnnn>-<slug>.md`. Format: MADR. Always `--no-edit` in non-interactive contexts.

### mdbook — Documentation
Documentation lives in `docs/src/` and is built with mdbook. ADRs, guides, and reference material go here. Keep docs close to the decisions they describe.

### just — Repo Controller
Justfiles are the primary interface for operating this repo. See Module Tree above. Prefer `just <recipe>` over raw shell commands when a recipe exists.

## Development Methodology

### FDD — Feature-Driven Development (Planning)
Used for planning before any non-trivial implementation.
1. Identify the feature or change from bd issues
2. Build a feature list — decompose into atomic, client-valued functions
3. Plan by feature — design each function, identify files to create/modify, define interfaces
4. Seek approval on the plan before writing code
5. Build by feature — implement one feature at a time through the TDD/BDD cycles below

### TDD — Test-Driven Development (Unit Tests)
Used for all unit-level implementation.
1. **Red** — Write a failing test that describes the desired behavior
2. **Green** — Write the minimum code to make the test pass
3. **Refactor** — Improve structure without changing behavior, all tests still pass
4. Commit after each green+refactor cycle
5. Never write implementation code without a failing test first

### BDD — Behavior-Driven Development (Phases & Acceptance Tests)
Used for phase-level planning and acceptance criteria.
1. Define scenarios in Given/When/Then format from the user's perspective
2. Scenarios map to acceptance tests — one scenario per behavior
3. Group scenarios into phases; each phase is a deliverable milestone
4. A phase is complete when all its scenarios pass
5. Acceptance tests are the contract — do not weaken them to make code pass

### How They Fit Together
```
FDD: Plan features → decompose into phases (BDD) and units (TDD)
 └─ BDD: Define phase scenarios (Given/When/Then) → acceptance tests
     └─ TDD: Implement each unit (Red/Green/Refactor) → unit tests
         └─ Phase complete when all acceptance scenarios pass
```

## Git Workflow

### Branch Strategy
- Use feature branches for all development
- Never commit directly to main/master
- Issues are closed via Pull Request, not manually
- Link PRs to issues using `Closes #X` or `Fixes #X` in PR description

### Commit Format
Header uses Conventional Commits, body uses Keep-a-Changelog format:
```
<type>(<scope>): <description>

### Added
- New features

### Changed
- Changes to existing functionality

### Fixed
- Bug fixes

### Removed
- Removed features
```
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

Only include body sections that apply. Omit empty sections.

## Session Protocol

### Starting a Session
1. `bd ready` to find available work
2. `bd update <id> --status in_progress` to claim it
3. Create a feature branch from main

### Ending a Session
All steps are mandatory. Work is NOT complete until `git push` succeeds.
1. File issues for remaining work — `bd` issues for anything needing follow-up
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

Never stop before pushing. Never say "ready to push when you are" — push it yourself. If push fails, resolve and retry until it succeeds.
