---
name: ha-emby-issue-selector
description: Use when starting work to select the next issue - queries GitHub project board, applies priority logic, and routes to the appropriate workflow (bug-triage or issue-executor).
---

# Home Assistant Emby Issue Selector

## Overview

**Select the next issue to work on using priority-based logic and route to the appropriate workflow.**

This skill queries the GitHub project board, prioritizes issues, and directs you to either bug investigation or implementation based on issue type and status.

## When to Use

- Starting a work session
- Completed an issue and need the next one
- User asks "what should I work on?"
- User asks to "pick up the next issue"

## Priority Order

Issues are selected in this priority order:

| Priority | Criteria | Action |
|----------|----------|--------|
| 1 | `priority: critical` + `bug` + `confirmed` | Fix immediately |
| 2 | `priority: high` + `bug` + `confirmed` | Fix next |
| 3 | `priority: critical` + `bug` + `ai-triaged` | Investigate to confirm |
| 4 | `priority: high` + `bug` + `ai-triaged` | Investigate to confirm |
| 5 | `status: in-progress` + assigned to me | Resume existing work |
| 6 | `priority: critical` + `enhancement` | Implement high-value feature |
| 7 | `priority: high` + `enhancement` | Implement important feature |
| 8 | `priority: medium` + `bug` + `confirmed` | Fix medium bugs |
| 9 | `priority: medium` + `bug` + `ai-triaged` | Investigate medium bugs |
| 10 | `priority: medium` + `enhancement` | Medium features |
| 11 | `priority: low` + any | Low priority items |
| 12 | Oldest unassigned | Backlog items |

## Selection Workflow

### Step 1: Check for In-Progress Work

```bash
# Check if I have work in progress
gh issue list \
  --label "status: in-progress" \
  --assignee @me \
  --state open \
  -L 5

# Also check episodic memory for session context
```

**If in-progress work exists:** Resume that issue first.

### Step 2: Query High-Priority Items

```bash
# Critical confirmed bugs (highest priority)
gh issue list \
  --label "bug" \
  --label "confirmed" \
  --label "priority: critical" \
  --state open \
  -L 5

# High-priority confirmed bugs
gh issue list \
  --label "bug" \
  --label "confirmed" \
  --label "priority: high" \
  --state open \
  -L 5

# Critical bugs needing investigation
gh issue list \
  --label "bug" \
  --label "ai-triaged" \
  --label "priority: critical" \
  --state open \
  -L 5

# High-priority bugs needing investigation
gh issue list \
  --label "bug" \
  --label "ai-triaged" \
  --label "priority: high" \
  --state open \
  -L 5
```

### Step 3: Query Enhancement Requests

```bash
# High-priority enhancements
gh issue list \
  --label "enhancement" \
  --label "priority: high" \
  --state open \
  -L 5

# Medium-priority enhancements
gh issue list \
  --label "enhancement" \
  --label "priority: medium" \
  --state open \
  -L 5
```

### Step 4: Check Medium/Low Priority

```bash
# Medium-priority bugs
gh issue list \
  --label "bug" \
  --label "priority: medium" \
  --state open \
  -L 5

# Low-priority items
gh issue list \
  --label "priority: low" \
  --state open \
  -L 5
```

### Step 5: Fallback - Oldest Issues

```bash
# Oldest unassigned open issues
gh issue list \
  --state open \
  --json number,title,labels,createdAt \
  --jq 'sort_by(.createdAt) | .[0:5]'
```

## Routing Logic

After selecting an issue, route to the appropriate skill:

