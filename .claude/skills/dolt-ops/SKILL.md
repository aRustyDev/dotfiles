---
id: dolt-ops-skill
title: Dolt Operations Skill
created: 2026-03-28T00:00:00
updated: 2026-03-28T00:00:00
project: dotfiles
scope: ai
type: reference
status: draft
publish: false
tags:
  - dolt
  - database
  - sql
  - version-control
  - launchd
  - daemon
aliases:
  - dolt
  - dolt-server
  - sql database
related:
  - beads-ops
---

# Dolt Operations Skill

Comprehensive reference for managing Dolt SQL databases — server lifecycle, database operations, troubleshooting, and integration with bd (beads).

## Activation Triggers

- "dolt"
- "dolt server"
- "database"
- "sql server"
- "dolt not running"
- "dolt port"
- "dolt troubleshoot"
- "beads data loss"

## What is Dolt

Dolt is a SQL database with Git-like version control. Every table has branches, commits, diffs, merges, and logs. It speaks the MySQL wire protocol (port 13306 in this environment) and can also run as DoltgreSQL (PostgreSQL-compatible).

In this environment, Dolt is the backing store for bd (beads) issue tracking. It runs as a persistent launchd service managed by the daemon module.

## Architecture

```
┌─────────────────────────────────────────────┐
│ launchd (dev.arusty.dolt)                   │
│   manages: dolt sql-server                  │
│   port: 13306 (fixed)                       │
│   data: ~/.local/share/dolt/databases/      │
│   logs: ~/.local/state/daemon/dolt/         │
│   plist: ~/Library/LaunchAgents/            │
├─────────────────────────────────────────────┤
│ Consumers:                                  │
│   bd (beads) ──> 127.0.0.1:13306           │
│   direct SQL ──> mysql -h 127.0.0.1 -P 13306 -u root │
└─────────────────────────────────────────────┘
```

### Key Paths

| Path | Purpose |
|------|---------|
| `~/.local/share/dolt/databases/` | Database storage (each DB is a subdirectory) |
| `~/.local/state/daemon/dolt/dolt.log` | Server stdout log |
| `~/.local/state/daemon/dolt/dolt-error.log` | Server stderr log |
| `~/Library/LaunchAgents/dev.arusty.dolt.plist` | launchd service definition |
| `~/.dolt/` | Dolt global config (user, credentials) |

### Key Settings

| Setting | Value | Reason |
|---------|-------|--------|
| Port | 13306 | Avoids MySQL (3306) and legacy dolt (3307) conflicts |
| Host | 127.0.0.1 | Local only, no network exposure |
| User | root | Default dolt superuser (no password in dev) |
| KeepAlive | on crash | launchd restarts on crash, not on clean exit |
| RunAtLoad | true | Starts automatically at login |

## Server Lifecycle

### Via daemon module (preferred)

```bash
just daemon status dolt        # check if running, show PID and port
just daemon load dolt          # start via launchctl
just daemon unload dolt        # stop via launchctl
just daemon restart dolt       # unload + load
just daemon logs dolt          # tail the server log
just daemon doctor             # health check all services
just daemon doctor fix         # kill orphans, clean stale state
```

### Via dolt module

```bash
just db dolt install           # full setup: brew, dirs, plist, load, verify
just db dolt info              # show dolt version, config, paths
just db dolt servers           # show running dolt servers
```

### Direct launchctl (escape hatch)

```bash
launchctl list | grep dolt
launchctl load ~/Library/LaunchAgents/dev.arusty.dolt.plist
launchctl unload ~/Library/LaunchAgents/dev.arusty.dolt.plist
```

## Database Operations

### Managing databases

```bash
just db dolt init <name>       # create new database in ~/.local/share/dolt/databases/<name>/
just db dolt list              # list all databases
just db dolt sql <name>        # open interactive SQL shell
just db dolt status <name>     # show dolt status (uncommitted changes)
just db dolt log <name>        # show commit history
just db dolt diff <name>       # show uncommitted changes
just db dolt commit <name> "<message>"  # stage all + commit
```

### Remote operations

```bash
just db dolt clone <remote> [name]  # clone from DoltHub
just db dolt push <name>            # push to remote
just db dolt pull <name>            # pull from remote
```

### Direct SQL

```bash
mysql -h 127.0.0.1 -P 13306 -u root <database>
```

### Dolt-specific SQL

