---
id: 7e3f9a8b-2c4d-4e6a-9f5b-3d7c8e2a5b1f
title: Dotfiles Analytics Features
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:34
project: dotfiles
scope: analytics
type: plan
status: 🚧 in-progress
publish: false
tags:
  - analytics
  - features
  - json
  - sql
  - graph
  - validation
aliases:
  - Analytics
  - Dotfiles Analytics
related: []
---

# Analytics

## Feature Requests and Ideas

- Identify commands/packages that don't have "completion" entries
  - Follow on by enabling `gh-cli` code-searches to find related issues
  - ie, "they don't exist", "they aren't robust", "they aren't to standard"
- Count Lines of Code (LOC)
- Identify and centralized TODOs from across the codebase
- Make the whole codebase searchable, and indexed
- Make converters for JSON -> SQL (to support SQLite and DuckDB)
- Make converters for JSON -> Kuzu/Graph
- Make validators for all JSON files & output files
- Make unit tests to support justfiles
- Validators to determine "coverage" of the dotfiles; ie what isn't being vetted
- extract into referenced entries
  - `aliases` can be compared globally for conflicts
  - `keybindings` can be compared globally for conflicts
  - `completions` can be compared globally for conflicts
