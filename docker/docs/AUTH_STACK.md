# Authentication & Authorization Stack

This document covers the authentication (AuthN) and authorization (AuthZ) services configured in this Docker Compose setup.

## Overview

The stack provides a complete identity and access management solution using:

| Component | Purpose | Port(s) |
|-----------|---------|---------|
| **ORY Kratos** | Identity Management (registration, login, MFA) | 4433, 4434 |
| **ORY Hydra** | OAuth 2.0 / OpenID Connect Provider | 4444, 4445 |
| **ORY Oathkeeper** | Identity-Aware Proxy (API Gateway) | 4455, 4456 |
| **ORY Keto** | Permission Server (Zanzibar-style) | 4466-4469 |
| **AuthZed SpiceDB** | Authorization Database (Zanzibar-style) | 50051, 8443 |

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           Traefik                                    │
│                      (Reverse Proxy + TLS)                          │
└───────────────┬─────────────────────────────────────┬───────────────┘
                │                                     │
        ┌───────▼───────┐                     ┌───────▼───────┐
        │ id.localhost  │                     │authz.localhost│
        └───────┬───────┘                     └───────┬───────┘
                │                                     │
    ┌───────────┼───────────┐             ┌──────────┼──────────┐
    │           │           │             │          │          │
┌───▼───┐  ┌────▼────┐  ┌───▼────┐   ┌────▼────┐  ┌──▼───┐
│Kratos │  │  Hydra  │  │Oathkpr │   │ SpiceDB │  │ Keto │
│       │  │         │  │        │   │         │  │      │
│Identity│  │OAuth2/  │  │  API   │   │  AuthZ  │  │Perms │
│Mgmt   │  │ OIDC    │  │Gateway │   │   DB    │  │Server│
└───┬───┘  └────┬────┘  └───┬────┘   └────┬────┘  └──┬───┘
    │           │           │             │          │
    └───────────┴───────────┴─────────────┴──────────┘
                            │
                    ┌───────▼───────┐
                    │   PostgreSQL  │
                    │  (Databases)  │
                    └───────────────┘
```

## Quick Start

### 1. Start the Stack

```bash
# Start all auth services
docker-compose -f modules/authn/kratos.yaml \
               -f modules/authn/hydra.yaml \
               -f modules/authn/oathkeeper.yaml \
               -f modules/authz/keto.yaml \
               -f modules/authz/spicedb.yaml \
               up -d

# Or with dev tools (mailslurper for email testing)
docker-compose -f modules/authn/kratos.yaml --profile dev up -d
```

### 2. Verify Services

```bash
# Check health endpoints
curl -s https://id.localhost/health/ready
curl -s https://authz.localhost/health/ready

# Check OIDC discovery
curl -s https://id.localhost/.well-known/openid-configuration | jq
```

## Component Details

### ORY Kratos (Identity Management)

Handles user registration, login, account recovery, and profile management.

**Endpoints:**
- `https://id.localhost/self-service/login/browser` - Login flow
- `https://id.localhost/self-service/registration/browser` - Registration
- `https://id.localhost/self-service/recovery/browser` - Password recovery
- `https://id.localhost/sessions/whoami` - Current session info

**Configuration:**
- Main config: `config/ory/kratos/kratos.yaml`
- Identity schema: `config/ory/kratos/schemas/identity.schema.json`

**Features:**
- Email/password authentication
- WebAuthn (passwordless)
- TOTP (2FA)
- Account recovery via email
- Email verification

### ORY Hydra (OAuth 2.0 / OIDC)

Provides OAuth 2.0 and OpenID Connect capabilities.

**Endpoints:**
- `https://id.localhost/.well-known/openid-configuration` - OIDC Discovery
- `https://id.localhost/oauth2/auth` - Authorization endpoint
- `https://id.localhost/oauth2/token` - Token endpoint
- `https://id.localhost/admin/*` - Admin API (internal)

**Configuration:**
- Main config: `config/ory/hydra/hydra.yaml`

**Features:**
- OAuth 2.0 Authorization Code + PKCE
- OpenID Connect Core 1.0
- JWT access tokens
- Refresh token rotation

### ORY Oathkeeper (API Gateway)

Identity-Aware Proxy that enforces authentication and authorization.

**Endpoints:**
- `https://id.localhost/decisions` - ForwardAuth endpoint for Traefik
- Port 4455 - Proxy mode (direct routing)
- Port 4456 - API mode (management)

**Configuration:**
- Main config: `config/ory/oathkeeper/oathkeeper.yaml`
- Access rules: `config/ory/oathkeeper/rules/access-rules.yaml`

**Authenticators:**
- `anonymous` - No authentication
- `cookie_session` - Kratos session cookie
- `bearer_token` - OAuth 2.0 token introspection
- `jwt` - JWT validation

**Authorizers:**
- `allow` - Allow all
- `deny` - Deny all
- `remote_json` - Keto permission check

### ORY Keto (Permissions)

Google Zanzibar-inspired permission server.

**Endpoints:**
- `https://authz.localhost/relation-tuples/check` - Check permissions
- `https://authz.localhost/expand` - Expand permission tree
- `https://authz.localhost/admin/relation-tuples` - Manage tuples

**Configuration:**
- Main config: `config/ory/keto/keto.yaml`
- Namespaces: `config/ory/keto/namespaces/namespaces.keto.ts`

**Example Permission Check:**
```bash
curl -X POST https://authz.localhost/relation-tuples/check \
  -H "Content-Type: application/json" \
  -H "X-Service: keto" \
  -d '{
    "namespace": "Resource",
    "object": "doc-123",
    "relation": "read",
    "subject_id": "user-456"
  }'
```

### AuthZed SpiceDB (Authorization Database)

