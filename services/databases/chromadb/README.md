# ChromaDB

the newest kid in the block of vector databases. It is open source, free to use, designed to run in memory and optimized to be a vector database. Its Python & Javascript SDK and REST API function like a simplified Document DB (no schema needed). So no need to learn/re-learn SQL. It allows for scalar search filter to rein down the vector search scope for efficiency. I ran it using 100000+ docs and it doesn’t even sweat.

## Special Features

- The Python SDK can run embedding models locally (downloaded from HuggingFace) or call external embedding APIs (like OpenAI) under the hood so you don’t have write addition code for generating embeddings for search.
- It supports URIs as 1st class citizen where content gets downloaded and embedded under the hood.
- If you don’t want vector fields/vector search you can also use it like a simple document DB.
- It supports fuzzy text search search on documents with large text fields like MongoDB.

## Caveats

- ChromaDB is currently in Alpha release. It does not have a cloud hosted instance. Although their website claims that it will be a thing in future but the timeline is unclear.
- The metadata cannot have nested compound fields: as in the fields can be either simple types or array.
- Although The query syntax is also not as rich to support various scenarios like Mongodb but it is the simplicity and very focused use case is what gives it an advantage.
- Unlike MongoDB, each document/data-object can have ONLY one vector field.
