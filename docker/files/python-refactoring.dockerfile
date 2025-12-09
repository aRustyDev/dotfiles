# =============================================================================
# Python Refactoring MCP Server - Streamable HTTP
# =============================================================================
# Wraps brukhabtu/rope-mcp with supergateway to provide Streamable HTTP
# transport. Enables AI assistants to perform Python code refactoring using
# the Rope library.
#
# Build:
#   docker build -f python-refactoring.dockerfile -t python-refactoring-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -v /path/to/python/project:/workspaces/project \
#     python-refactoring-mcp:http
#
# Source: https://github.com/brukhabtu/rope-mcp
# Rope Library: https://github.com/python-rope/rope
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build the Python MCP server
# -----------------------------------------------------------------------------
FROM python:3.12-slim AS builder

WORKDIR /build

# Install git and build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone the rope-mcp repository
RUN git clone --depth 1 https://github.com/brukhabtu/rope-mcp.git .

# Install poetry and build wheel
RUN pip install --no-cache-dir poetry && \
    poetry config virtualenvs.create false && \
    poetry build -f wheel

# -----------------------------------------------------------------------------
# Stage 2: Runtime image with supergateway
# -----------------------------------------------------------------------------
FROM python:3.12-slim

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=60000

# Environment Variables (can be overridden at runtime)
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# Install Node.js for supergateway
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install supergateway globally
RUN npm install -g supergateway

# Copy and install the wheel from builder
COPY --from=builder /build/dist/*.whl /tmp/
RUN pip install --no-cache-dir /tmp/*.whl && rm /tmp/*.whl

# Create workspace directory for Python projects
RUN mkdir -p /workspaces
WORKDIR /workspaces

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the rope-mcp server
# rope-mcp-server is the entry point from pyproject.toml
CMD supergateway \
    --stdio "rope-mcp-server" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
