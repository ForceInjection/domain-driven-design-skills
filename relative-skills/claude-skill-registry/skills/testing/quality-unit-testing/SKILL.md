---
name: quality-unit-testing
description: Write high-quality Rust unit tests following best practices. Use when writing new tests, reviewing test code, or improving test quality. Emphasizes clear naming, AAA pattern, isolation, and deployment confidence.
---

# Quality Unit Testing for Rust

Expert guidance for writing unit tests that catch real bugs and provide deployment confidence.

## Core Philosophy

**Quality over coverage**: Tests should catch real bugs and enable fearless deployment, not just boost coverage percentages.

## When to Use This Skill

Use for:
- Writing new unit tests
- Reviewing test code quality
- Improving existing test suites
- Establishing testing standards
- Evaluating test effectiveness

## Quick Reference

### Test Naming: `test_<function>_<scenario>_<expected_behavior>`

Use descriptive three-part names for most tests. Well-named two-part names are acceptable for very simple tests:

**Preferred (three-part):**
```rust
#[test]
fn test_process_payment_insufficient_funds_returns_error()

#[test]
fn test_calculate_discount_new_customer_returns_zero()

#[tokio::test]
async fn test_withdraw_valid_amount_decreases_balance()
```

**Acceptable for simple tests (two-part):**
```rust
#[test]
fn test_new_account_initializes_fields()  // When behavior is obvious

#[test]
fn test_default_context_values()  // When scenario is implicit
```

### AAA Pattern: Arrange-Act-Assert

Structure tests with clear sections. AAA comments are **recommended for complex tests** (>10 lines, multiple setup steps, async operations), **optional for simple tests**:

**Complex test (AAA comments recommended):**
```rust
#[test]
fn test_account_withdraw_valid_amount_decreases_balance() {
    // Arrange - Set up test context
    let mut account = Account::new(100);

    // Act - Execute behavior
    let result = account.withdraw(30);

    // Assert - Verify outcome
    assert!(result.is_ok());
    assert_eq!(account.balance(), 70);
}
```

**Simple test (AAA comments optional):**
```rust
#[test]
fn test_new_account_starts_with_zero_balance() {
    let account = Account::new(0);
    assert_eq!(account.balance(), 0);
}
```

### Isolation: Mock External Dependencies

- ✅ Mock: APIs, databases, file systems, time/date, external services
- ❌ Don't mock: Value types, pure functions, the code under test

### Single Responsibility

Each test verifies ONE behavior with ONE reason to fail.

### Speed Target

Milliseconds per test. Unit tests should run instantly.

## Detailed Guidance

For detailed information on specific topics, see:

- **Test Naming Patterns**: `reference/naming-conventions.md`
- **AAA Structure Details**: `reference/aaa-pattern.md`
- **Async Testing**: `reference/async-testing.md`
- **Test Builders**: `reference/test-builders.md`
- **Anti-Patterns to Avoid**: `reference/anti-patterns.md`

## Test Quality Analysis

### Installation

The analysis script requires Python 3.8+ and optionally the `tomli` library for TOML configuration support:

```bash
# Install dependencies (optional but recommended)
pip install -r scripts/requirements.txt

# Or install manually
pip install tomli  # Only needed for Python < 3.11
```

**Note**: Python 3.11+ includes `tomllib` in the standard library, so no dependencies are needed. For earlier versions, install `tomli` to use TOML configuration files.

### Usage

To analyze test file quality:
```bash
# Basic analysis
python scripts/analyze-test-quality.py memory-core/src/lib.rs

# Lenient mode (recommended for existing codebases)
python scripts/analyze-test-quality.py memory-core/src/lib.rs --lenient

# With specific options
python scripts/analyze-test-quality.py memory-core/src/lib.rs \
    --allow-two-part-names \
    --max-assertions 7

# Using config file (requires tomli for Python < 3.11)
python scripts/analyze-test-quality.py memory-core/src/lib.rs \
    --config=.test-quality.toml
```

### Configuration Options

Create `.test-quality.toml` in your project root:
```toml
# Test quality analysis configuration
[naming]
require_three_parts = false  # Allow two-part names for simple tests
min_parts = 2

[structure]
require_aaa_comments = "complex"  # "always", "complex", or "never"
complex_test_threshold = 10  # Lines count for "complex"

[focus]
max_assertions = 7  # Warning threshold
max_assertions_error = 10  # Error threshold

[severity]
naming_violation = "medium"  # "high", "medium", or "low"
missing_aaa_simple = "low"
missing_aaa_complex = "medium"
```

