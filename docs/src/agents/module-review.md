The formula file exists but may need format adjustments for gt's parser. Let me summarize the complete architecture:

  Complete Architecture Summary
```asciidoc
  ┌─────────────────────────────────────────────────────────────────┐
  │                     Gastown Orchestration                       │
  │  ┌───────────────────────────────────────────────────────────┐  │
  │  │  gt formula run module-review --var module=X --var parent=Y│  │
  │  └───────────────────────────────────────────────────────────┘  │
  └────────────────────────────┬────────────────────────────────────┘
                               │
           ┌───────────────────┼───────────────────┐
           ▼                   │                   ▼
  ┌─────────────────┐          │          ┌─────────────────┐
  │  Phase 1 Agent  │          │          │  Phase 2 Agent  │
  │    (haiku)      │          │          │    (sonnet)     │
  │                 │    gt mail│          │                 │
  │ - Read files    │◄─────────┤          │ - Review Ph1    │
  │ - Run checks    │          │          │ - Reclassify    │
  │ - Create issues │──────────┼─────────►│ - Judgment      │
  │   via bd create │          │          │ - Create issues │
  │ - Mail status   │──────────┘          │ - Mail summary  │
  └────────┬────────┘                     └────────┬────────┘
           │                                       │
           │           bd create / bd update       │
           └───────────────────┬───────────────────┘
                               ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │                          Beads                                   │
  │  ┌─────────────────────────────────────────────────────────┐    │
  │  │ dotfiles-pmz (Dotfiles Review Epic)                     │    │
  │  │   ├── dotfiles-pmz.61 (git module)                      │    │
  │  │   │     ├── .61.1 "git: Add [group()] attributes"       │    │
  │  │   │     ├── .61.2 "git: Add missing recipes"            │    │
  │  │   │     └── .61.3 "git: op:// format refinement"        │    │
  │  │   ├── dotfiles-pmz.51 (meilisearch module)              │    │
  │  │   └── ...                                                │    │
  │  └─────────────────────────────────────────────────────────┘    │
  │                                                                  │
  │  ┌─────────────────────────────────────────────────────────┐    │
  │  │ dotfiles-4th (Justfile Review - repo-wide issues)       │    │
  │  │   ├── "lib.just: Shell settings"                        │    │
  │  │   └── "lib.just: xdg_config definition"                 │    │
  │  └─────────────────────────────────────────────────────────┘    │
  └─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │                       Monitoring                                 │
  │  gt mail watch          - Real-time agent messages               │
  │  gt trail               - Recent agent activity                  │
  │  gt convoy list         - Batch progress                         │
  │  bd epic status         - Epic completion %                      │
  └─────────────────────────────────────────────────────────────────┘

  Files Created/Updated
  ┌────────────────────────────────────┬────────────────────────────────────────────────┐
  │                File                │                    Purpose                     │
  ├────────────────────────────────────┼────────────────────────────────────────────────┤
  │ .claude/agents/module-review.md    │ Agent spec with checklists + beads integration │
  ├────────────────────────────────────┼────────────────────────────────────────────────┤
  │ .beads/formulas/module-review.toml │ Gastown workflow formula                       │
  └────────────────────────────────────┴────────────────────────────────────────────────┘
```
