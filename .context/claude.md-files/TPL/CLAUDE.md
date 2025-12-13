---
id: 446111ce-7fde-4ed3-a8fa-c3fcd4532c07
title: TPL-GO Developer Guide
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
  - TPL-GO Developer Guide
  - TPL-GO Developer Guide Reference
related: []
---

# TPL-GO Developer Guide

## Build Commands
- `make` - Format and build project
- `make deps` - Get all dependencies
- `make test` - Run all tests

## Test Commands
- `go test -v ./...` - Run all tests verbosely
- `go test -v -run=TestName` - Run a specific test by name

## Code Style
- Use `goimports` for formatting (run via `make`)
- Follow standard Go formatting conventions
- Group imports: standard library first, then third-party
- Use PascalCase for exported types/methods, camelCase for variables
- Add comments for public API and complex logic
- Place related functionality in logically named files

## Error Handling
- Use custom `Error` type with detailed context
- Include error wrapping with `Unwrap()` method
- Return errors with proper context information (line, position)

## Testing
- Write table-driven tests with clear input/output expectations
- Use package `tpl_test` for external testing perspective
- Include detailed error messages (expected vs. actual)
- Test every exported function and error case

## Dependencies
- Minimum Go version: 1.23.0
- External dependencies managed through go modules

## Modernization Notes
- Use `errors.Is()` and `errors.As()` for error checking
- Replace `interface{}` with `any` type alias
- Replace type assertions with type switches where appropriate
- Use generics for type-safe operations
- Implement context cancellation handling for long operations
- Add proper docstring comments for exported functions and types
- Use log/slog for structured logging
- Add linting and static analysis tools