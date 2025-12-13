---
id: 9a8b7c6d-5e4f-3a2b-1c0d-9e8f7a6b5c4d
title: stdio-to-HTTP Wrappers for MCP Servers
created: 2025-12-12T00:00:00
updated: 2025-12-12T00:00:00
project: dotfiles
scope:
  - docker
  - mcp
type: guide
status: ✅ active
publish: true
tags:
  - mcp
  - stdio
  - http
  - wrappers
  - docker
  - supergateway
aliases:
  - MCP HTTP Wrappers
  - stdio Bridge
related:
  - ref: "[[mcp-transports-p1]]"
    description: Transport types overview
  - ref: "[[mcp-transports-p2]]"
    description: Concurrent access patterns
  - ref: "[[wrapper-quickstart]]"
    description: Quick start guide for wrappers
  - ref: "[[traefik-proxy-guide]]"
    description: Traefik routing configuration
---

# stdio-to-HTTP Wrappers for MCP Servers

This guide explains what stdio-to-HTTP wrappers are, how they work, and provides examples of existing projects and implementations.

---

## What is a stdio-to-HTTP Wrapper?

A **stdio-to-HTTP wrapper** is a bridge service that:

1. **Listens on an HTTP port** - Accepts HTTP/SSE requests
2. **Spawns stdio processes** - Runs the MCP server command
3. **Bridges communication** - Sends HTTP body to process stdin, reads stdout, returns as HTTP response
4. **Manages lifecycle** - Handles process creation, termination, errors, timeouts

```
┌──────────────┐                ┌─────────────────┐               ┌──────────────┐
│              │   HTTP POST    │                 │   stdin       │              │
│  MCP Client  │──────────────>│  HTTP Wrapper   │─────────────>│ stdio MCP    │
│              │                │  (Port 8080)    │               │   Server     │
│              │<──────────────│                 │<─────────────│ (node dist/  │
│              │   HTTP 200     │                 │   stdout      │  index.js)   │
└──────────────┘                └─────────────────┘               └──────────────┘
```

---

## Why Use Wrappers?

### Problems They Solve

| Problem | Without Wrapper | With Wrapper |
|---------|----------------|--------------|
| **Remote access** | stdio only works locally | HTTP accessible from network |
| **Traefik routing** | Can't route to stdio | Can route to HTTP port |
| **MCP clients** | Many only support HTTP/SSE | All clients can connect |
| **Multiple agents** | Need docker exec for each | HTTP handles concurrency naturally |
| **Load balancing** | Hard to distribute load | Can use standard HTTP load balancers |
| **Authentication** | No built-in auth | Can add API keys, OAuth, etc. |
| **Monitoring** | Hard to track usage | HTTP logs, metrics, tracing |

---

## Existing Projects

### 1. **supergateway** (Recommended, Node.js)

**Repository**: https://github.com/supercorp-ai/supergateway
**Maintainer**: Supercorp AI
**Language**: Node.js/TypeScript
**License**: MIT

**Features**:
- ✅ Streamable HTTP transport (MCP spec 2025-03-26)
- ✅ SSE (Server-Sent Events) support
- ✅ WebSocket support
- ✅ Stateful and stateless modes
- ✅ Session management with configurable timeout
- ✅ Custom headers support
- ✅ OAuth2 Bearer token authentication
- ✅ Zero-config for most use cases

**Why supergateway**:
- Most actively maintained wrapper
- Full support for latest MCP Streamable HTTP spec
- Simple CLI interface
- Works with any stdio MCP server
- Production-ready with session management

**Usage**:
```bash
# Install globally
npm install -g supergateway

# Basic usage - wraps any stdio MCP server
supergateway --stdio "mcp-server-time" --outputTransport streamableHttp --port 8080

# Stateful mode with session timeout
supergateway \
  --stdio "npx -y @modelcontextprotocol/server-filesystem /data" \
  --outputTransport streamableHttp \
  --stateful \
  --sessionTimeout 60000 \
  --port 8080

# Custom endpoint path
supergateway \
  --stdio "mcp-server-time" \
  --outputTransport streamableHttp \
  --streamableHttpPath /mcp \
  --port 8080
```

