---
name: tasks
description: Manage Google Tasks with full CRUD operations via Ruby scripts. This skill should be used when working with Google Tasks - creating, reading, updating, deleting, and organizing tasks and task lists. Supports task completion, subtask creation, task ordering, and integration with other Google skills through shared OAuth authentication.
category: productivity
version: 1.0.0
---

# Google Tasks Skill

## Overview

This skill provides comprehensive Google Tasks API integration, enabling Claude Code to manage task lists and tasks programmatically. It shares OAuth authentication with other Google skills (Calendar, Drive, Sheets, Docs, Contacts, Gmail) for seamless multi-service workflows.

## Authentication

**Shared OAuth Token**: This skill uses the same OAuth credentials as other Google skills:
- **Credentials**: `~/.claude/.google/client_secret.json`
- **Token**: `~/.claude/.google/token.json`
- **Scope**: `https://www.googleapis.com/auth/tasks`

The token file contains all Google API scopes, so if you've authenticated with Calendar, Drive, or other Google skills, Tasks will work automatically.

### First-Time Setup

If the Tasks scope isn't yet authorized:
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb list_tasklists
```
This will trigger the OAuth flow if needed.

## Task List Operations

### List All Task Lists
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb list_tasklists
```
Returns all task lists in the user's account.

### Get a Specific Task List
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb get_tasklist --id "TASKLIST_ID"
```

### Create a New Task List
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_tasklist --title "Project Tasks"
```

### Update a Task List
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb update_tasklist --id "TASKLIST_ID" --title "Updated Title"
```

### Delete a Task List
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb delete_tasklist --id "TASKLIST_ID"
```

## Task Operations

### List Tasks in a Task List
```bash
# List all tasks (including completed)
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb list_tasks --tasklist "TASKLIST_ID" --show_completed true

# List only incomplete tasks
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb list_tasks --tasklist "TASKLIST_ID"

# List with hidden tasks
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb list_tasks --tasklist "TASKLIST_ID" --show_hidden true
```

### Get a Specific Task
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb get_task --tasklist "TASKLIST_ID" --id "TASK_ID"
```

### Create a Task
```bash
# Simple task
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_task --tasklist "TASKLIST_ID" --title "Buy groceries"

# Task with details
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_task \
  --tasklist "TASKLIST_ID" \
  --title "Complete project proposal" \
  --notes "Include budget estimates and timeline" \
  --due "2025-12-15"

# Create a subtask (child of another task)
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_task \
  --tasklist "TASKLIST_ID" \
  --title "Research competitors" \
  --parent "PARENT_TASK_ID"

# Position task after a specific task
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_task \
  --tasklist "TASKLIST_ID" \
  --title "Follow-up meeting" \
  --previous "PREVIOUS_TASK_ID"
```

### Update a Task
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb update_task \
  --tasklist "TASKLIST_ID" \
  --id "TASK_ID" \
  --title "Updated title" \
  --notes "Updated notes" \
  --due "2025-12-20"
```

### Complete a Task
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb complete_task --tasklist "TASKLIST_ID" --id "TASK_ID"
```

### Uncomplete a Task
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb uncomplete_task --tasklist "TASKLIST_ID" --id "TASK_ID"
```

### Move a Task
```bash
# Move to top of list
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb move_task --tasklist "TASKLIST_ID" --id "TASK_ID"

# Move after a specific task
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb move_task \
  --tasklist "TASKLIST_ID" \
  --id "TASK_ID" \
  --previous "PREVIOUS_TASK_ID"

# Move as subtask of another task
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb move_task \
  --tasklist "TASKLIST_ID" \
  --id "TASK_ID" \
  --parent "PARENT_TASK_ID"
```

### Delete a Task
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb delete_task --tasklist "TASKLIST_ID" --id "TASK_ID"
```

### Clear Completed Tasks
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb clear_completed --tasklist "TASKLIST_ID"
```

## Natural Language Examples

**User**: "Show me all my task lists"
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb list_tasklists
```

**User**: "Create a new task list called 'Home Renovation'"
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_tasklist --title "Home Renovation"
```

