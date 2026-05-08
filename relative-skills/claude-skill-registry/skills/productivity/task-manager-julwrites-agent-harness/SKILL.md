---
name: task-manager
description: Manage project tasks. Create, list, update, and track dependencies of tasks.
---

# Task Manager

Use this skill to manage the project's task documentation in `docs/tasks/`.

### Create a Task
```bash
python3 scripts/tasks.py create "Task Title" --status pending --priority high --type task --estimate "2h"
```

### List Tasks
```bash
# List all pending tasks
python3 scripts/tasks.py list --status pending

# List tasks in a specific sprint
python3 scripts/tasks.py list --sprint "Sprint 1"
```

### Update a Task
```bash
python3 scripts/tasks.py update TASK-ID --status in_progress
```

### Manage Dependencies
```bash
python3 scripts/tasks.py link TASK-A TASK-B  # A depends on B
python3 scripts/tasks.py unlink TASK-A TASK-B
```

### View Task Details
```bash
python3 scripts/tasks.py show TASK-ID
```

### Get Next Task Recommendation
```bash
python3 scripts/tasks.py next
```
