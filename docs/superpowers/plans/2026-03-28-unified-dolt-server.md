# Unified Dolt Server Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace bd's unstable random-port dolt auto-start with a persistent launchd-managed server on a fixed port, managed through a generic daemon module.

**Architecture:** A new `daemon/` justfile module provides generic launchd lifecycle management (load/unload/status/doctor). The existing `services/databases/dolt/` module generates a launchd plist and registers with daemon. bd's config is updated to connect to the fixed port.

**Tech Stack:** just (justfiles), launchd (macOS service manager), dolt (SQL database), bash

**Spec:** `docs/superpowers/specs/2026-03-28-unified-dolt-server-design.md`

---

## File Structure

### New files
| File | Responsibility |
|------|---------------|
| `daemon/justfile` | Generic launchd service lifecycle recipes (load, unload, status, doctor, etc.) |
| `daemon/data.yml` | Module config for daemon |
| `daemon/services/.gitkeep` | Placeholder for service plist templates |
| `services/databases/dolt/dolt.plist.template` | Launchd plist template for dolt server |

### Modified files
| File | Change |
|------|--------|
| `justfile` (root) | Register `mod daemon` |
| `.claude/CLAUDE.md` | Add daemon to module tree |
| `services/databases/dolt/justfile` | Update port, add launchd recipe, remove serve-bg/stop |
| `services/databases/dolt/data.yml` | Update databases_dir |
| `tools/agents/beads/config.yaml` | Update dolt port to 13306 |

### Deleted files
| File | Reason |
|------|--------|
| `daemon/dolt-state.json` | Stale runtime artifact |
| `daemon/dolt.pid` | Stale runtime artifact |
| `daemon/dolt.lock` | Stale runtime artifact |
| `daemon/dolt.log` | Stale runtime artifact |

---

## Task 1: Clean up stale daemon state

**Files:**
- Delete: `daemon/dolt-state.json`
- Delete: `daemon/dolt.pid`
- Delete: `daemon/dolt.lock`
- Delete: `daemon/dolt.log`

- [ ] **Step 1: Remove stale runtime files from repo**

```bash
cd /private/etc/dotfiles/adam
rm daemon/dolt-state.json daemon/dolt.pid daemon/dolt.lock daemon/dolt.log
```

- [ ] **Step 2: Commit**

```bash
git add daemon/dolt-state.json daemon/dolt.pid daemon/dolt.lock daemon/dolt.log
git commit -m "chore(daemon): Remove stale dolt runtime artifacts"
```

---

## Task 2: Create daemon module scaffolding

**Files:**
- Create: `daemon/data.yml`
- Create: `daemon/services/.gitkeep`
- Modify: `daemon/justfile` (replace stub)

- [ ] **Step 1: Create data.yml**

```yaml
# daemon/data.yml
dotdir: "${XDG_STATE_HOME}/daemon"
```

- [ ] **Step 2: Create services directory**

```bash
mkdir -p /private/etc/dotfiles/adam/daemon/services
touch /private/etc/dotfiles/adam/daemon/services/.gitkeep
```

- [ ] **Step 3: Write daemon/justfile with mktree and list recipes**

Start with the foundation — directory setup and service discovery. Other recipes build on this.

```just
# daemon/justfile
set shell := ["bash", "-euo", "pipefail", "-c"]

import '../.build/just/lib.just'

launch_agents := env("HOME") + "/Library/LaunchAgents"
state_dir := env("XDG_STATE_HOME", env("HOME") / ".local/state") / "daemon"
plist_prefix := "dev.arusty."

# Create state directories
mktree:
    mkdir -p "{{ state_dir }}"

# List registered services (discovered by plist glob)
list:
    #!/usr/bin/env bash
    echo "Registered services:"
    for plist in "{{ launch_agents }}/{{ plist_prefix }}"*.plist; do
        [[ -f "$plist" ]] || { echo "  (none)"; exit 0; }
        name=$(basename "$plist" .plist | sed "s/^{{ plist_prefix }}//")
        echo "  $name"
    done
```

- [ ] **Step 4: Verify justfile parses**

```bash
cd /private/etc/dotfiles/adam && just -f daemon/justfile --list
```

Expected: shows `mktree` and `list` recipes.

- [ ] **Step 5: Commit**

```bash
git add daemon/data.yml daemon/services/.gitkeep daemon/justfile
git commit -m "feat(daemon): Add module scaffolding with mktree and list"
```

---

## Task 3: Add daemon load/unload/restart recipes

**Files:**
- Modify: `daemon/justfile`

- [ ] **Step 1: Add load recipe**

Append to `daemon/justfile`:

```just
# Load a service via launchctl
load name:
    #!/usr/bin/env bash
    plist="{{ launch_agents }}/{{ plist_prefix }}{{ name }}.plist"
    if [[ ! -f "$plist" ]]; then
        echo "✗ No plist found: $plist"
        exit 1
    fi
    launchctl load "$plist"
    echo "✓ Loaded {{ name }}"
```

- [ ] **Step 2: Add unload recipe**

```just
# Unload a service via launchctl
unload name:
    #!/usr/bin/env bash
    plist="{{ launch_agents }}/{{ plist_prefix }}{{ name }}.plist"
    if [[ ! -f "$plist" ]]; then
        echo "✗ No plist found: $plist"
        exit 1
    fi
    launchctl unload "$plist" 2>/dev/null || true
    echo "✓ Unloaded {{ name }}"
```

- [ ] **Step 3: Add restart and remove recipes**

```just
# Restart a service (unload + load)
restart name:
    #!/usr/bin/env bash
    "{{ just_executable() }}" -f "{{ justfile() }}" unload "{{ name }}"
    sleep 1
    "{{ just_executable() }}" -f "{{ justfile() }}" load "{{ name }}"

# Remove a service (unload + delete plist + clean state)
remove name:
    #!/usr/bin/env bash
    "{{ just_executable() }}" -f "{{ justfile() }}" unload "{{ name }}"
    plist="{{ launch_agents }}/{{ plist_prefix }}{{ name }}.plist"
    rm -f "$plist"
    rm -rf "{{ state_dir }}/{{ name }}"
    echo "✓ Removed {{ name }}"
```

- [ ] **Step 4: Verify all recipes parse**

```bash
just -f daemon/justfile --list
```

Expected: shows `mktree`, `list`, `load`, `unload`, `restart`, `remove`.

- [ ] **Step 5: Commit**

```bash
git add daemon/justfile
git commit -m "feat(daemon): Add load, unload, restart, remove recipes"
```

---

## Task 4: Add daemon status and logs recipes

**Files:**
- Modify: `daemon/justfile`

- [ ] **Step 1: Add status recipe**

```just
# Show status of one or all services
status name="":
    #!/usr/bin/env bash
    check_service() {
        local svc="$1"
        local label="{{ plist_prefix }}$svc"
        local svc_state="{{ state_dir }}/$svc"

        if launchctl list "$label" &>/dev/null; then
            pid=$(launchctl list "$label" 2>/dev/null | awk 'NR==2{print $1}')
            echo "✓ $svc: running (PID: $pid)"
        else
            echo "✗ $svc: not running"
        fi
    }

    if [[ -n "{{ name }}" ]]; then
        check_service "{{ name }}"
    else
        for plist in "{{ launch_agents }}/{{ plist_prefix }}"*.plist; do
            [[ -f "$plist" ]] || { echo "No services registered."; exit 0; }
            svc=$(basename "$plist" .plist | sed "s/^{{ plist_prefix }}//")
            check_service "$svc"
        done
    fi
```

- [ ] **Step 2: Add logs recipe**

```just
# Tail logs for a service
logs name:
    #!/usr/bin/env bash
    log_dir="{{ state_dir }}/{{ name }}"
    if [[ -f "$log_dir/{{ name }}.log" ]]; then
        tail -f "$log_dir/{{ name }}.log"
    elif [[ -f "$log_dir/{{ name }}-error.log" ]]; then
        tail -f "$log_dir/{{ name }}-error.log"
    else
        echo "No logs found in $log_dir"
        exit 1
    fi
```

- [ ] **Step 3: Commit**

```bash
git add daemon/justfile
git commit -m "feat(daemon): Add status and logs recipes"
```

---

## Task 5: Add daemon doctor recipe

**Files:**
- Modify: `daemon/justfile`

- [ ] **Step 1: Add doctor recipe**