**Dockerfile Example** (time MCP server):
```dockerfile
FROM node:22-slim

# Install Python and the MCP server
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir mcp-server-time

# Install supergateway
RUN npm install -g supergateway

EXPOSE 8080

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(8080, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the stdio server
CMD supergateway \
    --stdio "mcp-server-time" \
    --outputTransport streamableHttp \
    --port 8080 \
    --streamableHttpPath /mcp \
    --stateful \
    --sessionTimeout 60000
```

**Docker Compose Example**:
```yaml
services:
  time:
    build:
      context: ${XDG_CONFIG_HOME:-$HOME/.config}/docker/files
      dockerfile: time.dockerfile
    image: time-mcp:http
    container_name: tool-time
    restart: unless-stopped
    networks:
      - traefik-public
    ports:
      - "8211:8080"
    environment:
      PORT: 8080
      MCP_PATH: /mcp
      SESSION_TIMEOUT: 60000
    healthcheck:
      test: ["CMD", "node", "-e", "require('net').connect(8080, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 15s
    labels:
      traefik.enable: true
      traefik.docker.network: traefik-public
```

---

### 2. **mcp-proxy** (TypeScript)

**Repository**: https://www.npmjs.com/package/mcp-proxy
**Maintainer**: punkpeye (Glama AI)
**Language**: TypeScript
**License**: MIT

**Features**:
- ✅ SSE (Server-Sent Events) support
- ✅ Streamable HTTP transport
- ✅ Stateless and stateful modes
- ✅ API key authentication
- ✅ Graceful shutdown
- ✅ Request timeout handling
- ✅ Debug logging

**Usage**:
```bash
# Install globally
npm install -g mcp-proxy

# Run wrapper for any stdio MCP server
mcp-proxy node dist/index.js --port 8080

# With API key authentication
mcp-proxy \
  --apiKey "secret-key-123" \
  --port 8080 \
  --host 0.0.0.0 \
  node dist/index.js

# In stateless mode
mcp-proxy \
  --stateless \
  --port 8080 \
  npx -y @modelcontextprotocol/server-filesystem /data
```

**Docker Example**:
```yaml
sequentialthinking-http:
  image: node:20-alpine
  command: >
    sh -c "npm install -g mcp-proxy &&
           mcp-proxy
             --host 0.0.0.0
             --port 8080
             --apiKey ${MCP_API_KEY:-}
             node /app/dist/index.js"
  ports:
    - "9001:8080"
  volumes:
    - ./sequentialthinking:/app
  labels:
    traefik.enable: true
    traefik.http.services.thinking.loadbalancer.server.port: 8080
    traefik.http.routers.thinking.rule: Host(`thinking.localhost`)
    traefik.http.routers.thinking.service: thinking
```

---

### 3. **mcp-wrapper-http** (Python/Flask)

**Repository**: https://github.com/DougBourban/mcp-wrapper-http
**Author**: Doug Bourban
**Language**: Python (Flask)
**License**: GPL-3.0

**Features**:
- ✅ Full JSON-RPC 2.0 support
- ✅ Server-Sent Events streaming
- ✅ Session management (optional)
- ✅ Thread-safe concurrent handling
- ✅ Origin validation
- ✅ Health check endpoint
- ✅ Comprehensive error handling

**Installation**:
```bash
pip install flask

# Clone repository
git clone https://github.com/DougBourban/mcp-wrapper-http.git
cd mcp-wrapper-http
```

**Usage**:
```bash
# Basic usage
python http_wrapper.py node dist/index.js

# Custom host and port
python http_wrapper.py \
  --host 0.0.0.0 \
  --port 8080 \
  npx -y @modelcontextprotocol/server-filesystem /data

# With debug mode
python http_wrapper.py \
  --debug \
  --port 3000 \
  python your-mcp-server.py
```

