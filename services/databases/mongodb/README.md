# MongoDB

Probably the most popular Document DB among web app developers for its Javascript like input and query language (and not having to use SQL). This is definitely my personal favorite general purpose database. Its API and Drivers really thought about how web app developers thinking about managing and accessing data making it quite intuitive for people like me who DO NOT LIKE SQL. MongoDB also supports storing vectors and similarity search as a first class member of the data objects/documents along with their scalar fields. Along with vector similarity search it also supports filters using scalar fields in the documents/data objects. On top of that MongoDB has be around for quite some time and the code base in rock solid.

## Special Features

- You don’t have to create separate documents/data-objects to hold your vector fields. The vector fields are 1st class member of the documents (like the scalar fields)
- Each document can support multiple vector fields.
- There are drivers for pretty much every language I could think of.

## Caveats

- Maximum vector length is 2048 (This may have changed now)
