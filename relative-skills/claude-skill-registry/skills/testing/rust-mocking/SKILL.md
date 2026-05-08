---
name: rust-mocking
description: Create mocks using mockall and trait-based abstractions. Use when unit testing code with external dependencies.
---

# Mocking

Trait-based mocking with mockall for isolated unit tests.

## Setup mockall

```toml
# Cargo.toml
[dev-dependencies]
mockall = "0.12"
```

## Basic Mock with automock

```rust
use mockall::{automock, predicate::*};

#[automock]
trait Repository {
    fn get(&self, id: i32) -> Option<User>;
    fn save(&self, user: &User) -> Result<(), Error>;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_with_mock() {
        let mut mock = MockRepository::new();

        // Setup expectations
        mock.expect_get()
            .with(eq(123))
            .times(1)
            .returning(|_| Some(User::default()));

        // Use mock
        let result = service_function(&mock, 123);
        assert!(result.is_ok());
    }
}
```

## Async Mock

```rust
use mockall::{automock, predicate::*};

#[automock]
#[async_trait::async_trait]
trait AsyncRepository {
    async fn get(&self, id: i32) -> Result<User, Error>;
    async fn save(&self, user: &User) -> Result<(), Error>;
}

#[tokio::test]
async fn test_async_mock() {
    let mut mock = MockAsyncRepository::new();

    mock.expect_get()
        .with(eq(42))
        .returning(|_| Ok(User::default()));

    let result = mock.get(42).await;
    assert!(result.is_ok());
}
```

## Predicates

```rust
use mockall::predicate::*;

mock.expect_process()
    .with(eq(42))                    // Exact match
    .returning(|_| Ok(()));

mock.expect_process()
    .with(ne(0))                     // Not equal
    .returning(|_| Ok(()));

mock.expect_process()
    .with(gt(10))                    // Greater than
    .returning(|_| Ok(()));

mock.expect_search()
    .with(str::starts_with("test"))  // String predicate
    .returning(|_| vec![]);

mock.expect_validate()
    .with(function(|x: &User| x.is_valid()))  // Custom predicate
    .returning(|_| true);

mock.expect_any()
    .withf(|a, b| a > b)             // Multi-argument predicate
    .returning(|_, _| true);
```

## Return Values

```rust
// Return constant
mock.expect_get()
    .returning(|_| Some(User::default()));

// Return based on input
mock.expect_get()
    .returning(|id| Some(User { id, ..Default::default() }));

// Return once, then different value
mock.expect_get()
    .times(1)
    .returning(|_| Some(User::new("first")));
mock.expect_get()
    .returning(|_| Some(User::new("subsequent")));

// Return error
mock.expect_save()
    .returning(|_| Err(Error::NotFound));
```

## Call Counting

```rust
// Exact count
mock.expect_get()
    .times(3)
    .returning(|_| None);

// Range
mock.expect_get()
    .times(1..=5)
    .returning(|_| None);

// At least
mock.expect_get()
    .times(1..)
    .returning(|_| None);

// Any number (including zero)
mock.expect_get()
    .times(..)
    .returning(|_| None);

// Never called
mock.expect_get()
    .never();
```

## Sequences

```rust
use mockall::Sequence;

let mut seq = Sequence::new();

mock.expect_connect()
    .times(1)
    .in_sequence(&mut seq)
    .returning(|| Ok(()));

mock.expect_send()
    .times(1)
    .in_sequence(&mut seq)
    .returning(|_| Ok(()));

mock.expect_disconnect()
    .times(1)
    .in_sequence(&mut seq)
    .returning(|| Ok(()));
```

## Trait-Based Design for Testability

```rust
// Define trait for external dependency
pub trait Storage {
    fn read(&self, key: &str) -> Result<Vec<u8>, Error>;
    fn write(&self, key: &str, data: &[u8]) -> Result<(), Error>;
}

// Production implementation
pub struct S3Storage {
    bucket: String,
}

impl Storage for S3Storage {
    fn read(&self, key: &str) -> Result<Vec<u8>, Error> {
        // Real S3 operations
    }

    fn write(&self, key: &str, data: &[u8]) -> Result<(), Error> {
        // Real S3 operations
    }
}

// Business logic uses trait
pub struct Processor<S: Storage> {
    storage: S,
}

impl<S: Storage> Processor<S> {
    pub fn process(&self, key: &str) -> Result<(), Error> {
        let data = self.storage.read(key)?;
        // Process data...
        self.storage.write(&format!("{}_processed", key), &result)
    }
}

// Test with mock
#[cfg(test)]
mod tests {
    use super::*;
    use mockall::automock;

    #[automock]
    impl Storage for MockStorage { ... }

    #[test]
    fn test_processor() {
        let mut mock = MockStorage::new();

        mock.expect_read()
            .with(eq("input.txt"))
            .returning(|_| Ok(vec![1, 2, 3]));

        mock.expect_write()
            .with(eq("input.txt_processed"), always())
            .returning(|_, _| Ok(()));

        let processor = Processor { storage: mock };
        assert!(processor.process("input.txt").is_ok());
    }
}
```

## Mocking with Generics

```rust
#[automock]
trait Cache<K, V> {
    fn get(&self, key: &K) -> Option<V>;
    fn set(&self, key: K, value: V);
}

#[test]
fn test_generic_mock() {
    let mut mock = MockCache::<String, i32>::new();

    mock.expect_get()
        .with(eq("key".to_string()))
        .returning(|_| Some(42));

    assert_eq!(mock.get(&"key".to_string()), Some(42));
}
```

## Partial Mocks with mockall_double

```rust
use mockall_double::double;

mod real_module {
    pub fn helper() -> i32 { 42 }
}

#[double]
use real_module;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_with_mocked_helper() {
        let ctx = real_module::helper_context();
        ctx.expect().returning(|| 100);

        assert_eq!(real_module::helper(), 100);
    }
}
```

## Guidelines

- Design with traits for testability
- Use `#[automock]` for automatic mock generation
- Prefer trait bounds over concrete types in business logic
- Use predicates to match arguments
- Verify call counts with `times()`
- Use sequences for order-dependent tests
- Keep mocks focused on the interface being tested

## Examples

See `hercules-local-algo/src/db/repo.rs` for trait-based repository pattern.
