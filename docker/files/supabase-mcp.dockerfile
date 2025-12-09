# =============================================================================
# Supabase MCP Server - Streamable HTTP
# =============================================================================
# Wraps self-hosted Supabase MCP server with supergateway to provide
# Streamable HTTP transport. Enables AI assistants to interact with
# self-hosted Supabase instances.
#
# Build:
#   docker build -f supabase-mcp.dockerfile -t supabase-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -e SUPABASE_URL=http://localhost:8000 \
#     -e SUPABASE_ANON_KEY=your-anon-key \
#     supabase-mcp:http
#
# Source: https://github.com/HenkDz/selfhosted-supabase-mcp
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

# Required: Supabase connection details
ENV SUPABASE_URL=
ENV SUPABASE_ANON_KEY=

# Optional: Elevated access
ENV SUPABASE_SERVICE_ROLE_KEY=
ENV DATABASE_URL=
ENV SUPABASE_AUTH_JWT_SECRET=

# Create app directory
WORKDIR /app

# Clone and build the self-hosted Supabase MCP server
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone --depth 1 https://github.com/HenkDz/selfhosted-supabase-mcp.git .

# Install dependencies and build
RUN npm install && npm run build

# Install supergateway globally
RUN npm install -g supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the Supabase MCP server
# Note: Server reads env vars directly, CLI args are optional overrides
CMD supergateway \
    --stdio "node dist/index.js" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
