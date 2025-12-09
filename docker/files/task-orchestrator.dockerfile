# =============================================================================
# Task Orchestrator MCP Server - Streamable HTTP
# =============================================================================
# Wraps jpicklyk/task-orchestrator with supergateway to provide Streamable HTTP
# transport. Orchestration framework for AI coding assistants that solves
# context pollution and token exhaustion.
#
# Build:
#   docker build -f task-orchestrator.dockerfile -t task-orchestrator-mcp:http .
#
# Run:
#   docker run -p 8080:8080 \
#     -v task-orchestrator-data:/app/data \
#     -v /path/to/project:/project \
#     task-orchestrator-mcp:http
#
# Source: https://github.com/jpicklyk/task-orchestrator
# =============================================================================

FROM ghcr.io/jpicklyk/task-orchestrator:latest AS base

# -----------------------------------------------------------------------------
# Runtime image with supergateway
# -----------------------------------------------------------------------------
FROM node:22-alpine

# Build Arguments
ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=120000

# Environment Variables (can be overridden at runtime)
ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# Task Orchestrator environment
ENV DATABASE_PATH=/app/data/tasks.db
ENV MCP_TRANSPORT=stdio
ENV LOG_LEVEL=info
ENV USE_FLYWAY=true

# Install Java runtime (Amazon Corretto)
RUN apk add --no-cache \
    openjdk21-jre-headless \
    bash

WORKDIR /app

# Copy the application JAR and docs from base image
COPY --from=base /app/orchestrator.jar /app/orchestrator.jar
COPY --from=base /app/docs /app/docs

# Install supergateway globally
RUN npm install -g supergateway

# Create data directory for SQLite database
RUN mkdir -p /app/data /project

# Expose the configured port
EXPOSE ${PORT}

# Health check - verify supergateway is listening
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the Task Orchestrator MCP server
CMD supergateway \
    --stdio "java -Dfile.encoding=UTF-8 -Djava.awt.headless=true --enable-native-access=ALL-UNNAMED -jar /app/orchestrator.jar" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
