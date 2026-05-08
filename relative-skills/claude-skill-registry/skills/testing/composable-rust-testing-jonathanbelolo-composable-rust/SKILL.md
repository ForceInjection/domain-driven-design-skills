---
name: composable-rust-testing
description: Expert knowledge for testing Composable Rust applications. Use when writing unit tests for reducers, setting up integration tests with real dependencies, using test utilities (TestStore, FixedClock, mocks), working with testcontainers for PostgreSQL/Redpanda, property-based testing, or questions about testing patterns and best practices.
---

# Composable Rust Testing Expert

Expert knowledge for testing Composable Rust applications - unit testing reducers, integration testing with real dependencies, test utilities (TestStore, FixedClock, mocks), property-based testing, and testcontainers.

## When to Use This Skill

Automatically apply when:
- Writing unit tests for reducers
- Setting up integration tests
- Using test utilities (TestStore, FixedClock, mocks)
- Working with testcontainers for PostgreSQL/Redpanda
- Questions about testing patterns or best practices
- Debugging test failures

## Testing Philosophy

### Core Principle

**Business logic tests run at memory speed (no I/O).**

```
Unit Tests (Reducers):
  - Pure functions
  - No I/O, only state updates
  - Test in microseconds
  - Use mocks for environment

Integration Tests:
  - Real dependencies (PostgreSQL, Redpanda)
  - Test full flow
  - Test in milliseconds to seconds
  - Use testcontainers for isolation
```

### Benefits

- **Fast feedback**: Unit tests run in <1ms
- **Deterministic**: No flaky tests from network/timing
- **Isolated**: Each test is independent
- **Comprehensive**: Easy to test edge cases
- **Refactorable**: Tests don't depend on implementation details

## Test Organization

### Crate Structure

```
my-crate/
├── src/
│   ├── lib.rs
│   ├── reducer.rs
│   └── types.rs
├── tests/
│   ├── integration_tests.rs  # Integration tests
│   └── common/
│       └── mod.rs  # Shared test utilities
└── Cargo.toml
```

### Unit Tests (In Source Files)

```rust
// In src/reducer.rs
impl Reducer for OrderReducer {
    // Implementation
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_place_order() {
        // Unit test
    }

    #[test]
    fn test_cancel_order() {
        // Unit test
    }
}
```

**Pattern**: Unit tests live in same file as implementation. Use `#[cfg(test)]`.

### Integration Tests (In tests/ Directory)

```rust
// In tests/integration_tests.rs
use my_crate::*;
use testcontainers::*;

#[tokio::test]
async fn test_order_flow_with_postgres() {
    // Integration test with real database
}
```

**Pattern**: Integration tests in `tests/` directory. Can test across modules. Use real dependencies.

## Unit Testing Reducers

### Basic Reducer Test Pattern

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use composable_rust_testing::{FixedClock, test_clock};

    fn test_environment() -> OrderEnvironment<MockDatabase, FixedClock, MockHttpClient> {
        OrderEnvironment {
            database: MockDatabase::new(),
            clock: test_clock(),
            http_client: MockHttpClient::new(),
        }
    }

    #[test]
    fn test_place_order() {
        // Arrange
        let env = test_environment();
        let mut state = OrderState::default();
        let action = OrderAction::PlaceOrder {
            customer_id: "cust-123".to_string(),
            items: vec![
                Item {
                    id: "item-1".to_string(),
                    quantity: 2,
                    price: Decimal::from(10),
                }
            ],
        };

        // Act
        let effects = OrderReducer.reduce(&mut state, action, &env);

        // Assert
        assert_eq!(state.status, OrderStatus::Placed);
        assert_eq!(state.customer_id, Some("cust-123".to_string()));
        assert_eq!(state.items.len(), 1);
        assert_eq!(effects.len(), 2);
        assert!(matches!(effects[0], Effect::Database(_)));
        assert!(matches!(effects[1], Effect::PublishEvent(_)));
    }
}
```

**Pattern**:
1. Create test environment with mocks
2. Create initial state
3. Create action
4. Call reducer
5. Assert state changes
6. Assert effects returned

### Testing State Transitions

```rust
#[test]
fn test_order_state_machine() {
    let env = test_environment();
    let mut state = OrderState::default();

    // Transition: NotStarted → Placed
    let effects = OrderReducer.reduce(
        &mut state,
        OrderAction::PlaceOrder { ... },
        &env,
    );
    assert_eq!(state.status, OrderStatus::Placed);

    // Transition: Placed → Confirmed
    let effects = OrderReducer.reduce(
        &mut state,
        OrderAction::ConfirmOrder { ... },
        &env,
    );
    assert_eq!(state.status, OrderStatus::Confirmed);

    // Invalid transition: Confirmed → Placed (should be no-op)
    let effects = OrderReducer.reduce(
        &mut state,
        OrderAction::PlaceOrder { ... },
        &env,
    );
    assert_eq!(state.status, OrderStatus::Confirmed);  // ✅ Still confirmed
    assert!(matches!(effects[0], Effect::None));
}
```

**Pattern**: Test state machine transitions, including invalid transitions.

### Testing Edge Cases

```rust
#[test]
fn test_place_order_with_empty_items() {
    let env = test_environment();
    let mut state = OrderState::default();
    let action = OrderAction::PlaceOrder {
        customer_id: "cust-123".to_string(),
        items: vec![],  // ❌ Empty items
    };

    let effects = OrderReducer.reduce(&mut state, action, &env);

    // Should not change state
    assert_eq!(state.status, OrderStatus::NotStarted);
    assert!(matches!(effects[0], Effect::None));
}

