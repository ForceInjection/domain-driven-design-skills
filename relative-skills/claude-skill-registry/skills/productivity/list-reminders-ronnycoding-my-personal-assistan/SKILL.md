---
name: list-reminders
description: List tasks from macOS Reminders app, organized by priority and due date. Use when the user asks about their to-do list, tasks, reminders, or what they need to work on. Returns tasks categorized by status, priority, and list.
allowed-tools: Bash
---

# List Reminders

Retrieves and organizes tasks from macOS Reminders for daily planning and task management.

## When to Use

- "What's on my to-do list?"
- "Show me my tasks for today"
- "What reminders do I have?"
- "Any overdue tasks?"
- "What do I need to work on?"

## Instructions

### Execute Reminders List

```bash
osascript .claude/skills/list-reminders/scripts/list_tasks.scpt
```

### Present Results

Organize tasks by:
1. **Overdue** (highest priority)
2. **Today**
3. **Upcoming**
4. **By List** (Work, Personal, etc.)

Format clearly with priorities and due dates.

For examples, see [examples.md](examples.md).
