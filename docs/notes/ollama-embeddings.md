---
id: 9c4f2a1e-7b3d-4e9f-a2c8-5d6e8f9a1b2c
title: Ollama Embedding Models Reference
created: 2025-12-12T00:00:00
updated: 2025-12-12T00:00:00
project: dotfiles
scope:
  - ai
  - docker
type: reference
status: ✅ active
publish: true
tags:
  - ollama
  - embeddings
  - graphiti
  - vector-database
  - llm
aliases:
  - Ollama Embeddings Guide
  - Embedding Models
related:
  - ref: "[[model-dependencies]]"
    description: Model configuration and independence
  - ref: "[[graphiti-strategy]]"
    description: Graphiti entity type planning
---

# Ollama Embedding Models Reference

This document provides a reference for embedding models available in Ollama, including their dimensions, parameters, and recommended use cases for the Graphiti MCP Memory backend.

## Quick Reference Table

| Model | Parameters | Embedding Dimensions | Context Length | Size | Best For |
|-------|-----------|---------------------|----------------|------|----------|
| `nomic-embed-text` | 137M | **768** | 8192 | ~274 MB | General purpose, large context |
| `mxbai-embed-large` | 334M | **1024** | 512 | ~669 MB | High accuracy, retrieval tasks |
| `all-minilm` | 22M-33M | **384** | 512 | ~45 MB | Fast, lightweight |
| `bge-m3` | 567M | **1024** | 8192 | ~1.1 GB | Multilingual, multi-granularity |
| `bge-large` | 335M | **1024** | 512 | ~670 MB | English, high quality |
| `snowflake-arctic-embed` | 22M-335M | **384-1024** | varies | varies | Optimized performance, various sizes |
| `snowflake-arctic-embed2` | 568M | **1024** | varies | ~1.1 GB | Multilingual, frontier model |
| `granite-embedding` | 30M-278M | **384-768** | varies | varies | IBM, multilingual options |

## Currently Configured

**Model**: `nomic-embed-text`
**Dimensions**: **768**
**Context Length**: 8192 tokens
**Size**: 274 MB

## Detailed Model Information

### nomic-embed-text ⭐ (Recommended for Graphiti)

```bash
ollama pull nomic-embed-text
```

- **Parameters**: 137M
- **Embedding Dimensions**: 768
- **Context Length**: 8192 tokens (via num_ctx parameter)
- **Architecture**: nomic-bert
- **Quantization**: F16
- **Best For**:
  - Large context windows (8K tokens)
  - General-purpose embedding tasks
  - Good balance of performance and size
  - Currently used in our Graphiti setup

**Why Recommended**:
- Excellent context length (8192 tokens) for processing large documents
- Open source and high-performing
- Reasonable model size (274 MB)
- Well-tested with Graphiti MCP server

### mxbai-embed-large

```bash
ollama pull mxbai-embed-large
```

- **Parameters**: 334M
- **Embedding Dimensions**: 1024
- **Context Length**: 512 tokens
- **Size**: ~669 MB
- **Best For**:
  - State-of-the-art retrieval quality
  - When accuracy is more important than speed
  - Semantic search applications

**Trade-offs**:
- Higher dimensional embeddings (1024 vs 768)
- Larger model size
- Shorter context window (512 vs 8192)

### all-minilm (Lightweight Option)

```bash
ollama pull all-minilm
```

- **Parameters**: 22M-33M
- **Embedding Dimensions**: 384
- **Context Length**: 512 tokens
- **Size**: ~45 MB
- **Best For**:
  - Resource-constrained environments
  - Fast embedding generation
  - Large-scale batch processing

**Trade-offs**:
- Lower dimensional embeddings may reduce semantic precision
- Shorter context window
- Smaller model may be less accurate for complex queries

### bge-m3 (Multilingual)

```bash
ollama pull bge-m3
```

- **Parameters**: 567M
- **Embedding Dimensions**: 1024
- **Context Length**: 8192 tokens
- **Size**: ~1.1 GB
- **Best For**:
  - Multilingual applications
  - Multi-granularity embedding (sentence, passage, document)
  - Versatile use cases

