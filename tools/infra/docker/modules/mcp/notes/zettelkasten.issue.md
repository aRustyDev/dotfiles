---
id: ecd0d753-709f-4553-857b-f4541325d5d5
title: Zettelkasten MCP Docker Environment Configuration
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:38
project: dotfiles
scope: docker
type: reference
status: 📝 draft
publish: false
tags:
  - docker
  - mcp
aliases:
  - Zettelkasten MCP Docker Environment Configuration
  - Zettelkasten.Issue
related: []
---

When I run the command I get an error

```bash
docker run -i --rm -v /Users/adamsm/.local/share/mcp/zettelkasten/notes:/var/data/notes -v /Users/adamsm/.local/share/mcp/zettelkasten/db:/var/data/db ghcr.io/arustydev/mcp:zettelkasten
usage: main.py [-h] [--notes-dir NOTES_DIR] [--database-path DATABASE_PATH]
               [--log-level {DEBUG,INFO,WARNING,ERROR,CRITICAL}]
               [--transport {stdio,http}] [--host HOST] [--port PORT] [--cors]
main.py: error: argument --port: invalid int value: '$ZETTELKASTEN_HTTP_PORT'
```

This is the repo for the container https://github.com/aRustyDev/zettelkasten-mcp/tree/main

What do I need to set in the following zed MCP config to get this to run

```json
 "zettelkasten": {
      "source": "custom",
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-v",
        "/Users/adamsm/.local/share/mcp/zettelkasten/notes:/var/data/notes",
        "-v",
        "/Users/adamsm/.local/share/mcp/zettelkasten/db:/var/data/db",
        "ghcr.io/arustydev/mcp:zettelkasten"
      ],
      "env": {
        "ZETTELKASTEN_HTTP_HOST": "0.0.0.0",
        "ZETTELKASTEN_HTTP_PORT": "8000",
        "ZETTELKASTEN_HTTP_CORS": "${ZETTELKASTEN_HTTP_CORS:-false}",
        "ZETTELKASTEN_HTTP_CORS_ORIGINS": "${ZETTELKASTEN_HTTP_CORS_ORIGINS:-*}",
        "ZETTELKASTEN_JSON_RESPONSE": "true"
      }
    },
```

## Assistant

The issue is that the container's entrypoint is trying to use environment variables directly in arguments, but they're not being substituted. Looking at the error, the container expects `--port` to be an integer but it's receiving the literal string `$ZETTELKASTEN_HTTP_PORT`.

Let me check the repository to understand how it's configured:

**Tool Call: github_get_file_contents**
Status: Failed

**Tool Call: fetch_content**
Status: Failed

**Tool Call: github_get_file_contents**
Status: Failed

**Tool Call: github_get_file_contents**
Status: Failed

**Tool Call: Read file**
Status: Failed

Path /tmp/tmplcnruhmy not found in project

**Tool Call: github_get_file_contents**
Status: Failed

## Assistant

Let me check what the downloaded files contain:

**Tool Call: `curl -s https://raw.githubusercontent.com/aRustyDev/zettelkasten-mcp/main/docker/.env.example`**
Status: Completed

```
# Zettelkasten MCP Docker Environment Configuration
# Copy this file to .env and customize as needed

# ============================================================================
# Storage Configuration
# ============================================================================
# Host paths for persistent data storage
ZETTELKASTEN_NOTES_DIR=./data/notes
ZETTELKASTEN_DATABASE_DIR=./data/db

# ============================================================================
# HTTP Transport Configuration
# ============================================================================
# Port to expose the HTTP server on the host
ZETTELKASTEN_HTTP_PORT=8000

# Enable CORS for browser-based clients
# Set to "true" to allow cross-origin requests
ZETTELKASTEN_HTTP_CORS=false

# Allowed CORS origins (comma-separated)
# Use "*" for all origins (not recommended for production)
# Example: https://example.com,https://app.example.com
ZETTELKASTEN_HTTP_CORS_ORIGINS=*

# ============================================================================
# Logging Configuration
# ============================================================================
# Log level: DEBUG, INFO, WARNING, ERROR, CRITICAL
ZETTELKASTEN_LOG_LEVEL=INFO

# ============================================================================
# Usage Examples
# ============================================================================
#
# Start the HTTP server with default settings:
#   docker-compose -f docker/docker-compose.http.yml up
#
# Start with CORS enabled:
#   ZETTELKASTEN_HTTP_CORS=true docker-compose -f docker/docker-compose.http.yml up
#
# Start on a custom port:
#   ZETTELKASTEN_HTTP_PORT=9000 docker-compose -f docker/docker-compose.http.yml up
#
# Build and start in detached mode:
#   docker-compose -f docker/docker-compose.http.yml up -d --build
#
# View logs:
#   docker-compose -f docker/docker-compose.http.yml logs -f
#
# Stop the server:
#   docker-compose -f docker/docker-compose.http.yml down
#
```

