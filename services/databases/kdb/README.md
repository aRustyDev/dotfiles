# KDB

Originating from the team that created KDB+, KDB.AI vector database SKU of KDB+. Unlike Mongo, Chroma and Weaviate, KDB.AI is an RDBMS and needs a schema. The saving grace is that although this an RDBMS, neighter the Python Driver nor the API requires you to write SQL (Did I say I don’t SQL)

## Pros

- Vector search support hybrid queries to include both sparse and dense vectors.
- It also optimized for time series queries making it great for temporal anomaly analysis such fraud detection, product abuse detection, security detection.
- KDB.AI is an RDBMS, time-series DB and vector DB all in one. This makes it quite a starter choice for a general purpose database for a GenAI application.
- KDB.AI is incredibly fast even for a large load and relatively light weight.

## Min Sys Req
- 1 vCPU and 4 Gi RAM (although I have run it with 2 Gi)

### PostgreSQL

Officially the most feature rich DB, PostgreSQL could not sit out the vector DB war. There is an open source extension for Postgres that is in active development.

#### Pros

- If a part of your code base (the non-vector stuff) is already using Postgres or you are already familiar with the ecosystem, it may make sense to continue with it for now at least for prototyping to reduce the learning time.
- There is no feature Postgres doesn’t have. So if you have an eclectic storage and usage of data, this is a one stop shop.

#### Caveats

- It’s all SQL baby. If you are not a fan of SQL, don’t even touch this.
- Performance is meh 😒.
- Unless you need a relational database I don’t see the point of using Postgres. Even in that case, KDB.AI kicks butt!
