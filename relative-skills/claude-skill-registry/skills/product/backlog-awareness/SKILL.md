---
name: backlog-awareness
description: Check project backlog when discussing feature ideas or priorities. Use when user mentions adding features, asks what's planned, discusses priorities, or proposes new functionality. Silently reads backlog.json to show relevant items and suggest /feature-capture for untracked ideas.
allowed-tools: Read, Glob
---

# Backlog Awareness

Automatically check the project backlog when the user discusses feature ideas, priorities, or planned work.

## When to Use

Invoke this skill when the user:
- Proposes new functionality: "We should add...", "It would be nice if...", "What if we..."
- Asks about planned work: "What features are planned?", "Is X in the backlog?"
- Discusses priorities: "What should we work on next?", "What's most important?"
- Mentions a specific feature by name that might be tracked

## Instructions

### Step 1: Load the Backlog
```
Read: docs/planning/backlog.json
```

If the file doesn't exist, inform the user:
```
No backlog found at docs/planning/backlog.json.
Use /feature-capture to start tracking features.
```

### Step 2: Analyze User Intent

Determine what the user is asking about:
- **New idea**: Check if it's already tracked
- **Status query**: Find matching items
- **Priority question**: Show items by priority

### Step 3: Search for Matches

For new ideas or feature mentions:
1. Search `items` array for matching:
   - `name` (partial match, case-insensitive)
   - `problemStatement` (keyword match)
   - `affectedAreas` (if user mentions specific areas)

2. Categorize results:
   - Exact matches (same feature exists)
   - Related items (similar features or same area)

### Step 4: Respond Appropriately

**If feature exists in backlog:**
```
This feature is already tracked:

**[name]** (ID: [id])
- Status: [status]
- Priority: [priority]
- Problem: [problemStatement]

[If status is "backlog"]: Ready to start? Use `/feature-plan [id]`
[If status is "in-progress"]: Currently being worked on.
[If status is "completed"]: Already completed on [completedAt].
```

**If related items exist:**
```
Related items in backlog:
- [name] ([id]) - [status] - [brief description]

Your idea might be:
- An extension of [related item]
- A separate feature worth tracking

Add as new item? Use `/feature-capture`
```

**If not tracked:**
```
This isn't tracked in the backlog yet.

To add it: `/feature-capture`
```

## Output Format

Keep responses concise. Show:
- Matching/related backlog items (if any)
- Current status of matches
- Clear next action (implement existing or add new)

## Integration Notes

This skill works with:
- `/feature-capture` - Suggest when idea isn't tracked
- `/feature-plan` - Suggest when item is ready to start
- `status-dashboard` skill - For broader status queries
