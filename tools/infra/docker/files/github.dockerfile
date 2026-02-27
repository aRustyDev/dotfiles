# =============================================================================
# GitHub MCP Server - Streamable HTTP
# =============================================================================
# Wraps the official GitHub MCP server with supergateway to provide
# Streamable HTTP transport.
#
# Build:
#   docker build -f github.dockerfile -t github-mcp:http .
#
# Run:
#   docker run -p 8080:8080 -e GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxx github-mcp:http
#
# Source: https://github.com/github/github-mcp-server
# =============================================================================

# Stage 1: Get the GitHub MCP server binary
FROM ghcr.io/github/github-mcp-server:latest AS github-mcp

# Stage 2: Build the HTTP wrapper
FROM node:22-alpine

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

# Copy the GitHub MCP server binary from the first stage
COPY --from=github-mcp /server/github-mcp-server /usr/local/bin/github-mcp-server

# Make it executable
RUN chmod +x /usr/local/bin/github-mcp-server

# Install supergateway globally
RUN npm install -g supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the GitHub MCP server
CMD supergateway \
    --stdio "github-mcp-server stdio" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
