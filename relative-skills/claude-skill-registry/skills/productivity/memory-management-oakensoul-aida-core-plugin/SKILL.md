---
name: memory-management
description: Automatically manage user's personal memory, context, and decision tracking. Invoked when context updates are needed or decisions are made.
---

# Memory Management Skill

Automatically maintain the user's personal memory system in `~/.claude/memory/`.

## Directory Structure
```
~/.claude/memory/
├── context.md          # Current state (updated frequently)
├── decisions.md        # Decision log with rationale
└── history/
    └── YYYY-MM.md      # Monthly archives
```

## Automatic Activation

This skill activates automatically when:
- User says "remember" or "I decided"
- Significant work is completed
- Day transitions (start-day, end-day)
- Context changes substantially
- User explicitly requests memory operation

## Core Operations

### 1. Update Context

Update `context.md` with current state:
```markdown
# Current Context
Last Updated: {ISO timestamp}

## Current Focus
{What user is currently working on}

## Recent Activity
- {Timestamp}: {What happened}
- {Timestamp}: {What happened}

## Active Projects
- {Project name}: {Status and notes}

## Pending Items
- {Action item}
- {Action item}

## Important Notes
{Any context-specific notes}
```

**Rules:**
- Keep concise (< 2000 tokens)
- Most recent first
- Remove stale items
- Include timestamps
- Be specific and actionable

### 2. Log Decisions

Append to `decisions.md`:
```markdown
## {YYYY-MM-DD}: {Decision Title}

**Context**: {Why this decision came up}

**Decision**: {What was decided}

**Rationale**: {Why this choice makes sense}

**Alternatives Considered**:
- {Option A}: {Why not chosen}
- {Option B}: {Why not chosen}

**Expected Impact**: {What this affects}

**Related**: {Links to projects or other decisions}

---
```

**When to log:**
- User explicitly states a decision
- User chooses between options
- Direction changes
- Important commitment made

### 3. Archive to History

At month-end, create/append to `history/YYYY-MM.md`:
```markdown
# {Month Year}

## Summary
{High-level summary of the month}

## Major Decisions
{List of significant decisions}

## Project Progress  
{Status updates on projects}

## Lessons Learned
{Key takeaways}

---

## Detailed Timeline
{Chronological log of significant events}
```

## File Management

### Creating Files
If files don't exist, create with templates above.

### Reading Files
Always read before updating to maintain continuity.

### Writing Files
- Use append for logs (decisions.md, history)
- Overwrite for current state (context.md)
- Include timestamps
- Maintain formatting

### Error Handling
- If file is corrupted, attempt recovery
- If file is missing, create from template
- If directory doesn't exist, create it
- Always inform user of issues

## Integration with Commands

This skill works with:
- `/remember` - Triggers decision/context logging
- `/recall` - Reads from memory files
- `/start-day` - Updates context for new day
- `/end-day` - Archives and summarizes
- `/init-aida` - Creates initial files

## Best Practices

1. **Be Concise**: Memory files are loaded in every session
2. **Be Specific**: Generic notes aren't helpful later
3. **Include Context**: Future you needs to understand
4. **Timestamp Everything**: Know when things happened
5. **Link Related Items**: Connect decisions to projects
6. **Archive Regularly**: Keep active files lean
