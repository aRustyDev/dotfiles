# =============================================================================
# GitLab MCP Server - Streamable HTTP
# =============================================================================
# Wraps the official mcp/gitlab stdio server with supergateway to provide
# Streamable HTTP transport.
#
# Build:
#   docker build -f gitlab.dockerfile -t gitlab-mcp:http .
#
# Run:
#   docker run -p 8080:8080 -e GITLAB_PERSONAL_ACCESS_TOKEN=glpat-xxx gitlab-mcp:http
#
# Source: https://github.com/modelcontextprotocol/servers/tree/main/src/gitlab
# =============================================================================

FROM mcp/gitlab:latest

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

# Install supergateway globally
RUN npm install -g supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Override the base image entrypoint and run supergateway
ENTRYPOINT []
CMD supergateway \
    --stdio "node dist/index.js" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
