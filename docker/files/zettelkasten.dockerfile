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

RUN apt-get update && apt-get install -y git
RUN pip install uv

RUN git clone https://github.com/entanglr/zettelkasten-mcp /app

WORKDIR /app

RUN uv venv && source .venv/bin/activate
RUN uv add "mcp[cli]"
RUN mkdir -p $ZETTELKASTEN_NOTES_DIR $ZETTELKASTEN_DATABASE_DIR

ENTRYPOINT ["python", "-m", "zettelkasten_mcp.main", "--notes-dir", "$ZETTELKASTEN_NOTES_DIR", "--database-path", "$ZETTELKASTEN_DATABASE_PATH"]
