# =============================================================================
# Bruno MCP Server - Streamable HTTP
# =============================================================================
# Wraps hungthai1401/bruno-mcp with supergateway to provide Streamable HTTP
# transport. Enables AI assistants to run Bruno API test collections and
# get detailed test results.
#
# Build:
#   docker build -f bruno.dockerfile -t bruno-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -v /path/to/collections:/collections:ro \
#     bruno-mcp:http
#
# Source: https://github.com/hungthai1401/bruno-mcp
# Bruno: https://www.usebruno.com/
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build the TypeScript MCP server
# -----------------------------------------------------------------------------
FROM node:22-alpine AS builder

WORKDIR /build

# Install git for cloning
RUN apk add --no-cache git

# Clone the bruno-mcp repository
RUN git clone --depth 1 https://github.com/hungthai1401/bruno-mcp.git .

# Install dependencies and build
RUN npm ci --ignore-scripts && npm run build

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

WORKDIR /app

# Copy built application from builder
COPY --from=builder /build/build ./build
COPY --from=builder /build/package.json ./package.json
COPY --from=builder /build/package-lock.json ./package-lock.json

# Install production dependencies only (includes @usebruno/cli)
RUN npm ci --omit=dev --ignore-scripts

# Install supergateway globally
RUN npm install -g supergateway

# Create collections directory for mounting Bruno collections
RUN mkdir -p /collections
WORKDIR /collections

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the Bruno MCP server
CMD supergateway \
    --stdio "node /app/build/index.js" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