**Tool Call: `curl -s https://raw.githubusercontent.com/aRustyDev/zettelkasten-mcp/main/docker/Dockerfile`**
Status: Completed

```
FROM python:3.12-slim as repo

SHELL ["/bin/bash", "-c"]

ARG REPO=aRustyDev/zettelkasten-mcp

RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/$REPO.git /app

FROM python:3.12-slim as app

SHELL ["/bin/bash", "-c"]

# Build arguments
ARG ZETTELKASTEN_LOG_LEVEL=INFO

# Environment variables for storage paths
ENV ZETTELKASTEN_NOTES_DIR=/var/data/notes
ENV ZETTELKASTEN_DATABASE_DIR=/var/data/db
ENV ZETTELKASTEN_DATABASE_PATH=$ZETTELKASTEN_DATABASE_DIR/zettelkasten.db

# HTTP transport configuration
ENV ZETTELKASTEN_HTTP_HOST=0.0.0.0
ENV ZETTELKASTEN_HTTP_PORT=8000
ENV ZETTELKASTEN_HTTP_CORS=false
ENV ZETTELKASTEN_HTTP_CORS_ORIGINS=*
ENV ZETTELKASTEN_JSON_RESPONSE=true

# Logging
ENV ZETTELKASTEN_LOG_LEVEL=${ZETTELKASTEN_LOG_LEVEL}

# Define volumes for persistent data
VOLUME ["${ZETTELKASTEN_NOTES_DIR}", "${ZETTELKASTEN_DATABASE_DIR}"]

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install uv for Python package management
RUN pip install --no-cache-dir uv

# Set working directory
WORKDIR /app

# Copy project files
COPY --from=repo /app/pyproject.toml /app/uv.lock /app/README.md ./
COPY --from=repo /app/src/ /app/src/

# Create virtual environment and install dependencies
RUN uv venv && \
    source .venv/bin/activate && \
    uv sync --no-dev

# Create data directories
RUN mkdir -p ${ZETTELKASTEN_NOTES_DIR} ${ZETTELKASTEN_DATABASE_DIR}

# Expose HTTP port
EXPOSE $ZETTELKASTEN_HTTP_PORT

# Health check endpoint (FastMCP may provide this)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:$ZETTELKASTEN_HTTP_PORT/health').read()" || exit 1

# Run the server with HTTP transport
ENTRYPOINT ["/app/.venv/bin/python", "-m", "zettelkasten_mcp.main"]
CMD ["--transport", "http", "--host", "$ZETTELKASTEN_HTTP_HOST", "--port", "$ZETTELKASTEN_HTTP_PORT"]
```

## Assistant

I see the issue! The `CMD` line in the Dockerfile uses `$ZETTELKASTEN_HTTP_HOST` and `$ZETTELKASTEN_HTTP_PORT` **as literal strings** instead of expanding the environment variables. This is because `CMD` with the array syntax doesn't do shell variable expansion.

For **stdio transport** (which is what MCP clients need), you don't need HTTP at all. Here's the corrected configuration:

## Fixed Zed MCP Config

```json
"zettelkasten": {
  "source": "custom",
  "command": "docker",
  "args": [
    "run",
    "-i",
    "--rm",
    "-v",
    "/Users/adamsm/.local/share/mcp/zettelkasten/notes:/var/data/notes",
    "-v",
    "/Users/adamsm/.local/share/mcp/zettelkasten/db:/var/data/db",
    "ghcr.io/arustydev/mcp:zettelkasten",
    "--transport", "stdio",
    "--notes-dir", "/var/data/notes",
    "--database-path", "/var/data/db/zettelkasten.db"
  ]
}
```

**Key changes:**

