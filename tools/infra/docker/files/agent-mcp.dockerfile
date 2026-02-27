# --- --- --- --- --- --- --- --- --- --- ---
# | === === === [ Clone Repo ] === === === |
# --- --- --- --- --- --- --- --- --- --- ---
FROM python:3.12-slim AS repo
SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/rinadelph/Agent-MCP /app
WORKDIR /app

# --- --- --- --- --- --- --- --- --- --- ---
# === === === [ Server: Python ] === === ===
# --- --- --- --- --- --- --- --- --- --- ---
FROM python:3.12-slim AS python

# Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build-time configuration (non-sensitive)
ARG PORT="8080"
ARG AGENT_MCP_HOST="0.0.0.0"
ARG AGENT_MCP_PORT="8000"
ARG MCP_SERVER_URL="http://localhost:8080/messages"
ARG MCP_PROJECT_DIR="/workspace"
ARG AGENT_MCP_LOG_LEVEL="INFO"
ARG AGENT_MCP_MAX_AGENTS="10"
ARG AGENT_MCP_SKIP_TUI="false"
ARG AGENT_MCP_ENABLE_RAG="true"
ARG AGENT_MCP_ENABLE_AGENTS="true"
ARG MCP_DEBUG="false"
ARG CI="false"
ARG DISABLE_AUTO_INDEXING="false"

# Runtime environment variables
# IMPORTANT: Secrets should be provided at runtime using:
#   docker run -e OPENAI_API_KEY=your-key ...
#   or via docker-compose secrets
ENV PORT="${PORT}" \
    AGENT_MCP_HOST="${AGENT_MCP_HOST}" \
    AGENT_MCP_PORT="${AGENT_MCP_PORT}" \
    MCP_SERVER_URL="${MCP_SERVER_URL}" \
    MCP_PROJECT_DIR="${MCP_PROJECT_DIR}" \
    AGENT_MCP_LOG_LEVEL="${AGENT_MCP_LOG_LEVEL}" \
    AGENT_MCP_MAX_AGENTS="${AGENT_MCP_MAX_AGENTS}" \
    AGENT_MCP_SKIP_TUI="${AGENT_MCP_SKIP_TUI}" \
    AGENT_MCP_ENABLE_RAG="${AGENT_MCP_ENABLE_RAG}" \
    AGENT_MCP_ENABLE_AGENTS="${AGENT_MCP_ENABLE_AGENTS}" \
    MCP_DEBUG="${MCP_DEBUG}" \
    CI="${CI}" \
    DISABLE_AUTO_INDEXING="${DISABLE_AUTO_INDEXING}"

# Secrets (must be provided at runtime - NOT stored in image)
ENV OPENAI_API_KEY="" \
    MCP_ADMIN_TOKEN=""

# Install system dependencies and uv
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir uv

WORKDIR /app

# Copy Python project files
COPY --from=repo /app/pyproject.toml /app/pyproject.toml
COPY --from=repo /app/agent_mcp/ /app/agent_mcp/

# Create virtual environment and install dependencies
# uv sync reads from pyproject.toml (no lock file in repo yet)
RUN uv venv && uv sync

# Create workspace directory for project files
RUN mkdir -p ${MCP_PROJECT_DIR}

EXPOSE ${PORT} ${AGENT_MCP_PORT}

# uv run automatically activates the venv
ENTRYPOINT ["uv", "run", "-m", "agent_mcp.cli", "--transport", "sse", "--no-tui"]
CMD ["--port", "8080", "--project-dir", "/workspace"]

# --- --- --- --- --- --- --- --- --- --- ---
# | === === === [ Server: Node ] === === === |
# --- --- --- --- --- --- --- --- --- --- ---
FROM node:20-slim AS node
WORKDIR /app

# Install build dependencies for native modules (better-sqlite3)
# and curl for health checks
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Node server package files
COPY --from=repo /app/agent-mcp-node/package*.json /app/