```sql
-- Version control
CALL dolt_commit('-am', 'Add users table');
CALL dolt_branch('feature-branch');
CALL dolt_checkout('feature-branch');
CALL dolt_merge('feature-branch');

-- History
SELECT * FROM dolt_log;
SELECT * FROM dolt_diff('HEAD~1', 'HEAD', 'tablename');
SELECT * FROM dolt_status;
SELECT * FROM dolt_branches;
```

## Configuration

### Dolt global config

```bash
dolt config --global --list                          # show all
dolt config --global --add user.name "Your Name"     # set user
dolt config --global --add user.email "you@example.com"
```

### bd (beads) connection

bd connects to dolt via settings in `tools/agents/beads/config.yaml`:

```yaml
dolt:
  mode: server
  host: 127.0.0.1
  port: 13306
  user: root
```

Per-project `.beads/config.yaml` files can override these settings. The global config is the source of truth, symlinked during `just tool agent beads install`.

## Troubleshooting

### Server not running

**Symptom:** `bd` commands fail with connection errors, or `just daemon status dolt` shows not running.

```bash
# Check status
just daemon status dolt

# Check if the plist exists
ls ~/Library/LaunchAgents/dev.arusty.dolt.plist

# If plist exists, load it
just daemon load dolt

# If plist missing, reinstall
just db dolt install

# Check logs for crash reason
just daemon logs dolt
```

### Orphaned dolt processes

**Symptom:** Multiple `dolt sql-server` processes running, bd shows port-change warnings, data doesn't persist.

This was the root cause of the original instability bug — bd auto-started servers on random ports, accumulating orphaned processes.

```bash
# Detect orphans
just daemon doctor

# Kill orphans and clean stale state
just daemon doctor fix

# Verify clean state
ps aux | grep 'dolt sql-server'
just daemon status dolt
```

### Port conflict

**Symptom:** Server fails to start, log shows "address already in use".

```bash
# Find what's using port 13306
lsof -i :13306

# Kill it if it's a stale dolt process
kill <pid>

# Restart clean
just daemon restart dolt
```

### bd operations not persisting

**Symptom:** `bd close`, `bd dep add` appear to succeed but revert on next `bd list`.

**Root cause (historical):** bd was connecting to a server on a different port than expected, or the server restarted mid-operation losing unflushed writes.

**With the unified setup, this should not happen.** If it does:

1. Verify bd config points to 13306: `grep port .beads/config.yaml`
2. Verify only one dolt server is running: `ps aux | grep 'dolt sql-server'`
3. Verify the server is healthy: `just daemon status dolt`
4. Check for recent server restarts in logs: `just daemon logs dolt`

### Database tables missing

**Symptom:** Dolt log shows "table not found" errors.

This happens when the server starts but bd hasn't initialized its schema yet, or when the server's `--data-dir` points to a different directory than expected.

```bash
# Verify data-dir matches
cat ~/Library/LaunchAgents/dev.arusty.dolt.plist | grep -A1 data-dir

# List databases
just db dolt list

# Check if the expected database exists
ls ~/.local/share/dolt/databases/

# If bd's database is missing, re-initialize
bd init
```

### Server crashes repeatedly

**Symptom:** launchd keeps restarting dolt but it crashes immediately.

```bash
# Check error log
cat ~/.local/state/daemon/dolt/dolt-error.log

# Check if data is corrupted
cd ~/.local/share/dolt/databases/<name> && dolt status

# Common fixes
dolt gc                        # garbage collect
dolt stash                     # stash uncommitted changes
```

## Integration with bd (beads)

bd uses dolt as its backing store. Each project gets a database named `beads_<project-prefix>` (e.g., `beads_dotfiles-adam`).

**How they interact:**
- `bd init` creates the beads database and schema in the running dolt server
- `bd sync` commits beads state to dolt and syncs with git
- All `bd` mutations (create, close, update, dep add/rm) write to dolt via SQL
- bd reads `dolt.host`, `dolt.port`, `dolt.user` from `.beads/config.yaml`

**Critical rule:** The dolt server must be running BEFORE any bd commands. With launchd managing the server, this is automatic after initial setup.

## DoltgreSQL (PostgreSQL mode)

Dolt can also serve a PostgreSQL-compatible interface. This is separate from the MySQL-compatible server and runs on a different port.

```bash
# Start PostgreSQL-compatible server (manual, not launchd-managed)
just db dolt serve-pg <name> [port=5432]

# Connect
psql -h 127.0.0.1 -p 5432 -U root <database>
```

DoltgreSQL is not managed by the daemon module. If you need persistent PostgreSQL mode, create a separate launchd plist.
