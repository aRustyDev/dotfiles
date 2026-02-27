# =============================================================================
# Todoist MCP Server - Streamable HTTP
# =============================================================================
# Wraps abhiz123/todoist-mcp-server with supergateway to provide Streamable HTTP
# transport. Enables natural language task management with Todoist via AI.
#
# Build:
#   docker build -f todoist.dockerfile -t todoist-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -e TODOIST_API_TOKEN=your-token \
#     todoist-mcp:http
#
# Source: https://github.com/abhiz123/todoist-mcp-server
# NPM: https://www.npmjs.com/package/@abhiz123/todoist-mcp-server
# =============================================================================

FROM node:20-alpine

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=60000

# Environment Variables (can be overridden at runtime)
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

WORKDIR /app

# Install todoist-mcp-server and supergateway globally
RUN npm install -g @abhiz123/todoist-mcp-server supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the Todoist MCP server
CMD supergateway \
    --stdio "todoist-mcp-server" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
