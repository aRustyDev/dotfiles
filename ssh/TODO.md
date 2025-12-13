---
id: 0b1c2d3e-4f5a-6b7c-8d9e-0f1a2b3c4d5e
title: SSH Configuration TODO
created: 2025-12-13T00:00:00
updated: 2025-12-13T17:04
project: dotfiles
scope:
  - network
  - ssh
type: plan
status: 🚧 in-progress
publish: false
tags:
  - ssh
  - teleport
  - configuration
aliases:
  - ssh-tasks
related: []
---

# TODO

## SSH

| status | Task                                                       | notes          |
| ------ | ---------------------------------------------------------- | -------------- |
| `todo` | [teleport][teleport]: Implement Agentless SSH              |                |
| `todo` | [cue][cue-file]: create validation for config files        | `op://` syntax |
| `todo` | [tree-sitter][tree-sitter-parser]: extend parser           | `op://` syntax |
| `todo` | [tree-sitter][tree-sitter-highlighter]: extend highlighter | `op://` syntax |
| `todo` | [configs][docs-ssh-config]: review configs for further use |                |

- [teleport]: https://goteleport.com/docs/enroll-resources/server-access/openssh/openssh-agentless/
- [cue-file]: ../.build/cue/ssh
- [tree-sitter-highlighter]: ../tree-sitter/highlights/ssh-config
- [tree-sitter-parser]: ../tree-sitter/parsers/ssh-config
- [docs-ssh-config]: https://www.ssh.com/academy/ssh/config
- [man-ssh-config]: https://www.ssh.com/academy/ssh/config
