---
name: tk-stats
description: Show project task statistics and progress. Use when user says /tk:stats or asks about progress, how many tasks, completion rate, or project status.
---

# Show Task Statistics

Display progress statistics for the current project.

## Instructions

1. Use the `tk_context` MCP tool to get full project state
2. Calculate and display:
   - Total tasks by status (ready, in_progress, blocked, done)
   - Completion percentage
   - Number of learnings and decisions recorded
   - Any tasks with active timers

## Output Format

```
## Project Progress

**Completion:** X/Y tasks done (Z%)

| Status      | Count |
|-------------|-------|
| Done        | X     |
| In Progress | X     |
| Ready       | X     |
| Blocked     | X     |

**Context:**
- X learnings recorded
- X decisions documented
- X tasks have notes

**Active Timers:** (if any)
- [task-id]: running for Xh Xm
```

## Notes

- If completion is high (>80%), congratulate progress
- If many tasks are blocked, highlight the blockers
- Show time spent if tasks have duration tracked
