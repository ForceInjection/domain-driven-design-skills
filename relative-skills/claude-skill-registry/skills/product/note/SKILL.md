---
name: note
description: Quick capture for thoughts, observations, or ideas during research sessions. Use when the user types /note or wants to capture a quick thought without context-switching. Logs timestamped notes to activity.md. Supports both explicit /note command and natural language like "make a note" or "jot down".
---

# Quick Note Capture

> Quick capture for thoughts, observations, or ideas during a work session.

## When to Use
- When you have a quick thought you don't want to lose
- Observations during an experiment or analysis
- Ideas that pop up while working on something else
- Anything you want logged but don't want to context-switch for

## Syntax

```
/note [your thought here]
```

**Examples:**
```
/note Realized the preprocessing step might be dropping too many samples
/note Meeting with PI moved to Thursday
/note Try using rolling average instead of mean for smoothing
/note The cluster seems slower today - check job queue
```

## Execution Steps

### 1. Parse Input

Extract the note text from everything after `/note `.

### 2. Check for Today's Entry

Look in `.research/logs/activity.md` for an entry matching today's date:
- Pattern: `## YYYY-MM-DD` or `## [YYYY-MM-DD]`

### 3a. If Today's Entry Exists

Append the note to the existing entry's Notes section:

```markdown
## 2024-12-02

**Session focus**: [existing content]

**Notes**:
- [existing notes]
- [HH:MM] [New note text]  ← ADD HERE
```

If no Notes section exists in today's entry, add one:

```markdown
**Notes**:
- [HH:MM] [Note text]
```

### 3b. If No Entry for Today

Create a minimal placeholder entry that `/wrap_up` will expand later:

```markdown
## [YYYY-MM-DD]

**Session focus**: [To be filled by /wrap_up]

**Notes**:
- [HH:MM] [Note text]
```

Prepend this to `activity.md` after the templates section.

### 4. Confirm (Brief)

Single-line confirmation to minimize disruption:

```
📝 Noted.
```

Or if it created a new day entry:

```
📝 Noted. (Started today's entry - run /wrap_up later to complete it)
```

## Behavior Notes

### Speed is Priority
- No confirmation dialogs
- No follow-up questions
- Minimal output
- Get the user back to work immediately

### Timestamp Format
Use 24-hour time in user's local timezone:
```
- [14:32] Realized the threshold is too aggressive
- [15:45] PI suggested trying hierarchical clustering
```

### Multiple Notes Same Day
Each note appends to the Notes section:
```markdown
**Notes**:
- [09:15] Started fresh after coffee
- [11:30] The new approach is working better
- [14:22] Hit a wall with memory usage
- [16:45] Fixed it - was loading full dataset unnecessarily
```

### Integration with /wrap_up
When user runs `/wrap_up`, these notes are:
1. Preserved in the Notes section
2. Used to help infer session focus
3. May inform "Decisions made" if they mention choices

## Edge Cases

### Empty note
```
/note
```
Response:
```
What did you want to note? Usage: /note [your thought]
```

### Very long note
Accept it - the user knows what they need to capture. Don't truncate.

### Note looks like a task
If the note contains action words like "TODO", "need to", "should", "must":
```
📝 Noted. (This sounds like a task - want me to add it to tasks.md too? y/n)
```

Only ask this for obvious task-like notes, not for observations.

## Example Session

```
User: /note The correlation coefficient dropped after adding the new samples

RA: 📝 Noted.

[User continues working...]

User: /note Check if batch effect is causing this

RA: 📝 Noted.

[Later...]

User: /note Fixed it - needed to normalize by batch first

RA: 📝 Noted.

[End of day...]

User: /wrap_up

RA: Here's today's summary:
    ...
    **Notes**:
    - [10:23] The correlation coefficient dropped after adding the new samples
    - [10:45] Check if batch effect is causing this
    - [14:30] Fixed it - needed to normalize by batch first
    ...
```

## Related Skills
- `wrap-up` - Integrates notes into full daily summary
- `task` - For action items (use instead of /note for todos)
