---
name: discord-chat-summary
description: "Summarize Discord chat messages across servers. Use when user asks for chat summary, digest, highlights, recap, or overview of Discord conversations."
---

# Discord Chat Summary

Generate summaries of synced Discord chat messages. Claude reads the message files directly and produces a concise summary of key discussions, topics, and activity.

## Persona Context

**REQUIRED:** Before executing this skill, load your configured persona:

```bash
python ${CLAUDE_PLUGIN_ROOT}/../community-agent/tools/persona_status.py --prompt
```

This outputs your persona definition. Apply it when generating summaries:
- **Voice**: Present findings in the persona's voice ("I noticed...", "I recommend...")
- **Style**: Use the persona's preferred formatting (bullet points vs prose)
- **Framing**: Frame insights and recommendations as the persona would
- **Tone**: Match the persona's warmth/formality in the summary introduction

## When to Use

- User asks for a summary of Discord chats
- User wants a digest or recap of Discord conversations
- User asks "what's been happening" in Discord
- User wants highlights from Discord channels
- User asks for an overview of Discord activity
- User wants to catch up on Discord messages

## Smart Defaults (Reduce Questions)

**When user is vague, apply these defaults instead of asking:**

| User Says | Default Action |
|-----------|----------------|
| "summarize Discord" | Summarize ALL synced data, last 7 days |
| "what's happening" | Same as above |
| "summarize [server name]" | All channels in that server, last 7 days |
| No time specified | Default to last 7 days |

**When NO data exists:**
1. Don't just say "no data found"
2. Run `/discord-quickstart` flow instead
3. Offer to sync recommended servers, then summarize

**Only ask for clarification when:**
- Multiple interpretations are equally valid
- User explicitly asks "which servers do I have?"

## How to Execute

### Step 0: Handle Empty State

First check if any data exists:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_status.py --json
```

If `sync.has_data` is false:
- DON'T just say "no data, run sync first"
- Instead, run the `/discord-quickstart` flow to help them sync
- Then proceed to summarize

### Step 1: Get the Manifest

Get the manifest to understand what data is available:

```bash
python ${CLAUDE_PLUGIN_ROOT}/tools/discord_manifest.py
```

This shows all synced servers, channels, message counts, and last sync times.

**CRITICAL PATH RESOLUTION:** All data paths shown in the manifest are relative to the **current working directory** (cwd) where Claude is running - NOT relative to this skill file or the plugin directory.

### Step 2: Display Data Coverage (REQUIRED)

**Before generating any summary, ALWAYS show the date coverage to the user.**

Extract and display this information from the manifest:

```
Data Coverage:
- Server: [ServerName] - [first_message] to [last_message] ([days_covered] days)
  - #channel1: [message_count] messages
  - #channel2: [message_count] messages
```

Get this from manifest fields:
- `servers[].date_range.first_message` - oldest message date
- `servers[].date_range.last_message` - newest message date
- `servers[].date_range.days_covered` - total days of data
- `servers[].channels[].message_count` - messages per channel

**This step is NOT optional.** Users must see what date range they're getting before the summary.

### Step 3: Determine Scope

Ask user or infer from their request which scope to summarize:

| Scope | Description |
|-------|-------------|
| All servers | Summarize across all synced servers |
| Specific server | Summarize all channels in one server |
| Specific channel | Summarize a single channel |

### Step 4: Read Messages

Read the relevant `messages.md` files based on scope:

**For all servers:**
```
Read each: ./data/{server-dir}/{channel}/messages.md
```

**For specific server (e.g., "Midjourney"):**
```
Read: ./data/662267976984297473-midjourney/*/messages.md
```

**For specific channel:**
```
Read: ./data/{server-dir}/{channel-name}/messages.md
```

### Step 5: Apply Time Filtering

If user specifies a time range, filter messages by date headers in the markdown.

**IMPORTANT:** When filtering, tell the user what filter you applied:

| User Request | Filter Logic |
|--------------|--------------|
| "last 7 days" | Only include messages under `## YYYY-MM-DD` headers from the past 7 days |
| "this week" | Messages from current week (Monday-Sunday) |
| "since Jan 1" | Messages from `## 2026-01-01` onwards |
| "yesterday" | Messages from yesterday's date only |

Date headers in messages.md look like: `## 2026-01-03`

Example filter output: "Filtering to last 7 days (Jan 3-10, 2026)"

### Step 6: Generate Summary (REQUIRED FORMAT)

**All summaries MUST include a date range header. Never produce a summary without showing the period covered.**

**Required Summary Format:**

```markdown
## [Server Name] Summary
**Period:** [start_date] to [end_date] ([N] days)
**Messages:** [count] | **Channels:** [count] | **Active Users:** [count]

---

### Key Topics
| Date | Topic | Channel |
|------|-------|---------|
| Jan 9 | [Topic description] | #channel |
| Jan 8 | [Topic description] | #channel |

### Notable Discussions
- **[Topic]** (Jan 9, #channel): [Brief description of the discussion]
- **[Topic]** (Jan 8, #channel): [Brief description]

### Active Participants
@user1 (45 msgs), @user2 (32 msgs), @user3 (28 msgs)

### Unanswered Questions
- "[Question text]?" (@user, Jan 8, #channel)
```

**Key requirements:**
- Period/date range MUST be in the header
- Topics should include the date they were discussed
- Include channel context for multi-channel summaries

## Example Usage

**User:** "Summarize the Discord chats from last week"

**Claude:**
1. Runs `python ${CLAUDE_PLUGIN_ROOT}/tools/discord_manifest.py` to list available servers
2. Reads all `messages.md` files from paths in manifest
3. Filters to only include `## 2025-12-27` through `## 2026-01-03`
4. Generates summary

**User:** "What's been happening in the Midjourney server?"

**Claude:**
1. Runs `python ${CLAUDE_PLUGIN_ROOT}/tools/discord_manifest.py`
2. Finds Midjourney server directory from manifest
3. Reads all channel messages.md files in that server
4. Generates server-wide summary

**User:** "Give me a quick digest of #general"

**Claude:**
1. Runs `python ${CLAUDE_PLUGIN_ROOT}/tools/discord_manifest.py` to find #general channel path
2. Reads that specific `messages.md`
3. Generates channel-focused summary

## Message Format Reference

Messages in `messages.md` are structured as:

```markdown
## 2026-01-03

### 4:12 AM - @username (user_id)
Message content here

### 4:30 AM - @another_user (user_id)
↳ replying to @username:
Reply content

Reactions: heart 2 | rocket 1
```

## Prerequisites

- Messages must be synced first using the `discord-sync` skill
- At least one server/channel should have data in `./data/` directory (relative to cwd)

## Limitations

- Only summarizes locally synced messages (not live Discord data)
- Cannot summarize messages not yet pulled via `discord-sync`
- Large message volumes may require focusing on specific channels or date ranges

## Next Steps

- Use `discord-sync` to pull fresh messages before summarizing
- Use `discord-read` to view full message details after identifying interesting discussions
