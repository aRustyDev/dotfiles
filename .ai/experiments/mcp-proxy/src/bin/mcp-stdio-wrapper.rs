//! MCP Stdio Wrapper
//!
//! A transparent wrapper for MCP servers that intercepts stdio communication
//! and logs all requests/responses to an observability proxy.
//!
//! Usage:
//!   mcp-stdio-wrapper [--proxy-url URL] [--client NAME] [--experiment ID] -- <command> [args...]
//!
//! Example:
//!   mcp-stdio-wrapper --client claude-code --experiment baseline -- npx @modelcontextprotocol/server-github
//!
//! The wrapper:
//! 1. Spawns the actual MCP server as a subprocess
//! 2. Forwards stdin to the subprocess
//! 3. Forwards subprocess stdout to our stdout
//! 4. Asynchronously logs all JSON-RPC messages to the observability proxy

use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::env;
use std::io::{self, BufRead, BufReader, Write};
use std::process::{Command, Stdio};
use std::sync::mpsc;
use std::thread;
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};
use uuid::Uuid;

// ============================================================================
// Configuration
// ============================================================================

#[derive(Clone, Debug)]
struct Config {
    proxy_url: String,
    client: String,
    experiment: Option<String>,
    session_id: String,
    command: String,
    args: Vec<String>,
    async_logging: bool,
}

impl Config {
    fn from_args() -> Result<Self, String> {
        let args: Vec<String> = env::args().collect();

        let mut proxy_url = env::var("MCP_PROXY_URL")
            .unwrap_or_else(|_| "http://localhost:8080/log".to_string());
        let mut client = env::var("MCP_CLIENT")
            .unwrap_or_else(|_| "unknown".to_string());
        let mut experiment = env::var("MCP_EXPERIMENT").ok();
        let session_id = env::var("MCP_SESSION_ID")
            .unwrap_or_else(|_| Uuid::new_v4().to_string());
        let async_logging = env::var("MCP_ASYNC_LOGGING")
            .map(|v| v == "true" || v == "1")
            .unwrap_or(true);

        let mut i = 1;
        let mut command_start = None;

        while i < args.len() {
            match args[i].as_str() {
                "--proxy-url" => {
                    i += 1;
                    if i >= args.len() {
                        return Err("--proxy-url requires a value".to_string());
                    }
                    proxy_url = args[i].clone();
                }
                "--client" => {
                    i += 1;
                    if i >= args.len() {
                        return Err("--client requires a value".to_string());
                    }
                    client = args[i].clone();
                }
                "--experiment" => {
                    i += 1;
                    if i >= args.len() {
                        return Err("--experiment requires a value".to_string());
                    }
                    experiment = Some(args[i].clone());
                }
                "--" => {
                    command_start = Some(i + 1);
                    break;
                }
                arg if arg.starts_with('-') => {
                    return Err(format!("Unknown option: {}", arg));
                }
                _ => {
                    command_start = Some(i);
                    break;
                }
            }
            i += 1;
        }

        let command_start = command_start
            .ok_or_else(|| "No command specified".to_string())?;

        if command_start >= args.len() {
            return Err("No command specified".to_string());
        }

        let command = args[command_start].clone();
        let cmd_args = args[command_start + 1..].to_vec();

        Ok(Config {
            proxy_url,
            client,
            experiment,
            session_id,
            command,
            args: cmd_args,
            async_logging,
        })
    }
}

// ============================================================================
// Log Message Types
// ============================================================================

#[derive(Debug, Clone, Serialize)]
struct LogMessage {
    timestamp: u64,
    session_id: String,
    client: String,
    experiment: Option<String>,
    direction: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    method: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    id: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    tool_name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    duration_ms: Option<u128>,
    #[serde(skip_serializing_if = "Option::is_none")]
    is_error: Option<bool>,
    raw: String,
}

