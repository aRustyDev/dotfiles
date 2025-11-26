FROM python:3.12-slim

SHELL ["/bin/bash", "-c"]

ARG ZETTELKASTEN_LOG_LEVEL=INFO

ENV ZETTELKASTEN_LOG_LEVEL=${ZETTELKASTEN_LOG_LEVEL}
# Note storage (Markdown files)
ENV ZETTELKASTEN_NOTES_DIR=/var/data/notes
# Database for indexing
ENV ZETTELKASTEN_DATABASE_DIR=/var/data/db
ENV ZETTELKASTEN_DATABASE_PATH=$ZETTELKASTEN_DATABASE_DIR/zettelkasten.db

VOLUME [$ZETTELKASTEN_NOTES_DIR, $ZETTELKASTEN_DATABASE_DIR]

# # Check version requirements
# python --version  # Should be >=3.10
# node --version    # Should be >=18.0.0
# npm --version     # Should be >=9.0.0
RUN apt-get update && apt-get install -y git node npm nvm
RUN pip install uv

RUN git clone https://github.com/rinadelph/Agent-MCP /app

WORKDIR /app

RUN nvm use
RUN uv venv && source .venv/bin/activate
# RUN uv install
# RUN uv add "mcp[cli]"
RUN mkdir -p $ZETTELKASTEN_NOTES_DIR $ZETTELKASTEN_DATABASE_DIR

# ENTRYPOINT ["python", "-m", "zettelkasten_mcp.main", "--notes-dir", "$ZETTELKASTEN_NOTES_DIR", "--database-path", "$ZETTELKASTEN_DATABASE_PATH"]
ENTRYPOINT ["uv", "run", "-m", "agent_mcp.cli", "--port", "8080", "--project-dir", "path-to-directory"]

# # Launch dashboard (recommended for full experience)
# cd agent_mcp/dashboard && npm install && npm run dev
