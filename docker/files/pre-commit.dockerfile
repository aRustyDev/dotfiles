FROM python:3.12-slim

SHELL ["/bin/bash", "-c"]

# VOLUME [$ZETTELKASTEN_NOTES_DIR, $ZETTELKASTEN_DATABASE_DIR]

RUN apt-get update && apt-get install -y git
RUN pip install uv

RUN git clone https://github.com/sjswerdloff/pre-commit-mcp

WORKDIR /pre-commit-mcp

RUN uv venv && source .venv/bin/activate
RUN uv sync

ENTRYPOINT ["uv", "--directory", "/pre-commit-mcp", "run", "pre_commit_mcp"]
