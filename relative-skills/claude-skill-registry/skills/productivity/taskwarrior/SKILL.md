---
name: taskwarrior
description: Manage tasks using taskwarrior CLI. Use this when the user wants to add, list, complete, modify, delete, or search tasks, set priorities, due dates, tags, or work with task contexts and reports.
allowed-tools: Bash
---

# Taskwarrior Task Management

You are helping the user manage their tasks using taskwarrior (the `task` command).

## Core Principles

1. Always show the user what commands you're running
2. Display task output clearly so the user can see their tasks
3. Use taskwarrior's built-in formatting - don't try to reformat the output
4. Confirm successful operations with the user

## Common Operations

### Adding Tasks

```bash
# Basic task
task add "Task description"

# With priority (H=High, M=Medium, L=Low)
task add "Important task" priority:H

# With due date
task add "Task with deadline" due:tomorrow
task add "Task with deadline" due:2025-12-31
task add "Task with deadline" due:eom  # end of month

# With project
task add "Task in project" project:work

# With tags
task add "Task with tags" +bug +urgent

# Combined
task add "Complete report" project:work priority:H due:friday +report
```

### Listing Tasks

```bash
# List all pending tasks
task list

# List all tasks (including completed)
task all

# Filter by project
task project:work list

# Filter by tag
task +urgent list

# Filter by status
task status:pending list
task status:completed list

# Next most important task
task next

# Custom reports
task overdue
task waiting
task blocked
```

### Completing Tasks

```bash
# Complete by ID
task 5 done

# Complete multiple tasks
task 5,7,9 done
```

### Modifying Tasks

```bash
# Modify description
task 5 modify "New description"

# Add/change priority
task 5 modify priority:H

# Add/change due date
task 5 modify due:tomorrow

# Add to project
task 5 modify project:work

# Add tags
task 5 modify +urgent +bug

# Remove tags
task 5 modify -urgent
```

### Deleting and Managing

```bash
# Delete a task
task 5 delete

# Start/stop a task (time tracking)
task 5 start
task 5 stop

# Annotate a task (add notes)
task 5 annotate "This is a note"

# Set task as waiting
task 5 modify wait:tomorrow
```

### Searching and Filtering

```bash
# Search descriptions
task /keyword/ list

# Complex filters
task project:work and +urgent list
task due.before:eow list  # end of week
task priority:H list
```

### Context Management

```bash
# Define a context (filter preset)
task context define work project:work

# List contexts
task context list

# Set active context
task context work

# Clear context
task context none

# Show current context
task context show
```

### Information and Reports

```bash
# Show task details
task 5 info

# Show summary
task summary

# Show burndown
task burndown.daily

# Show statistics
task stats
```

## Best Practices

1. **IDs change**: Task IDs can change as tasks are completed/deleted. Always list tasks first to get current IDs.

2. **Confirm before bulk operations**: When deleting or modifying multiple tasks, show the user what will be affected first.

3. **Use filters wisely**: Help users create effective filters to find tasks quickly.

4. **Contexts are powerful**: Suggest setting up contexts for common work modes (work, personal, urgent, etc.).

5. **Date helpers**: Taskwarrior supports many date formats:
   - `today`, `tomorrow`, `yesterday`
   - `eow`, `eom`, `eoq`, `eoy` (end of week/month/quarter/year)
   - `soww`, `somw` (start of work week/month)
   - Relative: `5days`, `2weeks`, `1month`
   - ISO format: `2025-12-31`

## Error Handling

- If a command fails, explain why and suggest corrections
- If no tasks match a filter, let the user know
- If task IDs are invalid, list current tasks to help the user find the right ID

## Example Workflow

When the user asks to manage tasks:

1. Show them their current tasks first (if relevant)
2. Execute their requested operation
3. Show the updated state
4. Confirm success

Example:
```
User: "Add a high priority task to fix the login bug"
1. Run: task add "Fix login bug" priority:H +bug
2. Show the output (new task created)
3. Optionally run: task list to show the updated list
```
