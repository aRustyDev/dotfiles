# =============================================================================
# Task Master AI MCP Server - Streamable HTTP
# =============================================================================
# Wraps task-master-ai with supergateway to provide Streamable HTTP transport.
# AI-driven task management system with PRD parsing, complexity analysis,
# and multi-provider LLM support.
#
# Build:
#   docker build -f task-master.dockerfile -t task-master-ai:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -e ANTHROPIC_API_KEY=your-key \
#     -v $(pwd)/.taskmaster:/app/.taskmaster \
#     task-master-ai:http
#
# Source: https://github.com/eyaltoledano/claude-task-master
# NPM: https://www.npmjs.com/package/task-master-ai
# =============================================================================

FROM node:22-alpine

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=120000

# Environment Variables (can be overridden at runtime)
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# Task Master requires git for some operations
RUN apk add --no-cache git

WORKDIR /app

# Install task-master-ai and supergateway globally
RUN npm install -g task-master-ai supergateway

# Create directories for task storage
RUN mkdir -p /app/.taskmaster /app/projects

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the Task Master AI MCP server
CMD supergateway \
    --stdio "task-master-ai" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
