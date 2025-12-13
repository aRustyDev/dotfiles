---
id: 12345678-9abc-def0-1234-56789abcdef0
title: Metadata Schema
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:29
project: dotfiles
scope:
  - general
type: reference
status: 📝 draft
publish: false
tags:
  - metadata
  - schema
  - json
aliases:
  - Meta.json Schema
related: []
---

# Metadata

```json
{
  "version": "1.0.0",
  "category": "example",
  "tags": ["example", "template"],
  "description": "This is an example meta.json file",
  "completions": {
    "cmd": ""
  },
  "dependencies": {
    "binaries": ["dependency1", "dependency2"],
    "env_vars": ["FOOENV"]
  },
  "url": {
    "contribute": "",
    "bugz": "",
    "docs": ""
  },
  "dotdir": true,
  "env": {
    "shell": "./path/to/env.yaml",
    "dir": "./path/to/.env"
  },
  "just": ["./path/to/sub/justfile", "./path/to/justfile"],
  "templates": [
    "$REPO/path/to/sub/template.yaml",
    "$REPO/path/to/template.yaml"
  ],
  "loc": 0,
  "health_checks": [],
  "generates": [],
  "platform_overrides": {
    "darwin": {
      "just": ["./path/to/sub/justfile", "./path/to/justfile"],
      "templates": [
        "$REPO/path/to/sub/template.yaml",
        "$REPO/path/to/template.yaml"
      ]
    },
    "linux": {
      "just": ["./path/to/sub/justfile", "./path/to/justfile"],
      "templates": [
        "$REPO/path/to/sub/template.yaml",
        "$REPO/path/to/template.yaml"
      ]
    },
    "windows": {
      "just": ["./path/to/sub/justfile", "./path/to/justfile"],
      "templates": [
        "$REPO/path/to/sub/template.yaml",
        "$REPO/path/to/template.yaml"
      ]
    }
  },
  "xdg": {
    "bin": null,
    "data": null,
    "cache": null,
    "state": null,
    "config": null
  }
}
```
