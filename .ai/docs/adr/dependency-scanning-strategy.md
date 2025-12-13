---
title: Dependency Scanning Strategy
status: approved
date: 2025-12-04
decision-makers: [arustydev]
tags: [security, dependencies, ci-cd, github-actions]
---

# Dependency Scanning Strategy

## Context

This project requires comprehensive dependency vulnerability scanning across multiple ecosystems (npm, Python, Go, Rust, containers). Multiple overlapping tools and workflows were identified that needed consolidation.

## Decision

### Workflow Purpose Clarification

| Workflow                  | Trigger                      | Purpose                        |
|---------------------------|------------------------------|--------------------------------|
| dependency-review.yml     | pull_request                 | Block PRs with vulnerable deps |
| deps-*.yml                | schedule / workflow_dispatch | Report outdated deps           |
| dependabot.yml            | Dependabot                   | Auto-create update PRs         |
| dependabot-auto-merge.yml | pull_request                 | Auto-merge safe updates        |

### Consolidation Decisions

#### 1. dependabot.yml - Single Source (APPROVED)

- **Phase 1.3.1**: Create `dependabot.yml` with multi-ecosystem support
- **Phase 5.3.1**: Extend existing `dependabot.yml` with auto-merge rules (NOT create duplicate)

Rationale: A single `dependabot.yml` file should define all ecosystem configurations. Auto-merge rules can be added as the file matures.

#### 2. Container Dependency Scanning - Missing Task Added (APPROVED)

- **Phase 3.17.5**: Create `deps-container.yml` for Dockerfile base image checks

Rationale: Container base images require separate scanning from application dependencies. Tools like `trivy`, `grype`, or `docker scout` should scan for outdated/vulnerable base images.

#### 3. Rust Security Tools - Keep Both (DECISION PENDING RESEARCH)

- **cargo-audit**: Keep for RustSec vulnerability database scanning
- **cargo-deny**: Keep for license compliance, bans, and advisories

Rationale: These tools have overlapping but distinct purposes. See detailed analysis below.

## Implementation Tasks

### Phase 1: Foundation

- [ ] 1.3.1 Create `dependabot.yml` with multi-ecosystem support
  - npm ecosystem
  - pip ecosystem
  - github-actions ecosystem
  - cargo ecosystem (Rust)
  - gomod ecosystem (Go)
  - docker ecosystem

### Phase 3: Ecosystem-Specific Scanning

- [ ] 3.17.1 Create `deps-npm.yml` for scheduled npm audits
- [ ] 3.17.2 Create `deps-python.yml` for safety/pip-audit checks
- [ ] 3.17.3 Create `deps-go.yml` for govulncheck
- [ ] 3.17.4 Create `deps-rust.yml` for cargo-audit AND cargo-deny
- [ ] 3.17.5 Create `deps-container.yml` for Dockerfile base image checks

### Phase 5: Automation

- [ ] 5.3.1 Extend `dependabot.yml` with auto-merge rules for:
  - Patch version updates (auto-merge after CI passes)
  - Minor version updates (require manual approval)
  - Major version updates (require review + approval)
- [ ] 5.3.2 Create `dependabot-auto-merge.yml` workflow

## Rust Security Tools Deep Analysis

### cargo-audit

**Purpose**: Security vulnerability scanning against RustSec Advisory Database

**Key Characteristics**:
- Built by the Rust Secure Code working group
- Official/canonical RustSec frontend
- Zero-configuration - works out of the box
- **Unique feature**: Experimental auto-fix (`cargo install cargo-audit --features=fix`)
- Fast execution suitable for pre-commit hooks
- JSON output for CI integration

**Installation**:
```bash
cargo install cargo-audit
# With auto-fix support:
cargo install cargo-audit --locked --features=fix
```

**Usage**:
```bash
cargo audit                    # Standard scan
cargo audit --json             # JSON output for CI
cargo audit fix                # Auto-fix (experimental)
```

### cargo-deny

**Purpose**: Comprehensive dependency linting and policy enforcement

**Key Characteristics**:
- Created by Embark Studios
- Uses RustSec database (same as cargo-audit) for vulnerability checks
- Requires `deny.toml` configuration file
- SARIF output for GitHub Security tab integration
- GitHub Action available: `EmbarkStudios/cargo-deny-action`

**Installation**:
```bash
cargo install cargo-deny
cargo deny init  # Generate deny.toml template
```

