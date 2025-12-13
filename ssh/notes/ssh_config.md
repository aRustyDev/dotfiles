---
id: 1c2d3e4f-5a6b-7c8d-9e0f-1a2b3c4d5e6f
title: SSH Configuration Notes
created: 2025-12-13T00:00:00
updated: 2025-12-13T17:04
project: dotfiles
scope:
  - network
  - ssh
type: reference
status: 📝 draft
publish: false
tags:
  - ssh
  - configuration
  - environment
aliases:
  - ssh-notes
related: []
---

# SSH Configuration Notes

- [`SetEnv`][sshdoc-setenv]: Directly specify ENV=VAR to be sent to the server. Similarly to SendEnv, with the exception of the TERM variable, the server must be prepared to accept the environment variable.
- [`SendEnv`][sshdoc-setenv]: Specifies what whitespace separated ENVs from the local environ(7) should be sent to the server.
  - The server must also support it.
  - Variables are specified by name, which may contain wildcard characters.
  - the server must be configured to accept these environment variables.
  - TERM environment variable is always sent whenever a pseudo-terminal is requested as it is required by the protocol.

- [sshdoc-setenv]: https://man.openbsd.org/ssh_config.5#SetEnv
