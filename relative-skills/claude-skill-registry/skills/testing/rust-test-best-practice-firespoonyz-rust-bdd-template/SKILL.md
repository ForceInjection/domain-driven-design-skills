---
name: rust-test-best-practice
description: |
  Comprehensive guide to Rust automated testing covering unit, integration, 
  and documentation tests. Includes practical patterns for async testing, 
  property-based testing with proptest, mocking strategies using traits, 
  and essential testing tools (cargo-nextest, criterion, tarpaulin). 
  Emphasizes FIRST principles and CI/CD integration.
  
  Use this when: setting up new Rust projects, establishing testing standards 
  for teams, improving existing test suites, implementing TDD workflows, or 
  learning Rust testing ecosystem best practices. Particularly valuable for 
  projects requiring high reliability and comprehensive test coverage.
---
# Rust Automated Testing Best Practices Guide

## 1. Test Organization Structure

**Unit Tests**: Use `#[cfg(test)]` modules within the same file
```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_basic_functionality() {
        assert_eq!(2 + 2, 4);
    }
}
```

**Integration Tests**: Place in `tests/` directory to test public APIs

**Documentation Tests**: Embed examples in doc comments that double as tests
```rust
/// Adds two numbers together.
///
/// ```
/// assert_eq!(add(2, 3), 5);
/// ```
pub fn add(a: i32, b: i32) -> i32 { a + b }
```

## 2. Core Testing Principles

**Use Descriptive Test Names**: Clearly express test intent
```rust
#[test]
fn connection_timeout_returns_error_after_30_seconds() { }
```

**Follow AAA Pattern**: Arrange (setup), Act (execute), Assert (verify)

**Test Boundary Conditions**: Empty inputs, maximum values, error cases, edge scenarios

**One Assertion Per Test**: Focus each test on a single behavior (when practical)

## 3. Advanced Testing Techniques

**Test Panics with `#[should_panic]`**:
```rust
#[test]
#[should_panic(expected = "invalid input")]
fn test_panics_on_invalid_input() {
    process_data(""); // Should panic
}
```

**Async Testing**: Use `tokio::test` or `async-std::test`
```rust
#[tokio::test]
async fn test_async_operation() {
    let result = fetch_data().await;
    assert!(result.is_ok());
}
```

**Property-Based Testing**: Use `proptest` to test invariants across random inputs
```rust
proptest! {
    #[test]
    fn reversing_twice_returns_original(s: String) {
        let reversed_twice = s.chars().rev().collect::<String>()
            .chars().rev().collect::<String>();
        assert_eq!(s, reversed_twice);
    }
}
```

## 4. Mocking with mockall

> **Important**: Before using mockall, always read the latest official documentation at https://docs.rs/mockall for up-to-date API and best practices.

### When to Use Mocks

Mock objects serve two main purposes:

1. **Isolation Testing**: When testing a specific module, mock the inputs and outputs of other modules to isolate the module under test.
2. **Simulating Edge Cases**: Mock boundary conditions to test scenarios that are difficult to trigger or reproduce in real-world situations.

**Key Principle**: Mock the *trait boundaries* (interfaces/dependencies), not concrete implementations.

### Basic Usage

Add to `Cargo.toml`:
```toml
[dev-dependencies]
mockall = "0.14"
```

**Using `#[automock]`** (from official repository):
```rust
#[cfg(test)]
use mockall::{automock, mock, predicate::*};

#[cfg_attr(test, automock)]
trait MyTrait {
    fn foo(&self, x: u32) -> u32;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn mytest() {
        let mut mock = MockMyTrait::new();
        mock.expect_foo()
            .with(eq(4))        // Argument matcher
            .times(1)           // Expected call count
            .returning(|x| x + 1);  // Return value
        
        assert_eq!(5, mock.foo(4));
    }
}
```

### Return Values
```rust
#[automock]
trait MyTrait {
    fn foo(&self) -> u32;
    fn bar(&self, x: u32, y: u32) -> u32;
}

let mut mock = MockMyTrait::new();
mock.expect_foo()
    .return_const(42u32);       // Constant value
mock.expect_bar()
    .returning(|x, y| x + y);   // Computed value
```

### Matching Multiple Calls
```rust
#[automock]
trait Foo {
    fn foo(&self, x: u32) -> u32;
}

let mut mock = MockFoo::new();
mock.expect_foo()
    .with(eq(5))
    .return_const(50u32);
mock.expect_foo()
    .with(eq(6))
    .return_const(60u32);
```

### Sequences (Enforce Call Order)
```rust
#[automock]
trait Foo {
    fn foo(&self);
}

let mut seq = Sequence::new();

let mut mock1 = MockFoo::new();
mock1.expect_foo()
    .times(1)
    .in_sequence(&mut seq)
    .returning(|| ());

let mut mock2 = MockFoo::new();
mock2.expect_foo()
    .times(1)
    .in_sequence(&mut seq)
    .returning(|| ());
```

## 5. Essential Testing Tools

- **Cargo test**: Built-in test runner with filtering via `--test`
- **Cargo-nextest**: Faster parallel test execution with better output
- **Cargo-watch**: Auto-run tests on file changes (`cargo watch -x test`)
- **Tarpaulin/llvm-cov**: Code coverage analysis
- **Criterion**: Statistical benchmarking framework

## 6. Test Execution Strategies

**Run specific tests**:
```bash
cargo test test_name
cargo test module_name::
cargo test --test integration_test_name
```

**Run with output**:
```bash
cargo test -- --nocapture  # Show println! output
cargo test -- --show-output  # Show output for passing tests
```

**Parallel vs Sequential**:
```bash
cargo test -- --test-threads=1  # Run serially
```

## 7. CI/CD Integration

Set up GitHub Actions to:
- Run tests on multiple Rust versions (stable, beta, nightly)
- Test all feature combinations: `cargo test --all-features`
- Check code coverage and fail if below threshold
- Run `cargo clippy` and `cargo fmt --check`

Example workflow snippet:
```yaml
- name: Run tests
  run: |
    cargo test --all-features --workspace
    cargo test --doc
```

## 8. Performance and Benchmark Testing

Use `criterion` for reliable benchmarks:
```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn benchmark_function(c: &mut Criterion) {
    c.bench_function("my_function", |b| {
        b.iter(|| my_function(black_box(100)))
    });
}

criterion_group!(benches, benchmark_function);
criterion_main!(benches);
```

## 9. Test Quality Guidelines

**Keep Tests FIRST**:
- **F**ast: Tests should run quickly
- **I**solated: No dependencies between tests
- **R**epeatable: Same results every time
- **S**elf-validating: Pass or fail, no manual checking
- **T**imely: Written alongside or before production code

**Maintain Test Code Quality**: Apply same standards as production code—tests should be clean, readable, and maintainable.

**Avoid Test Flakiness**: Don't use `sleep()`, random values without seeds, or depend on external state.

## 10. Common Patterns

**Test Fixtures**: Use `setup()` helper functions or the `rstest` crate for parameterized tests

**Custom Assertions**: Create helper functions for complex assertions

**Error Testing**: Test both error types and error messages
```rust
#[test]
fn returns_correct_error() {
    let result = fallible_operation();
    assert!(matches!(result, Err(Error::InvalidInput)));
}
```

---

**Key Takeaway**: Comprehensive testing is a cornerstone of reliable Rust software. Invest in your test suite—it pays dividends in confidence, maintainability, and rapid development.