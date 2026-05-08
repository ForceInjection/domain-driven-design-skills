---
name: bash-history
description: Search and retrieve bash command history using Atuin. Use when users ask about commands they've run before, want to find a specific command, recall how they did something previously, or ask "how did I..." or "what command did I use to..."
---

# Bash History Skill

Access bash command history through Atuin to search for and retrieve previously executed commands.

## Tools

### mcp__bash-history__search_history

Search for commands matching a query.

**Parameters:**
- `query` (string): Search term to find matching commands
- `limit` (number, default: 10): Maximum results to return
- `include_failed` (boolean, default: false): Include failed commands

### mcp__bash-history__get_recent_history

Get the most recent commands.

**Parameters:**
- `limit` (number, default: 10): Number of recent commands
- `include_failed` (boolean, default: false): Include failed commands

## Example Usage

When user asks: "How did I deploy last time?"
```
Use mcp__bash-history__search_history with query "deploy"
```

When user asks: "What commands did I run recently?"
```
Use mcp__bash-history__get_recent_history with limit 20
```

When user asks: "Show me failed git commands"
```
Use mcp__bash-history__search_history with query "git" and include_failed true
```

## Output Format

Results include command text, exit code (0 = success), and timestamp. Present clearly and offer to help reuse commands.