1. Removed all the `env` settings (they're for HTTP mode, not stdio)
2. Added `--transport stdio` argument
3. Added `--notes-dir` and `--database-path` arguments to explicitly set paths

## Test Command

```bash
docker run -i --rm \
  -v /Users/adamsm/.local/share/mcp/zettelkasten/notes:/var/data/notes \
  -v /Users/adamsm/.local/share/mcp/zettelkasten/db:/var/data/db \
  ghcr.io/arustydev/mcp:zettelkasten \
  --transport stdio \
  --notes-dir /var/data/notes \
  --database-path /var/data/db/zettelkasten.db
```

## Alternative: If You Want HTTP Mode

If you actually want to run it in HTTP mode (for web access), you need to override the CMD with proper shell expansion:

```json
"zettelkasten": {
  "source": "custom",
  "command": "docker",
  "args": [
    "run",
    "-i",
    "--rm",
    "-p", "8000:8000",
    "-v", "/Users/adamsm/.local/share/mcp/zettelkasten/notes:/var/data/notes",
    "-v", "/Users/adamsm/.local/share/mcp/zettelkasten/db:/var/data/db",
    "-e", "ZETTELKASTEN_HTTP_PORT=8000",
    "ghcr.io/arustydev/mcp:zettelkasten",
    "--transport", "http",
    "--host", "0.0.0.0",
    "--port", "8000",
    "--notes-dir", "/var/data/notes",
    "--database-path", "/var/data/db/zettelkasten.db"
  ]
}
```

But **for MCP clients like Zed, you want stdio**, so use the first configuration.

## User

What changes do I need to make to the DOCKERFILE to enable passing the `$ZETTELKASTEN_HTTP_HOST` and `$ZETTELKASTEN_HTTP_PORT` in at runtime instead of them being executed as literal strings

## Assistant

To fix the Dockerfile so it properly expands environment variables at runtime, you need to change the `CMD` to use **shell form** instead of **exec form**, or use an entrypoint script. Here are both solutions:

## Solution 1: Use Shell Form for CMD (Simplest)

Change the last line of the Dockerfile from:

```dockerfile
CMD ["--transport", "http", "--host", "$ZETTELKASTEN_HTTP_HOST", "--port", "$ZETTELKASTEN_HTTP_PORT"]
```

To:

```dockerfile
CMD --transport http --host $ZETTELKASTEN_HTTP_HOST --port $ZETTELKASTEN_HTTP_PORT
```

**Why this works:** Shell form (`CMD command`) runs through `/bin/sh -c`, which expands variables. Exec form (`CMD ["executable", "param"]`) does not.

## Solution 2: Use Shell Wrapper in CMD (More Explicit)

```dockerfile
CMD ["/bin/sh", "-c", "/app/.venv/bin/python -m zettelkasten_mcp.main --transport http --host $ZETTELKASTEN_HTTP_HOST --port $ZETTELKASTEN_HTTP_PORT"]
```

**Note:** This combines ENTRYPOINT's command with CMD arguments.

## Solution 3: Entrypoint Script (Most Flexible - Recommended)

Create an entrypoint script that handles variable expansion:

**1. Create `docker/entrypoint.sh`:**

```bash
#!/bin/bash
set -e

# Default values if not set
ZETTELKASTEN_HTTP_HOST=${ZETTELKASTEN_HTTP_HOST:-0.0.0.0}
ZETTELKASTEN_HTTP_PORT=${ZETTELKASTEN_HTTP_PORT:-8000}
ZETTELKASTEN_TRANSPORT=${ZETTELKASTEN_TRANSPORT:-http}
ZETTELKASTEN_NOTES_DIR=${ZETTELKASTEN_NOTES_DIR:-/var/data/notes}
ZETTELKASTEN_DATABASE_PATH=${ZETTELKASTEN_DATABASE_PATH:-/var/data/db/zettelkasten.db}

# Build the command with expanded variables
exec /app/.venv/bin/python -m zettelkasten_mcp.main \
    --transport "$ZETTELKASTEN_TRANSPORT" \
    --host "$ZETTELKASTEN_HTTP_HOST" \
    --port "$ZETTELKASTEN_HTTP_PORT" \
    --notes-dir "$ZETTELKASTEN_NOTES_DIR" \
    --database-path "$ZETTELKASTEN_DATABASE_PATH" \
    "$@"
```

**2. Update the Dockerfile:**

```dockerfile
# ... (keep everything before ENTRYPOINT the same)

# Copy entrypoint script
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose HTTP port
EXPOSE $ZETTELKASTEN_HTTP_PORT

# Health check endpoint (FastMCP may provide this)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:${ZETTELKASTEN_HTTP_PORT}/health').read()" || exit 1

# Use entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
CMD []
```

## Complete Fixed Dockerfile (Solution 3)

Here's the full corrected version:

```dockerfile
FROM python:3.12-slim as repo

SHELL ["/bin/bash", "-c"]

ARG REPO=aRustyDev/zettelkasten-mcp

RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/$REPO.git /app

FROM python:3.12-slim as app

SHELL ["/bin/bash", "-c"]

# Build arguments
ARG ZETTELKASTEN_LOG_LEVEL=INFO

# Environment variables for storage paths
ENV ZETTELKASTEN_NOTES_DIR=/var/data/notes
ENV ZETTELKASTEN_DATABASE_DIR=/var/data/db
ENV ZETTELKASTEN_DATABASE_PATH=$ZETTELKASTEN_DATABASE_DIR/zettelkasten.db

# HTTP transport configuration
ENV ZETTELKASTEN_HTTP_HOST=0.0.0.0
ENV ZETTELKASTEN_HTTP_PORT=8000
ENV ZETTELKASTEN_HTTP_CORS=false
ENV ZETTELKASTEN_HTTP_CORS_ORIGINS=*
ENV ZETTELKASTEN_JSON_RESPONSE=true
ENV ZETTELKASTEN_TRANSPORT=http

# Logging
ENV ZETTELKASTEN_LOG_LEVEL=${ZETTELKASTEN_LOG_LEVEL}

# Define volumes for persistent data
VOLUME ["${ZETTELKASTEN_NOTES_DIR}", "${ZETTELKASTEN_DATABASE_DIR}"]

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install uv for Python package management
RUN pip install --no-cache-dir uv

# Set working directory
WORKDIR /app

# Copy project files
COPY --from=repo /app/pyproject.toml /app/uv.lock /app/README.md ./
COPY --from=repo /app/src/ /app/src/

# Create virtual environment and install dependencies
RUN uv venv && \
    source .venv/bin/activate && \
    uv sync --no-dev

# Create data directories
RUN mkdir -p ${ZETTELKASTEN_NOTES_DIR} ${ZETTELKASTEN_DATABASE_DIR}

# Create entrypoint script inline
RUN echo '#!/bin/bash\n\
set -e\n\
ZETTELKASTEN_HTTP_HOST=${ZETTELKASTEN_HTTP_HOST:-0.0.0.0}\n\
ZETTELKASTEN_HTTP_PORT=${ZETTELKASTEN_HTTP_PORT:-8000}\n\
ZETTELKASTEN_TRANSPORT=${ZETTELKASTEN_TRANSPORT:-http}\n\
ZETTELKASTEN_NOTES_DIR=${ZETTELKASTEN_NOTES_DIR:-/var/data/notes}\n\
ZETTELKASTEN_DATABASE_PATH=${ZETTELKASTEN_DATABASE_PATH:-/var/data/db/zettelkasten.db}\n\
exec /app/.venv/bin/python -m zettelkasten_mcp.main \\\n\
    --transport "$ZETTELKASTEN_TRANSPORT" \\\n\
    --host "$ZETTELKASTEN_HTTP_HOST" \\\n\
    --port "$ZETTELKASTEN_HTTP_PORT" \\\n\
    --notes-dir "$ZETTELKASTEN_NOTES_DIR" \\\n\
    --database-path "$ZETTELKASTEN_DATABASE_PATH" \\\n\
    "$@"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

# Expose HTTP port
EXPOSE 8000

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:' + str($ZETTELKASTEN_HTTP_PORT) + '/health').read()" || exit 1

# Use entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
CMD []
```

## Usage After Fix

Now you can properly override at runtime:

```bash
# HTTP mode with custom port
docker run -i --rm \
  -e ZETTELKASTEN_HTTP_PORT=9000 \
  -e ZETTELKASTEN_HTTP_HOST=127.0.0.1 \
  -p 9000:9000 \
  -v /Users/adamsm/.local/share/mcp/zettelkasten/notes:/var/data/notes \
  -v /Users/adamsm/.local/share/mcp/zettelkasten/db:/var/data/db \
  ghcr.io/arustydev/mcp:zettelkasten

# STDIO mode
docker run -i --rm \
  -e ZETTELKASTEN_TRANSPORT=stdio \
  -v /Users/adamsm/.local/share/mcp/zettelkasten/notes:/var/data/notes \
  -v /Users/adamsm/.local/share/mcp/zettelkasten/db:/var/data/db \
  ghcr.io/arustydev/mcp:zettelkasten
```

## Why Solution 3 is Best

- ✅ **Flexibility**: Can handle both stdio and http transports
- ✅ **Default values**: Provides sensible defaults if env vars not set
- ✅ **Additional args**: The `"$@"` allows passing extra CLI arguments
- ✅ **Clear separation**: Entrypoint logic separate from Dockerfile
- ✅ **Debugging**: Easier to troubleshoot startup issues

**Recommendation**: Submit a PR to the `aRustyDev/zettelkasten-mcp` repository with Solution 3!

## User

would this work?
`CMD ["--transport", "http", "--host", $ZETTELKASTEN_HTTP_HOST, "--port", $ZETTELKASTEN_HTTP_PORT]`

## Assistant

**No, that won't work.** That syntax is invalid JSON and will cause a Docker build error.

The `CMD` instruction in Dockerfile must be either:

1. **Exec form** (JSON array): `CMD ["executable", "param1", "param2"]`
2. **Shell form** (string): `CMD command param1 param2`

Your attempt mixes both forms and has incorrect JSON syntax (missing quotes around the variables).

## Why It Fails

```dockerfile
# ❌ INVALID - Not valid JSON, will fail to build
CMD ["--transport", "http", "--host", $ZETTELKASTEN_HTTP_HOST, "--port", $ZETTELKASTEN_HTTP_PORT]
```

**Error you'd get:**

```
Error response from daemon: invalid reference format
```

## What Happens with Different Syntaxes

```dockerfile
# ❌ Exec form - Variables NOT expanded (treated as literal strings)
CMD ["--transport", "http", "--host", "$ZETTELKASTEN_HTTP_HOST", "--port", "$ZETTELKASTEN_HTTP_PORT"]
# Result: --host $ZETTELKASTEN_HTTP_HOST (literal string, not 0.0.0.0)

# ✅ Shell form - Variables ARE expanded
CMD --transport http --host $ZETTELKASTEN_HTTP_HOST --port $ZETTELKASTEN_HTTP_PORT
# Result: --host 0.0.0.0 (properly expanded)

# ✅ Exec form with shell - Variables ARE expanded
CMD ["/bin/sh", "-c", "exec /app/.venv/bin/python -m zettelkasten_mcp.main --transport http --host $ZETTELKASTEN_HTTP_HOST --port $ZETTELKASTEN_HTTP_PORT"]
# Result: --host 0.0.0.0 (properly expanded via shell)
```

## Quick Fix Comparison

If you want the absolute minimal change to the existing Dockerfile:

### Current (Broken):

```dockerfile
ENTRYPOINT ["/app/.venv/bin/python", "-m", "zettelkasten_mcp.main"]
CMD ["--transport", "http", "--host", "$ZETTELKASTEN_HTTP_HOST", "--port", "$ZETTELKASTEN_HTTP_PORT"]
```

### Minimal Fix (Shell Form):

```dockerfile
ENTRYPOINT ["/app/.venv/bin/python", "-m", "zettelkasten_mcp.main"]
CMD --transport http --host $ZETTELKASTEN_HTTP_HOST --port $ZETTELKASTEN_HTTP_PORT
```

### Or (Exec Form with Shell):

```dockerfile
# Remove ENTRYPOINT or make it just the shell
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/app/.venv/bin/python -m zettelkasten_mcp.main --transport http --host $ZETTELKASTEN_HTTP_HOST --port $ZETTELKASTEN_HTTP_PORT"]
```

## Recommendation

For the zettelkasten-mcp project, I'd recommend the **entrypoint script approach** (Solution 3 from my previous answer) because:

1. ✅ Supports both `stdio` and `http` transports
2. ✅ Handles all environment variables consistently
3. ✅ Provides default values
4. ✅ More maintainable for future changes
5. ✅ Allows passing additional arguments via `docker run ... arg1 arg2`

But if you want **just the minimal fix**, use shell form:

```dockerfile
CMD --transport http --host $ZETTELKASTEN_HTTP_HOST --port $ZETTELKASTEN_HTTP_PORT
```

## User

convert this json to a command line again

```json
"zettelkasten": {
  "source": "custom",
  "command": "docker",
  "args": [
    "run",
    "-i",
    "--rm",
    "-p", "8000:8000",
    "-v", "/Users/adamsm/.local/share/mcp/zettelkasten/notes:/var/data/notes",
    "-v", "/Users/adamsm/.local/share/mcp/zettelkasten/db:/var/data/db",
    "-e", "ZETTELKASTEN_HTTP_PORT=8000",
    "ghcr.io/arustydev/mcp:zettelkasten",
    "--transport", "http",
    "--host", "0.0.0.0",
    "--port", "8000",
    "--notes-dir", "/var/data/notes",
    "--database-path", "/var/data/db/zettelkasten.db"
  ]
}
```

## Assistant

Here's the command:

```bash
docker run -i --rm -p 8000:8000 \
  -v /Users/adamsm/.local/share/mcp/zettelkasten/notes:/var/data/notes \
  -v /Users/adamsm/.local/share/mcp/zettelkasten/db:/var/data/db \
  -e ZETTELKASTEN_HTTP_PORT=8000 \
  ghcr.io/arustydev/mcp:zettelkasten \
  --transport http \
  --host 0.0.0.0 \
  --port 8000 \
  --notes-dir /var/data/notes \
  --database-path /var/data/db/zettelkasten.db
```

Or as a one-liner:

```bash
docker run -i --rm -p 8000:8000 -v /Users/adamsm/.local/share/mcp/zettelkasten/notes:/var/data/notes -v /Users/adamsm/.local/share/mcp/zettelkasten/db:/var/data/db -e ZETTELKASTEN_HTTP_PORT=8000 ghcr.io/arustydev/mcp:zettelkasten --transport http --host 0.0.0.0 --port 8000 --notes-dir /var/data/notes --database-path /var/data/db/zettelkasten.db
```

This will start the Zettelkasten MCP server in HTTP mode on port 8000, accessible at `http://localhost:8000`.

## User

I have deployed the docker container with zettelkasten to localhost:8200

I'm now trying to access it via mcp-remote like

```bash
npx -y mcp-remote \
    http://localhost:8200/api \
    --allow-http
```

But am getting the following error

```bash
npx -y mcp-remote \
    http://localhost:8200/api \
    --allow-http
[29491] Using automatically selected callback port: 17060
[29491] [29491] Connecting to remote server: http://localhost:8200/api
[29491] Using transport strategy: http-first
[29491] Received error: Error POSTing to endpoint (HTTP 404): Not Found
[29491] Recursively reconnecting for reason: falling-back-to-alternate-transport
[29491] [29491] Connecting to remote server: http://localhost:8200/api
[29491] Using transport strategy: sse-only
[29491] Connection error: SseError: SSE error: Non-200 status code (404)
    at _eventSource.onerror (file:///Users/adamsm/.npm/_npx/705d23756ff7dacc/node_modules/mcp-remote/dist/chunk-WSHBHZXM.js:13096:23)
    at EventSource.failConnection_fn (file:///Users/adamsm/.npm/_npx/705d23756ff7dacc/node_modules/mcp-remote/dist/chunk-WSHBHZXM.js:12986:53)
    at file:///Users/adamsm/.npm/_npx/705d23756ff7dacc/node_modules/mcp-remote/dist/chunk-WSHBHZXM.js:12828:74
    at process.processTicksAndRejections (node:internal/process/task_queues:103:5) {
  code: 404,
  event: {
    type: 'error',
    message: 'Non-200 status code (404)',
    code: 404,
    defaultPrevented: false,
    cancelable: false,
    timeStamp: 202.113
  }
}
[29491] Fatal error: SseError: SSE error: Non-200 status code (404)
    at _eventSource.onerror (file:///Users/adamsm/.npm/_npx/705d23756ff7dacc/node_modules/mcp-remote/dist/chunk-WSHBHZXM.js:13096:23)
    at EventSource.failConnection_fn (file:///Users/adamsm/.npm/_npx/705d23756ff7dacc/node_modules/mcp-remote/dist/chunk-WSHBHZXM.js:12986:53)
    at file:///Users/adamsm/.npm/_npx/705d23756ff7dacc/node_modules/mcp-remote/dist/chunk-WSHBHZXM.js:12828:74
    at process.processTicksAndRejections (node:internal/process/task_queues:103:5) {
  code: 404,
  event: {
    type: 'error',
    message: 'Non-200 status code (404)',
    code: 404,
    defaultPrevented: false,
    cancelable: false,
    timeStamp: 202.113
  }
}
```
