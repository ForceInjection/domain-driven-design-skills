---
name: board
description: "Task board for agents. Track work, manage cards across lists."
allowed-tools: mcp__board__board_list, mcp__board__board_add, mcp__board__board_update, mcp__board__board_move, mcp__board__board_delete, mcp__board__board_get
---

# board

**Trello-like task board designed for AI agents. Structured JSON output, not human markdown.**

## Why This Exists

Agents need to track complex work that spans multiple steps. The board provides:
- Persistent state across sessions
- Organized workflow (backlog → todo → in_progress → done)
- Priority tracking
- Labels for categorization

## Quick Reference

| Task | Tool | Example |
|------|------|---------|
| See board | `board_list` | `board_list({})` |
| Create card | `board_add` | `board_add({ title: "Fix bug" })` |
| Update card | `board_update` | `board_update({ id, priority: "high" })` |
| Move card | `board_move` | `board_move({ id, list: "done" })` |
| Delete card | `board_delete` | `board_delete({ id })` |
| Get details | `board_get` | `board_get({ id })` |

## Default Lists

| List | Purpose |
|------|---------|
| `backlog` | Ideas, future work |
| `todo` | Planned for current session |
| `in_progress` | Currently working on |
| `blocked` | Waiting on something |
| `done` | Completed |

## Priorities

- `low` - Nice to have
- `medium` - Normal priority (default)
- `high` - Important
- `critical` - Urgent

## Typical Workflow

### Starting Work
```
board_list({})                    // See current state
board_add({ title: "Task 1" })    // Add new card
board_move({ id, list: "todo" })  // Move to todo
```

### During Work
```
board_move({ id, list: "in_progress" })  // Start working
board_update({ id, labels: ["bug"] })    // Add context
board_move({ id, list: "done" })         // Complete
```

### Filtering
```
board_list({ list: "in_progress" })      // Current work only
board_list({ priority: "high" })         // High priority
board_list({ labels: ["bug"] })          // Bugs only
board_list({ search: "auth" })           // Search text
```

## Output Format

All tools return structured JSON:
```json
{
  "board": "Board",
  "lists": [{ "id": "todo", "name": "To Do", "cardCount": 3 }],
  "cards": [{ "id": "...", "title": "...", "list": "...", "priority": "..." }],
  "total": 3
}
```

## Storage

Data persists in `.board/board.json` in the project root.
