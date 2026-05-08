---
name: julien-mcp-notion
description: Install Notion MCP for workspace integration. Use when user needs Notion API access.
category: mcp
triggers:
  - install notion mcp
  - notion integration
  - notion api mcp
---

# MCP Notion Installer

This skill installs the Notion MCP server into the current project.

## Installation Procedure

When the user asks to install Notion MCP:

1. **Check for existing `.mcp.json`** in the project root
2. **Merge configuration** - Add this server to `mcpServers`:

```json
{
  "notion": {
    "command": "cmd",
    "args": ["/c", "npx", "-y", "@suekou/mcp-notion-server"],
    "env": {
      "NOTION_API_TOKEN": "${NOTION_API_TOKEN}",
      "NOTION_MARKDOWN_CONVERSION": "${NOTION_MARKDOWN_CONVERSION}"
    }
  }
}
```

3. **If `.mcp.json` doesn't exist**, create it with the full structure:

```json
{
  "mcpServers": {
    "notion": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@suekou/mcp-notion-server"],
      "env": {
        "NOTION_API_TOKEN": "${NOTION_API_TOKEN}",
        "NOTION_MARKDOWN_CONVERSION": "${NOTION_MARKDOWN_CONVERSION}"
      }
    }
  }
}
```

## Environment Variables Required

- `NOTION_API_TOKEN`: Your Notion integration token
- `NOTION_MARKDOWN_CONVERSION`: Set to "true" for markdown conversion

## Usage After Installation

Restart Claude Code to activate the MCP server.

## Example Usage

After installation, use in Claude Code:
```
"List all pages in my Notion workspace"
"Create a new page titled 'Meeting Notes'"
```

## Skill Chaining

- **Input**: User request to install Notion MCP
- **Output**: Configured `.mcp.json` with notion server
- **Tools Used**: Read, Edit, Write
- **Chains With**: Notion Pro MCP, Notion Internal MCP

## Troubleshooting

| Problem | Solution |
|---------|----------|
| API token invalid | Create new integration at notion.so/my-integrations |
| Page not found | Share page with your integration in Notion |
| `npx` not found | Install Node.js and ensure npm is in PATH |
| Markdown conversion fails | Set NOTION_MARKDOWN_CONVERSION to "true" |