**deny.toml Example**:
```toml
[advisories]
db-path = "~/.cargo/advisory-db"
vulnerability = "deny"
unmaintained = "warn"

[licenses]
confidence-threshold = 0.93
allow = ["Apache-2.0", "MIT", "BSD-3-Clause", "ISC"]
exceptions = [
    { allow = ["MPL-2.0"], crate = "webpki-roots" },
]

[bans]
multiple-versions = "deny"
wildcards = "deny"
deny = [
    { crate = "openssl-sys", use-instead = "rustls" },
]
skip = [
    { crate = "windows-sys@0.48.0", reason = "transitive dep" },
]

[sources]
unknown-registry = "deny"
unknown-git = "deny"
```

### Feature Comparison Matrix

| Feature                       | cargo-audit | cargo-deny | Notes |
|-------------------------------|:-----------:|:----------:|-------|
| RustSec vulnerability DB      | ✅ (primary) | ✅         | Same database |
| Zero configuration            | ✅          | ❌         | deny.toml required |
| Auto-fix vulnerabilities      | ✅ (experimental) | ❌   | Unique to cargo-audit |
| License compliance            | ❌          | ✅         | Critical for OSS |
| Crate bans/allowlists         | ❌          | ✅         | Policy enforcement |
| Duplicate crate detection     | ❌          | ✅         | Reduce bloat |
| Source verification           | ❌          | ✅         | Registry restrictions |
| SARIF output                  | ❌          | ✅         | GitHub Security tab |
| Custom advisories             | ❌          | ✅         | Internal policies |
| Unmaintained crate warnings   | ❌          | ✅         | Proactive |
| GitHub Action                 | ✅          | ✅         | Both available |

### When to Use Each

| Scenario                          | cargo-audit | cargo-deny |
|-----------------------------------|:-----------:|:----------:|
| Quick CI vulnerability check      | ✅          | ⚪         |
| Pre-commit hook                   | ✅          | ⚪         |
| License compliance (OSS publish)  | ❌          | ✅         |
| Banning problematic crates        | ❌          | ✅         |
| Auto-fixing vulnerabilities       | ✅          | ❌         |
| SARIF → GitHub Security           | ❌          | ✅         |
| Weekly deep policy scan           | ⚪          | ✅         |
| Supply chain policy enforcement   | ❌          | ✅         |

Legend: ✅ = Recommended, ⚪ = Can use but not optimal, ❌ = Not supported

### Alternative Tools Considered

#### cargo-vet (Mozilla)

**Purpose**: Supply chain verification through audits

**Key Characteristics**:
- Tracks whether dependencies have been audited by trusted entities
- Stores audits in `supply-chain/` directory
- Designed for organizational use
- Latest version: 0.10.1

**Relationship to cargo-audit/cargo-deny**: Complementary - focuses on "who reviewed this code" rather than "does this have known vulns"

**Best for**: Organizations requiring audit trails for all dependencies

#### cargo-crev

**Purpose**: Cryptographically-signed code review sharing

**Key Characteristics**:
- Web of trust model for dependency reviews
- Community-based verification
- Creates reviewer identity/fingerprint

**Interoperability**: `crevette` tool exports cargo-crev reviews to cargo-vet format

**Best for**: Open source projects wanting community-validated dependencies

#### Trivy (Aqua Security)

**Purpose**: Multi-ecosystem vulnerability scanner

**Rust Support**:
- Scans `Cargo.lock` files
- Uses RustSec via OSV export
- Can scan binaries built with `cargo-auditable`
- Also scans containers, IaC, etc.

