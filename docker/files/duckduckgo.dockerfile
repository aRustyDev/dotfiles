# =============================================================================
# DuckDuckGo MCP Server - Streamable HTTP
# =============================================================================
# Extends the official mcp/duckduckgo image to support HTTP transport.
#
# Build:
#   docker build -f duckduckgo.dockerfile -t duckduckgo-mcp:http .
#
# Build with custom args:
#   docker build -f duckduckgo.dockerfile \
#     --build-arg TRANSPORT=sse \
#     --build-arg HOST=127.0.0.1 \
#     --build-arg PORT=8080 \
#     -t duckduckgo-mcp:http .
#
# Run:
#   docker run -p 3000:3000 duckduckgo-mcp:http
#
# Source: https://github.com/nickclyde/duckduckgo-mcp-server
# =============================================================================

FROM mcp/duckduckgo:latest

# -----------------------------------------------------------------------------
# Build Arguments
# -----------------------------------------------------------------------------
# Transport mode: http, streamable-http, sse, stdio
ARG TRANSPORT=http
# Host to bind to (0.0.0.0 for all interfaces)
ARG HOST=0.0.0.0
# Port to listen on
ARG PORT=3000
# Log level: DEBUG, INFO, WARNING, ERROR, CRITICAL
ARG LOG_LEVEL=INFO

# -----------------------------------------------------------------------------
# Environment Variables (can be overridden at runtime)
# -----------------------------------------------------------------------------
ENV MCP_TRANSPORT=${TRANSPORT}
ENV MCP_HOST=${HOST}
ENV MCP_PORT=${PORT}
ENV MCP_LOG_LEVEL=${LOG_LEVEL}

# Expose the configured port
EXPOSE ${PORT}

# Override entrypoint to use HTTP transport with configurable options
CMD ["python", "-c", "\
import os;\
from duckduckgo_mcp_server.server import mcp;\
mcp.run(\
    transport=os.environ.get('MCP_TRANSPORT', 'http'),\
    host=os.environ.get('MCP_HOST', '0.0.0.0'),\
    port=int(os.environ.get('MCP_PORT', 3000)),\
    log_level=os.environ.get('MCP_LOG_LEVEL', 'INFO')\
)"]
