---
name: Ultraplan
description: This skill should be used when the user asks to "start parallel implementation", "orchestrate tasks", "run ultraplan", "launch ultrathink workflow", "parallel subagent execution", "plan and implement feature", "coordinate implementation across phases", "run 100 agents", "massive parallel work", or needs guidance on orchestrating multi-phase implementation workflows with parallel Task invocations.
version: 1.0.0
---

# Ultraplan - Parallel Orchestration Workflow

Ultraplan enables coordinated multi-phase implementation using parallel Task invocations (up to 100 simultaneous). It leverages subagents for each implementation phase.

## Core Concept

Ultraplan orchestrates work through phases:

| Phase | Purpose | Subagent Role |
|-------|---------|---------------|
| Phase 1 | Exploration | Understand codebase areas |
| Phase 2 | Planning | Design implementation approach |
| Phase 3 | Implementation | Execute planned changes |
| Phase 4 | Verification | Validate correctness |

Each phase may spawn multiple parallel Task invocations for independent subtasks.

## Invocation Process

### Step 1: Context Gathering

Before orchestrating, gather implementation context:

1. Identify target areas of the codebase
2. Determine parallelization opportunities - independent subtasks within each phase
3. Map dependencies - which tasks block others

Query the user if context is insufficient:
- "Which areas should I focus on?"
- "Should I work on a specific phase or orchestrate all phases?"

### Step 2: Task Decomposition

For each task, decompose into parallelizable subtasks:

**Parallelization Rules:**
- Tasks within the same phase MAY run in parallel if no data dependency
- Tasks across phases MUST respect phase ordering (1 -> 2 -> 3 -> 4)
- Maximum 100 parallel Task invocations per orchestration batch

**Task Schema:**
```
task_id: unique-task-identifier
phase: 1|2|3|4
description: imperative description
deps: [task_id, ...]
files: [affected files]
acceptance: testable criteria
```

### Step 3: Subagent Dispatch

Launch parallel Task invocations for independent subtasks:

**Dispatch Pattern:**
```
For each phase in [1, 2, 3, 4]:
  identify_ready_tasks(phase)  # Tasks with satisfied deps
  batch_tasks = partition(ready_tasks, max_batch=100)
  for batch in batch_tasks:
    parallel_invoke(Task, batch)  # Up to 100 simultaneous
  await_all(batch)
  validate_phase_output()
  proceed_to_next_phase()
```

**Subagent Prompt Template:**

Each Task invocation receives:
1. Specific task identifier
2. Target file paths
3. Acceptance criteria
4. Phase-specific instructions

### Step 4: Progress Tracking

Track implementation progress:

1. **Before work**: Mark task as in-progress
2. **After completion**: Mark task as complete
3. **Add traceability**: Note validation method

### Step 5: Verification Gate

Before marking orchestration complete:

1. Run build - no warnings
2. Run tests - all pass
3. Run linting - no warnings

## Phase-Specific Subagent Instructions

### Phase 1 Subagent: Exploration

Instructions for Phase 1 Task invocations:
- Read and understand target files
- Identify key types and APIs
- Find existing patterns
- Map dependencies
- Report findings (do NOT make changes)

### Phase 2 Subagent: Planning

Instructions for Phase 2 Task invocations:
- Design changes based on exploration
- Specify file paths and line ranges
- Order changes by dependency
- Identify test cases needed
- Return structured plan

### Phase 3 Subagent: Implementation

Instructions for Phase 3 Task invocations:
- Execute planned changes
- Follow existing code patterns
- Add documentation
- Run local tests
- Report completion status

### Phase 4 Subagent: Verification

Instructions for Phase 4 Task invocations:
- Run full test suite
- Check linting
- Verify documentation
- Report any issues found

## Orchestration Commands

| Action | How to Invoke |
|--------|---------------|
| Start ultraplan | "Run /ultraplan" or "start parallel implementation" |
| Target specific area | "Implement changes to the auth module" |
| Single phase only | "Run exploration phase only" |
| Check status | "What tasks remain?" |
| Verify completion | "Validate all tasks are complete" |

## Error Handling

When a subagent Task fails:

1. Capture failure context - error message, affected files
2. Determine retry eligibility - transient vs. fundamental failure
3. Isolate affected tasks - do not block unrelated parallel work
4. Report to orchestrator - aggregate failure summary
5. Suggest remediation - specific fix guidance

## Best Practices

### Parallelization Guidelines

1. Maximize parallelism within phases (independent subtasks)
2. Respect phase boundaries - never start Phase N+1 before Phase N completes
3. Batch appropriately - group related subtasks to minimize context switches
4. Use explicit dependencies - model task DAG accurately

### Code Quality Gates

Every subagent must ensure:
- No compiler/linter warnings
- All tests pass
- Documentation complete

## Quick Start

To begin an ultraplan orchestration:

1. Identify target areas of the codebase
2. Confirm scope with user
3. Decompose into parallelizable tasks
4. Dispatch Phase 1 subagents in parallel
5. On Phase 1 completion, dispatch Phase 2, etc.
6. Run verification gate
7. Report final status
