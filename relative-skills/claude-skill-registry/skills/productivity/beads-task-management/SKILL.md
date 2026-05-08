---
name: beads-task-management
description: Use beads for structured task tracking with dependencies, recovery cards, and cross-session context management
---

# Beads Task Management

## Overview

Beads is a git-backed issue tracker designed for AI agents and distributed workflows. This skill teaches Claude how to use beads effectively for task management, context recovery, and cross-session collaboration.

**Core principle:** Persistent task tracking prevents context loss and enables multi-session workflows.

## Prerequisites

**Required:**
- `bd` (beads CLI) - Install: `brew install steveyegge/beads/bd`
- Git repository
- Project initialized with `bd init`

**Optional but Recommended:**
- `~/.claude/hooks/beads-auto-sync.sh` - Auto-sync hook (see HOOK_SETUP.md)

**First-time setup in a project:**
```bash
cd <project-directory>
bd init
```

## When to Use This Skill

Use beads when:
- Working on multi-session tasks (spans multiple days/weeks)
- Tasks have dependencies or blockers
- Discovering new work during implementation
- Need to preserve context across Claude Code compacts/restarts
- Multiple people/agents working on same project

**Don't use beads for:**
- Single-session, simple tasks (use TodoWrite instead)
- Throwaway experiments
- Projects without `.beads/` directory

## The Recovery Card Pattern

**CRITICAL:** Every beads project must have a standardized recovery card.

### Recovery Card Convention

- **Title:** `RECOVERY: Current Session Context` (always this exact title)
- **Status:** `in_progress` (appears in `bd ready`)
- **Priority:** P0
- **Content:** Detailed context for restoring work after time away

### Starting a Session

```bash
bd ready
```

The recovery card appears first. Read it, follow instructions, then close it.

### Ending a Session

Before compact or stopping work:

```bash
# Check if recovery card exists
bd list --status in_progress | grep -i recovery

# Update existing card
bd update <id> --description "$(cat <<'EOF'
Context from [DATE]:

COMPLETED THIS SESSION:
- [item 1]
- [item 2]

IN PROGRESS:
- [current work] - Run: bd show <id>

GIT STATUS:
- Branch: [name]
- Commits ahead: [number]
- Uncommitted changes: [list key files]

NEXT STEPS:
1. [next task]
2. [following task]

BLOCKERS/NOTES:
- [critical context]
EOF
)"

# Or create new if doesn't exist
bd create "RECOVERY: Current Session Context" -p 0 --description "..."
bd update <new-id> --status in_progress

# Always sync
bd sync
```

## Essential Commands

### Finding Work

```bash
bd ready                          # Show unblocked work (ready to do)
bd list --status=open             # All open issues
bd list --status=in_progress      # Your active work
bd show <id>                      # Detailed view with dependencies
```

### Creating Issues

```bash
# Basic creation
bd create --title="Task name" --type=task --priority=2

# With description
bd create --title="Feature X" --type=feature --priority=1 --description "Details..."

# Types: task, bug, feature, epic
# Priority: 0-4 or P0-P4 (0=critical, 2=medium, 4=backlog)
#   Use numbers (0-4), NOT strings ("high", "medium", "low")
```

### Managing Work

```bash
bd update <id> --status=in_progress    # Claim work
bd update <id> --assignee=username     # Assign to someone
bd close <id>                          # Mark complete
bd close <id1> <id2> <id3>            # Close multiple at once (efficient)
bd close <id> --reason="explanation"   # Close with reason
```

### Dependencies

```bash
bd dep add <child> <parent>       # Child depends on parent (parent blocks child)
bd blocked                        # Show all blocked issues
bd show <id>                      # See blockers and blocked-by
```

### Sync & Collaboration

```bash
bd sync                           # Sync with git remote
bd sync --status                  # Check sync status without syncing
bd stats                          # Project health (open/closed/blocked)
```

## Common Workflows

### Workflow 1: Starting Work

```bash
# 1. Check recovery card
bd ready
bd show vulcan-clean-4rp   # Read recovery card

# 2. Close recovery card
bd close vulcan-clean-4rp --reason "Context restored"

# 3. Find next task
bd ready
bd show <next-task-id>

# 4. Claim it
bd update <id> --status=in_progress

# 5. Update TodoWrite for session tracking
TodoWrite: Add tasks for current work
```

### Workflow 2: Discovering New Work

```bash
# While working, you discover issues
bd create --title="Fix bug in X" --type=bug --priority=1

# If it blocks current work
bd dep add <current-task-id> <new-bug-id>

# Update status
bd update <current-task-id> --status=open  # Unblock yourself
bd update <new-bug-id> --status=in_progress  # Work on blocker
```

### Workflow 3: Completing Work

