---
name: julien-mcp-notion-pro
description: Install Notion Pro MCP for secondary workspace. Use when user has multiple Notion workspaces.
category: mcp
triggers:
  - install notion pro mcp
  - notion secondary
  - multiple notion
---

# MCP Notion Pro Installer

This skill installs the Notion Pro MCP server into the current project (uses secondary Notion workspace).

## Installation Procedure

When the user asks to install Notion Pro MCP:

1. **Check for existing `.mcp.json`** in the project root
2. **Merge configuration** - Add this server to `mcpServers`:

```json
{
  "notion-pro": {
    "command": "cmd",
    "args": ["/c", "npx", "-y", "@suekou/mcp-notion-server"],
    "env": {
      "NOTION_API_TOKEN": "${NOTION_PRO_API_TOKEN}",
      "NOTION_MARKDOWN_CONVERSION": "${NOTION_MARKDOWN_CONVERSION}"
    }
  }
}
```

3. **If `.mcp.json` doesn't exist**, create it with the full structure:

```json
{
  "mcpServers": {
    "notion-pro": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@suekou/mcp-notion-server"],
      "env": {
        "NOTION_API_TOKEN": "${NOTION_PRO_API_TOKEN}",
        "NOTION_MARKDOWN_CONVERSION": "${NOTION_MARKDOWN_CONVERSION}"
      }
    }
  }
}
```

## Environment Variables Required

- `NOTION_PRO_API_TOKEN`: Your secondary Notion integration token
- `NOTION_MARKDOWN_CONVERSION`: Set to "true" for markdown conversion

## Usage After Installation

Restart Claude Code to activate the MCP server.

## Skill Chaining

- **Input**: User request to install Notion Pro MCP
- **Output**: Configured `.mcp.json` with notion-pro server
- **Tools Used**: Read, Edit, Write
- **Chains With**: Notion MCP, Notion Internal MCP

## Troubleshooting

| Problem | Solution |
|---------|----------|
| API token invalid | Create new integration at notion.so/my-integrations |
| Page not found | Share page with your integration in Notion |
| `npx` not found | Install Node.js and ensure npm is in PATH |
| Wrong workspace | Verify NOTION_PRO_API_TOKEN is for correct workspace |
