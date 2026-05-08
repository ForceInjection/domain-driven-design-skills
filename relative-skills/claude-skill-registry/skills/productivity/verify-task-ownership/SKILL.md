---
name: verify-task-ownership
description: Verify session ownership before working on existing tasks (multi-instance coordination)
allowed-tools: Bash, Read
---

# Verify Task Ownership Skill

**Purpose**: Check if an existing task is owned by the current session before working on it.
Prevents multiple Claude instances from conflicting on the same task.

**Why This Matters**: When multiple Claude Code instances run concurrently, each may find
existing tasks in various states. Without ownership verification, one instance may take over
another's work-in-progress, causing conflicts and lost work.

## When to Use This Skill

### Use verify-task-ownership When:

- Task directory already exists at `/workspace/tasks/{task-name}/`
- Before resuming work on any existing task
- When finding a task in AWAITING_USER_APPROVAL state
- Starting a session and checking for continuable work

### Do NOT Use When:

- Creating a new task (task directory doesn't exist)
- Task confirmed as yours from previous check in same session
- Working on task you just initialized with task-init

## Ownership Verification Process

### Step 1: Check if Task Directory Exists

```bash
TASK_NAME="{task-name}"
TASK_DIR="/workspace/tasks/$TASK_NAME"

if [ ! -d "$TASK_DIR" ]; then
  echo "Task directory doesn't exist - safe to create new task"
  exit 0  # PROCEED with task-init
fi
```

### Step 2: Check task.json for Session Ownership

```bash
# Get session_id from task.json
LOCK_SESSION=$(jq -r '.session_id // "missing"' "$TASK_DIR/task.json" 2>/dev/null)

# Get current session ID (from SessionStart hook)
CURRENT_SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
```

### Step 3: Apply Decision Matrix

```bash
if [ "$LOCK_SESSION" = "missing" ] || [ -z "$LOCK_SESSION" ]; then
  echo "WARNING: Task exists but has no session_id"
  echo "SELECT A DIFFERENT TASK - cannot determine owner, treat as owned"
  # DO NOT PROCEED - another instance may own this task

elif [ "$LOCK_SESSION" != "$CURRENT_SESSION_ID" ]; then
  echo "ERROR: Task owned by different session: $LOCK_SESSION"
  echo "SELECT A DIFFERENT TASK - this one is taken"
  # MUST NOT work on this task

else
  echo "SUCCESS: Task owned by current session - can resume"
  # SAFE to continue working on this task
fi
```

## Decision Matrix

| task.json exists? | Has session_id? | Matches current? | Action |
|-------------------|-----------------|------------------|--------|
| NO | N/A | N/A | **PROCEED** - Create new task.json with YOUR session_id |
| YES | NO | N/A | **SELECT DIFFERENT TASK** - Cannot determine owner, treat as owned |
| YES | YES | NO | **SELECT DIFFERENT TASK** - Another instance owns this |
| YES | YES | YES | **RESUME** - Continue your previous work |

**CRITICAL**: Never offer to take over a task from a different session. Just select a different task.
Only take over if the user explicitly requests it.

## Complete Verification Script

```bash
#!/bin/bash
set -euo pipefail

TASK_NAME="${1:?Task name required}"
CURRENT_SESSION_ID="${2:-${CLAUDE_SESSION_ID:-unknown}}"
TASK_DIR="/workspace/tasks/$TASK_NAME"

echo "=== Verifying Task Ownership ==="
echo "Task: $TASK_NAME"
echo "Current Session: $CURRENT_SESSION_ID"

# Step 1: Check if task exists
if [ ! -d "$TASK_DIR" ]; then
  echo ""
  echo "Result: PROCEED"
  echo "Task directory doesn't exist. Safe to create new task with task-init."
  exit 0
fi

# Step 2: Check task.json
if [ ! -f "$TASK_DIR/task.json" ]; then
  echo ""
  echo "Result: SELECT_DIFFERENT_TASK"
  echo "Task directory exists but no task.json found."
  echo "Another instance may have partially created this task."
  exit 1
fi

# Step 3: Get ownership info
LOCK_SESSION=$(jq -r '.session_id // "missing"' "$TASK_DIR/task.json" 2>/dev/null)
TASK_STATE=$(jq -r '.state // "unknown"' "$TASK_DIR/task.json" 2>/dev/null)

echo "Task State: $TASK_STATE"
echo "Task Owner: $LOCK_SESSION"

# Step 4: Apply decision matrix
if [ "$LOCK_SESSION" = "missing" ] || [ -z "$LOCK_SESSION" ]; then
  echo ""
  echo "Result: SELECT_DIFFERENT_TASK"
  echo "Task exists but has no session_id - cannot determine owner."
  echo "Treat as owned by another instance. Select a different task."
  exit 1

elif [ "$LOCK_SESSION" != "$CURRENT_SESSION_ID" ]; then
  echo ""
  echo "Result: SELECT_DIFFERENT_TASK"
  echo "Task is owned by a different Claude instance."
  echo "Owner session: $LOCK_SESSION"
  echo "Your session: $CURRENT_SESSION_ID"
  echo "Choose a different task to work on."
  exit 2

else
  echo ""
  echo "Result: RESUME"
  echo "Task is owned by current session."
  echo "Safe to resume work on this task."
  exit 0
fi
```

## Ownership Verification is a GATE {#ownership-gate}

**CRITICAL**: Ownership verification is a **gate** that controls whether ANY further work on that task
should occur. Once mismatch is detected, STOP IMMEDIATELY.

### ⚠️ Mismatch Detected = STOP INVESTIGATING

When session ownership mismatch is detected:

1. **DO NOT** run `git log` to check pending commits
2. **DO NOT** run `git diff` to see what changes exist
3. **DO NOT** read task files to understand the task state
4. **DO NOT** investigate the task in any way

**IMMEDIATELY** select a different task. Never offer to take over - just move on.

**CRITICAL**: Never suggest taking over a task from a different session. Users must explicitly
request takeover if they want it. Claude should never offer this as an option.

**Why This Matters**: Offering takeover options wastes user time with unnecessary decisions and
may cause confusion about which session should own which task.

**Rationale**: Ownership verification is resource-efficient only if treated as a gate. The correct
response to a mismatch is always to select a different task, not to ask the user.

## Common Mistakes

### Mistake: Offering to Take Over

```
❌ WRONG:
"Session mismatch detected. This task is owned by a different session.

Would you like me to:
1. Take over this task anyway, OR
2. Work on a different task?"
[Wastes user time with unnecessary decision - just select a different task!]
```

```
✅ CORRECT:
"Task 'implement-feature' is owned by a different session. Selecting a different task..."
[Immediately moves to next available task without asking]
```

### Mistake: Continuing Investigation After Mismatch

```
❌ WRONG:
"Session mismatch detected. Let me check git log to see what commits are pending..."
[Runs git log, git diff, reads files]
"Now I understand the task state. Should I take it over?"
[Wasted investigation on a task you shouldn't work on]
```

```
✅ CORRECT:
"Task 'implement-feature' is owned by a different session. Moving on..."
[No investigation, immediately selects different task]
```

### Mistake: Taking Over Another Instance's Task

```
❌ WRONG:
"I see task implement-feature is in AWAITING_USER_APPROVAL state.
Let me present it for approval..."
[But this task was created by a different Claude instance!]
```

```
✅ CORRECT:
"I see task implement-feature exists. Let me verify ownership..."
[Runs verification]
"This task is owned by session abc-123, but my session is xyz-789.
I'll select a different task to work on."
```

### Mistake: Not Recording Session ID

When creating tasks, ALWAYS include session_id:

```json
{
  "task_name": "implement-feature",
  "session_id": "your-session-id-here",  // ← REQUIRED
  "state": "INIT",
  "created": "2025-12-04T15:00:00Z"
}
```

## Integration with task-init

The task-init skill accepts session_id as 3rd parameter:

```bash
/workspace/main/.claude/scripts/task-init.sh "$TASK_NAME" "$DESCRIPTION" "$SESSION_ID"
```

This ensures new tasks are properly tagged with ownership information.

## Workflow Integration

```
[Session starts]
        ↓
[Receive task assignment]
        ↓
[Check if task directory exists]
        ↓
    ┌───┴───────────────────┐
    │ NO                    │ YES
    ↓                       ↓
[Use task-init          [Invoke verify-task-ownership skill]
 with session_id]               ↓
    │               ┌───────────┴───────────┐
    │               │                       │
    │          RESUME (yours)          DIFFERENT OWNER
    │               ↓                       ↓
    │        [Continue work]         [Select different task]
    ↓               ↓                       ↓
[Work on task]  [Work on task]      [Back to task selection]
```

## Related Skills

- **task-init**: Creates new tasks with session_id ownership tracking
- **state-transition**: Manages task state changes (respects ownership)

## Environment Variables

- `CLAUDE_SESSION_ID`: Current session identifier (set by SessionStart hook)

## Troubleshooting

### "No session_id in task.json"

Task was created before ownership tracking was added. Treat as owned by another instance
and select a different task. Only take over if user explicitly requests it.

### "Session ID is 'unknown'"

Your session ID wasn't properly set. Check:
1. SessionStart hook ran successfully
2. `CLAUDE_SESSION_ID` environment variable is set
3. Session ID was passed to verify script

### Multiple Instances Want Same Task

This is expected behavior! The ownership system ensures only one instance
works on each task. Other instances should select different tasks from
todo.md or wait for the current owner to complete.
