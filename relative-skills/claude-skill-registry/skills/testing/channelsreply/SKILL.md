---
name: channels/reply
description: Reply to a specific message in a channel. Use this to respond to issues, answer questions, or continue threaded conversations.
license: MIT
---

# Reply to Message

Post a reply to an existing message, creating a threaded conversation.

## When to Use This Skill

Use this skill when:

- Responding to a reported issue with a fix or update
- Answering a question in a DM
- Providing status updates on an ongoing issue
- Continuing a conversation thread
- Acknowledging receipt of a message

## Process

### Step 1: Identify the Message

You need the message ID to reply to. Get this from:

- The output of `channels read`
- The message path (e.g., `2025-12-15T10:30:00.000Z`)

### Step 2: Compose Reply

Write your response to the original message.

### Step 3: Post Reply

```bash
npx dot-agents channels reply "<channel>" "<message-id>" "<reply>"
```

For multi-line replies:

```bash
npx dot-agents channels reply "<channel>" "<message-id>" "$(cat <<'EOF'
Your multi-line
reply here
EOF
)"
```

## Examples

### Example 1: Reply to an Issue

Original message in `#issues`:

```text
[2025-12-15T10:30:00.000Z] from: morning-paper
**Issue:** Calendar API timeout
```

Reply:

```bash
npx dot-agents channels reply "#issues" "2025-12-15T10:30:00.000Z" "$(cat <<'EOF'
**Status:** Resolved

Root cause: Network timeout due to VPN disconnection.
Fix: Added retry logic with exponential backoff.

Verified working in subsequent run.
EOF
)"
```

### Example 2: Quick Acknowledgment

```bash
npx dot-agents channels reply "@human" "2025-12-15T14:00:00.000Z" "Understood. Will proceed with the archive operation."
```

### Example 3: Request More Information

```bash
npx dot-agents channels reply "#issues" "2025-12-15T09:00:00.000Z" "$(cat <<'EOF'
Need more details to investigate:

1. Which workflow triggered this?
2. What was the exact error message?
3. Has this happened before?
EOF
)"
```

### Example 4: Status Update on Ongoing Issue

```bash
npx dot-agents channels reply "#issues" "2025-12-15T08:00:00.000Z" "$(cat <<'EOF'
**Update:** Still investigating

Tried:
- Restarting daemon (no effect)
- Clearing cache (no effect)

Next steps:
- Check system logs
- Test with fresh config
EOF
)"
```

## Best Practices

- Keep replies focused on the original topic
- Use structured formats for status updates
- Reference specific actions taken or planned
- Close the loop on issues when resolved
- Use replies rather than new messages for ongoing threads

## Thread Structure

Replies create a nested structure:

```text
channels/#issues/
  2025-12-15T10:30:00.000Z/
    message.md          # Original message
    replies/
      2025-12-15T11:00:00.000Z/
        message.md      # First reply
      2025-12-15T11:30:00.000Z/
        message.md      # Second reply
```

## Error Handling

**Message not found**: Verify the channel and message ID are correct.

**Invalid message ID format**: Use the full ISO 8601 timestamp from the original message.