**Trade-offs**:
- Larger model size
- Slower embedding generation
- Excellent for non-English content

## Checking Model Details

To inspect any Ollama embedding model:

```bash
docker exec ollama ollama show <model-name>
```

Example output:
```
Model
    architecture        nomic-bert
    parameters          137M
    context length      2048
    embedding length    768  ← This is the dimension you need
    quantization        F16
```

## Configuration in Graphiti

The embedding dimensions are configured in `graphiti.yaml`:

```yaml
embedder:
  provider: "openai"
  model: "nomic-embed-text"  # ← Change this to switch models

  providers:
    openai:
      api_key: "ollama"
      api_base: "http://ollama:11434/v1"
```

**Important**: After changing the embedding model:

1. Pull the new model:
   ```bash
   docker exec ollama ollama pull <new-model>
   ```

2. Update the model name in `graphiti.yaml`

3. Restart the memory service:
   ```bash
   docker restart memory
   ```

4. **Clear the existing graph** if switching models (embeddings from different models are not compatible):
   ```bash
   # Via MCP tool:
   clear_graph()
   ```

## Embedding Dimension Compatibility

⚠️ **Warning**: Changing embedding models after building a knowledge graph will cause compatibility issues because:

- Different models produce different dimensional vectors (384, 768, 1024, etc.)
- Vector similarity searches require consistent dimensions
- You must clear the graph and re-ingest all data when switching models

## Recommendations by Use Case

### General Purpose AI Memory (Current Setup)
- **Model**: `nomic-embed-text`
- **Dimensions**: 768
- **Reason**: Best balance of performance, context length, and size

### Multilingual Applications
- **Model**: `bge-m3` or `snowflake-arctic-embed2`
- **Dimensions**: 1024
- **Reason**: Native multilingual support

### Resource-Constrained Environments
- **Model**: `all-minilm` or `granite-embedding:30m`
- **Dimensions**: 384
- **Reason**: Smallest model size, fastest inference

### Maximum Accuracy
- **Model**: `mxbai-embed-large` or `bge-large`
- **Dimensions**: 1024
- **Reason**: State-of-the-art performance on benchmarks

### Long Documents
- **Model**: `nomic-embed-text` or `bge-m3`
- **Context Length**: 8192 tokens
- **Reason**: Large context window for processing full documents

## Performance Considerations

### Speed vs Quality Trade-off

| Model Size | Speed | Quality | Memory Usage |
|-----------|-------|---------|--------------|
| 22M-30M | ⚡⚡⚡ | ⭐⭐ | 🟢 Low |
| 137M | ⚡⚡ | ⭐⭐⭐ | 🟡 Medium |
| 334M-567M | ⚡ | ⭐⭐⭐⭐ | 🔴 High |

### Database Storage Impact

Embedding dimensions directly affect database storage:

- **384 dimensions**: ~1.5 KB per embedding (float32)
- **768 dimensions**: ~3 KB per embedding (float32)
- **1024 dimensions**: ~4 KB per embedding (float32)

For a knowledge graph with 10,000 entities:
- 384D: ~15 MB
- 768D: ~30 MB
- 1024D: ~40 MB

## Updating the Init Container

To automatically pull a different model on startup, update `global.yaml`:

```yaml
ollama-pull-models:
  command:
    - "-c"
    - "sleep 3; ollama pull llama3.2 && ollama pull nomic-embed-text"
    #                                            ↑ Change this model name
```

## References

- [Ollama Embedding Models](https://ollama.com/search?c=embedding)
- [Nomic Embed Documentation](https://docs.nomic.ai/reference/endpoints/nomic-embed-text)
- [BAAI BGE Models](https://github.com/FlagOpen/FlagEmbedding)
- [MixedBread AI](https://www.mixedbread.ai/docs/embeddings/mxbai-embed-large-v1)
- [Snowflake Arctic Embed](https://www.snowflake.com/en/data-cloud/arctic/)

## Current Setup Summary

- ✅ Model: `nomic-embed-text`
- ✅ Dimensions: 768
- ✅ Context: 8192 tokens
- ✅ Size: 274 MB
- ✅ Status: Optimized for general-purpose AI memory with large context support

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
