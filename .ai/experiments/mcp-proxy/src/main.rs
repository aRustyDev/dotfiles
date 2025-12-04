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
