# Neo4j

If you have worked with graph databases or knowledge graphs before you have either used or heard of Neo4j. Neo4j added support for vector fields as a first class citizen to its nodes and vector search through Cipher syntax from its 5.18 release. It is a graph native database that now supports vector search. Which means that the primary use case it still knowledge graph that can have nodes that require fuzzy search.

## Pros

- Vector properties are first class citizens of the nodes so no need to create new/additional nodes.
- You can do similarity search as part of Cipher, which to me is the best query languages to be ever made (GQL you can ki$$ it 🍑).
- Neo4j supports much larger vectors of 4096 which is not necessarily the case for some of the other vector databases

## Caveats

- I have not experienced this first hand but heard from multiple DB gurus that past 100 million nodes Neo4j performance struggles quite a bit.
- If you need simple database of large number of documents where the relationship between the documents do not really matter much, I would say go with something simpler like ChromaDB or Weaviate.
- I am not sure if the community edition supports vector search. The enterprise edition requires a key to activate.
- Similar to MongoDB there is no native integration with embedding generation. But you can use libraries like Langchain or Griptape to get through that.
