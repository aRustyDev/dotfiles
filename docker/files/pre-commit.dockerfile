FROM python:3.12-slim

ARG REPO=sjswerdloff/pre-commit-mcp

SHELL ["/bin/bash", "-c"]

# Install system dependencies
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

# Install pre-commit globally
RUN pip install pre-commit

# Clone and set up the MCP server
RUN git clone https://github.com/$REPO /opt/pre-commit-mcp

WORKDIR /opt/pre-commit-mcp

# Set up the MCP server environment
RUN uv venv && uv sync

# The actual project workspace where .pre-commit-config.yaml lives
VOLUME [ "/workspace" ]

# Set the working directory to the mounted project
WORKDIR /workspace

# Run the MCP server
# The server will look for .pre-commit-config.yaml in /workspace
ENTRYPOINT ["uv", "--directory", "/opt/pre-commit-mcp", "run", "pre_commit_mcp"]
