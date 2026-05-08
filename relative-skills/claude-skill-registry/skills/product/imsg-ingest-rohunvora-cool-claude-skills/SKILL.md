---
name: imsg-ingest
description: >
  Primary iMessage interface. Full-featured CLI for message export, conversation
  management, contact resolution, and thread state. Use when user mentions
  "imessage", "imsg", "text message", "iphone messages", or phone numbers.
  Triggers: "imessage messages", "export imessage", "text from john",
  "imessage contacts", "sync imessage". This is STANDALONE - do not defer
  to unified-messages for iMessage operations.
---

# iMessage Export (imsg-ingest)

Primary interface for all iMessage operations. **Standalone and full-featured.**

**Location**: `/Users/satoshi/data/imsg-ingest`

## Quick Start

```bash
cd /Users/satoshi/data/imsg-ingest

# Check access (MUST have Full Disk Access)
poetry run imsg status

# Sync messages
poetry run imsg sync

# List conversations
poetry run imsg list

# Export specific conversation
poetry run imsg dump "+14155551234" --output john.jsonl
```

## Prerequisites

**Full Disk Access required.** See [references/setup.md](references/setup.md) for setup.

## Core Workflows

### Quick Export for AI Context (Recommended)

Get recent messages as markdown, ready to paste into Claude:

```bash
# Syncs first, outputs to stdout (last 24h)
python scripts/quick_export.py "+14155551234"

# By contact name
python scripts/quick_export.py "John Doe" --hours 48

# Copy to clipboard
python scripts/quick_export.py "+14155551234" | pbcopy

# Visual copy in browser
python scripts/quick_export.py "+14155551234" | quick-view

# Intentional save
python scripts/quick_export.py "+14155551234" --save
# → exports/14155551234_2026-01-02.md
```

See [references/files.md](references/files.md) for file management philosophy.

### Export via CLI (Alternative)

```bash
# By phone number
poetry run imsg dump "+14155551234" --output john.jsonl

# By email
poetry run imsg dump "john@example.com" --output john.jsonl

# By name (searches contacts)
poetry run imsg dump "John Doe" --output john.jsonl

# Last 7 days only
poetry run imsg dump "+14155551234" --last 7d --output john.jsonl
```

### Sync Operations

```bash
# Sync new messages (forward)
poetry run imsg sync

# Backfill older messages
poetry run imsg sync --backfill
```

### List Conversations

```bash
# All conversations
poetry run imsg list

# DMs only
poetry run imsg list --no-groups

# Groups only
poetry run imsg list --no-dms

# With minimum message count
poetry run imsg list --min-messages 10
```

### Export All Conversations

```bash
# Export all with 10+ messages
poetry run imsg dump-all --min-messages 10

# Limit messages per chat
poetry run imsg dump-all --limit-per-chat 500
```

### Contact Resolution

```bash
# Check contact system status
poetry run imsg contacts status

# Lookup a contact
poetry run imsg contacts lookup "+14155551234"

# List all contacts
poetry run imsg contacts list

# Refresh contacts from AddressBook
poetry run imsg contacts sync

# Update exports with contact names
poetry run imsg contacts refresh-exports
```

See [references/contacts.md](references/contacts.md) for resolution backends.

## Data Locations

| Path | Purpose |
|------|---------|
| `data/conversations/` | Exported conversations (*.jsonl) |
| `data/sync-state.json` | Sync state (rowid tracking) |
| `data/context/state.json` | Thread states (done/draft/snooze) |

### Source Database

```
~/Library/Messages/chat.db
```

Read-only SQLite access. Requires Full Disk Access.

## Thread ID Format

iMessage threads use format: `imsg:dm:identifier` or `imsg:group:chatID`

Examples:
- `imsg:dm:+14155551234` - DM with phone number
- `imsg:dm:john@example.com` - DM with email
- `imsg:group:chat123456` - Group chat

## Thread State

State stored in `data/context/state.json`. Same format as tg-ingest:

```json
{
  "imsg:dm:+14155551234": {
    "status": "pending",
    "draft": null,
    "note": "Follow up on project",
    "snooze": null
  }
}
```

States: `pending`, `done`, `archived`