#[derive(Debug, Deserialize)]
struct JsonRpcMessage {
    #[serde(default)]
    method: Option<String>,
    #[serde(default)]
    params: Option<Value>,
    #[serde(default)]
    id: Option<Value>,
    #[serde(default)]
    result: Option<Value>,
    #[serde(default)]
    error: Option<Value>,
}

// ============================================================================
// Logging
// ============================================================================

fn send_log(proxy_url: &str, message: LogMessage) {
    let client = match ureq::AgentBuilder::new()
        .timeout(Duration::from_secs(5))
        .build()
        .post(proxy_url)
        .set("Content-Type", "application/json")
        .set("X-MCP-Client", &message.client)
        .set("X-MCP-Session", &message.session_id)
        .set("X-MCP-Direction", &message.direction)
        .send_json(&message)
    {
        Ok(_) => {}
        Err(e) => {
            eprintln!("[mcp-wrapper] Failed to send log: {}", e);
        }
    }
}

fn extract_tool_name(method: &Option<String>, params: &Option<Value>) -> Option<String> {
    if method.as_deref() == Some("tools/call") {
        params
            .as_ref()
            .and_then(|p| p.get("name"))
            .and_then(|n| n.as_str())
            .map(|s| s.to_string())
    } else {
        None
    }
}

fn current_timestamp_ms() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as u64)
        .unwrap_or(0)
}

