---
name: linearis-cli
description: Reference for Linearis CLI commands to interact with Linear project management. Use when working with Linear tickets, cycles, projects, milestones, or when the user mentions ticket IDs like TEAM-123, BRAVO-456, ENG-789.
---

# Linearis CLI Reference

**CRITICAL: Always use these exact patterns. Do NOT guess or improvise syntax.**

## Issue Operations

### Read a Ticket
```bash
linearis issues read TEAM-123                    # ✅ By identifier
linearis issues read 7690e05c-32fb-4cf2-b709-f9adb12e73e7  # ✅ By UUID
```

**Common mistakes:**
```bash
linearis issues get TEAM-123      # ❌ WRONG - no 'get' command
linearis issue view TEAM-123      # ❌ WRONG - no 'view', use 'read'
linearis issue TEAM-123           # ❌ WRONG - missing subcommand
```

### List Tickets
```bash
linearis issues list                      # Basic list (25 tickets)
linearis issues list --limit 50           # With limit
linearis issues list --team BRAVO         # Filter by team
linearis issues list --team BRAVO --limit 100
```

**NOTE:** `--limit` and `--team` are the ONLY supported filters. For other filtering, use jq:
```bash
# Filter by status - use jq, NOT --status or --filter
linearis issues list --limit 100 | jq '.[] | select(.state.name == "In Progress")'

# Search by title
linearis issues list --limit 100 | jq '.[] | select(.title | contains("auth"))'
```

**Common mistakes:**
```bash
linearis issues list --status "In Progress"  # ❌ WRONG - no --status flag
linearis issues list --filter "keyword"      # ❌ WRONG - no --filter flag
linearis issues --filter "keyword"           # ❌ WRONG - no --filter flag
```

### Search Tickets
```bash
linearis issues search "keyword" --team BRAVO    # ✅ Correct
linearis issues search "auth" --team ENG         # ✅ Correct
```

### Update a Ticket
```bash
# Update state - use --state NOT --status!
linearis issues update TEAM-123 --state "In Progress"
linearis issues update TEAM-123 --state "Research"
linearis issues update TEAM-123 --state "Done"

# Other updates
linearis issues update TEAM-123 --title "New title"
linearis issues update TEAM-123 --description "New description"
linearis issues update TEAM-123 --priority 1              # 1=Urgent, 2=High, 3=Medium, 4=Low
linearis issues update TEAM-123 --assignee <user-id>
linearis issues update TEAM-123 --project "Project Name"
linearis issues update TEAM-123 --cycle "Cycle Name"
linearis issues update TEAM-123 --project-milestone "Milestone Name"
linearis issues update TEAM-123 --labels "bug,urgent"
linearis issues update TEAM-123 --clear-cycle
linearis issues update TEAM-123 --clear-project-milestone
```

**Common mistakes:**
```bash
linearis issues update TEAM-123 --status "Done"   # ❌ WRONG - use --state
```

### Create a Ticket
```bash
linearis issues create "Title of ticket"
linearis issues create "Title" --description "Description" --state "Todo" --priority 2
linearis issues create "Title" --team BRAVO --project "Project Name"
```

## Comment Operations

### Add a Comment
```bash
linearis comments create TEAM-123 --body "Starting research"

# Multi-line comment
linearis comments create TEAM-123 --body "Research complete!

See findings: https://github.com/..."
```

**Common mistakes:**
```bash
linearis issues comment TEAM-123 "Comment"        # ❌ WRONG
linearis issues add-comment TEAM-123 "Comment"    # ❌ WRONG
linearis comment TEAM-123 --body "Comment"        # ❌ WRONG
```

**Correct pattern:** `linearis comments create` (plural "comments", then "create")

## Cycle Operations

### List Cycles
```bash
linearis cycles list --team BRAVO              # All cycles
linearis cycles list --team BRAVO --active     # Only active cycle
linearis cycles list --team BRAVO --limit 5    # Recent cycles
```

### Read Cycle Details
```bash
linearis cycles read "Sprint 2025-11" --team BRAVO   # By name
linearis cycles read <cycle-uuid>                     # By UUID
```

Returns all issues in the cycle - useful for cycle analysis.

### Get Active Cycle Pattern
```bash
CYCLE=$(linearis cycles list --team BRAVO --active | jq -r '.[0].name')
linearis cycles read "$CYCLE" --team BRAVO | jq '.issues[] | {identifier, title, state: .state.name}'
```

## Project Operations

### List Projects
```bash
linearis projects list --team BRAVO
linearis projects list --team BRAVO | jq '.[] | select(.name == "Auth System")'
```

## Milestone Operations

### List Milestones
```bash
linearis project-milestones list --project "Project Name"
linearis project-milestones list --project <project-uuid>
```

### Read Milestone
```bash
linearis project-milestones read "Beta Launch" --project "Auth System"
linearis project-milestones read <milestone-uuid>
```

### Update Milestone
```bash
linearis project-milestones update "Milestone" --project "Project" --name "New Name"
linearis project-milestones update "Milestone" --project "Project" --target-date "2025-12-31"
```

## Label Operations

```bash
linearis labels list --team BRAVO
```

## Common Workflow Patterns

### Read ticket, update state, add comment
```bash
# 1. Read ticket
linearis issues read TEAM-123

# 2. Update state
linearis issues update TEAM-123 --state "In Progress"

# 3. Add comment
linearis comments create TEAM-123 --body "Starting work on this"
```

### Find tickets in current cycle
```bash
CYCLE=$(linearis cycles list --team BRAVO --active | jq -r '.[0].name')
linearis cycles read "$CYCLE" --team BRAVO | jq '.issues[] | {identifier, title, state: .state.name}'
```

### Get tickets by project
```bash
linearis issues list --team BRAVO --limit 100 | jq '.[] | select(.project.name == "Auth System")'
```

### Mark ticket as done with PR link
```bash
linearis issues update TEAM-123 --state "Done"
linearis comments create TEAM-123 --body "Merged: PR #456 https://github.com/org/repo/pull/456"
```

## Quick Reference Card

| Action | Command |
|--------|---------|
| Read ticket | `linearis issues read TEAM-123` |
| Update state | `linearis issues update TEAM-123 --state "State"` |
| Add comment | `linearis comments create TEAM-123 --body "text"` |
| Search | `linearis issues search "keyword" --team TEAM` |
| List issues | `linearis issues list --team TEAM --limit N` |
| Active cycle | `linearis cycles list --team TEAM --active` |
| Cycle details | `linearis cycles read "Name" --team TEAM` |

## Important Rules

1. **--state NOT --status**: Always use `--state` for issue state updates
2. **comments create**: Use `linearis comments create`, not `issues comment`
3. **issues read**: Use `read`, not `get` or `view`
4. **Filtering via jq**: No `--filter` or `--status` flags - pipe to jq instead
5. **Team parameter**: Most commands need `--team TEAM-KEY`
6. **Quotes for spaces**: `--cycle "Sprint 2025-11"` not `--cycle Sprint 2025-11`
7. **JSON output**: All commands return JSON - use jq for parsing

## Getting Help

```bash
linearis --help
linearis issues --help
linearis issues update --help
linearis comments --help
linearis cycles --help
```
