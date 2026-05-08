---
name: obsidian-catalog
description: >
  Sync Claude conversations to Obsidian vault. Use when user asks to:
  sync conversations, export chat history, catalog sessions, generate
  summaries, review past work, search conversation history, or asks
  what was discussed on a specific date or about a specific topic.
allowed-tools: Read, Grep, Glob, Bash, Write, Task
version: 1.0.0
---

# Obsidian Conversation Catalog

Catalog all Claude conversations (browser exports + Claude Code CLI sessions) into an Obsidian vault with rich frontmatter, Claude-generated summaries, and Dataview-compatible structure.

## Quick Start

### Sync All Conversations
```bash
python ~/.claude/skills/obsidian-catalog/scripts/sync.py --all
```

### Import Browser Export
```bash
python ~/.claude/skills/obsidian-catalog/scripts/sync.py --browser "/path/to/export.zip"
```

### Sync Claude Code History Only
```bash
python ~/.claude/skills/obsidian-catalog/scripts/sync.py --code
```

### Filter by Date
```bash
python ~/.claude/skills/obsidian-catalog/scripts/sync.py --code --since 2025-12-01
```

### List Sessions Without Syncing
```bash
python ~/.claude/skills/obsidian-catalog/scripts/sync.py --all --list-only
```

## Configuration

Edit `~/.claude/skills/obsidian-catalog/config.yaml` to configure:
- `vault_path`: Path to Obsidian vault's Claude folder
- `claude_code_path`: Path to Claude Code history (default: ~/.claude/projects)
- `auto_summarize`: Whether to generate summaries automatically

## Generating Summaries

After syncing, generate summaries for sessions that need them:

1. Run sync to export sessions (without summaries)
2. Ask: "Generate summaries for the synced sessions"
3. I will use sub agents to process sessions in batches
4. Summaries are written to each session's frontmatter

For large imports (100+ sessions), summaries are generated in batches using sub agents to manage context efficiently.

## Searching Conversation History

Once synced, find past sessions by asking:
- "What did we work on last Tuesday?"
- "Find sessions about GIS processing"
- "Show recent conversations about the land dashboard"
- "What topics have we discussed this month?"

I will search the Obsidian vault at the configured path and return relevant sessions.

## Output Structure

Sessions are organized in the vault as:
```
Claude/
├── Sessions/
│   ├── Browser/2025/01/24/     # Claude.ai conversations
│   │   └── 2025-01-24-960f89e7.md
│   └── Code/2025/12/06/        # Claude Code sessions
│       └── 2025-12-06-2d31c8e7.md
├── Summaries/
│   ├── Daily/                   # Daily rollups
│   └── Projects/                # Per-project summaries
├── _raw/                        # Original export data
└── _Dashboard.md                # Dataview queries
```

## Frontmatter Fields

Each session file includes:
- `type`: claude-session
- `source`: browser | code
- `session_id`: UUID
- `title`: Conversation name
- `date`, `created`, `updated`: Timestamps
- `project`: Project name
- `message_count`: Number of messages
- `topics`: Keywords (Claude-generated)
- `summary`: Brief summary (Claude-generated)
- `has_code`: Whether it contains code blocks
- `word_count`, `duration_minutes`: Metrics

## Sub Agent Strategy

For summary generation, I use sub agents (Task tool) to:
- Process sessions in batches of 10-20
- Maintain fresh context for each batch
- Generate summaries in parallel when possible
- Handle 300+ conversations without context overflow
