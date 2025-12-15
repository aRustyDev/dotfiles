---
id: 282896ca-c5b9-483b-81ff-f82bbe936a16
title: Gix output format
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
  - Gix output format
  - Gix output format Reference
related: []
---

# Gix output format

- all output should be formatt-able as
  - (\*) json (`jq` support)
  - markdown
  - html
  - txt
  - yaml
  - csv
  - tsv
  - toml

## Use cases

### Cleaning up local branches

- instead of `git branch --v | grep "\[gone\]" | awk '{print $1}' | xargs git branch -D`
  - `gix branch --v -o json | jq '.'`

clean-git:
git stash save "just: stashing while cleaning up"
git checkout main
git branch --v | grep "\[gone\]" | awk '{print $1}' | xargs git branch -D
git fetch origin --prune
git checkout main
git pop