**Docker Example**:
```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY http_wrapper.py .
RUN pip install flask

# Expose port
EXPOSE 5000

# Run wrapper with your MCP server
CMD ["python", "http_wrapper.py", \
     "--host", "0.0.0.0", \
     "node", "/app/dist/index.js"]
```

**Docker Compose**:
```yaml
thinking-wrapper:
  build:
    context: ./mcp-wrapper-http
    dockerfile: Dockerfile
  command:
    - "python3"
    - "http_wrapper.py"
    - "--host"
    - "0.0.0.0"
    - "--port"
    - "5000"
    - "docker"
    - "exec"
    - "-i"
    - "thinking"
    - "node"
    - "dist/index.js"
  ports:
    - "9001:5000"
  labels:
    traefik.enable: true
    traefik.http.services.thinking.loadbalancer.server.port: 5000
    traefik.http.routers.thinking.rule: Host(`thinking.localhost`)
  depends_on:
    - sequentialthinking
```

---

### 4. **mcp-http-wrapper** (i-dream-of-ai)

**Repository**: https://github.com/i-dream-of-ai/mcp-http-wrapper
**Author**: i-dream-of-ai
**Language**: Node.js/TypeScript
**License**: (check repo)

**Features**:
- ✅ Secure API key authentication
- ✅ Universal wrapper for any stdio server
- ✅ Simple configuration
- ✅ Production-ready

**Usage**: (Check repository for latest documentation)

---

### 5. **Custom Stdio-to-HTTP Bridges**

Several other implementations exist:
- **netadx1ai/mcp-stdio-wrapper** - Claude Desktop integration focus
- **ConstAgility/faxify-mcp-client** - Bridges for Cursor/ChatGPT Desktop
- **adamwattis/mcp-proxy-server** - Aggregates multiple MCP servers

---

## DIY Implementation Examples

### Minimal Node.js Wrapper (50 lines)

```javascript
// mcp-stdio-http.js
const express = require('express');
const { spawn } = require('child_process');

const app = express();
app.use(express.json());

const MCP_COMMAND = process.argv.slice(2); // e.g., ['node', 'dist/index.js']
const PORT = process.env.PORT || 8080;

app.post('/mcp', async (req, res) => {
  try {
    // Spawn MCP server process
    const child = spawn(MCP_COMMAND[0], MCP_COMMAND.slice(1), {
      stdio: ['pipe', 'pipe', 'pipe']
    });

    let stdout = '';
    let stderr = '';

    // Collect stdout
    child.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    // Collect stderr
    child.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    // Send request to stdin
    child.stdin.write(JSON.stringify(req.body) + '\n');
    child.stdin.end();

    // Wait for process to complete
    child.on('close', (code) => {
      if (code !== 0) {
        return res.status(500).json({
          jsonrpc: '2.0',
          error: {
            code: -32603,
            message: 'Internal error',
            data: stderr
          },
          id: req.body.id
        });
      }

      try {
        const response = JSON.parse(stdout);
        res.json(response);
      } catch (e) {
        res.status(500).json({
          jsonrpc: '2.0',
          error: {
            code: -32700,
            message: 'Parse error',
            data: stdout
          },
          id: req.body.id
        });
      }
    });
  } catch (error) {
    res.status(500).json({
      jsonrpc: '2.0',
      error: {
        code: -32603,
        message: error.message
      },
      id: req.body.id
    });
  }
});

app.listen(PORT, () => {
  console.log(`MCP HTTP wrapper listening on port ${PORT}`);
  console.log(`Wrapping command: ${MCP_COMMAND.join(' ')}`);
});
```

**Usage**:
```bash
npm install express
node mcp-stdio-http.js node dist/index.js
```

---

### Minimal Python Wrapper (60 lines)

