# MCP Observability Proxy

A high-performance reverse proxy for Model Context Protocol (MCP) servers that provides comprehensive observability including distributed tracing, metrics, and logging.

## Features

- **JSON-RPC Parsing**: Understands MCP protocol, extracts tool names, arguments, and results
- **Distributed Tracing**: OpenTelemetry-native with automatic span creation for each request
- **Prometheus Metrics**: Request counts, latencies, error rates by tool/client/experiment
- **Client Identification**: Track usage across different AI clients via headers
- **Experiment Tagging**: A/B test different models, prompts, or configurations
- **Zero-config Upstream**: Point any MCP client at the proxy, it forwards to actual servers

## Quick Start

### Prerequisites

- Docker & Docker Compose
- An MCP server running locally (default: `http://localhost:8081`)

### Start the Stack

```bash
# Start all services (proxy, Jaeger, Prometheus, Grafana)
docker-compose up -d

# View proxy logs
docker-compose logs -f proxy
```

### Endpoints

| Service             | URL                                | Description                 |
| ------------------- | ---------------------------------- | --------------------------- |
| MCP Proxy           | http://localhost:8080              | Point your MCP clients here |
| Grafana             | http://localhost:3000              | Dashboards (admin/admin)    |
| Jaeger UI           | http://localhost:16686             | Distributed traces          |
| Prometheus          | http://localhost:9090              | Metrics & queries           |
| Proxy Metrics       | http://localhost:8080/metrics      | Prometheus scrape endpoint  |
| Proxy Health        | http://localhost:8080/health       | Health check                |
| Recent Observations | http://localhost:8080/observations | JSON of recent requests     |

## Configuration

### Environment Variables

| Variable                      | Default                   | Description             |
| ----------------------------- | ------------------------- | ----------------------- |
| `MCP_UPSTREAM_URL`            | `http://localhost:8081`   | Upstream MCP server URL |
| `MCP_LISTEN_ADDR`             | `0.0.0.0:8080`            | Proxy listen address    |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | (none)                    | OTEL collector endpoint |
| `OTEL_SERVICE_NAME`           | `mcp-observability-proxy` | Service name in traces  |
| `RUST_LOG`                    | `mcp_proxy=info`          | Log level               |

### Client Headers

Add these headers to your MCP client requests for rich observability:

| Header             | Description              | Example                         |
| ------------------ | ------------------------ | ------------------------------- |
| `X-MCP-Client`     | Identifies the AI client | `claude-code`, `cursor`, `zed`  |
| `X-MCP-Experiment` | Experiment/A/B test ID   | `exp-gpt4-v-claude`, `rules-v2` |
| `X-MCP-Session`    | Session identifier       | `session-abc123`                |

## Configuring MCP Clients

### Claude Desktop / Claude Code

Edit your `claude_desktop_config.json`:

**Option A: HTTP Transport (if supported)**

```json
{
  "mcpServers": {
    "my-tool": {
      "url": "http://localhost:8080",
      "headers": {
        "X-MCP-Client": "claude-desktop",
        "X-MCP-Experiment": "baseline"
      }
    }
  }
}
```

**Option B: Stdio with Wrapper (recommended for Claude Code)**

Use the `mcp-stdio-wrapper` binary to wrap any stdio-based MCP server:

```json
{
  "mcpServers": {
    "github": {
      "command": "/path/to/mcp-stdio-wrapper",
      "args": [
        "--client",
        "claude-code",
        "--experiment",
        "baseline",
        "--",
        "npx",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "MCP_PROXY_URL": "http://localhost:8080/log",
        "GITHUB_TOKEN": "your-token"
      }
    }
  }
}
```

The wrapper transparently intercepts all JSON-RPC messages and logs them to the observability proxy while forwarding them to/from the actual MCP server.

### Cursor

In Cursor settings, configure your MCP endpoint to point to the proxy:

```json
{
  "mcp": {
    "servers": {
      "my-tool": {
        "url": "http://localhost:8080",
        "headers": {
          "X-MCP-Client": "cursor"
        }
      }
    }
  }
}
```

### Programmatic Clients

```python
import httpx

async with httpx.AsyncClient() as client:
    response = await client.post(
        "http://localhost:8080",
        headers={
            "X-MCP-Client": "my-app",
            "X-MCP-Experiment": "prompt-v2",
            "X-MCP-Session": "user-123",
        },
        json={
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {"name": "search", "arguments": {"query": "test"}},
            "id": 1
        }
    )
```

## Metrics

### Available Prometheus Metrics

