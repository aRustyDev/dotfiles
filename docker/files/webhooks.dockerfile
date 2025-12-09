# =============================================================================
# Webhook Tester MCP Server - Streamable HTTP
# =============================================================================
# Wraps webhook-tester-mcp with supergateway to provide Streamable HTTP transport.
# Interacts with webhook-test.com to create, manage, and inspect webhooks for
# testing and debugging webhook integrations.
#
# Build:
#   docker build -f webhooks.dockerfile -t webhooks-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -e WEBHOOK_TESTER_API_KEY=your_api_key \
#     -e WEBHOOK_TESTER_BASE_URL=https://api.webhook-test.com \
#     webhooks-mcp:http
#
# Source: https://github.com/alimo7amed93/webhook-tester-mcp
# =============================================================================

FROM node:22-alpine

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=120000

# Environment Variables
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# Webhook Tester API configuration (must be provided at runtime)
ENV WEBHOOK_TESTER_API_KEY=""
ENV WEBHOOK_TESTER_BASE_URL="https://api.webhook-test.com"

# Install Python and git
RUN apk add --no-cache python3 py3-pip git

WORKDIR /app

# Clone the webhook-tester-mcp repository
RUN git clone --depth 1 https://github.com/alimo7amed93/webhook-tester-mcp.git .

# Install Python dependencies
RUN pip3 install --no-cache-dir --break-system-packages \
    fastmcp \
    httpx \
    python-dotenv

# Install supergateway globally
RUN npm install -g supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping webhook-tester-mcp
CMD supergateway \
    --stdio "fastmcp run /app/server.py" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
