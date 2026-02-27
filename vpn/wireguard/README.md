# vpn

WireGuard VPN configuration and management.

## Current Configuration

- `wg0-client-ipv4.conf` - IPv4-only WireGuard client template
- `wg0-client-ipv6.conf` - Dual-stack (IPv4+IPv6) WireGuard client template
- `brewfile` - wireguard-tools

### Features

- **WireGuard**: Fast, modern VPN protocol
- **Templates**: Pre-configured client configs (need keys filled in)
- **Key management**: Generate keypairs and preshared keys

## Installation

```bash
just -f vpn/justfile install
```

## Usage

### Setup a Configuration

1. Copy template to system config:
   ```bash
   just -f vpn/justfile setup wg0-client-ipv4
   ```

2. Edit the installed config with your actual keys:
   ```bash
   sudo $EDITOR /etc/wireguard/wg0-client-ipv4.conf
   ```

3. Connect:
   ```bash
   just -f vpn/justfile up wg0-client-ipv4
   ```

### Connection Management

```bash
# Bring up VPN
just -f vpn/justfile up wg0

# Bring down VPN
just -f vpn/justfile down wg0

# Show status
just -f vpn/justfile status

# Show detailed interface info
just -f vpn/justfile show wg0
```

### Key Management

```bash
# Generate new keypair
just -f vpn/justfile keygen myclient

# Generate preshared key
just -f vpn/justfile psk
```

### List Configs

```bash
# Available templates
just -f vpn/justfile list

# Installed configs
just -f vpn/justfile installed

# Full info
just -f vpn/justfile info
```

## Configuration Templates

### wg0-client-ipv4.conf

Basic IPv4 client for connecting to a WireGuard server on a private network.

| Field | Description |
|-------|-------------|
| `Address` | Client's VPN IP (e.g., `192.168.2.2`) |
| `PrivateKey` | Client's private key |
| `ListenPort` | Local port (optional) |
| `PublicKey` | Server's public key |
| `Endpoint` | Server IP:port |
| `AllowedIPs` | Routes through VPN (`192.168.2.0/24` for split tunnel) |

### wg0-client-ipv6.conf

Dual-stack client that routes ALL traffic through VPN (full tunnel).

| Field | Description |
|-------|-------------|
| `Address` | Client IPs (IPv4 + IPv6) |
| `DNS` | Cloudflare DNS (IPv6 + IPv4) |
| `AllowedIPs` | `0.0.0.0/0, ::/0` (all traffic) |

## Security Notes

- **Private keys**: Never commit actual private keys. Use placeholders or 1Password references.
- **Config permissions**: Configs in `/etc/wireguard/` should be `chmod 600`
- **Preshared keys**: Optional but add quantum-resistant security

## TODOs

### Configuration (Medium Priority)

- [ ] **1Password integration**: Use `op inject` for key management
- [ ] **Multiple server configs**: Add configs for different VPN servers

### Automation (Low Priority)

- [ ] **Auto-connect**: launchd service for automatic VPN on network change
- [ ] **Split tunneling**: Configs for routing only specific traffic

## File Structure

```
vpn/
├── wg0-client-ipv4.conf  # IPv4 client template
├── wg0-client-ipv6.conf  # Dual-stack client template
├── brewfile              # wireguard-tools
├── justfile              # Management recipes
├── data.yml              # Module config
└── README.md             # This file
```

## References

- [WireGuard Official](https://www.wireguard.com/)
- [WireGuard Quick Start](https://www.wireguard.com/quickstart/)
- [WireGuard on macOS](https://www.wireguard.com/install/)
- [WireGuard IPv6 Setup](https://blog.frehi.be/2022/06/11/setting-up-wireguard-vpn-with-ipv6/)
