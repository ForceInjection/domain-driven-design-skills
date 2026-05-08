---
name: vault-tasks
description: Get all tasks from the vault with filtering options. Triggers on "all tasks", "task list", "show tasks", "find tasks".
auto_trigger: true
trigger_keywords:
  - "all tasks"
  - "task list"
  - "show tasks"
  - "find tasks"
  - "open tasks"
  - "completed tasks"
  - "list tasks"
  - "tasks in"
  - "todos"
  - "to-do list"
  - "what needs doing"
  - "open items"
  - "pending tasks"
  - "checklist"
  - "things to do"
  - "work items"
allowed-tools: mcp__flywheel__get_all_tasks
---

# Vault Task List

Get all tasks from your vault with filtering options.

## When to Use

Invoke when you want to:
- See all open tasks across the vault
- Filter tasks by folder, tag, or status
- Quick task overview when outside Obsidian
- Complement Dataview task queries

## Arguments

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `status` | No | "all" | Filter: "open", "completed", "cancelled", "all" |
| `folder` | No | - | Limit to notes in this folder |
| `tag` | No | - | Filter to tasks with this tag |
| `limit` | No | 100 | Maximum tasks to return |

## Process

### 1. Parse User Input

Identify filter criteria:
- "show all open tasks"
- "tasks in the projects/ folder"
- "completed tasks with #urgent tag"
- "list tasks from work notes"

### 2. Call MCP Tool

```
mcp__flywheel__get_all_tasks(
  status: "open",
  folder: "projects/",
  tag: "#urgent",
  limit: 50
)
```

### 3. Format Results

**Tasks Found:**
```
Vault Tasks
=================================================

Filter: open tasks in projects/
Found: 23 tasks

-------------------------------------------------

High Priority (5):

  ☐ Complete API documentation
    📍 projects/Alpha.md (line 45)
    📅 Due: 2026-01-05
    🏷️ #urgent

  ☐ Review pull request #123
    📍 projects/Beta.md (line 23)
    📅 Due: 2026-01-02
    🏷️ #review

  ☐ Fix authentication bug
    📍 projects/Alpha.md (line 67)
    🏷️ #bug

  ... and 2 more

-------------------------------------------------

Normal Priority (18):

  ☐ Update README with new features
    📍 projects/Alpha.md (line 89)
    🏷️ #docs

  ☐ Add unit tests for UserService
    📍 projects/Beta.md (line 56)
    🏷️ #testing

  ☐ Refactor database queries
    📍 projects/Gamma.md (line 34)

  ... and 15 more

-------------------------------------------------

Summary:
  Open: 23 tasks
  With due dates: 8 tasks
  Overdue: 2 tasks
  Tagged: 23 tasks

=================================================
```

**By Status:**
```
Vault Tasks
=================================================

Status breakdown (all tasks):

  Open:       23 tasks
  Completed:  156 tasks
  Cancelled:   4 tasks
  ────────────────────
  Total:      183 tasks

Completion rate: 85%

Recent completions (last 7 days):
  ✓ Deploy v2.0 to production (2025-12-30)
  ✓ Write architecture document (2025-12-29)
  ✓ Review team feedback (2025-12-28)
  ... and 12 more

=================================================
```

## Relationship to Dataview

| Tool | Use Case | When |
|------|----------|------|
| **Dataview (Obsidian)** | Rich queries, live views | In Obsidian |
| **vault-tasks (Claude)** | Quick overview, CLI access | Outside Obsidian |

This skill **complements** your Dataview workflow:
- Use when chatting with Claude about tasks
- Quick checks without opening Obsidian
- Cross-reference with other Claude tools

## Task Syntax Supported

The skill recognizes Obsidian checkbox syntax:
- `- [ ]` Open task
- `- [x]` Completed task
- `- [-]` Cancelled task
- `- [/]` In progress (treated as open)

Due date formats:
- `📅 2026-01-05` (emoji format)
- `due: 2026-01-05` (text format)
- `[due:: 2026-01-05]` (Dataview format)

## Use Cases

- **Morning check**: "What tasks are open?"
- **Folder focus**: "Tasks in my work/ folder"
- **Tag filter**: "Show #urgent tasks"
- **Progress tracking**: "How many tasks completed this week?"

## Integration

Works well with other skills:
- **vault-due**: Focus on deadline-based view
- **task-add**: Add new tasks to daily notes
- **vault-search**: Find notes by task status
- **vault-activity**: Correlate tasks with activity

---

**Version:** 1.0.0
