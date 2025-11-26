# Graphiti MCP API

## Standard Tools

- `add_episode`: Add an episode to the knowledge graph (supports text, JSON, and message formats)
- `search_nodes`: Search the knowledge graph for relevant node summaries
- `search_facts`: Search the knowledge graph for relevant facts (edges between entities)
- `delete_entity_edge`: Delete an entity edge from the knowledge graph
- `delete_episode`: Delete an episode from the knowledge graph
- `get_entity_edge`: Get an entity edge by its UUID
- `get_episodes`: Get the most recent episodes for a specific group
- `clear_graph`: Clear all data from the knowledge graph and rebuild indices
- `get_status`: Get the status of the Graphiti MCP server and Neo4j connection

> Q: Can I add in the Zettelkasten tools?
>
> > `zk_create_note` Create a new note with a title, content, and optional tags
> > `zk_get_note` Retrieve a specific note by ID or title
> > `zk_update_note` Update an existing note's content or metadata
> > `zk_delete_note` Delete a note
> > `zk_create_link` Create links between notes
> > `zk_remove_link` Remove links between notes
> > `zk_search_notes` Search for notes by content, tags, or links
> > `zk_get_linked_notes` Find notes linked to a specific note
> > `zk_get_all_tags` List all tags in the system
> > `zk_find_similar_notes` Find notes similar to a given note
> > `zk_find_central_notes` Find notes with the most connections
> > `zk_find_orphaned_notes` Find notes with no connections
> > `zk_list_notes_by_date` List notes by creation/update date
> > `zk_rebuild_index` Rebuild the database index from Markdown files