```bash
# Close all completed tasks at once
bd close <id1> <id2> <id3> --reason "Implemented and tested"

# Sync to remote
bd sync

# Check what's ready next
bd ready
```

### Workflow 4: Creating Epic with Subtasks

```bash
# Create epic
bd create --title="Backend Refactor" --type=epic --priority=1
# Note the ID (e.g., bd-abc)

# Create subtasks
bd create --title="Phase 1: Models" --parent bd-abc --priority=1
bd create --title="Phase 2: Controllers" --parent bd-abc --priority=1
bd create --title="Phase 3: Tests" --parent bd-abc --priority=1

# Add dependencies (Phase 2 depends on Phase 1)
bd dep add bd-abc.2 bd-abc.1
bd dep add bd-abc.3 bd-abc.2
```

## Integration with TodoWrite

**Use both tools together:**

| Tool | When | Why |
|------|------|-----|
| **Beads** | Multi-session, has dependencies, discovered work | Persistent, survives compacts |
| **TodoWrite** | Single-session execution tracking | Real-time progress visibility |

**Pattern:**
```bash
# At session start
bd show <task-id>                 # Read beads task
TodoWrite: Break down into steps  # Track execution

# During work
TodoWrite: Update progress        # Real-time tracking
bd create: Discovered issues      # Persistent tracking

# At session end
TodoWrite: Mark complete          # Clean up session todos
bd close <task-id>                # Mark beads task done
bd update recovery card           # Preserve context
bd sync                           # Commit to git
```

## Session Close Checklist

**Before ending ANY session with beads:**

```bash
# 1. Check what changed
git status

# 2. Stage code changes
git add <specific-files>

# 3. Sync beads
bd sync

# 4. Commit code
git commit -m "..."

# 5. Sync beads again (captures any new beads changes)
bd sync

# 6. Push to remote
git push

# 7. Verify
git status  # Must show "up to date with origin"
```

**Work is NOT done until pushed.**

## Red Flags - STOP

- Saying "done" without running `bd sync`
- Ending session without updating recovery card
- Closing beads without `bd sync`
- Forgetting to `git push` beads changes
- Marking task complete without updating beads status

## Best Practices

### Priority Guidelines

```
P0 (0): Critical blockers, production issues
P1 (1): High priority features, important bugs
P2 (2): Medium priority, normal development
P3 (3): Nice-to-have features
P4 (4): Backlog, future work
```

### When to Create vs Update

**Create new issue when:**
- Discovered during implementation
- Requires separate tracking
- Has unique dependencies
- Multi-session scope

**Update existing issue when:**
- Adding details
- Changing status/priority
- Adding comments
- Quick notes

### Batch Operations for Efficiency

```bash
# GOOD: Close multiple at once
bd close <id1> <id2> <id3> <id4>

# BAD: One at a time
bd close <id1>
bd close <id2>
bd close <id3>
```

### Epic Organization

```bash
# Use epics for multi-phase work
epic (type=epic)
├── epic.1 (type=task) → Phase 1
├── epic.2 (type=task) → Phase 2
└── epic.3 (type=task) → Phase 3

# Set dependencies
bd dep add epic.2 epic.1  # Phase 2 blocked by Phase 1
bd dep add epic.3 epic.2  # Phase 3 blocked by Phase 2
```

## Anti-Patterns

**Don't:**
- Use beads for trivial single-line changes
- Forget to sync before pushing code
- Skip recovery card updates
- Use `git add .` (always add specific files)
- Create issues without descriptions
- Use string priorities ("high", "medium") instead of numbers (0-4)

## Troubleshooting

### "Sync conflicts"
```bash
bd sync --status        # Check sync state
bd sync --from-main     # Force pull from main
```

### "Can't find recovery card"
```bash
bd list --status in_progress | grep -i recovery
bd list | grep -i "RECOVERY:"
```

### "Beads changes not committed"
```bash
cd <project-root>
git status              # Check .beads/issues.jsonl status
bd sync                 # Commits beads changes to beads-sync branch
```

## References

- Beads GitHub: https://github.com/steveyegge/beads
- Installation: `brew install steveyegge/beads/bd`
- Beads is designed for AI agents and distributed teams
- Hash-based IDs prevent merge conflicts

## Integration Points

This skill works with:
- **prepare-compact** - Updates recovery card before compact
- **restore-context** - Reads recovery card after compact
- **TodoWrite** - Single-session execution tracking
- **verification-before-completion** - Ensures beads synced before claims
- **finishing-a-development-branch** - Closes beads before merge/PR

## The Bottom Line

**Beads preserves context across sessions.**

When you compact, restart, or return days later:
- TodoWrite is gone
- Beads persists
- Recovery card restores full context
- No work is lost

This is non-negotiable for multi-session work.
