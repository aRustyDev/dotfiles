# =============================================================================
# char-index MCP Server - Streamable HTTP
# =============================================================================
# Wraps agent-hanju/char-index-mcp with supergateway to provide Streamable HTTP
# transport. Provides character-level index-based string manipulation for AI
# assistants - perfect for test code generation with precise positioning.
#
# Build:
#   docker build -f char-index.dockerfile -t char-index-mcp:http .
#
# Run:
#   docker run -p 8080:8080 char-index-mcp:http
#
# Source: https://github.com/agent-hanju/char-index-mcp
# PyPI: https://pypi.org/project/char-index-mcp/
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build/install the Python MCP server
# -----------------------------------------------------------------------------
FROM python:3.11-slim AS builder

# Install uv for fast package installation
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

WORKDIR /app

# Install char-index-mcp from PyPI
RUN uv pip install --system char-index-mcp

# -----------------------------------------------------------------------------
# Stage 2: Runtime image with supergateway
# -----------------------------------------------------------------------------
FROM python:3.11-slim

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

# Copy Python packages from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/char-index-mcp /usr/local/bin/char-index-mcp

WORKDIR /app

# Install supergateway globally
RUN npm install -g supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the char-index MCP server
CMD supergateway \
    --stdio "char-index-mcp" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