#[test]
fn test_cancel_nonexistent_order() {
    let env = test_environment();
    let mut state = OrderState::default();  // No order ID
    let action = OrderAction::CancelOrder {
        order_id: "order-123".to_string(),
        reason: "Test".to_string(),
    };

    let effects = OrderReducer.reduce(&mut state, action, &env);

    // Should be no-op
    assert!(matches!(effects[0], Effect::None));
}
```

**Pattern**: Test validation failures, missing data, invalid inputs.

### Developer Experience: ReducerTest Builder

The `ReducerTest` builder provides a fluent Given-When-Then API for testing reducers:

```rust
use composable_rust_testing::ReducerTest;

#[test]
fn test_place_order_with_builder() {
    ReducerTest::new(OrderReducer, test_environment())
        .given_state(OrderState::default())
        .when_action(OrderAction::PlaceOrder {
            customer_id: "cust-1".into(),
            items: vec![test_item()],
        })
        .then_state(|state| {
            assert_eq!(state.status, OrderStatus::Placed);
            assert_eq!(state.items.len(), 1);
        })
        .assert_has_event_store_effect()
        .run();
}
```

**Testing Multiple Actions:**

```rust
#[test]
fn test_order_lifecycle() {
    ReducerTest::new(OrderReducer, test_environment())
        .given_state(OrderState::default())
        .when_actions(vec![
            OrderAction::PlaceOrder { /* ... */ },
            OrderAction::ConfirmPayment { /* ... */ },
            OrderAction::ShipOrder { /* ... */ },
        ])
        .then_state(|state| {
            assert_eq!(state.status, OrderStatus::Shipped);
        })
        .assert_effect_count(3)  // Three effects (one per action)
        .run();
}
```

**Helper Assertions:**

```rust
.assert_has_event_store_effect()  // At least one EventStore effect
.assert_has_publish_event_effect()  // At least one PublishEvent effect
.assert_effect_count(n)  // Exactly n effects
.assert_no_effects()  // No effects returned
```

**Benefits**:
- **Readable**: Given-When-Then makes intent clear
- **Concise**: Less boilerplate than manual testing
- **Type-safe**: Compile-time checking
- **Composable**: Chain multiple actions and assertions

## Test Utilities

### FixedClock Pattern

```rust
use composable_rust_testing::{FixedClock, test_clock};

// Create fixed clock at specific time
let clock = FixedClock::new(
    DateTime::parse_from_rfc3339("2025-01-15T10:30:00Z")
        .unwrap()
        .with_timezone(&Utc)
);

// Or use test_clock() for default test time
let clock = test_clock();

// Get current time (always returns same value)
let now = clock.now();

// Advance time for testing delays
clock.advance(Duration::from_secs(60));
let later = clock.now();  // 60 seconds later
```

**Use for**: Deterministic timestamps in tests. Testing time-based logic.

### TestStore Pattern

```rust
use composable_rust_testing::TestStore;

