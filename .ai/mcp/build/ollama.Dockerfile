FROM ollama
RUN ollama pull deepseek-r1:7b # LLM
RUN ollama pull nomic-embed-text # embeddings
