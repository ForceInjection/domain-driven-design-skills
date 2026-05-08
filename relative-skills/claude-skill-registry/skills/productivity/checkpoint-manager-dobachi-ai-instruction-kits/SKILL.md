---
name: checkpoint-manager
description: Skill for tracking and managing task progress. Checks pending tasks at conversation start, proposes task creation for new requests, suggests completion reports when work is done. Integrates with checkpoint system.
---

# Checkpoint Manager Skill

A skill for consistently tracking and reporting task progress.

## Auto-Suggestion Triggers

| Situation | Suggestion |
|-----------|------------|
| Conversation start | "Shall I check for pending tasks?" |
| New task request | "Shall I start a checkpoint?" |
| Before loading instructions | "Shall I record instruction usage?" |
| Work milestone | "Shall I report progress?" |
| Work completion | "Shall I complete the task?" |

## Workflow Overview

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  pending    │    │  start      │    │  progress   │    │  complete   │
│  check      │ → │  begin      │ → │  report     │ → │  finish     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                          ↓
                   ┌─────────────┐
                   │ instruction │
                   │ management  │
                   └─────────────┘
```

See [workflow.md](workflow.md) for details.

## Command Reference

### Task Management

```bash
# Check pending tasks
scripts/checkpoint.sh pending

# Start a new task (task ID auto-generated)
scripts/checkpoint.sh start "<task-name>" <steps>

# Report progress (only during instruction use)
scripts/checkpoint.sh progress <task-id> <current> <total> "<status>" "<next>"

# Complete task (all instructions must be completed)
scripts/checkpoint.sh complete <task-id> "<result>"

# Report error
scripts/checkpoint.sh error <task-id> "<message>"
```

### Instruction Management

```bash
# Start using an instruction
scripts/checkpoint.sh instruction-start "<path>" "<purpose>" [task-id]

# Complete instruction use
scripts/checkpoint.sh instruction-complete "<path>" "<result>" [task-id]
```

### Status Check

```bash
# Show task history
scripts/checkpoint.sh summary <task-id>
```

## Usage Scenarios

### Scenario 1: Conversation Start

When user starts a new conversation, suggest checking for pending tasks:

```
AI: Shall I check for pending tasks?

# Execute
scripts/checkpoint.sh pending
```

### Scenario 2: New Task Request

When user requests something like "implement X":

```
AI: Shall I start a checkpoint?
    Task name: [user's request]
    Estimated steps: [based on complexity]

# Execute
scripts/checkpoint.sh start "Feature implementation" 5
# → Task ID: TASK-123456-abc123
```

### Scenario 3: Instruction Use

Before loading an instruction:

```
AI: Shall I record instruction usage?

# Execute
scripts/checkpoint.sh instruction-start "instructions/en/presets/web_api.md" "REST API development" TASK-123456-abc123
```

### Scenario 4: Work Milestone

When significant progress is made:

```
AI: Shall I report progress?
    Current: 2/5 steps
    Status: Design complete
    Next: Start implementation

# Execute
scripts/checkpoint.sh progress TASK-123456-abc123 2 5 "Design complete" "Start implementation"
```

### Scenario 5: Work Completion

When task is complete:

```
AI: Shall I complete the task?
    Result: [summary of work]

# Execute instruction completion first
scripts/checkpoint.sh instruction-complete "instructions/en/presets/web_api.md" "3 endpoints implemented" TASK-123456-abc123

# Then complete task
scripts/checkpoint.sh complete TASK-123456-abc123 "REST API 3 endpoints implemented"
```

## Workflow Constraints

| Constraint | Description |
|------------|-------------|
| Progress report | Only allowed during instruction use |
| Task completion | All instructions must be completed first |
| Task ID omission | Warning displayed for instruction commands |

## Decision Criteria

### When to Suggest Task Start

- User requests specific work
- Work involves multiple steps
- Keywords like "implement", "create", "fix"

### When to Suggest Progress Report

- Significant code changes made
- Tests passed/failed
- Clear work milestone reached

### When to Suggest Task Completion

- User says "done", "finished", "complete"
- All requirements met
- Tests passing

## Notes

- Task IDs are auto-generated (e.g., TASK-123456-abc123)
- Keep status and actions brief and clear
- Use the same task ID throughout a task
- Run `scripts/checkpoint.sh` from project root
