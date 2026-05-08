---
name: slack-connect
description: Connect to Slack workspace for messaging and channel management. Load when user mentions 'slack', 'connect slack', 'slack message', 'slack channel', 'send to slack', or any Slack operations. Meta-skill that validates config, discovers workspace, and routes to appropriate operations.
---

# Slack Connect

**Entry point for all Slack operations.** Validates configuration, discovers workspace, and routes requests to appropriate skills.

## Trigger Phrases

Load this skill when user says:
- "slack" / "connect slack" / "slack connect"
- "send slack message" / "message [channel]"
- "list slack channels" / "slack channels"
- "search slack" / "find in slack"
- "slack users" / "who's on slack"
- Any reference to Slack operations

---

## Quick Reference

**First-time setup:**
```bash
python 00-system/skills/slack/slack-master/scripts/setup_slack.py
```

**Check configuration:**
```bash
python 00-system/skills/slack/slack-master/scripts/check_slack_config.py --json
```

---

## Workflow

### Step 1: Validate Configuration

**Always run first:**

```bash
python 00-system/skills/slack/slack-master/scripts/check_slack_config.py --json
```

**If `ai_action` is `proceed_with_operation`:**
- Continue to Step 2

**If `ai_action` is `run_oauth_setup`:**
1. Tell user: "Slack needs to be set up. Let me guide you through authorization."
2. Run: `python 00-system/skills/slack/slack-master/scripts/setup_slack.py`
3. After setup, re-check config

**If `ai_action` is `create_slack_app`:**
1. Guide user through creating a Slack App
2. Load: `slack-master/references/setup-guide.md`
3. After app created, run setup wizard

---

### Step 2: Identify User Intent

Parse what the user wants to do:

| User Says | Route To |
|-----------|----------|
| "send message to #general" | Messaging → send_message.py |
| "list channels" | Channels → list_channels.py |
| "get messages from #dev" | Channels → channel_history.py |
| "search for 'project update'" | Search → search_messages.py |
| "list users" | Users → list_users.py |
| "upload file" | Files → upload_file.py |
| "add reaction" | Reactions → (see Phase 7) |
| "pin message" | Pins → (see Phase 9) |
| "set reminder" | Reminders → (see Phase 10) |

---

### Step 3: Execute Operation

Use the appropriate script from `slack-master/scripts/`:

#### Messaging Operations

**Send message:**
```bash
python 00-system/skills/slack/slack-master/scripts/send_message.py \
  --channel "C1234567890" \
  --text "Hello from Nexus!" \
  --json
```

**Update message:**
```bash
python 00-system/skills/slack/slack-master/scripts/update_message.py \
  --channel "C1234567890" \
  --ts "1234567890.123456" \
  --text "Updated message" \
  --json
```

**Delete message:**
```bash
python 00-system/skills/slack/slack-master/scripts/delete_message.py \
  --channel "C1234567890" \
  --ts "1234567890.123456" \
  --json
```

#### Channel Operations

**List channels:**
```bash
python 00-system/skills/slack/slack-master/scripts/list_channels.py \
  --types "public_channel,private_channel" \
  --limit 50 \
  --json
```

**Get channel info:**
```bash
python 00-system/skills/slack/slack-master/scripts/channel_info.py \
  --channel "C1234567890" \
  --json
```

**Get channel history:**
```bash
python 00-system/skills/slack/slack-master/scripts/channel_history.py \
  --channel "C1234567890" \
  --limit 20 \
  --json
```

#### User Operations

**List users:**
```bash
python 00-system/skills/slack/slack-master/scripts/list_users.py \
  --limit 100 \
  --json
```

**Get user info:**
```bash
python 00-system/skills/slack/slack-master/scripts/user_info.py \
  --user "U1234567890" \
  --json
```

#### Search Operations

**Search messages:**
```bash
python 00-system/skills/slack/slack-master/scripts/search_messages.py \
  --query "project update" \
  --count 20 \
  --json
```

**Search files:**
```bash
python 00-system/skills/slack/slack-master/scripts/search_files.py \
  --query "report.pdf" \
  --count 10 \
  --json
```

#### File Operations

