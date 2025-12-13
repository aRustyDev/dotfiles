---
id: ff1f3bcb-1328-41e3-9b7c-60946539384a
title: "MCP HTTP Transport: Legacy vs Modern"
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - mcp
  - docker
type: reference
status: 📝 draft
publish: false
tags:
  - mcp
  - http
  - sse
  - transport
  - protocol
aliases:
  - MCP Legacy vs Modern
  - SSE vs Streamable HTTP
related:
  - ref: "[[mcp-transports]]"
    description: MCP transport mechanisms overview
  - ref: "[[stdio-http-wrappers]]"
    description: HTTP wrapper implementations
---

# MCP HTTP Transport Protocols - Legacy vs Modern

Understanding the differences between Legacy HTTP+SSE and Modern Streamable HTTP is critical for debugging client compatibility issues.

---

## Executive Summary

| Aspect | Legacy HTTP+SSE | Modern Streamable HTTP |
|--------|-----------------|------------------------|
| **Spec Date** | 2024-11-05 | 2025-03-26 |
| **Status** | Deprecated but widely deployed | Current standard |
| **Endpoints** | `/sse` (GET) + `/messages/` (POST) | `/mcp` (GET, POST, DELETE) |
| **Session ID** | URL query parameter | HTTP header |
| **Content Negotiation** | None | `Accept` header based |

---

## The Two Transport Protocols

### Legacy HTTP+SSE Transport (2024-11-05)

Uses **two separate endpoints**:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/sse` | GET | Server-to-client event stream |
| `/messages/?session_id=<uuid>` | POST | Client-to-server JSON-RPC messages |

**Connection Flow:**
```
Client                          Server
  | GET /sse                      |
  |------------------------------>|
  | 200 OK (text/event-stream)    |
  |<------------------------------|
  | event: endpoint               |
  | data: /messages/?session_id=xyz
  |<------------------------------|
  | POST /messages/?session_id=xyz|
  |------------------------------>|
  | 202 Accepted                  |
  |<------------------------------|
  | event: message (response)     |
  |<------------------------------|
```

**Why 405 errors are correct**: `/sse` is GET-only. POST requests must go to `/messages/`.

---

### Modern Streamable HTTP Transport (2025-03-26)

Uses **single unified endpoint**:

| Method | Purpose |
|--------|---------|
| `POST /mcp` | Send JSON-RPC messages |
| `GET /mcp` | Establish SSE stream |
| `DELETE /mcp` | Terminate session |

**Connection Flow:**
```
Client                          Server
  | POST /mcp                     |
  | Accept: text/event-stream     |
  |------------------------------>|
  | 202 Accepted                  |
  |<------------------------------|
  | GET /mcp                      |
  | Mcp-Session-Id: <session-id>  |
  |------------------------------>|
  | 200 OK (text/event-stream)    |
  |<------------------------------|
```

**Key differences:**
- Session ID in `Mcp-Session-Id` header (not URL)
- Content negotiation via `Accept` header
- Single endpoint handles all operations

---

## Client Compatibility Matrix

| Client | Legacy HTTP+SSE | Modern Streamable HTTP | Notes |
|--------|-----------------|------------------------|-------|
| mcp-remote CLI | Yes | Yes | Has fallback logic |
| Zed (subprocess) | Timeout | Yes | Timeout during fallback |
| Zed (HTTP config) | No | Yes | No fallback, expects Modern |
| Claude Desktop (old) | Yes | No | Uses Legacy |
| Claude Desktop (new) | Yes | Yes | Supports both |

---

## Why Zed Times Out

1. **Zed tries POST to `/sse`** (expecting Modern Streamable HTTP)
2. **Server returns 405** (correct for Legacy HTTP+SSE)
3. **Zed doesn't fallback** (doesn't recognize Legacy protocol)
4. **60-second timeout** expires

### Why mcp-remote Works

`mcp-remote` implements fallback logic:
1. Try POST (http-first strategy)
2. Receive 405 error
3. Fallback to sse-only strategy
4. Try GET /sse
5. Success!

---

## Technical Comparison

### Session Management

**Legacy:**
```
Session ID in URL: /messages/?session_id=ABC123
```

**Modern:**
```
Session ID in header: Mcp-Session-Id: ABC123
```

### Response Types

**Legacy:**
- `/sse` always returns `text/event-stream`
- `/messages/` always expects `application/json`

**Modern:**
- Server chooses based on `Accept` header:
  - `text/event-stream` for streaming
  - `application/json` for immediate response
  - `202 Accepted` for queued messages

---

## Workarounds

### For Zed with Legacy Servers

Use mcp-remote as proxy:

```json
{
  "context_servers": {
    "myserver": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "http://localhost:8000/sse", "--allow-http"]
    }
  }
}
```

### For Compatible Clients

Direct connection:
- GET `/sse` for SSE stream
- POST `/messages/?session_id=` for messages

---

## References

- [Legacy HTTP+SSE Spec (2024-11-05)](https://spec.modelcontextprotocol.io/specification/2024-11-05/basic/transports/)
- [Modern Streamable HTTP Spec (2025-03-26)](https://modelcontextprotocol.io/specification/2025-03-26/basic/transports)
- [Cloudflare: Bringing streamable HTTP to MCP](https://blog.cloudflare.com/streamable-http-mcp-servers-python/)
- [Why MCP Switched: SSE vs Streamable HTTP](https://blog.fka.dev/blog/2025-06-06-why-mcp-deprecated-sse-and-go-with-streamable-http/)

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
