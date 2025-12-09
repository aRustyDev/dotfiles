# =============================================================================
# Typst MCP Server - Streamable HTTP
# =============================================================================
# Wraps typst-mcp with supergateway to provide Streamable HTTP transport.
# Provides tools for working with Typst markup language including LaTeX
# conversion, syntax checking, and rendering to images.
#
# Build:
#   docker build -f typst.dockerfile -t typst-mcp:http .
#
# Run:
#   docker run -p 8080:8080 typst-mcp:http
#
# Source: https://github.com/johannesbrandenburger/typst-mcp
# =============================================================================

FROM ghcr.io/johannesbrandenburger/typst-mcp:latest AS base

# Production image with supergateway
FROM node:22-alpine

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=120000

# Environment Variables
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# Install system dependencies for typst-mcp
RUN apk add --no-cache \
    python3 \
    py3-pip \
    py3-numpy \
    py3-pillow \
    pandoc \
    fontconfig \
    ttf-liberation \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Copy the typst-mcp application from base image
COPY --from=base /app /app

# Install typst binary
RUN wget -qO- https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz \
    | tar -xJf - -C /usr/local/bin --strip-components=1 \
    && chmod +x /usr/local/bin/typst

# Install supergateway globally
RUN npm install -g supergateway

# Install uv for Python package management (used by typst-mcp)
RUN pip3 install --no-cache-dir uv --break-system-packages

# Install Python dependencies
RUN cd /app && uv pip install --system -e .

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping typst-mcp
CMD supergateway \
    --stdio "uv run python /app/server.py" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
