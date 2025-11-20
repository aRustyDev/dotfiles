# id: 2d8f9e1a-4c7b-5e3d-9a6f-8c7d6e5f4a3b
# Hosting Multiple Database UIs with Traefik

This guide explains how to host multiple database UIs (FalkorDB, PostgreSQL, MongoDB, etc.) behind Traefik using different routing strategies.

## The Challenge

You want to access multiple database UIs like:
- `db.localhost/ui/falkor` → FalkorDB UI
- `db.localhost/ui/postgres` → PostgreSQL Admin UI
- `db.localhost/ui/mongo` → MongoDB Compass Web

**Problem**: Modern web apps (Next.js, React, Vue) use absolute asset paths like `/_next/static/...` or `/static/js/...` which break with path-based routing.

## Solution Options

### Option 1: Different Subdomains (Recommended ⭐)

Use separate subdomains for each database UI.

**URLs**:
- `http://falkor.localhost/` → FalkorDB UI
- `http://postgres.localhost/` → PostgreSQL UI  
- `http://mongo.localhost/` → MongoDB UI

**Pros**:
- ✅ Clean, simple configuration
- ✅ No asset loading issues
- ✅ Each app thinks it's at root `/`
- ✅ Easy to add new UIs
- ✅ Industry standard pattern

**Cons**:
- Different hostnames (minor UX consideration)
- Need to remember multiple subdomains

**Configuration**:

```yaml
# FalkorDB
falkordb:
  image: falkordb/falkordb:latest
  container_name: falkordb
  ports:
    - "6379:6379"
    - "3000:3000"
  labels:
    traefik.enable: true
    traefik.http.services.falkorui.loadbalancer.server.port: 3000
    traefik.http.routers.falkorui.rule: Host(`falkor.localhost`)
    traefik.http.routers.falkorui.service: falkorui
    traefik.http.routers.falkorui.entrypoints: web

# PostgreSQL (pgAdmin)
pgadmin:
  image: dpage/pgadmin4:latest
  container_name: pgadmin
  ports:
    - "5050:80"
  environment:
    PGADMIN_DEFAULT_EMAIL: admin@example.com
    PGADMIN_DEFAULT_PASSWORD: admin
  labels:
    traefik.enable: true
    traefik.http.services.pgadmin.loadbalancer.server.port: 80
    traefik.http.routers.pgadmin.rule: Host(`postgres.localhost`)
    traefik.http.routers.pgadmin.service: pgadmin
    traefik.http.routers.pgadmin.entrypoints: web

# MongoDB (Mongo Express)
mongo-express:
  image: mongo-express:latest
  container_name: mongo-express
  ports:
    - "8081:8081"
  environment:
    ME_CONFIG_MONGODB_URL: mongodb://mongo:27017/
  labels:
    traefik.enable: true
    traefik.http.services.mongoui.loadbalancer.server.port: 8081
    traefik.http.routers.mongoui.rule: Host(`mongo.localhost`)
    traefik.http.routers.mongoui.service: mongoui
    traefik.http.routers.mongoui.entrypoints: web
```

---

### Option 2: Path-Based with Asset Rewriting (Advanced)

Use a single domain with path prefixes, but rewrite asset requests.

**URLs**:
- `http://db.localhost/ui/falkor` → FalkorDB UI
- `http://db.localhost/ui/postgres` → PostgreSQL UI

**Pros**:
- ✅ Single domain
- ✅ Logical URL structure

**Cons**:
- ❌ Complex Traefik configuration
- ❌ Requires middleware for each app
- ❌ Can break with app updates
- ❌ Hard to maintain

**Configuration**:

```yaml
falkordb:
  labels:
    traefik.enable: true
    
    # Service definition
    traefik.http.services.falkorui.loadbalancer.server.port: 3000
    
    # Main app route
    traefik.http.routers.falkorui-app.rule: Host(`db.localhost`) && PathPrefix(`/ui/falkor`)
    traefik.http.routers.falkorui-app.service: falkorui
    traefik.http.middlewares.falkor-strip.stripprefix.prefixes: /ui/falkor
    traefik.http.routers.falkorui-app.middlewares: falkor-strip
    
    # Asset routes (Next.js specific)
    traefik.http.routers.falkorui-assets.rule: Host(`db.localhost`) && (PathPrefix(`/_next`) || PathPrefix(`/static`))
    traefik.http.routers.falkorui-assets.service: falkorui
    # No strip prefix for assets - they need to go directly
```

