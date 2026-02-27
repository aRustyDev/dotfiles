---
number: 7
title: Service Module Conventions
date: 2026-02-25
status: proposed
tags:
  - services
  - lifecycle
  - modules
---

# 7. Service Module Conventions

Date: 2026-02-25

## Status

Proposed

## Context

Some modules manage background services (databases, daemons, long-running processes). These modules need additional recipes beyond the standard set defined in ADR-002 for:

- Starting and stopping services
- Monitoring service health
- Viewing logs
- Managing persistence (launchd, systemd)

Currently, service-related recipes are inconsistent across modules.

## Decision

### 1. Service Module Definition

A module is a "service module" if it manages a background process that:
- Runs independently of the shell session
- Listens on a port or socket
- Requires explicit start/stop lifecycle management

Examples: `databases/meilisearch`, `databases/redis`, `docker`

### 2. Required Service Recipes

Service modules must implement these recipes (in addition to ADR-002 standard recipes):

| Recipe | Group | Purpose |
|--------|-------|---------|
| `start` | service | Start the service |
| `stop` | service | Stop the service |
| `restart` | service | Stop then start the service |
| `status` | info | Show service status (running, PID, port) |
| `logs` | info | View/tail service logs |

### 3. Recipe Specifications

#### `start`
- Starts the service in the background
- Writes PID to state directory
- Prints confirmation with PID and port/socket
- Should be idempotent (no-op if already running)

```just
[group("service")]
start:
    #!/usr/bin/env bash
    if pgrep -x myservice > /dev/null; then
        echo "myservice is already running"
        exit 0
    fi
    nohup myservice --config generated.toml > "{{ logs }}/myservice.log" 2>&1 &
    echo $! > "{{ state }}/myservice.pid"
    echo "✓ myservice started (PID: $!)"
```

#### `stop`
- Gracefully stops the service
- Removes PID file
- Should be idempotent (no-op if not running)

```just
[group("service")]
stop:
    #!/usr/bin/env bash
    if [ -f "{{ state }}/myservice.pid" ]; then
        pid=$(cat "{{ state }}/myservice.pid")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            rm "{{ state }}/myservice.pid"
            echo "✓ myservice stopped (PID: $pid)"
        else
            rm "{{ state }}/myservice.pid"
            echo "PID file stale, removed"
        fi
    else
        echo "myservice is not running"
    fi
```

#### `restart`
- Depends on `stop` and `start`

```just
[group("service")]
restart: stop start
    @just health
```

#### `status`
- Shows whether service is running
- Shows PID if running
- Shows port/socket if applicable
- Shows uptime if possible

```just
[group("info")]
status:
    #!/usr/bin/env bash
    if [ -f "{{ state }}/myservice.pid" ]; then
        pid=$(cat "{{ state }}/myservice.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo "✓ myservice is running (PID: $pid)"
            echo "  Port: {{ port }}"
        else
            echo "✗ myservice is not running (stale PID file)"
        fi
    else
        echo "✗ myservice is not running"
    fi
```

#### `logs`
- Tails the service log file
- Should use `tail -f` for live following

```just
[group("info")]
logs:
    tail -f "{{ logs }}/myservice.log"
```

### 4. Optional Service Recipes

These recipes are recommended but not required:

| Recipe | Group | Purpose |
|--------|-------|---------|
| `enable` | service | Enable service auto-start (launchd/systemd) |
| `disable` | service | Disable service auto-start |
| `reload` | service | Reload configuration without restart |

### 5. State and Log Directories

Service modules should use standard directories:

```just
state := data_local_directory() / "myservice"
logs := state / "logs"
```

### 6. Health Recipe Enhancement

For service modules, the `health` recipe (from ADR-002) should check:
- Process is running
- Port is responding (if network service)
- Health endpoint returns OK (if available)

```just
[group("info")]
health:
    #!/usr/bin/env bash
    # Check process
    if ! pgrep -x myservice > /dev/null; then
        echo "✗ myservice process not running"
        exit 1
    fi

    # Check health endpoint
    if curl -sf "http://localhost:{{ port }}/health" > /dev/null; then
        echo "✓ myservice is healthy"
    else
        echo "✗ myservice is not responding"
        exit 1
    fi
```

### 7. Recipe Dependencies

Use just's native recipe dependencies for setup:

```just
# start depends on template being generated
start: template
    ...

# restart depends on stop, then start
restart: stop start
    ...
```

## Consequences

### Easier

- Consistent service management across all service modules
- Predictable recipe names for operators
- Easy to script service orchestration

### More Difficult

- More recipes to implement for service modules
- Must maintain PID files and log directories
- Health checks require service-specific knowledge

## Anti-patterns

1. **Services without stop recipes**
   ```just
   # Bad: no way to stop cleanly
   start:
       myservice &

   # Good: proper lifecycle management
   start:
       ...write PID...
   stop:
       ...read PID and kill...
   ```

2. **Blocking start recipes**
   ```just
   # Bad: blocks the shell
   start:
       myservice --config config.toml

   # Good: backgrounds the process
   start:
       nohup myservice --config config.toml &
   ```

3. **Missing idempotency**
   ```just
   # Bad: starts duplicate processes
   start:
       myservice &

   # Good: checks if already running
   start:
       if ! pgrep -x myservice; then myservice &; fi
   ```