**Trade-offs**:
- Less Rust-specific than cargo-audit
- Good for unified scanning across multiple ecosystems
- Some historical issues with Rust scanning (#5214)

**Best for**: Projects needing single tool for multiple ecosystems

### Recommendation: Defense-in-Depth with All Four Tools

Use **cargo-audit**, **cargo-deny**, **cargo-vet**, and **cargo-crev** as complementary layers:

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
│  │  • Detects CVEs and security advisories                             │   │
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
│  │  • Duplicate detection (reduce attack surface)                      │   │
│  │  Question answered: "Does this meet our POLICIES?"                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  Layer 3: AUDIT TRAIL (Detective)                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  cargo-vet                                                           │   │
│  │  • Tracks who audited each dependency                               │   │
│  │  • Enforces "no unvetted code" policy                               │   │
│  │  • Imports audits from trusted organizations                        │   │
│  │  • Creates institutional memory of reviews                          │   │
│  │  Question answered: "Has this been AUDITED by someone we trust?"    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  Layer 4: COMMUNITY TRUST (Proactive)                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  cargo-crev                                                          │   │
│  │  • Cryptographically signed reviews                                 │   │
│  │  • Web of trust model                                               │   │
│  │  • Community-sourced security assessments                           │   │
│  │  • Cross-project review sharing                                     │   │
│  │  Question answered: "What does the COMMUNITY think of this?"        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Defense-in-Depth: When to Use Each Tool

### By Development Lifecycle Stage

| Stage | Tool | Purpose | Frequency |
|-------|------|---------|-----------|
| **Adding new dependency** | cargo-crev | Check community reviews before adding | On-demand |
| **Adding new dependency** | cargo-vet | Check if already audited by trusted org | On-demand |
| **Pre-commit hook** | cargo-audit | Fast vulnerability check | Every commit |
| **Pull Request** | cargo-audit | Block PRs with known vulns | Every PR |
| **Pull Request** | cargo-deny | Enforce license/ban policies | Every PR |
| **Weekly CI** | cargo-deny | Comprehensive policy scan | Scheduled |
| **Weekly CI** | cargo-vet | Check for unvetted dependencies | Scheduled |
| **Before release** | All four | Full supply chain verification | Release gate |
| **New team member** | cargo-vet | Import their organization's audits | Onboarding |
| **After audit** | cargo-crev | Publish review for community | Post-audit |

### By Security Question

| Question | Primary Tool | Backup Tool |
|----------|-------------|-------------|
| "Is this crate safe to use?" | cargo-crev (reviews) | cargo-audit (vulns) |
| "Does this have known CVEs?" | cargo-audit | cargo-deny [advisories] |
| "Is this license compatible?" | cargo-deny [licenses] | Manual review |
| "Should we ban this crate?" | cargo-deny [bans] | cargo-vet (criteria) |
| "Has anyone reviewed this?" | cargo-vet | cargo-crev |
| "Can I trust this registry?" | cargo-deny [sources] | cargo-vet |
| "Are we using duplicates?" | cargo-deny [bans] | cargo-outdated |

### By Attack Vector Mitigated

| Attack Vector | Tool | How It Helps |
|--------------|------|--------------|
| **Known vulnerability exploitation** | cargo-audit | Detects published CVEs |
| **Typosquatting** | cargo-deny | Ban known typosquats, restrict sources |
| **License violation lawsuit** | cargo-deny | Enforce license allowlist |
| **Malicious maintainer** | cargo-vet + cargo-crev | Require human review of changes |
| **Dependency confusion** | cargo-deny | Restrict to crates.io only |
| **Unmaintained abandonment** | cargo-deny | Warn on unmaintained crates |
| **Supply chain injection** | cargo-vet | Audit trail of all dependencies |
| **Subtle backdoor** | cargo-crev | Community code review |

## Implementation Strategy

### Phase 1: Foundation (Immediate)

```bash
# Install all tools
cargo install cargo-audit --features=fix
cargo install cargo-deny
cargo install cargo-vet
cargo install cargo-crev

# Initialize configurations
cargo deny init          # Creates deny.toml
cargo vet init           # Creates supply-chain/
cargo crev id new        # Creates reviewer identity
```

### Phase 2: CI Integration

**deps-rust.yml** (all four tools):

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
  # Layer 1: Known Vulnerabilities (fast, every PR)
  cargo-audit:
    name: "Layer 1: Vulnerability Scan"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: rustsec/audit-check@v2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

  # Layer 2: Policy Enforcement (every PR)
  cargo-deny:
    name: "Layer 2: Policy Check"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EmbarkStudios/cargo-deny-action@v2
        with:
          command: check
          arguments: --all-features

  # Layer 3: Audit Trail (weekly + dependency changes)
  cargo-vet:
    name: "Layer 3: Audit Verification"
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule' || contains(github.event.head_commit.modified, 'Cargo')
    steps:
      - uses: actions/checkout@v4

      - name: Install cargo-vet
        run: cargo install cargo-vet

      - name: Import trusted audits
        run: |
          cargo vet fetch-imports

      - name: Check audit status
        run: cargo vet --locked

  # Layer 4: Community Trust (informational, weekly)
  cargo-crev:
    name: "Layer 4: Community Reviews"
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule'
    continue-on-error: true  # Advisory, not blocking
    steps:
      - uses: actions/checkout@v4

      - name: Install cargo-crev
        run: cargo install cargo-crev

      - name: Fetch reviews
        run: cargo crev repo fetch all

      - name: Generate trust report
        run: |
          cargo crev crate verify --recursive 2>&1 | tee crev-report.txt

      - name: Upload report
        uses: actions/upload-artifact@v4
        with:
          name: crev-trust-report
          path: crev-report.txt
```

### Phase 3: Configuration Files

**deny.toml** (cargo-deny):
```toml
[graph]
targets = []
all-features = true

[advisories]
db-path = "~/.cargo/advisory-db"
vulnerability = "deny"
unmaintained = "warn"
yanked = "deny"
notice = "warn"

[licenses]
confidence-threshold = 0.93
allow = [
    "MIT",
    "Apache-2.0",
    "BSD-2-Clause",
    "BSD-3-Clause",
    "ISC",
    "Zlib",
    "CC0-1.0",
    "Unlicense",
]
exceptions = [
    { allow = ["MPL-2.0"], crate = "webpki-roots" },
    { allow = ["Unicode-DFS-2016"], crate = "unicode-ident" },
]

[licenses.private]
ignore = true

[bans]
multiple-versions = "warn"
wildcards = "deny"
highlight = "all"
deny = [
    { crate = "openssl-sys", use-instead = "rustls" },
    { crate = "openssl", use-instead = "rustls" },
]
skip = []
skip-tree = []

[sources]
unknown-registry = "deny"
unknown-git = "deny"
allow-registry = ["https://github.com/rust-lang/crates.io-index"]
```

**supply-chain/config.toml** (cargo-vet):
```toml
[cargo-vet]
version = "0.10"

[imports.mozilla]
url = "https://raw.githubusercontent.com/AliRn-dev/AliRn-dev/main/AliRn-dev"

[imports.embark]
url = "https://raw.githubusercontent.com/AliRn-dev/AliRn-dev/main/AliRn-dev"

[imports.bytecode-alliance]
url = "https://raw.githubusercontent.com/AliRn-dev/AliRn-dev/main/AliRn-dev"

[policy.example-crate]
audit-as-crates-io = true

# Custom criteria beyond the defaults
[criteria.crypto-reviewed]
description = "Cryptographic code has been reviewed for correctness"
implies = ["safe-to-deploy"]
```

### Phase 4: Pre-commit Hook

**.pre-commit-config.yaml**:
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

### Phase 5: Developer Workflow

```bash
# Before adding a new dependency
cargo crev crate search <crate-name>      # Check community reviews
cargo vet suggest                          # See if already audited

# After reviewing a crate
cargo crev crate review <crate-name>       # Publish your review
cargo vet certify <crate-name> <version>   # Record your audit

# Regular maintenance
cargo audit                                # Quick vuln check
cargo deny check                           # Full policy check
cargo vet                                  # Verify all audited
cargo crev repo publish                    # Share your reviews
```

## Tool Comparison Summary

| Dimension | cargo-audit | cargo-deny | cargo-vet | cargo-crev |
|-----------|:-----------:|:----------:|:---------:|:----------:|
| **Focus** | Known vulns | Policies | Audit trail | Community trust |
| **Data source** | RustSec DB | Config file | Org audits | Web of trust |
| **Configuration** | None | deny.toml | supply-chain/ | ~/.config/crev |
| **Speed** | Fast (<5s) | Medium (~30s) | Medium (~30s) | Slow (network) |
| **Blocks PRs** | Yes | Yes | Optional | No (advisory) |
| **Maintenance** | Low | Medium | Medium | High |
| **Best for** | All projects | All projects | Organizations | OSS maintainers |

## Consequences

### Positive

- Four layers of defense covering different attack vectors
- Known vulnerabilities caught immediately (cargo-audit)
- Policy violations prevented (cargo-deny)
- Audit trail for compliance (cargo-vet)
- Community intelligence leveraged (cargo-crev)
- Progressive adoption possible (start with audit, add layers)

### Negative

- Four tools to maintain and update
- Multiple configuration files (deny.toml, supply-chain/, crev config)
- Increased CI time when running all tools
- Learning curve for team members
- cargo-crev requires ongoing community engagement

### Mitigations

- Layer by speed: audit (fast) on every PR, others on schedule
- Share configurations via templates
- Import audits from trusted organizations (Mozilla, Embark)
- Make cargo-crev advisory-only (don't block on it)
- Document team workflow for adding dependencies

## References

- [Comparing Rust Supply Chain Safety Tools - LogRocket](https://blog.logrocket.com/comparing-rust-supply-chain-safety-tools/)
- [Rust Auditing Tools in 2025](https://markaicode.com/rust-auditing-tools-2025-automated-security-scanning/)
- [cargo-audit crates.io](https://crates.io/crates/cargo-audit)
- [cargo-deny documentation](https://embarkstudios.github.io/cargo-deny/)
- [cargo-deny GitHub Action](https://github.com/EmbarkStudios/cargo-deny-action)
- [cargo-vet (Mozilla)](https://github.com/mozilla/cargo-vet)
- [RustSec Advisory Database](https://rustsec.org/)
- [Trivy Rust Support](https://trivy.dev/v0.62/docs/coverage/language/rust/)
- [Dependabot documentation](https://docs.github.com/en/code-security/dependabot)
- [GitHub Dependency Review](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/about-dependency-review)
