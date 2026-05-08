---
name: discord-init
description: "Initialize Discord configuration. Use when user wants to set up, configure, or connect their Discord account for the first time."
---

# Discord Init

Automatically configure the Discord server from your account.

## When to Use

- User says "set up Discord" or "configure Discord"
- User says "connect my Discord account"
- User says "initialize Discord"
- First time setup before syncing
- When `config/agents.yaml` doesn't exist or needs updating

## How to Execute

### Auto-detect and save server:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_init.py
```

### Select a specific server:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_init.py --server SERVER_ID
```

## What It Does

All paths are relative to cwd (current working directory):

1. Connects to Discord using your token from `./.env`
2. Lists all servers you have access to
3. If one server: auto-selects it
4. If multiple: selects the first one (or use `--server` to pick)
5. Saves configuration to `./config/agents.yaml`

## Output

Updates `./config/agents.yaml` with Discord settings:
- `discord.default_server_id`: Your Discord server ID
- `discord.default_server_name`: Server display name
- `data_dir`: Where messages are stored (shared setting)
- `discord.retention_days`: Default sync history

## Prerequisites

- `./.env` file with `DISCORD_USER_TOKEN` set (in cwd)
- Get your token: https://discordhunt.com/articles/how-to-get-discord-user-token

## Next Steps

After init, use discord-sync to download messages.