```python
# mcp_stdio_http.py
import subprocess
import json
import sys
from flask import Flask, request, jsonify

app = Flask(__name__)
MCP_COMMAND = sys.argv[1:]  # e.g., ['node', 'dist/index.js']

@app.route('/mcp', methods=['POST'])
def mcp_endpoint():
    try:
        # Spawn MCP server process
        process = subprocess.Popen(
            MCP_COMMAND,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        # Send request to stdin
        request_data = json.dumps(request.json)
        stdout, stderr = process.communicate(input=request_data, timeout=30)

        # Check exit code
        if process.returncode != 0:
            return jsonify({
                'jsonrpc': '2.0',
                'error': {
                    'code': -32603,
                    'message': 'Internal error',
                    'data': stderr
                },
                'id': request.json.get('id')
            }), 500

        # Parse and return response
        response = json.loads(stdout)
        return jsonify(response)

    except subprocess.TimeoutExpired:
        process.kill()
        return jsonify({
            'jsonrpc': '2.0',
            'error': {
                'code': -32603,
                'message': 'Request timeout'
            },
            'id': request.json.get('id')
        }), 500

    except Exception as e:
        return jsonify({
            'jsonrpc': '2.0',
            'error': {
                'code': -32603,
                'message': str(e)
            },
            'id': request.json.get('id')
        }), 500

@app.route('/health', methods=['GET'])
def health():
    return {'status': 'ok'}

if __name__ == '__main__':
    if len(MCP_COMMAND) == 0:
        print("Usage: python mcp_stdio_http.py <command> [args...]")
        sys.exit(1)

    print(f"Starting MCP HTTP wrapper for: {' '.join(MCP_COMMAND)}")
    app.run(host='0.0.0.0', port=8080)
```

**Usage**:
```bash
pip install flask
python mcp_stdio_http.py node dist/index.js
```

---

### Go Wrapper (Production-Ready)

```go
// main.go
package main

import (
	"bufio"
	"encoding/json"
	"log"
	"net/http"
	"os/exec"
	"time"
)

type JSONRPCRequest struct {
	JSONRPC string                 `json:"jsonrpc"`
	Method  string                 `json:"method"`
	Params  map[string]interface{} `json:"params,omitempty"`
	ID      interface{}            `json:"id"`
}

type JSONRPCResponse struct {
	JSONRPC string                 `json:"jsonrpc"`
	Result  interface{}            `json:"result,omitempty"`
	Error   *JSONRPCError          `json:"error,omitempty"`
	ID      interface{}            `json:"id"`
}

type JSONRPCError struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

var mcpCommand []string

func mcpHandler(w http.ResponseWriter, r *http.Request) {
	// Only accept POST
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Parse request
	var req JSONRPCRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		sendError(w, -32700, "Parse error", err.Error(), nil)
		return
	}

	// Spawn MCP process
	cmd := exec.Command(mcpCommand[0], mcpCommand[1:]...)
	stdin, _ := cmd.StdinPipe()
	stdout, _ := cmd.StdoutPipe()

	if err := cmd.Start(); err != nil {
		sendError(w, -32603, "Internal error", err.Error(), req.ID)
		return
	}

	// Send request to stdin
	if err := json.NewEncoder(stdin).Encode(req); err != nil {
		sendError(w, -32603, "Internal error", err.Error(), req.ID)
		return
	}
	stdin.Close()

	// Read response with timeout
	done := make(chan bool)
	var response JSONRPCResponse

	go func() {
		scanner := bufio.NewScanner(stdout)
		if scanner.Scan() {
			json.Unmarshal(scanner.Bytes(), &response)
		}
		done <- true
	}()

	select {
	case <-done:
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	case <-time.After(30 * time.Second):
		cmd.Process.Kill()
		sendError(w, -32603, "Request timeout", "", req.ID)
	}
}

func sendError(w http.ResponseWriter, code int, message, data string, id interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusInternalServerError)
	json.NewEncoder(w).Encode(JSONRPCResponse{
		JSONRPC: "2.0",
		Error: &JSONRPCError{
			Code:    code,
			Message: message,
			Data:    data,
		},
		ID: id,
	})
}

func main() {
	mcpCommand = os.Args[1:] // e.g., ["node", "dist/index.js"]

	http.HandleFunc("/mcp", mcpHandler)
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(`{"status":"ok"}`))
	})

	log.Printf("Starting MCP HTTP wrapper on :8080")
	log.Printf("Wrapping command: %v", mcpCommand)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
```

