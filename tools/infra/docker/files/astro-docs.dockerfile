# =============================================================================
# Astro Docs MCP Server - HTTP Proxy
# =============================================================================
# Proxies the remote Astro Docs MCP server through a local HTTP endpoint.
# Uses mcp-remote to bridge the remote server to local supergateway.
#
# Build:
#   docker build -f astro-docs.dockerfile -t astro-docs-mcp:http .
#
# Run:
#   docker run -p 8080:8080 astro-docs-mcp:http
#
# Remote server: https://mcp.docs.astro.build/mcp
# Source: https://github.com/withastro/docs-mcp
# =============================================================================

FROM node:20-slim

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
ENV NODE_ENV=production

# Remote Astro Docs MCP server URL
ENV ASTRO_DOCS_MCP_URL=https://mcp.docs.astro.build/mcp

# Create app directory
WORKDIR /app

# Install mcp-remote and supergateway globally
RUN npm install -g @anthropic-ai/mcp-remote supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping mcp-remote connected to Astro docs
CMD supergateway \
    --stdio "npx -y @anthropic-ai/mcp-remote ${ASTRO_DOCS_MCP_URL}" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
