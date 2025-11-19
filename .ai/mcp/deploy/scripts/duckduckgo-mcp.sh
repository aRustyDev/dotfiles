#!/bin/sh
# MCP wrapper for DuckDuckGo search server
# This script properly connects to the running container's stdio

set -e

# The container 'websearch' is already running the MCP server as PID 1
# We need to send commands via docker attach, but that doesn't work well
# Instead, we'll use a socat approach or restart the container on-demand

CONTAINER_NAME="websearch"

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: Container ${CONTAINER_NAME} is not running" >&2
    exit 1
fi

# Use docker attach with --no-stdin=false to pipe our stdin to the container
# The --sig-proxy=false prevents signals from being forwarded
exec docker attach --no-stdin=false --sig-proxy=false "${CONTAINER_NAME}"