**Warning**: This approach is fragile and may break when apps update their asset paths.

---

### Option 3: Hybrid Approach (Practical ⭐⭐)

Use subdomains for complex apps (Next.js, React) and paths for simple ones.

**URLs**:
- `http://falkor.localhost/` → FalkorDB UI (Next.js - needs subdomain)
- `http://db.localhost/adminer` → Adminer (simple PHP - works with paths)
- `http://db.localhost/phpmyadmin` → phpMyAdmin (simple - works with paths)

**Strategy**:
- **Subdomain**: For apps with complex JS frameworks
- **Path**: For simple apps or those with base path support

**Configuration**:

```yaml
# Complex app - use subdomain
falkordb:
  labels:
    traefik.http.routers.falkorui.rule: Host(`falkor.localhost`)
    # ... rest of config

# Simple app - use path
adminer:
  image: adminer:latest
  container_name: adminer
  labels:
    traefik.enable: true
    traefik.http.services.adminer.loadbalancer.server.port: 8080
    traefik.http.routers.adminer.rule: Host(`db.localhost`) && PathPrefix(`/adminer`)
    traefik.http.routers.adminer.service: adminer
    traefik.http.middlewares.adminer-strip.stripprefix.prefixes: /adminer
    traefik.http.routers.adminer.middlewares: adminer-strip
```

---

### Option 4: Organize by Database Type

Group UIs by database type using different subdomains.

**URLs**:
- `http://graph.localhost/` → FalkorDB (graph database)
- `http://relational.localhost/pgadmin` → PostgreSQL
- `http://relational.localhost/mysql` → MySQL
- `http://document.localhost/` → MongoDB

**Pros**:
- ✅ Logical organization
- ✅ Flexible routing per subdomain

**Cons**:
- More complex mental model
- Mixed routing strategies

---

### Option 5: Port-Based (Not Recommended)

Each UI on a different port.

**URLs**:
- `http://db.localhost:3000/` → FalkorDB
- `http://db.localhost:5050/` → PostgreSQL
- `http://db.localhost:8081/` → MongoDB

**Pros**:
- Simple configuration
- No routing complexity

**Cons**:
- ❌ Poor user experience (remembering ports)
- ❌ Doesn't use Traefik effectively
- ❌ Not production-ready

---

## Recommended Solution: Multiple Subdomains

For your specific use case (`db.localhost/ui/falkor` + `db.localhost/ui/postgres`), here's the recommended approach:

### Strategy

Use database-specific subdomains:

```
falkor.localhost     → FalkorDB UI
postgres.localhost   → PostgreSQL Admin (pgAdmin)
mysql.localhost      → MySQL Admin (phpMyAdmin)
mongo.localhost      → MongoDB UI (Mongo Express)
redis.localhost      → Redis Commander
```

### Implementation

