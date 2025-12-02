# =============================================================================
# Fetch MCP Server - Streamable HTTP
# =============================================================================
# Wraps the official mcp/fetch stdio server with supergateway to provide
# Streamable HTTP transport.
#
# Build:
#   docker build -f fetch.dockerfile -t fetch-mcp:http .
#
# Run:
#   docker run -p 8080:8080 fetch-mcp:http
#
# Source: https://github.com/modelcontextprotocol/servers/tree/main/src/fetch
# =============================================================================

FROM mcp/fetch:latest

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

# Install Node.js (Debian-based image)
RUN apt-get update && apt-get install -y --no-install-recommends nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Install supergateway globally
RUN npm install -g supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Override entrypoint and run supergateway
ENTRYPOINT []
CMD supergateway \
    --stdio "mcp-server-fetch" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