**User**: "Add a task to buy paint for the living room, due next Friday"
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_task \
  --tasklist "TASKLIST_ID" \
  --title "Buy paint for living room" \
  --due "2025-12-05"
```

**User**: "Mark the grocery shopping task as done"
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb complete_task --tasklist "TASKLIST_ID" --id "TASK_ID"
```

**User**: "Show me all incomplete tasks in my work list"
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb list_tasks --tasklist "WORK_LIST_ID"
```

**User**: "Delete all completed tasks from my personal list"
```bash
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb clear_completed --tasklist "PERSONAL_LIST_ID"
```

## Workflow Patterns

### Project Task Management
```bash
# 1. Create a project task list
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_tasklist --title "Website Redesign"

# 2. Add main tasks
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_task --tasklist "LIST_ID" --title "Design mockups"
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_task --tasklist "LIST_ID" --title "Frontend development"
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_task --tasklist "LIST_ID" --title "Backend API"

# 3. Add subtasks
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_task \
  --tasklist "LIST_ID" \
  --title "Create wireframes" \
  --parent "DESIGN_TASK_ID"
```

### Daily Task Review
```bash
# List all incomplete tasks
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb list_tasks --tasklist "LIST_ID"

# Complete finished tasks
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb complete_task --tasklist "LIST_ID" --id "TASK_ID"

# Clear old completed tasks
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb clear_completed --tasklist "LIST_ID"
```

### Calendar + Tasks Integration
When a calendar event requires follow-up tasks:
```bash
# After creating/reviewing a calendar event, create related tasks
ruby ~/.claude/skills/tasks/scripts/tasks_manager.rb create_task \
  --tasklist "WORK_LIST_ID" \
  --title "Prepare meeting agenda" \
  --notes "For project kickoff on Monday" \
  --due "2025-12-06"
```

## Output Format

All commands return JSON with this structure:

**Success**:
```json
{
  "status": "success",
  "code": 0,
  "data": { ... },
  "message": "Operation completed successfully"
}
```

**Error**:
```json
{
  "status": "error",
  "code": 1,
  "message": "Error description"
}
```

### Exit Codes
- `0`: Success
- `1`: General failure
- `2`: Authentication error
- `3`: API error
- `4`: Invalid arguments

## Task Object Structure

Tasks returned from the API include:
- `id`: Unique task identifier
- `title`: Task title
- `notes`: Task description/notes
- `status`: "needsAction" or "completed"
- `due`: Due date (RFC 3339 format)
- `completed`: Completion timestamp
- `parent`: Parent task ID (for subtasks)
- `position`: Order within the list
- `links`: Associated URLs
- `hidden`: Whether task is hidden
- `deleted`: Whether task is deleted

## Integration with Other Google Skills

This skill works seamlessly with:
- **Calendar**: Create tasks from events, link tasks to meetings
- **Drive**: Reference documents in task notes
- **Sheets**: Export task data for reporting
- **Docs**: Link project documents to tasks
- **Contacts**: Assign tasks related to contacts
- **Gmail**: Create tasks from email threads

All skills share the same OAuth token, so authentication is unified.

## Error Handling

Common errors and solutions:

**"Authentication required"**: Run any command to trigger OAuth flow
**"Task list not found"**: Verify the task list ID with `list_tasklists`
**"Task not found"**: Verify the task ID with `list_tasks`
**"Invalid due date"**: Use YYYY-MM-DD format

## Best Practices

1. **Use task lists for organization**: Group related tasks in dedicated lists
2. **Leverage subtasks**: Break complex tasks into manageable subtasks
3. **Set due dates**: Help prioritize with explicit deadlines
4. **Add notes**: Include context and details in task notes
5. **Regular cleanup**: Use `clear_completed` to remove finished tasks

## Resources

### scripts/
- `tasks_manager.rb` - Main Ruby script for all Google Tasks operations

## Dependencies

Required Ruby gems:
- `google-apis-tasks_v1`
- `googleauth`