```
┌─────────────────────────────────────────────────────────────────┐
│                      ROUTING DECISION                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Has label "bug"?                                               │
│       │                                                         │
│       ├── YES ──► Has label "confirmed"?                        │
│       │                │                                        │
│       │                ├── YES ──► ha-emby-issue-executor       │
│       │                │           (Fix the bug)                │
│       │                │                                        │
│       │                └── NO ───► ha-emby-bug-triage           │
│       │                            (Investigate first)          │
│       │                                                         │
│       └── NO ───► Has label "enhancement" or "feature"?         │
│                        │                                        │
│                        ├── YES ──► ha-emby-issue-executor       │
│                        │           (Implement feature)          │
│                        │                                        │
│                        └── NO ───► Has label "question"?        │
│                                        │                        │
│                                        ├── YES ──► Answer or    │
│                                        │           skip         │
│                                        │                        │
│                                        └── NO ───► Evaluate     │
│                                                    case-by-case │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Skip Conditions

**Skip issues with these labels:**

| Label | Reason |
|-------|--------|
| `needs-info` | Waiting on reporter |
| `status: blocked` | External dependency |
| `upstream` | Emby server issue |
| `ha-core` | Home Assistant core issue |
| `status: wontfix` | Won't be addressed |
| `status: duplicate` | Already handled elsewhere |

```bash
# Exclude blocked issues from query
gh issue list \
  --label "bug" \
  --label "confirmed" \
  --state open \
  --json number,title,labels \
  --jq '[.[] | select(.labels | map(.name) | contains(["needs-info"]) | not)]'
```

## Output Format

After selecting an issue, announce:

```
## Selected Issue

**Issue:** #42 - WebSocket disconnects on server restart
**Type:** Bug (confirmed)
**Priority:** High
**Components:** websocket, api
**Assigned:** @me

**Routing to:** ha-emby-issue-executor

**Next steps:**
1. Create branch: `issue-42-websocket-reconnect`
2. Review issue details and comments
3. Begin TDD implementation
```

Or for bugs needing investigation:

```
## Selected Issue

**Issue:** #43 - Media player shows wrong album art
**Type:** Bug (needs investigation)
**Priority:** Medium
**Components:** media-player, api
**Assigned:** @me

**Routing to:** ha-emby-bug-triage

**Next steps:**
1. Start local HA environment
2. Configure to match reporter's setup
3. Attempt reproduction
4. Gather evidence
5. Update issue with findings
```

## Claim the Issue

Before routing, claim the issue:

```bash
# Assign to self
gh issue edit {N} --add-assignee @me

# Update status
gh issue edit {N} --add-label "status: investigating"
# or
gh issue edit {N} --add-label "status: in-progress"

# Comment that work is starting
gh issue comment {N} --body "Starting investigation on this issue."
```

## Memory Integration

**Check episodic memory first:**

- Previous work on this issue?
- Related issues already investigated?
- Decisions made in prior sessions?

**After selecting:**

- Record selected issue in memory
- Note routing decision
- Track session start

## Common Scenarios

### Scenario: User says "work on bugs"

```bash
# Focus query on bugs only
gh issue list \
  --label "bug" \
  --state open \
  --json number,title,labels \
  -L 20

# Apply priority ordering
# Route based on confirmed/unconfirmed
```

### Scenario: User says "what's the most urgent?"

```bash
# Query critical first
gh issue list --label "priority: critical" --state open -L 5

# Then high priority
gh issue list --label "priority: high" --state open -L 5
```

### Scenario: User says "continue where I left off"

```bash
# Check in-progress first
gh issue list --label "status: in-progress" --assignee @me --state open

# Check memory for last session's work
```

### Scenario: User points to specific issue

Skip selection, validate the issue exists, claim it, and route directly.

## Related Skills

| Routing To | Skill | When |
|------------|-------|------|
| Bug investigation | `ha-emby-bug-triage` | Bug without `confirmed` label |
| Implementation | `ha-emby-issue-executor` | Confirmed bugs, features |
| GitHub queries | `ha-emby-github` | CLI commands, labels |

**Cross-references:**
- For priority label meanings → See `ha-emby-github` § "Priority Labels"
- For component labels → See `ha-emby-github` § "Component Labels"
- For status labels → See `ha-emby-github` § "Status Labels"

## The Bottom Line

1. **Check in-progress work first**
2. **Query by priority order**
3. **Skip blocked/waiting issues**
4. **Claim before routing**
5. **Route to correct workflow:**
   - Unconfirmed bugs → `ha-emby-bug-triage`
   - Confirmed bugs → `ha-emby-issue-executor`
   - Features → `ha-emby-issue-executor`
