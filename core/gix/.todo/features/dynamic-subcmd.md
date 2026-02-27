---
id: fc36d242-985b-451c-80c9-988622a3de57
title: Subcommands
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope: git
type: plan
status: 🚧 in-progress
publish: false
tags:
  - git
  - gix
aliases:
  - Subcommands
  - Subcommands Reference
related: []
---

# Subcommands

- Pickup additional subcommands by searching `PATH` for `gix-*`
- Identify subcommand schema dynamically
- Command attestation verification
- Subcommands must have attestations

## Metadata

- `meta`: Meta info on the command
  - `attest`
    - `provenance`
    - `slsa`
  - `sbom`
- `help`: Help command specific to this command; Used for generating MAN pages, and INFO pages
- `command`: Command Name
- `categories`: List of categories this command belongs too

```json
{
  "$schema": "https://json-schema.org/draft-07/schema",
  "type": "object",
  "required": ["person", "command"],
  "properties": {
    "subcommands": {
      "type": "array",
      "description": "Any further subcommands",
      "properties": {
        "firstName": {
          "type": "string",
          "description": "First name of the person"
        },
        "lastName": {
          "type": "string",
          "description": "Last name of the person"
        },
        "age": {
          "type": "number",
          "description": "Age in years"
        },
        "isEmployed": {
          "type": "boolean",
          "description": "Whether the person is currently employed"
        }
      },
      "required": ["firstName", "lastName"],
      "items": {
        "type": "object",
        "properties": {}
      }
    },
    "command": {
      "type": "string",
      "description": ""
    },
    "categories": {
      "type": "array",
      "description": "command categories",
      "items": {
        "type": "string"
      },
      "minItems": 1
    }
  }
}
```

## Attestation

### What is attested

- Build provenance
- SBOM verification
- Binary Hash
