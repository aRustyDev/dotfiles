- knowledge / context management
- AI tool configs
- aws bedrock testing
- MCP server configs
- MCP Server development
- AI Rule development / refinement
- AI Workflow guardrails development

## Problems

- project knowledge is not called out explicitly, or in ways that are semantically searchable
- design patterns have to be updated declaratively and independently of the code itself
- project work has to be updated / captured manually by the user
- mcp server configuration is confusing and messy
  - CAUSE: not centralized
  - CAUSE: no strategy documented
  - CAUSE: no strategy documented
- gitlab code is not semantically searchable
  - CAUSE: no gitlab MCP server is not configured
  - CAUSE: no gitlab knowledge graph is not configured

## GAPs

- No agentic framework / plan exists for integrating AI into non-human workflows
  - Ex: CI/CD jobs w/ AI steps
  - Ex: No GitLab managed Agents (https://docs.gitlab.com/user/duo_agent_platform/agents/)
- No context / memory system exists for AI tooling
- No RAW inference endpoints exist to enable generating embeddings for RAG or vector DBs
  - If fixed, this would allow creating project specific knowledge bases, and
- When used, MCP servers are regularly inconsistent in the deployment options
  - Ex: some use docker, some use local installs, some use `npx -y mcp-remote`
- No token observability system exists to track token usage across AI calls

## Solutions

- Use `dotfiles`

## Notes

- it sounds like there is a GovAI platform that is about to be released that will allow API'd access to bedrock LLMs

---

- [ ] MR for GTTS Components
  - [ ] Update Map-Packer to use merged component
- [ ] MR for MAP Apollo Component
- [ ] MR for MAP ECR Component
- [ ] MR for MAP Artifactory Component
- [ ] Rename repo `image-map-ami-builder` to `image-map-packer`
- [ ] Rename repo `map-components` to `map/components`
- [ ] Implement using `map-packer` in `ami-eks` repo

---

OpenInference MCP Instrumentation
mcp-telemetry
Arize Phoenix
Langfuse Experiments
OpenLLMetry

## GOAL: Capture Observability Data for MCP Tool Calls via Proxy

Comparison Matrix

| Approach         | Setup Complexity             | MCP Awareness      | Token Tracking    | Experiment Tags | Self-Hostable |
| ---------------- | ---------------------------- | ------------------ | ----------------- | --------------- | ------------- |
| Traefik + Plugin | 🔴 High (need custom plugin) | ❌ None            | ❌ No             | ✅ Via headers  | ✅ Yes        |
| FastMCP Proxy    | 🟢 Low                       | ✅ Native          | ⚠️ If in response | ✅ Yes          | ✅ Yes        |
| OTEL Collector   | 🟡 Medium                    | ⚠️ Custom receiver | ⚠️ If in response | ✅ Yes          | ✅ Yes        |
| Envoy + Lua      | 🟡 Medium                    | ⚠️ Via Lua parsing | ⚠️ If in response | ✅ Yes          | ✅ Yes        |
| Custom Go/Rust   | 🟡 Medium                    | ✅ Full control    | ⚠️ If in response | ✅ Yes          | ✅ Yes        |

#### Requirements

- Capture
  - Tokens used per tool call
  - Experiment Tags
  - Tool Names + Arguments
  - Response times / latency
  - Success / Failure
  - Request / Response payloads (optionally)
  - Client identifiers (headers, auth tokens, client certs)
  - Model used (by client & by tool / mcp)
- Be self-hostable
- Be MCP Aware (to parse JSON-RPC tool calls)

### Project: Add MCP dependency to export Observability Data

- Would want to do this in Rust

```python
# Skeleton Example in FastMCP
from fastmcp import FastMCP, Client
from fastmcp.server.middleware import Middleware
import json
import httpx

# Create a proxy server that forwards to your actual MCP servers
proxy = FastMCP("MCP Observability Proxy")

# Custom observability middleware
class ObservabilityMiddleware(Middleware):
    async def process_tool_call(self, request, call_next):
        # Capture before
        tool_name = request.params.name
        tool_args = request.params.arguments
        client_id = request.context.get("client_id", "unknown")

        # Log to your observability backend
        await self.log_to_backend({
            "type": "tool_call",
            "tool": tool_name,
            "args": tool_args,
            "client": client_id,
            "timestamp": datetime.utcnow().isoformat()
        })

        # Forward the request
        start = time.perf_counter()
        response = await call_next(request)
        duration = time.perf_counter() - start

        # Log response
        await self.log_to_backend({
            "type": "tool_response",
            "tool": tool_name,
            "duration_ms": duration * 1000,
            "success": not response.isError
        })

        return response

    async def log_to_backend(self, data):
        # Send to Langfuse, OTEL collector, Loki, etc.
        async with httpx.AsyncClient() as client:
            await client.post("http://otel-collector:4318/v1/logs", json=data)

proxy.add_middleware(ObservabilityMiddleware())

```

### Project: Traefik MCP-Observability Middleware

- Custom plugin to parse JSON-RPC and extract tool calls

```yaml
# Example Traefik Middleware Config
http:
  routers:
    mcp-router:
      rule: "PathPrefix(`/mcp`)"
      service: mcp-backend
      middlewares:
        - mcp-observability
        - access-log

  middlewares:
    mcp-observability:
      plugin:
        mcp-logger:
          # Custom plugin to parse JSON-RPC and extract tool calls
          logLevel: "debug"
          exportTo: "otel" # or "langfuse", "loki"

    access-log:
      accessLog:
        filePath: "/var/log/traefik/mcp-access.log"
        format: json
        fields:
          headers:
            names:
              X-MCP-Client: keep
              X-MCP-Session: keep
              Authorization: drop

  services:
    mcp-backend:
      loadBalancer:
        servers:
          - url: "http://mcp-server:8080"
```

```json
// Example MCP Server Configuration
{
  "mcpServers": {
    "my-tool": {
      "url": "https://mcp-proxy.internal/mcp/my-tool",
      "headers": {
        "X-MCP-Client": "claude-desktop",
        "X-MCP-User": "adamsm",
        "X-MCP-Experiment": "exp-001"
      }
    }
  }
}
```

### Project: Custom OTEL Receiver as a Proxy

```yaml
# OTEL Collector Config to Proxy MCP Traffic
receivers:
  # Receive MCP traffic as HTTP
  otlphttp:
    endpoint: 0.0.0.0:4318

  # Custom receiver for MCP JSON-RPC (you'd implement this)
  mcp_proxy:
    endpoint: 0.0.0.0:8080
    upstream: "http://actual-mcp-server:8080"

processors:
  # Extract attributes from MCP payloads
  attributes:
    actions:
      - key: mcp.tool.name
        from_context: jsonrpc.method
        action: insert
      - key: mcp.client
        from_context: http.headers.x-mcp-client
        action: insert

  # Batch for efficiency
  batch:
    timeout: 5s
    send_batch_size: 100

  # Add resource attributes
  resource:
    attributes:
      - key: service.name
        value: "mcp-proxy"
        action: upsert

exporters:
  # Send to Langfuse
  otlphttp/langfuse:
    endpoint: "https://cloud.langfuse.com"
    headers:
      Authorization: "Bearer ${LANGFUSE_SECRET_KEY}"

  # Or to local Phoenix
  otlphttp/phoenix:
    endpoint: "http://phoenix:6006/v1/traces"

  # Debug logging
  logging:
    loglevel: debug

service:
  pipelines:
    traces:
      receivers: [mcp_proxy]
      processors: [attributes, batch, resource]
      exporters: [otlphttp/langfuse, logging]
```

### Project: Custom Go/Rust Proxy

```go
package main

import (
    "encoding/json"
    "io"
    "log"
    "net/http"
    "net/http/httputil"
    "net/url"
    "time"
)

type JSONRPCRequest struct {
    Method string          `json:"method"`
    Params json.RawMessage `json:"params"`
    ID     interface{}     `json:"id"`
}

type MCPObservabilityProxy struct {
    upstream *httputil.ReverseProxy
    logger   *ObservabilityLogger
}

func (p *MCPObservabilityProxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    start := time.Now()

    // Read and parse request body
    body, _ := io.ReadAll(r.Body)
    var rpcReq JSONRPCRequest
    json.Unmarshal(body, &rpcReq)

    // Extract observability data
    observation := map[string]interface{}{
        "timestamp":  start.UTC(),
        "client":     r.Header.Get("X-MCP-Client"),
        "experiment": r.Header.Get("X-MCP-Experiment"),
        "method":     rpcReq.Method,
        "params":     rpcReq.Params,
    }

    // Wrap response writer to capture response
    recorder := &responseRecorder{ResponseWriter: w}

    // Forward request
    p.upstream.ServeHTTP(recorder, r)

    // Complete observation
    observation["duration_ms"] = time.Since(start).Milliseconds()
    observation["status_code"] = recorder.statusCode
    observation["response_size"] = recorder.size

    // Send to observability backend (async)
    go p.logger.Log(observation)
}

func main() {
    upstream, _ := url.Parse("http://actual-mcp-server:8080")
    proxy := &MCPObservabilityProxy{
        upstream: httputil.NewSingleHostReverseProxy(upstream),
        logger:   NewOTELLogger("http://otel-collector:4318"),
    }

    log.Println("MCP Observability Proxy listening on :8080")
    http.ListenAndServe(":8080", proxy)
}
```

```rust
//! MCP Observability Proxy
//!
//! A reverse proxy for Model Context Protocol (MCP) servers that captures
//! observability data including tool calls, timing, and client metadata.
//!
//! Features:
//! - JSON-RPC request/response parsing
//! - OpenTelemetry trace export
//! - Prometheus metrics endpoint
//! - Client identification via headers
//! - Experiment tagging support

use axum::{
    body::Body,
    extract::{Request, State},
    http::{header, HeaderMap, StatusCode},
    response::{IntoResponse, Response},
    routing::{get, post},
    Router,
};
use bytes::Bytes;
use http_body_util::BodyExt;
use hyper_util::{client::legacy::Client, rt::TokioExecutor};
use opentelemetry::{
    global,
    trace::{Span, SpanKind, Status, Tracer},
    KeyValue,
};
use opentelemetry_otlp::WithExportConfig;
use opentelemetry_sdk::{runtime, trace as sdktrace, Resource};
use prometheus::{Encoder, HistogramOpts, HistogramVec, IntCounterVec, Opts, Registry, TextEncoder};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{
    sync::Arc,
    time::{Duration, Instant},
};
use tokio::sync::RwLock;
use tracing::{error, info, warn};

// ============================================================================
// Configuration
// ============================================================================

#[derive(Clone, Debug)]
struct Config {
    /// Upstream MCP server URL
    upstream_url: String,
    /// Listen address for the proxy
    listen_addr: String,
    /// OTEL collector endpoint
    otel_endpoint: Option<String>,
    /// Service name for tracing
    service_name: String,
}

impl Config {
    fn from_env() -> Self {
        Self {
            upstream_url: std::env::var("MCP_UPSTREAM_URL")
                .unwrap_or_else(|_| "http://localhost:8081".to_string()),
            listen_addr: std::env::var("MCP_LISTEN_ADDR")
                .unwrap_or_else(|_| "0.0.0.0:8080".to_string()),
            otel_endpoint: std::env::var("OTEL_EXPORTER_OTLP_ENDPOINT").ok(),
            service_name: std::env::var("OTEL_SERVICE_NAME")
                .unwrap_or_else(|_| "mcp-observability-proxy".to_string()),
        }
    }
}

// ============================================================================
// JSON-RPC Types
// ============================================================================

#[derive(Debug, Clone, Serialize, Deserialize)]
struct JsonRpcRequest {
    jsonrpc: String,
    method: String,
    #[serde(default)]
    params: Option<Value>,
    id: Option<Value>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct JsonRpcResponse {
    jsonrpc: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    result: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<JsonRpcError>,
    id: Option<Value>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct JsonRpcError {
    code: i64,
    message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    data: Option<Value>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct McpToolCallParams {
    name: String,
    #[serde(default)]
    arguments: Option<Value>,
}

// ============================================================================
// Metrics
// ============================================================================

#[derive(Clone)]
struct Metrics {
    request_counter: IntCounterVec,
    request_duration: HistogramVec,
    tool_calls: IntCounterVec,
    tool_errors: IntCounterVec,
    registry: Registry,
}

impl Metrics {
    fn new() -> Self {
        let registry = Registry::new();

        let request_counter = IntCounterVec::new(
            Opts::new("mcp_proxy_requests_total", "Total number of MCP requests"),
            &["method", "client", "experiment"],
        )
        .unwrap();

        let request_duration = HistogramVec::new(
            HistogramOpts::new("mcp_proxy_request_duration_seconds", "Request duration in seconds")
                .buckets(vec![0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0]),
            &["method", "client"],
        )
        .unwrap();

        let tool_calls = IntCounterVec::new(
            Opts::new("mcp_proxy_tool_calls_total", "Total number of tool calls"),
            &["tool_name", "client", "experiment"],
        )
        .unwrap();

        let tool_errors = IntCounterVec::new(
            Opts::new("mcp_proxy_tool_errors_total", "Total number of tool call errors"),
            &["tool_name", "client", "error_code"],
        )
        .unwrap();

        registry.register(Box::new(request_counter.clone())).unwrap();
        registry.register(Box::new(request_duration.clone())).unwrap();
        registry.register(Box::new(tool_calls.clone())).unwrap();
        registry.register(Box::new(tool_errors.clone())).unwrap();

        Self {
            request_counter,
            request_duration,
            tool_calls,
            tool_errors,
            registry,
        }
    }
}

// ============================================================================
// Observability Data
// ============================================================================

#[derive(Debug, Clone, Serialize)]
struct ObservationRecord {
    timestamp: chrono::DateTime<chrono::Utc>,
    client: String,
    experiment: Option<String>,
    session_id: Option<String>,
    method: String,
    tool_name: Option<String>,
    tool_arguments: Option<Value>,
    duration_ms: u128,
    status: String,
    error: Option<String>,
    request_size: usize,
    response_size: usize,
}

// ============================================================================
// Application State
// ============================================================================

struct AppState {
    config: Config,
    http_client: Client<hyper_util::client::legacy::connect::HttpConnector, Body>,
    metrics: Metrics,
    tracer: Option<opentelemetry_sdk::trace::Tracer>,
    observations: RwLock<Vec<ObservationRecord>>,
}

impl AppState {
    fn new(config: Config, metrics: Metrics, tracer: Option<opentelemetry_sdk::trace::Tracer>) -> Self {
        let http_client = Client::builder(TokioExecutor::new()).build_http();
        Self {
            config,
            http_client,
            metrics,
            tracer,
            observations: RwLock::new(Vec::new()),
        }
    }
}

// ============================================================================
// Handlers
// ============================================================================

/// Extract client metadata from headers
fn extract_client_metadata(headers: &HeaderMap) -> (String, Option<String>, Option<String>) {
    let client = headers
        .get("x-mcp-client")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("unknown")
        .to_string();

    let experiment = headers
        .get("x-mcp-experiment")
        .and_then(|v| v.to_str().ok())
        .map(|s| s.to_string());

    let session_id = headers
        .get("x-mcp-session")
        .and_then(|v| v.to_str().ok())
        .map(|s| s.to_string());

    (client, experiment, session_id)
}

/// Parse JSON-RPC request and extract tool information
fn parse_jsonrpc_request(body: &[u8]) -> Option<JsonRpcRequest> {
    serde_json::from_slice(body).ok()
}

/// Parse JSON-RPC response
fn parse_jsonrpc_response(body: &[u8]) -> Option<JsonRpcResponse> {
    serde_json::from_slice(body).ok()
}

/// Extract tool name from tools/call params
fn extract_tool_name(method: &str, params: &Option<Value>) -> Option<String> {
    if method == "tools/call" {
        params.as_ref().and_then(|p| {
            p.get("name")
                .and_then(|n| n.as_str())
                .map(|s| s.to_string())
        })
    } else {
        None
    }
}

/// Main proxy handler
async fn proxy_handler(
    State(state): State<Arc<AppState>>,
    request: Request,
) -> Result<Response, StatusCode> {
    let start = Instant::now();
    let (parts, body) = request.into_parts();
    let headers = parts.headers.clone();

    // Extract client metadata
    let (client, experiment, session_id) = extract_client_metadata(&headers);

    // Read request body
    let request_bytes = body
        .collect()
        .await
        .map_err(|_| StatusCode::BAD_REQUEST)?
        .to_bytes();

    let request_size = request_bytes.len();

    // Parse JSON-RPC request
    let jsonrpc_request = parse_jsonrpc_request(&request_bytes);
    let method = jsonrpc_request
        .as_ref()
        .map(|r| r.method.clone())
        .unwrap_or_else(|| "unknown".to_string());

    let tool_name = jsonrpc_request
        .as_ref()
        .and_then(|r| extract_tool_name(&r.method, &r.params));

    let tool_arguments = jsonrpc_request
        .as_ref()
        .and_then(|r| {
            if r.method == "tools/call" {
                r.params.as_ref().and_then(|p| p.get("arguments").cloned())
            } else {
                None
            }
        });

    // Start tracing span
    let span = state.tracer.as_ref().map(|tracer| {
        let mut span = tracer
            .span_builder(format!("MCP {}", method))
            .with_kind(SpanKind::Server)
            .start(tracer);

        span.set_attribute(KeyValue::new("mcp.method", method.clone()));
        span.set_attribute(KeyValue::new("mcp.client", client.clone()));
        if let Some(ref exp) = experiment {
            span.set_attribute(KeyValue::new("mcp.experiment", exp.clone()));
        }
        if let Some(ref sess) = session_id {
            span.set_attribute(KeyValue::new("mcp.session_id", sess.clone()));
        }
        if let Some(ref tool) = tool_name {
            span.set_attribute(KeyValue::new("mcp.tool.name", tool.clone()));
        }
        span
    });

    // Record metrics
    state
        .metrics
        .request_counter
        .with_label_values(&[&method, &client, experiment.as_deref().unwrap_or("none")])
        .inc();

    if let Some(ref tool) = tool_name {
        state
            .metrics
            .tool_calls
            .with_label_values(&[tool, &client, experiment.as_deref().unwrap_or("none")])
            .inc();
    }

    // Build upstream request
    let upstream_uri = format!("{}{}", state.config.upstream_url, parts.uri.path_and_query().map(|pq| pq.as_str()).unwrap_or("/"));

    let mut upstream_request = Request::builder()
        .method(parts.method)
        .uri(&upstream_uri);

    // Forward relevant headers
    for (key, value) in headers.iter() {
        if key != header::HOST {
            upstream_request = upstream_request.header(key, value);
        }
    }

    let upstream_request = upstream_request
        .body(Body::from(request_bytes.clone()))
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    // Forward to upstream
    let upstream_response = state
        .http_client
        .request(upstream_request)
        .await
        .map_err(|e| {
            error!("Upstream request failed: {}", e);
            StatusCode::BAD_GATEWAY
        })?;

    let (response_parts, response_body) = upstream_response.into_parts();

    let response_bytes = response_body
        .collect()
        .await
        .map_err(|_| StatusCode::BAD_GATEWAY)?
        .to_bytes();

    let response_size = response_bytes.len();
    let duration = start.elapsed();

    // Parse response for error tracking
    let jsonrpc_response = parse_jsonrpc_response(&response_bytes);
    let (status, error_msg) = match &jsonrpc_response {
        Some(resp) if resp.error.is_some() => {
            let err = resp.error.as_ref().unwrap();
            if let Some(ref tool) = tool_name {
                state
                    .metrics
                    .tool_errors
                    .with_label_values(&[tool, &client, &err.code.to_string()])
                    .inc();
            }
            ("error".to_string(), Some(err.message.clone()))
        }
        Some(_) => ("success".to_string(), None),
        None => ("unknown".to_string(), None),
    };

    // Record duration metric
    state
        .metrics
        .request_duration
        .with_label_values(&[&method, &client])
        .observe(duration.as_secs_f64());

    // Complete tracing span
    if let Some(mut span) = span {
        span.set_attribute(KeyValue::new("mcp.status", status.clone()));
        span.set_attribute(KeyValue::new("mcp.duration_ms", duration.as_millis() as i64));
        span.set_attribute(KeyValue::new("mcp.request_size", request_size as i64));
        span.set_attribute(KeyValue::new("mcp.response_size", response_size as i64));

        if let Some(ref err) = error_msg {
            span.set_status(Status::error(err.clone()));
        } else {
            span.set_status(Status::Ok);
        }
        span.end();
    }

    // Store observation record
    let observation = ObservationRecord {
        timestamp: chrono::Utc::now(),
        client,
        experiment,
        session_id,
        method,
        tool_name,
        tool_arguments,
        duration_ms: duration.as_millis(),
        status,
        error: error_msg,
        request_size,
        response_size,
    };

    // Log observation
    info!(
        target: "mcp_proxy",
        client = %observation.client,
        method = %observation.method,
        tool = ?observation.tool_name,
        duration_ms = %observation.duration_ms,
        status = %observation.status,
        "MCP request completed"
    );

    // Store for recent observations endpoint
    {
        let mut observations = state.observations.write().await;
        observations.push(observation);
        // Keep only last 1000 observations in memory
        if observations.len() > 1000 {
            observations.remove(0);
        }
    }

    // Build response
    let mut response = Response::builder().status(response_parts.status);

    for (key, value) in response_parts.headers.iter() {
        response = response.header(key, value);
    }

    response
        .body(Body::from(response_bytes))
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)
}

/// Health check endpoint
async fn health_handler() -> impl IntoResponse {
    (StatusCode::OK, "OK")
}

/// Prometheus metrics endpoint
async fn metrics_handler(State(state): State<Arc<AppState>>) -> impl IntoResponse {
    let encoder = TextEncoder::new();
    let metric_families = state.metrics.registry.gather();
    let mut buffer = Vec::new();
    encoder.encode(&metric_families, &mut buffer).unwrap();

    (
        [(header::CONTENT_TYPE, encoder.format_type())],
        buffer,
    )
}

/// Recent observations endpoint (for debugging/UI)
async fn observations_handler(State(state): State<Arc<AppState>>) -> impl IntoResponse {
    let observations = state.observations.read().await;
    let json = serde_json::to_string_pretty(&*observations).unwrap_or_default();

    (
        [(header::CONTENT_TYPE, "application/json")],
        json,
    )
}

// ============================================================================
// Telemetry Setup
// ============================================================================

fn init_tracer(config: &Config) -> Option<opentelemetry_sdk::trace::Tracer> {
    let endpoint = config.otel_endpoint.as_ref()?;

    let exporter = opentelemetry_otlp::new_exporter()
        .http()
        .with_endpoint(endpoint);

    let tracer = opentelemetry_otlp::new_pipeline()
        .tracing()
        .with_exporter(exporter)
        .with_trace_config(
            sdktrace::Config::default()
                .with_resource(Resource::new(vec![
                    KeyValue::new("service.name", config.service_name.clone()),
                    KeyValue::new("service.version", env!("CARGO_PKG_VERSION")),
                ])),
        )
        .install_batch(runtime::Tokio)
        .ok()?;

    Some(tracer)
}

// ============================================================================
// Main
// ============================================================================

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize logging
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::from_default_env()
                .add_directive("mcp_proxy=info".parse().unwrap()),
        )
        .json()
        .init();

    // Load configuration
    let config = Config::from_env();
    info!(
        upstream = %config.upstream_url,
        listen = %config.listen_addr,
        otel = ?config.otel_endpoint,
        "Starting MCP Observability Proxy"
    );

    // Initialize metrics
    let metrics = Metrics::new();

    // Initialize tracer
    let tracer = init_tracer(&config);
    if tracer.is_some() {
        info!("OpenTelemetry tracing enabled");
    } else {
        warn!("OpenTelemetry tracing disabled (OTEL_EXPORTER_OTLP_ENDPOINT not set)");
    }

    // Create application state
    let state = Arc::new(AppState::new(config.clone(), metrics, tracer));

    // Build router
    let app = Router::new()
        .route("/health", get(health_handler))
        .route("/metrics", get(metrics_handler))
        .route("/observations", get(observations_handler))
        .fallback(post(proxy_handler))
        .with_state(state);

    // Start server
    let listener = tokio::net::TcpListener::bind(&config.listen_addr).await?;
    info!("Listening on {}", config.listen_addr);

    axum::serve(listener, app)
        .with_graceful_shutdown(shutdown_signal())
        .await?;

    // Cleanup
    global::shutdown_tracer_provider();

    Ok(())
}

async fn shutdown_signal() {
    tokio::signal::ctrl_c()
        .await
        .expect("Failed to install CTRL+C signal handler");
    info!("Shutdown signal received");
}
```

```toml
[package]
name = "mcp-observability-proxy"
version = "0.1.0"
edition = "2021"
description = "A reverse proxy for MCP servers with observability features"
license = "MIT"
authors = ["adamsm"]

[dependencies]
# Web framework
axum = { version = "0.7", features = ["macros"] }
# Utilities
bytes = "1"
chrono = { version = "0.4", features = ["serde"] }
http-body-util = "0.1"
# HTTP client
hyper = { version = "1", features = ["full"] }
hyper-util = { version = "0.1", features = [
  "client",
  "client-legacy",
  "http1",
  "tokio"
] }
# Observability
opentelemetry = { version = "0.24", features = ["trace"] }
opentelemetry-otlp = { version = "0.17", features = [
  "http-proto",
  "reqwest-client"
] }
opentelemetry_sdk = { version = "0.24", features = ["rt-tokio", "trace"] }
prometheus = "0.13"
# Serialization
serde = { version = "1", features = ["derive"] }
serde_json = "1"
tokio = { version = "1", features = ["full"] }
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter", "json"] }

[profile.release]
strip = true
lto = true
panic = "abort"
codegen-units = 1

```

---

Summary: Accessing Token Counts & Thread Data from Zed and Claude Code

Both tools store conversation data locally, but **neither currently provides a clean API or plugin system specifically for extracting token counts and prompts programmatically**. Here's what I found:

---

### 1. Claude Code

**Data Storage Location:**

- Sessions/conversations are stored in JSON Lines (`.jsonl`) format at:
  - `~/.claude/projects/<project-hash>/<session-id>.jsonl`
- Configuration stored in `~/.claude.json` and `~/.claude/settings.json`

**Accessing Thread/Token Data:**

**Option A: Use the SDK with `--output-format json`** (Recommended)

Claude Code has an SDK/CLI mode that returns structured JSON including usage info:

```/dev/null/example.sh#L1-3
# Run claude in print mode with JSON output
claude -p "your query" --output-format json
```

This returns structured JSON with token usage from the API response.

**Option B: Parse Session Transcript Files**

The `transcript_path` (provided in hook inputs) points to `.jsonl` files containing the full conversation. You can parse these for:

- Messages (user/assistant)
- Tool calls
- API responses (which include token usage from Anthropic API)

**Option C: Use Hooks** (Best for Real-Time Monitoring)

Claude Code's **hooks system** allows you to intercept events and send data to your endpoint:

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/your-telemetry-script.py"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/log-tool-use.py"
          }
        ]
      }
    ]
  }
}
```

Your hook script receives JSON via stdin including:

- `session_id`
- `transcript_path` (full conversation history)

You can then parse the transcript and POST to your remote endpoint.

**Option D: Agent SDK (for programmatic usage)**

The Claude Agent SDK (`@anthropic-ai/claude-agent-sdk`) provides programmatic access if you're building your own tooling on top of Claude:

```/dev/null/example.ts#L1-3
npm install @anthropic-ai/claude-agent-sdk
```

---

### 2. Zed Editor

**Data Storage Location:**

- Zed stores agent/assistant threads in its local data directory:
  - macOS: `~/Library/Application Support/Zed/`
  - Linux: `~/.local/share/zed/`
- Thread history is managed by `HistoryStore` (see [history_store.rs](https://github.com/zed-industries/zed/blob/d5ed9d3e3a96492c049a1ab50819f196ed255037/crates/agent/src/history_store.rs))

**Token Usage:**
Zed tracks token counts internally in its `Thread` struct (see [thread.rs](https://github.com/zed-industries/zed/blob/d5ed9d3e3a96492c049a1ab50819f196ed255037/crates/agent/src/thread.rs)), including:

- `input_tokens`
- `output_tokens`
- Usage from API responses

**Current Limitations:**

- **No public API or extension system** for extracting this data
- **No hooks/plugins** like Claude Code has
- Data is stored in Zed's internal format, not easily parseable externally

**Potential Approaches:**

1. **Parse Zed's data files directly** (fragile, format may change)
2. **Build a Zed extension** (Zed's extension API is still evolving)
3. **Use MCP servers** - Zed supports MCP; you could potentially create an MCP server that logs interactions
4. **Feature request** - Submit a feature request to Zed for telemetry/export hooks

---

### Existing Tools/Plugins

I searched but found **no existing plugins or tools** that specifically extract token counts from either Zed or Claude Code threads for remote reporting. This appears to be a gap in the ecosystem.

---

### Recommended Approach for Your Use Case

If you need to send thread/token data to a remote endpoint, I'd suggest:

**For Claude Code:**

```python
#!/usr/bin/env python3
# telemetry-hook.py
import json
import sys
import requests

# Read hook input from stdin
input_data = json.load(sys.stdin)
session_id = input_data.get("session_id")
transcript_path = input_data.get("transcript_path")

# Parse transcript for token counts
tokens = {"input": 0, "output": 0}
with open(transcript_path, 'r') as f:
    for line in f:
        event = json.loads(line)
        # Extract usage data from API responses
        if "usage" in event:
            tokens["input"] += event["usage"].get("input_tokens", 0)
            tokens["output"] += event["usage"].get("output_tokens", 0)

# Send to your remote endpoint
requests.post("https://your-endpoint.com/telemetry", json={
    "client": "claude-code",
    "session_id": session_id,
    "tokens": tokens,
    "transcript_path": transcript_path
})

sys.exit(0)
```

Configure in `~/.claude/settings.json` to run on `SessionEnd`.

**For Zed:**
You'd likely need to:

1. Monitor Zed's data directory for changes
2. Parse the thread files (format discovery required)
3. Or create an MCP server that sits between Zed and the LLM provider to intercept responses