## Templates

Use pre-built templates for consistent test structure:
- Basic unit test: `templates/unit-test.md`
- Async test: `templates/async-test.md`
- Test builder pattern: `templates/test-builder.md`

## Quality Checklists

Before committing tests, verify against:
- Pre-commit checklist: `checklists/pre-commit.md`
- Code review checklist: `checklists/review.md`

## Key Success Metrics

You're succeeding when:
- ✅ You deploy without manual testing
- ✅ Test failures pinpoint exact problems
- ✅ Refactoring doesn't break unrelated tests
- ✅ Tests run in milliseconds
- ✅ Every failure is actionable

You need improvement when:
- ❌ Tests are skipped because they're slow
- ❌ Test failures require investigation
- ❌ High coverage but low deployment confidence
- ❌ Flaky tests train team to ignore failures

## Rust-Specific Best Practices

### 1. Use `#[tokio::test]` for Async Tests
```rust
#[tokio::test]
async fn test_async_operation() {
    let result = async_function().await;
    assert!(result.is_ok());
}
```

### 2. Use Result<()> for Tests with Error Handling
```rust
#[test]
fn test_operation() -> anyhow::Result<()> {
    let result = fallible_operation()?;
    assert_eq!(result, expected);
    Ok(())
}
```

### 3. Use Test Builders for Complex Setup
```rust
let episode = TestEpisodeBuilder::new()
    .with_task("Test task")
    .with_context(context)
    .completed(true)
    .build();
```

### 4. Clean Up with RAII (Drop)
```rust
struct TestDb(TempDir);

impl Drop for TestDb {
    fn drop(&mut self) {
        // Cleanup happens automatically
    }
}
```

### 5. Use `tempfile` for File System Tests
```rust
#[test]
fn test_file_operation() {
    let dir = TempDir::new().unwrap();
    let path = dir.path().join("test.db");
    // Test with path
    // Cleanup happens automatically when dir is dropped
}
```

## Project-Specific Patterns

### Testing Async Code with Tokio
```rust
#[tokio::test]
async fn test_start_episode_valid_task_creates_episode() {
    // Arrange
    let memory = create_test_memory().await;
    let context = TaskContext::default();

    // Act
    let episode_id = memory.start_episode("Test task", context).await?;

    // Assert
    assert!(!episode_id.is_empty());
    let episode = memory.get_episode(&episode_id).await?;
    assert_eq!(episode.task_description, "Test task");
}
```

### Testing Error Cases
```rust
#[tokio::test]
async fn test_get_episode_invalid_id_returns_error() {
    // Arrange
    let memory = create_test_memory().await;

    // Act
    let result = memory.get_episode("invalid_id").await;

    // Assert
    assert!(result.is_err());
    assert!(matches!(result.unwrap_err(), Error::EpisodeNotFound(_)));
}
```

### Using Test Utilities
```rust
use test_utils::*;

#[test]
fn test_episode_completion() {
    // Arrange
    let episode = create_completed_episode("Test task", true);

    // Act & Assert
    assert!(episode.is_complete());
    assert_eq!(episode.verdict, Some(Verdict::Success));
}
```

## Workflow for Creating Tests

1. **Understand the code**: What behavior needs verification?
2. **Identify risks**: What could break in production?
3. **Write failing test first** (red-green-refactor)
4. **Apply AAA pattern** with clear naming
5. **Isolate dependencies** with proper mocking
6. **Verify test speed** (should be milliseconds)
7. **Check quality** against checklists
8. **Ensure value**: Does this catch real bugs?

## Workflow for Reviewing Tests

1. Run analysis script: `scripts/analyze-test-quality.py`
2. Check against review checklist: `checklists/review.md`
3. Verify naming follows conventions
4. Ensure proper isolation
5. Confirm single responsibility
6. Check for anti-patterns
7. Validate test value

## Remember

**The goal is deployment confidence, not coverage theater.**

Focus testing effort where failures hurt most:
- **High Priority**: Business logic, data integrity, async correctness
- **Medium Priority**: Integration points, error handling
- **Low Priority**: Simple getters/setters, trivial code

## Integration with Other Skills

- Use **test-runner** to execute tests: `cargo test`
- Use **test-fix** when tests fail and need diagnosis
- Use **code-quality** to ensure test code meets standards
- Use **rust-code-quality** for comprehensive review
