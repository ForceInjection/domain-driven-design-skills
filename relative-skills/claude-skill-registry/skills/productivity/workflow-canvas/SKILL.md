---
name: workflow-canvas
description: Celery canvas patterns for workflow composition including chains, groups, chords, signatures, error handling, and nested workflows. Use when building complex task workflows, parallel execution patterns, task synchronization, callback handling, or when user mentions canvas primitives, workflow composition, task chains, parallel processing, or chord patterns.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Workflow Canvas

**Purpose:** Implement Celery canvas patterns for composing complex, distributed task workflows.

**Activation Triggers:**
- Sequential task execution needed (chains)
- Parallel task processing required (groups)
- Synchronization after parallel work (chords)
- Complex workflow composition
- Task result aggregation
- Error handling in workflows
- Nested or conditional workflows

**Key Resources:**
- `scripts/test-workflow.sh` - Test workflow execution and validate patterns
- `scripts/validate-canvas.sh` - Validate canvas structure and dependencies
- `scripts/generate-workflow.sh` - Generate workflows from templates
- `templates/` - Complete workflow pattern implementations
- `examples/` - Real-world workflow scenarios with explanations

## Canvas Primitives

### 1. Signatures

Foundation of canvas system - encapsulate task invocation details:

```python
from celery import signature

# Named signature
signature('tasks.add', args=(2, 2), countdown=10)

# Using task method
add.signature((2, 2), countdown=10)

# Shortcut syntax (most common)
add.s(2, 2)

# Immutable signature (prevents result forwarding)
add.si(2, 2)
```

**Use templates/chain-workflow.py** for signature examples.

### 2. Chains

Sequential task execution where each task's result becomes next task's first argument:

```python
from celery import chain

# Explicit chain
chain(add.s(2, 2), add.s(4), add.s(8))()

# Pipe syntax (recommended)
(add.s(2, 2) | add.s(4) | add.s(8))()

# With immutable tasks (independent execution)
(add.si(2, 2) | process.s() | notify.si('done'))()
```

**Key Pattern:** Use `.si()` when task should NOT receive previous result.

**See templates/chain-workflow.py** for complete patterns.

### 3. Groups

Execute multiple tasks in parallel, returns GroupResult:

```python
from celery import group

# Parallel execution
group(add.s(i, i) for i in range(10))()

# With result tracking
job = group(process.s(item) for item in batch)
result = job.apply_async()
result.get()  # Wait for all tasks
```

**Requirements:**
- Tasks must NOT ignore results
- Result backend required

**See templates/group-parallel.py** for implementation.

### 4. Chords

Group header + callback that executes after all header tasks complete:

```python
from celery import chord

# Basic chord
chord(add.s(i, i) for i in range(100))(tsum.s()).get()

# With error handling
chord(
    process.s(item) for item in batch
)(aggregate_results.s()).on_error(handle_chord_error.s())
```

**Critical Requirements:**
- Result backend MUST be enabled
- Set `task_ignore_result=False` explicitly
- Redis 2.2+ for proper operation

**Error Handling:**
Failed header tasks → callback receives ChordError with task ID and exception.

**See templates/chord-pattern.py** for complete implementation.

### 5. Map & Starmap

Built-in tasks for sequence processing (single message, sequential execution):

```python
# Map: one call per element
add.map([(2, 2), (4, 4), (8, 8)])

# Starmap: unpacks tuples
add.starmap(zip(range(100), range(100)))
```

**Difference from groups:** Single task message vs multiple messages.

### 6. Chunks

Divide large iterables into sized batches:

```python
# Process 100 items in chunks of 10
add.chunks(zip(range(100), range(100)), 10)
```

**Returns:** Nested lists corresponding to chunk outputs.

## Advanced Patterns

### Partial Application

```python
# Incomplete signature
partial = add.s(2)

# Complete later (arguments prepended)
partial.delay(4)  # Executes add(4, 2)

# Kwargs merge with precedence
partial = process.s(timeout=30)
partial.apply_async(kwargs={'timeout': 60})  # Uses 60
```

### Nested Workflows

Combine primitives for complex logic:

```python
# Chain of chords
workflow = chain(
    chord([task1.s(), task2.s()])(callback1.s()),
    chord([task3.s(), task4.s()])(callback2.s())
)

# Groups in chains
workflow = (
    prepare.s() |
    group([process.s(i) for i in range(10)]) |
    finalize.s()
)
```

