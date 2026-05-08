---
name: things3-cli-wrapper
description: "Manage Things 3 tasks, projects, and areas using the thangs CLI. Supports listing, adding, editing, completing, and canceling tasks with intelligent filtering and organization."
allowed-tools:
  - Bash
---

# Things3 CLI Wrapper Skill

## Overview

This skill teaches you how to use the `thangs` CLI tool to manage tasks in Things 3, a popular task management application for macOS. Things 3 must be installed and running on the user's system for these commands to work.

**When to use this skill:**
- Managing personal or professional tasks
- Creating, updating, or completing to-do items
- Organizing work into projects and areas
- Filtering and viewing tasks by various criteria

**Prerequisites:**
- Things 3 must be installed on macOS
- The `thangs` CLI must be installed globally (`npm install -g @dougskinner/thangs`)
- Things 3 must be running (or will launch automatically when commands execute)

**Key Capabilities:**
- List and filter tasks by list, project, area, or tag
- Create new tasks with rich metadata (notes, due dates, tags, assignments)
- Update existing tasks (rename, change dates, move between projects/areas)
- Complete or cancel tasks
- Create projects and areas for organization
- Machine-readable JSON output for scripting

## Core Concepts

### Things 3 Hierarchy

Things 3 organizes tasks in a three-level hierarchy:

1. **Areas** (top level) - Major life domains like "Work", "Personal", "Health"
2. **Projects** (middle level) - Specific initiatives within areas like "Q1 Planning", "Website Redesign"
3. **Tasks** (bottom level) - Individual actionable items

**Important relationships:**
- Tasks can belong to a project OR an area, but not both
- Projects can belong to an area
- Tasks without a project or area go to the Inbox

### Built-in Lists

Things 3 provides smart lists that dynamically filter tasks:
- **Today** - Tasks scheduled for today
- **Upcoming** - Tasks scheduled for future dates
- **Anytime** - Tasks without specific dates
- **Someday** - Tasks deferred for later consideration

### Task Lifecycle

Tasks progress through states:
1. **Created** - New task in Inbox or assigned location
2. **Scheduled** - Task assigned to a date (appears in Today/Upcoming)
3. **Completed** - Task marked as done
4. **Canceled** - Task moved to trash

### Tags

Tasks can have multiple tags for cross-cutting organization (e.g., "urgent", "waiting", "quick-win"). Tags are comma-separated in commands.

## Commands Quick Reference

### Decision Tree: Which Command to Use?

**Want to VIEW tasks?** → Use `list`
- Filter by list: `--list Today`
- Filter by project: `--project "Website Redesign"`
- Filter by area: `--area Work`
- Filter by tag: `--tag urgent`

**Want to CREATE something?**
- New task → Use `add <name>`
- New project → Use `add-project <name>`
- New area → Use `add-area <name>`

**Want to MODIFY a task?**
- Update properties → Use `edit <task>`
- Mark as done → Use `complete <task>`
- Move to trash → Use `cancel <task>`

### Command Syntax Patterns

#### list - View Tasks

```bash
thangs list [--list <name>] [--project <name>] [--area <name>] [--tag <name>] [--json]
```

**Options:**
- `--list` - Filter by built-in list: Today, Upcoming, Anytime, Someday
- `--project` - Filter by project name (case-insensitive partial match)
- `--area` - Filter by area name (case-insensitive partial match)
- `--tag` - Filter by tag name (case-insensitive partial match)
- `--json` - Output JSON array instead of formatted table

**Examples:**
```bash
thangs list                          # All tasks
thangs list --list Today             # Today's tasks
thangs list --project "Marketing"    # Tasks in Marketing project
thangs list --area Work --json       # Work area tasks as JSON
```

#### add - Create Task

```bash
thangs add <name> [--notes <text>] [--due <YYYY-MM-DD>] [--tags <tag1,tag2>] [--project <name>] [--area <name>] [--json]
```

**Required:**
- `<name>` - Task name (positional argument)

**Options:**
- `--notes` - Task notes/description
- `--due` - Due date in YYYY-MM-DD format
- `--tags` - Comma-separated tags
- `--project` - Assign to project by name
- `--area` - Assign to area by name
- `--json` - Output JSON response

**Examples:**
```bash
thangs add "Review budget"
thangs add "Call client" --due 2025-12-15 --tags urgent,phone
thangs add "Design mockups" --project "Website Redesign" --notes "Focus on mobile-first"
```

#### edit - Update Task

```bash
thangs edit <task> [--name <newName>] [--notes <text>] [--due <YYYY-MM-DD>] [--tags <tag1,tag2>] [--project <name>] [--area <name>] [--json]
```

**Required:**
- `<task>` - Current task name (must be unique)

**Options:**
- `--name` - Rename the task
- `--notes` - Update task notes
- `--due` - Change due date (YYYY-MM-DD format)
- `--tags` - Replace all tags (comma-separated, empty string clears tags)
- `--project` - Move to different project
- `--area` - Move to different area
- `--json` - Output JSON response

**Examples:**
```bash
thangs edit "Review budget" --due 2025-12-20
thangs edit "Call client" --tags urgent,follow-up
thangs edit "Old name" --name "New name" --project "Different Project"
```

#### complete - Mark Task Done

```bash
thangs complete <task> [--json]
```

**Required:**
- `<task>` - Task name to complete (must be unique)

**Examples:**
```bash
thangs complete "Review budget"
thangs complete "Call client" --json
```

#### cancel - Move Task to Trash

```bash
thangs cancel <task> [--json]
```

**Required:**
- `<task>` - Task name to cancel (must be unique)

**Examples:**
```bash
thangs cancel "Outdated task"
thangs cancel "Duplicate item" --json
```

#### add-project - Create Project

