---
name: xaffinity-cli-usage
description: Use when running xaffinity CLI commands, or when user asks to search, find, get, export, or list people, companies, opportunities, lists, or CRM data from Affinity via command line. Also use when user mentions "xaffinity", "export to CSV", or needs help with Affinity CLI commands.
---

# xaffinity CLI Usage

Use this skill when running xaffinity commands to interact with Affinity CRM.

## REQUIRED FIRST STEP: Verify API Key

**STOP. Before doing ANYTHING else, run this command:**

```bash
xaffinity config check-key --json
```

This MUST be your first action when handling any Affinity request.

**If `"configured": true`** - Use the `pattern` field from the output for ALL subsequent commands:
- If `"pattern": "xaffinity --dotenv --readonly <command> --json"` -> use `--dotenv`
- If `"pattern": "xaffinity --readonly <command> --json"` -> no `--dotenv` needed

**If `"configured": false`** - Stop and help user set up:
1. Tell them: "You need to configure an Affinity API key first."
2. Direct them: Affinity -> Settings -> API -> Generate New Key
3. Tell them to run: `xaffinity config setup-key` (do NOT run it for them - it's interactive)

## IMPORTANT: Write Operations Require Explicit User Request

**Always use `--readonly` unless user explicitly requests writes.**

Write operations include creating, updating, or deleting:
- Notes, interactions, reminders
- List entries, field values
- Persons, companies, opportunities

## Destructive Commands Require Double Confirmation

**IMPORTANT**: Before executing ANY delete command, you MUST:

1. **Look up the entity first** to show the user what will be deleted
2. **Ask the user in your response** by showing them the entity details and requesting confirmation
3. **Wait for user's next message** - do NOT proceed until they explicitly confirm
4. **Only after user confirms** should you run the delete with `--yes`

Example flow:
```
User: "Delete person 123"
You: xaffinity person get 123 --readonly --json
You: "This will permanently delete John Smith (ID: 123, email: john@example.com).
      Type 'yes' to confirm deletion."
[Stop here and wait for user's response]

User: "yes"
You: xaffinity person delete 123 --yes
```

**Destructive commands**: `person delete`, `company delete`, `opportunity delete`, `note delete`, `reminder delete`, `field delete`, `list entry delete`, `interaction delete`

**Note**: This is conversation-based confirmation - you ask, then wait for the user's next message. The `--yes` flag bypasses the CLI's interactive prompt, but you must get explicit user confirmation in the conversation first.

## Critical Patterns

| Pattern | Purpose |
|---------|---------|
| `--readonly` | Prevent accidental data modification (ALWAYS use) |
| `--json` | Structured, parseable output (ALWAYS use) |
| `--all` | Fetch all pages (for exports) |
| `--yes` | Skip confirmation on delete commands (use after user confirms) |
| `--help` | Discover command options (USE THIS, don't guess) |

## Common Commands

```bash
# Search/Get entities
xaffinity person search "John Smith" --json
xaffinity person get 123 --json
xaffinity person get email:alice@example.com --json
xaffinity company get domain:acme.com --json

# List all
xaffinity person ls --all --json
xaffinity company ls --all --json
xaffinity list ls --json

# Export to CSV
xaffinity person ls --all --csv contacts.csv --csv-bom
xaffinity list export LIST_ID --all --csv output.csv --csv-bom

# Export with expanded associations
xaffinity list export LIST_ID --expand people --all --csv output.csv
xaffinity list export LIST_ID --expand people --expand companies --all --csv output.csv
```

## Filtering (Custom Fields Only)

```bash
# Filter on custom fields
xaffinity person ls --filter 'Department = "Sales"' --all --json
xaffinity list export LIST_ID --filter 'Status = "Active"' --all --json

# Filter syntax
# = exact match
# =~ contains
# =^ starts with
# =$ ends with
# != * is NULL
# & AND
# | OR

# Examples
--filter 'Status = "Active" & Region = "US"'
--filter 'Status = "New" | Status = "Pending"'
```

**Cannot filter**: `name`, `email`, `domain`, `type` - use `--all` and post-process with `jq`.

## Gotchas & Workarounds

### Internal meetings NOT in interactions
The interactions API only shows meetings with **external** contacts.
```bash
# Returns NOTHING for internal-only meetings:
xaffinity interaction ls --person-id 123 --type meeting ...

# Workaround - use notes:
xaffinity note ls --person-id 123 --json  # Filter for isMeeting: true
```

### Interactions require BOTH dates (max 1 year)
```bash
# WRONG:
xaffinity interaction ls --person-id 123 --type meeting --json

# CORRECT:
xaffinity interaction ls --person-id 123 --type meeting \
  --start-time 2025-01-01 --end-time 2025-12-31 --json
```

### Smart Fields not in API
"Last Meeting", "Next Meeting" are UI-only. Use:
```bash
xaffinity person search "Alice" --with-interaction-dates --json
xaffinity company search "Acme" --with-interaction-dates --json
```

### List filtering is client-side
All entries fetched, then filtered locally. For efficiency:
```bash
# INEFFICIENT - 3 API calls fetching same data:
xaffinity list export 123 --filter 'Status = "New"' --all --json > new.json
xaffinity list export 123 --filter 'Status = "Active"' --all --json > active.json

# BETTER - 1 API call, post-process:
xaffinity list export 123 --all --json > all.json
jq '[.[] | select(.Status == "New")]' all.json > new.json
jq '[.[] | select(.Status == "Active")]' all.json > active.json
```

### Opportunities bound to one list
Cannot move/copy opportunities between lists. Created with `--list-id`.

### Global organizations are read-only
Companies with `global: true` cannot be modified.

## Quick Reference

| Task | Command |
|------|---------|
| Find person by email | `person get email:user@example.com` |
| Find company by domain | `company get domain:acme.com` |
| Export all contacts | `person ls --all --csv contacts.csv --csv-bom` |
| Export pipeline with people | `list export LIST_ID --expand people --all --csv out.csv` |
| Get command help | `xaffinity <command> --help` |

## Installation

```bash
pip install "affinity-sdk[cli]"
```

## Documentation

- Full CLI reference: `xaffinity --help`
- SDK docs: https://yaniv-golan.github.io/affinity-sdk/latest/
