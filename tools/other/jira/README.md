---
id: 2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a
title: Jira CLI Installation
created: 2025-12-13T00:00:00
updated: 2025-12-13T17:04
project: dotfiles
scope:
  - tools
  - jira
type: reference
status: ✅ active
publish: false
tags:
  - jira
  - cli
  - golang
aliases:
  - jira-install
related: []
---

# Install
```bash
# Create the configuration directory in your home folder
mkdir -p ~/.jira.d/templates

# Create the main configuration file
touch ~/.jira.d/config.yml

# Ensure you have Go modules enabled
export GO111MODULE=on

# Install go-jira directly from the repository
go install github.com/go-jira/jira/cmd/jira@latest

# Verify the installation
jira version
```
