---
name: task-engine
description: Create, organize, and prioritize tasks from briefs or brain dumps. Sync with Taskmaster MCP. Use to plan work, track status, and pick next steps.
triggers:
  - create tasks
  - organize tasks
  - what needs to be done
  - prioritize
  - תארגן את המשימות
  - brain dump
---

# Task Engine Skill

Transform project briefs and brain dumps into organized, prioritized task lists with dependencies. Syncs bidirectionally with Taskmaster MCP.

## Purpose

The task engine manages all task-related operations including creation, organization, prioritization, and synchronization with Taskmaster MCP. It supports both structured input (from briefs) and unstructured input (brain dumps).

## Taskmaster MCP Integration

### Read Operations
| Function | Purpose |
|----------|---------|
| `get_tasks` | Retrieve all tasks for a project |
| `get_task` | Get specific task by ID |
| `next_task` | Find next task to work on based on dependencies |

### Write Operations
| Function | Purpose |
|----------|---------|
| `parse_prd` | Generate tasks from PRD document |
| `expand_task` | Break task into subtasks |
| `set_task_status` | Update task status (pending/in-progress/done) |
| `update_subtask` | Modify subtask details |

### Sync Direction
- **Local → Taskmaster**: Push changes from {project}_tasks.md to MCP
- **Taskmaster → Local**: Pull updates from MCP to {project}_tasks.md
- **Bidirectional**: Keep both in sync

## Inputs

**Required:**
- `source`: Brief, brain dump, or raw task list

**Optional:**
- `project_context`: From {project}_brief.md
- `existing_tasks`: From {project}_tasks.md or Taskmaster

## Workflow

### Step 1: Capture Tasks

**From Brief:**
- Extract implied tasks from milestones
- Convert deliverables to tasks
- Identify dependencies from success criteria

**From Brain Dump:**
- Parse text for action items
- Identify verbs indicating tasks
- Group related items

**From Existing List:**
- Clean up format
- Standardize structure
- Fill missing fields

### Step 2: Structure Tasks

Apply these rules:
- One clear outcome per task
- Create subtasks if work exceeds 2 hours
- Maximum 3 levels of nesting
- Each task needs: ID, name, status, priority

### Step 3: Analyze Priority

Use the Eisenhower Matrix:

| Quadrant | Priority | Action |
|----------|----------|--------|
| Urgent + Important | High Priority | Do first |
| Not Urgent + Important | Medium Priority | Schedule |
| Urgent + Not Important | Delegate | Assign out |
| Neither | Low Priority / Backlog | Do later |

### Step 4: Identify Dependencies

For each task, determine:
- What must complete before this?
- What does this block?
- Are there parallel paths?

### Step 5: Sync with Taskmaster

```python
# Example sync workflow
tasks = taskmaster.get_tasks(project_root)
local_tasks = parse_tasks_md(f"{project}_tasks.md")

# Merge and update
for task in merged_tasks:
    if task.changed_locally:
        taskmaster.set_task_status(task.id, task.status)
    elif task.changed_remotely:
        update_local_task(task)
```

### Step 6: Checkpoint

**CHECKPOINT:** Present organized list to user

Ask:
- "Does this capture everything?"
- "Is the priority correct?"
- "Any dependencies I missed?"

### Step 7: Save

- Save as `{project}_tasks.md`
- Suggest: "Use delegation-advisor to assign high priority tasks"

## Output Format

See `resources/tasks_template.md` for full template.

```markdown
# Tasks: {project_name}

**Last Updated:** {timestamp}
**Total Tasks:** {count} | **Completed:** {done_count}

## High Priority / Urgent

### [ ] {task_name}
- **ID:** {task_id}
- **Status:** {status}
- **Assignee:** {human|ai_agent|pending}
- **Dependencies:** {deps}

## Medium Priority
...

## Low Priority / Backlog
...

## Completed
- [x] {completed_task} (Done: {date})
```

## Example: Brain Dump Processing

**User Input:**
> "brain dump: צריך לחקור frameworks קיימים, לכתוב draft לדיקן, להכין מצגת, לתאם פגישה עם IT, לבדוק תקציב"

**Processing:**
1. Extract 5 action items
2. Categorize by type (research, writing, meetings)
3. Assign priorities based on dependencies
4. Sync with Taskmaster

**Output:**
```markdown
# Tasks: AI Strategy

## High Priority / Urgent
### [ ] Research existing AI frameworks
- **ID:** task-1
- **Status:** pending
- **Dependencies:** none

### [ ] Draft proposal for Dean
- **ID:** task-2
- **Dependencies:** task-1

## Medium Priority
### [ ] Prepare presentation
- **ID:** task-3
- **Dependencies:** task-2
```

## Cross-Interface Notes

- **Claude AI**: Taskmaster MCP called via skill
- **Claude Code**: Taskmaster MCP called natively
- Both use same task format for compatibility

