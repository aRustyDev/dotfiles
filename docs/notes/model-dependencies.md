---
id: 3f8e7d6c-5a4b-9e2f-1c3d-8a9b7f6e4d2c
title: Model Dependencies in Graphiti MCP Server
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
  - ai
  - llm
  - embeddings
  - graphiti
  - model-configuration
aliases:
  - Graphiti Model Guide
  - Model Independence
related:
  - ref: "[[ollama-embeddings]]"
    description: Embedder model reference
  - ref: "[[model-comparison-llama-vs-gpt-oss]]"
    description: LLM model comparison
---

# Model Dependencies in Graphiti MCP Server

This document explains the relationships and dependencies between the three model types used in Graphiti: LLM, Embedder, and Cross-Encoder (Reranker).

## TL;DR - Quick Answer

**No, your choices are functionally independent!**

You can mix and match models freely:
- ✅ `llama3.2` for LLM + `nomic-embed-text` for embeddings + `llama3.2` for cross-encoder
- ✅ `mistral` for LLM + `mxbai-embed-large` for embeddings + `qwen` for cross-encoder
- ✅ Any combination that works via OpenAI-compatible API

**BUT** - The embedder choice has critical persistence implications (see below).

---

## The Three Model Types Explained

### 1. LLM (Language Model)
**Configuration**: `llm.model`
**Current**: `llama3.2`

**Purpose**:
- Extract entities from conversations/documents
- Identify relationships between entities
- Generate entity summaries and descriptions
- Create episode summaries
- Deduplicate similar entities
- Answer questions about the knowledge graph

**Input/Output**:
- Input: Text prompts with instructions
- Output: Structured text (JSON, descriptions, etc.)

**Examples of Tasks**:
```
Prompt: "Extract entities from: John works at Acme Corp in Seattle"
Output: {
  "entities": [
    {"name": "John", "type": "Person"},
    {"name": "Acme Corp", "type": "Organization"},
    {"name": "Seattle", "type": "Location"}
  ],
  "relationships": [
    {"from": "John", "to": "Acme Corp", "type": "works_at"},
    {"from": "Acme Corp", "to": "Seattle", "type": "located_in"}
  ]
}
```

---

### 2. Embedder (Embedding Model)
**Configuration**: `embedder.model`
**Current**: `nomic-embed-text` (768 dimensions)

**Purpose**:
- Convert text to numerical vectors (embeddings)
- Enable semantic similarity search
- Support "find similar entities" queries
- Power vector-based retrieval

**Input/Output**:
- Input: Text string
- Output: Fixed-dimension vector (e.g., 768 floats)

**Example**:
```
Input: "artificial intelligence"
Output: [0.234, -0.567, 0.123, ..., 0.456]  (768 numbers)

Input: "machine learning"
Output: [0.245, -0.543, 0.134, ..., 0.467]  (768 numbers)
         ↑ Similar vectors = semantically related concepts
```

---

### 3. Cross-Encoder / Reranker
**Configuration**: `cross_encoder.model`
**Current**: `llama3.2`

**Purpose**:
- Rerank search results for better relevance
- Score pairs of (query, candidate) for relevance
- Improve retrieval quality beyond vector similarity

**Input/Output**:
- Input: Pair of texts (query + candidate)
- Output: Relevance score (0.0 to 1.0)

**Example**:
```
Query: "What is John's job?"
Candidates after vector search:
  1. "John works at Acme Corp"
  2. "John lives in Seattle"
  3. "John likes coffee"

Cross-encoder scores:
  1. 0.95 ← Most relevant, ranked first
  2. 0.12 ← Less relevant
  3. 0.05 ← Least relevant
```

---

## Model Independence Matrix

| From ↓ To → | LLM | Embedder | Cross-Encoder |
|-------------|-----|----------|---------------|
| **LLM** | — | ✅ Independent | ✅ Independent |
| **Embedder** | ✅ Independent | — | ✅ Independent |
| **Cross-Encoder** | ✅ Independent | ✅ Independent | — |

**Legend**:
- ✅ Independent = Can change one without changing the other
- ❌ Dependent = Changing one requires changing the other
- ⚠️ Caution = Technically independent but has implications

---

## Can I Mix and Match?

### YES - These Combinations Work Fine

