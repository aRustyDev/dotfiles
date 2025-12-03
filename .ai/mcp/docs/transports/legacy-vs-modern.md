---
id: FF1F3BCB-1328-41E3-9B7C-60946539384A
title: MCP HTTP Transport Protocols - Legacy vs Modern
status: ✅ Documented
date: 2025-11-22
author: aRustyDev
related:
  - 9282B346-B74A-4522-B79C-690705DC1C92 # ADR: HTTP Transport Architecture
  - 2F7850D8-3E51-456C-AE60-C70BAF323BFB # Plan: Streamable HTTP Implementation
---

# MCP HTTP Transport Protocols - Legacy vs Modern

**Created:** 2025-11-22
**Author:** aRustyDev
**Status:** ✅ Documented

---

## Overview

The Model Context Protocol (MCP) has evolved through two HTTP transport specifications. Understanding the differences is critical for debugging client compatibility issues and implementing proper server support.

## Executive Summary

**Problem:** Zed editor times out when connecting to our MCP server with 60-second timeout and 405 errors.

**Root Cause:** Protocol version mismatch

- Our server implements **Legacy HTTP+SSE (2024-11-05 spec)**
- Zed expects **Modern Streamable HTTP (2025-03-26 spec)**
- The 405 error is **correct behavior** for Legacy mode

**Impact:** Modern MCP clients (Zed, newer Claude Desktop versions) cannot connect via HTTP.

---

## The Two Transport Protocols

### Legacy HTTP+SSE Transport (2024-11-05)

**Specification Date:** 2024-11-05
**Status:** Deprecated but widely deployed
**Current Implementation:** FastMCP 1.2.0+

#### Architecture

Uses **two separate endpoints**:

1. **SSE Endpoint** (GET only)
   - Path: `/sse`
   - Method: `GET`
   - Purpose: Server-to-client event stream
   - Response: `Content-Type: text/event-stream`

2. **Messages Endpoint** (POST only)
   - Path: `/messages/?session_id=<uuid>`
   - Method: `POST`
   - Purpose: Client-to-server JSON-RPC messages
   - Response: `202 Accepted` or error

#### Connection Flow

```
Client                          Server
  |                               |
  | GET /sse                      |
  |------------------------------>|
  |                               |
  | 200 OK                        |
  | Content-Type: text/event-stream
  |<------------------------------|
  |                               |
  | event: endpoint               |
  | data: /messages/?session_id=xyz
  |<------------------------------|
  |                               |
  | POST /messages/?session_id=xyz|
  | { JSON-RPC request }          |
  |------------------------------>|
  |                               |
  | 202 Accepted                  |
  |<------------------------------|
  |                               |
  | event: message                |
  | data: { JSON-RPC response }   |
  |<------------------------------|
```

#### The 405 Error Explained

**Why it happens:**

```bash
curl -X POST http://localhost:8000/sse
# Returns: 405 Method Not Allowed
```

**This is CORRECT behavior!** In Legacy HTTP+SSE:

- `/sse` is **GET-only** (for establishing SSE stream)
- POST requests must go to `/messages/`, not `/sse`

**Code Evidence:**

```python
# fastmcp/server.py line 76-77
sse_path: str = "/sse"
message_path: str = "/messages/"
```

---

### Modern Streamable HTTP Transport (2025-03-26)

**Specification Date:** 2025-03-26
**Status:** Current standard
**Current Implementation:** ❌ Not supported by FastMCP

#### Architecture

Uses **single unified endpoint**:

**MCP Endpoint** (GET, POST, DELETE)

- Path: `/mcp` (or any configured path)
- Methods: `GET`, `POST`, `DELETE`
- Purpose: All MCP protocol interactions

#### Connection Flow

