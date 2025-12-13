---
created: 2025-12-13T11:47
updated: 2025-12-13T11:55
---

# CCometixLine Feature Roadmap

## Tier 1: Critical Gaps (Parity Features)

| Feature                        | Source                               | Why Critical                                              |
| ------------------------------ | ------------------------------------ | --------------------------------------------------------- |
| Multi-line support (1-9 lines) | claude-code-statusline               | Single biggest limitation; all competitors have this      |
| ASCII charset fallback         | claude-powerline, ccstatusline       | Nerd Font requirement blocks adoption                     |
| Cost tracking segments         | All competitors                      | Session cost, daily cost, block cost, burn rate           |
| Block timer                    | ccstatusline, claude-code-statusline | 5-hour billing window tracking is essential for Max users |

## Tier 2: Competitive Advantages

| Feature                      | Source                 | Differentiation                                         |
| ---------------------------- | ---------------------- | ------------------------------------------------------- |
| MCP server status            | claude-code-statusline | Only one tool has this; growing importance              |
| Detailed git segment options | claude-powerline       | SHA, stash count, time-since-commit, upstream, worktree |
| Session metrics              | claude-powerline       | Response time, lines added/removed, message count       |
| Auto-wrap layout             | claude-powerline       | Segments wrap to terminal width automatically           |
| Widget alignment             | ccstatusline           | Auto-align segments across multiple lines               |

## Tier 3: Unique Differentiators (Leverage Rust)

| Feature                          | Rationale                                                  |
| -------------------------------- | ---------------------------------------------------------- |
| Sub-10ms multi-line rendering    | Rust advantage - be 10x faster than Bash/Node              |
| Embedded ccusage                 | Compile ccusage logic directly in (no external dependency) |
| Live updating                    | Watch mode with efficient polling (Rust async)             |
| Memory-mapped transcript parsing | Fast large file handling for usage stats                   |
| WASM build                       | Run in browser-based terminals (unique)                    |

## Tier 4: Polish & DX

| Feature                            | Source           | Notes                                       |
| ---------------------------------- | ---------------- | ------------------------------------------- |
| Interactive segment picker in TUI  | ccstatusline     | Drag-and-drop segment ordering              |
| Theme import/export                | All              | Share themes as single files                |
| --preview mode                     | -                | Test statusline without Claude Code running |
| Config validation with suggestions | -                | ccline check with fix suggestions           |
| Per-project config                 | claude-powerline | .claude-powerline.json pattern              |

---

## Implementation Priority Matrix

```asciidoc

                      HIGH IMPACT
                           │
      ┌────────────────────┼────────────────────┐
      │                    │                    │
      │  Multi-line        │  MCP Status        │
      │  ASCII fallback    │  Embedded ccusage  │
      │  Cost tracking     │  Auto-wrap         │
      │  Block timer       │                    │
      │                    │                    │
  LOW ├────────────────────┼────────────────────┤ HIGH
  EFFORT                   │                    EFFORT
      │                    │                    │
      │  Per-project cfg   │  WASM build        │
      │  Theme export      │  Live updating     │
      │  Preview mode      │  Segment alignment │
      │                    │                    │
      └────────────────────┼────────────────────┘
                           │
                      LOW IMPACT
```

Suggested Phased Rollout Phase 1: Parity (v2.0)

```toml
# New config structure
[display]
lines = 3
charset = "unicode"  # or "ascii"
auto_wrap = true

[[display.line]]
segments = ["directory", "git", "model"]

[[display.line]]
segments = ["session_cost", "block_timer", "context"]

[[display.line]]
segments = ["daily_cost", "burn_rate", "mcp_status"]
```

New segments:

- session_cost - Current session $
- daily_cost - Today's total $
- block_cost - 5-hour window $
- block_timer - Time remaining in block
- burn_rate - $/hr or tokens/min

Phase 2: Leadership (v2.5)

```toml
[git]
show_sha = true
show_stash = true
show_upstream = true
show_time_since_commit = true
show_worktree = true

[metrics]
show_response_time = true
show_lines_changed = true
show_message_count = true

[mcp]
enabled = true
show_server_count = true
show_connection_status = true
```

Phase 3: Unique Value (v3.0)

- Embedded usage tracking (no ccusage dependency)
- Sub-process watching for live updates
- WASM target for Codespaces/web terminals
- Plugin system for custom segments (Lua or WASM)

---

```toml
# Config Example (Target State)

[display]
lines = 2
charset = "unicode"  # "ascii" for no Nerd Font
auto_wrap = false
alignment = true     # align segments across lines

[theme]
name = "nord"        # or custom hex colors

# Line 1: Project context
[[line]]
segments = ["directory", "git", "model", "context"]

# Line 2: Cost & performance
[[line]]
segments = ["session_cost", "block_timer", "burn_rate", "mcp_status"]

[segments.git]
style = "detailed"   # minimal | default | detailed
show_sha = true
show_stash = true

[segments.block_timer]
style = "progress"   # time | progress | both
width = 16           # progress bar width

[segments.mcp_status]
show_count = true
show_names = false   # list server names

[budget]
daily_limit = 25.0
block_limit = 15.0
warning_threshold = 80
```

---

Quick Wins (Weekend Projects)

1. ASCII charset - Simple icon mapping table
2. --preview flag - Render with mock data
3. Session cost segment - Parse transcript for token counts
4. Per-project config - Check ./.ccline.toml first

These four alone would close 60% of the gap with minimal effort.
