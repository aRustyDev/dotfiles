---
id: b2c3d4e5-f6a7-8901-bcde-f23456789012
title: "ADR: Dependency Scanning Strategy"
created: 2025-12-04T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - security
  - rust
type: adr
status: ✅ approved
publish: false
tags:
  - adr
  - architecture
  - security
  - dependencies
  - ci-cd
  - rust
aliases:
  - Dependency Scanning ADR
  - Rust Supply Chain Security
related:
  - ref: "[[rust-supply-chain-tools]]"
    description: Detailed tool comparison
adr:
  number: "002"
  supersedes: null
  superseded_by: null
  deciders:
    - arustydev
---

# ADR: Dependency Scanning Strategy

## Status

Approved

## Context

This project requires comprehensive dependency vulnerability scanning across multiple ecosystems (npm, Python, Go, Rust, containers). Multiple overlapping tools and workflows needed consolidation.

---

## Decision

### Workflow Purpose Clarification

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| dependency-review.yml | pull_request | Block PRs with vulnerable deps |
| deps-*.yml | schedule / workflow_dispatch | Report outdated deps |
| dependabot.yml | Dependabot | Auto-create update PRs |
| dependabot-auto-merge.yml | pull_request | Auto-merge safe updates |

### Consolidation Decisions

#### 1. dependabot.yml - Single Source (APPROVED)

- **Phase 1.3.1**: Create `dependabot.yml` with multi-ecosystem support
- **Phase 5.3.1**: Extend existing `dependabot.yml` with auto-merge rules

Rationale: A single `dependabot.yml` file should define all ecosystem configurations.

#### 2. Container Dependency Scanning (APPROVED)

- **Phase 3.17.5**: Create `deps-container.yml` for Dockerfile base image checks

Rationale: Container base images require separate scanning from application dependencies.

#### 3. Rust Security Tools - Defense-in-Depth (APPROVED)

Use **cargo-audit**, **cargo-deny**, **cargo-vet**, and **cargo-crev** as complementary layers.

---

## Rust Supply Chain Security: Defense-in-Depth

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        RUST SUPPLY CHAIN SECURITY                           │
│                         Defense-in-Depth Model                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Layer 1: KNOWN VULNERABILITIES (Reactive)                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  cargo-audit                                                         │   │
│  │  • Scans against RustSec Advisory Database                          │   │
│  │  • Auto-fix capability for quick remediation                        │   │
│  │  Question answered: "Does this have KNOWN vulnerabilities?"         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  Layer 2: POLICY ENFORCEMENT (Preventive)                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  cargo-deny                                                          │   │
│  │  • License compliance (GPL contamination, etc.)                     │   │
│  │  • Banned crates (openssl-sys → rustls)                             │   │
│  │  • Source restrictions (only crates.io)                             │   │
│  │  Question answered: "Does this meet our POLICIES?"                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  Layer 3: AUDIT TRAIL (Detective)                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  cargo-vet                                                           │   │
│  │  • Tracks who audited each dependency                               │   │
│  │  • Imports audits from trusted organizations                        │   │
│  │  Question answered: "Has this been AUDITED by someone we trust?"    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  Layer 4: COMMUNITY TRUST (Proactive)                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  cargo-crev                                                          │   │
│  │  • Cryptographically signed reviews                                 │   │
│  │  • Web of trust model                                               │   │
│  │  Question answered: "What does the COMMUNITY think of this?"        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Tool Comparison

| Feature | cargo-audit | cargo-deny | cargo-vet | cargo-crev |
|---------|:-----------:|:----------:|:---------:|:----------:|
| **Focus** | Known vulns | Policies | Audit trail | Community trust |
| **Data source** | RustSec DB | Config file | Org audits | Web of trust |
| **Configuration** | None | deny.toml | supply-chain/ | ~/.config/crev |
| **Speed** | Fast (<5s) | Medium (~30s) | Medium (~30s) | Slow (network) |
| **Blocks PRs** | Yes | Yes | Optional | No (advisory) |

---

## When to Use Each Tool

### By Development Lifecycle Stage

| Stage | Tool | Purpose | Frequency |
|-------|------|---------|-----------|
| **Adding new dependency** | cargo-crev | Check community reviews | On-demand |
| **Adding new dependency** | cargo-vet | Check if already audited | On-demand |
| **Pre-commit hook** | cargo-audit | Fast vulnerability check | Every commit |
| **Pull Request** | cargo-audit | Block PRs with known vulns | Every PR |
| **Pull Request** | cargo-deny | Enforce license/ban policies | Every PR |
| **Weekly CI** | cargo-deny | Comprehensive policy scan | Scheduled |
| **Before release** | All four | Full supply chain verification | Release gate |

### By Attack Vector Mitigated

| Attack Vector | Tool | How It Helps |
|--------------|------|--------------|
| **Known vulnerability exploitation** | cargo-audit | Detects published CVEs |
| **Typosquatting** | cargo-deny | Ban known typosquats |
| **License violation lawsuit** | cargo-deny | Enforce license allowlist |
| **Malicious maintainer** | cargo-vet + cargo-crev | Require human review |
| **Dependency confusion** | cargo-deny | Restrict to crates.io only |
| **Supply chain injection** | cargo-vet | Audit trail of all deps |

---

## Implementation

### Installation

```bash
cargo install cargo-audit --features=fix
cargo install cargo-deny
cargo install cargo-vet
cargo install cargo-crev

# Initialize configurations
cargo deny init          # Creates deny.toml
cargo vet init           # Creates supply-chain/
cargo crev id new        # Creates reviewer identity
```

### Example deny.toml

```toml
[advisories]
vulnerability = "deny"
unmaintained = "warn"
yanked = "deny"

[licenses]
allow = ["MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause", "ISC"]

[bans]
multiple-versions = "warn"
wildcards = "deny"
deny = [
    { crate = "openssl-sys", use-instead = "rustls" },
]

[sources]
unknown-registry = "deny"
unknown-git = "deny"
```

---

## Consequences

### Positive

- Four layers of defense covering different attack vectors
- Known vulnerabilities caught immediately
- Policy violations prevented
- Audit trail for compliance
- Progressive adoption possible

### Negative

- Four tools to maintain
- Multiple configuration files
- Increased CI time when running all tools
- Learning curve for team

### Mitigations

- Layer by speed: audit (fast) on every PR, others on schedule
- Import audits from trusted organizations (Mozilla, Embark)
- Make cargo-crev advisory-only (don't block on it)

---

## References

- [cargo-audit](https://crates.io/crates/cargo-audit)
- [cargo-deny](https://embarkstudios.github.io/cargo-deny/)
- [cargo-vet (Mozilla)](https://github.com/mozilla/cargo-vet)
- [RustSec Advisory Database](https://rustsec.org/)
- [Comparing Rust Supply Chain Safety Tools](https://blog.logrocket.com/comparing-rust-supply-chain-safety-tools/)

---

> [!info] Metadata
> **ADR**: `= this.adr.number`
> **Status**: `= this.status`
> **Deciders**: `= this.adr.deciders`
