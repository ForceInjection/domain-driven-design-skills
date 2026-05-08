---
name: stickies
description: Display and read Stickies notes on macOS. Use when the user asks to show notes, create stickies, or read existing stickies.
---

# Stickies Skill Guide

Display content in a sticky note on screen:

```bash
scripts/iStickies.sh "<content>"
```

Read all currently displayed stickies:

```bash
scripts/iStickies.sh --read
```

Supports markdown formatting:

- `# Title`, `## Subtitle`, `### Section`
- `**bold**` and `*italic*`
- `- bullet points`
- `1. numbered lists`
- `` `code` ``

Use for:

- Quick notes to user
- Task summaries
- Important reminders

Note: Requires Accessibility permissions for Terminal.
