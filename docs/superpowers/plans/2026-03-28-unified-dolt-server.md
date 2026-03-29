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
| `daemon/services/.gitkeep` | Placeholder for service plist templates (tracked; runtime artifacts go elsewhere) |
| `services/databases/dolt/dolt.plist.template` | Launchd plist template for dolt server |

### Modified files
| File | Change |
|------|--------|
| `justfile` (root) | Register `mod daemon` |
| `.claude/CLAUDE.md` | Add daemon to module tree |
| `services/databases/dolt/justfile` | Update port, add launchd recipe, remove serve-bg |
| `services/databases/dolt/data.yml` | Update databases_dir |
| `tools/agents/beads/config.yaml` | Update dolt port from 3307 to 13306 |

### Cleanup (untracked local files, not in git)
| File | Reason |
|------|--------|
| `daemon/dolt-state.json` | Stale runtime artifact (untracked) |
| `daemon/dolt.pid` | Stale runtime artifact (untracked) |
| `daemon/dolt.lock` | Stale runtime artifact (untracked) |
| `daemon/dolt.log` | Stale runtime artifact (untracked) |

---

## Task 1: Clean up stale daemon state and create scaffolding

These files are untracked (gitignored), so cleanup is a local-only operation combined with the first real commit.

**Files:**
- Delete (local only): `daemon/dolt-state.json`, `daemon/dolt.pid`, `daemon/dolt.lock`, `daemon/dolt.log`
- Create: `daemon/data.yml`
- Create: `daemon/services/.gitkeep`
- Modify: `daemon/justfile` (replace stub)

- [ ] **Step 1: Remove stale runtime files from disk**

```bash
cd /private/etc/dotfiles/adam
rm -f daemon/dolt-state.json daemon/dolt.pid daemon/dolt.lock daemon/dolt.log
```

No commit needed — these files are not tracked by git.

- [ ] **Step 2: Create data.yml**

```yaml
# daemon/data.yml
dotdir: "{{xdg_state}}/daemon"
```

Note: uses `{{xdg_state}}` template syntax to match existing `data.yml` conventions in the repo.

- [ ] **Step 3: Create services directory**

```bash
mkdir -p /private/etc/dotfiles/adam/daemon/services
touch /private/etc/dotfiles/adam/daemon/services/.gitkeep
```

- [ ] **Step 4: Write daemon/justfile with mktree and list recipes**

Replace the entire stub justfile with:

