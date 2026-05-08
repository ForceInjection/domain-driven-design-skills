---
name: google-tasks
version: 1.0
description: "Manage Google Tasks and task lists. Load when user mentions 'google tasks', 'tasks', 'todo list', 'create task', 'complete task', or references task/todo management."
---

# Google Tasks

Create, update, and manage tasks and task lists in Google Tasks via OAuth authentication.

---

## Pre-Flight Check (ALWAYS RUN FIRST)

```bash
python3 00-system/skills/google/google-master/scripts/google_auth.py --check --service tasks
```

**Exit codes:**
- **0**: Ready to use - proceed with user request
- **1**: Need to login - run `python3 00-system/skills/google/google-master/scripts/google_auth.py --login`
- **2**: Missing credentials or dependencies - see [../google-master/references/setup-guide.md](../google-master/references/setup-guide.md)

---

## Quick Reference

### List Task Lists
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py lists
```

### Create Task List
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py create-list "Work Tasks"
```

### List Tasks (Default List)
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py tasks
```

### List Tasks (Specific List)
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py tasks --list <list_id>
```

### List Tasks Including Completed
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py tasks --show-completed
```

### Create Task
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py create "Buy groceries"
```

### Create Task with Due Date
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py create "Submit report" --due 2025-12-25
```

### Create Task with Notes
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py create "Call John" --notes "Discuss project timeline"
```

### Create Subtask
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py create "Subtask" --parent <parent_task_id>
```

### Update Task
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py update <task_id> --title "New title" --due 2025-12-30
```

### Complete Task
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py complete <task_id>
```

### Uncomplete Task
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py uncomplete <task_id>
```

### Delete Task
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py delete <task_id>
```

### Clear Completed Tasks
```bash
python3 00-system/skills/google/google-tasks/scripts/tasks_operations.py clear-completed
```

---

## Task Status

| Status | Description |
|--------|-------------|
| `needsAction` | Task is incomplete (active) |
| `completed` | Task is done |

---

## Date Format

Due dates use `YYYY-MM-DD` format:
- `2025-12-25` - December 25, 2025
- `2025-01-01` - January 1, 2025

---

## Available Operations

### Task Lists

| Operation | Function | Description |
|-----------|----------|-------------|
| **Lists** | `list_task_lists()` | List all task lists |
| **Create List** | `create_task_list()` | Create new task list |
| **Delete List** | `delete_task_list()` | Delete a task list |
| **Rename List** | `rename_task_list()` | Rename a task list |

### Tasks

| Operation | Function | Description |
|-----------|----------|-------------|
| **Tasks** | `list_tasks()` | List tasks in a list |
| **Get** | `get_task()` | Get task details |
| **Create** | `create_task()` | Create new task |
| **Update** | `update_task()` | Update task |
| **Complete** | `complete_task()` | Mark as done |
| **Uncomplete** | `uncomplete_task()` | Mark as not done |
| **Delete** | `delete_task()` | Delete task |
| **Move** | `move_task()` | Reorder or make subtask |
| **Clear** | `clear_completed()` | Remove completed tasks |

---

## Common Workflows

### Daily Task Review
```python
from tasks_operations import list_tasks

# Get incomplete tasks
tasks = list_tasks('@default', show_completed=False)
for task in tasks:
    print(f"- {task['title']} (due: {task['due']})")
```

### Weekly Planning
```python
from tasks_operations import create_task

weekly_tasks = [
    ("Monday standup", "2025-12-16"),
    ("Client call", "2025-12-17"),
    ("Submit report", "2025-12-20"),
]

for title, due in weekly_tasks:
    create_task('@default', title, due=due)
```

---

## Error Handling

See [../google-master/references/error-handling.md](../google-master/references/error-handling.md) for common errors and solutions.

---

## Setup

First-time setup: [../google-master/references/setup-guide.md](../google-master/references/setup-guide.md)

**Quick start:**
1. `pip install google-auth google-auth-oauthlib google-api-python-client`
2. Create OAuth credentials in Google Cloud Console (enable Google Tasks API, choose "Desktop app")
3. Add to `.env` file at Nexus root:
   ```
   GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=your-client-secret
   GOOGLE_PROJECT_ID=your-project-id
   ```
4. Run `python3 00-system/skills/google/google-master/scripts/google_auth.py --login`