**Upload file:**
```bash
python 00-system/skills/slack/slack-master/scripts/upload_file.py \
  --file "/path/to/file.pdf" \
  --channels "C1234567890" \
  --title "My Report" \
  --json
```

**List files:**
```bash
python 00-system/skills/slack/slack-master/scripts/list_files.py \
  --channel "C1234567890" \
  --limit 20 \
  --json
```

---

### Step 4: Handle Results

**Success:**
- Display relevant information to user
- Format output nicely (channel names, usernames, etc.)

**Error:**
- Load `slack-master/references/error-handling.md` if needed
- Common errors:
  - `channel_not_found` → Help user find correct channel
  - `missing_scope` → Need to add scope and re-authorize
  - `rate_limited` → Wait and retry

---

## Operation Scripts Reference

All scripts are in `00-system/skills/slack/slack-master/scripts/`:

### Messaging
| Script | API Method | Description |
|--------|------------|-------------|
| send_message.py | chat.postMessage | Send a message |
| update_message.py | chat.update | Edit a message |
| delete_message.py | chat.delete | Delete a message |
| schedule_message.py | chat.scheduleMessage | Schedule a message |

### Conversations
| Script | API Method | Description |
|--------|------------|-------------|
| list_channels.py | conversations.list | List channels |
| channel_info.py | conversations.info | Get channel details |
| channel_history.py | conversations.history | Get messages |
| create_channel.py | conversations.create | Create channel |

### Users
| Script | API Method | Description |
|--------|------------|-------------|
| list_users.py | users.list | List workspace users |
| user_info.py | users.info | Get user details |

### Files
| Script | API Method | Description |
|--------|------------|-------------|
| upload_file.py | files.upload | Upload a file |
| list_files.py | files.list | List files |

### Search
| Script | API Method | Description |
|--------|------------|-------------|
| search_messages.py | search.messages | Search messages |
| search_files.py | search.files | Search files |

---

## Channel Resolution

When user references a channel by name (e.g., "#general"):

1. First, list channels to find the ID:
   ```bash
   python list_channels.py --json
   ```

2. Find matching channel in response
3. Use the channel ID (e.g., "C1234567890") for operations

**Common Pattern:**
```python
# User says: "send message to #general"
# 1. List channels to find ID
# 2. Use ID in send_message.py --channel C123...
```

---

## User Resolution

When user references someone by name (e.g., "@john"):

1. List users to find the ID:
   ```bash
   python list_users.py --json
   ```

2. Find matching user in response
3. Use the user ID (e.g., "U1234567890") for operations

---

## Example Interactions

### Send a Message

**User**: "Send 'Hello team!' to #general"

**AI Actions**:
1. Check config: `check_slack_config.py --json`
2. List channels: `list_channels.py --json`
3. Find #general ID → C1234567890
4. Send message: `send_message.py --channel C1234567890 --text "Hello team!" --json`
5. Confirm to user: "Message sent to #general"

---

### Search Slack

**User**: "Search slack for 'quarterly report'"

**AI Actions**:
1. Check config
2. Search: `search_messages.py --query "quarterly report" --json`
3. Display results with channel names and snippets

---

### List My Channels

**User**: "What slack channels am I in?"

**AI Actions**:
1. Check config
2. List: `list_channels.py --types "public_channel,private_channel" --json`
3. Display channel names and member counts

---

## Error Handling

### Configuration Errors

| Error | Action |
|-------|--------|
| No token | Run setup_slack.py |
| Invalid token | Re-authenticate |
| Token revoked | Re-authenticate |

### Operation Errors

| Error | Action |
|-------|--------|
| channel_not_found | List channels, help user find correct one |
| missing_scope | Add scope to app, re-authorize |
| rate_limited | Wait retry_after seconds, then retry |
| not_in_channel | Join channel first |

### For detailed error handling:
Load: `slack-master/references/error-handling.md`

---

## Related Resources

- **Setup**: `slack-master/references/setup-guide.md`
- **API Reference**: `slack-master/references/api-reference.md`
- **Authentication**: `slack-master/references/authentication.md`
- **Errors**: `slack-master/references/error-handling.md`

---

**Version**: 1.0
**Created**: 2025-12-17
**Status**: Production Ready