# Copy Node server source code (needed before npm ci due to postinstall script)
COPY --from=repo /app/agent-mcp-node/ /app/

# Install ALL dependencies including devDependencies (needed for TypeScript compilation)
# Skip postinstall as build doesn't exist yet
RUN npm ci --ignore-scripts

# Build TypeScript to JavaScript
RUN npm run build

# Make the server executable (what postinstall would have done)
RUN chmod +x build/examples/server/agentMcpServer.js 2>/dev/null || true

# Remove devDependencies to reduce image size (keep only production deps)
RUN npm prune --omit=dev

# Create workspace directory for project files
RUN mkdir -p /workspace

# Expose MCP server port
EXPOSE 8080

# Health check for MCP server
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Secrets (must be provided at runtime)
ENV OPENAI_API_KEY="" \
    MCP_ADMIN_TOKEN=""

# Run the Node MCP server
CMD ["node", "build/index.js", "--port", "8080", "--project-dir", "/workspace", "--no-tui"]

#  --- --- --- --- --- --- --- --- --- --- --- ---
# | === === === === [ Dashboard ] === === === === |
#  --- --- --- --- --- --- --- --- --- --- --- ---
FROM node:20-slim AS dashboard
WORKDIR /app

# Install curl for health checks
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy ONLY dashboard package files
COPY --from=repo /app/agent_mcp/dashboard/package*.json /app/

# Install all dependencies (Next.js needs devDependencies to build)
RUN npm ci

# Copy ONLY dashboard source code
COPY --from=repo /app/agent_mcp/dashboard/ /app/

# Build Next.js application for production
RUN npm run build

# Remove devDependencies after build to reduce image size
RUN npm prune --omit=dev

# Expose Next.js default port
EXPOSE 3000

# Health check for Next.js application
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Run Next.js production server
CMD ["npm", "start"]

# --- --- --- --- --- --- --- --- --- --- --- ---
# === === === [ Server + Dashboard ] === === ===
# --- --- --- --- --- --- --- --- --- --- --- ---
FROM node:20-slim AS combined
WORKDIR /app

# Install system dependencies for native modules and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install pm2 globally for process management
RUN npm install -g pm2

# Set up Node server
WORKDIR /app/server
COPY --from=repo /app/agent-mcp-node/package*.json /app/server/
COPY --from=repo /app/agent-mcp-node/ /app/server/
RUN npm ci --ignore-scripts && npm run build && npm prune --omit=dev

# Set up Dashboard
WORKDIR /app/dashboard
COPY --from=repo /app/agent_mcp/dashboard/package*.json /app/dashboard/
COPY --from=repo /app/agent_mcp/dashboard/ /app/dashboard/
RUN npm ci && npm run build && npm prune --omit=dev

# Create workspace directory
RUN mkdir -p /workspace

# Create pm2 ecosystem file for managing both processes
RUN echo '{\n\
  "apps": [\n\
    {\n\
      "name": "mcp-server",\n\
      "cwd": "/app/server",\n\
      "script": "node",\n\
      "args": "build/index.js --port 8080 --project-dir /workspace --no-tui",\n\
      "env": {\n\
        "NODE_ENV": "production"\n\
      }\n\
    },\n\
    {\n\
      "name": "dashboard",\n\
      "cwd": "/app/dashboard",\n\
      "script": "npm",\n\
      "args": "start",\n\
      "env": {\n\
        "NODE_ENV": "production"\n\
      }\n\
    }\n\
  ]\n\
}' > /app/ecosystem.config.json

# Expose both ports
EXPOSE 8080 3000

# Health check (checks both services)
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8080/health && curl -f http://localhost:3000/ || exit 1

# Secrets (must be provided at runtime)
ENV OPENAI_API_KEY="" \
    MCP_ADMIN_TOKEN=""

WORKDIR /app

# Start both services with pm2
CMD ["pm2-runtime", "start", "ecosystem.config.json"]
