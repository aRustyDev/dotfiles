# =============================================================================
# MAS Sequential Thinking MCP Server - Streamable HTTP
# =============================================================================
# Wraps FradSer/mcp-server-mas-sequential-thinking with supergateway to provide
# Streamable HTTP transport. Multi-Agent System with 6 specialized agents for
# parallel problem-solving from multiple perspectives.
#
# Build:
#   docker build -f multi-agent-system.dockerfile -t multi-agent-system-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -e LLM_PROVIDER=deepseek \
#     -e DEEPSEEK_API_KEY=your_key \
#     multi-agent-system-mcp:http
#
# Source: https://github.com/FradSer/mcp-server-mas-sequential-thinking
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build the Python MCP server
# -----------------------------------------------------------------------------
FROM python:3.10-slim AS builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gcc \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone --depth 1 https://github.com/FradSer/mcp-server-mas-sequential-thinking.git .

# Install uv for faster dependency resolution
RUN pip install --no-cache-dir uv

# Create virtual environment and install dependencies
RUN uv venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN uv pip install hatchling && uv pip install .

# -----------------------------------------------------------------------------
# Stage 2: Runtime image with supergateway
# -----------------------------------------------------------------------------
FROM python:3.10-slim

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=120000

# Environment Variables (can be overridden at runtime)
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Node.js for supergateway
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install supergateway globally
RUN npm install -g supergateway

# Create data directory for persistent storage
RUN mkdir -p /data/mas_sequential_thinking
ENV DATABASE_URL="sqlite:///data/mas_sequential_thinking/sessions.db"

WORKDIR /app

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the MAS sequential thinking server
# Note: Longer session timeout due to multi-agent parallel processing
CMD supergateway \
    --stdio "mcp-server-mas-sequential-thinking" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
