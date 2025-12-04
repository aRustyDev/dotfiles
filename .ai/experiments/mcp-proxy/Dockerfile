# Build stage
FROM rust:1.83-alpine AS builder

# Install build dependencies
RUN apk add --no-cache musl-dev openssl-dev openssl-libs-static pkgconfig

WORKDIR /app

# Copy manifests first for better caching
COPY Cargo.toml Cargo.lock* ./

# Create dummy source to build dependencies
RUN mkdir src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

# Copy actual source
COPY src ./src

# Build the application
RUN touch src/main.rs && \
    cargo build --release

# Runtime stage
FROM alpine:3.20

# Install runtime dependencies
RUN apk add --no-cache ca-certificates

# Create non-root user
RUN addgroup -S mcp && adduser -S mcp -G mcp

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/target/release/mcp-observability-proxy /app/mcp-proxy

# Set ownership
RUN chown -R mcp:mcp /app

USER mcp

# Environment variables with defaults
ENV MCP_UPSTREAM_URL=http://localhost:8081
ENV MCP_LISTEN_ADDR=0.0.0.0:8080
ENV RUST_LOG=mcp_proxy=info

# Expose ports
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

ENTRYPOINT ["/app/mcp-proxy"]
