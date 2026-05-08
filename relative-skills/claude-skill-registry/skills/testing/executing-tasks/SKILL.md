---
name: executing-tasks
description: >-
  Use when working through any task checklist (not just OpenSpec). Complete one
  task, verify, mark done, then next. No skipping, no adding, no reordering.
---

# Executing Tasks

Work through task lists systematically.

> **Announce:** "I'm using executing-tasks to work through this checklist systematically."

## Iron Law

```
ONE TASK AT A TIME - VERIFY BEFORE MOVING ON
```

## Process

### Step 1: Identify Current Task

Find the first incomplete task:
```
- [x] Completed task
- [x] Completed task
- [ ] ← THIS ONE (current)
- [ ] Pending task
```

### Step 2: Announce

```
Working on: [Task description]
```

### Step 3: Execute

Do EXACTLY what the task says:
- If it says "create file X" → create file X
- If it says "add function Y" → add function Y
- If it says "run command Z" → run command Z

Do NOT:
- Add things the task didn't ask for
- Skip steps you think are unnecessary
- Combine with other tasks
- "Improve" the approach

### Step 4: Verify

Run any verification specified in the task.

If no verification specified, at minimum:
- Did I do what the task asked?
- Did I break anything else?

### Step 5: Mark Complete

Update the task list: `- [ ]` → `- [x]`

### Step 6: Report

```
Completed: [Task description]
Result: [Brief outcome]
Next: [Next task] or "All tasks complete"
```

### Step 7: Repeat

Go to Step 1 for next task.

## Handling Blockers

If a task cannot be completed:

```
BLOCKED: [Task description]
Reason: [Why it can't be done]
Options:
1. [Possible resolution]
2. [Alternative approach]
3. Skip and continue (if independent)

Awaiting guidance.
```

Do NOT:
- Guess at the solution
- Skip without reporting
- Change the task scope

## Task Dependencies

If tasks have dependencies:

```
- [ ] 1.1 Create database table
- [ ] 1.2 Add RLS policy (depends on 1.1)
- [ ] 2.1 Create frontend component (independent)
```

- Complete dependencies first
- Independent tasks can be done in any order
- If blocked by dependency, report it

## Progress Tracking

Keep a running count:
```
Progress: 3/10 tasks complete
Current: Task 1.4
```

## Completion

When all tasks are `[x]`:

```
All tasks complete: [X/X]

Summary:
- [Category]: [What was done]
- [Category]: [What was done]

Verification:
- [What was verified]

Ready for: [Next step - usually review]
```

## Red Flags - STOP

If you catch yourself:
- Working on multiple tasks at once
- Skipping "obvious" tasks
- Adding unrequested work
- Not verifying before marking complete

STOP. One task. Verify. Mark complete. Next.
