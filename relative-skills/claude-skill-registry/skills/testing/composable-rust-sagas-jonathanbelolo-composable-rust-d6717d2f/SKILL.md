---
name: composable-rust-sagas
description: Expert knowledge for implementing distributed sagas in Composable Rust. Use when coordinating multiple aggregates in distributed transactions, implementing compensation logic or rollback flows, working with EventBus trait or Redpanda integration, designing saga state machines, or questions about eventual consistency and distributed transaction patterns.
---

# Composable Rust Sagas Expert

Expert knowledge for implementing distributed sagas in Composable Rust - multi-aggregate coordination, compensation logic, state machines, event bus patterns, and orchestration vs choreography.

## When to Use This Skill

Automatically apply when:
- Coordinating multiple aggregates in a distributed transaction
- Implementing compensation logic or rollback flows
- Working with `EventBus` trait or Redpanda integration
- Designing saga state machines
- Questions about eventual consistency or distributed transactions
- Debugging saga failures or compensation flows

## Saga Pattern Fundamentals

### What is a Saga?

A **saga** is a sequence of local transactions across multiple aggregates, where each transaction publishes events. If a step fails, execute **compensating transactions** to undo completed work.

```
Success flow:
Order → Payment → Inventory → Shipping → ✅ Complete

Failure flow (payment fails):
Order → Payment ❌ → Compensate Order → ✅ Rolled back
```

### Why Sagas?

**Problem**: You can't use distributed transactions (2PC) because:
- High latency and contention
- Poor availability (all participants must be up)
- Doesn't scale across services/databases

**Solution**: Saga pattern with eventual consistency:
- Each aggregate commits independently
- If failure occurs, compensate completed steps
- Eventually consistent (all aggregates converge to correct state)

### Saga vs 2PC

| Aspect | 2PC (Distributed Transaction) | Saga |
|--------|-------------------------------|------|
| Consistency | Strong (ACID) | Eventual |
| Availability | Low (blocks on coordinator) | High (no blocking) |
| Latency | High (2 phases, locks) | Low (async events) |
| Failure handling | Rollback (automatic) | Compensate (manual) |
| Scalability | Poor (locks, contention) | Good (no locks) |

## Saga as Reducer (Core Pattern)

**Key insight**: A saga is just a reducer with a state machine.

