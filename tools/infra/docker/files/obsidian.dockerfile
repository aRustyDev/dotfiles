# =============================================================================
# Obsidian MCP Server - Streamable HTTP
# =============================================================================
# Wraps MarkusPfundstein/mcp-obsidian with supergateway to provide
# Streamable HTTP transport. Connects to Obsidian via Local REST API plugin.
#
# Build:
#   docker build -f obsidian.dockerfile -t obsidian-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -e OBSIDIAN_API_KEY=your-api-key \
#     -e OBSIDIAN_HOST=host.docker.internal \
#     -e OBSIDIAN_PORT=27124 \
#     obsidian-mcp:http
#
# Prerequisites:
#   - Obsidian running with Local REST API plugin enabled
#   - Plugin: https://github.com/coddingtonbear/obsidian-local-rest-api
#
# Source: https://github.com/MarkusPfundstein/mcp-obsidian
# =============================================================================

FROM python:3.12-slim

# -----------------------------------------------------------------------------
# Build Arguments
# -----------------------------------------------------------------------------
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=60000

# -----------------------------------------------------------------------------
# Environment Variables (can be overridden at runtime)
# -----------------------------------------------------------------------------
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# Obsidian connection (override at runtime)
ENV OBSIDIAN_API_KEY=
ENV OBSIDIAN_HOST=host.docker.internal
ENV OBSIDIAN_PORT=27124

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install uv package manager
RUN pip install --no-cache-dir uv

# Install mcp-obsidian
RUN uv pip install --system mcp-obsidian

# Install supergateway globally
RUN npm install -g supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping mcp-obsidian
CMD supergateway \
    --stdio "mcp-obsidian" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