```yaml
# Example 1: All the same model
llm:
  model: "llama3.2"
embedder:
  model: "nomic-embed-text"
cross_encoder:
  model: "llama3.2"
```

```yaml
# Example 2: All different models
llm:
  model: "mistral"
embedder:
  model: "mxbai-embed-large"
cross_encoder:
  model: "qwen"
```

```yaml
# Example 3: Specialized models
llm:
  model: "llama3.2"           # Good at instruction following
embedder:
  model: "nomic-embed-text"   # Excellent embeddings
cross_encoder:
  model: "bge-reranker"       # Specialized reranker
```

---

## Critical Constraint: Embedder Persistence

### ⚠️ The Embedder is "Sticky"

Once you create a knowledge graph with a specific embedder:
- **All vectors are stored in that dimension** (e.g., 768)
- **Changing embedders breaks existing data**
- **You must clear and rebuild the graph**

#### Why This Matters

```
Scenario 1: Start with nomic-embed-text (768 dimensions)
- Store 10,000 entity embeddings in FalkorDB
- Each embedding: 768 floats

Scenario 2: Switch to mxbai-embed-large (1024 dimensions)
- New embeddings: 1024 floats
- Old embeddings: 768 floats
- ❌ Vector search breaks! (dimension mismatch)
- ❌ Similarity calculations fail!
```

#### Migration Process

If you must change embedders:

```bash
# 1. Export your data (if you want to preserve it)
# Use MCP tool: get_episodes()

# 2. Clear the graph
# Use MCP tool: clear_graph()

# 3. Update configuration
# Edit graphiti.yaml:
embedder:
  model: "new-model-name"
  dimensions: <new-dimensions>

# 4. Pull new model
docker exec ollama ollama pull new-model-name

# 5. Restart memory service
docker restart memory

# 6. Re-ingest all your data
# Use MCP tool: add_episode() for each episode
```

---

## LLM and Cross-Encoder Flexibility

### ✅ Easy to Change

Unlike the embedder, you can change LLM or cross-encoder anytime:

```bash
# Update graphiti.yaml
llm:
  model: "mistral"  # Changed from llama3.2

# Pull new model
docker exec ollama ollama pull mistral

# Restart
docker restart memory

# ✅ Works immediately - no data migration needed!
```

**Why?**
- LLM only processes text → text (no stored state)
- Cross-encoder only scores pairs (no stored state)
- Embedder creates persistent vectors (stored in database)

---

## Performance Considerations

While models are functionally independent, some combinations work better together:

### Model Family Coherence

**Option A: Same Model Family**
```yaml
llm:
  model: "llama3.2"
cross_encoder:
  model: "llama3.2"
embedder:
  model: "nomic-embed-text"  # Different is fine
```
**Pros**:
- Consistent "understanding" of concepts
- Single model loaded in memory (if LLM = cross-encoder)
- Less disk space

**Cons**:
- Limited optimization per task

**Option B: Specialized Models**
```yaml
llm:
  model: "qwen:32b"              # Large, smart for extraction
cross_encoder:
  model: "bge-reranker-large"    # Purpose-built reranker
embedder:
  model: "mxbai-embed-large"     # State-of-art embeddings
```
**Pros**:
- Best quality for each task
- Optimized performance

**Cons**:
- More disk space
- Longer startup time
- Higher memory usage

---

## Recommended Configurations

### 1. Balanced (Current Setup) ⭐
```yaml
llm:
  model: "llama3.2"              # 2GB, fast, good quality
embedder:
  model: "nomic-embed-text"      # 274MB, 768D, 8K context
  dimensions: 768
cross_encoder:
  model: "llama3.2"              # Reuse LLM
```
**Use Case**: General purpose, resource-efficient
**Total Size**: ~2.3 GB

---

### 2. High Performance
```yaml
llm:
  model: "qwen:32b"              # Best reasoning
embedder:
  model: "mxbai-embed-large"     # Best embeddings
  dimensions: 1024
cross_encoder:
  model: "qwen:32b"              # Reuse LLM
```
**Use Case**: Maximum accuracy, ample resources
**Total Size**: ~20 GB

---

### 3. Lightweight
```yaml
llm:
  model: "phi"                   # Small, fast
embedder:
  model: "all-minilm"            # Tiny embeddings
  dimensions: 384
cross_encoder:
  model: "phi"                   # Reuse LLM
```
**Use Case**: Raspberry Pi, edge devices
**Total Size**: ~500 MB

