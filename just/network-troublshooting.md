# macOS Network Troubleshooting Guide

A comprehensive guide to diagnosing network issues on macOS, based on a real debugging session where the local machine had severe connectivity issues despite good ISP speeds and other devices working fine.

---

## Table of Contents

1. [Network Interface Discovery](#1-network-interface-discovery)
2. [Interface Statistics](#2-interface-statistics)
3. [Connection State Analysis](#3-connection-state-analysis)
4. [Process Resource Usage](#4-process-resource-usage)
5. [Per-Process Network Traffic](#5-per-process-network-traffic)
6. [Connectivity Testing](#6-connectivity-testing)
7. [DNS Configuration](#7-dns-configuration)
8. [Socket Buffer Limits](#8-socket-buffer-limits)
9. [VPN/Tunnel Status](#9-vpntunnel-status)
10. [Routing Table](#10-routing-table)
11. [Tunnel Interfaces](#11-tunnel-interfaces)
12. [VPN Process Detection](#12-vpn-process-detection)
13. [Gateway Connectivity](#13-gateway-connectivity)
14. [DNS Resolution Testing](#14-dns-resolution-testing)
15. [Wi-Fi Network Info](#15-wi-fi-network-info)
16. [Wi-Fi Hardware Details](#16-wi-fi-hardware-details)
17. [Common Fixes](#17-common-fixes)

---

## 1. Network Interface Discovery

### Command
```bash
networksetup -listallhardwareports
```

### Purpose
Lists all network hardware ports (interfaces) on the system, showing the mapping between human-readable names (e.g., "Wi-Fi", "Ethernet Adapter") and device identifiers (e.g., `en0`, `en3`).

### Documentation
- `man networksetup`
- Apple Developer: [System Configuration Framework](https://developer.apple.com/documentation/systemconfiguration)

### What the Output Reveals
- Available network interfaces and their device names
- MAC addresses for each interface
- Whether you're using Wi-Fi (`en0`), Ethernet (`en3`/`en4`), or Thunderbolt bridges
- VLAN configurations if any exist

### Example Output Analysis
```
Hardware Port: Wi-Fi
Device: en0
Ethernet Address: a0:9a:8e:23:cd:ea
```
This shows the primary Wi-Fi interface is `en0` - important for subsequent commands that target specific interfaces.

---

## 2. Interface Statistics

### Command
```bash
netstat -i
```

### Purpose
Displays network interface statistics including packet counts, errors, and collisions. Useful for identifying hardware-level issues.

### Documentation
- `man netstat`
- Flag `-i` shows interface state

### What the Output Reveals
- **Ipkts/Opkts**: Input/output packet counts
- **Ierrs/Oerrs**: Input/output errors (non-zero indicates hardware/driver issues)
- **Coll**: Collisions (relevant for older Ethernet, should be 0 on modern networks)
- **MTU**: Maximum Transmission Unit size

### Key Indicators
- `Ierrs > 0`: Possible hardware issues, cable problems, or driver bugs
- `Oerrs > 0`: Transmission failures, possibly congestion or hardware issues
- Packet counts help identify which interface is actively being used

---

## 3. Connection State Analysis

### Command
```bash
netstat -an | grep -E "ESTABLISHED|CLOSE_WAIT|TIME_WAIT" | wc -l
netstat -an | grep -E "ESTABLISHED|CLOSE_WAIT|TIME_WAIT" | awk '{print $6}' | sort | uniq -c | sort -rn
```

### Purpose
Counts active network connections and groups them by TCP state. Helps identify connection exhaustion or leaked connections.

### Documentation
- `man netstat`
- TCP state machine: [RFC 793](https://tools.ietf.org/html/rfc793)

### What the Output Reveals
- **ESTABLISHED**: Active connections (normal)
- **CLOSE_WAIT**: Connection closed by remote, waiting for local close (high numbers indicate application bugs)
- **TIME_WAIT**: Connection closed, waiting for stray packets (normal, but excessive numbers can exhaust ports)

### Key Indicators
- `CLOSE_WAIT > 100`: Application not properly closing connections
- `TIME_WAIT > 1000`: Possible port exhaustion, may need to tune `net.inet.tcp.msl`
- Total connections > 10000: Potential resource exhaustion

---

## 4. Process Resource Usage

### Command
```bash
top -l 1 -n 10 -stats pid,command,cpu,mem,state
```

### Purpose
Captures a snapshot of the top 10 processes by resource usage without entering interactive mode.

### Documentation
- `man top`
- `-l 1`: Single iteration (non-interactive)
- `-n 10`: Show top 10 processes
- `-stats`: Specify which columns to display

### What the Output Reveals
- CPU hogs that might be saturating the system
- Memory pressure that could cause swapping
- Process states (running, sleeping, etc.)

### Key Indicators
- CPU > 100%: Process using multiple cores heavily
- High memory with "running" state: Possible resource contention
- Look for runaway processes consuming resources

---

## 5. Per-Process Network Traffic

### Command
```bash
nettop -P -L 1 -n
```

### Purpose
Shows network traffic statistics broken down by process. The most valuable tool for identifying which application is consuming bandwidth or experiencing network issues.

### Documentation
- `man nettop`
- `-P`: Show per-process statistics
- `-L 1`: Single sample (non-interactive)
- `-n`: Don't resolve addresses to names

### What the Output Reveals
| Column | Meaning |
|--------|---------|
| `bytes_in/out` | Data transferred |
| `rx_dupe` | Duplicate packets received (retransmissions from sender) |
| `rx_ooo` | Out-of-order packets (network congestion/path issues) |
| `re-tx` | Retransmissions sent (packet loss indicator) |
| `rtt_avg` | Average round-trip time |

### Key Indicators (CRITICAL)
- **`rx_ooo > 10000`**: Severe network path issues, packets arriving out of order
- **`re-tx > 10000`**: Massive packet loss requiring retransmissions
- **`rx_dupe > 1000`**: Remote side is retransmitting heavily

In the diagnostic session, we found:
- `curl` processes with **2.2 million** out-of-order packets
- `claude` process with **519,000** retransmissions

These numbers indicate catastrophic network layer issues.

---

## 6. Connectivity Testing

### Commands
```bash
# Test raw IP connectivity (bypasses DNS)
ping -c 3 8.8.8.8

# Test DNS resolution + connectivity
ping -c 3 google.com
```

### Purpose
Basic connectivity testing. The first command tests raw IP routing, the second adds DNS resolution to the test.

### Documentation
- `man ping`
- `-c 3`: Send 3 packets only

### What the Output Reveals
- **100% packet loss to 8.8.8.8**: Fundamental routing/connectivity issue
- **"Unknown host"**: DNS resolution failure
- **High latency (>100ms to gateway)**: Network congestion or interference
- **Packet loss >5%**: Significant network issues

### Key Indicators
- Gateway ping >10ms: Local network issues
- External ping >200ms: ISP or routing issues
- Any packet loss: Requires investigation

---

## 7. DNS Configuration

### Command
```bash
scutil --dns | grep -A 5 "resolver #1"
```

### Purpose
Shows the system's DNS resolver configuration, including which DNS servers are being used and for which domains.

### Documentation
- `man scutil`
- Apple: [DNS Configuration](https://developer.apple.com/library/archive/documentation/Networking/Conceptual/SystemConfigFrameworks/)

### What the Output Reveals
- Primary DNS server (usually router IP like `192.168.1.1` or custom like `8.8.8.8`)
- Search domains
- Interface binding (`if_index`)
- Reachability flags

### Key Indicators
- `nameserver[0]` pointing to VPN interface: VPN may be intercepting DNS
- Multiple resolvers with different interfaces: Split-tunnel VPN or complex routing
- `reach: 0x00000000`: DNS server unreachable

---

## 8. Socket Buffer Limits

### Command
```bash
sysctl kern.ipc.somaxconn kern.ipc.maxsockbuf
```

### Purpose
Shows kernel TCP/IP socket buffer limits. Low values can cause performance issues under high load.

### Documentation
- `man sysctl`
- `man tcp`

### What the Output Reveals
- `kern.ipc.somaxconn`: Maximum pending connections queue (default: 128)
- `kern.ipc.maxsockbuf`: Maximum socket buffer size (default: 8MB)

### Key Indicators
- `somaxconn = 128`: May need increasing for high-connection servers
- Low `maxsockbuf`: Can limit throughput on high-bandwidth connections

---

## 9. VPN/Tunnel Status

### Command
```bash
warp-cli status
```

### Purpose
Checks Cloudflare WARP VPN status. WARP can intercept all traffic and cause issues if misconfigured or in a bad state.

### Documentation
- [Cloudflare WARP CLI](https://developers.cloudflare.com/warp-client/get-started/linux/)

### What the Output Reveals
- Connection status (Connected/Disconnected)
- Disconnect reason (important for debugging)
- Mode (WARP, WARP+, DoH only, etc.)

### Key Indicators
- **"Disconnected" + "Reason: Settings Changed"**: WARP may have left routing in broken state
- Running but disconnected: Daemon active but not tunneling (can still affect routing)

---

## 10. Routing Table

### Commands
```bash
# Default route details
route -n get default

# Full routing table
netstat -rn | grep -E "^default|^0"
```

### Purpose
Shows how traffic is routed, particularly the default gateway and any VPN-related routes.

### Documentation
- `man route`
- `man netstat` (routing section)

### What the Output Reveals
- Default gateway IP address
- Which interface is used for default traffic
- VPN tunnel routes (usually `utun*` interfaces)
- Route flags (UP, GATEWAY, STATIC, etc.)

### Key Indicators
- Multiple default routes: VPN or complex routing (can cause issues)
- Default route via `utun*`: VPN is intercepting all traffic
- Gateway not matching expected router IP: Possible hijacking or misconfiguration

In the diagnostic session:
```
default            192.168.1.1        UGScg    en0        # Normal
default            fe80::%utun0       UGcIg    utun0      # VPN IPv6
default            fe80::%utun1       UGcIg    utun1      # Multiple tunnels!
...
```
Six tunnel interfaces with default routes is suspicious.

---

## 11. Tunnel Interfaces

### Command
```bash
ifconfig | grep -A 5 utun
```

### Purpose
Shows configuration of tunnel interfaces (`utun*`), which are typically created by VPNs.

### Documentation
- `man ifconfig`
- Apple: [Network Extension Framework](https://developer.apple.com/documentation/networkextension)

### What the Output Reveals
- Active tunnel interfaces
- MTU sizes (can affect fragmentation)
- IPv4/IPv6 addresses assigned to tunnels
- Interface flags (UP, RUNNING, etc.)

### Key Indicators
- Multiple `utun` interfaces: Multiple VPNs or leaked tunnel interfaces
- `utun` with no IPv4 address: Possibly stale/broken tunnel
- Very low MTU (<1280): Can cause fragmentation issues

---

## 12. VPN Process Detection

### Command
```bash
ps aux | grep -iE "cloudflare|warp|vpn|tunnel" | grep -v grep
```

### Purpose
Identifies running VPN-related processes that might be affecting network traffic.

### Documentation
- `man ps`

### What the Output Reveals
- VPN daemons running in background
- User vs system processes
- Resource usage of VPN software

### Key Indicators
- Multiple VPN processes: Potential conflicts
- VPN daemon running as root: Has full network control
- High CPU usage: VPN encryption overhead or bugs

---

## 13. Gateway Connectivity

### Command
```bash
ping -c 2 192.168.1.1  # Replace with your gateway IP
```

### Purpose
Tests connectivity to local gateway. This should have <5ms latency and 0% packet loss.

### Documentation
- `man ping`

### What the Output Reveals
- **Latency to gateway**: Should be <5ms for wired, <20ms for Wi-Fi
- **Packet loss**: Should be 0%

### Key Indicators (CRITICAL)
In the diagnostic session:
```
round-trip min/avg/max/stddev = 1124.570/1124.570/1124.570/nan ms
```
**1124ms to local gateway is catastrophic** - normal is <5ms. This indicates severe local network issues.

---

## 14. DNS Resolution Testing

### Commands
```bash
# Test DNS via local router
dig @192.168.1.1 google.com +short +timeout=3

# Test DNS via Google (bypasses local DNS)
dig @8.8.8.8 google.com +short +timeout=3

# Alternative using nslookup
nslookup google.com 192.168.1.1
```

### Purpose
Tests DNS resolution through specific servers to isolate DNS issues from connectivity issues.

### Documentation
- `man dig`
- `man nslookup`

### What the Output Reveals
- Whether DNS servers are responding
- Which DNS path is working (local vs external)
- Response times for DNS queries

### Key Indicators
- External DNS works but local doesn't: Router DNS issue
- Neither works: Fundamental connectivity issue (not DNS-specific)
- Slow responses (>500ms): DNS server issues or network congestion

---

## 15. Wi-Fi Network Info

### Command
```bash
networksetup -getinfo "Wi-Fi"
```

### Purpose
Shows current Wi-Fi network configuration including IP address, subnet, router, and DHCP status.

### Documentation
- `man networksetup`

### What the Output Reveals
- IP address assignment method (DHCP/Static)
- Current IP address
- Subnet mask
- Router/gateway IP
- IPv6 status

---

## 16. Wi-Fi Hardware Details

### Command
```bash
system_profiler SPAirPortDataType
```

### Purpose
Comprehensive Wi-Fi hardware and connection information including signal strength, noise floor, channel, and PHY mode.

### Documentation
- `man system_profiler`
- Data type `SPAirPortDataType` for Wi-Fi

### What the Output Reveals
| Metric | Good Value | Poor Value |
|--------|-----------|------------|
| Signal | > -60 dBm | < -75 dBm |
| Noise | < -85 dBm | > -70 dBm |
| SNR (Signal-Noise) | > 25 dB | < 15 dB |
| Transmit Rate | > 400 Mbps | < 100 Mbps |
| Channel | 5GHz/6GHz preferred | 2.4GHz congested |

### Key Indicators
In the diagnostic session:
```
Signal / Noise: -44 dBm / -94 dBm  # Excellent (50dB SNR)
Transmit Rate: 780                  # Good
Channel: 44 (5GHz, 80MHz)          # Good
```
The Wi-Fi signal was excellent, confirming the issue was software/network stack, not wireless interference.

---

## 17. Common Fixes

### Fix Cloudflare WARP Issues
```bash
# Reconnect WARP
warp-cli disconnect && warp-cli connect

# Fully disable WARP daemon
warp-cli disconnect
sudo launchctl unload /Library/LaunchDaemons/com.cloudflare.1dot1dot1dot1.macos.warp.daemon.plist
```

### Flush DNS Cache
```bash
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
```

### Reset Wi-Fi Interface
```bash
networksetup -setairportpower en0 off && sleep 2 && networksetup -setairportpower en0 on
```

### Renew DHCP Lease
```bash
sudo ipconfig set en0 DHCP
```

### Reset Network Configuration (Nuclear Option)
```bash
# Remove network preferences (will reset all network settings)
sudo rm /Library/Preferences/SystemConfiguration/NetworkInterfaces.plist
sudo rm /Library/Preferences/SystemConfiguration/preferences.plist
# Then restart
```

---

## Diagnostic Summary Template

When troubleshooting, collect this information:

```bash
# Quick diagnostic script
echo "=== Interfaces ===" && networksetup -listallhardwareports | head -20
echo "=== Interface Stats ===" && netstat -i | head -10
echo "=== Connections ===" && netstat -an | grep ESTABLISHED | wc -l
echo "=== Gateway Ping ===" && ping -c 2 $(route -n get default | grep gateway | awk '{print $2}')
echo "=== DNS Test ===" && dig google.com +short +timeout=2
echo "=== Wi-Fi Signal ===" && system_profiler SPAirPortDataType 2>/dev/null | grep -E "Signal|Noise|Channel|Transmit"
echo "=== VPN Status ===" && warp-cli status 2>/dev/null || echo "WARP not installed"
echo "=== Tunnel Interfaces ===" && ifconfig | grep -c utun
echo "=== Top Network Processes ===" && nettop -P -L 1 -n 2>/dev/null | head -15
```

---

## Key Findings from Diagnostic Session

| Check | Result | Status |
|-------|--------|--------|
| Wi-Fi Signal | -44 dBm (excellent) | ✅ |
| Gateway Latency | 1124ms | ❌ Critical |
| Gateway Packet Loss | 50% | ❌ Critical |
| DNS Resolution | Working | ✅ |
| WARP Status | Disconnected (bad state) | ⚠️ Suspect |
| Tunnel Interfaces | 6 active | ⚠️ Excessive |
| TCP Retransmissions | 519K+ | ❌ Critical |
| Out-of-order Packets | 2.2M+ | ❌ Critical |

**Root Cause**: Cloudflare WARP disconnected in a bad state ("Settings Changed"), likely leaving network routing or packet handling in a broken state despite having an excellent Wi-Fi signal.

**Resolution**: Properly reconnect or fully disable WARP, then cycle the network interface.