**Build & Run**:
```bash
go build -o mcp-wrapper main.go
./mcp-wrapper node dist/index.js
```

---

## Integration with Your Global Deployment

### Option 1: Using mcp-proxy (Recommended)

**Add to global.yaml**:

```yaml
# Wrapper for sequentialthinking
thinking-http:
  image: node:20-alpine
  container_name: thinking-http
  restart: unless-stopped
  command: >
    sh -c "npm install -g mcp-proxy &&
           mcp-proxy
             --host 0.0.0.0
             --port 8080
             --debug
             docker exec -i thinking node dist/index.js"
  ports:
    - "9001:8080"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock  # For docker exec
  labels:
    traefik.enable: true
    traefik.http.services.thinking.loadbalancer.server.port: 8080
    traefik.http.routers.thinking.rule: Host(`thinking.localhost`)
    traefik.http.routers.thinking.service: thinking
    traefik.http.routers.thinking.entrypoints: web
  depends_on:
    - sequentialthinking

# Or use PathPrefix routing
thinking-http-path:
  # Same as above, but with:
  labels:
    traefik.http.routers.thinking.rule: Host(`mcp.localhost`) && PathPrefix(`/thinking`)
    traefik.http.middlewares.strip-thinking.stripprefix.prefixes: /thinking
    traefik.http.routers.thinking.middlewares: strip-thinking
```

---

### Option 2: Using Python Flask Wrapper

```yaml
thinking-http:
  build:
    context: ./wrappers
    dockerfile: Dockerfile.python
  container_name: thinking-http
  restart: unless-stopped
  command:
    - "python3"
    - "/app/http_wrapper.py"
    - "--host"
    - "0.0.0.0"
    - "--port"
    - "8080"
    - "docker"
    - "exec"
    - "-i"
    - "thinking"
    - "node"
    - "dist/index.js"
  ports:
    - "9001:8080"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - ./wrappers/http_wrapper.py:/app/http_wrapper.py
  labels:
    traefik.enable: true
    traefik.http.services.thinking.loadbalancer.server.port: 8080
    traefik.http.routers.thinking.rule: Host(`thinking.localhost`)
  depends_on:
    - sequentialthinking
```

**Dockerfile.python**:
```dockerfile
FROM python:3.11-slim

RUN pip install flask
RUN apt-get update && apt-get install -y docker.io

WORKDIR /app

CMD ["python3", "http_wrapper.py"]
```

---

### Option 3: Sidecar Pattern (Most Efficient)

Instead of `docker exec`, mount the MCP server directly:

```yaml
thinking-http:
  image: node:20-alpine
  container_name: thinking-http
  restart: unless-stopped
  working_dir: /mcp-server
  command: >
    sh -c "npm install -g mcp-proxy &&
           mcp-proxy
             --host 0.0.0.0
             --port 8080
             node index.js"
  ports:
    - "9001:8080"
  volumes:
    # Mount the MCP server code
    - mcp-sequentialthinking:/mcp-server:ro
  labels:
    traefik.enable: true
    traefik.http.services.thinking.loadbalancer.server.port: 8080
    traefik.http.routers.thinking.rule: Host(`thinking.localhost`)

# Volume to share MCP server code
volumes:
  mcp-sequentialthinking:
    driver: local
```

---

## Comparison of Wrapper Solutions

| Feature | mcp-proxy | mcp-wrapper-http | DIY Node.js | DIY Python | DIY Go |
|---------|-----------|------------------|-------------|------------|--------|
| **Maturity** | ⭐⭐⭐ Official | ⭐⭐ Community | ⭐ Basic | ⭐ Basic | ⭐⭐ Production |
| **Setup** | npm install | git clone | 50 lines | 60 lines | 100 lines |
| **SSE Support** | ✅ Yes | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Session Mgmt** | ✅ Yes | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Auth** | ✅ API Key | ❌ No | ❌ No | ❌ No | ❌ No |
| **Concurrency** | ✅ Excellent | ✅ Good | ⚠️ Basic | ⚠️ Basic | ✅ Excellent |
| **Resource Usage** | Medium | Medium | Low | Low | Very Low |
| **Maintenance** | Active | Active | DIY | DIY | DIY |

