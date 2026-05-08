---
name: nomos-test-execution
description: Orchestrates test execution for the Nomos monorepo following TESTING_GUIDE.md standards. Use this when running tests, debugging test failures, validating coverage, or executing verification checklists from AGENTS.md files.
---

# Nomos Test Execution Guide

This skill orchestrates test execution for the Nomos monorepo, providing command guidance and verification workflows following the project's testing standards.

## When to Use This Skill

- Running the test suite (unit, integration, or all tests)
- Debugging test failures (hermetic vs integration)
- Validating test coverage
- Executing mandatory verification checklists from `AGENTS.md` files
- Regenerating golden files for parser/compiler tests
- Running race detector
- Testing specific modules independently

## Testing Standards Overview

- **80% minimum coverage** required for all modules
- **100% coverage** for critical business logic paths
- **Table-driven tests** as standard pattern
- **Integration tests** require `//go:build integration` tag
- **Test isolation** using `t.TempDir()`
- **Hermetic tests** - no network/external deps in unit tests

## Quick Command Reference

### Basic Test Commands

```bash
# Run all tests (unit only, fast)
make test

# Run with race detector
make test-race

# Run unit tests only (explicit)
make test-unit

# Run integration tests only
make test-integration

# Run all tests (unit + integration)
make test-all

# Test specific module
make test-module MODULE=libs/parser
make test-module MODULE=libs/compiler
make test-module MODULE=apps/command-line

# Generate coverage reports
make test-coverage
```

### Build Commands (Required Before Some Tests)

```bash
# Build all applications
make build

# Build CLI specifically
make build-cli

# Build test binaries (required for integration tests)
make build-test
```

### Development Commands

```bash
# Format code before testing
make fmt

# Tidy dependencies
make mod-tidy

# Lint (requires golangci-lint)
make lint

# Full verification workflow
make fmt && make test && make lint
```

## Test Execution Workflows

### Workflow 1: Basic Unit Testing

**When:** Regular development, fast feedback loop

```bash
# 1. Run unit tests
make test

# 2. If failures, run specific module
make test-module MODULE=libs/parser

# 3. Check race conditions if suspicious
make test-race
```

**Expected output:**
```
ok      github.com/autonomous-bits/nomos/libs/parser    0.123s  coverage: 92.1% of statements
ok      github.com/autonomous-bits/nomos/libs/compiler  0.456s  coverage: 88.5% of statements
```

### Workflow 2: Pre-Commit Verification

**When:** Before committing code

```bash
# 1. Format code
make fmt

# 2. Run all unit tests
make test

# 3. Run race detector
make test-race

# 4. Lint if available
make lint
```

### Workflow 3: Full Integration Testing

**When:** Before PR, release preparation, debugging complex issues

```bash
# 1. Build test binaries first (critical!)
make build-test

# 2. Run integration tests
make test-integration

# 3. Run all tests (unit + integration)
make test-all
```

**Common mistake:** Forgetting `make build-test` causes integration tests to fail with "binary not found" errors.

### Workflow 4: Module-Specific Testing

**When:** Working on specific module, faster iteration

```bash
# Parser module
make test-module MODULE=libs/parser

# Compiler module
make test-module MODULE=libs/compiler

# CLI module
make test-module MODULE=apps/command-line
```

### Workflow 5: Coverage Validation

**When:** Ensuring coverage requirements met

```bash
# 1. Generate coverage report
make test-coverage

# 2. Open HTML report
open coverage.html  # macOS
xdg-open coverage.html  # Linux
start coverage.html  # Windows

# 3. Verify minimum 80% coverage
# Look for files below threshold
```

**Check coverage manually:**
```bash
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out | grep total
# Example output: total: (statements) 88.2%
```

## Debugging Test Failures

### Failure Type 1: Unit Test Failures

**Symptom:** Test fails in regular `make test` run

**Debug steps:**
```bash
# 1. Run specific test verbosely
cd libs/parser
go test -v -run TestParsing

# 2. Check for table-driven test case
# Look at test output to identify failing case

# 3. Run with race detector
go test -race -run TestParsing

# 4. Check test helper usage
# Ensure helpers marked with t.Helper()
```