**See templates/nested-workflows.py** for production patterns.

### Error Callbacks

```python
# Task-level error handling
add.s(2, 2).on_error(log_error.s()).delay()

# Chord error handling
chord(
    header_tasks
)(callback.s()).on_error(handle_error.s())
```

**Errback signature:** `(request, exc, traceback)`

**Execution:** Synchronous in worker.

**See templates/error-handling-workflow.py** for comprehensive patterns.

### Complex Workflow Example

```python
from celery import chain, group, chord

# Data processing pipeline
workflow = chain(
    # Stage 1: Fetch and validate
    fetch_data.s(),
    validate_data.s(),

    # Stage 2: Parallel processing
    group([
        transform_batch.s(i) for i in range(num_batches)
    ]),

    # Stage 3: Aggregate results
    chord([
        aggregate_batch.s(i) for i in range(num_batches)
    ])(finalize_report.s()),

    # Stage 4: Notify
    send_notification.si('pipeline_complete')
)

# Execute with error handling
result = workflow.apply_async(
    link_error=handle_pipeline_error.s()
)
```

**See templates/complex-workflow.py** for production-ready implementation.

## Testing Workflows

### Validate Canvas Structure

```bash
# Check workflow composition
./scripts/validate-canvas.sh path/to/workflow.py

# Validates:
# - Result backend enabled
# - Task ignore_result settings
# - Proper signature usage
# - Error callback patterns
```

### Test Workflow Execution

```bash
# Run workflow with test data
./scripts/test-workflow.sh workflow_name

# Options:
# --dry-run    : Validate without execution
# --verbose    : Show detailed task flow
# --timeout 30 : Set execution timeout
```

## Best Practices

**DO:**
- Enable result backend for groups/chords
- Use `.si()` for independent tasks in chains
- Implement error callbacks for critical workflows
- Set explicit timeouts for long-running workflows
- Use chunks for large data processing
- Add metadata with stamping API (5.3+)
- Make error callbacks idempotent

**DON'T:**
- Have tasks wait synchronously for other tasks
- Ignore results for tasks in groups
- Forget to call `super()` in `after_return()` overrides
- Use chords without Redis 2.2+
- Create deeply nested workflows (>3 levels)
- Mix synchronous and async task calls

## Configuration Requirements

**Celery Config:**
```python
# Required for canvas
result_backend = 'redis://localhost:6379/0'
result_extended = True  # Store task args/kwargs

# Recommended
task_track_started = True
result_expires = 3600  # 1 hour

# For large workflows
worker_prefetch_multiplier = 1
task_acks_late = True
```

## Debugging

**Visualize workflow:**
```python
from celery import DependencyGraph

graph = workflow.__graph__()
with open('workflow.dot', 'w') as f:
    f.write(graph.to_dot())

# Convert to image:
# dot -Tpng workflow.dot -o workflow.png
```

**Monitor execution:**
```python
result = workflow.apply_async()
print(f"Task ID: {result.id}")
print(f"Status: {result.status}")
print(f"Children: {result.children}")
```

## Resources

**Templates:**
- `chain-workflow.py` - Sequential task patterns
- `group-parallel.py` - Parallel execution patterns
- `chord-pattern.py` - Synchronization patterns
- `complex-workflow.py` - Multi-stage pipelines
- `error-handling-workflow.py` - Error callback patterns
- `nested-workflows.py` - Advanced composition

**Scripts:**
- `test-workflow.sh` - Execute and validate workflows
- `validate-canvas.sh` - Static analysis of canvas patterns
- `generate-workflow.sh` - Generate workflows from templates

**Examples:**
- `examples/chain-example.md` - Real-world chain scenarios
- `examples/group-example.md` - Parallel processing use cases
- `examples/chord-example.md` - Synchronization patterns
- `examples/complex-workflows.md` - Production workflow architectures

## Security Compliance

This skill follows strict security rules:
- All code examples use placeholder values only
- No real API keys, passwords, or secrets
- Environment variable references in all code
- `.gitignore` protection documented

---

**Version:** 1.0.0
**Celery Compatibility:** 5.0+
**Required Backend:** Redis 2.2+ or compatible result backend
