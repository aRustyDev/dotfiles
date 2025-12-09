# =============================================================================
# Docling MCP Server - Streamable HTTP
# =============================================================================
# Wraps docling-mcp with supergateway to provide Streamable HTTP transport.
# Docling enables document processing, PDF conversion, and structured document
# generation for AI assistants.
#
# Build:
#   docker build -f docling.dockerfile -t docling-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -v /path/to/documents:/data/documents \
#     docling-mcp:http
#
# Source: https://github.com/docling-project/docling-mcp
# =============================================================================

FROM python:3.12-slim

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

# Install system dependencies (including poppler for PDF processing)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    nodejs \
    npm \
    poppler-utils \
    tesseract-ocr \
    && rm -rf /var/lib/apt/lists/*

# Install uv package manager
RUN pip install --no-cache-dir uv

# Install docling-mcp (includes docling library)
RUN uv pip install --system docling-mcp

# Install supergateway globally
RUN npm install -g supergateway

# Create cache/data directories
RUN mkdir -p /data/documents /data/cache

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping docling-mcp-server
CMD supergateway \
    --stdio "docling-mcp-server" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
