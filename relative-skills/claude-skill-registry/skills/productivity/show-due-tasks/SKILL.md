---
name: vault-due
description: Get tasks sorted by due date, focusing on upcoming deadlines. Triggers on "due tasks", "upcoming deadlines", "what's due", "deadlines".
auto_trigger: true
trigger_keywords:
  - "due tasks"
  - "upcoming deadlines"
  - "what's due"
  - "deadlines"
  - "due dates"
  - "tasks due"
  - "overdue"
  - "due this week"
  - "what's coming up"
  - "calendar"
  - "schedule"
  - "approaching deadlines"
  - "due soon"
  - "upcoming"
  - "deadline calendar"
  - "when due"
allowed-tools: mcp__flywheel__get_tasks_with_due_dates
---

# Due Date Task View

Get tasks sorted by due date for deadline-focused planning.

## When to Use

Invoke when you want to:
- See what's due today/this week
- Identify overdue tasks
- Plan upcoming work by deadline
- Quick deadline check without Obsidian

## Arguments

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `status` | No | "open" | Filter: "open", "completed", "cancelled", "all" |
| `folder` | No | - | Limit to notes in this folder |

## Process

### 1. Parse User Input

Identify deadline focus:
- "what's due this week?"
- "show overdue tasks"
- "upcoming deadlines in projects/"
- "tasks due today"

### 2. Call MCP Tool

```
mcp__flywheel__get_tasks_with_due_dates(
  status: "open",
  folder: null
)
```

### 3. Format Results

```
Due Date Task View
=================================================

Today: 2026-01-01 (Wednesday)

-------------------------------------------------

🔴 OVERDUE (2 tasks):

  ☐ Submit quarterly report
    📍 work/reports/Q4.md (line 23)
    📅 Due: 2025-12-31 (1 day overdue)
    🏷️ #report

  ☐ Review contractor invoices
    📍 work/admin/Invoices.md (line 12)
    📅 Due: 2025-12-30 (2 days overdue)

-------------------------------------------------

🟡 DUE TODAY (1 task):

  ☐ New Year planning session
    📍 personal/goals/2026.md (line 8)
    📅 Due: 2026-01-01
    🏷️ #planning

-------------------------------------------------

🟢 THIS WEEK (5 tasks):

  Thu 01/02:
    ☐ Review pull request #123
      📍 projects/Beta.md (line 23)
      🏷️ #review

  Fri 01/03:
    ☐ Deploy v2.1 to staging
      📍 projects/Alpha.md (line 45)
      🏷️ #deploy

  Sat 01/04:
    (no tasks)

  Sun 01/05:
    ☐ Complete API documentation
      📍 projects/Alpha.md (line 67)
      🏷️ #docs

    ☐ Weekly review
      📍 personal/routines/Weekly.md (line 5)

    ☐ Backup important files
      📍 personal/routines/Weekly.md (line 8)

-------------------------------------------------

📅 NEXT WEEK (3 tasks):

  Mon 01/06:
    ☐ Team sync meeting prep
      📍 work/meetings/Team-Sync.md (line 12)

  Wed 01/08:
    ☐ Architecture review
      📍 projects/Gamma.md (line 34)

  Fri 01/10:
    ☐ Sprint retrospective
      📍 work/agile/Sprint-23.md (line 56)

-------------------------------------------------

Summary:
  🔴 Overdue: 2 tasks (action needed!)
  🟡 Today: 1 task
  🟢 This week: 5 tasks
  📅 Next week: 3 tasks

  Total with due dates: 11 open tasks

=================================================
```

**No Due Dates:**
```
Due Date Task View
=================================================

Today: 2026-01-01

No tasks with due dates found.

You have 23 open tasks without due dates.
Use /vault-tasks to see all tasks.

Tip: Add due dates to tasks:
  - [ ] Task description 📅 2026-01-15
  - [ ] Task description [due:: 2026-01-15]

=================================================
```

## Due Date Formatting

Recognized formats:
- `📅 2026-01-05` - Emoji format (recommended)
- `due: 2026-01-05` - Text format
- `[due:: 2026-01-05]` - Dataview inline format
- `(due 2026-01-05)` - Parenthetical format

## Use Cases

- **Morning planning**: "What's due today?"
- **Week preview**: "Upcoming deadlines"
- **Overdue check**: "Am I behind on anything?"
- **Sprint planning**: "What's due this sprint?"

## Integration

Works well with other skills:
- **vault-tasks**: Full task list without date focus
- **task-add**: Add tasks with due dates
- **vault-activity**: Correlate completions with activity
- **vault-concurrent**: See what else you worked on around deadlines

---

**Version:** 1.0.0