**Recommendation**: Use **mcp-proxy** for production, DIY for learning/customization.

---

## Testing Your Wrapper

### 1. Health Check

```bash
curl http://localhost:8080/health
# Expected: {"status":"ok"}
```

### 2. Initialize Connection

```bash
curl -X POST http://localhost:8080/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {},
      "clientInfo": {"name": "test", "version": "1.0"}
    },
    "id": 1
  }'
```

### 3. List Tools

```bash
curl -X POST http://localhost:8080/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/list",
    "id": 2
  }'
```

### 4. Use with mcp-remote

```bash
npx -y mcp-remote http://localhost:8080/mcp --allow-http
```

---

## Performance Considerations

### Process Spawning Strategy

| Strategy | Pros | Cons | Best For |
|----------|------|------|----------|
| **Per-request spawn** | Stateless, isolated | High overhead | Low-traffic |
| **Long-lived process** | Fast response | Memory usage | High-traffic |
| **Process pool** | Balanced | Complex | Very high-traffic |

### Resource Limits

```yaml
thinking-http:
  deploy:
    resources:
      limits:
        cpus: '2.0'
        memory: 1G
      reservations:
        cpus: '0.5'
        memory: 256M
```

---

## Security Considerations

### 1. API Key Authentication

```bash
# With mcp-proxy
mcp-proxy --apiKey "secret-key" node dist/index.js

# Client request
curl -X POST http://localhost:8080/mcp \
  -H "X-API-Key: secret-key" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}'
```

### 2. Network Isolation

```yaml
thinking-http:
  networks:
    - internal  # Don't expose to public network
  labels:
    traefik.docker.network: internal
```

### 3. Rate Limiting (with Traefik)

```yaml
labels:
  traefik.http.middlewares.thinking-ratelimit.ratelimit.average: 10
  traefik.http.middlewares.thinking-ratelimit.ratelimit.burst: 20
  traefik.http.routers.thinking.middlewares: thinking-ratelimit
```

---

## Troubleshooting

### Wrapper Can't Find Docker Socket

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock  # ← Add this
```

### Process Timeout

Increase timeout:
```bash
# mcp-proxy
mcp-proxy --requestTimeout 60000 node dist/index.js  # 60 seconds

# Python wrapper
# Modify timeout in subprocess.communicate(timeout=60)
```

### High Memory Usage

Use process pool or long-lived process instead of spawning per-request.

### CORS Issues

Add CORS headers:
```javascript
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, X-API-Key');
  next();
});
```

---

## Recommended Architecture

For your global MCP deployment:

```
┌─────────────────────────────────────────────────────────────┐
│                         Traefik                              │
│              (thinking.localhost routing)                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │   thinking-http        │
            │   (mcp-proxy:8080)     │
            │                        │
            │   ┌────────────────┐   │
            │   │ stdio bridge   │   │
            │   └────────┬───────┘   │
            └────────────┼───────────┘
                         │ docker exec -i
                         ▼
            ┌────────────────────────┐
            │   thinking             │
            │   (stdio container)    │
            │   node dist/index.js   │
            └────────────────────────┘
```

**Benefits**:
- ✅ HTTP access via Traefik
- ✅ Preserves existing stdio container
- ✅ Minimal changes to current setup
- ✅ Easy to remove wrapper if not needed

---

## Next Steps

1. **Choose a wrapper**: mcp-proxy (recommended) or custom
2. **Add to global.yaml**: Create wrapper service
3. **Configure Traefik**: Add routing labels
4. **Test**: Verify HTTP access works
5. **Monitor**: Check resource usage
6. **Scale**: Add more wrappers if needed

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