---

### 4. Multilingual
```yaml
llm:
  model: "aya"                   # Multilingual LLM
embedder:
  model: "bge-m3"                # Multilingual embeddings
  dimensions: 1024
cross_encoder:
  model: "aya"                   # Reuse LLM
```
**Use Case**: Non-English or mixed-language content
**Total Size**: ~10 GB

---

## Testing Model Changes

### Safe Testing Approach

1. **Use a separate group_id** for testing:
```yaml
# Test configuration
graphiti:
  group_id: "test-new-model"  # Isolated from main graph
```

2. **Test LLM change**:
```bash
# Edit graphiti.yaml, change llm.model
docker exec ollama ollama pull new-llm-model
docker restart memory
# Test with add_episode() - no data loss risk
```

3. **Test embedder change** (requires caution):
```bash
# Create new test environment or clear test group
# Change embedder.model and dimensions
docker exec ollama ollama pull new-embed-model
docker restart memory
# Re-add test data
```

---

## Common Questions

### Q: Can I use GPT-4 for LLM and Ollama for embeddings?
**A**: Yes! Mix cloud and local models:
```yaml
llm:
  provider: "openai"
  model: "gpt-4"
  providers:
    openai:
      api_key: "${OPENAI_API_KEY}"
      api_base: "https://api.openai.com/v1"

embedder:
  provider: "openai"  # Via Ollama's OpenAI-compatible API
  model: "nomic-embed-text"
  providers:
    openai:
      api_key: "ollama"
      api_base: "http://ollama:11434/v1"
```

### Q: Should I use the same model for LLM and cross-encoder?
**A**: It's efficient (saves memory) but not required. If you have a specialized reranker model, use it!

### Q: What happens if I change LLM after building a graph?
**A**: Nothing breaks! The graph stores:
- ✅ Extracted entities (text, not model-dependent)
- ✅ Relationships (text, not model-dependent)
- ✅ Embeddings (tied to embedder, not LLM)

The new LLM will:
- Process new episodes differently (potentially better/worse)
- But won't affect existing graph data

### Q: Can I change embedding dimensions without changing the model?
**A**: No. Dimensions are a property of the model itself. `nomic-embed-text` always produces 768-dimensional vectors.

---

## Decision Matrix

| Scenario | LLM | Embedder | Cross-Encoder | Action |
|----------|-----|----------|---------------|--------|
| Want better entity extraction | Change ✅ | Keep | Keep | Safe, instant |
| Want better search results | Keep | Change ⚠️ | Keep | Requires rebuild |
| Want better reranking | Keep | Keep | Change ✅ | Safe, instant |
| Want to reduce memory | Change ✅ | Change ⚠️ | Change ✅ | Embedder needs rebuild |
| Switch to multilingual | Change ✅ | Change ⚠️ | Change ✅ | Embedder needs rebuild |

**Legend**:
- ✅ = Safe, no data migration
- ⚠️ = Requires clearing graph and re-ingesting data

---

## Summary

### The Golden Rules

1. **✅ LLM and Cross-Encoder are swappable**
   - Change anytime without breaking existing data
   - Only affects future processing quality

2. **⚠️ Embedder is persistent**
   - Locked in once you build a graph
   - Changing requires clearing and rebuilding
   - Choose wisely at project start

3. **✅ All three are functionally independent**
   - No hard dependencies between them
   - Mix cloud and local models freely
   - Optimize each for its specific task

4. **💡 Practical optimization**
   - Reuse LLM for cross-encoder to save memory
   - Invest in good embedder (it's the hardest to change)
   - Experiment with LLM freely (safe to swap)

---

## Current Graphiti Setup

```yaml
# Your current configuration (working well!)
llm:
  model: "llama3.2"              # ✅ Good instruction following

embedder:
  model: "nomic-embed-text"      # ✅ Excellent choice
  dimensions: 768                #    - 8K context window
                                 #    - Balanced quality/size

cross_encoder:
  model: "llama3.2"              # ✅ Reuses LLM efficiently
```

**Recommendation**: This is a solid, balanced configuration. Only change if:
- You need multilingual support → Switch all three
- You need more accuracy → Upgrade to larger models
- You need less resources → Downgrade to smaller models

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