### Failure Type 2: Integration Test Failures

**Symptom:** Test fails only with `make test-integration`

**Debug steps:**
```bash
# 1. Verify build tags present
grep -r "//go:build integration" libs/compiler/test/

# 2. Ensure test binary built
make build-test
ls -la bin/

# 3. Run integration test verbosely
cd libs/compiler
go test -v -tags=integration ./test/...

# 4. Check for external dependencies
# - Network calls?
# - File system operations?
# - Provider binary execution?
```

### Failure Type 3: Golden File Mismatches (Parser)

**Symptom:** "output mismatch" errors comparing actual vs golden files

**Debug steps:**
```bash
# 1. Review actual output
cat testdata/fixtures/test.csl
cat testdata/golden/test.csl.json

# 2. If intentional change, regenerate golden files
cd libs/parser
rm testdata/golden/test.csl.json
go test  # Will regenerate

# 3. Review diff before committing
git diff testdata/golden/

# 4. Run tests again to verify
go test
```

### Failure Type 4: Hermetic Test Violations

**Symptom:** Tests pass locally but fail in CI

**Debug steps:**
```bash
# 1. Check for hermetic violations:
# - Network calls in unit tests
# - Hardcoded paths
# - Time-dependent behavior
# - External dependencies

# 2. Verify test uses t.TempDir()
grep -A 10 "func Test" libs/compiler/*_test.go | grep TempDir

# 3. Check for missing build tags
# Unit tests should NOT have //go:build tags
# Integration tests MUST have //go:build integration

# 4. Isolate test
go test -run TestSpecific -count=1 -v
```

### Failure Type 5: Race Detector Warnings

**Symptom:** `make test-race` reports data races

**Debug steps:**
```bash
# 1. Run race detector with failing test
go test -race -run TestConcurrent -v

# 2. Examine race report
# Shows: goroutine stack traces where race occurs

# 3. Common causes:
# - Missing mutex protection
# - Shared map access
# - Provider caching without locks

# 4. Fix and re-run
make test-race
```

## Module-Specific Test Patterns

### Parser Module (libs/parser)

**Test organization:**
```
testdata/
  fixtures/     # Input .csl files
  golden/       # Expected AST outputs
  errors/       # Error test cases
```

**Common commands:**
```bash
cd libs/parser

# Run all tests
go test ./...

# Run benchmarks
go test -bench=. -benchmem

# Regenerate golden files (after intentional changes)
rm testdata/golden/*.json
go test

# Check coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

**Expected behavior:**
- Golden files auto-generate if missing (review before commit!)
- Benchmarks should meet performance goals (see AGENTS.md)
- Coverage should exceed 80%

### Compiler Module (libs/compiler)

**Test organization:**
```
testdata/          # Test fixtures
test/              # Integration tests
testutil/          # Fake providers, test helpers
```

**Common commands:**
```bash
cd libs/compiler

# Unit tests only
go test -run "^Test" ./...

# Integration tests (hermetic)
make build-test  # Critical first step
go test -tags=integration ./test/...

# All tests
go test ./... && go test -tags=integration ./test/...

# Test provider resolution specifically
go test -v -run TestProvider
```

**Expected behavior:**
- Hermetic tests use fake providers from `testutil/`
- Integration tests require real provider binaries
- Provider process cleanup verified (no zombie processes)

### CLI Module (apps/command-line)

**Test organization:**
```
testdata/          # Test configs
test/              # Integration tests (CLI invocation)
internal/          # Unit tests alongside code
```

**Common commands:**
```bash
cd apps/command-line

# Build CLI first
make build-cli

# Unit tests
go test ./internal/...

# Integration tests (invoke CLI binary)
make build-test
go test -tags=integration ./test/...

# Test specific command
go test -v -run TestInit ./internal/initcmd/
```

**Expected behavior:**
- Integration tests invoke actual CLI binary
- Exit codes verified
- Stdout/stderr captured and validated

## Verification Checklists (Mandatory)

Each module has verification requirements in `AGENTS.md`. Follow these before completing tasks:

### Universal Checklist (All Modules)

```bash
# ✅ Build Verification
make build
# All code must compile without errors

