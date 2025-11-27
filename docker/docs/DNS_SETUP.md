# DNS Setup for Docker/Traefik

Simple DNS recipes that **extend** (not replace) your volta unbound setup.

## Architecture

```
Volta Setup (you manage separately):
  volta/justfile → generates unbound.conf with nodejs.org, etc.

Docker Setup (extends volta):
  docker/justfile → adds localhost, test, etc. to same config
```

## Recipes (4 total)

```bash
just dns-add <tld> [ip]    # Add a zone (default: 127.0.0.1)
just dns-remove <tld>      # Remove a zone
just dns-init              # Add all docker_zones
just dns-clean             # Remove all docker_zones
```

## Usage

### First Time Setup

```bash
# 1. Initialize volta (if not already)
cd /Users/arustydev/repos/configs/dotfiles/volta
just init

# 2. Add docker zones
cd /Users/arustydev/repos/configs/dotfiles/docker
just dns-init
```

This adds to volta's config:
```
local-zone: "localhost" static
local-data: "localhost A 127.0.0.1"

local-zone: "test" static
local-data: "test A 127.0.0.1"

local-zone: "local" static
local-data: "local A 127.0.0.1"

local-zone: "dev" static
local-data: "dev A 127.0.0.1"
```

### Add Custom TLD

```bash
# Add example.tld → 127.0.0.1
just dns-add example.tld

# Add custom IP
just dns-add internal.corp 192.168.1.100
```

### Remove TLD

```bash
just dns-remove example.tld
```

### Clean Up

```bash
# Remove only docker zones (volta zones remain)
just dns-clean
```

## How It Works

**Does NOT:**
- ❌ Regenerate unbound config
- ❌ Touch volta's zones
- ❌ Use templates

**Does:**
- ✅ Appends zones to existing config
- ✅ Removes only its own zones
- ✅ Simple sed/awk operations
- ✅ Coexists with volta

## Testing

```bash
# These should work:
dig +short api.localhost        # 127.0.0.1
dig +short anything.test        # 127.0.0.1

# Volta zones still work:
dig +short nodejs.org @127.0.0.2   # volta's IPs
```

## Configuration

Change default zones in `docker/justfile`:
```just
docker_zones := "localhost test myapp mycompany"
```

## Clean Separation

```
Unbound Config Ownership:
┌────────────────────────────────┐
│ server:                        │ ← Volta owns
│   do-ip6: no                   │ ← Volta owns
│   ...                          │ ← Volta owns
│                                │
│ local-zone: "nodejs.org" ...   │ ← Volta owns
│ local-zone: "yarnpkg.com" ...  │ ← Volta owns
│                                │
│ local-zone: "localhost" ...    │ ← Docker adds
│ local-zone: "test" ...         │ ← Docker adds
│                                │
│ forward-zone: ...              │ ← Volta owns
└────────────────────────────────┘
```

Docker only adds/removes `local-zone` and `local-data` lines for its TLDs.
