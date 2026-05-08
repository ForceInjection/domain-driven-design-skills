---
name: tk-workflow
description: Show the Tasuku task workflow guide. Use when user says /tk:workflow or asks how to use Tasuku, task workflow, or needs help with task management.
---

# Tasuku Workflow Guide

Tasuku is an agent-first task management system. Here's how to use it effectively.

## Task Lifecycle

```
ready → in_progress → done
          ↓
       blocked → (unblock) → ready
```

## Common Operations

### Starting Work
```
1. tk_list status=ready     # See what's available
2. tk_start id=task-id      # Claim the task
3. tk_timer_start id=task-id # Optional: track time
```

### Finishing Work
```
1. tk_timer_stop id=task-id  # Stop timer if running
2. tk_done id=task-id        # Mark complete
3. tk_note task_id note="What was done"  # Optional: add notes
```

### When Blocked
```
1. tk_block id=task-id blocked_by=["other-task"]
2. Work on something else from ready queue
3. tk_unblock id=task-id  # When blocker is resolved
```

### Recording Context
```
tk_learn insight="Important discovery"   # Save learnings
tk_decide id=name chose=X over=[Y,Z] because="reason"  # Document decisions
tk_note task_id=id note="Details"        # Add task notes
```

## Multi-Agent Coordination

When multiple agents work in parallel:
```
tk_claim id=task-id agent=my-name   # Exclusive claim
tk_release id=task-id               # Release when done
```

Claims expire after 2 hours if not renewed.

## Best Practices

1. **Keep tasks small** - One task = one PR
2. **Update status immediately** - Don't batch updates
3. **Record learnings** - Future sessions benefit
4. **Document decisions** - Capture the "why"
5. **Use priorities** - Critical (0) to Backlog (4)