#[tokio::test]
async fn test_with_test_store() {
    let env = test_environment();
    let store = TestStore::new(OrderState::default(), OrderReducer, env);

    // Send action
    store.send(OrderAction::PlaceOrder { ... }).await;

    // Wait for state change
    store.wait_for_state(|state| state.status == OrderStatus::Placed).await;

    // Get final state
    let state = store.state().await;
    assert_eq!(state.status, OrderStatus::Placed);

    // Get all actions that were processed
    let actions = store.actions().await;
    assert_eq!(actions.len(), 2);  // Initial + response
}
```

**TestStore features**:
- `wait_for_state`: Block until predicate is true
- `actions()`: Get all actions processed
- Useful for testing async flows without timing issues

### Mock Database Pattern

```rust
use std::collections::HashMap;
use std::sync::{Arc, RwLock};

#[derive(Clone)]
pub struct MockDatabase {
    data: Arc<RwLock<HashMap<String, Vec<u8>>>>,
}

impl MockDatabase {
    pub fn new() -> Self {
        Self {
            data: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    pub fn get_saved_data(&self, key: &str) -> Option<Vec<u8>> {
        self.data.read().unwrap().get(key).cloned()
    }
}

impl Database for MockDatabase {
    async fn save(&self, key: &str, data: &[u8]) -> Result<(), Error> {
        self.data.write().unwrap().insert(key.to_string(), data.to_vec());
        Ok(())
    }

    async fn load(&self, key: &str) -> Result<Vec<u8>, Error> {
        self.data
            .read()
            .unwrap()
            .get(key)
            .cloned()
            .ok_or(Error::NotFound)
    }
}

// Usage in tests
#[tokio::test]
async fn test_saves_to_database() {
    let mock_db = MockDatabase::new();
    let env = OrderEnvironment {
        database: mock_db.clone(),
        // ...
    };

    let store = Store::new(OrderState::default(), OrderReducer, env);
    store.send(OrderAction::PlaceOrder { ... }).await;

    // Verify database was called
    let saved_data = mock_db.get_saved_data("order-123");
    assert!(saved_data.is_some());
}
```

**Pattern**: In-memory HashMap. `Arc<RwLock<>>` for thread safety. Expose inspection methods (`get_saved_data`).

### InMemoryEventStore Pattern

```rust
use composable_rust_testing::InMemoryEventStore;

#[tokio::test]
async fn test_event_sourcing() {
    let event_store = InMemoryEventStore::new();

    // Append events
    event_store.append("order-123", &[event1, event2], 0).await?;

    // Load events
    let events = event_store.load("order-123", 0).await?;
    assert_eq!(events.len(), 2);

    // Test version conflict
    let result = event_store.append("order-123", &[event3], 0).await;
    assert!(matches!(result, Err(Error::VersionConflict { .. })));
}
```

**Use for**: Testing event sourcing without PostgreSQL. Fast, deterministic.

### InMemoryEventBus Pattern

```rust
use composable_rust_testing::InMemoryEventBus;

#[tokio::test]
async fn test_saga_with_in_memory_event_bus() {
    let event_bus = InMemoryEventBus::new();

    // Subscribe to events
    event_bus.subscribe("orders", "payment-service", |event| {
        Box::pin(async move {
            // Handle event
            Ok(())
        })
    }).await?;

    // Publish event
    event_bus.publish("orders", OrderEvent::OrderCreated { ... }).await?;

    // Assertions on handled events
}
```

**Use for**: Testing sagas without Redpanda. Synchronous, deterministic.

## Integration Testing

### Testcontainers Pattern (PostgreSQL)

```rust
use testcontainers::*;
use testcontainers_modules::postgres::Postgres;

#[tokio::test]
async fn test_with_real_postgres() {
    // Start PostgreSQL container
    let docker = clients::Cli::default();
    let postgres = docker.run(Postgres::default());

    // Get connection details
    let host = "127.0.0.1";
    let port = postgres.get_host_port_ipv4(5432);
    let connection_string = format!(
        "postgres://postgres:postgres@{}:{}/postgres",
        host, port
    );

    // Create connection pool
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&connection_string)
        .await
        .unwrap();

    // Run migrations
    sqlx::migrate!("./migrations").run(&pool).await.unwrap();

    // Create event store with real database
    let event_store = PostgresEventStore::new(pool.clone());

    // Test with real database
    let events = vec![/* test events */];
    event_store.append("order-123", &events, 0).await.unwrap();

    let loaded = event_store.load("order-123", 0).await.unwrap();
    assert_eq!(loaded.len(), events.len());

    // Container automatically stops and removes when dropped
}
```

**Pattern**:
1. Start container with testcontainers
2. Get connection details
3. Run migrations
4. Test with real database
5. Container auto-cleanup

### Testcontainers Pattern (Redpanda)

```rust
use testcontainers_modules::redpanda::Redpanda;

#[tokio::test]
async fn test_with_real_redpanda() {
    let docker = clients::Cli::default();
    let redpanda = docker.run(Redpanda::default());

    let bootstrap_servers = format!(
        "127.0.0.1:{}",
        redpanda.get_host_port_ipv4(9092)
    );

    let event_bus = RedpandaEventBus::builder()
        .broker(&bootstrap_servers)
        .build()
        .unwrap();

    // Test with real Redpanda
    event_bus.publish("orders", OrderEvent::OrderCreated { ... }).await.unwrap();
}
```

### Waiting for Specific Events (CRITICAL PATTERN)

**⚠️ DO NOT FORGET THIS PATTERN** - Use `send_and_wait_for` / `send_and_wait_for_with_metadata` to wait for saga completion or specific events in tests.

#### Pattern: Wait for Single Event Type

```rust
use std::time::Duration;

// Send command and wait for completion event
let result = store.send_and_wait_for(
    SagaAction::StartWorkflow { ... },
    |action| matches!(action, SagaAction::WorkflowCompleted { .. }),
    Duration::from_secs(10)
).await?;

// Result is the WorkflowCompleted action
match result {
    SagaAction::WorkflowCompleted { id, .. } => {
        // Assert on completion
    }
    _ => unreachable!()
}
```

#### Pattern: Wait for Success OR Failure

```rust
// Wait for EITHER completion OR failure (handles both paths)
let result = saga_store.send_and_wait_for(
    EventInventorySagaAction::CreateEventWithInventory {
        event_id,
        name: "Test Event".to_string(),
        venue,
        // ...
    },
    |action| matches!(action,
        EventInventorySagaAction::EventCreationCompleted { .. } |
        EventInventorySagaAction::EventCreationFailed { .. }
    ),
    Duration::from_secs(10)
).await?;

// Then match on what we got
match result {
    EventInventorySagaAction::EventCreationCompleted { event_id, sections_initialized, .. } => {
        // Happy path - saga succeeded
        println!("Event created with {} sections", sections_initialized);
    }
    EventInventorySagaAction::EventCreationFailed { event_id, error, .. } => {
        // Error path - saga failed
        panic!("Event creation failed: {}", error);
    }
    _ => unreachable!()
}
```

#### Pattern: With Metadata (Correlation IDs)

```rust
use composable_rust_core::event::EventMetadata;
use ticketing::projections::CorrelationId;

// Generate correlation ID for tracking
let correlation_id = CorrelationId::new();
let metadata = EventMetadata::with_correlation_id(correlation_id.to_string());

// Send with metadata and wait for result
let result = saga_store.send_and_wait_for_with_metadata(
    EventInventorySagaAction::CreateEventWithInventory { ... },
    Some(metadata),
    |action| matches!(action,
        EventInventorySagaAction::EventCreationCompleted { .. } |
        EventInventorySagaAction::EventCreationFailed { .. }
    ),
    Duration::from_secs(10)
).await?;

// Metadata propagates through event chain for distributed tracing
```

#### Why This Pattern?

**✅ Correct**:
```rust
// WAIT for saga completion before assertions
let result = saga_store.send_and_wait_for(...).await?;
assert_eq!(result.event_id, expected_id);
```

**❌ WRONG**:
```rust
// DON'T use wait() - only waits for effects, not saga completion!
let mut handle = saga_store.send(...).await?;
handle.wait().await; // ⚠️ Saga may not be complete!
assert!(...); // ⚠️ Projection may not have caught up!
```

**❌ WRONG**:
```rust
// DON'T use sleep - flaky and slow!
store.send(...).await?;
tokio::time::sleep(Duration::from_millis(500)).await; // ❌ Race condition!
assert!(...);
```

**Key Benefits**:
- **Deterministic**: Wait for EXACT event, not arbitrary time
- **Fast**: Returns immediately when event arrives
- **Clear**: Predicate explicitly states what we're waiting for
- **Debuggable**: Timeout error shows what event we expected

**When to Use**:
- Testing sagas (wait for completion/failure)
- Testing projections (wait for projection to catch up)
- E2E tests (wait for full workflow completion)
- Integration tests with async workflows

### Integration Test Organization

```rust
// tests/common/mod.rs - Shared utilities
pub fn test_postgres_pool() -> PgPool {
    // Setup test database
}

pub fn test_environment<D: Database>(database: D) -> OrderEnvironment<D, SystemClock, ...> {
    OrderEnvironment {
        database,
        clock: SystemClock,
        // ...
    }
}

// tests/integration_tests.rs
mod common;

#[tokio::test]
async fn test_order_flow() {
    let pool = common::test_postgres_pool();
    let event_store = PostgresEventStore::new(pool);
    let env = common::test_environment(event_store);

    // Integration test
}
```

**Pattern**: Shared utilities in `tests/common/`. Import in test files.

## Property-Based Testing

### Proptest Pattern

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_order_amount_always_positive(
        items in prop::collection::vec(any::<Item>(), 1..10)
    ) {
        let env = test_environment();
        let mut state = OrderState::default();

        let action = OrderAction::PlaceOrder {
            customer_id: "cust-123".to_string(),
            items,
        };

        let _ = OrderReducer.reduce(&mut state, action, &env);

        // Property: total amount always >= 0
        prop_assert!(state.total_amount >= Decimal::ZERO);
    }
}

// Custom strategies
fn arb_order_action() -> impl Strategy<Value = OrderAction> {
    prop_oneof![
        any::<String>().prop_map(|id| OrderAction::PlaceOrder {
            customer_id: id,
            items: vec![],
        }),
        any::<String>().prop_map(|id| OrderAction::CancelOrder {
            order_id: id,
            reason: "test".to_string(),
        }),
    ]
}

proptest! {
    #[test]
    fn test_reducer_never_panics(action in arb_order_action()) {
        let env = test_environment();
        let mut state = OrderState::default();

        // Should never panic
        let _ = OrderReducer.reduce(&mut state, action, &env);
    }
}
```

**Use for**:
- Testing invariants (e.g., amounts always positive)
- Finding edge cases
- Verifying reducer never panics

## Testing Async Code

### Basic Async Test

```rust
#[tokio::test]
async fn test_async_operation() {
    let store = Store::new(OrderState::default(), OrderReducer, env);

    store.send(OrderAction::PlaceOrder { ... }).await;

    let state = store.state().await;
    assert_eq!(state.status, OrderStatus::Placed);
}
```

### Testing Timeouts

```rust
#[tokio::test]
async fn test_timeout() {
    let store = Store::new(OrderState::default(), OrderReducer, env);

    let result = tokio::time::timeout(
        Duration::from_millis(100),
        store.send_and_wait_for(
            OrderAction::SlowOperation { ... },
            |action| matches!(action, OrderAction::OperationComplete { .. }),
            Duration::from_secs(10),
        ),
    )
    .await;

    assert!(result.is_err());  // Timed out
}
```

### Testing Concurrent Operations

```rust
#[tokio::test]
async fn test_concurrent_orders() {
    let store = Arc::new(Store::new(OrderState::default(), OrderReducer, env));

    let handles: Vec<_> = (0..10)
        .map(|i| {
            let store = store.clone();
            tokio::spawn(async move {
                store
                    .send(OrderAction::PlaceOrder {
                        customer_id: format!("cust-{}", i),
                        items: vec![],
                    })
                    .await
            })
        })
        .collect();

    // Wait for all
    for handle in handles {
        handle.await.unwrap();
    }

    // Verify state
    let state = store.state().await;
    // Assertions...
}
```

## Benchmarking

### Basic Benchmark

```rust
// benches/order_benchmark.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn bench_place_order(c: &mut Criterion) {
    let env = test_environment();
    let reducer = OrderReducer;

    c.bench_function("place_order", |b| {
        b.iter(|| {
            let mut state = OrderState::default();
            let action = OrderAction::PlaceOrder {
                customer_id: black_box("cust-123".to_string()),
                items: black_box(vec![test_item()]),
            };
            reducer.reduce(black_box(&mut state), black_box(action), &env)
        });
    });
}

criterion_group!(benches, bench_place_order);
criterion_main!(benches);
```

**Run with**: `cargo bench`

## Common Testing Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: I/O in Reducer Tests

```rust
#[test]
fn test_place_order() {
    let env = OrderEnvironment {
        database: PostgresDatabase::new(real_pool),  // ❌ Real DB in unit test
        // ...
    };

    // This test will be slow and flaky
}
```

**Solution**: Use mocks for unit tests. Real dependencies for integration tests.

### ❌ Anti-Pattern 2: Testing Implementation Details

```rust
#[test]
fn test_internal_state() {
    let mut state = OrderState::default();
    state.internal_counter += 1;  // ❌ Testing internal field

    assert_eq!(state.internal_counter, 1);
}
```

**Solution**: Test behavior (inputs → outputs), not internal state.

### ❌ Anti-Pattern 3: Fragile Assertions

```rust
#[test]
fn test_place_order() {
    let effects = reducer.reduce(&mut state, action, &env);

    // ❌ Asserting exact string
    assert_eq!(state.order_id.unwrap(), "order-2025-01-15-10-30-00");
}
```

**Solution**: Assert on structure, not specific values (unless deterministic).

### ❌ Anti-Pattern 4: Not Using Fixtures

```rust
#[test]
fn test_a() {
    let state = OrderState {
        order_id: Some("order-123".to_string()),
        customer_id: Some("cust-123".to_string()),
        items: vec![],
        // ... 20 more fields
    };
}

#[test]
fn test_b() {
    let state = OrderState {
        order_id: Some("order-123".to_string()),
        customer_id: Some("cust-123".to_string()),
        items: vec![],
        // ... same 20 fields
    };
}
```

**Solution**: Use fixture functions:

```rust
fn test_order_state() -> OrderState {
    OrderState {
        order_id: Some("order-123".to_string()),
        customer_id: Some("cust-123".to_string()),
        items: vec![],
        // ... rest
    }
}

#[test]
fn test_a() {
    let state = test_order_state();
    // ...
}
```

### ❌ Anti-Pattern 5: No Cleanup in Integration Tests

```rust
#[tokio::test]
async fn test_with_shared_db() {
    let pool = shared_test_pool();  // ❌ Shared pool, no cleanup

    // Test inserts data but doesn't clean up
    event_store.append("order-123", &events, 0).await.unwrap();

    // Next test may see this data!
}
```

**Solution**: Use testcontainers (auto-cleanup) or explicit cleanup:

```rust
#[tokio::test]
async fn test_with_cleanup() {
    let pool = test_pool();

    // Test logic

    // Cleanup
    sqlx::query("DELETE FROM events WHERE stream_id = $1")
        .bind("order-123")
        .execute(&pool)
        .await
        .unwrap();
}
```

## Test Coverage

### Running Coverage

```bash
# Install tarpaulin
cargo install cargo-tarpaulin

# Run coverage
cargo tarpaulin --all-features --workspace --out Html

# Open report
open tarpaulin-report.html
```

### Coverage Goals

- **Reducers**: Aim for >90% coverage (pure logic, easy to test)
- **Integration**: Aim for >70% coverage (harder to test exhaustively)
- **Focus**: Cover all edge cases, not just happy path

## Quick Reference Checklist

When writing tests:

- [ ] **Unit tests for reducers**: Pure, fast, no I/O
- [ ] **Use test utilities**: FixedClock, mocks, TestStore
- [ ] **Integration tests**: Real dependencies, testcontainers
- [ ] **Test edge cases**: Empty inputs, invalid data, state machine violations
- [ ] **Property tests**: For invariants and fuzz testing
- [ ] **Async tests**: Use `#[tokio::test]`
- [ ] **Fixtures**: Extract common test data
- [ ] **Cleanup**: Auto-cleanup with testcontainers or explicit cleanup
- [ ] **Coverage**: >90% for reducers, >70% overall
- [ ] **Benchmarks**: For performance-critical code

## Performance Tips

- **Unit tests**: Run in <1ms each
- **Integration tests**: Parallelize with `cargo test -- --test-threads=4`
- **Testcontainers**: Reuse containers across tests in same file (with caution)
- **Mocks**: Zero overhead, always prefer for unit tests

## See Also

- **Architecture**: `composable-rust-architecture.skill` - Core patterns
- **Event Sourcing**: `composable-rust-event-sourcing.skill` - Event store testing
- **Sagas**: `composable-rust-sagas.skill` - Saga testing patterns
- **Testing utilities**: `composable-rust/testing` crate
- **Examples**: `examples/*/tests/` - Real-world test examples

---

**Remember**: Unit tests are fast and test business logic. Integration tests are slower and test with real dependencies. Use mocks for speed, real dependencies for confidence.
