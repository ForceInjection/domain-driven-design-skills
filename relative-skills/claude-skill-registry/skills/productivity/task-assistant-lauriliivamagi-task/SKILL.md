---
name: task-assistant
description: "Intelligent task management via the `task` CLI. Invoke when users ask to: create/list/update/delete tasks, search tasks (text or semantic), track work items with due dates, organize tasks into projects, run batch operations, generate activity reports, or manage recurring tasks. Supports natural language dates and Google Calendar sync."
---

# Task Assistant

## Overview

This skill enables task management via the `task` CLI tool backed by SQLite with
vector search. Use this skill to create, track, update, and organize tasks
during coding sessions.

## Quick Start

```bash
# Create a task
task add "Implement authentication" --project Backend -d "next friday"

# Create a task with tags
task add "Fix login bug" --tag bug --tag auth

# List tasks
task list                              # Active tasks
task list -q "auth"                    # Text search
task list --tag bug                    # Filter by tag
task list --semantic "API integration" # Semantic search

# Update task
task update 1 --status done

# View details
task view 1
```

## Core Operations

### Creating Tasks

```bash
# Basic task
task add "Task title" "Optional description"

# With project and due date (supports datetime)
task add "Review PR" --project Work -d "tomorrow at 14:00"

# As subtask
task add "Write tests" --parent 5

# Output JSON for programmatic use
task add "Deploy fix" --json
```

### Listing and Searching

```bash
task list                           # Active (non-done) tasks
task list --all                     # Include completed
task list -q "search term"          # Text search
task list --semantic "bug fixes"    # AI-powered similarity search
task list --overdue                 # Past due date
task list --status in-progress      # Filter by status
task list --priority 2              # Filter by priority (0=normal, 1=high, 2=urgent)
task list --project "Backend"       # Filter by project
```

### Updating Tasks

```bash
task update <id> --status done        # Mark complete
task update <id> --status in-progress # Start working
task update <id> --priority 2         # Set urgent
task update <id> --due "2025-12-31T14:00:00Z"  # Change due date
task update <id> --title "New title"  # Change title
task update <id> -D "New description" # Change description
task update <id> --project "Work"     # Move to project
task update <id> --clear-project      # Remove from project
```

### Comments and Attachments

```bash
task comment <id> "Progress note here"
task attach <id> ./relevant-file.pdf
```

### Batch Operations

```bash
# Batch create from JSON file
task batch-add --file tasks.json

# Bulk update multiple tasks
task bulk update 1 2 3 --status done

# Bulk delete
task bulk delete 4 5 6 --yes
```

### Tag Management

```bash
task tag list                      # List all tags with usage counts
task tag add <id> bug priority     # Add tags to a task
task tag remove <id> bug           # Remove tag from task
```

## Additional Resources

- **For setup instructions** (semantic search, Google Calendar): Read
  `references/setup_guide.md`
- **For advanced features** (recurring tasks, reports, workspaces,
  multi-database): Read `references/advanced_features.md`
- **For TUI keyboard shortcuts**: Read `references/tui_reference.md`
- **For complete API reference**: Read `references/api_reference.md`
