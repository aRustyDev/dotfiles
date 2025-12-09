# =============================================================================
# KiCad MCP Server - Streamable HTTP
# =============================================================================
# Wraps kicad-mcp with supergateway to provide Streamable HTTP transport.
# Provides AI-powered tools for KiCad electronic design automation including
# project management, PCB analysis, BOM generation, DRC checks, and more.
#
# Build:
#   docker build -f kicad.dockerfile -t kicad-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -v ~/KiCad:/workspace \
#     -e KICAD_SEARCH_PATHS=/workspace \
#     kicad-mcp:http
#
# Source: https://github.com/lamaalrajih/kicad-mcp
# =============================================================================

FROM node:22-bookworm-slim

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=120000

# Environment Variables
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# KiCad MCP configuration
ENV KICAD_SEARCH_PATHS=/workspace
ENV KICAD_USER_DIR=/workspace

# Install Python, git, and KiCad CLI tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    git \
    ca-certificates \
    # KiCad CLI for DRC checks and file operations
    kicad \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone the kicad-mcp repository
RUN git clone --depth 1 https://github.com/lamaalrajih/kicad-mcp.git .

# Create virtual environment and install dependencies
RUN python3 -m venv .venv \
    && .venv/bin/pip install --no-cache-dir --upgrade pip \
    && .venv/bin/pip install --no-cache-dir \
        "mcp[cli]>=1.0.0" \
        "fastmcp>=2.0.0" \
        "pandas>=2.0.0" \
        "pyyaml>=6.0.0" \
        "defusedxml>=0.7.0"

# Install supergateway globally
RUN npm install -g supergateway

# Create workspace directory for KiCad projects
RUN mkdir -p /workspace

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping kicad-mcp
CMD supergateway \
    --stdio "/app/.venv/bin/python /app/main.py" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
