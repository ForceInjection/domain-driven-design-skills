---
name: issue-tracking
description: Creates and manages issues via tissue for tracking work items, bugs, and features. Use for organizing work, checking ready issues, or updating status.
---

# Issue Tracking Skill

Work tracking via [tissue](https://github.com/femtomc/tissue), a git-native issue tracker.

## When to Use

- Creating new issues for bugs or features
- Checking what's ready to work on
- Updating issue status
- Adding comments or context to issues
- Managing dependencies between issues

## Setup

Tissue stores issues in `.tissue/` (git-tracked).

```bash
# Initialize (once per project)
tissue init
```

## Core Operations

### List issues
```bash
tissue list                    # All issues
tissue list --status open      # Open only
tissue list --tag bug          # By tag
tissue list --priority 1       # High priority
```

### Show ready issues
```bash
tissue ready                   # No blockers, ready to work
```

### Show issue details
```bash
tissue show <id>
```

### Create issue
```bash
tissue new "title"
tissue new "title" -t bug              # With tag
tissue new "title" -p 1                # Priority 1 (highest)
tissue new "title" -t feature -p 2     # Both
```

### Update status
```bash
tissue status <id> open
tissue status <id> in_progress
tissue status <id> closed
```

### Add comment
```bash
tissue comment <id> -m "message"
```

## Tags and Priority

### Standard Tags

| Tag | Purpose |
|-----|---------|
| `bug` | Something broken |
| `feature` | New functionality |
| `refactor` | Code improvement |
| `docs` | Documentation |
| `trivial` | Quick fix |

### Priority Levels

| Priority | Meaning |
|----------|---------|
| 1 | Critical - do first |
| 2 | High - do soon |
| 3 | Medium - normal |
| 4 | Low - when time permits |
| 5 | Backlog - someday |

## Dependencies

```bash
# Add dependency (A blocks B)
tissue dep add <blocker-id> blocks <blocked-id>

# Remove dependency
tissue dep rm <blocker-id> blocks <blocked-id>

# Show what blocks an issue
tissue show <id>   # Lists blockers
```

## Workflow Integration

Use tissue to track work items. When working on an issue:
1. Check `tissue ready` to see what's available
2. Start working: `tissue status <id> in_progress`
3. Add comments as you discover things
4. Close when done: `tissue status <id> closed`

### Issue Naming

Issues get IDs like `auth-a3f2`. The prefix comes from the title:
- "Fix auth bug" → `auth-xxxx`
- "Add caching" → `caching-xxxx`

## Examples

```bash
# Create a bug
tissue new "Login fails on Safari" -t bug -p 2

# Check ready work
tissue ready

# Start working
tissue status auth-a3f2 in_progress

# Add finding
tissue comment auth-a3f2 -m "Root cause: cookie SameSite attribute"

# Close it
tissue status auth-a3f2 closed
```

## Querying

```bash
# High priority bugs
tissue list --tag bug --priority 1

# All open features
tissue list --tag feature --status open

# Everything assigned to current sprint
tissue list --tag sprint-42
```

## Integration with jwz

Issue topics in jwz follow the pattern `issue:<id>`:

```bash
# Post to issue topic
jwz post "issue:auth-a3f2" -m "Starting work on this"

# Read issue discussion
jwz read "issue:auth-a3f2"
```

This connects tissue issues with agent discussions.