### Saga State Pattern

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CheckoutSagaState {
    pub checkout_id: String,
    pub current_step: SagaStep,
    pub completed_steps: Vec<SagaStep>,

    // IDs for compensation
    pub order_id: Option<String>,
    pub payment_id: Option<String>,
    pub reservation_id: Option<String>,

    // Data
    pub customer_id: String,
    pub items: Vec<Item>,
    pub amount: Decimal,

    // Tracking
    pub started_at: DateTime<Utc>,
    pub retry_count: u32,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum SagaStep {
    NotStarted,
    CreatingOrder,
    ProcessingPayment,
    ReservingInventory,
    Completed,
    Compensating { failed_at: Box<SagaStep> },
    Failed,
}
```

**Pattern**: Track current step, completed steps, and IDs needed for compensation.

### Saga Action Pattern

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum CheckoutSagaAction {
    // Initiating command
    StartCheckout {
        customer_id: String,
        items: Vec<Item>,
        amount: Decimal,
    },

    // Success events from aggregates
    OrderCreated { order_id: String },
    PaymentProcessed { payment_id: String },
    InventoryReserved { reservation_id: String },

    // Failure events from aggregates
    OrderCreationFailed { reason: String },
    PaymentFailed { reason: String },
    InventoryReservationFailed { reason: String },

    // Compensation events
    OrderCompensated,
    PaymentRefunded,

    // Saga completion
    SagaCompleted,
    SagaFailed { reason: String },
}
```

**Pattern**: Commands to start, events for each step (success/failure), compensation events, terminal states.

### Saga Reducer Implementation

```rust
pub struct CheckoutSagaReducer;

impl Reducer for CheckoutSagaReducer {
    type State = CheckoutSagaState;
    type Action = CheckoutSagaAction;
    type Environment = SagaEnvironment;

    fn reduce(
        &self,
        state: &mut Self::State,
        action: Self::Action,
        env: &Self::Environment,
    ) -> Vec<Effect<Self::Action>> {
        match (&state.current_step, action) {
            // Start saga
            (SagaStep::NotStarted, CheckoutSagaAction::StartCheckout { customer_id, items, amount }) => {
                state.current_step = SagaStep::CreatingOrder;
                state.customer_id = customer_id.clone();
                state.items = items.clone();
                state.amount = amount;

                vec![
                    Effect::PublishEvent(OrderCommand::CreateOrder {
                        customer_id,
                        items,
                    }),
                ]
            }

            // Order created → proceed to payment
            (SagaStep::CreatingOrder, CheckoutSagaAction::OrderCreated { order_id }) => {
                state.order_id = Some(order_id.clone());
                state.completed_steps.push(SagaStep::CreatingOrder);
                state.current_step = SagaStep::ProcessingPayment;

                vec![
                    Effect::PublishEvent(PaymentCommand::ProcessPayment {
                        order_id,
                        amount: state.amount,
                    }),
                ]
            }

            // Payment processed → proceed to inventory
            (SagaStep::ProcessingPayment, CheckoutSagaAction::PaymentProcessed { payment_id }) => {
                state.payment_id = Some(payment_id.clone());
                state.completed_steps.push(SagaStep::ProcessingPayment);
                state.current_step = SagaStep::ReservingInventory;

                vec![
                    Effect::PublishEvent(InventoryCommand::ReserveItems {
                        order_id: state.order_id.clone().unwrap(),
                        items: state.items.clone(),
                    }),
                ]
            }

            // Inventory reserved → complete
            (SagaStep::ReservingInventory, CheckoutSagaAction::InventoryReserved { reservation_id }) => {
                state.reservation_id = Some(reservation_id);
                state.completed_steps.push(SagaStep::ReservingInventory);
                state.current_step = SagaStep::Completed;

                vec![
                    Effect::PublishEvent(CheckoutSagaAction::SagaCompleted),
                ]
            }

            // Payment failed → compensate order
            (SagaStep::ProcessingPayment, CheckoutSagaAction::PaymentFailed { reason }) => {
                state.current_step = SagaStep::Compensating {
                    failed_at: Box::new(SagaStep::ProcessingPayment),
                };

                // Compensate completed steps in reverse order
                self.compensate(state, env)
            }

            // Inventory failed → compensate payment and order
            (SagaStep::ReservingInventory, CheckoutSagaAction::InventoryReservationFailed { reason }) => {
                state.current_step = SagaStep::Compensating {
                    failed_at: Box::new(SagaStep::ReservingInventory),
                };

                self.compensate(state, env)
            }

            _ => vec![Effect::None],
        }
    }
}

impl CheckoutSagaReducer {
    /// Compensate completed steps in reverse order
    fn compensate(
        &self,
        state: &CheckoutSagaState,
        env: &SagaEnvironment,
    ) -> Vec<Effect<CheckoutSagaAction>> {
        let mut effects = vec![];

        // Compensate in reverse order
        for step in state.completed_steps.iter().rev() {
            match step {
                SagaStep::CreatingOrder => {
                    if let Some(order_id) = &state.order_id {
                        effects.push(Effect::PublishEvent(OrderCommand::CancelOrder {
                            order_id: order_id.clone(),
                            reason: "Saga compensation".to_string(),
                        }));
                    }
                }
                SagaStep::ProcessingPayment => {
                    if let Some(payment_id) = &state.payment_id {
                        effects.push(Effect::PublishEvent(PaymentCommand::RefundPayment {
                            payment_id: payment_id.clone(),
                        }));
                    }
                }
                _ => {}
            }
        }

        effects
    }
}
```

**Pattern**:
1. Match on `(current_step, action)` tuple
2. Update state, track completed steps
3. Publish next command via `Effect::PublishEvent`
4. On failure, compensate completed steps in reverse order

## EventBus Pattern (Multi-Aggregate Communication)

### EventBus Trait

```rust
pub trait EventBus: Send + Sync {
    type Event: Send + Sync;

    /// Publish event to topic
    async fn publish(&self, topic: &str, event: Self::Event) -> Result<(), Error>;

    /// Subscribe to topic with consumer group
    async fn subscribe(
        &self,
        topic: &str,
        group_id: &str,
        handler: impl Fn(Self::Event) -> Pin<Box<dyn Future<Output = Result<(), Error>> + Send>> + Send + Sync + 'static,
    ) -> Result<(), Error>;
}
```

### Publish Pattern

```rust
// In reducer, return Effect::PublishEvent
vec![
    Effect::PublishEvent {
        topic: "orders".to_string(),
        event: OrderEvent::OrderCreated { order_id: "123".to_string() },
    },
]

// Store executes effect via event bus
async fn execute_effect(&self, effect: Effect<Action>) {
    match effect {
        Effect::PublishEvent { topic, event } => {
            self.event_bus.publish(&topic, event).await?;
        }
        // ...
    }
}
```

### Subscribe Pattern

```rust
// Payment aggregate subscribes to orders topic
event_bus
    .subscribe("orders", "payment-service", |event| {
        Box::pin(async move {
            match event {
                OrderEvent::OrderCreated { order_id } => {
                    // Send payment processing action to payment store
                    payment_store
                        .send(PaymentAction::ProcessPayment { order_id })
                        .await?;
                }
                _ => {}
            }
            Ok(())
        })
    })
    .await?;
```

**Pattern**: Each aggregate subscribes to events it cares about. Sends actions to its own store. This creates cross-aggregate coordination.

### At-Least-Once Delivery

Events may be delivered multiple times. Design for idempotency:

```rust
// Idempotent action handling
fn reduce(&self, state: &mut State, action: Action, env: &Env) -> Vec<Effect> {
    match action {
        PaymentAction::ProcessPayment { order_id } => {
            // Check if already processed
            if state.processed_order_ids.contains(&order_id) {
                return vec![Effect::None];  // ✅ Idempotent
            }

            // Process payment
            state.processed_order_ids.insert(order_id.clone());
            // ... payment logic

            vec![Effect::PublishEvent(PaymentEvent::PaymentProcessed { order_id })]
        }
        _ => vec![Effect::None],
    }
}
```

**Pattern**: Track processed IDs or use unique keys to prevent duplicate processing.

## Orchestration vs Choreography

### Choreography (Event-Driven)

Each aggregate listens to events and reacts independently:

```
Order creates order → publishes OrderCreated
    ↓
Payment listens → processes payment → publishes PaymentProcessed
    ↓
Inventory listens → reserves items → publishes InventoryReserved
```

**Benefits**:
- Decoupled (no central coordinator)
- Aggregates are independent
- Easy to add new participants

**Drawbacks**:
- Hard to understand full flow
- Difficult to handle failures (who compensates?)
- No single source of saga state

### Orchestration (Saga Coordinator)

Central saga reducer coordinates the flow:

```
Saga: Create order → command
    ↓
Order: Order created → event
    ↓
Saga: Process payment → command
    ↓
Payment: Payment processed → event
    ↓
Saga: Reserve inventory → command
```

**Benefits**:
- Clear flow (visible in saga reducer)
- Centralized compensation logic
- Easy to track saga state
- Easier to debug

**Drawbacks**:
- Central coordinator (potential bottleneck)
- Saga knows about all participants

**Recommendation**: Use **orchestration** (saga as reducer) for complex flows with compensation. Use **choreography** for simple event cascades.

## Redpanda/Kafka Integration

### RedpandaEventBus Pattern

```rust
pub struct RedpandaEventBus {
    producer: FutureProducer,
    consumer: StreamConsumer,
}

impl RedpandaEventBus {
    pub fn builder() -> RedpandaEventBusBuilder {
        RedpandaEventBusBuilder::new()
    }
}

// Usage
let event_bus = RedpandaEventBus::builder()
    .broker("localhost:9092")
    .build()?;
```

### Publish Implementation

```rust
async fn publish(&self, topic: &str, event: Event) -> Result<(), Error> {
    let payload = bincode::serialize(&event)?;

    let record = FutureRecord::to(topic)
        .payload(&payload)
        .key(&event.aggregate_id());  // Partition by aggregate ID

    self.producer
        .send(record, Duration::from_secs(5))
        .await
        .map_err(|(err, _)| Error::PublishFailed(err))?;

    Ok(())
}
```

**Pattern**: Serialize with bincode. Use aggregate ID as key (ensures ordering per aggregate).

### Subscribe Implementation

```rust
async fn subscribe<F>(
    &self,
    topic: &str,
    group_id: &str,
    handler: F,
) -> Result<(), Error>
where
    F: Fn(Event) -> Pin<Box<dyn Future<Output = Result<(), Error>> + Send>> + Send + Sync + 'static,
{
    self.consumer.subscribe(&[topic])?;

    loop {
        match self.consumer.recv().await {
            Ok(message) => {
                let payload = message.payload().ok_or(Error::EmptyMessage)?;
                let event: Event = bincode::deserialize(payload)?;

                // Process event
                handler(event).await?;

                // Commit offset (at-least-once delivery)
                self.consumer.commit_message(&message, CommitMode::Async)?;
            }
            Err(e) => {
                eprintln!("Error receiving message: {}", e);
            }
        }
    }
}
```

**Pattern**:
1. Receive message
2. Deserialize event
3. Call handler
4. Commit offset (manual commit for at-least-once)

### Consumer Groups Pattern

Multiple instances of the same aggregate can share work:

```
Topic: orders (3 partitions)
Consumer Group: payment-service
  ├─ Instance 1 → Partition 0
  ├─ Instance 2 → Partition 1
  └─ Instance 3 → Partition 2
```

**Pattern**: Use same `group_id` for all instances. Kafka assigns partitions automatically. Each partition processed by exactly one instance.

## Compensation Patterns

### Pattern 1: Reverse Order Compensation

Compensate in reverse order of execution:

```rust
fn compensate(state: &SagaState) -> Vec<Effect> {
    let mut effects = vec![];

    for step in state.completed_steps.iter().rev() {
        effects.push(compensation_for_step(step));
    }

    effects
}
```

### Pattern 2: Compensating Actions

Each action has a compensating action:

| Action | Compensating Action |
|--------|---------------------|
| Create order | Cancel order |
| Charge payment | Refund payment |
| Reserve inventory | Release inventory |
| Send email | Send cancellation email |

### Pattern 3: Idempotent Compensation

Compensation must be idempotent (may be retried):

```rust
fn compensate_order(state: &mut State, order_id: &str) -> Vec<Effect> {
    // Check if already compensated
    if state.compensated_order_ids.contains(order_id) {
        return vec![Effect::None];
    }

    state.compensated_order_ids.insert(order_id.to_string());

    vec![Effect::PublishEvent(OrderCommand::CancelOrder {
        order_id: order_id.to_string(),
    })]
}
```

### Pattern 4: Partial Compensation

Some actions can't be fully compensated. Use best-effort:

```rust
match failed_step {
    SagaStep::EmailSent => {
        // Can't unsend email, send apology email instead
        vec![Effect::PublishEvent(EmailCommand::SendApology {
            customer_id: state.customer_id.clone(),
        })]
    }
    SagaStep::ExternalApiCalled => {
        // External API may not support compensation
        // Log for manual intervention
        vec![Effect::Log {
            level: LogLevel::Error,
            message: "Manual compensation required for external API".to_string(),
        }]
    }
}
```

## Error Handling and Retries

### Transient vs Permanent Failures

```rust
use composable_rust_core::delay;

match error {
    Error::NetworkTimeout | Error::ServiceUnavailable => {
        // Transient error → retry
        if state.retry_count < MAX_RETRIES {
            state.retry_count += 1;
            vec![delay! {
                duration: exponential_backoff(state.retry_count),
                action: original_action
            }]
        } else {
            // Max retries → compensate
            self.compensate(state, env)
        }
    }
    Error::InvalidData | Error::InsufficientFunds => {
        // Permanent error → compensate immediately
        self.compensate(state, env)
    }
}
```

### Dead Letter Queue Pattern

```rust
if state.retry_count >= MAX_RETRIES {
    vec![
        Effect::PublishEvent {
            topic: "dead-letter-queue".to_string(),
            event: SagaFailedEvent {
                saga_id: state.saga_id.clone(),
                failed_at: state.current_step.clone(),
                reason: error.to_string(),
            },
        },
        // Then compensate
        ...self.compensate(state, env),
    ]
}
```

**Pattern**: Send to DLQ for manual review, then compensate.

## Testing Patterns

### Unit Test: Saga State Machine

```rust
#[test]
fn test_checkout_saga_success_flow() {
    let env = test_environment();
    let mut state = CheckoutSagaState::new("saga-1".to_string());

    // Start checkout
    let effects = reducer.reduce(
        &mut state,
        CheckoutSagaAction::StartCheckout { ... },
        &env,
    );
    assert_eq!(state.current_step, SagaStep::CreatingOrder);

    // Order created
    let effects = reducer.reduce(
        &mut state,
        CheckoutSagaAction::OrderCreated { order_id: "order-1".to_string() },
        &env,
    );
    assert_eq!(state.current_step, SagaStep::ProcessingPayment);

    // Payment processed
    let effects = reducer.reduce(
        &mut state,
        CheckoutSagaAction::PaymentProcessed { payment_id: "pay-1".to_string() },
        &env,
    );
    assert_eq!(state.current_step, SagaStep::ReservingInventory);

    // Inventory reserved
    let effects = reducer.reduce(
        &mut state,
        CheckoutSagaAction::InventoryReserved { reservation_id: "res-1".to_string() },
        &env,
    );
    assert_eq!(state.current_step, SagaStep::Completed);
}
```

### Unit Test: Compensation

```rust
#[test]
fn test_checkout_saga_compensation() {
    let env = test_environment();
    let mut state = CheckoutSagaState::new("saga-1".to_string());

    // Simulate completed steps
    state.current_step = SagaStep::ProcessingPayment;
    state.completed_steps.push(SagaStep::CreatingOrder);
    state.order_id = Some("order-1".to_string());

    // Payment fails
    let effects = reducer.reduce(
        &mut state,
        CheckoutSagaAction::PaymentFailed { reason: "Insufficient funds".to_string() },
        &env,
    );

    // Should compensate order
    assert!(matches!(state.current_step, SagaStep::Compensating { .. }));
    assert!(matches!(effects[0], Effect::PublishEvent(OrderCommand::CancelOrder { .. })));
}
```

### Integration Test: With InMemoryEventBus

```rust
#[tokio::test]
async fn test_saga_with_event_bus() {
    let event_bus = InMemoryEventBus::new();

    // Create stores for each aggregate
    let order_store = Store::new(OrderState::default(), OrderReducer, order_env);
    let payment_store = Store::new(PaymentState::default(), PaymentReducer, payment_env);
    let saga_store = Store::new(CheckoutSagaState::new("saga-1"), SagaReducer, saga_env);

    // Subscribe aggregates to events
    event_bus.subscribe("orders", "payment-service", |event| {
        Box::pin(async move {
            payment_store.send(PaymentAction::from_order_event(event)).await
        })
    }).await?;

    // Start saga
    saga_store.send(CheckoutSagaAction::StartCheckout { ... }).await;

    // Wait for completion
    tokio::time::sleep(Duration::from_millis(100)).await;

    let saga_state = saga_store.state().await;
    assert_eq!(saga_state.current_step, SagaStep::Completed);
}
```

## Common Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Synchronous Cross-Aggregate Calls
```rust
// ❌ Don't call other aggregates directly
fn reduce(...) -> Vec<Effect> {
    let payment_result = payment_service.process_payment().await;  // ❌ Tight coupling
}
```
**Solution**: Use event bus for async communication.

### ❌ Anti-Pattern 2: Not Tracking Compensation Data
```rust
// ❌ Can't compensate without IDs
struct SagaState {
    current_step: Step,
    // ❌ Missing: order_id, payment_id, etc.
}
```
**Solution**: Store all IDs needed for compensation.

### ❌ Anti-Pattern 3: Ignoring Idempotency
```rust
// ❌ Processing same event twice
fn reduce(...) -> Vec<Effect> {
    state.balance -= amount;  // ❌ Double-deduct if event replays
}
```
**Solution**: Check if event already processed.

### ❌ Anti-Pattern 4: Compensation Order Errors
```rust
// ❌ Compensating in wrong order
fn compensate(state: &SagaState) -> Vec<Effect> {
    for step in state.completed_steps.iter() {  // ❌ Forward order
        // Compensation
    }
}
```
**Solution**: Compensate in **reverse** order.

### ❌ Anti-Pattern 5: No Timeout for Saga Steps
```rust
// ❌ Saga waits forever for event
fn reduce(...) -> Vec<Effect> {
    // Waits indefinitely for PaymentProcessed event
}
```
**Solution**: Use timeouts and retry logic:
```rust
use composable_rust_core::delay;

vec![
    Effect::PublishEvent(command),
    delay! {
        duration: Duration::from_secs(30),
        action: SagaAction::StepTimeout { step: current_step }
    },
]
```

## Advanced Patterns

### Pattern: Nested Sagas (Hierarchical Workflows)

**Use Case**: Complex workflows where one saga orchestrates multiple child sagas.

**Example**: Order Fulfillment saga coordinates Payment saga + Shipping saga + Notification saga.

#### Parent Saga State

```rust
#[derive(Clone, Debug)]
pub struct OrderFulfillmentState {
    pub order_id: String,
    pub status: FulfillmentStatus,

    // Child saga states (owned by parent)
    pub payment_saga: PaymentSagaState,
    pub shipping_saga: Option<ShippingSagaState>,
    pub notification_saga: Option<NotificationSagaState>,

    // Track which child sagas are active
    pub active_children: Vec<ChildSaga>,
}

#[derive(Clone, Debug)]
pub enum FulfillmentStatus {
    Idle,
    ProcessingPayment,
    ProcessingShipping,
    SendingNotifications,
    Completed,
    Compensating { failed_child: ChildSaga },
    Failed,
}

#[derive(Clone, Debug, PartialEq)]
pub enum ChildSaga {
    Payment,
    Shipping,
    Notification,
}
```

#### Parent Saga Reducer

```rust
impl Reducer for OrderFulfillmentSaga {
    type State = OrderFulfillmentState;
    type Action = FulfillmentAction;
    type Environment = FulfillmentEnvironment;

    fn reduce(
        &self,
        state: &mut Self::State,
        action: Self::Action,
        env: &Self::Environment,
    ) -> SmallVec<[Effect<Self::Action>; 4]> {
        use FulfillmentStatus::*;

        match (&state.status, action) {
            // Parent starts: delegate to Payment child saga
            (Idle, FulfillmentAction::StartFulfillment { order_id, amount }) => {
                state.status = ProcessingPayment;
                state.order_id = order_id.clone();
                state.active_children.push(ChildSaga::Payment);

                // Delegate to child Payment saga
                smallvec![Effect::PublishEvent(PaymentAction::InitiatePayment {
                    order_id,
                    amount,
                })]
            }

            // Child Payment saga completed successfully
            (ProcessingPayment, FulfillmentAction::PaymentCompleted { transaction_id }) => {
                state.payment_saga.transaction_id = Some(transaction_id.clone());
                state.status = ProcessingShipping;
                state.active_children.push(ChildSaga::Shipping);

                // Start next child saga
                smallvec![Effect::PublishEvent(ShippingAction::InitiateShipping {
                    order_id: state.order_id.clone(),
                    transaction_id,
                })]
            }

            // Child Payment saga failed → Compensate
            (ProcessingPayment, FulfillmentAction::PaymentFailed { error }) => {
                state.status = Compensating {
                    failed_child: ChildSaga::Payment,
                };

                // No compensation needed (nothing to undo yet)
                smallvec![Effect::PublishEvent(FulfillmentAction::FulfillmentFailed {
                    reason: format!("Payment failed: {error}"),
                })]
            }

            // Child Shipping saga failed → Compensate Payment
            (ProcessingShipping, FulfillmentAction::ShippingFailed { error }) => {
                state.status = Compensating {
                    failed_child: ChildSaga::Shipping,
                };

                // Compensate: Refund payment (undo child Payment saga)
                if let Some(transaction_id) = &state.payment_saga.transaction_id {
                    smallvec![Effect::PublishEvent(PaymentAction::RefundPayment {
                        transaction_id: transaction_id.clone(),
                    })]
                } else {
                    smallvec![Effect::None]
                }
            }

            // All child sagas succeeded
            (ProcessingShipping, FulfillmentAction::ShippingCompleted { tracking }) => {
                state.status = Completed;
                state.active_children.clear();

                smallvec![Effect::PublishEvent(FulfillmentAction::FulfillmentCompleted {
                    order_id: state.order_id.clone(),
                    tracking,
                })]
            }

            _ => smallvec![Effect::None],
        }
    }
}
```

#### Key Patterns for Nested Sagas

**1. Parent Owns Child State**

```rust
pub struct ParentState {
    pub child1: Child1State,  // ✅ Owned by parent
    pub child2: Child2State,  // ✅ Owned by parent
}
```

**Why**: Parent needs visibility into child state for compensation and coordination.

**2. Explicit Child Tracking**

```rust
pub active_children: Vec<ChildSaga>,  // Track which children are running
```

**Why**: Know which children to compensate if parent saga fails.

**3. Error Propagation Up, Compensation Down**

```rust
// Error propagates UP from child to parent
(ProcessingChild, Action::ChildFailed { error }) => {
    state.status = Compensating { failed_child };
    // Parent decides what to do
}

// Compensation flows DOWN from parent to children
(Compensating, _) => {
    // Parent triggers compensation in children
    smallvec![Effect::PublishEvent(ChildAction::Compensate)]
}
```

**4. Sequential vs Parallel Children**

```rust
// Sequential: Start child2 after child1 completes
(ChildCompleted, Child1Success) => {
    smallvec![Effect::PublishEvent(StartChild2)]
}

// Parallel: Start all children at once
(Idle, Start) => {
    smallvec![
        Effect::PublishEvent(StartChild1),
        Effect::PublishEvent(StartChild2),
        Effect::PublishEvent(StartChild3),
    ]
}
```

#### Benefits of Nested Sagas

- ✅ **Modularity**: Child sagas are reusable in different parent contexts
- ✅ **Clear ownership**: Parent owns coordination, children own domain logic
- ✅ **Explicit compensation**: Parent decides compensation strategy
- ✅ **Testing**: Test child sagas independently, parent tests coordination

#### When to Use Nested Sagas

**Use nested sagas when**:
- Workflow has clear hierarchical structure
- Child workflows are reusable across different parents
- Need different compensation strategies per parent context

**Avoid nested sagas when**:
- Workflow is simple and flat (use single saga)
- Children are tightly coupled (merge into one saga)
- Communication overhead exceeds benefit (inline the logic)

### Pattern: Saga Timeouts

```rust
use composable_rust_core::delay;

vec![
    Effect::PublishEvent(command),
    delay! {
        duration: Duration::from_secs(30),
        action: SagaAction::Timeout {
            step: state.current_step.clone(),
        }
    },
]

// In reducer
(step, SagaAction::Timeout { step: timeout_step }) if step == timeout_step => {
    // Step timed out, compensate
    self.compensate(state, env)
}
```

### Pattern: Saga Persistence

Persist saga state to recover from crashes:

```rust
fn reduce(...) -> Vec<Effect> {
    vec![
        Effect::Database(SaveSagaState(state.clone())),
        Effect::PublishEvent(next_command),
    ]
}
```

## Quick Reference Checklist

When implementing sagas:

- [ ] **State machine**: Track current step and completed steps
- [ ] **Compensation data**: Store IDs needed for rollback
- [ ] **Idempotent actions**: Check if already processed
- [ ] **Reverse compensation**: Undo in reverse order
- [ ] **Timeout handling**: Don't wait forever for events
- [ ] **Retry logic**: Distinguish transient vs permanent errors
- [ ] **Dead letter queue**: Handle max retries
- [ ] **Event bus**: Use for cross-aggregate communication
- [ ] **Consumer groups**: For parallel processing
- [ ] **Manual offset commit**: For at-least-once delivery

## Performance Considerations

- **Orchestration overhead**: Saga coordinator is extra hop, but usually negligible (<10ms)
- **Event bus latency**: Kafka/Redpanda add ~5-20ms per event
- **Compensation cost**: Rare in happy path (typically <1% of sagas compensate)
- **Consumer lag**: Monitor with Kafka metrics, scale consumers if needed

## See Also

- **Architecture**: `composable-rust-architecture.skill` - Core reducer/effect patterns
- **Event Sourcing**: `composable-rust-event-sourcing.skill` - Event store and persistence
- **Documentation**: `docs/sagas.md` - Comprehensive saga guide
- **Patterns**: `docs/saga-patterns.md` - Additional saga patterns
- **Consistency**: `docs/consistency-patterns.md` - Consistency guarantees

---

**Remember**: A saga is just a reducer with a state machine. Compensate in reverse order. Design for idempotency. Use event bus for coordination.