```bash
thangs add-project <name> [--area <name>] [--notes <text>] [--deadline <YYYY-MM-DD>] [--json]
```

**Required:**
- `<name>` - Project name

**Options:**
- `--area` - Create project within specific area
- `--notes` - Project notes
- `--deadline` - Project deadline (YYYY-MM-DD format)
- `--json` - Output JSON response

**Examples:**
```bash
thangs add-project "Q1 Planning"
thangs add-project "Website Redesign" --area Work --deadline 2025-03-31
```

#### add-area - Create Area

```bash
thangs add-area <name> [--json]
```

**Required:**
- `<name>` - Area name

**Examples:**
```bash
thangs add-area "Work"
thangs add-area "Health" --json
```

## Common Workflows

### Basic Operations

**Daily Task Review**
```bash
# See what's due today
thangs list --list Today

# Complete a task
thangs complete "Morning standup"

# Add a new task for today
thangs add "Review pull requests" --due 2025-12-09
```

**Quick Task Capture**
```bash
# Add task to Inbox (default)
thangs add "Call dentist"

# Add task with context
thangs add "Prepare presentation" --notes "Include Q4 metrics" --tags work,urgent
```

**Task Completion**
```bash
# Mark task as done
thangs complete "Write report"

# Cancel task that's no longer needed
thangs cancel "Old meeting prep"
```

### Intermediate Operations

**Project-Based Task Management**
```bash
# Create a new project
thangs add-project "Website Redesign" --area Work

# Add tasks to the project
thangs add "Create wireframes" --project "Website Redesign"
thangs add "Review designs" --project "Website Redesign" --tags review

# View all project tasks
thangs list --project "Website Redesign"

# Complete project tasks
thangs complete "Create wireframes"
```

**Area-Based Organization**
```bash
# Create areas for life domains
thangs add-area "Work"
thangs add-area "Personal"
thangs add-area "Health"

# Add tasks directly to areas (without projects)
thangs add "Schedule doctor visit" --area Health
thangs add "Update resume" --area Personal

# View all tasks in an area
thangs list --area Work
```

**Tag-Based Filtering**
```bash
# Add tasks with tags
thangs add "Review contracts" --tags urgent,legal
thangs add "Quick email replies" --tags quick-win

# Filter by tag
thangs list --tag urgent
thangs list --tag quick-win
```

### Advanced Operations

**Batch Operations with JSON Output**
```bash
# Get all Today tasks as JSON for processing
thangs list --list Today --json > today.json

# Parse JSON with jq (if available)
thangs list --area Work --json | jq '.[] | select(.tags | contains("urgent"))'
```

**Task Migration Between Projects**
```bash
# Move task to different project
thangs edit "Update documentation" --project "New Project"

# Move task from project to area directly
thangs edit "General task" --area Work
```

**Due Date Management**
```bash
# Set due date for task
thangs edit "Submit report" --due 2025-12-15

# View upcoming tasks
thangs list --list Upcoming

# Reschedule task
thangs edit "Submit report" --due 2025-12-20
```

**Complex Task Updates**
```bash
# Update multiple properties at once
thangs edit "Research competitors" \
  --name "Competitive analysis report" \
  --due 2025-12-31 \
  --tags research,high-priority \
  --project "Market Research" \
  --notes "Focus on pricing and features"
```

## Important Notes

### Task Name Uniqueness

**Critical:** For `complete`, `cancel`, and `edit` commands, task names must be unique. If multiple tasks have the same name, you'll receive an error listing all matching tasks. In this case:

1. Rename one of the tasks to make them unique
2. Use the full task name with more specific identifiers
3. View the list of tasks to identify which one to update

**Example Error:**
```bash
thangs complete "Meeting"
# Error: Multiple tasks found with name "Meeting":
# - "Meeting" (Project: Q1 Planning, Due: 2025-12-10)
# - "Meeting" (Project: Weekly Sync, Due: 2025-12-11)
```

**Solution:**
```bash
# Make names unique first
thangs edit "Meeting" --name "Q1 Planning Meeting"  # Edit the first one
thangs complete "Q1 Planning Meeting"
```

### Date Format

All date inputs must use **YYYY-MM-DD** format:
- ✅ Correct: `--due 2025-12-31`
- ❌ Wrong: `--due 12/31/2025`
- ❌ Wrong: `--due Dec 31, 2025`

### Things 3 Must Be Running

The CLI interacts with Things 3 via AppleScript, which requires Things 3 to be running. If Things 3 is not running, it will launch automatically, but there may be a brief delay on the first command.

### JSON Output for Scripting

Use `--json` flag for machine-readable output when:
- Building automation scripts
- Parsing output with tools like `jq`
- Integrating with other systems

**JSON Output Format:**
```json
{
  "success": true,
  "data": { ... }
}
```

or on error:
```json
{
  "success": false,
  "error": "Error message"
}
```

### Error Handling Patterns

**Common errors and solutions:**

1. **Task not found** - Verify task name is correct (case-sensitive)
2. **Multiple tasks found** - Make task names unique (see above)
3. **Invalid date format** - Use YYYY-MM-DD format
4. **Project/Area not found** - Create the project/area first, or check spelling
5. **Things 3 not accessible** - Ensure Things 3 is installed and permissions are granted

### Performance Considerations

- Listing all tasks can be slow with large task databases (1000+ tasks)
- Use filters (--list, --project, --area) to narrow results
- JSON output is faster than table formatting for large result sets

## See Also

For complete command reference with all options and examples, see:
- **[reference.md](reference.md)** - Detailed documentation for every command, flag, and option
- **[examples.md](examples.md)** - Real-world usage scenarios and workflows

For developers modifying or contributing to this skill:
- **[README.md](README.md)** - Skill structure, testing workflow, and contribution guidelines
