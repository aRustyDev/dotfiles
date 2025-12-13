---
id: 4a2b9c8d-5e7f-4a1b-8c3d-9e6f2a4b7c1d
title: Environment Management (Dryad)
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:31
project: dotfiles
scope: environment
type: reference
status: ✅ active
publish: false
tags:
  - environment
  - env
  - dryad
  - xdg
  - shell
  - configuration
aliases:
  - Env Management
  - Dryad
  - Environment Variables
related: []
---

# `Env` Management

> Possible Project Names: `Dryad`

- MAYBE: use [shenv](https://github.com/shenv/shenv)
- `env` spec needs to:
  - keep `PREFIXES` seperate and modular
  - be able to manage `PREFIXES` as a `STRATEGY`
  - be able to highlight tools that don't have the ability to support diverse prefixes or ANY prefixes (ie only use static paths)
  - have links to docs (local and source/official), and blogs/resources
  - have space for comments
  - have status/stage/tags
- Need to be able to support `built-in` 'functions'
  - hostname
  - user
  - shell awareness
  - path awareness
  - fpath awareness
  - shell specific supports ([awesome](https://github.com/alebcay/awesome-shell))
    - `zsh`
    - `bash`
    - `fish`
    - `nushell`
    - `elvish`
    - `powershell`
    - `nix-shell`?
    - `tcsh`
    - `xonsh`
    - `ion`
    - `murex`
    - `oksh`/`ksh`
- direnv awareness
- Output needs to be sort-able
  - category
  - ENV KEY_PRE
  - ENV KEY_POST
  - ENV VAL_PRE
  - ENV VAL_POST
- `XDG_*` Style **_Extended_**
  - BIN
  - STATE
  - CACHE
  - DATA
  - CONFIG
  - "SCRIPTS" (Interpreted tools)
  - LIBS (Library code repos)
  - SRC (Project code repos)
  - Roles
    - shared(3), user(2), admin(1), daemon(1), system(0)
