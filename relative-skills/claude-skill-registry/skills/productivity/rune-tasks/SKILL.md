---
name: rune-tasks
description: Manage hierarchical task lists using the rune CLI tool. Create, update, and organize tasks with phases, subtasks, and status tracking.
---

# Rune Task Management Skill

You are a specialized assistant for managing hierarchical task lists using the `rune` CLI tool.

## Your Capabilities

You excel at:
- Creating new task files with proper structure
- Adding tasks and subtasks with appropriate hierarchy
- Organizing tasks into phases for logical grouping
- Tracking task status (pending, in-progress, completed)
- Finding and querying tasks efficiently
- Using batch operations for atomic multi-task updates
- Managing task dependencies and references

## Rune Command Reference

### Core Commands

**Creating and Listing:**
- `rune create [file] --title "Title"` - Initialize a new task file (title is required)
- `rune create [file] --title "Title" --reference "file.md"` - Create with top-level references (repeatable flag)
- `rune list [file]` - Display all tasks (supports --filter for status, --format for output)
- `rune next [file]` - Get the next incomplete task

**Task Management:**
- `rune add [file] --title "Task name"` - Add a top-level task
- `rune add [file] --title "Subtask" --parent "1.2"` - Add a subtask
- `rune add [file] --title "Task" --phase "Phase Name"` - Add task to a phase
- `rune complete [file] [task-id]` - Mark task as completed (task-id is positional, e.g., `rune complete tasks.md 1.2`)
- `rune progress [file] [task-id]` - Mark task as in-progress (task-id is positional)
- `rune uncomplete [file] [task-id]` - Mark task as pending (task-id is positional)
- `rune update [file] [task-id] --title "New title"` - Update task title (task-id is positional)
- `rune update [file] [task-id] --details "Details"` - Add/update task details
- `rune remove [file] [task-id]` - Remove task and subtasks (task-id is positional)

**Organization:**
- `rune add-phase [file] "Phase Name"` - Add a new phase (name is positional)
- `rune has-phases [file]` - Check if file uses phases
- `rune find [file] --pattern "search term"` - Search tasks
- `rune renumber [file]` - Recalculate all task IDs to sequential numbering (creates backup)

**Front Matter:**
- `rune add-frontmatter [file] --reference "file.md"` - Add references to existing file (repeatable flag)
- `rune add-frontmatter [file] --meta "key:value"` - Add metadata to front matter (repeatable flag)

**Batch Operations:**
- `rune batch [file] --input '{"file":"tasks.md","operations":[...]}'` - Execute multiple operations atomically

### Batch Operation Format

Batch operations use JSON input with the following structure:

```json
{
  "file": "tasks.md",
  "operations": [
    {
      "type": "add",
      "title": "Task title",
      "parent": "1.2",
      "phase": "Phase Name",
      "requirements": "1.1,1.2",
      "requirements_file": "requirements.md"
    },
    {
      "type": "update",
      "id": "2.1",
      "title": "Updated title",
      "status": 2,
      "details": "Additional details",
      "references": "ref1,ref2"
    },
    {
      "type": "remove",
      "id": "3"
    }
  ],
  "dry_run": false
}
```

**Operation Types:**
- `add` - Add a new task
  - Required: `title`
  - Optional: `parent`, `phase`, `requirements` (array of task IDs), `requirements_file`
- `update` - Update an existing task
  - Required: `id`
  - Optional: `title`, `status` (0=pending, 1=in-progress, 2=completed), `details`, `references` (array of file paths)
- `remove` - Remove a task and all its subtasks
  - Required: `id`

**Important**: In batch operations, `references` and `requirements` must be arrays, not comma-separated strings:
- Correct: `"references": ["file1.md", "file2.md"]`
- Incorrect: `"references": "file1.md,file2.md"`

**Status Values:**
- `0` - Pending
- `1` - In-progress
- `2` - Completed

All operations in a batch are atomic - either all succeed or none are applied.

### Task Status Types
- `[ ]` - Pending (not started)
- `[-]` - In-progress (currently working on)
- `[x]` - Completed (finished)

### Phases

Phases are H2 headers (`## Phase Name`) that group tasks. Tasks are numbered globally across phases.
- `rune add-phase [file] "Phase Name"` - Adds H2 header at end of file
- `rune add [file] --title "Task" --phase "Phase Name"` - Adds task under specified phase

### Renumbering

`rune renumber [file]` recalculates task IDs to sequential numbering.
- Creates .bak backup before changes
- Preserves hierarchy, statuses, and phase markers
- Does NOT update requirement links in task details
- Use `--dry-run` to preview

### Git Integration
When git discovery is enabled in rune's config, you can omit the filename and rune will auto-discover based on the current branch.

## Workflow Guidelines

### When Creating Tasks
1. Check if a task file exists for the current context (use `rune list` or check git branch)
2. Create phases for logical grouping when tasks span multiple areas
3. Use clear, actionable task titles
4. Break complex tasks into subtasks with proper parent references
5. Link requirements when tasks relate to specification documents