// ============================================================================
// Main
// ============================================================================

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let config = Config::from_args().map_err(|e| {
        eprintln!("Usage: mcp-stdio-wrapper [OPTIONS] -- <command> [args...]");
        eprintln!();
        eprintln!("Options:");
        eprintln!("  --proxy-url URL     Observability proxy URL (default: $MCP_PROXY_URL or http://localhost:8080/log)");
        eprintln!("  --client NAME       Client identifier (default: $MCP_CLIENT or 'unknown')");
        eprintln!("  --experiment ID     Experiment identifier (default: $MCP_EXPERIMENT)");
        eprintln!();
        eprintln!("Environment variables:");
        eprintln!("  MCP_PROXY_URL       Observability proxy URL");
        eprintln!("  MCP_CLIENT          Client identifier");
        eprintln!("  MCP_EXPERIMENT      Experiment identifier");
        eprintln!("  MCP_SESSION_ID      Session ID (auto-generated if not set)");
        eprintln!("  MCP_ASYNC_LOGGING   Enable async logging (default: true)");
        eprintln!();
        eprintln!("Error: {}", e);
        std::process::exit(1);
    })?;

    eprintln!(
        "[mcp-wrapper] Starting: {} {:?}",
        config.command, config.args
    );
    eprintln!("[mcp-wrapper] Client: {}", config.client);
    eprintln!("[mcp-wrapper] Session: {}", config.session_id);
    eprintln!("[mcp-wrapper] Proxy: {}", config.proxy_url);

    // Spawn the actual MCP server
    let mut child = Command::new(&config.command)
        .args(&config.args)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::inherit())
        .spawn()
        .map_err(|e| format!("Failed to spawn command '{}': {}", config.command, e))?;

    let child_stdin = child.stdin.take().expect("Failed to open child stdin");
    let child_stdout = child.stdout.take().expect("Failed to open child stdout");

    // Create channel for async logging
    let (log_tx, log_rx) = mpsc::channel::<LogMessage>();

    // Track pending requests for duration calculation
    let pending_requests = std::sync::Arc::new(std::sync::Mutex::new(
        std::collections::HashMap::<String, Instant>::new(),
    ));

    // Spawn logging thread
    let proxy_url = config.proxy_url.clone();
    let logging_thread = thread::spawn(move || {
        for message in log_rx {
            send_log(&proxy_url, message);
        }
    });

    // Clone for threads
    let config_stdin = config.clone();
    let log_tx_stdin = log_tx.clone();
    let pending_requests_stdin = pending_requests.clone();

    // Thread: Read from our stdin, write to child stdin, log requests
    let stdin_thread = thread::spawn(move || {
        let stdin = io::stdin();
        let mut child_stdin = child_stdin;

        for line in stdin.lock().lines() {
            let line = match line {
                Ok(l) => l,
                Err(e) => {
                    eprintln!("[mcp-wrapper] Error reading stdin: {}", e);
                    break;
                }
            };

            // Forward to child
            if let Err(e) = writeln!(child_stdin, "{}", line) {
                eprintln!("[mcp-wrapper] Error writing to child: {}", e);
                break;
            }
            if let Err(e) = child_stdin.flush() {
                eprintln!("[mcp-wrapper] Error flushing child stdin: {}", e);
                break;
            }

            // Parse and log
            let parsed: Option<JsonRpcMessage> = serde_json::from_str(&line).ok();

            let method = parsed.as_ref().and_then(|p| p.method.clone());
            let id = parsed.as_ref().and_then(|p| p.id.clone());
            let tool_name = parsed
                .as_ref()
                .and_then(|p| extract_tool_name(&p.method, &p.params));

            // Track request timing
            if let Some(ref id) = id {
                let id_str = serde_json::to_string(id).unwrap_or_default();
                pending_requests_stdin
                    .lock()
                    .unwrap()
                    .insert(id_str, Instant::now());
            }

            let log_msg = LogMessage {
                timestamp: current_timestamp_ms(),
                session_id: config_stdin.session_id.clone(),
                client: config_stdin.client.clone(),
                experiment: config_stdin.experiment.clone(),
                direction: "request".to_string(),
                method,
                id,
                tool_name,
                duration_ms: None,
                is_error: None,
                raw: line,
            };

            let _ = log_tx_stdin.send(log_msg);
        }
    });

    // Clone for stdout thread
    let config_stdout = config.clone();
    let log_tx_stdout = log_tx.clone();
    let pending_requests_stdout = pending_requests.clone();

    // Thread: Read from child stdout, write to our stdout, log responses
    let stdout_thread = thread::spawn(move || {
        let reader = BufReader::new(child_stdout);
        let stdout = io::stdout();
        let mut stdout_lock = stdout.lock();

        for line in reader.lines() {
            let line = match line {
                Ok(l) => l,
                Err(e) => {
                    eprintln!("[mcp-wrapper] Error reading from child: {}", e);
                    break;
                }
            };

            // Forward to our stdout
            if let Err(e) = writeln!(stdout_lock, "{}", line) {
                eprintln!("[mcp-wrapper] Error writing to stdout: {}", e);
                break;
            }
            if let Err(e) = stdout_lock.flush() {
                eprintln!("[mcp-wrapper] Error flushing stdout: {}", e);
                break;
            }

            // Parse and log
            let parsed: Option<JsonRpcMessage> = serde_json::from_str(&line).ok();

            let id = parsed.as_ref().and_then(|p| p.id.clone());
            let is_error = parsed.as_ref().map(|p| p.error.is_some());

            // Calculate duration if this is a response to a tracked request
            let duration_ms = id.as_ref().and_then(|id| {
                let id_str = serde_json::to_string(id).unwrap_or_default();
                pending_requests_stdout
                    .lock()
                    .unwrap()
                    .remove(&id_str)
                    .map(|start| start.elapsed().as_millis())
            });

            let log_msg = LogMessage {
                timestamp: current_timestamp_ms(),
                session_id: config_stdout.session_id.clone(),
                client: config_stdout.client.clone(),
                experiment: config_stdout.experiment.clone(),
                direction: "response".to_string(),
                method: None,
                id,
                tool_name: None,
                duration_ms,
                is_error,
                raw: line,
            };

            let _ = log_tx_stdout.send(log_msg);
        }
    });

    // Wait for threads
    let _ = stdin_thread.join();
    let _ = stdout_thread.join();

    // Close log channel and wait for logging thread
    drop(log_tx);
    let _ = logging_thread.join();

    // Wait for child process
    let status = child.wait()?;

    eprintln!("[mcp-wrapper] Child process exited with: {}", status);

    std::process::exit(status.code().unwrap_or(1));
}
