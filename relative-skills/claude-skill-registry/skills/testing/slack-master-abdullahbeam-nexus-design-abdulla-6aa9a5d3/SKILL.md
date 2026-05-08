---
name: slack-master
description: Shared resource library for Slack integration skills. DO NOT load directly - provides common references (setup, API docs, error handling, authentication) and scripts used by slack-connect and individual Slack skills.
---

# Slack Master

**This is NOT a user-facing skill.** It's a shared resource library referenced by Slack integration skills.

## Purpose

Provides shared resources to eliminate duplication across:
- `slack-connect` - Meta-skill for Slack workspace operations
- `slack-send-message` - Send messages to channels/DMs
- `slack-list-channels` - List available channels
- `slack-search-messages` - Search message history
- And 29 other operation skills...

**Instead of loading this skill**, users directly invoke the specific skill they need above.

---

## Architecture: DRY Principle

**Problem solved:** Slack skills would have duplicated content (setup instructions, API docs, auth flow, error handling).

**Solution:** Extract shared content into `slack-master/references/` and `slack-master/scripts/`, then reference from each skill.

**Result:** Single source of truth, reduced context per skill.

---

## Authentication Model: User OAuth

This integration uses **User OAuth** (not Bot OAuth) for team-wide deployment:

```
┌─────────────────────────────────────────────────────────────┐
│  USER OAUTH (Per-User Authentication)                       │
├─────────────────────────────────────────────────────────────┤
│  • Each team member authenticates with their own account    │
│  • Messages sent appear as the user (not a bot)             │
│  • Users only see channels/DMs they have access to          │
│  • No cross-user data exposure possible                     │
│  • Token type: xoxp- (user tokens)                          │
└─────────────────────────────────────────────────────────────┘
```

**Why User OAuth?**
- Messages appear from the actual user, not a bot
- Respects existing channel permissions
- No need for bot installation in every channel
- Each user controls their own access

---

## Shared Resources

All Slack skills reference these resources (progressive disclosure).

### references/

**[setup-guide.md](references/setup-guide.md)** - Complete setup wizard
- Creating a Slack App with User OAuth
- Configuring OAuth scopes
- Getting client ID and secret
- Running the OAuth flow

**[api-reference.md](references/api-reference.md)** - Slack API patterns
- Base URL and authentication
- All 32 API endpoints documented
- Request/response examples
- Rate limiting info

**[error-handling.md](references/error-handling.md)** - Troubleshooting
- Common errors and solutions
- HTTP error codes
- Token expiration handling
- Scope issues

