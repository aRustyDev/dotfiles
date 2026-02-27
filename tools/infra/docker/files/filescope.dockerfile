# =============================================================================
# FileScopeMCP Server - Streamable HTTP
# =============================================================================
# Wraps FileScopeMCP with supergateway to provide Streamable HTTP transport.
# Analyzes codebases to identify important files based on dependency relationships,
# generates Mermaid diagrams, and tracks file summaries.
#
# Build:
#   docker build -f filescope.dockerfile -t filescope-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -v /path/to/project:/workspace \
#     -e BASE_DIR=/workspace \
#     filescope-mcp:http
#
# Source: https://github.com/admica/FileScopeMCP
# =============================================================================

FROM node:22-alpine AS builder

# Install git for cloning
RUN apk add --no-cache git

WORKDIR /build

# Clone and build FileScopeMCP
RUN git clone --depth 1 https://github.com/admica/FileScopeMCP.git . \
    && npm install \
    && npm run build

# Production image
FROM node:22-alpine

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=120000

# Environment Variables
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# Base directory for file analysis (mount your project here)
ENV BASE_DIR=/workspace

WORKDIR /app

# Copy built application from builder
COPY --from=builder /build/dist /app/dist
COPY --from=builder /build/package.json /app/
COPY --from=builder /build/node_modules /app/node_modules

# Install supergateway globally
RUN npm install -g supergateway

# Create directories for workspace and data persistence
RUN mkdir -p /workspace /app/data

# Create wrapper script to pass base-dir argument
RUN cat > /app/start.sh << 'EOF'
#!/bin/sh
exec node /app/dist/mcp-server.js --base-dir="${BASE_DIR}"
EOF
RUN chmod +x /app/start.sh

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping FileScopeMCP
CMD supergateway \
    --stdio "/app/start.sh" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
