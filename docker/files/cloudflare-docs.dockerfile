# =============================================================================
# Cloudflare Docs MCP Server - HTTP Proxy
# =============================================================================
# Proxies Cloudflare's remote MCP servers through a local HTTP endpoint.
# Default: Documentation server. Can be configured for other CF services.
#
# Build:
#   docker build -f cloudflare-docs.dockerfile -t cloudflare-docs-mcp:http .
#
# Run:
#   docker run -p 8080:8080 cloudflare-docs-mcp:http
#
# Available Cloudflare MCP servers (set via CLOUDFLARE_MCP_URL):
#   - https://docs.mcp.cloudflare.com/mcp          (Documentation)
#   - https://bindings.mcp.cloudflare.com/mcp     (Workers Bindings)
#   - https://builds.mcp.cloudflare.com/mcp       (Workers Builds)
#   - https://observability.mcp.cloudflare.com/mcp (Logs/Analytics)
#   - https://radar.mcp.cloudflare.com/mcp        (Internet Insights)
#   - https://browser.mcp.cloudflare.com/mcp      (Browser Rendering)
#   - https://containers.mcp.cloudflare.com/mcp   (Sandbox Environments)
#
# Source: https://github.com/cloudflare/mcp-server-cloudflare
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

# Default to Cloudflare Documentation MCP server
ENV CLOUDFLARE_MCP_URL=https://docs.mcp.cloudflare.com/mcp

# Create app directory
WORKDIR /app

# Install mcp-remote and supergateway globally
RUN npm install -g @anthropic-ai/mcp-remote supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping mcp-remote connected to Cloudflare
CMD supergateway \
    --stdio "npx -y @anthropic-ai/mcp-remote ${CLOUDFLARE_MCP_URL}" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
