# =============================================================================
# Code Reasoning MCP Server - Streamable HTTP
# =============================================================================
# Wraps mettamatt/code-reasoning with supergateway to provide Streamable HTTP
# transport. Enables AI assistants to perform structured, step-by-step
# reasoning for complex programming tasks.
#
# Build:
#   docker build -f code-reasoning.dockerfile -t code-reasoning-mcp:http .
#
# Run:
#   docker run -p 8080:8080 code-reasoning-mcp:http
#
# Source: https://github.com/mettamatt/code-reasoning
# Based on: Anthropic's sequential-thinking MCP server
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build the TypeScript MCP server
# -----------------------------------------------------------------------------
FROM node:22-alpine AS builder

WORKDIR /build

# Install git for cloning
RUN apk add --no-cache git

# Clone the code-reasoning repository
RUN git clone --depth 1 https://github.com/mettamatt/code-reasoning.git .

# Install dependencies and build
RUN --mount=type=cache,target=/root/.npm npm ci
RUN npm run build

# -----------------------------------------------------------------------------
# Stage 2: Runtime image with supergateway
# -----------------------------------------------------------------------------
FROM node:22-alpine

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=60000

# Environment Variables (can be overridden at runtime)
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}
ENV NODE_ENV=production

WORKDIR /app

# Copy built application from builder
COPY --from=builder /build/dist /app/dist
COPY --from=builder /build/package.json /app/package.json
COPY --from=builder /build/package-lock.json /app/package-lock.json

# Install production dependencies and supergateway
RUN npm ci --ignore-scripts --omit-dev && \
    npm install -g supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the code-reasoning MCP server
CMD supergateway \
    --stdio "node /app/dist/index.js" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