**[authentication.md](references/authentication.md)** - User OAuth flow
- OAuth 2.0 authorization flow
- Token exchange process
- Token refresh (Slack tokens don't expire normally)
- Per-user token storage

### scripts/

#### Authentication & Configuration

**[check_slack_config.py](scripts/check_slack_config.py)** - Pre-flight validation
```bash
python check_slack_config.py [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--json` | No | False | Output structured JSON for AI consumption |

Exit codes: 0=configured, 1=partial, 2=not configured

**When to Use:** Run this FIRST before any Slack operation. Use to validate user token is configured, diagnose authentication issues, or check if OAuth setup is needed.

---

**[setup_slack.py](scripts/setup_slack.py)** - Interactive OAuth wizard
```bash
python setup_slack.py
```
No arguments - runs interactively. Guides through OAuth authorization, gets user token, saves to `.env`.

**When to Use:** Use when Slack integration needs initial setup, when check_slack_config.py returns exit code 2, or when user needs to re-authenticate.

---

**[slack_client.py](scripts/slack_client.py)** - Shared API client
```python
from slack_client import get_client
client = get_client()
result = client.post('chat.postMessage', {'channel': 'C123', 'text': 'Hello'})
```

Provides:
- Automatic token loading from .env
- Request formatting for Slack API
- Error handling and response parsing
- Rate limit awareness

**When to Use:** Import this in all Slack operation scripts for consistent API access.

---

#### Message Operations

**[send_message.py](scripts/send_message.py)** - Send message (chat.postMessage)
```bash
python send_message.py --channel CHANNEL --text "Message" [--thread-ts TS] [--json]
```

**[update_message.py](scripts/update_message.py)** - Update message (chat.update)
```bash
python update_message.py --channel CHANNEL --ts TIMESTAMP --text "New text" [--json]
```

**[delete_message.py](scripts/delete_message.py)** - Delete message (chat.delete)
```bash
python delete_message.py --channel CHANNEL --ts TIMESTAMP [--json]
```

**[schedule_message.py](scripts/schedule_message.py)** - Schedule message (chat.scheduleMessage)
```bash
python schedule_message.py --channel CHANNEL --text "Message" --post-at UNIX_TS [--json]
```

---

#### Channel Operations

**[list_channels.py](scripts/list_channels.py)** - List channels (conversations.list)
```bash
python list_channels.py [--types public,private] [--limit N] [--json]
```

**[channel_info.py](scripts/channel_info.py)** - Get channel info (conversations.info)
```bash
python channel_info.py --channel CHANNEL [--json]
```

**[channel_history.py](scripts/channel_history.py)** - Get messages (conversations.history)
```bash
python channel_history.py --channel CHANNEL [--limit N] [--oldest TS] [--latest TS] [--json]
```

**[create_channel.py](scripts/create_channel.py)** - Create channel (conversations.create)
```bash
python create_channel.py --name NAME [--is-private] [--json]
```

---

#### User Operations

**[list_users.py](scripts/list_users.py)** - List workspace users (users.list)
```bash
python list_users.py [--limit N] [--json]
```

**[user_info.py](scripts/user_info.py)** - Get user info (users.info)
```bash
python user_info.py --user USER_ID [--json]
```

---

#### File Operations

**[upload_file.py](scripts/upload_file.py)** - Upload file (files.upload)
```bash
python upload_file.py --file PATH --channels C1,C2 [--title TITLE] [--json]
```

**[list_files.py](scripts/list_files.py)** - List files (files.list)
```bash
python list_files.py [--channel CHANNEL] [--user USER] [--limit N] [--json]
```

---

#### Search Operations

**[search_messages.py](scripts/search_messages.py)** - Search messages (search.messages)
```bash
python search_messages.py --query "search terms" [--count N] [--json]
```

**[search_files.py](scripts/search_files.py)** - Search files (search.files)
```bash
python search_files.py --query "search terms" [--count N] [--json]
```

---

## Intelligent Error Detection Flow

When a Slack skill fails due to missing configuration, the AI should:

### Step 1: Run Config Check with JSON Output

```bash
python 00-system/skills/slack/slack-master/scripts/check_slack_config.py --json
```

### Step 2: Parse the `ai_action` Field

The JSON output includes an `ai_action` field that tells the AI what to do:

| ai_action | What to Do |
|-----------|------------|
| `proceed_with_operation` | Config OK, continue with the original operation |
| `run_oauth_setup` | Run: `python setup_slack.py` to authorize |
| `check_scopes` | Token exists but missing required scopes |
| `token_revoked` | User revoked access, need to re-authorize |

### Step 3: Help User Fix Issues

If `ai_action` is `run_oauth_setup`:

1. Tell user: "Slack integration needs setup. Let's authorize your account."
2. Run: `python 00-system/skills/slack/slack-master/scripts/setup_slack.py`
3. User will be guided through OAuth flow
4. Token saved to `.env`
5. Re-run config check to verify

### JSON Output Structure

```json
{
  "status": "not_configured",
  "exit_code": 2,
  "ai_action": "run_oauth_setup",
  "missing": [
    {"item": "SLACK_USER_TOKEN", "required": true, "location": ".env"}
  ],
  "fix_instructions": [...],
  "setup_wizard": "python 00-system/skills/slack/slack-master/scripts/setup_slack.py"
}
```

---

## How Skills Reference This

Each skill loads shared resources **only when needed** (progressive disclosure):

**slack-connect** uses:
- `check_slack_config.py` (validate before any operation)
- All API scripts based on user request
- All references as needed

**slack-send-message** uses:
- `check_slack_config.py` (validate before sending)
- `send_message.py` (core functionality)
- `error-handling.md` (troubleshooting)

---

## Environment Variables

Required in `.env`:
```
# Slack User OAuth Token (starts with xoxp-)
SLACK_USER_TOKEN=xoxp-xxxxxxxxxxxxx

# Optional: For OAuth setup flow
SLACK_CLIENT_ID=your-client-id
SLACK_CLIENT_SECRET=your-client-secret
```

---

## Required OAuth Scopes (User Token)

```
channels:read        # List public channels
channels:write       # Create/manage public channels
channels:history     # Read public channel messages
groups:read          # List private channels
groups:write         # Create/manage private channels
groups:history       # Read private channel messages
im:read              # List DMs
im:write             # Manage DMs
im:history           # Read DM messages
mpim:read            # List group DMs
mpim:write           # Manage group DMs
mpim:history         # Read group DM messages
chat:write           # Send messages
users:read           # List users
users:read.email     # Get user emails
files:read           # List/download files
files:write          # Upload files
reactions:read       # Get reactions
reactions:write      # Add/remove reactions
pins:read            # List pinned items
pins:write           # Pin/unpin items
search:read          # Search messages/files
reminders:read       # List reminders
reminders:write      # Create/delete reminders
team:read            # Get team info
```

---

## API Base URL

All API requests go to: `https://slack.com/api/`

---

**Version**: 1.0
**Created**: 2025-12-17
**Status**: Production Ready