Alternative Zanzibar implementation with more features.

**Endpoints:**
- `https://authz.localhost/api/*` - HTTP API
- Port 50051 - gRPC API (direct)
- Port 9090 - Metrics

**Configuration:**
- Schema: `config/spicedb/schema.zed`

**Example Schema:**
```zed
definition user {}

definition resource {
    relation owner: user
    relation viewer: user

    permission view = owner + viewer
    permission edit = owner
}
```

## Traefik Integration

### Routing Configuration

Routes are defined in `config/traefik/dynamic/`:
- `svc.authn.kratos.yaml`
- `svc.authn.hydra.yaml`
- `svc.authn.oathkeeper.yaml`
- `svc.authz.keto.yaml`
- `svc.authz.spicedb.yaml`

### ForwardAuth Middlewares

Available in `core.middlewares.yaml`:

```yaml
# Full Oathkeeper authentication/authorization
oathkeeper-auth@file

# Lightweight Kratos session check
kratos-session@file
```

**Usage in Traefik:**
```yaml
http:
  routers:
    my-protected-route:
      rule: "Host(`api.localhost`)"
      middlewares:
        - oathkeeper-auth@file
      service: my-service
```

## Database Setup

PostgreSQL databases are auto-created via `config/postgres/initdb.d/auth.sql`:

| Database | User | Purpose |
|----------|------|---------|
| `hydra` | `hydra` | OAuth 2.0 data |
| `kratos` | `kratos` | Identity data |
| `keto` | `keto` | Permission tuples |
| `spicedb` | `spicedb` | Authorization data |

## Environment Variables

### Secrets (Required)

```bash
# Hydra
HYDRA_SECRETS_SYSTEM=<32-byte-hex>  # openssl rand -hex 32
HYDRA_SECRETS_COOKIE=<32-byte-hex>

# Kratos
KRATOS_SECRETS_DEFAULT=<32-byte-hex>
KRATOS_SECRETS_COOKIE=<32-byte-hex>

# SpiceDB
SPICEDB_GRPC_PRESHARED_KEY=<your-key>
```

### Database Connection

```bash
# Override default database URLs
HYDRA_DSN=postgres://user:pass@host:5432/hydra
KRATOS_DSN=postgres://user:pass@host:5432/kratos
KETO_DSN=postgres://user:pass@host:5432/keto
SPICEDB_DATASTORE_CONN_URI=postgres://user:pass@host:5432/spicedb
```

### URLs

```bash
HYDRA_URLS_SELF_ISSUER=https://id.localhost
HYDRA_URLS_LOGIN=https://id.localhost/login
HYDRA_URLS_CONSENT=https://id.localhost/consent

KRATOS_PUBLIC_URL=https://id.localhost
```

## Common Tasks

### Create an OAuth 2.0 Client

```bash
# Using Hydra CLI
docker exec hydra hydra create client \
  --endpoint http://localhost:4445 \
  --grant-type authorization_code,refresh_token \
  --response-type code \
  --scope openid,offline_access \
  --redirect-uri https://myapp.localhost/callback \
  --name "My Application"
```

### Create a User (Kratos)

```bash
curl -X POST https://id.localhost/self-service/registration/browser \
  -H "Content-Type: application/json"
# Follow the returned flow URL
```

### Add Permission Tuple (Keto)

```bash
curl -X PUT https://authz.localhost/admin/relation-tuples \
  -H "Content-Type: application/json" \
  -H "X-Service: keto" \
  -d '{
    "namespace": "Resource",
    "object": "doc-123",
    "relation": "owner",
    "subject_id": "user-456"
  }'
```

### Add Relationship (SpiceDB)

```bash
# Using zed CLI
zed relationship create resource:doc-123 owner user:456 \
  --endpoint localhost:50051 \
  --token $SPICEDB_GRPC_PRESHARED_KEY
```

## Choosing Between Keto and SpiceDB

Both implement Zanzibar-style permissions. Choose based on:

| Feature | Keto | SpiceDB |
|---------|------|---------|
| ORY Integration | Native | Manual |
| Schema Language | TypeScript | ZED |
| Watch API | No | Yes |
| Caveats | No | Yes |
| Bulk Operations | Limited | Full |
| Playground UI | No | Yes |

**Recommendation:** Use SpiceDB for complex authorization needs, Keto for simpler ORY-native setups.

## Troubleshooting

### Check Service Logs

```bash
docker logs kratos
docker logs hydra
docker logs oathkeeper
docker logs keto
docker logs spicedb
```

### Common Issues

1. **Database connection errors**
   - Ensure PostgreSQL is running and healthy
   - Check DSN environment variables
   - Verify databases exist (run init scripts)

2. **CORS errors**
   - Check allowed origins in service configs
   - Verify Traefik CORS middleware

3. **Session not found**
   - Check cookie domain settings
   - Verify Kratos session lifespan

4. **OAuth token invalid**
   - Check Hydra issuer URL matches
   - Verify JWKS endpoint is accessible

## Security Considerations

1. **Secrets Management**
   - Use 1Password references (`op://...`) or proper secret management
   - Rotate secrets periodically
   - Never commit secrets to version control

2. **Network Security**
   - Admin APIs should not be publicly accessible
   - Use Traefik middlewares for additional protection
   - Consider IP whitelisting for admin endpoints

3. **TLS**
   - All public endpoints use HTTPS via Traefik
   - Internal service communication can be HTTP (Docker network)

## References

- [ORY Documentation](https://www.ory.sh/docs/)
- [SpiceDB Documentation](https://authzed.com/docs/)
- [Google Zanzibar Paper](https://research.google/pubs/pub48190/)
- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [OpenID Connect Core](https://openid.net/specs/openid-connect-core-1_0.html)
