---
name: issue-workflow
description: Manage GitHub issues workflow - update status, add comments, create follow-ups. Use when starting work on an issue, completing an issue, or encountering blockers. Triggers on "issue", "close issue", "update issue", "blocked".
allowed-tools: Bash, Read
---

# GitHub Issue Workflow Manager

## Instructions

### Starting Work on an Issue

1. Fetch issue details:
   ```bash
   gh issue view <number> --repo chaoming/ww2-flutter-game
   ```

2. Add "in progress" comment:
   ```bash
   gh issue comment <number> --repo chaoming/ww2-flutter-game --body "Started working on this issue."
   ```

### Completing an Issue

1. Ensure all acceptance criteria are met
2. Close the issue with a summary:
   ```bash
   gh issue close <number> --repo chaoming/ww2-flutter-game --comment "Completed. Summary of changes: ..."
   ```

### Creating Follow-up Issues

If work reveals additional tasks:
```bash
gh issue create --repo chaoming/ww2-flutter-game \
  --title "Follow-up: <title>" \
  --label "<label>" \
  --body "Discovered while working on #<parent-number>. ..."
```

### Handling Blockers

1. Add blocker comment:
   ```bash
   gh issue comment <number> --repo chaoming/ww2-flutter-game \
     --body "Blocked by: <reason>. Need: <what's needed>"
   ```

2. If blocked by another issue, link them:
   ```bash
   gh issue comment <number> --repo chaoming/ww2-flutter-game \
     --body "Blocked by #<blocking-issue>"
   ```

## Project Labels
- `foundation` - M1: Foundation phase
- `core-gameplay` - M2: Core gameplay phase
- `combat-ai` - M3: Combat & AI phase
- `polish` - M4: Polish & Modes phase
- `models` - Data models
- `ui` - User interface
- `game-logic` - Game logic & mechanics
- `ai` - AI opponent
