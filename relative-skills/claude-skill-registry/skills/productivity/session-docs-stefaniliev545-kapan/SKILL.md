---
name: session-docs
description: Load when closing beads tasks, ending significant sessions, or when planning discussions need to be captured
---

# Session Documentation

Complements beads (task-level tracking) and skills (pattern-level knowledge) with **session-level context** - capturing decisions, rationale, and user thoughts that connect individual tasks.

## Philosophy

- **Beads tasks** track *what* was done
- **Skills** capture *how* to do recurring things  
- **Session docs** capture *why* decisions were made and user intent

Don't duplicate - reference beads task IDs, create issues for actionable items.

## Session Storage

Sessions are stored in `.beads/sessions.jsonl` with this structure:

```jsonl
{
  "id": "session-<short-id>",
  "date": "2025-12-30",
  "title": "Brief descriptive title",
  "summary": "1-2 sentence overview",
  "decisions": [
    {
      "topic": "What was decided",
      "choice": "The decision made",
      "rationale": "Why this over alternatives",
      "alternatives_considered": ["alt1", "alt2"]
    }
  ],
  "user_thoughts": "Captured user intent, preferences, or ideas expressed during session",
  "problems_encountered": ["Problem 1 and how it was resolved"],
  "related_tasks": ["kapan-xxx", "kapan-yyy"],
  "created_issues": ["kapan-zzz"]
}
```

## Writing Good Close Reasons

When closing beads tasks, write close reasons that capture **rationale**, not just actions:

### Weak Close Reasons
- "Done"
- "Fixed the bug"
- "Created the component"

### Strong Close Reasons
- "Fixed by adding null check - root cause was async race condition where user data loaded before auth completed"
- "Created StickySection component using Intersection Observer for performance over scroll listeners"
- "Kept hooks separate - they serve different purposes (swap tx data vs quote-only) despite similar names"

**Pattern**: `[What was done] - [why this approach / what was learned]`

## When to Write Session Summaries

Write a session summary when:
- Significant planning discussion occurred (like architecture decisions)
- Multiple related tasks were completed as part of a larger effort
- User expressed preferences/intent worth preserving
- Problems were solved in non-obvious ways

Don't write summaries for:
- Quick single-task sessions (the beads task itself is enough)
- Sessions that only involved exploration/reading

## Capturing User Planning Discussions

When the user is thinking through a problem or making decisions:

1. **Listen for expressed preferences** - "I want...", "I prefer...", "Let's do X over Y"
2. **Note the rationale they give** - even partial reasoning is valuable
3. **Extract actionable items** - create beads issues for concrete next steps
4. **Summarize their thought process** - helps future sessions understand intent

### Example Flow

User says: "I'm thinking we should store this in beads rather than a separate folder - keeps things together, and we already have the tooling. Though I'm not sure about the schema yet."

Capture as:
```json
{
  "decisions": [{
    "topic": "Session docs storage location",
    "choice": ".beads/sessions.jsonl",
    "rationale": "Consolidates tooling, avoids separate system",
    "alternatives_considered": ["docs/devlog/", "extend interactions.jsonl"]
  }],
  "user_thoughts": "User prefers consolidation over separation. Schema details still open."
}
```

If there's a concrete next step, create a beads issue.

## Template: Writing a Session Summary

```bash
# 1. Review what happened
beads list  # see tasks touched this session

# 2. Write the session entry (append to sessions.jsonl)
# Include: decisions made, user intent captured, any new issues created

# 3. Link back - mention session ID in related task close_reasons if helpful
```

## Don't Over-Document

- Keep summaries brief (aim for <200 words)
- Skip sessions that don't have meaningful decisions
- One session = one entry (don't split or combine artificially)
- Reference beads tasks instead of re-describing work