```just
# Health check all services; pass "fix" to kill orphans and clean stale state
doctor action="check":
    #!/usr/bin/env bash
    issues=0

    echo "=== Daemon Health Check ==="
    echo ""

    # Check each registered service
    for plist in "{{ launch_agents }}/{{ plist_prefix }}"*.plist; do
        [[ -f "$plist" ]] || { echo "No services registered."; exit 0; }
        svc=$(basename "$plist" .plist | sed "s/^{{ plist_prefix }}//")
        label="{{ plist_prefix }}$svc"

        if launchctl list "$label" &>/dev/null; then
            echo "✓ $svc: loaded"
        else
            echo "✗ $svc: plist exists but not loaded"
            issues=$((issues + 1))
            if [[ "{{ action }}" == "fix" ]]; then
                echo "  → Loading $svc..."
                launchctl load "$plist"
            fi
        fi
    done

    echo ""

    # Check for orphaned dolt processes (not managed by any plist)
    orphans=$(pgrep -f 'dolt sql-server' 2>/dev/null || true)
    if [[ -n "$orphans" ]]; then
        managed_pid=""
        if launchctl list "{{ plist_prefix }}dolt" &>/dev/null; then
            managed_pid=$(launchctl list "{{ plist_prefix }}dolt" 2>/dev/null | awk 'NR==2{print $1}')
        fi

        while IFS= read -r pid; do
            if [[ "$pid" != "$managed_pid" ]]; then
                port=$(lsof -nP -iTCP -sTCP:LISTEN -p "$pid" 2>/dev/null | awk 'NR==2{split($9,a,":"); print a[2]}')
                echo "✗ Orphaned dolt process: PID $pid (port: ${port:-unknown})"
                issues=$((issues + 1))
                if [[ "{{ action }}" == "fix" ]]; then
                    echo "  → Killing PID $pid..."
                    kill "$pid" 2>/dev/null || true
                fi
            fi
        done <<< "$orphans"
    fi

    if [[ $issues -eq 0 ]]; then
        echo "✓ All services healthy"
    else
        echo ""
        echo "$issues issue(s) found."
        if [[ "{{ action }}" != "fix" ]]; then
            echo "Run 'just daemon doctor fix' to auto-repair."
        fi
    fi
```

- [ ] **Step 2: Verify doctor recipe parses**

```bash
just -f daemon/justfile --list
```

Expected: shows all recipes including `doctor`.

- [ ] **Step 3: Commit**

```bash
git add daemon/justfile
git commit -m "feat(daemon): Add doctor recipe with orphan detection"
```

---

## Task 6: Register daemon module in root justfile

**Files:**
- Modify: `justfile` (root)
- Modify: `.claude/CLAUDE.md`

- [ ] **Step 1: Add mod declaration to root justfile**

Add after the `mod op` line (in the Core section):

```just
# Daemon service manager (launchd)
mod daemon 'daemon/justfile'
```

- [ ] **Step 2: Update the install recipe's names and paths arrays**

Add `daemon` to the `names` array and `daemon` to the `paths` array at the corresponding position (after `op`).

- [ ] **Step 3: Update the list recipe**

Add `daemon` to the Core line:
```
@echo "  Core:    git, ssh, op, daemon"
```

- [ ] **Step 4: Update .claude/CLAUDE.md module tree**

Add `daemon` to the Core section:
```
git          # Git version control with 1Password signing
ssh          # SSH client configuration
op           # 1Password CLI
daemon       # launchd service manager
```

- [ ] **Step 5: Verify module loads**

```bash
just --list
```

Expected: `daemon ...` appears in the module list.

- [ ] **Step 6: Commit**

```bash
git add justfile .claude/CLAUDE.md
git commit -m "feat(justfile): Register daemon module in root"
```

---

## Task 7: Create dolt plist template

**Files:**
- Create: `services/databases/dolt/dolt.plist.template`

- [ ] **Step 1: Write plist template**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>dev.arusty.dolt</string>

    <key>ProgramArguments</key>
    <array>
        <string>${HOMEBREW_PREFIX}/bin/dolt</string>
        <string>sql-server</string>
        <string>--host</string>
        <string>${DOLT_HOST}</string>
        <string>--port</string>
        <string>${DOLT_PORT}</string>
        <string>--data-dir</string>
        <string>${DOLT_DATA_DIR}</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>

    <key>WorkingDirectory</key>
    <string>${DOLT_DATA_DIR}</string>

    <key>StandardOutPath</key>
    <string>${DOLT_LOG_DIR}/dolt.log</string>

    <key>StandardErrorPath</key>
    <string>${DOLT_LOG_DIR}/dolt-error.log</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>${HOMEBREW_PREFIX}/bin:/usr/local/bin:/usr/bin:/bin</string>
    </dict>

    <key>ProcessType</key>
    <string>Background</string>
</dict>
</plist>
```

- [ ] **Step 2: Commit**

```bash
git add services/databases/dolt/dolt.plist.template
git commit -m "feat(dolt): Add launchd plist template"
```

---

## Task 8: Update dolt justfile for daemon integration

**Files:**
- Modify: `services/databases/dolt/justfile`
- Modify: `services/databases/dolt/data.yml`

- [ ] **Step 1: Update data.yml**

Replace contents with:

```yaml
dotdir: "${HOME}/.dolt"
databases_dir: "${HOME}/.local/share/dolt/databases"
```

- [ ] **Step 2: Update dolt justfile variables and port**

At the top of `services/databases/dolt/justfile`, change:

```just
# Dolt directories
dolt_home := env_var("HOME") / ".dolt"
databases_dir := env_var("HOME") / ".local/share/dolt/databases"

