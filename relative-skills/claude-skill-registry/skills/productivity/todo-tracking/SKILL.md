---
name: todo-tracking
description: Branch-scoped task system for persistent task management across sessions.
triggers:
  - "todo"
  - "task"
  - "task file"
  - "branch task"
  - "tasks/"
---

<objective>

All tasks live in `.claude/branches/<slugified-branch>/tasks/` as individual files with ordering support.

**One location. One format. Always on a branch. Branch names slugified (/ → -).**

</objective>

<routing>

## Resources

| Resource                          | Purpose                            |
| --------------------------------- | ---------------------------------- |
| `references/branch-tasks.md`      | Complete task system documentation |
| `templates/task-file-template.md` | Individual task file format        |
| `templates/plan-template.md`      | Plan document format               |

</routing>

<quick_start>

## Quick Start

### File Location

```text
.claude/branches/<branch>/tasks/
├── 001-pending-p1-setup-create-structure.md
├── 002-pending-p1-setup-install-deps.md
├── 010-pending-p1-us1-create-user-model.md
├── 011-complete-p1-us1-implement-auth.md
├── 050-pending-p1-found-fix-type-error.md  # From /crew:check
└── 099-pending-p3-polish-update-docs.md
```

### File Naming

```text
{order}-{status}-{priority}-{story}-{slug}.md
```

- **order**: 001, 002... (3 digits)
- **status**: pending, in_progress, complete
- **priority**: p1, p2, p3
- **story**: setup, found, us1, us2, polish

### Task File Structure

```markdown
---
status: pending
priority: p1
story: us1
parallel: true
file_path: src/models/user.ts
depends_on: []
---

# T010: Create User model

## Description

[What and why]

## Acceptance Criteria

- [ ] **Given** X, **When** Y, **Then** Z

## File Path

`src/models/user.ts`

## Work Log

### [DATE] - Created

**By:** /crew:design
```

</quick_start>

<parallel_strategy>

## Parallel Agent Strategy

**One task = One agent. Launch many in parallel.**

```javascript
// Launch all parallel tasks in SINGLE message
Task({
  subagent_type: "general-purpose",
  prompt: "T001...",
  description: "T001",
  run_in_background: true,
});
Task({
  subagent_type: "general-purpose",
  prompt: "T002...",
  description: "T002",
  run_in_background: true,
});
Task({
  subagent_type: "general-purpose",
  prompt: "T003...",
  description: "T003",
  run_in_background: true,
});

// Collect results
TaskOutput({ task_id: "t001-id", block: true });
TaskOutput({ task_id: "t002-id", block: true });
TaskOutput({ task_id: "t003-id", block: true });

// Launch next batch...
```

**Rules:**

- Each task handles ONE small piece of work
- Only launch tasks with `parallel: true`
- Batch and collect before next batch
- Small scope = faster completion = less context exhaustion

</parallel_strategy>

<command_integration>

## Command Integration

| Command        | Action                                         |
| -------------- | ---------------------------------------------- |
| `/crew:design` | Creates plan + individual task files           |
| `/crew:build`  | Reads tasks, launches parallel agents by batch |
| `/crew:check`  | Adds finding files as new tasks                |
| `/crew:fix`    | Works through pending tasks                    |

</command_integration>

<checklist>

## Validation Checklist

- [ ] Tasks in `.claude/branches/<slugified-branch>/tasks/` (feat/foo → feat-foo)
- [ ] Filenames follow ordering convention
- [ ] Status matches filename AND frontmatter
- [ ] Each task has acceptance criteria
- [ ] Parallel tasks marked appropriately
- [ ] Work log updated on completion

</checklist>
