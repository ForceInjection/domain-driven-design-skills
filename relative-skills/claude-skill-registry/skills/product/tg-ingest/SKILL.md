---
name: tg-ingest
description: >
  Primary Telegram interface. Full-featured CLI for message export, DM management,
  group sync, contact scoring, and thread state. Use when user mentions "telegram",
  "tg", "@username", or telegram-specific terms. Triggers: "telegram messages",
  "export telegram", "telegram DMs", "telegram groups", "sync telegram",
  "@username messages", "telegram contacts". This is STANDALONE - do not defer
  to unified-messages for telegram operations.
---

# Telegram Export (tg-ingest)

Primary interface for all Telegram operations. **Standalone and full-featured.**

**Location**: `/Users/satoshi/data/tg-ingest`

## Quick Start

```bash
cd /Users/satoshi/data/tg-ingest

# Check status
poetry run tg_export status

# Sync all DMs + whitelisted groups
poetry run tg_export sync-all

# Export specific DM
poetry run tg_export dump-dm --user vibhu --out exports/vibhu.jsonl

# List DMs
poetry run tg_export list-dms
```

## Core Workflows

### Quick Export for AI Context (Recommended)

Get recent messages as markdown, ready to paste into Claude:

```bash
# Syncs first, outputs to stdout (last 24h)
python scripts/quick_export.py klutch

# Custom time range
python scripts/quick_export.py klutch --hours 48

# Copy to clipboard
python scripts/quick_export.py klutch | pbcopy

# Visual copy in browser
python scripts/quick_export.py klutch | quick-view

# Intentional save
python scripts/quick_export.py klutch --save
# → exports/klutch_2026-01-02.md
```

See [references/files.md](references/files.md) for file management philosophy.

### Export via CLI (Alternative)

```bash
# By username (pulls from API, may have caching issues)
poetry run tg_export dump-dm --user vibhu --out vibhu.jsonl

# Last 7 days only
poetry run tg_export dump-dm --user vibhu --last 7d --out vibhu.jsonl
```

**Note:** Prefer quick_export.py for reading synced data. Use dump-dm only for initial exports.

### Sync Operations

```bash
# One-shot sync (DMs + whitelisted groups)
poetry run tg_export sync-all

# Backfill older messages
poetry run tg_export sync-all --backfill

# Live continuous sync
poetry run tg_export live --interval 5m

# Sync DMs only
poetry run tg_export sync-dms --dir data/dms
```

### Manage Thread State

Thread states are stored in `data/decisions.jsonl`.

```bash
# Via CLI (if implemented) or direct file edit
# States: pending, done, archived
# Also supports: draft, snooze, note
```

See [references/state.md](references/state.md) for state management details.

### Manage Groups

```bash
# List registered groups
poetry run tg_export groups list

# Add a group to sync
poetry run tg_export groups add "crypto trenches" --type trading

# Sync groups
poetry run tg_export groups sync

# Backfill group history
poetry run tg_export groups backfill crypto_trenches --limit 1000
```

See [references/groups.md](references/groups.md) for registry management.

### Contact Lookup & Scoring

```bash
# Initialize contacts from DMs
poetry run tg_export contacts-init --dm-dir data/dms

# List contacts by priority
poetry run tg_export contacts-list --tier high

# Score all contacts
poetry run tg_export contacts-score

# Show contact details
poetry run tg_export contacts-show vibhu
```

See [references/contacts.md](references/contacts.md) for scoring algorithm.

## Data Locations

| Path | Purpose |
|------|---------|
| `data/dms/` | DM exports (*.jsonl + *.jsonl.idx) |
| `data/groups/` | Group exports |
| `data/registry.json` | Group registry |
| `data/decisions.jsonl` | Thread states |
| `data/session.session` | Telethon auth |
| `contacts/` | Contact database |

## Authentication

First-time setup:
```bash
# Set env vars (in .env or shell)
export TG_API_ID=your_id
export TG_API_HASH=your_hash

# Login (interactive)
poetry run tg_export login
```

Session persists in `data/session.session`.

## Thread ID Format

Telegram threads use format: `tg:dm:username` or `tg:group:slug`

Examples:
- `tg:dm:vibhu` - DM with @vibhu
- `tg:group:crypto_trenches` - Group chat
