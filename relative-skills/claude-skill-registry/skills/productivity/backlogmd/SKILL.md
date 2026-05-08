---
name: backlog.md
description: Manage backlog tasks using the Backlog.md CLI. Use for creating, editing, viewing, and searching tasks in your backlog.
---

# Backlog.md CLI Skill

You are a Backlog.md CLI expert assistant.

## Task Management Commands

### Create Task

```bash
backlog task create "Title" -d "Description" --ac "Criterion 1" --ac "Criterion 2"
```

- Multiple `--ac` flags for acceptance criteria
- Use `--draft` for draft tasks
- Use `-p <parent-id>` for subtasks
- Include JIRA ticket in title: `"[PROJ-123] Task description"`

### View Task

```bash
backlog task 42 --plain
```

- Always use `--plain` flag for AI-friendly output
- Shows all task details, ACs, plan, notes

### Edit Task Metadata

```bash
backlog task edit 42 -s "In Progress" -a @myself
backlog task edit 42 -t "New Title" -l backend,api --priority high
```

- `-s, --status` - Change status ("To Do", "In Progress", "Done")
- `-a, --assignee` - Assign to user
- `-t, --title` - Update title
- `-l, --labels` - Set labels (comma-separated)
- `--priority` - Set priority (low/medium/high)

### Manage Acceptance Criteria

```bash
# Add multiple ACs
backlog task edit 42 --ac "New criterion" --ac "Another one"

# Check ACs (mark complete)
backlog task edit 42 --check-ac 1 --check-ac 2

# Uncheck AC
backlog task edit 42 --uncheck-ac 3

# Remove AC
backlog task edit 42 --remove-ac 4
```

### Add Implementation Content

```bash
# Add plan (use ANSI-C quoting for newlines)
backlog task edit 42 --plan $'1. Research\n2. Implement\n3. Test'

# Add notes (PR description)
backlog task edit 42 --notes $'Implemented X\nUpdated tests'

# Append to notes
backlog task edit 42 --append-notes $'- Fixed bug\n- Added validation'
```

## Searching & Listing

### Search Tasks

```bash
backlog search "keyword" --plain
backlog search "auth" --type task --status "To Do" --plain
```

### List Tasks

```bash
backlog task list --plain
backlog task list -s "In Progress" -a @myself --plain
backlog task list --priority high --plain
```

## Typical Implementation Workflow

```bash
# 1. Find work
backlog task list -s "To Do" --plain

# 2. Start work
backlog task edit 42 -s "In Progress" -a @myself

# 3. Add plan
backlog task edit 42 --plan $'1. Analyze\n2. Implement\n3. Test'

# 4. Mark ACs complete as you work
backlog task edit 42 --check-ac 1 --check-ac 2

# 5. Add implementation notes
backlog task edit 42 --notes $'Implemented using pattern X\nUpdated files Y and Z'

# 6. Mark done
backlog task edit 42 -s Done
```

## Usage Guidelines

1. **Always use `--plain` flag** when viewing/listing tasks for AI-readable output
2. **Never edit task files directly** - Always use CLI commands
3. **Use ANSI-C quoting** (`$'...\n...'`) for multi-line content (plan, notes, description)
4. **Include JIRA ticket** in title when applicable: `[TICKET-123] Description`
5. **Mark ACs complete** as you work through them
6. **Start work properly**: Set status "In Progress" and assign to yourself first

## Error Handling

- Check task exists: `backlog task 42 --plain`
- List all tasks if ID unknown: `backlog task list --plain`
- Use search for keywords: `backlog search "topic" --plain`
- For AC operations, verify AC index with `backlog task 42 --plain`

Full help: `backlog --help`
