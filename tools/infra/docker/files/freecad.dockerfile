# =============================================================================
# FreeCAD MCP Server - Streamable HTTP
# =============================================================================
# Wraps freecad-mcp with supergateway to provide Streamable HTTP transport.
# Enables AI assistants to control FreeCAD for 3D CAD modeling operations.
#
# IMPORTANT: Requires FreeCAD running with the MCP addon and RPC server started.
# The addon must be installed in FreeCAD and "Start RPC Server" command run.
#
# Build:
#   docker build -f freecad.dockerfile -t freecad-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -e FREECAD_RPC_HOST=host.docker.internal \
#     freecad-mcp:http
#
# Source: https://github.com/neka-nat/freecad-mcp
# PyPI: https://pypi.org/project/freecad-mcp/
# =============================================================================

FROM python:3.12-slim

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=120000

# Environment Variables
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# FreeCAD RPC connection (default: host.docker.internal for Docker Desktop)
# For Linux Docker, use the host's IP or --network=host
ENV FREECAD_RPC_HOST=host.docker.internal
ENV FREECAD_RPC_PORT=9875

# Install Node.js for supergateway
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install freecad-mcp and supergateway
RUN pip install --no-cache-dir freecad-mcp \
    && npm install -g supergateway

# Create a wrapper script that patches the FreeCAD connection host
# This allows connecting to FreeCAD running on the Docker host
RUN cat > /app/freecad_mcp_wrapper.py << 'EOF'
#!/usr/bin/env python3
"""
Wrapper for freecad-mcp that allows configurable RPC host/port.
This patches the hardcoded localhost:9875 to use environment variables.
"""
import os
import sys

# Patch the get_freecad_connection function before importing the server
import freecad_mcp.server as server

# Store original class
OriginalFreeCADConnection = server.FreeCADConnection

# Get host/port from environment
rpc_host = os.environ.get('FREECAD_RPC_HOST', 'localhost')
rpc_port = int(os.environ.get('FREECAD_RPC_PORT', '9875'))

# Override the get_freecad_connection function
_patched_connection = None

def patched_get_freecad_connection():
    global _patched_connection
    if _patched_connection is None:
        _patched_connection = OriginalFreeCADConnection(host=rpc_host, port=rpc_port)
        if not _patched_connection.ping():
            server.logger.error(f"Failed to ping FreeCAD at {rpc_host}:{rpc_port}")
            _patched_connection = None
            raise Exception(
                f"Failed to connect to FreeCAD at {rpc_host}:{rpc_port}. "
                "Make sure FreeCAD is running with the MCP addon and RPC server started."
            )
        server.logger.info(f"Connected to FreeCAD at {rpc_host}:{rpc_port}")
    return _patched_connection

# Apply the patch
server.get_freecad_connection = patched_get_freecad_connection

# Run the server
if __name__ == "__main__":
    server.main()
EOF

RUN chmod +x /app/freecad_mcp_wrapper.py

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the patched FreeCAD MCP server
CMD supergateway \
    --stdio "python /app/freecad_mcp_wrapper.py" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
