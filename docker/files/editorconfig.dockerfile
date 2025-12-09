# =============================================================================
# EditorConfig MCP Server - Native HTTP
# =============================================================================
# MCP server that applies .editorconfig formatting rules to files.
# Prevents AI coding agents from generating files with formatting issues.
#
# Build:
#   docker build -f editorconfig.dockerfile -t editorconfig-mcp:http .
#
# Run:
#   docker run -p 8432:8432 \
#     -v /path/to/project:/workspace \
#     editorconfig-mcp:http
#
# Source: https://github.com/neilberkman/editorconfig_mcp
# =============================================================================

FROM node:20-slim

# -----------------------------------------------------------------------------
# Build Arguments
# -----------------------------------------------------------------------------
ARG PORT=8432

# -----------------------------------------------------------------------------
# Environment Variables (can be overridden at runtime)
# -----------------------------------------------------------------------------
ENV PORT=${PORT}
ENV NODE_ENV=production

# Create app directory
WORKDIR /app

# Install editorconfig-mcp-server globally
RUN npm install -g editorconfig-mcp-server

# Create workspace directory for mounting projects
RUN mkdir -p /workspace
WORKDIR /workspace

# Expose the configured port
EXPOSE ${PORT}

# Health check using the built-in /health endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD node -e "require('http').get('http://localhost:${PORT}/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

# Run the server
CMD ["editorconfig-mcp-server"]
