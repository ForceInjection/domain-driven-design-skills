---
name: discord-sync
description: "Sync Discord messages to local storage. Use when user asks to sync, pull, fetch, or download Discord messages."
---

# Discord Sync

Syncs messages from Discord servers to local Markdown files for reading and analysis.

## When to Use

- User asks to "sync Discord messages"
- User asks to "pull messages from Discord"
- User wants to "get Discord history"
- User wants to "update Discord data"
- User wants to "download Discord messages"
- User asks to "fetch messages from #channel"

## How to Execute

### Sync all channels in configured server:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_sync.py
```

### Sync specific channel:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_sync.py --channel CHANNEL_ID
```

### Sync specific server:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_sync.py --server SERVER_ID
```

### Sync with custom history range:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_sync.py --days 7
```

### Full re-sync (ignore previous sync state):

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_sync.py --full
```

## Output Location

All paths are relative to cwd (current working directory):

Messages saved to: `./data/{server_id}/{channel_name}/messages.md`

Sync state tracked in: `./data/{server_id}/sync_state.yaml`

## Prerequisites

- `./.env` file with `DISCORD_USER_TOKEN` set (in cwd)
- `./config/server.yaml` with `server_id` configured (unless using --server flag)

## Incremental Sync

By default, sync is incremental - only new messages since last sync are fetched.
Use `--full` to re-sync all messages within the date range.

## Next Steps

After syncing, use discord-read skill to view or search messages.