```just
set shell := ["bash", "-euo", "pipefail", "-c"]

import '../.build/just/lib.just'

launch_agents := env("HOME") + "/Library/LaunchAgents"
state_dir := env("XDG_STATE_HOME", env("HOME") / ".local/state") / "daemon"
plist_prefix := "dev.arusty."

# Create state directories and ensure LaunchAgents dir exists
mktree:
    mkdir -p "{{ state_dir }}"
    mkdir -p "{{ launch_agents }}"

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

- [ ] **Step 5: Verify justfile parses**

```bash
cd /private/etc/dotfiles/adam && just -f daemon/justfile --list
```

Expected: shows `mktree` and `list` recipes (plus lib.just inherited recipes).

- [ ] **Step 6: Commit**

```bash
git add daemon/data.yml daemon/services/.gitkeep daemon/justfile
git commit -m "feat(daemon): Add module scaffolding with mktree and list"
```

---

## Task 2: Add daemon load/unload/restart recipes

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

Expected: shows recipes including `mktree`, `list`, `load`, `unload`, `restart`, `remove`.

- [ ] **Step 5: Commit**

```bash
git add daemon/justfile
git commit -m "feat(daemon): Add load, unload, restart, remove recipes"
```

---

## Task 3: Add daemon status and logs recipes

**Files:**
- Modify: `daemon/justfile`

- [ ] **Step 1: Add status recipe**

Append to `daemon/justfile`:

```just
# Show status of one or all services
status name="":
    #!/usr/bin/env bash
    check_service() {
        local svc="$1"
        local label="{{ plist_prefix }}$svc"

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

## Task 4: Add daemon doctor recipe

**Files:**
- Modify: `daemon/justfile`

- [ ] **Step 1: Add doctor recipe**

Append to `daemon/justfile`:

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
    # TODO: Make orphan detection generic (driven by config per service) when more services are added
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

## Task 5: Register daemon module in root justfile

**Files:**
- Modify: `justfile` (root)
- Modify: `.claude/CLAUDE.md`

- [ ] **Step 1: Add mod declaration to root justfile**

Add after the `mod op 'core/op/justfile'` line (in the Core section):

```just
# Daemon service manager (launchd)
mod daemon 'daemon/justfile'
```

- [ ] **Step 2: Update the install recipe's names and paths arrays**

Change the arrays from:
```bash
names=(git ssh op shell term editor db svc infra os vpn wm browser ver tool)
paths=(core/git core/ssh core/op shells terminals editors services/databases services tools/infra os vpn window-mgr browsers tools/ver-mgr tools)
```

to:
```bash
names=(git ssh op daemon shell term editor db svc infra os vpn wm browser ver tool)
paths=(core/git core/ssh core/op daemon shells terminals editors services/databases services tools/infra os vpn window-mgr browsers tools/ver-mgr tools)
```

- [ ] **Step 3: Update the list recipe**

Change the Core line to:
```just
    @echo "  Core:    git, ssh, op, daemon"
```

- [ ] **Step 4: Update .claude/CLAUDE.md module tree**

In the Core section, add `daemon`:
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

Expected: `daemon ...` appears in the module list among other groups.

- [ ] **Step 6: Commit**

```bash
git add justfile .claude/CLAUDE.md
git commit -m "feat(justfile): Register daemon module in root"
```

---

## Task 6: Create dolt plist template

**Files:**
- Create: `services/databases/dolt/dolt.plist.template`

- [ ] **Step 1: Write plist template**

The template uses `${VAR}` envsubst variables that resolve to absolute paths at hydration time. Tildes and `$HOME` must not appear in the generated plist — launchd does not expand them.

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

## Task 7: Update dolt justfile for daemon integration

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

Replace the existing variable block at the top of `services/databases/dolt/justfile`. The existing block is:

```just
# Dolt directories
dolt_home := env_var("HOME") / ".dolt"
databases_dir := env_var("HOME") / ".local/share/dolt/databases"

# Default server settings
default_port := "3306"
default_host := "127.0.0.1"
```

Replace with:

```just
# Dolt directories
dolt_home := env_var("HOME") / ".dolt"
databases_dir := env_var("HOME") / ".local/share/dolt/databases"

# Server settings (port 13306 avoids MySQL 3306 and legacy dolt 3307 conflicts)
default_port := "13306"
default_host := "127.0.0.1"

# Daemon integration
launch_agents := env_var("HOME") / "Library/LaunchAgents"
dolt_state := env("XDG_STATE_HOME", env("HOME") / ".local/state") / "daemon/dolt"
brew_prefix := `brew --prefix`
```

Note: `dolt_home`, `databases_dir`, and `default_host` are unchanged. `default_port` changes from `"3306"` to `"13306"`. Three new variables are added for daemon integration.

- [ ] **Step 3: Add launchd recipe**

Add after the `mktree` recipe:

```just
# Generate and install launchd plist
launchd: mktree
    #!/usr/bin/env bash
    mkdir -p "{{ dolt_state }}"
    mkdir -p "{{ launch_agents }}"
    export HOMEBREW_PREFIX="{{ brew_prefix }}"
    export DOLT_HOST="{{ default_host }}"
    export DOLT_PORT="{{ default_port }}"
    export DOLT_DATA_DIR="{{ databases_dir }}"
    export DOLT_LOG_DIR="{{ dolt_state }}"
    envsubst < "{{ justfile_directory() }}/dolt.plist.template" \
        > "{{ launch_agents }}/dev.arusty.dolt.plist"
    echo "✓ Plist installed to {{ launch_agents }}/dev.arusty.dolt.plist"
```

- [ ] **Step 4: Update install recipe**

Replace the existing `install` recipe. The `dependencies`, `config`, and `mktree` recipes remain unchanged — only the `install` recipe's dependency line and body change.

Old:
```just
install: dependencies config
    @echo "Dolt installed. Use 'dolt init' in a directory to create a database."
```

New:
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

Delete the entire `serve-bg` recipe (definition and body). Replace the `stop` recipe. Add a new `start` recipe. Keep `serve` (foreground, single-database debug tool) and `serve-pg` unchanged.

```just
# Start dolt server (via daemon)
start:
    "{{ just_executable() }}" -f "{{ justfile_directory() }}/../../../daemon/justfile" load dolt

# Stop dolt server (via daemon)
stop:
    "{{ just_executable() }}" -f "{{ justfile_directory() }}/../../../daemon/justfile" unload dolt
```

- [ ] **Step 6: Verify justfile parses**

```bash
just --list db::dolt
```

Expected: shows recipes including `launchd`, `start`, `stop` among others.

- [ ] **Step 7: Commit**

```bash
git add services/databases/dolt/justfile services/databases/dolt/data.yml
git commit -m "feat(dolt): Integrate with daemon module, pin port 13306"
```

---

## Task 8: Update beads config

**Files:**
- Modify: `tools/agents/beads/config.yaml`

- [ ] **Step 1: Update dolt port in beads config**

This is the source-of-truth config that gets symlinked during `just tool agent beads install`. Change the `dolt:` block from:

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

## Task 9: Smoke test end-to-end

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