```yaml
services:
  # FalkorDB
  falkordb:
    image: falkordb/falkordb:latest
    container_name: falkordb
    ports:
      - "6379:6379"
      - "3000:3000"
    volumes:
      - ${XDG_DATA_HOME:-$HOME/.local/share}/mcp/falkordb:/data
    labels:
      traefik.enable: true
      traefik.http.services.falkorui.loadbalancer.server.port: 3000
      traefik.http.routers.falkorui.rule: Host(`falkor.localhost`)
      traefik.http.routers.falkorui.service: falkorui
      traefik.http.routers.falkorui.entrypoints: web

  # PostgreSQL + pgAdmin
  postgres:
    image: postgres:16-alpine
    container_name: postgres
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_USER: postgres
      POSTGRES_DB: postgres
    volumes:
      - ${XDG_DATA_HOME:-$HOME/.local/share}/mcp/postgres:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@localhost.local
      PGADMIN_DEFAULT_PASSWORD: admin
      PGADMIN_CONFIG_SERVER_MODE: 'False'
      PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: 'False'
    volumes:
      - ${XDG_DATA_HOME:-$HOME/.local/share}/mcp/pgadmin:/var/lib/pgadmin
    labels:
      traefik.enable: true
      traefik.http.services.pgadmin.loadbalancer.server.port: 80
      traefik.http.routers.pgadmin.rule: Host(`postgres.localhost`)
      traefik.http.routers.pgadmin.service: pgadmin
      traefik.http.routers.pgadmin.entrypoints: web

  # MongoDB + Mongo Express
  mongodb:
    image: mongo:7
    container_name: mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    volumes:
      - ${XDG_DATA_HOME:-$HOME/.local/share}/mcp/mongodb:/data/db
    ports:
      - "27017:27017"

  mongo-express:
    image: mongo-express:latest
    container_name: mongo-express
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: root
      ME_CONFIG_MONGODB_ADMINPASSWORD: example
      ME_CONFIG_MONGODB_URL: mongodb://root:example@mongodb:27017/
      ME_CONFIG_BASICAUTH: false
    labels:
      traefik.enable: true
      traefik.http.services.mongoui.loadbalancer.server.port: 8081
      traefik.http.routers.mongoui.rule: Host(`mongo.localhost`)
      traefik.http.routers.mongoui.service: mongoui
      traefik.http.routers.mongoui.entrypoints: web
    depends_on:
      - mongodb

  # Redis + Redis Commander
  redis:
    image: redis:7-alpine
    container_name: redis
    ports:
      - "6380:6379"
    volumes:
      - ${XDG_DATA_HOME:-$HOME/.local/share}/mcp/redis:/data

  redis-commander:
    image: rediscommander/redis-commander:latest
    container_name: redis-commander
    environment:
      REDIS_HOSTS: local:redis:6379
    labels:
      traefik.enable: true
      traefik.http.services.redisui.loadbalancer.server.port: 8081
      traefik.http.routers.redisui.rule: Host(`redis.localhost`)
      traefik.http.routers.redisui.service: redisui
      traefik.http.routers.redisui.entrypoints: web
    depends_on:
      - redis
```

---

## Alternative: Unified Database Portal

Create a custom landing page at `db.localhost` with links to all database UIs:

```yaml
# Custom nginx landing page
db-portal:
  image: nginx:alpine
  container_name: db-portal
  volumes:
    - ./db-portal/index.html:/usr/share/nginx/html/index.html:ro
  labels:
    traefik.enable: true
    traefik.http.services.dbportal.loadbalancer.server.port: 80
    traefik.http.routers.dbportal.rule: Host(`db.localhost`)
    traefik.http.routers.dbportal.service: dbportal
    traefik.http.routers.dbportal.entrypoints: web
```

