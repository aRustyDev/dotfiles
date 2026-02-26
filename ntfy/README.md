# ntfy

Push notifications made easy - send notifications to your phone or desktop.

## Current Configuration

- `client.yml` - Client configuration for subscribing/publishing
- `server.yaml` - Example server configuration (for self-hosting)
- `brewfile` - ntfy CLI

### Features

- **Simple publishing**: Send notifications via CLI or HTTP
- **Subscriptions**: Subscribe to topics for real-time notifications
- **Actions**: Add clickable buttons to notifications
- **Priorities**: urgent, high, default, low, min

## Installation

```bash
just -f ntfy/justfile install
```

## Usage

### Publishing Notifications

```bash
# Simple notification
ntfy publish mytopic "Hello World"

# With title
ntfy publish --title "Alert" mytopic "Something happened"

# High priority with emoji
ntfy publish --priority high --tags warning mytopic "Server down!"

# With action button
ntfy publish --actions "view, Open Logs, https://logs.example.com" mytopic "Check logs"
```

### Using Just Recipes

```bash
# Test notification
just -f ntfy/justfile test mytopic

# Send with title
just -f ntfy/justfile send mytopic "Alert" "Something happened"

# High priority alert
just -f ntfy/justfile alert mytopic "Server is down!"

# With action URL
just -f ntfy/justfile action mytopic "Click to view" "https://example.com"
```

### Subscribing

```bash
# Subscribe to topic (foreground)
just -f ntfy/justfile subscribe mytopic

# Subscribe and run command
just -f ntfy/justfile subscribe-exec mytopic 'echo "$m"'

# Background subscription
ntfy subscribe --poll mytopic
```

### From Scripts

```bash
# Using curl
curl -d "Backup complete" ntfy.sh/mytopic

# With JSON
curl -H "Content-Type: application/json" \
  -d '{"topic":"mytopic","message":"Hello","title":"Alert"}' \
  ntfy.sh
```

## Priority Levels

| Priority | CLI Flag | Use Case |
|----------|----------|----------|
| `max`/`urgent` | `--priority urgent` | Critical alerts |
| `high` | `--priority high` | Important notifications |
| `default` | (none) | Normal messages |
| `low` | `--priority low` | Background info |
| `min` | `--priority min` | Silent logging |

## Self-Hosting

The `server.yaml` contains an example server configuration for self-hosting ntfy.

Key settings:
- `base-url`: Public URL of your server
- `listen-http`: Internal listen address
- `behind-proxy`: Set true if using reverse proxy
- `cache-file`: SQLite database for message cache
- `attachment-cache-dir`: Directory for file attachments

## Integration Ideas

- **CI/CD**: Notify on build completion
- **Monitoring**: Alert on service failures
- **Backups**: Confirm backup completion
- **Cron jobs**: Report job status
- **Home automation**: Device notifications

## TODOs

### Configuration (Medium Priority)

- [ ] **1Password integration**: Secure topic tokens
- [ ] **Default subscriptions**: Auto-subscribe to common topics

### Integration (Low Priority)

- [ ] **launchd service**: Background subscription daemon
- [ ] **Shell integration**: Notification on long command completion

## File Structure

```
ntfy/
├── client.yml    # Client config (symlinked to ~/.config/ntfy/)
├── server.yaml   # Example server config
├── brewfile      # ntfy CLI
├── justfile      # Installation recipes
├── data.yml      # Module config
└── README.md     # This file
```

## References

- [ntfy Documentation](https://docs.ntfy.sh/)
- [ntfy GitHub](https://github.com/binwiederhier/ntfy)
- [ntfy.sh](https://ntfy.sh/) - Free hosted service
- [Publishing](https://docs.ntfy.sh/publish/)
- [Subscribing](https://docs.ntfy.sh/subscribe/cli/)
