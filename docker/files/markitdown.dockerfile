# =============================================================================
# MarkItDown MCP Server - Streamable HTTP
# =============================================================================
# Wraps KorigamiK/markitdown_mcp_server with supergateway to provide Streamable
# HTTP transport. Converts various file formats to Markdown using Microsoft's
# MarkItDown utility.
#
# Build:
#   docker build -f markitdown.dockerfile -t markitdown-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -v /path/to/files:/workdir:ro \
#     markitdown-mcp:http
#
# Source: https://github.com/KorigamiK/markitdown_mcp_server
# MarkItDown: https://github.com/microsoft/markitdown
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build the Python MCP server
# -----------------------------------------------------------------------------
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

WORKDIR /build

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

# Install git for cloning
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone --depth 1 https://github.com/KorigamiK/markitdown_mcp_server.git .

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-editable

# -----------------------------------------------------------------------------
# Stage 2: Runtime image with supergateway
# -----------------------------------------------------------------------------
FROM python:3.12-slim-bookworm

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=60000

# Environment Variables (can be overridden at runtime)
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# Install Node.js for supergateway and system dependencies for document processing
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    # For PDF processing
    libmagic1 \
    # For image OCR (optional but useful)
    tesseract-ocr \
    # For audio processing (optional)
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Python virtual environment from builder
COPY --from=builder /build/.venv /app/.venv

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

# Install supergateway globally
RUN npm install -g supergateway

# Create workdir for mounting files to convert
RUN mkdir -p /workdir
WORKDIR /workdir

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the MarkItDown MCP server
CMD supergateway \
    --stdio "markitdown_mcp_server" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