**db-portal/index.html**:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Database Management Portal</title>
    <style>
        body { font-family: Arial; max-width: 800px; margin: 50px auto; }
        .db-card { border: 1px solid #ddd; padding: 20px; margin: 10px 0; border-radius: 5px; }
        .db-card:hover { background: #f5f5f5; }
        a { text-decoration: none; color: #333; }
    </style>
</head>
<body>
    <h1>🗄️ Database Management Portal</h1>
    
    <a href="http://falkor.localhost">
        <div class="db-card">
            <h3>📊 FalkorDB (Graph Database)</h3>
            <p>Redis-based graph database with Cypher query support</p>
        </div>
    </a>
    
    <a href="http://postgres.localhost">
        <div class="db-card">
            <h3>🐘 PostgreSQL (pgAdmin)</h3>
            <p>Relational database administration</p>
        </div>
    </a>
    
    <a href="http://mongo.localhost">
        <div class="db-card">
            <h3>🍃 MongoDB (Mongo Express)</h3>
            <p>Document database management</p>
        </div>
    </a>
    
    <a href="http://redis.localhost">
        <div class="db-card">
            <h3>⚡ Redis (Commander)</h3>
            <p>In-memory data structure store</p>
        </div>
    </a>
</body>
</html>
```

Now you have:
- `http://db.localhost/` → Portal with links to all DBs
- `http://falkor.localhost/` → FalkorDB UI
- `http://postgres.localhost/` → PostgreSQL UI
- `http://mongo.localhost/` → MongoDB UI
- `http://redis.localhost/` → Redis UI

---

## Comparison Matrix

| Approach | Complexity | Maintenance | UX | Works with Modern Apps |
|----------|-----------|-------------|----|-----------------------|
| Multiple Subdomains | ⭐ Low | ⭐ Easy | ⭐⭐⭐ Good | ✅ Yes |
| Path + Asset Rewrite | ⭐⭐⭐ High | ⭐⭐⭐ Hard | ⭐⭐⭐ Good | ⚠️ Sometimes |
| Hybrid | ⭐⭐ Medium | ⭐⭐ Medium | ⭐⭐ OK | ✅ Yes |
| Portal + Subdomains | ⭐ Low | ⭐ Easy | ⭐⭐⭐⭐ Excellent | ✅ Yes |
| Ports | ⭐ Low | ⭐ Easy | ⭐ Poor | ✅ Yes |

---

## Decision Tree

```
Do you control the app's source code?
├─ YES → Can configure basePath?
│   ├─ YES → Use path-based routing
│   └─ NO  → Use subdomain routing
└─ NO (3rd party app)
    ├─ Simple app (PHP, static) → Try path-based
    └─ Modern app (Next.js, React) → Use subdomain routing
```

---

## Testing Your Setup

```bash
# Test each database UI
curl -I http://falkor.localhost/
curl -I http://postgres.localhost/
curl -I http://mongo.localhost/

# Check Traefik sees all routes
curl -s http://localhost:8080/api/http/routers | jq '.[].name'

# Verify assets load
curl -I http://falkor.localhost/_next/static/chunks/webpack-*.js
```

---

## Migration Path

If you're currently using `db.localhost/ui/falkor`:

1. **Add subdomain routing** alongside existing:
   ```yaml
   # Keep old route for compatibility
   traefik.http.routers.falkorui-legacy.rule: Host(`db.localhost`) && PathPrefix(`/ui/falkor`)
   
   # Add new subdomain route
   traefik.http.routers.falkorui.rule: Host(`falkor.localhost`)
   ```

2. **Update bookmarks/links** to use new subdomain

3. **Remove legacy route** after transition period

---

## Best Practices

1. **Use subdomains for production** - More reliable, easier to maintain
2. **Create a portal page** - Better UX than remembering subdomains
3. **Document your routing** - Keep a reference of all DB UI URLs
4. **Test asset loading** - Always verify JS/CSS loads correctly
5. **Monitor Traefik logs** - Catch routing issues early

---

## Real-World Example: Complete DB Stack

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:latest
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

  # Portal
  db-portal:
    image: nginx:alpine
    volumes:
      - ./db-portal:/usr/share/nginx/html:ro
    labels:
      traefik.enable: true
      traefik.http.routers.dbportal.rule: Host(`db.localhost`)

  # Graph DB
  falkordb:
    image: falkordb/falkordb:latest
    volumes:
      - falkordb-data:/data
    labels:
      traefik.enable: true
      traefik.http.services.falkorui.loadbalancer.server.port: 3000
      traefik.http.routers.falkorui.rule: Host(`falkor.localhost`)

  # Relational DB
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres-data:/var/lib/postgresql/data

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@localhost.local
      PGADMIN_DEFAULT_PASSWORD: admin
      PGADMIN_CONFIG_SERVER_MODE: 'False'
    volumes:
      - pgadmin-data:/var/lib/pgadmin
    labels:
      traefik.enable: true
      traefik.http.routers.pgadmin.rule: Host(`postgres.localhost`)

  # Document DB
  mongodb:
    image: mongo:7
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    volumes:
      - mongo-data:/data/db

  mongo-express:
    image: mongo-express
    environment:
      ME_CONFIG_MONGODB_URL: mongodb://root:example@mongodb:27017/
      ME_CONFIG_BASICAUTH: false
    labels:
      traefik.enable: true
      traefik.http.routers.mongoui.rule: Host(`mongo.localhost`)

volumes:
  falkordb-data:
  postgres-data:
  pgadmin-data:
  mongo-data:
```

**Access**:
- Portal: http://db.localhost/
- FalkorDB: http://falkor.localhost/
- PostgreSQL: http://postgres.localhost/
- MongoDB: http://mongo.localhost/
- Traefik Dashboard: http://localhost:8080/

---

## Summary

**For your question**: "Can I have `db.localhost/ui/falkor` AND `db.localhost/ui/postgres`?"

**Short Answer**: Not easily with modern web apps.

**Recommended Solution**: Use separate subdomains:
- `falkor.localhost` for FalkorDB
- `postgres.localhost` for PostgreSQL
- Optional: `db.localhost` as a portal page linking to both

This approach is:
- ✅ Simple to configure
- ✅ Reliable for all app types
- ✅ Easy to maintain
- ✅ Industry standard
- ✅ Scalable (easy to add more DBs)

---

**Last Updated**: 2025-11-19  
**Related Docs**:
- `TRAEFIK_PROXY_GUIDE.md` - General Traefik configuration
- `global.yaml` - Current deployment configuration
