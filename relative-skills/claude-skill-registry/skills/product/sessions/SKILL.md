---
name: sessions
description: Sessions plugin setup and profile management. Activate when the user mentions sessions, setup, profile, or improvements.
---

# Sessions Skill

Record coding improvements to your profile at sessions.shotgun.dev.

## When to Activate

Activate this skill when:
- User mentions "sessions", "profile", or "improvements"
- User asks about recording what they learned
- User wants to track their coding progress
- After completing a significant task where the user learned something new

## Using the Improve Tool

The MCP server provides the `improve` tool for recording improvements.

Call it with a single `thing` parameter - a concise description of what was learned or improved:

```
improve({ thing: "Learned to use PostgreSQL arrays for storing OAuth scopes" })
```

Good improvements to record:
- New techniques or patterns learned
- Bug fixes and what caused them
- Configuration discoveries
- Best practices adopted
- Tools or libraries explored

Keep improvements concise and specific.