```
Client                          Server
  |                               |
  | POST /mcp                     |
  | Accept: text/event-stream,    |
  |         application/json      |
  | { JSON-RPC requests }         |
  |------------------------------>|
  |                               |
  | 202 Accepted                  |
  | (no body)                     |
  |<------------------------------|
  |                               |
  | GET /mcp                      |
  | Accept: text/event-stream     |
  |------------------------------>|
  |                               |
  | 200 OK                        |
  | Content-Type: text/event-stream
  |<------------------------------|
  |                               |
  | event: message                |
  | data: { JSON-RPC response }   |
  |<------------------------------|
  |                               |
  | POST /mcp                     |
  | Mcp-Session-Id: <session-id>  |
  | { JSON-RPC request }          |
  |------------------------------>|
  |                               |
  | 202 Accepted                  |
  |<------------------------------|
```

#### Endpoint Behavior

**POST /mcp:**

- **Request Headers:**
  - `Accept: application/json, text/event-stream`
  - `Mcp-Session-Id: <uuid>` (after initial connection)
  - `Content-Type: application/json`
- **Request Body:** JSON-RPC message(s)
- **Response:**
  - `202 Accepted` (no body) - Message queued
  - OR `Content-Type: text/event-stream` - Initiate SSE stream
  - OR `Content-Type: application/json` - Immediate response
  - OR `400 Bad Request` - Invalid input

**GET /mcp:**

- **Request Headers:**
  - `Accept: text/event-stream`
  - `Mcp-Session-Id: <uuid>` (optional)
- **Response:**
  - `200 OK` with `Content-Type: text/event-stream` - SSE stream
  - OR `405 Method Not Allowed` - Server doesn't support GET-only

**DELETE /mcp:**

- **Request Headers:**
  - `Mcp-Session-Id: <uuid>`
- **Response:**
  - `204 No Content` - Session terminated
  - OR `405 Method Not Allowed` - Server doesn't allow client termination

---

## Why Zed Times Out

### Zed's Behavior (Modern Client)

```
2025-11-22T01:23:05 INFO  Using HTTP transport for http://mcp.localhost/sse
```

1. **Zed tries POST to `/sse`** (expecting Modern Streamable HTTP)
2. **Server returns 405** (correct for Legacy HTTP+SSE)
3. **Zed doesn't fallback** (doesn't recognize Legacy protocol)
4. **60-second timeout** expires

### Why mcp-remote Works from CLI

```bash
npx -y mcp-remote http://mcp.localhost/sse --allow-http
# Output: Proxy established successfully
```

`mcp-remote` implements **fallback logic**:

1. Try POST (http-first strategy)
2. Receive 405 error
3. **Fallback to sse-only strategy**
4. Try GET /sse
5. Success! ✅

### Why Zed Subprocess Times Out

When Zed runs `mcp-remote` as a subprocess:

1. Process takes ~2-3 seconds for POST→GET fallback
2. Zed may timeout before "Proxy established" message
3. Or Zed doesn't properly detect success message from subprocess stdout

---

## Client Compatibility Matrix

| Client               | Legacy HTTP+SSE | Modern Streamable HTTP | Notes                       |
| -------------------- | --------------- | ---------------------- | --------------------------- |
| mcp-remote CLI       | ✅ Yes          | ✅ Yes                 | Has fallback logic          |
| Zed (subprocess)     | ❌ Timeout      | ✅ Yes                 | Timeout during fallback     |
| Zed (HTTP config)    | ❌ No           | ✅ Yes                 | No fallback, expects Modern |
| Claude Desktop (old) | ✅ Yes          | ❌ No                  | Uses Legacy                 |
| Claude Desktop (new) | ✅ Yes          | ✅ Yes                 | Supports both               |

---

## FastMCP Current Implementation

### Supported Transports

```python
# fastmcp/server.py line 148
def run(self, transport: Literal["stdio", "sse"] = "stdio") -> None:
```

**Only two transports:**

1. `stdio` - Standard input/output (for local processes)
2. `sse` - Server-Sent Events (Legacy HTTP+SSE)

