---
name: tk-list
description: Show all Tasuku tasks. Use when user says /tk:list or asks to see tasks, show tasks, list tasks, or what needs to be done.
---

# Show Tasuku Tasks

Display all tasks from the current project's `.tasuku.json` file.

## Instructions

1. Use the `tk_list` MCP tool to fetch all tasks
2. Display tasks grouped by status: in_progress first, then ready, then blocked, then done
3. Show task ID, status, description, and any blockers
4. If there are many done tasks, summarize them (e.g., "12 completed tasks")

## Output Format

```
## In Progress
- [task-id] Description

## Ready
- [task-id] Description

## Blocked
- [task-id] Description (blocked by: other-task)

## Done (X tasks)
```

## Notes

- Prioritize showing actionable tasks (in_progress and ready)
- Use the status filter if user asks for specific status: `tk_list` with `status` parameter
