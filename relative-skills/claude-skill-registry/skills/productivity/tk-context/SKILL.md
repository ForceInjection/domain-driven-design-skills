---
name: tk-context
description: Dump full Tasuku context for agent consumption. Use when user says /tk:context or asks for full context, project state, or needs to understand the entire task landscape.
---

# Full Context Dump

Provide complete project context including all tasks, learnings, decisions, and notes.

## Instructions

1. Use the `tk_context` MCP tool to get the full `.tasuku.json` state
2. Present the information in a structured, scannable format
3. Highlight key items:
   - Tasks currently in progress (what's being worked on)
   - Blocked tasks and their blockers
   - Recent decisions that affect current work
   - Relevant learnings/rules

## Output Format

```
## Current Work
[List in_progress tasks with owner if set]

## Ready Queue
[List ready tasks sorted by priority]

## Blockers
[List blocked tasks and what's blocking them]

## Key Decisions
[Recent or relevant architectural decisions]

## Learnings & Rules
[Important insights, especially any marked as rules]

## Notes
[Any notes attached to active tasks]
```

## Notes

- This is meant for getting oriented at the start of a session
- Focus on actionable information
- Skip archived tasks unless specifically requested
- If context is large, summarize done tasks as a count
