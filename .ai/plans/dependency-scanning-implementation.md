---
title: Dependency Scanning Implementation Plan
status: active
created: 2025-12-04
adr: ../docs/adr/dependency-scanning-strategy.md
tags: [security, dependencies, ci-cd, github-actions, rust]
---

# Dependency Scanning Implementation Plan

## Overview

Implement comprehensive dependency vulnerability scanning across multiple ecosystems using a defense-in-depth strategy. This plan derives from [ADR: Dependency Scanning Strategy](../docs/adr/dependency-scanning-strategy.md).

## Objectives

1. Establish automated vulnerability detection for all dependency ecosystems
2. Implement policy enforcement (licenses, bans, sources)
3. Create audit trails for supply chain compliance
4. Enable community trust verification for Rust crates

## Phase Summary

| Phase | Focus | Priority | Status |
|-------|-------|----------|--------|
| 1 | Foundation - Dependabot & dependency-review | High | Pending |
| 2 | PR-blocking workflows | High | Pending |
| 3 | Ecosystem-specific scheduled scans | Medium | Pending |
| 4 | Rust defense-in-depth (4 tools) | Medium | Pending |
| 5 | Automation & auto-merge | Low | Pending |

---

## Phase 1: Foundation

**Goal**: Establish baseline dependency management with Dependabot and PR blocking.

### Task 1.1: Create dependabot.yml

**File**: `.github/dependabot.yml`

```yaml
version: 2
updates:
  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    commit-message:
      prefix: "ci(deps)"

  # npm (if applicable)
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    commit-message:
      prefix: "chore(deps)"
    open-pull-requests-limit: 10

  # Python pip
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    commit-message:
      prefix: "chore(deps)"

  # Go modules
  - package-ecosystem: "gomod"
    directory: "/"
    schedule:
      interval: "weekly"
    commit-message:
      prefix: "chore(deps)"

  # Rust Cargo
  - package-ecosystem: "cargo"
    directory: "/"
    schedule:
      interval: "weekly"
    commit-message:
      prefix: "chore(deps)"

  # Docker
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
    commit-message:
      prefix: "chore(deps)"
```

- [ ] 1.1.1 Create `.github/dependabot.yml` with multi-ecosystem support
- [ ] 1.1.2 Configure commit message prefixes for conventional commits
- [ ] 1.1.3 Set appropriate schedule intervals per ecosystem
- [ ] 1.1.4 Verify Dependabot is enabled in repository settings

### Task 1.2: Create dependency-review.yml

**File**: `.github/workflows/dependency-review.yml`

```yaml
name: Dependency Review

on:
  pull_request:
    branches: [main]

permissions:
  contents: read
  pull-requests: write

jobs:
  dependency-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Dependency Review
        uses: actions/dependency-review-action@v4
        with:
          fail-on-severity: high
          deny-licenses: GPL-3.0, AGPL-3.0
          comment-summary-in-pr: always
```

- [ ] 1.2.1 Create `dependency-review.yml` workflow
- [ ] 1.2.2 Configure severity threshold (high)
- [ ] 1.2.3 Configure denied licenses
- [ ] 1.2.4 Enable PR commenting

---

## Phase 2: PR-Blocking Workflows

**Goal**: Block PRs that introduce vulnerabilities or policy violations.

### Task 2.1: Universal Security Check

**File**: `.github/workflows/security-deps.yml`

- [ ] 2.1.1 Create unified security check workflow
- [ ] 2.1.2 Add ecosystem detection logic
- [ ] 2.1.3 Configure as required status check

---

## Phase 3: Ecosystem-Specific Scanning

**Goal**: Scheduled deep scans for each ecosystem with detailed reporting.

### Task 3.1: deps-npm.yml

**File**: `.github/workflows/deps-npm.yml`

- [ ] 3.1.1 Create workflow with `npm audit --json`
- [ ] 3.1.2 Add SARIF output for GitHub Security tab
- [ ] 3.1.3 Configure weekly schedule
- [ ] 3.1.4 Add manual trigger (workflow_dispatch)

### Task 3.2: deps-python.yml

**File**: `.github/workflows/deps-python.yml`

- [ ] 3.2.1 Install safety and pip-audit
- [ ] 3.2.2 Run both scanners with JSON output
- [ ] 3.2.3 Upload results as artifacts
- [ ] 3.2.4 Configure weekly schedule

### Task 3.3: deps-go.yml

**File**: `.github/workflows/deps-go.yml`

- [ ] 3.3.1 Install govulncheck
- [ ] 3.3.2 Run `govulncheck -json ./...`
- [ ] 3.3.3 Parse and report vulnerabilities
- [ ] 3.3.4 Configure weekly schedule

### Task 3.4: deps-rust.yml (Defense-in-Depth)

**File**: `.github/workflows/deps-rust.yml`

This workflow implements the four-layer defense model:

