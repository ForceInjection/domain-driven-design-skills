---
name: obsidian-tasks
description: Manage tasks in the Obsidian vault - add, complete, reorder tasks
---

# Obsidian Task Management

Manage tasks in `~/dev/personal/obsidian/trobrock/Tasks.md`.

## Task File

Location: `~/dev/personal/obsidian/trobrock/Tasks.md`

Simple ordered list - position indicates priority (top = most important).

## Task Syntax

```markdown
- [ ] Incomplete task
- [x] Completed task
```

## Operations

### Add a Task

Append to the list:
```markdown
- [ ] {task description}
```

Or insert at a specific position if priority matters.

### Complete a Task

Change `- [ ]` to `- [x]`:
```markdown
- [x] Completed task
```

### Reorder Tasks

Move lines up or down to change priority. Top of list = highest priority.

### Remove Completed Tasks

Periodically delete `- [x]` lines to keep the list clean.

### Link to Projects

Optional - link tasks to projects:
```markdown
- [ ] Fix bug [[Comfortly]]
```

## Keep It Simple

- One flat list
- Order = priority
- Complete or delete when done
- No categories, tags, or dates required
