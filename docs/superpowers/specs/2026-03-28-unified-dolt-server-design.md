# Unified Dolt Server Design

**Date:** 2026-03-28
**Status:** Proposed
**Context:** [Dolt server port instability bug report](/Users/adam/notes/job-hunting/v1/notes/beads-dolt-server-stability-prompt.md)

## Problem

bd (beads) auto-starts Dolt servers on random ports. During long sessions, servers crash or become unreachable, and bd spawns replacements on new ports. This causes:

- Silent data loss (writes to the old server are lost)
- Orphaned `dolt sql-server` processes accumulating
- `bd close` / `bd dep add` appearing to succeed but not persisting
- Port-change warnings that are easy to miss

Root cause: no single, stable dolt server with a known port. Two independent management systems (bd auto-start, `just db dolt serve-bg`) and a third ad-hoc state directory (`daemon/`) with no coordination.

## Design

### 1. Daemon Module (`daemon/`)

A generic launchd service manager registered as a root-level justfile module (`just daemon <recipe>`).

**Responsibilities:**
- Load/unload launchd plists from `~/Library/LaunchAgents/`
- Provide unified status, logs, and health checks across all managed services
- Detect and kill orphaned processes

**Directory structure:**
```
daemon/
  justfile           # lifecycle recipes
  data.yml           # module config
  services/          # plist templates dropped here by service modules
    .gitkeep
```

**Recipes:**
```
just daemon status [name]       # show status of all or one service
just daemon load <name>         # launchctl load the service plist
just daemon unload <name>       # launchctl unload
just daemon restart <name>      # unload + load
just daemon logs <name>         # tail the service log
just daemon doctor              # check all services: orphaned PIDs, stale ports, unreachable endpoints
just daemon doctor --fix        # kill orphans, clean stale state
just daemon list                # list registered services
```

**Plist convention:** Services install their plists to `~/Library/LaunchAgents/dev.arusty.<name>.plist`. The daemon module discovers them by glob pattern.

**State directory:** Runtime state (PID files, port files, logs) lives in `~/.local/state/daemon/<name>/`. Not in the repo --- these are runtime artifacts.

**Doctor recipe:** Iterates all registered services. For each: checks PID file, verifies process is alive, checks expected port is reachable, reports orphaned processes (e.g., dolt processes not tracked by any PID file). This directly addresses the bug report's orphan accumulation problem.

### 2. Dolt Service (`services/databases/dolt/`)

The dolt module generates its launchd plist and registers with the daemon manager. Existing install/config/database management recipes stay here.

**Changes to existing module:**
- `install` recipe gains a `launchd` dependency that generates the plist and calls `just daemon load dolt`
- `serve-bg` / `stop` recipes replaced by `just daemon load dolt` / `just daemon unload dolt`
- `default_port` changes from `3306` to `13306`
- `databases_dir` changes from `~/.local/share/dolt/databases` to `~/.local/share/dolt/`
- `dolt_home` stays at `~/.dolt` (dolt's own global config, not ours to move)

**New files:**
```
services/databases/dolt/
  ...existing...
  dolt.plist.template    # launchd plist template, hydrated by install recipe
```

**Plist template key settings:**
```xml
Label:            dev.arusty.dolt
ProgramArguments: dolt sql-server --host 127.0.0.1 --port 13306 --data-dir ~/.local/share/dolt/
RunAtLoad:        true
KeepAlive:        SuccessfulExit = false  (restart on crash, not on clean exit)
WorkingDirectory: ~/.local/share/dolt/
StandardOutPath:  ~/.local/state/daemon/dolt/dolt.log
StandardErrorPath: ~/.local/state/daemon/dolt/dolt-error.log
```

**Install flow:**
1. `brew install dolt` (existing)
2. `mkdir -p ~/.local/share/dolt/` + `~/.local/state/daemon/dolt/`
3. Hydrate plist template -> `~/Library/LaunchAgents/dev.arusty.dolt.plist`
4. `just daemon load dolt`
5. Verify health: connect to `127.0.0.1:13306`

**Existing recipes preserved:** `init`, `list`, `sql`, `status`, `log`, `diff`, `commit`, `clone`, `push`, `pull`, `info`, `servers`. The `serve`, `serve-bg`, `serve-pg`, `stop` recipes become thin wrappers around daemon recipes or get removed.

### 3. bd Integration

With a persistent launchd-managed server, bd connects to the existing server rather than starting its own.

**bd config:** Pin the dolt connection in the beads config (`tools/agents/beads/config.yaml`):
```yaml
dolt:
  host: 127.0.0.1
  port: 13306
  auto_start: false
```

`auto_start: false` tells bd to connect to the existing server and fail loudly if unreachable, rather than silently spawning a new one on a random port. If the server is down, the fix is `just daemon load dolt`.

**Interaction model:**
```
bd command -> connects to 127.0.0.1:13306 -> succeeds (server managed by launchd)
           -> connection refused -> ERROR: "Dolt server not running. Run: just daemon load dolt"
```

This eliminates all six failure scenarios from the bug report: no random ports, no orphaned processes, no silent data loss from server restarts mid-operation.

### 4. Migration & Cleanup

**Stale state to remove:**
- `daemon/dolt-state.json`, `dolt.pid`, `dolt.lock`, `dolt.log` --- runtime artifacts from the old bd-managed server. Delete from repo.
- `daemon/justfile` stub --- replaced by the real daemon module.
- `/etc/dotfiles/adam/.dolt-data` --- stale data dir. Migrate or re-initialize in `~/.local/share/dolt/`.

**Orphaned processes:** Before first use of the new setup:
1. Kill any existing `dolt sql-server` processes (`pkill -f 'dolt sql-server'`)
2. Clean up stale `.beads/dolt-server.pid` and `.beads/dolt-server.port` files in project dirs
3. Load the new launchd service

**Data migration:** If `beads_dotfiles-adam` database in `.dolt-data` has data worth keeping, copy it to `~/.local/share/dolt/beads_dotfiles-adam/` before removing the old directory. The install recipe should check for this and prompt.

**Module registration:**
- `daemon/` registered in root justfile as a direct module: `mod daemon 'daemon/justfile'`
- Update `just list` output and `.claude/CLAUDE.md` module tree

**Meilisearch (future):** The meilisearch module already has its own launchd recipes. A follow-up task can migrate those to use the daemon module. Out of scope for this spec.

## Success Criteria

1. `just daemon status` shows dolt running on port 13306
2. `bd` commands connect to 13306 without auto-starting servers
3. No orphaned `dolt sql-server` processes after extended sessions
4. `just daemon doctor` detects and reports unhealthy services
5. Rebooting the machine restarts the dolt server automatically via launchd
6. `just db dolt install` sets up everything end-to-end (brew, dirs, plist, load, verify)