| Metric                               | Type      | Labels                        | Description      |
| ------------------------------------ | --------- | ----------------------------- | ---------------- |
| `mcp_proxy_requests_total`           | Counter   | method, client, experiment    | Total requests   |
| `mcp_proxy_request_duration_seconds` | Histogram | method, client                | Request latency  |
| `mcp_proxy_tool_calls_total`         | Counter   | tool_name, client, experiment | Tool invocations |
| `mcp_proxy_tool_errors_total`        | Counter   | tool_name, client, error_code | Tool errors      |

### Example PromQL Queries

```promql
# Request rate by client
rate(mcp_proxy_requests_total[5m])

# P99 latency by tool
histogram_quantile(0.99, rate(mcp_proxy_request_duration_seconds_bucket[5m]))

# Error rate by tool
rate(mcp_proxy_tool_errors_total[5m]) / rate(mcp_proxy_tool_calls_total[5m])

# Compare experiments
sum by (experiment) (rate(mcp_proxy_requests_total{experiment!="none"}[5m]))
```

## Traces

Each MCP request creates a span with the following attributes:

| Attribute           | Description                                        |
| ------------------- | -------------------------------------------------- |
| `mcp.method`        | JSON-RPC method (e.g., `tools/call`, `tools/list`) |
| `mcp.client`        | Client identifier from header                      |
| `mcp.experiment`    | Experiment tag from header                         |
| `mcp.session_id`    | Session identifier from header                     |
| `mcp.tool.name`     | Tool name (for `tools/call`)                       |
| `mcp.status`        | Request status (success/error)                     |
| `mcp.duration_ms`   | Request duration in milliseconds                   |
| `mcp.request_size`  | Request body size in bytes                         |
| `mcp.response_size` | Response body size in bytes                        |

## Stdio Wrapper (mcp-stdio-wrapper)

Claude Code and many MCP clients use **stdio transport**, not HTTP. The `mcp-stdio-wrapper` binary solves this by wrapping any stdio-based MCP server and logging all communication to the observability proxy.

### How It Works

```
┌─────────────────┐     stdio      ┌──────────────────┐     stdio      ┌─────────────────┐
│   Claude Code   │◄──────────────►│ mcp-stdio-wrapper│◄──────────────►│  Actual MCP     │
│   (or any       │                │                  │                │  Server         │
│   MCP client)   │                │  Logs to proxy   │                │  (GitHub, etc)  │
└─────────────────┘                └────────┬─────────┘                └─────────────────┘
                                            │ async HTTP POST
                                            ▼
                                   ┌──────────────────┐
                                   │  Observability   │
                                   │  Proxy /log      │
                                   └──────────────────┘
```

### Installation

```bash
# Build from source
cargo build --release --bin mcp-stdio-wrapper

# Copy to PATH
cp target/release/mcp-stdio-wrapper /usr/local/bin/
```

### Usage

```bash
# Basic usage
mcp-stdio-wrapper --client claude-code -- npx @modelcontextprotocol/server-github

# With all options
mcp-stdio-wrapper \
  --proxy-url http://localhost:8080/log \
  --client claude-code \
  --experiment prompt-v2 \
  -- npx @modelcontextprotocol/server-github

# Using environment variables
MCP_PROXY_URL=http://localhost:8080/log \
MCP_CLIENT=cursor \
MCP_EXPERIMENT=baseline \
mcp-stdio-wrapper -- python my_mcp_server.py
```

### Configuration for Claude Code

In your Claude Code MCP configuration:

```json
{
  "mcpServers": {
    "github": {
      "command": "mcp-stdio-wrapper",
      "args": [
        "--client",
        "claude-code",
        "--experiment",
        "gpt4-comparison",
        "--",
        "npx",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "MCP_PROXY_URL": "http://localhost:8080/log",
        "GITHUB_TOKEN": "ghp_..."
      }
    },
    "filesystem": {
      "command": "mcp-stdio-wrapper",
      "args": [
        "--client",
        "claude-code",
        "--",
        "npx",
        "@modelcontextprotocol/server-filesystem",
        "/home/user/projects"
      ],
      "env": {
        "MCP_PROXY_URL": "http://localhost:8080/log"
      }
    }
  }
}
```

### What Gets Logged

For each JSON-RPC message, the wrapper sends:

| Field         | Description                                           |
| ------------- | ----------------------------------------------------- |
| `timestamp`   | Unix timestamp in milliseconds                        |
| `session_id`  | Unique session identifier (auto-generated)            |
| `client`      | Client name from `--client` or `MCP_CLIENT`           |
| `experiment`  | Experiment ID from `--experiment` or `MCP_EXPERIMENT` |
| `direction`   | `request` or `response`                               |
| `method`      | JSON-RPC method (e.g., `tools/call`)                  |
| `id`          | JSON-RPC message ID                                   |
| `tool_name`   | Tool name for `tools/call` requests                   |
| `duration_ms` | Round-trip time for responses                         |
| `is_error`    | Whether response contains an error                    |
| `raw`         | Full JSON-RPC message                                 |

