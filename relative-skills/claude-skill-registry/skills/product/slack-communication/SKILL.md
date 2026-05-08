---
name: Slack Communication
description: Send messages to Slack channels or users.
---

# Slack Skill

## Capabilities
- **Send Message**: Post a text message to a specific channel or user (`slack.post_message`).

## Usage
- Use when the user asks to "notify the team", "send a slack", or "alert #general".
- Good for async notifications of completed tasks (e.g. "I've finished the report, sending to Slack now").

## Constraints
- Requires the user to have connected their Slack account.
- Message content is currently text-only (no complex blocks yet).