# Server settings
default_port := "13306"
default_host := "127.0.0.1"

# Daemon integration
launch_agents := env_var("HOME") / "Library/LaunchAgents"
state_dir := env("XDG_STATE_HOME", env("HOME") / ".local/state") / "daemon/dolt"
brew_prefix := `brew --prefix`
```

- [ ] **Step 3: Add launchd recipe**

Add to the dolt justfile:

```just
# Generate and install launchd plist
launchd: mktree
    #!/usr/bin/env bash
    mkdir -p "{{ state_dir }}"
    export HOMEBREW_PREFIX="{{ brew_prefix }}"
    export DOLT_HOST="{{ default_host }}"
    export DOLT_PORT="{{ default_port }}"
    export DOLT_DATA_DIR="{{ databases_dir }}"
    export DOLT_LOG_DIR="{{ state_dir }}"
    envsubst < "{{ justfile_directory() }}/dolt.plist.template" \
        > "{{ launch_agents }}/dev.arusty.dolt.plist"
    echo "✓ Plist installed to {{ launch_agents }}/dev.arusty.dolt.plist"
```

- [ ] **Step 4: Update install recipe**

Change the install recipe to:

```just
# Install dolt with launchd service
install: dependencies config mktree launchd
    #!/usr/bin/env bash
    echo "Loading dolt service..."
    "{{ just_executable() }}" -f "{{ justfile_directory() }}/../../../daemon/justfile" load dolt
    sleep 2
    # Verify health
    if mysql -h "{{ default_host }}" -P "{{ default_port }}" -u root -e "SELECT 1" &>/dev/null; then
        echo "✓ Dolt server running on {{ default_host }}:{{ default_port }}"
    else
        echo "⚠ Dolt server loaded but not yet responding (check logs with: just daemon logs dolt)"
    fi
    echo "✓ Dolt installed."
```

- [ ] **Step 5: Replace serve-bg and stop with daemon wrappers**

Replace the existing `serve-bg` and `stop` recipes:

```just
# Start dolt server (via daemon)
start:
    "{{ just_executable() }}" -f "{{ justfile_directory() }}/../../../daemon/justfile" load dolt

# Stop dolt server (via daemon)
stop:
    "{{ just_executable() }}" -f "{{ justfile_directory() }}/../../../daemon/justfile" unload dolt
```

Remove the old `serve-bg` recipe body entirely. Keep `serve` (foreground) and `serve-pg` for manual use.

- [ ] **Step 6: Verify justfile parses**

```bash
just --list db::dolt
```

Expected: shows updated recipes including `launchd`, `start`, `stop`.

- [ ] **Step 7: Commit**

```bash
git add services/databases/dolt/justfile services/databases/dolt/data.yml
git commit -m "feat(dolt): Integrate with daemon module, pin port 13306"
```

---

## Task 9: Update beads config

**Files:**
- Modify: `tools/agents/beads/config.yaml`

- [ ] **Step 1: Update dolt port in beads config**

Change the `dolt:` block from:

```yaml
dolt:
  mode: server
  host: 127.0.0.1
  port: 3307
  user: root
```

to:

```yaml
dolt:
  mode: server
  host: 127.0.0.1
  port: 13306
  user: root
```

- [ ] **Step 2: Commit**

```bash
git add tools/agents/beads/config.yaml
git commit -m "fix(beads): Pin dolt port to 13306 (daemon-managed server)"
```

---

## Task 10: Smoke test end-to-end

This task verifies the full setup works. No files are modified.

- [ ] **Step 1: Kill any existing dolt processes**

```bash
pkill -f 'dolt sql-server' 2>/dev/null || true
```

- [ ] **Step 2: Run dolt install**

```bash
just db dolt install
```

Expected: installs dolt, generates plist, loads via launchd, verifies health.

- [ ] **Step 3: Verify daemon status**

```bash
just daemon status dolt
```

Expected: `✓ dolt: running (PID: <number>)`

- [ ] **Step 4: Verify bd can connect**

```bash
bd list 2>&1 | head -5
```

Expected: bd connects to 13306, no port-change warnings.

- [ ] **Step 5: Run daemon doctor**

```bash
just daemon doctor
```

Expected: `✓ All services healthy`

- [ ] **Step 6: Verify persistence across restart**

```bash
just daemon restart dolt
sleep 3
just daemon status dolt
bd list 2>&1 | head -5
```

Expected: dolt restarts cleanly, bd reconnects without issues.

- [ ] **Step 7: Push all commits**

```bash
git push
```
