---
name: beads-integration
description: Manages persistent task memory using Beads. Automatically invoked when discussing task tracking, long-running projects, session persistence, or context preservation across sessions. Handles syncing between tasks.md and Beads.
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
---

# Beads Integration Skill

You are assisting with a project that uses **Beads** - a persistent task memory system that survives context limits and session boundaries.

## What is Beads?

Beads provides:
- **Persistent memory** across Claude Code sessions
- **Task graph** with dependencies and status
- **Discovery tracking** for implementation insights
- **Context preservation** before compaction

## Core Commands

### Initialize Beads
```bash
bd init          # Initialize in project
bd doctor        # Verify setup
```

### Prime Context
```bash
bd prime         # Load task graph into context
```
This runs automatically at SessionStart and PreCompact via hooks.

### Task Management
```bash
bd create "Task description" --type task --priority P1 --label "speckit:T001"
bd list                      # List all issues
bd list --status todo        # Filter by status
bd ready                     # Show tasks ready to work
bd update <id> --status in-progress
bd update <id> --status done
bd note <id> "Discovery note"
```

### Query Tasks
```bash
bd show <id>                 # Show task details
bd find "search term"        # Search tasks
bd list --label "speckit:*"  # Find Spec Kit tasks
```

## Pivotal-Style Workflow

Spec Kit + Beads implements **Pivotal Labs methodology**:

| Pivotal Concept | Beads Implementation |
|-----------------|---------------------|
| Story Types | `--type epic/task/bug` |
| Story States | `--status todo/in-progress/done` |
| Dependencies | `bd dep add` (P0 → P1 → P2) |
| Acceptance Criteria | Epic description field |

## Sync Patterns

### spec.md + plan.md → Beads Epic

After `/speckit.plan`, create a **Pivotal-style epic**:

```bash
./.specify/scripts/bash/create-beads-epic.sh specs/001-feature P0
```

This extracts from spec.md and plan.md:
- Problem Statement
- Business Value
- Architectural Vision
- Integration Tests
- Acceptance Criteria

Epic ID is saved to `specs/001-feature/.beads-epic-id`

### tasks.md → Beads Tasks

After `/speckit.tasks`, bulk import with dependencies:

```bash
# Get epic ID
EPIC_ID=$(cat specs/001-feature/.beads-epic-id)

# Create tasks with automatic priority detection and P0→P1→P2 dependencies
./.specify/scripts/bash/create-beads-issues.sh specs/001-feature/tasks.md $EPIC_ID

# Link Beads IDs back to tasks.md
./.specify/scripts/bash/update-tasks-with-beads-ids.sh specs/001-feature/tasks.md
```

The script automatically:
- Detects P0/P1/P2/P3 priority from markers
- Sets up blocking dependencies (P0 → P1 → P2)
- Labels by user story and component

### Beads → tasks.md

When status changes in Beads:
- Query Beads: `bd list --status done --label "speckit:*"`
- Update corresponding tasks in tasks.md to `[x]`

## When to Invoke This Skill

Claude should use this skill when:
- User mentions long-running projects or multi-session work
- Discussing task persistence or memory across sessions
- Working on tasks and needing to track progress
- Starting a new session on an existing feature
- Context compaction is imminent
- User asks about Beads commands or workflow

## Session Workflow

### Starting a Session
1. `bd prime` runs automatically via SessionStart hook
2. Check current task status: `bd ready`
3. Resume work on in-progress tasks

### During Work
1. Update status when starting: `bd update <id> --status in-progress`
2. Log discoveries: `bd note <id> "Found edge case..."`
3. Mark complete when done: `bd update <id> --status done`

### Ending a Session
1. `bd prime` runs automatically via PreCompact hook
2. Ensure all status updates are saved
3. Add session notes for next time

## Best Practices

### Task Linking Format
In tasks.md, link to Beads:
```markdown
- [ ] (speckit-abc.1) [T001] [P] [US1] Create user model
```

### Discovery Documentation
Use Beads notes for:
- Implementation insights
- Edge cases discovered
- Technical decisions made
- Blockers encountered

### Status Progression
```
todo → in-progress → done
              ↓
           blocked (if needed)
```

## Troubleshooting

### Beads not priming?
```bash
bd --version    # Check installed
bd doctor       # Diagnose issues
ls .beads/      # Check database exists
```

### Tasks not syncing?
1. Check Beads IDs in tasks.md
2. Verify label format: `speckit:T###`
3. Run sync scripts manually

### Context lost?
- Run `bd prime` manually
- Check SessionStart hook in settings.json
