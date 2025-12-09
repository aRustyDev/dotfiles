# =============================================================================
# ArXiv MCP Server - Streamable HTTP
# =============================================================================
# Wraps blazickjp/arxiv-mcp-server with supergateway to provide
# Streamable HTTP transport. Enables AI assistants to search and analyze
# arXiv research papers.
#
# Build:
#   docker build -f arxiv.dockerfile -t arxiv-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -v ~/.arxiv-mcp-server:/data/papers \
#     arxiv-mcp:http
#
# Source: https://github.com/blazickjp/arxiv-mcp-server
# =============================================================================

FROM python:3.12-slim

# -----------------------------------------------------------------------------
# Build Arguments
# -----------------------------------------------------------------------------
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=60000
ARG STORAGE_PATH=/data/papers

# -----------------------------------------------------------------------------
# Environment Variables (can be overridden at runtime)
# -----------------------------------------------------------------------------
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}
ENV ARXIV_STORAGE_PATH=${STORAGE_PATH}

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install uv package manager
RUN pip install --no-cache-dir uv

# Install arxiv-mcp-server as a uv tool
RUN uv tool install arxiv-mcp-server

# Add uv tools to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Install supergateway globally
RUN npm install -g supergateway

# Create storage directory
RUN mkdir -p ${STORAGE_PATH}

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping arxiv-mcp-server
CMD supergateway \
    --stdio "arxiv-mcp-server --storage-path ${ARXIV_STORAGE_PATH}" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