# ✅ Unit Test Verification
make test
# All existing tests must pass

# ✅ Race Detector
make test-race
# No data races reported

# ✅ Linting (if golangci-lint installed)
make lint
# No errors (warnings acceptable if documented)

# ✅ Coverage Check
make test-coverage
# Minimum 80% overall, 100% for critical paths
```

### Parser Module Checklist

```bash
cd libs/parser

# ✅ Build
go build ./...

# ✅ Unit Tests
go test ./...
# All tests pass

# ✅ Race Detector
go test -race ./...

# ✅ Golden Files
git diff testdata/golden/
# Review any changes to golden files

# ✅ Benchmarks
go test -bench=. -run=^$
# Performance meets goals

# ✅ Linting
go vet ./...
golangci-lint run

# ✅ Coverage
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out | grep total
# Minimum 80%
```

### Compiler Module Checklist

```bash
cd libs/compiler

# ✅ Build
go build ./...

# ✅ Unit Tests
go test ./...

# ✅ Integration Tests
go test -tags=integration ./test/...

# ✅ Race Detector
go test -race ./...

# ✅ Linting
go vet ./...
golangci-lint run

# ✅ Coverage
go test -coverprofile=coverage.out ./...
# Check: >= 80%
```

### CLI Module Checklist

```bash
cd apps/command-line

# ✅ Build CLI
make build-cli
./nomos --help
# Binary executes and shows help

# ✅ Unit Tests
go test ./internal/...

# ✅ Integration Tests
make build-test
go test -tags=integration ./test/...

# ✅ Race Detector
go test -race ./...

# ✅ Exit Codes
go test -v -run TestExitCode ./test/...
# Verify: 0 (success), 1 (errors), 2 (usage)

# ✅ Linting
go vet ./...
golangci-lint run

# ✅ Coverage
go test -coverprofile=coverage.out ./...
```

## Common Issues and Solutions

### Issue: "Test binary not found"

**Solution:**
```bash
make build-test
```

Integration tests require pre-built binaries.

### Issue: "go.work out of sync"

**Solution:**
```bash
make work-sync
make mod-tidy
```

### Issue: Tests pass locally, fail in CI

**Causes:**
1. Missing integration build tags
2. Hermetic test violations (network calls)
3. Platform-specific assumptions
4. Uncommitted test fixtures

**Solution:**
```bash
# Check build tags
grep -r "//go:build integration" .

# Check for network calls in unit tests
grep -r "http\." *_test.go

# Test in clean environment
git clean -xdf
make test
```

### Issue: Coverage below 80%

**Solution:**
```bash
# Identify uncovered code
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out | grep -v "100.0%"

# Add tests for uncovered functions
# Focus on critical paths first (must be 100%)
```

### Issue: Race detector warnings

**Solution:**
```bash
# Run with race detector
go test -race -v ./...

# Fix identified races:
# - Add mutex protection
# - Use channels for coordination
# - Copy data instead of sharing
```

## Best Practices

1. **Always run tests before committing:**
   ```bash
   make fmt && make test && make test-race
   ```

2. **Test specific module during development:**
   ```bash
   make test-module MODULE=libs/parser
   ```

3. **Build test binaries before integration tests:**
   ```bash
   make build-test
   ```

4. **Check coverage periodically:**
   ```bash
   make test-coverage
   ```

5. **Run full suite before PR:**
   ```bash
   make build-test && make test-all && make test-race
   ```

6. **Review golden file changes carefully:**
   ```bash
   git diff testdata/golden/
   ```

## Reference Documentation

For complete testing guidelines, see:
- [docs/TESTING_GUIDE.md](../../docs/TESTING_GUIDE.md)
- [apps/command-line/AGENTS.md](../../apps/command-line/AGENTS.md)
- [libs/compiler/AGENTS.md](../../libs/compiler/AGENTS.md)
- [libs/parser/AGENTS.md](../../libs/parser/AGENTS.md)
