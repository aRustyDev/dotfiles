# =============================================================================
# Sequential Thinking Tools MCP Server - Streamable HTTP
# =============================================================================
# Wraps spences10/mcp-sequentialthinking-tools with supergateway to provide
# Streamable HTTP transport. Guides tool usage at each reasoning step,
# helping LLMs decide which MCP tools to call during chain-of-thought.
#
# Build:
#   docker build -f sequentialthinking-tools.dockerfile -t sequentialthinking-tools-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -e MAX_HISTORY_SIZE=1000 \
#     sequentialthinking-tools-mcp:http
#
# Source: https://github.com/spences10/mcp-sequentialthinking-tools
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build the TypeScript MCP server
# -----------------------------------------------------------------------------
FROM node:22-alpine AS builder

WORKDIR /build

# Install git and pnpm
RUN apk add --no-cache git && \
    corepack enable && \
    corepack prepare pnpm@latest --activate

# Clone the repository
RUN git clone --depth 1 https://github.com/spences10/mcp-sequentialthinking-tools.git .

# Install dependencies and build
RUN pnpm install --frozen-lockfile
RUN pnpm build

# -----------------------------------------------------------------------------
# Stage 2: Runtime image with supergateway
# -----------------------------------------------------------------------------
FROM node:22-alpine

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=60000
ARG MAX_HISTORY_SIZE=1000

# Environment Variables (can be overridden at runtime)
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}
ENV MAX_HISTORY_SIZE=${MAX_HISTORY_SIZE}
ENV NODE_ENV=production

WORKDIR /app

# Copy built application from builder
COPY --from=builder /build/dist /app/dist
COPY --from=builder /build/package.json /app/package.json

# Install production dependencies and supergateway
RUN npm install --omit=dev && \
    npm install -g supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the sequentialthinking-tools MCP server
CMD supergateway \
    --stdio "node /app/dist/index.js" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
