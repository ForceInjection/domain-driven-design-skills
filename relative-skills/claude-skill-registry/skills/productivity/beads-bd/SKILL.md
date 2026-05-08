---
name: beads-bd
description: >
  Use this skill for ALL task, issue, and todo tracking when the project has a `.beads/` directory
  or uses `bd` commands. This skill MUST be used instead of TodoWrite for any project with beads
  initialized.
---

# bd (Beads) - Task Tracking for AI Agents

Distributed, git-backed graph issue tracker. Provides persistent memory for complex, multi-session work with dependency awareness.

## Setup Commands

```bash
bd prime              # Output workflow context (~1-2k tokens) - run at session start
bd onboard            # Show snippet to add to AGENTS.md for new projects
```

`bd prime` provides dynamic workflow context. Use it at session start or after context compaction to refresh bd knowledge.

## Core Workflow

### Session Start

```bash
bd prime              # Get workflow context (optional if using hooks)
bd ready              # Show tasks with no open blockers (sorted by priority)
bd show <id>          # Get full context for a task
bd update <id> --status in_progress  # Claim the task
```

### While Working

```bash
bd update <id> --notes "COMPLETED: X. IN PROGRESS: Y. BLOCKED BY: Z"
```

Write notes as if explaining to a future agent with zero conversation context.

### Task Completion

```bash
bd close <id> --reason "Summary of what was done"
bd ready              # Check what's now unblocked
```

### End of Session

```bash
bd sync               # Export to JSONL, commit, pull, push
```

## Essential Commands

| Command | Purpose |
|---------|---------|
| `bd prime` | Output workflow context (session start) |
| `bd ready` | Tasks with no open blockers |
| `bd create "Title" -p 1` | Create task (priority 0-4, 0=critical) |
| `bd show <id>` | Full task details + audit trail |
| `bd update <id> --status in_progress` | Start working |
| `bd update <id> --notes "Progress"` | Add notes (appends) |
| `bd close <id> --reason "Done"` | Complete task |
| `bd dep add <child> <parent>` | parent blocks child |
| `bd list` | All tasks (supports filters) |
| `bd blocked` | Tasks with open blockers |
| `bd sync` | Git sync (export/commit/pull/push) |

## Task Creation

```bash
# Standalone items (no parent required)
bd create "Fix authentication bug" -p 0 --type bug
bd create "Refactor logging" -p 2 --type chore

# Feature with description
bd create "OAuth Support" -p 1 --type feature --description "Add Google, GitHub OAuth"

# Full hierarchy: epic -> feature -> task
bd create "Auth System" -p 0 --type epic                            # Returns: bd-abc
bd create "OAuth Support" -p 1 --type feature --parent bd-abc       # Returns: bd-abc.1
bd create "Add Google provider" -p 2 --type task --parent bd-abc.1  # Returns: bd-abc.1.1
```

**Types**: epic, feature, task, bug, chore

**Hierarchy** (typical parent -> child):
- `epic` -> `feature` -> `task`
- `bug` and `chore` can optionally have `epic` or `feature` as parent
- All types can exist standalone without a parent

**Priorities**: 0=critical, 1=high, 2=medium (default), 3=low, 4=backlog

## Dependencies

```bash
bd dep add <child> <parent>   # parent blocks child
bd dep list <id>              # View blockers and dependents
bd dep tree <id>              # View full dependency tree
```

**Dependency types**:
- `blocks`: Parent must close before child is ready
- `parent-child`: Hierarchical (epic/feature/task relationships)
- `discovered-from`: Task A led to discovering task B
- `related`: Related but not blocking

bd prevents circular dependencies automatically.

## Filtering & Search

```bash
bd list --status open         # Only open tasks
bd list --priority 0          # Only P0 (critical)
bd list --type bug            # Only bugs
bd list --label backend       # Only with label
bd search "authentication"    # Text search
bd stats                      # Project metrics
```

## Git Sync

bd stores issues in `.beads/issues.jsonl` (one line per issue, git-friendly).

```bash
bd sync                       # All-in-one: export, commit, pull, push
bd export -o backup.jsonl     # Export only
bd import -i backup.jsonl     # Import only
```

Auto-sync: bd exports after changes (30s debounce) and imports after `git pull`.

## ID Format

Hash-based IDs prevent collisions across branches/agents:
- `bd-a1b2` (4 chars for <500 issues)
- `bd-a1b2.1` (hierarchical child of epic)

## Common Patterns

### Blocked Work

```bash
bd update <id> --status blocked --notes "API returns 503"
bd create "Fix API 503" -p 0 --type bug   # Returns: bd-blocker
bd dep add <id> bd-blocker                # Link dependency
bd ready                                   # Find other ready work
```

### Resume After Compaction

```bash
bd ready                      # Find where you left off
bd show <id>                  # Full context in notes field
# Notes contain: COMPLETED, IN PROGRESS, BLOCKERS, KEY DECISIONS
```

### Multi-Agent Coordination

```bash
bd update <id> --status in_progress --assignee agent-name
bd ready --assignee agent-name  # Query by assignee
bd sync                         # Push changes for other agents
```

## Error Recovery

| Error | Solution |
|-------|----------|
| `bd: command not found` | Install: `brew install steveyegge/beads/bd` or `npm install -g @beads/bd` |
| `No .beads database found` | Run `bd init` in git repo root |
| `Task not found` | Use `bd list` or `bd search` to find correct ID |
| `Circular dependency` | Restructure: `bd dep list <id>` to view graph |
| `Database is locked` | `bd daemon --stop && bd daemon --start` |

## Reference

Full documentation: https://github.com/steveyegge/beads
