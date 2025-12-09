# =============================================================================
# Rust Docs MCP Server - Streamable HTTP
# =============================================================================
# Provides real-time access to specific Rust crate documentation with semantic
# search and LLM summarization. Uses OpenAI for embeddings and summarization.
#
# Build:
#   docker build -f rust-docs.dockerfile -t rust-docs-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -e OPENAI_API_KEY=your-key \
#     -e RUST_CRATE="tokio@1.0" \
#     rust-docs-mcp:http
#
# Note: Each instance serves ONE specific crate. Configure via RUST_CRATE env.
#
# Source: https://github.com/Govcraft/rust-docs-mcp-server
# =============================================================================

FROM rust:1.83-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone and build the rust-docs MCP server
WORKDIR /build
RUN git clone --depth 1 https://github.com/Govcraft/rust-docs-mcp-server.git .
RUN cargo build --release

# -----------------------------------------------------------------------------
# Runtime Stage
# -----------------------------------------------------------------------------
FROM debian:bookworm-slim

# -----------------------------------------------------------------------------
# Build Arguments
# -----------------------------------------------------------------------------
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=60000

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# Required: OpenAI API key for embeddings and summarization
ENV OPENAI_API_KEY=

# Crate to serve documentation for (e.g., "tokio@1.0", "serde@^1.0")
ENV RUST_CRATE="tokio@1.0"

# Optional: Crate features (comma-separated, e.g., "full,rt-multi-thread")
ENV RUST_CRATE_FEATURES=

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    curl \
    nodejs \
    npm \
    # Required for cargo doc generation
    rustc \
    cargo \
    && rm -rf /var/lib/apt/lists/*

# Copy binary from builder
COPY --from=builder /build/target/release/rustdocs_mcp_server /usr/local/bin/

# Install supergateway globally
RUN npm install -g supergateway

# Create cache directory
RUN mkdir -p /root/.local/share/rustdocs-mcp-server

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Build command with optional features flag
# Note: Using shell form to allow environment variable expansion
CMD if [ -n "$RUST_CRATE_FEATURES" ]; then \
      CRATE_CMD="rustdocs_mcp_server \"${RUST_CRATE}\" -F ${RUST_CRATE_FEATURES}"; \
    else \
      CRATE_CMD="rustdocs_mcp_server \"${RUST_CRATE}\""; \
    fi && \
    supergateway \
      --stdio "$CRATE_CMD" \
      --outputTransport streamableHttp \
      --port ${PORT} \
      --streamableHttpPath ${MCP_PATH} \
      --stateful \
      --sessionTimeout ${SESSION_TIMEOUT}
