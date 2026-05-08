---
name: discord-read
description: "Read and search synced Discord messages. Use when user asks about discord conversations, wants to see messages, or search for specific content."
---

# Discord Read

Read locally synced Discord messages and search for specific content.

## When to Use

- User asks "what's in #channel"
- User asks about recent Discord conversations
- User wants to search Discord messages
- User asks "show me messages from Discord"
- User wants to find specific Discord discussion

## How to Execute

### Read all messages from a channel:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_read.py --channel CHANNEL_NAME
```

### Read last N messages:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_read.py --channel general --last 20
```

### Search for keyword:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_read.py --channel general --search "project update"
```

### Filter by date range:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_read.py --channel general --from 2026-01-01 --to 2026-01-03
```

### Read from specific server:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_read.py --channel general --server SERVER_ID
```

## Alternative: Direct File Read

For simpler access, first check what data exists using the manifest:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_manifest.py
```

Then read the markdown file directly (paths from manifest are relative to cwd):

```bash
cat ./data/{server_id}/{channel_name}/messages.md
```

## Output Format

Messages are formatted in Markdown with:
- Date headers (## YYYY-MM-DD)
- Message headers (### Time - @author)
- Reply indicators (↳ replying to @user)
- Attachments and embeds
- Reactions

## Prerequisites

- Messages must be synced first using discord-sync skill
- Channel name must match synced channel (case-insensitive)

## Error Handling

If messages are not found, the tool suggests running sync first.
