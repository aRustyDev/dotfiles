# Add testing framework for git-setup

## Description

Implement comprehensive testing for the git-setup command to ensure reliability and prevent regressions during development.

## Testing Requirements

### 1. Unit Tests
- [ ] Profile CRUD operations
- [ ] JSON parsing and validation
- [ ] Error handling functions
- [ ] Fuzzy matching algorithm
- [ ] Cache management

### 2. Integration Tests
- [ ] 1Password CLI interaction (with mocks)
- [ ] Git configuration commands
- [ ] File system operations
- [ ] Profile storage persistence

### 3. End-to-End Tests
- [ ] Complete workflow: add profile → use profile → verify git config
- [ ] Migration scenarios
- [ ] Error recovery scenarios
- [ ] Multi-profile management

### 4. Performance Tests
- [ ] Cache effectiveness
- [ ] Large profile list handling
- [ ] 1Password API call reduction
- [ ] Response time benchmarks

## Test Infrastructure

### Test Framework
- Bash testing framework (bats-core recommended)
- Mock 1Password CLI responses
- Isolated test environments
- CI/CD integration

### Test Data
```bash
# Mock 1Password responses
mock_ssh_keys.json
mock_item_details.json
mock_error_responses.json

# Test profiles
test_profiles.json
```

### Test Structure
```
tests/
├── unit/
│   ├── profile_management_test.sh
│   ├── fuzzy_matching_test.sh
│   └── cache_test.sh
├── integration/
│   ├── 1password_test.sh
│   └── git_config_test.sh
├── e2e/
│   └── full_workflow_test.sh
└── fixtures/
    └── mock_data/
```

## Acceptance Criteria

- [ ] 80%+ code coverage
- [ ] All critical paths tested
- [ ] Tests run in CI/CD pipeline
- [ ] Mock 1Password integration works
- [ ] Tests are maintainable and clear

## CI/CD Integration

- Run tests on every PR
- Block merge on test failure
- Performance regression detection
- Coverage reports generated

## Labels

- `testing`
- `infrastructure`
- `git`

## Milestone

Testing Framework

## Dependencies

- Issue #2 (MVP) and #4 (Advanced features) should be implemented
