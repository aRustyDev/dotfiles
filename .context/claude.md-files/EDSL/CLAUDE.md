---
id: fe2ae629-9886-4e32-908c-6f40b8cdefc4
title: EDSL Codebase Reference
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope: ai
type: reference
status: ✅ active
publish: false
tags:
  - claude
  - context
aliases:
  - EDSL Codebase Reference
  - EDSL Codebase Reference Reference
related: []
---

# EDSL Codebase Reference

## Build & Test Commands
- Install: `make install`
- Run all tests: `make test`
- Run single test: `pytest -xv tests/path/to/test.py`
- Run with coverage: `make test-coverage`
- Run integration tests: `make test-integration`
- Type checking: `make lint` (runs mypy)
- Format code: `make format` (runs black-jupyter)
- Generate docs: `make docs`
- View docs: `make docs-view`

## Code Style Guidelines
- **Formatting**: Use Black for consistent code formatting
- **Imports**: Group by stdlib, third-party, internal modules
- **Type hints**: Required throughout, verified by mypy
- **Naming**: 
  - Classes: PascalCase
  - Methods/functions/variables: snake_case
  - Constants: UPPER_SNAKE_CASE
  - Private items: _prefixed_with_underscore
- **Error handling**: Use custom exception hierarchy with BaseException parent
- **Documentation**: Docstrings for all public functions/classes
- **Testing**: Every feature needs associated tests

## Permissions Guidelines
- **Allowed without asking**: Running tests, linting, code formatting, viewing files
- **Ask before**: Modifying tests, making destructive operations, installing packages
- **Never allowed**: Pushing directly to main branch, changing API keys/secrets