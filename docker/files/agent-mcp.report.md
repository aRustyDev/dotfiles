# Agent-MCP Containerization Analysis

Based on my analysis of the [Agent-MCP repository](https://github.com/rinadelph/Agent-MCP), here's a comprehensive guide for containerizing this multi-agent AI collaboration system.

## Architecture Overview

Agent-MCP consists of **two main components** that should be containerized separately:

1. **MCP Server** (Backend) - Provides the Model Context Protocol endpoints, agent management, and RAG functionality
2. **Dashboard** (Frontend) - Next.js visualization interface for monitoring agents, tasks, and memory

### Communication Flow

```
Dashboard (Next.js) --HTTP--> MCP Server (Python/Node.js) --MCP Protocol--> AI Assistants
                                    |
                                    v
                            SQLite Database (.agent/mcp_state.db)
```

## Should Dashboard and Server Be Separate Containers?

**YES - They MUST be separate containers** for these reasons:

1. **Different runtimes**: Dashboard requires Node.js/Next.js, Server can be Python or Node.js
2. **Different lifecycles**: Server must run continuously, Dashboard is a web UI that can scale independently
3. **Optional deployment**: Dashboard is optional (server works standalone), allowing flexible deployment
4. **Resource allocation**: Dashboard (UI) and Server (compute-heavy RAG/embeddings) have different resource needs
5. **Network boundaries**: Dashboard is public-facing, Server should be internal with controlled access

## Environment Variables

### Required Variables

| Variable         | Purpose                               | Used By | Default        |
| ---------------- | ------------------------------------- | ------- | -------------- |
| `OPENAI_API_KEY` | OpenAI API key for embeddings and RAG | Server  | N/A (required) |

### Optional Variables

| Variable                  | Purpose                    | Used By   | Default                         | Notes                       |
| ------------------------- | -------------------------- | --------- | ------------------------------- | --------------------------- |
| `PORT`                    | Server port                | Server    | 8080                            | HTTP/SSE endpoint           |
| `AGENT_MCP_HOST`          | Server bind address        | Server    | 0.0.0.0                         | Listen on all interfaces    |
| `AGENT_MCP_PORT`          | Alternative port setting   | Server    | 8000                            | Node.js default             |
| `MCP_SERVER_URL`          | Backend server URL         | Dashboard | http://localhost:8080/messages/ | Connection endpoint         |
| `MCP_ADMIN_TOKEN`         | Pre-set admin token        | Server    | Auto-generated                  | Authentication token        |
| `MCP_PROJECT_DIR`         | Default project directory  | Server    | . (current)                     | Where .agent folder lives   |
| `AGENT_MCP_LOG_LEVEL`     | Logging verbosity          | Server    | INFO                            | DEBUG, INFO, WARNING, ERROR |
| `AGENT_MCP_MAX_AGENTS`    | Max concurrent agents      | Server    | 10                              | Hard limit on agents        |
| `AGENT_MCP_SKIP_TUI`      | Skip terminal UI           | Server    | false                           | Set true for containers     |
| `AGENT_MCP_ENABLE_RAG`    | Override RAG setting       | Server    | true                            | Enable/disable RAG          |
| `AGENT_MCP_ENABLE_AGENTS` | Override agent management  | Server    | true                            | Enable/disable agents       |
| `MCP_DEBUG`               | Debug mode                 | Server    | false                           | Verbose logging             |
| `CI`                      | CI environment detection   | Server    | false                           | Auto-skips TUI              |
| `DISABLE_AUTO_INDEXING`   | Disable auto file indexing | Server    | false                           | Manual indexing only        |

## CLI Arguments Not Settable via Environment Variables

### Python Server (`agent_mcp.cli`)

**Cannot be set via ENV:**

- `--transport` (stdio|sse) - **No ENV equivalent** - Critical for deployment mode
- `--advanced` - **No ENV equivalent** - Enables 3072-dim embeddings vs 1536-dim
- `--git` - **No ENV equivalent** - Experimental Git worktree support

**Can be set via ENV:**

- `--port` → `PORT`
- `--debug` → `MCP_DEBUG`
- `--no-tui` → `AGENT_MCP_SKIP_TUI` or `CI`
- `--no-index` → `DISABLE_AUTO_INDEXING`

### Node.js Server (`agent-mcp-node`)

**Cannot be set via ENV:**

- `--mode` (full|memoryRag|minimal|development|background) - **No ENV equivalent** - Tool configuration preset
- `--config-mode` - **No ENV equivalent** - Interactive TUI configuration

**Can be set via ENV:**

- `--port` → Auto-detected or PORT
- `--no-tui` → `AGENT_MCP_SKIP_TUI` or `CI`
- RAG/Agent flags → `AGENT_MCP_ENABLE_RAG`, `AGENT_MCP_ENABLE_AGENTS`

### Docker Implications

For containerization, you'll need to:

1. **Set `--transport sse`** explicitly in Dockerfile CMD (can't use stdio in container)
2. **Set `--no-tui`** or `CI=true` environment variable (no TTY in containers)
3. **Choose embedding mode** (`--advanced` flag) at build time, not runtime
4. **Choose tool mode** (`--mode`) for Node.js at build time or use saved config

## Dependencies

### Python Server Dependencies

**Runtime Requirements:**

- Python: `>=3.10`
- SQLite3 with vector search extension (sqlite-vec)

**Python Packages** (from `pyproject.toml` and `requirements.txt`):

```
anyio
click
openai>=1.0.0
starlette
uvicorn
jinja2
python-dotenv
sqlite-vec
httpx
tabulate
pyperclip
mcp>=1.8.1
requests
```

**Development (optional):**

```
pytest>=8.3.2
pytest-asyncio
black
isort
ruff>=0.5.5
```

**System Dependencies:**

- Build tools for sqlite-vec (gcc, make)
- Git (if using `--git` worktree support)

### Node.js Server Dependencies

**Runtime Requirements:**

- Node.js: `>=18.0.0`
- npm: `>=9.0.0`

**NPM Packages** (from `agent-mcp-node/package.json`):

```json
{
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.4.0",
    "@types/better-sqlite3": "^7.6.13",
    "better-sqlite3": "^12.2.0",
    "commander": "^14.0.0",
    "cors": "^2.8.5",
    "dotenv": "^17.2.1",
    "express": "^4.18.2",
    "glob": "^11.0.3",
    "inquirer": "^12.9.4",
    "openai": "^5.11.0",
    "sqlite-vec": "^0.1.7-alpha.2",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/node": "^22.10.0",
    "tsx": "^4.7.0",
    "typescript": "^5.7.2"
  }
}
```

**System Dependencies:**

- Build tools for better-sqlite3 (node-gyp, python3, gcc)

### Dashboard Dependencies

**Runtime Requirements:**

- Node.js: `>=18.0.0` (recommended 22.16.0)
- npm: `>=9.0.0` (recommended 10.9.2)

**NPM Packages** (from `agent_mcp/dashboard/package.json`):

```json
{
  "dependencies": {
    "@radix-ui/react-*": "Various versions",
    "@tanstack/react-query": "^5.81.2",
    "next": "15.3.4",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "vis-network": "^9.1.12",
    "zustand": "^5.0.5",
    "recharts": "^3.0.0",
    "lucide-react": "^0.523.0",
    "framer-motion": "^12.19.1"
  },
  "devDependencies": {
    "typescript": "^5",
    "tailwindcss": "^4",
    "eslint": "^9"
  }
}
```

## Building with NPM vs UV

### Python Server with UV (Recommended)

```bash
# Development
uv venv
uv install  # Reads pyproject.toml
uv run -m agent_mcp.cli --port 8080 --project-dir /app/data

# Container approach
FROM python:3.11-slim
RUN pip install uv
WORKDIR /app
COPY pyproject.toml .
COPY agent_mcp/ agent_mcp/
RUN uv venv && uv install
CMD ["uv", "run", "-m", "agent_mcp.cli", "--port", "8080", "--transport", "sse", "--no-tui"]
```

### Node.js Server with NPM

```bash
# Development
cd agent-mcp-node
npm install
npm run build  # Compiles TypeScript to build/
npm start      # Runs compiled JavaScript

# Container approach
FROM node:18-slim
WORKDIR /app
COPY agent-mcp-node/package*.json ./
RUN npm ci --production
COPY agent-mcp-node/ .
RUN npm run build
CMD ["node", "build/examples/server/agentMcpServer.js", "--port", "8080", "--no-tui"]
```

### Dashboard with NPM

```bash
# Development
cd agent_mcp/dashboard
npm install
npm run dev  # Development server on port 3000

# Production build
npm run build
npm start  # Production server

# Container approach
FROM node:18-slim
WORKDIR /app
COPY agent_mcp/dashboard/package*.json ./
RUN npm ci --production
COPY agent_mcp/dashboard/ .
RUN npm run build
CMD ["npm", "start"]
```

## Recommended Container Architecture

### Option 1: Python Server + Dashboard (Recommended)

```yaml
# docker-compose.yml
version: "3.8"

services:
  mcp-server:
    build:
      context: .
      dockerfile: Dockerfile.server.python
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - PORT=8080
      - AGENT_MCP_SKIP_TUI=true
      - MCP_DEBUG=false
      - AGENT_MCP_MAX_AGENTS=10
    volumes:
      - agent-data:/app/data # Persistent .agent directory
      - project-data:/app/project # Project files for RAG
    ports:
      - "8080:8080"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

  dashboard:
    build:
      context: .
      dockerfile: Dockerfile.dashboard
    environment:
      - MCP_SERVER_URL=http://mcp-server:8080/messages/
    ports:
      - "3847:3000"
    depends_on:
      - mcp-server
    restart: unless-stopped

volumes:
  agent-data:
  project-data:
```

### Option 2: Node.js Server + Dashboard

Replace `Dockerfile.server.python` with `Dockerfile.server.node` and adjust the server service accordingly.

## Sample Dockerfiles

### Dockerfile.server.python

```dockerfile
FROM python:3.11-slim

# Install system dependencies for sqlite-vec
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install UV
RUN pip install --no-cache-dir uv

WORKDIR /app

# Copy project files
COPY pyproject.toml requirements.txt ./
COPY agent_mcp/ agent_mcp/

# Create virtual environment and install dependencies
RUN uv venv && uv install

# Create data directory for persistent storage
RUN mkdir -p /app/data

# Expose server port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Run server (SSE mode, no TUI, port 8080)
CMD ["uv", "run", "-m", "agent_mcp.cli", \
     "--port", "8080", \
     "--transport", "sse", \
     "--project-dir", "/app/data", \
     "--no-tui"]
```

### Dockerfile.server.node

```dockerfile
FROM node:18-slim

# Install build dependencies for better-sqlite3
RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY agent-mcp-node/package*.json ./

# Install dependencies
RUN npm ci --production

# Copy source code
COPY agent-mcp-node/ .

# Build TypeScript
RUN npm run build

# Create data directory
RUN mkdir -p /app/data

# Expose server port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Run server
CMD ["node", "build/examples/server/agentMcpServer.js", \
     "--port", "8080", \
     "--host", "0.0.0.0", \
     "--project-dir", "/app/data", \
     "--no-tui"]
```

### Dockerfile.dashboard

```dockerfile
FROM node:18-slim

WORKDIR /app

# Copy package files
COPY agent_mcp/dashboard/package*.json ./

# Install dependencies
RUN npm ci --production

# Copy dashboard source
COPY agent_mcp/dashboard/ .

# Build Next.js application
RUN npm run build

# Expose dashboard port
EXPOSE 3000

# Health check (Next.js health endpoint)
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Run production server
CMD ["npm", "start"]
```

## Key Containerization Considerations

### 1. Data Persistence

- Mount volumes for `/app/data` (contains `.agent/mcp_state.db`)
- Consider backing up SQLite database periodically
- Project files may need to be mounted if RAG indexing is required

### 2. Networking

- Server must expose port 8080 (or configured PORT)
- Dashboard must be able to reach server (use Docker service names)
- Dashboard exposes port 3000 (mapped to host 3847 typically)

### 3. Environment Configuration

- **Always set**: `AGENT_MCP_SKIP_TUI=true` or `CI=true` (no TTY in containers)
- **Always set**: `--transport sse` for Python server (stdio won't work)
- **Required**: `OPENAI_API_KEY` for embeddings
- **Security**: Use secrets management for API keys, not plain ENV vars in production

### 4. Resource Requirements

- **Server**: 2GB RAM minimum (4GB+ recommended with RAG)
- **Dashboard**: 1GB RAM minimum
- **Storage**: 1GB minimum for database + indexed content

### 5. Startup Sequence

1. Server must start first and initialize database
2. Dashboard waits for server health check
3. Admin token is auto-generated on first run (check logs or database)

## Production Deployment Checklist

- [ ] Use multi-stage builds to reduce image size
- [ ] Set resource limits (CPU/memory)
- [ ] Configure log aggregation (server logs to stdout)
- [ ] Use secrets management for `OPENAI_API_KEY`
- [ ] Set up database backups for `.agent/mcp_state.db`
- [ ] Configure reverse proxy (nginx/traefik) for dashboard
- [ ] Enable HTTPS for production
- [ ] Set `MCP_DEBUG=false` in production
- [ ] Monitor server health endpoint (`/health`)
- [ ] Set appropriate `AGENT_MCP_MAX_AGENTS` based on resources
- [ ] Consider read-only filesystem with specific writable volumes
- [ ] Use non-root user in containers

## Summary

**Architecture**: Two separate containers (Server + Dashboard)

**Required ENV**: `OPENAI_API_KEY`

**Critical CLI Args**: `--transport sse`, `--no-tui`, `--project-dir`

**Build Approaches**:

- Python: UV (recommended) or pip
- Node.js: npm (standard)
- Dashboard: npm build + npm start

**Key Dependencies**:

- Python: openai, starlette, uvicorn, sqlite-vec, mcp
- Node.js: @modelcontextprotocol/sdk, express, better-sqlite3, openai
- Dashboard: Next.js 15, React 19, Radix UI

This analysis should provide everything needed to successfully containerize Agent-MCP!
