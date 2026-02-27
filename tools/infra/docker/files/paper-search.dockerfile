# =============================================================================
# Paper Search MCP Server - Streamable HTTP
# =============================================================================
# Wraps paper-search-mcp with supergateway to provide Streamable HTTP transport.
# Enables searching and downloading academic papers from multiple platforms.
#
# Build:
#   docker build -f paper-search.dockerfile -t paper-search-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -e SEMANTIC_SCHOLAR_API_KEY=your-key \
#     paper-search-mcp:http
#
# Source: https://github.com/openags/paper-search-mcp
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

# Optional API key for enhanced Semantic Scholar functionality
ENV SEMANTIC_SCHOLAR_API_KEY=

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install uv package manager
RUN pip install --no-cache-dir uv

# Install paper-search-mcp
RUN uv pip install --system paper-search-mcp

# Install supergateway globally
RUN npm install -g supergateway

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping paper-search-mcp
CMD supergateway \
    --stdio "python -m paper_search_mcp.server" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