**No support for:**

- ❌ Modern Streamable HTTP
- ❌ WebSocket transport
- ❌ HTTP/2 or HTTP/3

### Current Endpoints

```python
# Settings class (line 76-77)
sse_path: str = "/sse"          # GET: SSE stream
message_path: str = "/messages/" # POST: Client messages
```

### What Would Break

Implementing Modern Streamable HTTP requires:

- **New `/mcp` endpoint** handling POST, GET, DELETE
- **Session management** with `Mcp-Session-Id` headers
- **202 Accepted responses** for queued messages
- **Backward compatibility** maintaining `/sse` and `/messages/` endpoints

---

## Technical Comparison

### Request Methods

| Endpoint     | Legacy HTTP+SSE | Modern Streamable HTTP |
| ------------ | --------------- | ---------------------- |
| `/sse`       | GET only        | Not used               |
| `/messages/` | POST only       | Not used               |
| `/mcp`       | Not used        | GET, POST, DELETE      |

### Session Management

**Legacy HTTP+SSE:**

```
1. Client: GET /sse
2. Server: event: endpoint
           data: /messages/?session_id=ABC123
3. Client: POST /messages/?session_id=ABC123
```

Session ID in URL path/query parameter.

**Modern Streamable HTTP:**

```
1. Client: POST /mcp
2. Server: 202 Accepted (implicitly creates session)
3. Client: GET /mcp
           Mcp-Session-Id: ABC123
4. Server: SSE stream
```

Session ID in HTTP header.

### Content Negotiation

**Legacy HTTP+SSE:**

- No content negotiation
- `/sse` always returns `text/event-stream`
- `/messages/` always expects `application/json`

**Modern Streamable HTTP:**

- Client sends `Accept` header
- Server chooses response type:
  - `text/event-stream` for streaming
  - `application/json` for immediate response
  - `202 Accepted` for queued messages

---

## References

### Specifications

- **Legacy HTTP+SSE:** https://spec.modelcontextprotocol.io/specification/2024-11-05/basic/transports/
- **Modern Streamable HTTP:** https://modelcontextprotocol.io/specification/2025-03-26/basic/transports

### Related Resources

- **Cloudflare Blog:** [Bringing streamable HTTP transport to MCP](https://blog.cloudflare.com/streamable-http-mcp-servers-python/)
- **Why MCP Switched:** [SSE vs Streamable HTTP](https://blog.fka.dev/blog/2025-06-06-why-mcp-deprecated-sse-and-go-with-streamable-http/)
- **Example Implementation:** [mcp-streamable-http](https://github.com/invariantlabs-ai/mcp-streamable-http)

### Related Documentation

- [ADR: HTTP Transport Architecture](./adr-http-transport-architecture.md)
- [Plan: Streamable HTTP Implementation](../../.ai/plans/STREAMABLE_HTTP_IMPLEMENTATION.md)

---

## Recommendations

### Short Term (Current)

1. **Use mcp-remote proxy for Zed:**

   ```json
   {
     "context_servers": {
       "zettelkasten": {
         "command": "npx",
         "args": [
           "-y",
           "mcp-remote",
           "http://localhost:8000/sse",
           "--allow-http"
         ]
       }
     }
   }
   ```

2. **Direct connection for compatible clients:**
   - Use GET /sse for SSE stream
   - Use POST /messages/?session_id= for messages

### Long Term (Implementation Required)

1. **Implement Modern Streamable HTTP transport**
   - Add `/mcp` endpoint with POST, GET, DELETE support
   - Implement proper session management
   - Add content negotiation
   - Maintain backward compatibility with Legacy endpoints

2. **Update FastMCP library**
   - Contribute upstream to fastmcp project
   - Or fork and maintain custom version
   - Or migrate to different MCP SDK

---

**Last Updated:** 2025-11-22
**Next Review:** When implementing Streamable HTTP support
