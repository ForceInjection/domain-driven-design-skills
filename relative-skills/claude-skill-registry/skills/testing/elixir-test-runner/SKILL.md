---
name: elixir-test-runner
description: Run ExUnit tests with smart filtering, debugging options, and proper error reporting. Use when running tests, debugging failures, or validating specific test cases.
allowed-tools: Bash, Read, Grep
---

# Elixir Test Runner

This skill helps run ExUnit tests efficiently with proper filtering, debugging, and error analysis.

## When to Use

- Running full test suite
- Testing specific files or tests
- Debugging test failures
- Running tests with coverage
- Testing in different environments

## Basic Test Execution

### Run All Tests
```bash
mix test
```

### Run Specific Test File
```bash
mix test test/my_app/accounts_test.exs
```

### Run Specific Test by Line Number
```bash
mix test test/my_app/accounts_test.exs:42
```

### Run Tests Matching Pattern
```bash
# Run all tests with "user" in the name
mix test --only user
```

## Test Filtering

### By Tag
```elixir
# In test file
@tag :integration
test "complex integration test" do
  # ...
end
```

```bash
# Run only integration tests
mix test --only integration

# Exclude slow tests
mix test --exclude slow

# Run everything except integration
mix test --exclude integration
```

### By Module Pattern
```bash
# Run all controller tests
mix test test/**/controllers/*_test.exs

# Run all LiveView tests
mix test test/**/*_live_test.exs
```

### Umbrella App Filtering
```bash
# Run tests for specific app
mix test apps/my_app/test

# Run all umbrella tests
mix test --only apps
```

## Debugging Options

### With Trace (Detailed Output)
```bash
mix test --trace
```
Shows each test as it runs - useful for hanging tests.

### With Verbose Failures
```bash
mix test --max-failures 1
```
Stops after first failure for faster debugging.

### With Test Seed
```bash
# Tests run in random order by default
# To reproduce specific order:
mix test --seed 123456

# See seed in output:
# "Randomized with seed 123456"
```

### With IEx for Debugging
```bash
# Add IEx.pry() in test code
mix test --trace
```

## Test Output Control

### Show Only Failures
```bash
mix test --failed
```
Reruns only previously failed tests.

### Stale Tests
```bash
mix test --stale
```
Only runs tests for changed files.

### With Coverage
```bash
mix test --cover
```
Generates coverage report in `cover/` directory.

### Quiet Mode
```bash
mix test --quiet
```
Less verbose output.

## Test Environments

### Standard Test Run
```bash
mix test
```
Uses MIX_ENV=test automatically.

### With Database Reset
```bash
mix ecto.reset && mix test
```
Fresh database for each run.

### CI Mode
```bash
# Ensure warnings fail, run with coverage
mix test --warnings-as-errors --cover
```

## Common Test Patterns

### Test Suite Organization

**Unit Tests** (fast, isolated):
```bash
mix test test/my_app/accounts/user_test.exs
```

**Integration Tests** (slower, with database):
```bash
mix test --only integration
```

**Controller Tests**:
```bash
mix test test/my_app_web/controllers/
```

**LiveView Tests**:
```bash
mix test test/my_app_web/live/
```

### Parallel Testing

```elixir
# In test_helper.exs - already default
ExUnit.start()

# In DataCase
use MyApp.DataCase, async: true  # Parallel execution
```

```bash
# Run with more cores
mix test --max-cases 8
```

## Analyzing Test Failures

### Read Failure Output Carefully

Example failure:
```
1) test creates user with valid attrs (MyApp.AccountsTest)
   test/my_app/accounts_test.exs:42
   ** (RuntimeError) Database not started
```

**What to check:**
1. Test name: "creates user with valid attrs"
2. Module: MyApp.AccountsTest
3. File and line: test/my_app/accounts_test.exs:42
4. Error: Database not started

### Common Failure Patterns

**Database Not Started:**
```bash
# Start database
mix ecto.create
MIX_ENV=test mix ecto.migrate
```

**Async Test Conflicts:**
```elixir
# Change to synchronous if tests conflict
use MyApp.DataCase, async: false
```

**Missing Setup:**
```elixir
# Check for missing setup block
setup do
  :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
end
```

**Factory/Fixture Issues:**
```bash
# Verify factory data is valid
mix test test/support/fixtures.exs --trace
```

## Performance Optimization

### Identify Slow Tests
```bash
# Run with timing
mix test --trace | grep -E "^\s+test.*\([0-9]+\.[0-9]+s\)"
```

### Profile Test Suite
```bash
# With profiling
mix test --profile
```

### Parallel Execution
```elixir
# Enable async for fast unit tests
use MyApp.DataCase, async: true

# Disable for integration tests
use MyApp.DataCase, async: false
```

## Test Coverage

### Generate Coverage Report
```bash
mix test --cover
```

View report: `cover/excoveralls.html`

### Coverage Configuration
```elixir
# In mix.exs
def project do
  [
    test_coverage: [tool: ExCoveralls],
    preferred_cli_env: [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  ]
end
```

### With ExCoveralls
```bash
# HTML report
mix coveralls.html

# Detailed console report
mix coveralls.detail

# Check coverage threshold
mix coveralls --min-coverage 80
```

## CI/CD Integration

### GitHub Actions
```yaml
- name: Run tests
  run: mix test --warnings-as-errors --cover
```

### GitLab CI
```yaml
test:
  script:
    - mix ecto.create
    - mix ecto.migrate
    - mix test --cover
```

### Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit
mix test --failed || exit 1
```

## Troubleshooting

### Tests Hang
```bash
# Use --trace to see which test hangs
mix test --trace

# Look for:
# - Database connection issues
# - Infinite loops
# - Missing async: false for conflicting tests
```

### Tests Pass Locally, Fail in CI
**Common causes:**
1. Missing MIX_ENV=test
2. Database not created
3. Dependencies not fetched
4. Different Elixir/OTP versions
5. Async test conflicts

**Debug:**
```bash
# Reproduce CI environment locally
MIX_ENV=test mix do deps.get, ecto.create, ecto.migrate, test
```

### Flaky Tests
```bash
# Run same test multiple times
mix test test/my_app/accounts_test.exs:42 --trace
mix test test/my_app/accounts_test.exs:42 --trace
mix test test/my_app/accounts_test.exs:42 --trace

# Check for:
# - Time-dependent logic
# - Random data without seeds
# - Async conflicts
# - External dependencies
```

### Memory Issues
```bash
# Run with more memory
elixir --erl "+hms 4294967296" -S mix test
```

## Best Practices

1. **Run tests frequently** during development
2. **Use --stale** for fast feedback loop
3. **Tag slow tests** and exclude during dev
4. **Fix failures immediately** - don't accumulate
5. **Use --trace** when debugging
6. **Run full suite** before committing
7. **Check coverage** for critical code paths
8. **Keep tests fast** - mock external services
9. **Use factories** for consistent test data
10. **Run in CI** to catch environment issues

## Quick Reference

```bash
# Development workflow
mix test --stale                    # Fast feedback
mix test test/my_app/file_test.exs # Specific file
mix test --failed                   # Rerun failures

# Debugging
mix test --trace                    # See each test
mix test --max-failures 1          # Stop at first failure
mix test --seed 123456             # Reproduce order

# Coverage
mix test --cover                    # Basic coverage
mix coveralls.html                  # Detailed HTML

# Filtering
mix test --only integration        # Tagged tests
mix test --exclude slow            # Exclude tagged

# CI/CD
mix test --warnings-as-errors --cover
```
