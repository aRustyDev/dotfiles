# Meilisearch Local Setup

Fast, typo-tolerant search engine optimized for local development on MacBook Pro M5 (32GB RAM).

## Quick Start

```bash
# Stage 1: Install & run (insecure, for validation)
just install
just start-dev-bg
just health

# Stage 2: Test integration
just test-index
just info
just metrics

# Stage 3: Production setup
just setup-prod
just launchd-load
```

## Three-Stage Setup

### Stage 1: Installation (Insecure)

Basic setup for validating justfile logic and testing locally:

| Recipe | Description |
|--------|-------------|
| `install` | Install via Homebrew |
| `config-dev` | Generate development config (no auth) |
| `start-dev` | Start in foreground |
| `start-dev-bg` | Start in background |
| `stop-dev` | Stop background process |
| `validate-config` | Validate TOML syntax |
| `clean` | Delete all data (destructive) |

### Stage 2: Health & Integration

Verify Meilisearch is healthy and reachable:

| Recipe | Description |
|--------|-------------|
| `health` | Check `/health` endpoint |
| `ping` | Quick connectivity test |
| `info` | Version and stats |
| `list-indexes` | List all indexes |
| `test-index` | Create/query test index |
| `metrics` | Prometheus metrics |
| `logs` | Tail log file |
| `tasks` | View task queue |
| `dump` | Create data dump |

### Stage 3: Production Hardening

Secure configuration with SSL, API keys, and persistence:

| Recipe | Description |
|--------|-------------|
| `mkcerts` | Generate SSL certs via mkcert |
| `config-prod` | Generate production config |
| `start-prod` | Start with 1Password secrets |
| `launchd-install` | Create LaunchAgent plist |
| `launchd-load` | Enable auto-start |
| `launchd-unload` | Disable auto-start |
| `create-api-keys` | Generate API keys |
| `setup-logrotate` | Configure log rotation |
| `setup-prod` | Full production setup |

## Configuration

### Development (Stage 1-2)

- URL: `http://127.0.0.1:7700`
- No authentication required
- Metrics enabled at `/metrics`
- 8GB indexing memory, 8 threads

### Production (Stage 3)

- URL: `https://127.0.0.1:7700`
- Master key from 1Password: `op://Developer/meilisearch/credential`
- SSL via mkcert local CA
- Daily snapshots enabled
- LaunchAgent for persistence

## 1Password Setup

Create a Meilisearch item in your Developer vault:

```bash
op item create \
  --vault Developer \
  --category login \
  --title meilisearch \
  --fields "credential=$(openssl rand -base64 32)"
```

## MCP Integration

Add to your Claude config:

```json
{
  "mcpServers": {
    "meilisearch": {
      "command": "npx",
      "args": ["-y", "meilisearch-mcp"],
      "env": {
        "MEILI_HOST": "http://127.0.0.1:7700",
        "MEILI_API_KEY": "your-search-api-key"
      }
    }
  }
}
```

## Directory Structure

```
~/.local/share/meilisearch/    # Data directory
  data.ms/                     # Database files
  dumps/                       # Backup dumps
  snapshots/                   # Scheduled snapshots
  certs/                       # SSL certificates

~/.config/meilisearch/         # Configuration
  config.toml                  # Development config
  config-prod.toml             # Production config (template)

~/.local/state/meilisearch/    # Runtime state
  config-runtime.toml          # Injected production config
  meilisearch.pid              # PID file
  logs/                        # Log files
```

## CLI Reference

```bash
meilisearch \
  --config-file-path <path>           # Config file
  --db-path <path>                    # Database location
  --http-addr <host:port>             # Listen address
  --master-key <key>                  # Auth key (16+ bytes)
  --env <development|production>      # Environment
  --log-level <OFF|ERROR|WARN|INFO|DEBUG|TRACE>
  --max-indexing-memory <size>        # e.g., "8 GiB"
  --max-indexing-threads <n>          # CPU threads
  --no-analytics                      # Disable telemetry
  --ssl-cert-path <path>              # SSL certificate
  --ssl-key-path <path>               # SSL private key
  --experimental-enable-metrics       # Prometheus /metrics
```

## Resources

- [Meilisearch Docs](https://www.meilisearch.com/docs)
- [Configuration Options](https://www.meilisearch.com/docs/learn/configuration/instance_options)
- [API Reference](https://www.meilisearch.com/docs/reference/api/overview)
- [Meilisearch MCP](https://github.com/meilisearch/meilisearch-mcp)
