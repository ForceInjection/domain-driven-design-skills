---
name: discord-send
description: "Send messages to Discord channels. Use when user wants to post, reply, or send messages to Discord."
---

# Discord Send

Send messages to Discord channels using your user token.

## Persona Context

**REQUIRED:** Before executing this skill, load your configured persona:

```bash
python ${CLAUDE_PLUGIN_ROOT}/../community-agent/tools/persona_status.py --prompt
```

This outputs your persona definition. Apply it when composing messages:
- **Voice**: Write in first person as the persona ("I recommend..." not "The system suggests...")
- **Style**: Match the persona's communication style (formal/friendly/technical)
- **Personality**: Reflect the persona's traits in how you write
- **Signing**: Sign messages with persona name if appropriate for the context

## When to Use

- User asks to "send to Discord"
- User asks to "post in #channel"
- User asks to "reply to Discord message"
- User wants to "respond to that Discord conversation"
- User wants to post a message they composed

## How to Execute

### Send a message to a channel:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_send.py --channel CHANNEL_ID --message "Your message here"
```

### Reply to a specific message:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_send.py --channel CHANNEL_ID --message "Your reply" --reply-to MESSAGE_ID
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| --channel | Yes | Target channel ID |
| --message | Yes | Message content (max 2000 chars) |
| --reply-to | No | Message ID to reply to |

## Finding Channel IDs

Use discord-list skill to find channel IDs:
```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_list.py --channels SERVER_ID
```

## Finding Message IDs

Message IDs can be found in:
1. The messages.md files (in message headers)
2. Discord's Developer Mode (right-click → Copy ID)
3. The sync_state.yaml (last_message_id)

## Output

On success, returns:
- Message ID
- Channel ID
- Timestamp
- Reply target (if applicable)

## Limitations

- Maximum message length: 2000 characters
- Rate limited (automatic backoff)
- Requires valid user token in `./.env` (in cwd)

## Warning

Using a user token to send messages may violate Discord's Terms of Service. Use responsibly and at your own risk.
