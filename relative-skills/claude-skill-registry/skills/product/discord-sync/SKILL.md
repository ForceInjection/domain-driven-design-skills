---
name: discord-sync
description: "Sync Discord messages using USER TOKEN. Supports servers AND DMs. Use when routed here by community-agent:discord-sync or user explicitly requests user token sync."
---

# Discord User Token Sync

Syncs messages from Discord servers AND DMs using user token authentication.

## When to Use

- Routed here by `community-agent:discord-sync` preflight check
- User explicitly asks for "user token sync"
- User wants to sync DMs (bots cannot access DMs)
- User wants rich profile data (bio, pronouns)

## When NOT to Use

- User just says "sync discord" - use `community-agent:discord-sync` instead (it will route here if appropriate)
- User wants faster sync with bot token - use `discord-bot-connector:discord-sync`

## Smart Defaults (Reduce Questions)

**When user is vague, apply these defaults instead of asking:**

| User Says | Default Action |
|-----------|----------------|
| "sync my Discord" | Sync the configured default server from agents.yaml |
| "sync [server name]" | Find server by name, sync with 7 days default |
| No --days specified | Default to 7 days |
| "sync everything" | List available servers and ask user to pick |

**Only ask for clarification when:**
- User's server name matches multiple servers
- User explicitly asks "which servers can I sync?"

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

### Sync DMs

**DMs are included by default.** Use `--no-dms` to sync servers only.

Sync all (servers + DMs):
```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_sync.py
```

Sync servers only (exclude DMs):
```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_sync.py --no-dms
```

Sync a specific DM by channel ID:
```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_sync.py --dm CHANNEL_ID
```

Sync DMs with custom message limit (default: 100):
```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_sync.py --dm-limit 500
```

## DM Message Limits

### DM Limit (`--dm-limit`)
- Default: 100 (privacy-conscious default)
- Lower than server channel limit by design
- Increase manually if needed: `--dm-limit 500`

### Server Channel Limit (`--limit`)
- Default: 200 for quick mode
- Use config file to set higher limits for full sync

## Output Location

All paths are relative to cwd (current working directory):

### Server Messages
Messages saved to: `./data/{server_id}/{channel_name}/messages.md`

Sync state tracked in: `./data/{server_id}/sync_state.yaml`

### DM Messages
DM messages saved to: `./dms/discord/{user_id}-{username}/messages.md`

DM manifest: `./dms/discord/manifest.yaml`

## Prerequisites

- `./.env` file with `DISCORD_USER_TOKEN` set (in cwd)
- `./config/agents.yaml` with `discord.default_server_id` configured (unless using --server flag)

## Bot Token Alternative

For faster server message sync with higher rate limits (no DM access), use `discord-bot-connector:discord-sync` instead.

## Incremental Sync

By default, sync is incremental - only new messages since last sync are fetched.
Use `--full` to re-sync all messages within the date range.

## Next Steps

After syncing, use discord-read skill to view or search messages.
