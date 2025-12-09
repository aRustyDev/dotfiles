# =============================================================================
# ast-grep MCP Server - Streamable HTTP
# =============================================================================
# Wraps dgageot/mcp-ast-grep with supergateway to provide Streamable HTTP
# transport. Enables AI assistants to perform structural code search using
# ast-grep patterns.
#
# Build:
#   docker build -f ast-grep.dockerfile -t ast-grep-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -v /path/to/project:/workspaces/project:ro \
#     ast-grep-mcp:http
#
# Source: https://github.com/dgageot/mcp-ast-grep
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build the Go MCP server
# -----------------------------------------------------------------------------
ARG GO_VERSION=1.23

FROM --platform=${BUILDPLATFORM} golang:${GO_VERSION}-alpine AS builder

WORKDIR /build

# Install git for fetching dependencies
RUN apk add --no-cache git

# Clone the mcp-ast-grep repository
RUN git clone --depth 1 https://github.com/dgageot/mcp-ast-grep.git .

# Fetch ast-grep instructions
ADD https://raw.githubusercontent.com/ast-grep/ast-grep-mcp/b69eb5391bd93d46ef3dec07de814c3c39675c8f/ast-grep.mdc ./instructions.md

# Build the MCP server binary
ARG TARGETOS=linux
ARG TARGETARCH=amd64
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags "-s -w" -o /mcp-server .

# -----------------------------------------------------------------------------
# Stage 2: Runtime image with supergateway
# -----------------------------------------------------------------------------
FROM node:22-alpine

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=60000

# Environment Variables (can be overridden at runtime)
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# Install ast-grep CLI tool
RUN apk add --no-cache ast-grep

# Install supergateway globally
RUN npm install -g supergateway

# Copy the MCP server binary from builder
COPY --from=builder /mcp-server /usr/local/bin/mcp-ast-grep

# Create workspace directory
RUN mkdir -p /workspaces
WORKDIR /workspaces

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the ast-grep MCP server
CMD supergateway \
    --stdio "/usr/local/bin/mcp-ast-grep" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
