---
number: 6
title: Secret Management with 1Password
date: 2026-02-25
status: proposed
tags:
  - secrets
  - 1password
  - security
---

# 6. Secret Management with 1Password

Date: 2026-02-25

## Status

Proposed

## Context

Configuration files often require secrets (API keys, passwords, tokens). These secrets must be:

- Never committed to git
- Easily rotatable
- Accessible during configuration generation
- Consistent across development environments

The repository uses 1Password CLI (`op`) for secret management, but patterns vary across modules.

## Decision

### 1. Secret Reference Format

All secrets are referenced using 1Password URI format:

```
op://vault/item/field
```

Examples:
```
op://Developer/meilisearch/credential
op://Infrastructure/github/api-token
op://Personal/ssh/private-key
```

### 2. Secret Injection

Secrets are injected at runtime using `op inject`, never committed:

```bash
# In justfile template recipe
op inject -i config.toml -o generated.toml
```

The input file contains `op://` references; the output file contains actual secrets.

### 3. Vault Organization

Standard vault names for organization:

| Vault | Purpose |
|-------|---------|
| `Developer` | Development tools, local services |
| `Infrastructure` | Cloud services, CI/CD, deployment |
| `Personal` | Personal accounts, SSH keys |
| `Shared` | Team-shared credentials |

### 4. Item Naming

1Password items should be named to match the module/service:

```
op://Developer/meilisearch/...
op://Developer/docker-registry/...
op://Infrastructure/aws/...
```

### 5. Field Naming

Common field names for consistency:

| Field | Purpose |
|-------|---------|
| `credential` | Primary secret (password, API key) |
| `api-key` | API key specifically |
| `api-token` | API token specifically |
| `username` | Username for authentication |
| `password` | Password for authentication |
| `private-key` | SSH or other private key |
| `certificate` | TLS/SSL certificate |

### 6. Generated Files

Files containing injected secrets:
- Use `generated.*` naming (per ADR-004)
- Must be gitignored
- Should have restricted permissions (`chmod 600`)

### 7. Authentication

Users must authenticate with 1Password before running recipes that require secrets:

```bash
# Interactive sign-in
op signin

# Or use biometrics/system auth if configured
eval $(op signin)
```

Recipes should fail clearly if `op` is not authenticated.

## Consequences

### Easier

- Secrets never committed to git
- Single source of truth for credentials
- Easy secret rotation (update in 1Password, re-run template)
- Audit trail in 1Password

### More Difficult

- Requires 1Password CLI and account
- Must authenticate before running certain recipes
- Offline access to secrets not possible

## Anti-patterns

1. **Hardcoded secrets in tracked files**
   ```toml
   # Bad: secret in tracked file
   api_key = "sk-1234567890abcdef"

   # Good: 1Password reference
   api_key = "op://Developer/myservice/api-key"
   ```

2. **Committing generated files**
   ```bash
   # Bad: generated file with secrets committed
   git add generated.toml

   # Good: gitignore prevents this
   # .gitignore contains: generated.*
   ```

3. **Inconsistent vault/item naming**
   ```
   # Bad: inconsistent naming
   op://dev/meili/key
   op://Developer/MeiliSearch/API_KEY
   op://developer/meilisearch-prod/credential

   # Good: consistent naming
   op://Developer/meilisearch/credential
   ```

4. **Secrets in environment variables in tracked files**
   ```bash
   # Bad: .env file with secrets tracked
   API_KEY=sk-1234567890

   # Good: .env references 1Password
   API_KEY=op://Developer/myservice/api-key
   # Then: op inject -i .env -o .env.local
   ```

## Integration with Templating Pipeline

This ADR works with ADR-004 (Configuration Templating Pipeline):

```bash
# Full pipeline with secret injection
mustache data.yml config.toml | envsubst | op inject > generated.toml
```

The `op inject` stage is the final step, ensuring secrets are only present in the gitignored output file.