## MCP HTTP Adapter

For MCP servers that need to run in HTTP mode (rather than using the stdio wrapper):

### Option 1: FastMCP HTTP Mode

If your MCP server is built with FastMCP:

```bash
fastmcp run myserver.py --transport http --port 8081
```

### Option 2: mcp-proxy (Official)

Use the official MCP proxy to bridge stdio to HTTP:

```bash
npx @anthropic/mcp-proxy --stdio "python myserver.py" --port 8081
```

### Option 3: Custom Bridge

For custom stdio servers, create a simple HTTP wrapper:

```python
# stdio_to_http.py
import subprocess
import json
from flask import Flask, request, jsonify

app = Flask(__name__)
proc = subprocess.Popen(
    ["python", "my_mcp_server.py"],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    text=True
)

@app.route("/", methods=["POST"])
def proxy():
    proc.stdin.write(json.dumps(request.json) + "\n")
    proc.stdin.flush()
    response = proc.stdout.readline()
    return jsonify(json.loads(response))

if __name__ == "__main__":
    app.run(port=8081)
```

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           AI Clients                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │Claude Code  │  │  Cursor     │  │    Zed      │  │  Custom     │     │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘     │
└─────────┼────────────────┼────────────────┼────────────────┼────────────┘
          │                │                │                │
          │ +headers       │ +headers       │ +headers       │ +headers
          │                │                │                │
          └────────────────┴────────┬───────┴────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │   MCP Observability Proxy     │
                    │         (Rust)                │
                    │                               │
                    │  • JSON-RPC parsing           │
                    │  • Metrics collection         │
                    │  • Trace generation           │
                    │  • Request/response logging   │
                    └───────────────┬───────────────┘
                                    │
          ┌─────────────────────────┼─────────────────────────┐
          │                         │                         │
          ▼                         ▼                         ▼
┌─────────────────┐    ┌───────────────────────┐    ┌─────────────────┐
│ OTEL Collector  │    │   Upstream MCP        │    │   Prometheus    │
│                 │    │   Server(s)           │    │   Scraper       │
└────────┬────────┘    └───────────────────────┘    └────────┬────────┘
         │                                                    │
         ▼                                                    ▼
┌─────────────────┐                                ┌─────────────────┐
│     Jaeger      │                                │   Prometheus    │
│   (Traces)      │                                │   (Metrics)     │
└────────┬────────┘                                └────────┬────────┘
         │                                                    │
         └──────────────────────┬─────────────────────────────┘
                                │
                                ▼
                    ┌───────────────────────────────┐
                    │          Grafana              │
                    │    (Unified Dashboard)        │
                    └───────────────────────────────┘
```

## Development

### Build Locally

```bash
# Build all binaries
cargo build --release

# HTTP proxy (for HTTP-based MCP servers)
MCP_UPSTREAM_URL=http://localhost:8081 \
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318 \
./target/release/mcp-observability-proxy

# Stdio wrapper (for stdio-based MCP servers like Claude Code uses)
./target/release/mcp-stdio-wrapper --client test -- npx @modelcontextprotocol/server-github
```

### Run Tests

```bash
cargo test
```

### Build Docker Image

```bash
docker build -t mcp-observability-proxy .
```

## Limitations

- **Token Usage**: Token counts are only captured if the upstream MCP server includes them in responses. Most MCP servers don't track tokens directly—that happens at the LLM provider level. To track tokens, you'd need to instrument the LLM client separately (e.g., with Langfuse's OpenAI wrapper).
- **HTTP Proxy - Single Upstream**: The HTTP proxy routes all traffic to one upstream. For multiple MCP servers, run multiple proxy instances or use the stdio wrapper approach.
- **Stdio Wrapper - Async Logging**: Log messages are sent asynchronously to avoid blocking MCP communication. Some messages may be lost if the proxy is unavailable.

## Future Enhancements

- [ ] Multi-upstream routing based on path/method
- [ ] WebSocket/SSE support for streaming responses
- [x] ~~Built-in stdio adapter~~ (mcp-stdio-wrapper)
- [ ] Langfuse native integration
- [ ] Request/response body sampling for debugging
- [ ] Rate limiting per client/experiment
- [ ] Authentication middleware
- [ ] Grafana dashboard templates
- [ ] Token usage extraction from common LLM response formats

## License

MIT
