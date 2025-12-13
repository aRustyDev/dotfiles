---
id: 022a5fc5-3be4-4ab2-b682-b2833bcc7397
title: Lamoom Python Project Guide
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
  - Lamoom Python Project Guide
  - Lamoom Python Project Guide Reference
related: []
---

# Lamoom Python Project Guide

## Build/Test/Lint Commands
- Install deps: `poetry install`
- Run all tests: `poetry run pytest --cache-clear -vv tests`
- Run specific test: `poetry run pytest tests/path/to/test_file.py::test_function_name -v`
- Run with coverage: `make test`
- Format code: `make format` (runs black, isort, flake8, mypy)
- Individual formatting:
  - Black: `make make-black`
  - isort: `make make-isort`
  - Flake8: `make flake8`
  - Autopep8: `make autopep8`

## Code Style Guidelines
- Python 3.9+ compatible code
- Type hints required for all functions and methods
- Classes: PascalCase with descriptive names
- Functions/Variables: snake_case
- Constants: UPPERCASE_WITH_UNDERSCORES
- Imports organization with isort:
  1. Standard library imports
  2. Third-party imports
  3. Local application imports
- Error handling: Use specific exception types
- Logging: Use the logging module with appropriate levels
- Use dataclasses for structured data when applicable

## Project Conventions
- Use poetry for dependency management
- Add tests for all new functionality
- Maintain >80% test coverage (current min: 81%)
- Follow pre-commit hooks guidelines
- Document public APIs with docstrings