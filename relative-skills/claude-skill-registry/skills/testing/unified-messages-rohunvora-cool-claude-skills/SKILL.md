---
name: unified-messages
description: >
  Cross-platform messaging aggregator. Use as DEFAULT when user does NOT
  specify a platform (telegram/imessage). Provides unified inbox, search,
  and triage across both platforms. Triggers: "check messages" (no platform),
  "inbox", "who messaged me", "all my messages", "triage". NOT for platform-
  specific requests - use tg-ingest for "telegram X" or imsg-ingest for
  "imessage X".
---

# Unified Messages

Cross-platform aggregator for Telegram + iMessage. **Use when no platform specified.**

> If user says "telegram" → use tg-ingest skill
> If user says "imessage" → use imsg-ingest skill
> If user says "messages" (no platform) → use this skill

## Quick Start

```bash
# Sync both platforms
python -m unified.cli sync

# List pending threads
python -m unified.cli list

# Check status
python -m unified.cli status --detailed
```

## Thread ID Format

All threads use canonical IDs:
- **Telegram DM**: `tg:dm:username` (e.g., `tg:dm:vibhu`)
- **Telegram Group**: `tg:group:slug` (e.g., `tg:group:crypto_trenches`)
- **iMessage DM**: `imsg:dm:+14155551234` or `imsg:dm:email@example.com`
- **iMessage Group**: `imsg:group:chat123456`

## MCP Tools

| Tool | Purpose |
|------|---------|
| `unified_search` | Search people/threads across platforms |
| `unified_inbox` | List threads needing attention |
| `unified_get_person` | Full context for a person (threads, messages, notes) |
| `unified_get_thread` | Messages and state for specific thread |
| `unified_save_draft` | Save draft reply |
| `unified_set_status` | Set pending/done/archived |
| `unified_snooze` | Snooze until datetime |
| `unified_add_note` | Add note to thread |
| `unified_sync` | Sync both platforms |

## Workflows

### Daily Triage
1. `unified_sync` - Pull latest
2. `unified_inbox` - See what needs attention
3. Review each thread, then `set_status("done")` or `save_draft()`

### Find a Person
1. `unified_search("vibhu")` - Returns person with all thread IDs
2. `unified_get_person("vibhu")` - Full context with recent messages

### Reply Workflow
1. `unified_get_thread("tg:dm:username")` - Read conversation
2. `unified_save_draft("tg:dm:username", "Draft...")` - Save draft
3. Send manually in Telegram/iMessage
4. `unified_set_status("tg:dm:username", "done")` - Mark complete

## Project Structure

```
unified-messages/
├── unified/
│   ├── cli.py          # CLI (sync, status, list, generate, render)
│   ├── aggregator.py   # Cross-platform search, inbox, sync
│   ├── router.py       # Routes to correct platform
│   ├── contacts.py     # Person-centric contact resolution
│   └── triage.py       # Triage context generation
├── mcp_server.py       # MCP server (9 tools)
└── data/contacts.json  # Person registry
```

## Platform Dependencies

Imports from sibling repos:
- `tg-ingest/` - Telegram (Telethon)
- `imsg-ingest/` - iMessage (SQLite chat.db)

See [references/cli-commands.md](references/cli-commands.md) for full CLI docs.
See [references/data-locations.md](references/data-locations.md) for data paths.