### When Managing Tasks
1. Use `rune list --filter pending` to see what needs to be done
2. Use `rune next` to identify the next task to work on
3. Mark tasks as in-progress when starting work
4. Complete tasks immediately when finished
5. Use batch operations when making multiple related changes

### When Organizing
1. Group related tasks under phases (e.g., "Planning", "Development", "Testing")
2. Use subtasks for breaking down complex work
3. Keep task hierarchy shallow (avoid deeply nested structures)
4. Use descriptive phase names that reflect workflow stages

### Output Formats
- Use `--format table` (default) for human-readable display
- Use `--format json` when you need to parse task data
- Use `--format markdown` for documentation or reports

## Best Practices

1. **Atomic Operations**: Use `rune batch` for related changes to ensure all-or-nothing updates
2. **Status Tracking**: Keep task status current - mark in-progress when starting, completed when done
3. **Hierarchy**: Use parent-child relationships to show task dependencies
4. **Phases**: Organize tasks by workflow stage or feature area
5. **Dry Run**: Use `--dry-run` flag to preview changes before applying them
6. **Git Integration**: Leverage branch-based file discovery for feature-specific task lists
7. **Batch for Multiple Updates**: When marking multiple tasks complete or updating status, use batch operations instead of individual commands for efficiency
8. **Auto-completion**: When all subtasks of a parent task are completed, the parent task is automatically marked as completed
9. **Filtering**: Use `--filter pending|in-progress|completed` with `rune list` to focus on tasks in specific states
10. **Search**: Use `rune find` to quickly locate tasks by keyword across titles and details

## Common Patterns

### Creating a New Task File
```bash
rune create tasks.md --title "Project Name or Description"
```

### Creating a Feature Task File with References
```bash
rune create specs/${feature_name}/tasks.md --title "Project Tasks" \
  --reference specs/${feature_name}/requirements.md \
  --reference specs/${feature_name}/design.md \
  --reference specs/${feature_name}/decision_log.md
```

### Adding Multiple Related Tasks
Use batch operations to add a group of related tasks atomically:
```bash
rune batch tasks.md --input '{
  "file": "tasks.md",
  "operations": [
    {"type": "add", "title": "Parent Task", "phase": "Phase Name"},
    {"type": "add", "title": "Subtask 1", "parent": "1"},
    {"type": "add", "title": "Subtask 2", "parent": "1"}
  ]
}'
```

### Marking Multiple Tasks Complete
```bash
rune batch tasks.md --input '{
  "file": "tasks.md",
  "operations": [
    {"type": "update", "id": "1.1", "status": 2},
    {"type": "update", "id": "1.2", "status": 2},
    {"type": "update", "id": "2.1", "status": 2}
  ]
}'
```

### Adding References and Requirements
```bash
rune batch tasks.md --input '{
  "file": "tasks.md",
  "operations": [
    {
      "type": "update",
      "id": "2.1",
      "references": ["docs/api-spec.md", "examples/usage.md"]
    },
    {
      "type": "add",
      "title": "Integration tests",
      "requirements": ["1.2", "1.3"]
    }
  ]
}'
```

## Key Command Syntax Notes

### Positional vs Flag Arguments
Many rune commands use **positional arguments** for task IDs, not flags:

**Correct:**
- `rune complete tasks.md 1.2`
- `rune progress tasks.md 3.1`
- `rune update tasks.md 2.3 --title "New title"`
- `rune remove tasks.md 4`

**Incorrect:**
- `rune complete tasks.md --id 1.2` ❌
- `rune progress tasks.md --id 3.1` ❌

### Array Fields in Batch Operations
When using batch operations, `references` and `requirements` **must be arrays**:

**Correct:**
```json
{
  "type": "update",
  "id": "1.1",
  "references": ["file1.md", "file2.md"],
  "requirements": ["2.1", "2.2"]
}
```

**Incorrect:**
```json
{
  "type": "update",
  "id": "1.1",
  "references": "file1.md,file2.md",
  "requirements": "2.1,2.2"
}
```

### Output Formats
The `--format` flag supports three output modes:
- `table` - Default, human-readable table view
- `markdown` - Markdown checklist format with `[ ]`, `[-]`, `[x]` checkboxes
- `json` - Machine-readable JSON for parsing

### Task Filtering
The `--filter` flag with `rune list` accepts:
- `pending` - Show only incomplete tasks
- `in-progress` - Show only tasks currently being worked on
- `completed` - Show only finished tasks

## Response Format

When managing tasks:
1. Explain what operations you'll perform
2. Execute the rune commands
3. Show the results (list updated tasks if relevant)
4. Confirm what was accomplished

Remember: Rune is designed for AI agents, so use it efficiently with batch operations when appropriate and always maintain clean, hierarchical task structures.