```yaml
name: Rust Supply Chain Security

on:
  push:
    branches: [main]
  pull_request:
    paths:
      - '**/Cargo.toml'
      - '**/Cargo.lock'
      - 'deny.toml'
      - 'supply-chain/**'
  schedule:
    - cron: '0 6 * * 1'  # Weekly Monday 6am

jobs:
  # Layer 1: Known Vulnerabilities
  cargo-audit:
    name: "Layer 1: Vulnerability Scan"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: rustsec/audit-check@v2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

  # Layer 2: Policy Enforcement
  cargo-deny:
    name: "Layer 2: Policy Check"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EmbarkStudios/cargo-deny-action@v2

  # Layer 3: Audit Trail
  cargo-vet:
    name: "Layer 3: Audit Verification"
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule'
    steps:
      - uses: actions/checkout@v4
      - run: cargo install cargo-vet
      - run: cargo vet --locked

  # Layer 4: Community Trust
  cargo-crev:
    name: "Layer 4: Community Reviews"
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule'
    continue-on-error: true
    steps:
      - uses: actions/checkout@v4
      - run: cargo install cargo-crev
      - run: cargo crev repo fetch all
      - run: cargo crev crate verify --recursive
```

- [ ] 3.4.1 Create deps-rust.yml with four-layer structure
- [ ] 3.4.2 Configure cargo-audit for every PR
- [ ] 3.4.3 Configure cargo-deny for every PR
- [ ] 3.4.4 Configure cargo-vet for weekly runs
- [ ] 3.4.5 Configure cargo-crev as advisory (non-blocking)

### Task 3.5: deps-container.yml

**File**: `.github/workflows/deps-container.yml`

- [ ] 3.5.1 Create workflow using trivy or grype
- [ ] 3.5.2 Scan Dockerfiles for base image vulnerabilities
- [ ] 3.5.3 Scan built images if applicable
- [ ] 3.5.4 Configure weekly schedule

---

## Phase 4: Rust Configuration Files

**Goal**: Create policy configuration for cargo-deny and cargo-vet.

### Task 4.1: deny.toml

**File**: `deny.toml`

- [ ] 4.1.1 Create deny.toml with advisories section
- [ ] 4.1.2 Configure licenses allowlist
- [ ] 4.1.3 Configure bans (openssl → rustls)
- [ ] 4.1.4 Configure sources (crates.io only)
- [ ] 4.1.5 Test with `cargo deny check`

### Task 4.2: supply-chain/

**Directory**: `supply-chain/`

- [ ] 4.2.1 Run `cargo vet init`
- [ ] 4.2.2 Configure imports from Mozilla, Embark, bytecode-alliance
- [ ] 4.2.3 Define custom criteria if needed
- [ ] 4.2.4 Certify existing dependencies
- [ ] 4.2.5 Test with `cargo vet`

### Task 4.3: cargo-crev identity

- [ ] 4.3.1 Create crev identity with `cargo crev id new`
- [ ] 4.3.2 Configure trust for known reviewers
- [ ] 4.3.3 Document review workflow for team

---

## Phase 5: Automation

**Goal**: Automate safe dependency updates.

### Task 5.1: Extend dependabot.yml

- [ ] 5.1.1 Add groups for related dependencies
- [ ] 5.1.2 Configure ignore patterns for major versions
- [ ] 5.1.3 Set reviewer assignments

### Task 5.2: dependabot-auto-merge.yml

**File**: `.github/workflows/dependabot-auto-merge.yml`

```yaml
name: Dependabot Auto-Merge

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: write
  pull-requests: write

jobs:
  auto-merge:
    runs-on: ubuntu-latest
    if: github.actor == 'dependabot[bot]'
    steps:
      - name: Dependabot metadata
        id: metadata
        uses: dependabot/fetch-metadata@v2
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}

      - name: Auto-merge patch updates
        if: steps.metadata.outputs.update-type == 'version-update:semver-patch'
        run: gh pr merge --auto --squash "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- [ ] 5.2.1 Create auto-merge workflow
- [ ] 5.2.2 Configure for patch updates only
- [ ] 5.2.3 Require CI to pass before merge
- [ ] 5.2.4 Test with a patch dependency update

---

## Pre-commit Integration

### Task 6.1: Add cargo-audit to pre-commit

**File**: `.pre-commit-config.yaml`

```yaml
repos:
  - repo: local
    hooks:
      - id: cargo-audit
        name: cargo-audit
        entry: cargo audit
        language: system
        types: [rust]
        pass_filenames: false
```

- [ ] 6.1.1 Add cargo-audit hook
- [ ] 6.1.2 Test hook locally
- [ ] 6.1.3 Document in CONTRIBUTING.md

---

## Verification Checklist

After implementation, verify:

- [ ] Dependabot creates PRs for outdated dependencies
- [ ] dependency-review blocks PRs with high severity vulns
- [ ] deps-rust.yml runs all four layers
- [ ] cargo-deny blocks license violations
- [ ] cargo-vet tracks audit status
- [ ] Auto-merge works for patch updates
- [ ] Pre-commit hook catches vulnerabilities locally

---

## References

- [ADR: Dependency Scanning Strategy](../docs/adr/dependency-scanning-strategy.md)
- [GitHub Dependency Review Action](https://github.com/actions/dependency-review-action)
- [Dependabot Configuration](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file)
- [cargo-audit](https://github.com/rustsec/rustsec/tree/main/cargo-audit)
- [cargo-deny](https://embarkstudios.github.io/cargo-deny/)
- [cargo-vet](https://mozilla.github.io/cargo-vet/)
- [cargo-crev](https://github.com/crev-dev/cargo-crev)
