---
name: Long Task Execution Framework
description: Protocol for reliable multi-hour task execution with automatic checkpointing, validation, and recovery
version: 1.0.0
---

# Long Task Execution Framework

Robust protocol for executing tasks that take multiple hours with confidence.

## Core Principles

1. **Atomicity**: Every task must be decomposed into atomic sub-tasks < 10 minutes
2. **Validation**: Validate after every change, before every checkpoint
3. **Checkpointing**: Create checkpoint after every completed atomic task
4. **Recovery**: Automatic retry → rollback → escalate on failures
5. **Determinism**: Use scripts for critical operations (not LLM decisions)

## Atomic Task Requirements

Each atomic task MUST:
- Take < 10 minutes to execute
- Have clear, verifiable success criteria
- Be independently rollback-able
- Have explicit dependencies listed
- Have a rollback plan defined

## Validation Protocol

### After Every Code Change:
```bash
npx tsc --noEmit --skipLibCheck    # TypeScript (2-5s)
npx eslint src --max-warnings 0    # Linting (1-3s)
```

### After Atomic Task Completion:
```bash
bash .claude/framework/validation-gate.sh atomic
```

### Before Final Completion:
```bash
bash .claude/framework/validation-gate.sh final
```

**NEVER** continue if validation fails. Stop and recover.

## Checkpoint Strategy

### Create checkpoint:
- ✅ **AFTER** each atomic task completes successfully
- ✅ **BEFORE** risky operations (migrations, major refactors)
- ✅ **Every 15 minutes MAX** (even if task incomplete)
- ❌ **NEVER** on validation failures
- ❌ **NEVER** during rollback
- 📁 Snapshot stored at `.claude/checkpoints/{id}/snapshot/` (excludes `.claude/checkpoints`, `.git`, `node_modules`)

### Checkpoint naming:
- Pattern: `ckpt_{taskId}_{atomicTaskId}_{timestamp}`
- Example: `ckpt_sprint-1_task1.3_1729612345`

### Checkpoint metadata:
Include context:
- Decisions made ("Chose approach X over Y because...")
- Blockers encountered
- Files changed
- Next task

## Recovery Protocol

On failure, execute in order:

### Level 1: Retry (3 attempts max)
```bash
node .claude/framework/recovery.js --task-id=X --error='{"type":"...","message":"..."}'
```
- Same approach, maybe transient error
- Agent retries task automatically

### Level 2: Rollback
- Restore to last valid checkpoint
- Try alternative approach
- Agent retries with different strategy

### Level 3: Escalate
- Mark task as BLOCKED
- Notify human with error details and options
- Wait for manual intervention

## State Machine

Valid state transitions:
```
INITIALIZED → PLANNING
PLANNING → PLANNED | FAILED
PLANNED → EXECUTING
EXECUTING → VALIDATING | FAILED
VALIDATING → CHECKPOINTING | FAILED
CHECKPOINTING → EXECUTING | COMPLETED
FAILED → ROLLING_BACK | ABANDONED
ROLLING_BACK → EXECUTING | ABANDONED
```

**Invalid transitions are errors.**

## Scripts Reference

All scripts are in `.claude/framework/`:

```bash
# Logger (structured JSON logs)
node logger.js --event=EVENT_NAME --data='{"key":"value"}'

# Checkpoint Manager
node checkpoint-manager.js create --task-id=X --context='{"decisions":"..."}'
node checkpoint-manager.js restore --checkpoint-id=ckpt_xyz
node checkpoint-manager.js list

# Validation Gates
bash validation-gate.sh atomic       # Fast: tsc + eslint
bash validation-gate.sh checkpoint   # Medium: + tests
bash validation-gate.sh final        # Full: + build (optional)

# Recovery
node recovery.js --task-id=X --error='{"type":"...","message":"..."}'

# Conditional Hook (called by hooks automatically)
node conditional-hook.js validate-ts
node conditional-hook.js checkpoint
node conditional-hook.js final-validation
```

## Execution Loop

```
FOR EACH atomic task WHERE status !== 'completed':
  1. Mark task as 'in_progress' (TodoWrite)
  2. Execute task (write code, modify files)
     → Write hook triggers: validate-ts
  3. Validate explicitly: validation-gate.sh atomic
  4. If validation fails: call recovery.js
  5. Mark task as 'completed' (TodoWrite)
     → TodoWrite hook triggers: checkpoint (automatic)
  6. Continue to next task

WHEN all tasks done:
  7. Final validation: validation-gate.sh final
  8. Create final checkpoint
  9. Generate report
  10. Mark task as COMPLETED
```

## Success Criteria

A long task is successfully completed when:
1. ✅ All atomic tasks status = 'completed'
2. ✅ Final validation passes (TypeScript + ESLint + Tests)
3. ✅ Final checkpoint created
4. ✅ Execution report generated
5. ✅ Zero blockers or unresolved errors

## Iron Laws

1. **NEVER** skip task decomposition - Long task WITHOUT atomic tasks = BLOCKED
2. **NEVER** continue on validation failure - Failed validation = STOP + RECOVER
3. **NEVER** exceed maxTime (10min) - If task takes longer = something is wrong, STOP
4. **ALWAYS** checkpoint after completed task - No exceptions
5. **ALWAYS** use state machine - Invalid transitions = ERROR
6. **ALWAYS** log structured - Every event, every decision (JSON format)
7. **NEVER** lose context - Checkpoints carry FULL context
8. **ALWAYS** self-heal - Try recovery before escalating to human

## Performance Targets

- Validation per task: < 5 seconds (npx tsc --noEmit)
- Checkpoint creation: < 1 second
- Recovery decision: < 30 seconds
- Total overhead: < 5% of execution time

Use `npx tsc --noEmit` instead of `npm run build` for validation (90% faster).
