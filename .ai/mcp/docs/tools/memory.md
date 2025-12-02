# Memory Related Tools

## Scenarios

### Cross-Tool Project Flow

Define technical requirements of a project in Claude Desktop. Build in Cursor. Debug issues in Windsurf - all with shared context passed through OpenMemory.

### Preferences That Persist

Set your preferred code style or tone in one tool. When you switch to another MCP client, it can access those same preferences without redefining them.

### Project Knowledge

Save important project details once, then access them from any compatible AI tool - no more repetitive explanations.

### [Multi-Session Research Agent](https://docs.mem0.ai/cookbooks/operations/deep-research)

Run multi-session investigations that remember past findings and preferences.

Deep Research is an intelligent agent that synthesizes large amounts of online data and completes complex research tasks, customized to your unique preferences and insights. Built on Mem0’s technology, it enhances AI-driven online exploration with personalized memories.

You can check out the GitHub repository here: [Personalized Deep Research](https://github.com/mem0ai/personalized-deep-research/tree/mem0)

### [Collaborative Task Assistant](https://docs.mem0.ai/cookbooks/operations/team-task-agent)

Coordinate multi-user projects with shared memories and roles.

Build a multi-user collaborative chat or task management system with Mem0. Each message is attributed to its author, and all messages are stored in a shared project space. Mem0 makes it easy to track contributions, sort and group messages, and collaborate in real time

### [Content Creation Workflow](https://docs.mem0.ai/cookbooks/operations/content-writing)

Store voice guidelines once and apply them across every draft.

This guide demonstrates how to leverage Mem0 to streamline content writing by applying your unique writing style and preferences using persistent memory.

### [Personalized AI Tutor](https://docs.mem0.ai/cookbooks/companions/ai-tutor)

Keep student progress and preferences persistent across tutoring sessions.

You can create a personalized AI Tutor using Mem0. This guide will walk you through the necessary steps and provide the complete code to get you started.

The Personalized AI Tutor leverages Mem0 to retain information across interactions, enabling a tailored learning experience. By integrating with OpenAI’s GPT-4 model, the tutor can provide detailed and context-aware responses to user queries.

### Search with Personal Context

Blend Tavily’s realtime results with personal context stored in Mem0.

Imagine asking a search assistant for “coffee shops nearby” and instead of generic results, it shows remote-work-friendly cafes with great WiFi in your city because it remembers you mentioned working remotely before. Or when you search for “lunchbox ideas for kids” it knows you have a 7-year-old daughter and recommends peanut-free options that align with her allergy.

That’s what we are going to build today, a Personalized Search Assistant powered by Mem0 for memory and [Tavily](https://tavily.com/) for real-time search.

Most assistants treat every query like they’ve never seen you before. That means repeating yourself about your location, diet, or preferences, and getting results that feel generic.

- With Mem0, your assistant builds a memory of the user’s world.
- With Tavily, it fetches fresh and accurate results in real time.

Together, they make every interaction smarter, faster, and more personal.

## Essential Tasks for Memory Management

- Memory "Recall"
  - Reading / querying
  - Semantic Search & Retrieval
- Tagging & Categorization
- Contextual Linking
- Memory Summarization
- Memory Expiration & Archiving
- Memory Versioning
- Memory Export / Import
- Memory storage
  - Vectors, graphs, RDBMS, etc
- Memory listing, exploration, & browsing
- salience boosting
- sectorization
- Memory 'reinforcement'
- Memory Ranking / scoring (Relevance, Freshness, Importance)

## Memory Platforms

### mcp/memory

- `search_nodes`: true,
- `read_graph`: true,
- `open_nodes`: true,
- `delete_relations`: true,
- `delete_observations`: true,
- `delete_entities`: true,
- `create_relations`: true,
- `create_entities`: true,
- `add_observations`: true

### graphiti

- `add_memory`: Store episodes and interactions in the knowledge graph
- `search_facts`: Find relevant facts and relationships
- `search_nodes`: Search for entity summaries and information
- `get_episodes`: Retrieve recent episodes for context
- `delete_episode`: Remove episodes from the graph
- `clear_graph`: Reset the knowledge graph entirely

### MCP Memory Service

- `store_memory`: Store a new memory with content and optional metadata
  - Args:
    - `content` (string, required): The content to store as memory
    - `tags` (array[string], optional): Optional tags to categorize the memory (accepts array or comma-separated string)
    - `memory_type` (string, optional): Type of memory (note, decision, task, reference)
    - `metadata` (dict, optional): Additional metadata for the memory (e.g., source, author, timestamp)
    - `client_hostname`: Client machine hostname for source tracking
  - **IMPORTANT - Content Length Limits:**
    - Cloudflare backend: 800 characters max (BGE model 512 token limit)
    - SQLite-vec backend: No limit (local storage)
    - Hybrid backend: 800 characters max (constrained by Cloudflare sync)
    - If content exceeds the backend's limit, it will be automatically split into
      multiple linked memory chunks with preserved context (50-char overlap).
      The splitting respects natural boundaries: paragraphs → sentences → words.
  - **Tag Formats - All Formats Supported:** Both the tags parameter AND metadata.tags accept ALL formats:
    - ✅ Array format: tags=["tag1", "tag2", "tag3"]
    - ✅ Comma-separated string: tags="tag1,tag2,tag3"
    - ✅ Single string: tags="single-tag"
    - ✅ In metadata: metadata={"tags": "tag1,tag2", "type": "note"}
    - ✅ In metadata (array): metadata={"tags": ["tag1", "tag2"], "type": "note"}
    - All formats are automatically normalized internally. If tags are provided in both
      the tags parameter and metadata.tags, they will be merged (duplicates removed).
  - Returns:
    - Dictionary with:
      - `success`: Boolean indicating if storage succeeded
      - `message`: Status message
      - `content_hash`: Hash of original content (for single memory)
      - `chunks_created`: Number of chunks (if content was split)
      - `chunk_hashes`: List of content hashes (if content was split)

- `retrieve_memory`: Retrieve memories based on semantic similarity to a query
  - Args:
    - `query` (string, required): Search query
    - `limit` (integer, optional): Maximum results to return (default: 10)
- `search_by_tag`: Search memories by specific tags
  - Args:
    - `tags` (array[string], required): Tags to search for
    - `operation` (string, optional): "AND" or "OR" logic (default: "AND")
- `delete_memory`: Delete a specific memory by content hash
  - Args:
    - `content_hash` (string, required): Hash of the memory to delete
- `check_database_health`: Check the health and status of the memory database
- `list_memories`: List memories with pagination and optional filtering.
  - Args:
    - page: Page number (1-based)
    - page_size: Number of memories per page
    - tag: Filter by specific tag
    - memory_type: Filter by memory type
  - Returns:
    - Dictionary with memories and pagination info

- `get_cache_stats`: Get MCP server global cache statistics for performance monitoring. Returns detailed metrics about storage and memory service caching, including hit rates, initialization times, and cache sizes.
  - use-cases:
    - Monitoring cache effectiveness
    - Debugging performance issues
    - Verifying cache persistence across stateless HTTP calls
  - Returns:
    - Dictionary with cache statistics:
      - total_calls: Total MCP server invocations
      - hit_rate: Overall cache hit rate percentage
      - storage_cache: Storage cache metrics (hits/misses/size)
      - service_cache: MemoryService cache metrics (hits/misses/size)
      - performance: Initialization time statistics (avg/min/max)
      - backend_info: Current storage backend configuration

### [BasicMemory](https://docs.basicmemory.com/guides/mcp-tools-reference/)

- Knowledge Management Tools
  - write_note
  - read_note
  - edit_note
  - view_note
  - delete_note
  - move_note
- Search and Discovery Tools
  - search_notes
  - recent_activity
  - build_context
  - list_directory
- Project Management
  - Tools
    - list_memory_projects
    - create_memory_project
    - delete_project
    - sync_status
    - Utility Tools
    - read_content
    - canvas
  - Project Modes
    - Multi-Project Mode (Default)
    - Default Project Mode
    - Single Project Mode
  - Project Resolution Hierarchy
- Prompt Tools
  - Interactive Prompts
    - ai_assistant_guide
    - continue_conversation
    - search_notes
    - recent_activity
    - sync_status
- ChatGPT-Specific Tools

### [Mem0](https://docs.mem0.ai/open-source/overview)

### [OpenMemory](https://github.com/CaviraOSS/OpenMemory)

- `add_memories`: Store new memory objects
- `search_memory`: Retrieve relevant memories
- `list_memories`: View all stored memory
- `delete_all_memories`: Clear memory entirely

- `openmemory_query`
- `openmemory_store`
- `openmemory_list`
- `openmemory_get`
- `openmemory_reinforce`

## Ideas, Thoughts, & Questions

### Memory Reranking strategies

### Zettelkasten Note Linking

When storing notes, automatically create links between related notes based on content similarity. This would help build a web of interconnected knowledge over time.

- Q: Should zettelkasten notes be a separate memory type or integrated into general notes?
- Q: How do notes relate to memories?

### How to handle memory archiving

### Memory Versioning & Updates

### How to handle "Lessons Learned" or evolving knowledge

### How to make memories more context-aware

### Privacy & Security Considerations

### Personal vs Shared Memories

Thinking about agents that need to collaborate and also stay fresh/unbiased.
Compare that to personal memories that are subjective and unique to a user.
