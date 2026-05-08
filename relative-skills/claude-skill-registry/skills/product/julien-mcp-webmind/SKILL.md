---
name: julien-mcp-webmind
description: Install WebMind MCP for DOM analysis. Use when user needs Ragic DOM assistant capabilities.
category: mcp
triggers:
  - install webmind mcp
  - dom analysis mcp
  - ragic dom
---

# MCP WebMind Installer

This skill installs the WebMind MCP server into the current project.

## Installation Procedure

When the user asks to install WebMind MCP:

1. **Check for existing `.mcp.json`** in the project root
2. **Merge configuration** - Add this server to `mcpServers`:

```json
{
  "webmind": {
    "command": "node",
    "args": ["${ONEDRIVE_MCP_PATH}/webmind-analyzer-mcp/webmind-mcp-server/server.js"]
  }
}
```

3. **If `.mcp.json` doesn't exist**, create it with the full structure:

```json
{
  "mcpServers": {
    "webmind": {
      "command": "node",
      "args": ["${ONEDRIVE_MCP_PATH}/webmind-analyzer-mcp/webmind-mcp-server/server.js"]
    }
  }
}
```

## Environment Variables Required

- `ONEDRIVE_MCP_PATH`: Path to MCP servers folder

## Usage After Installation

Restart Claude Code to activate the MCP server. Provides DOM analysis for Ragic.

## Skill Chaining

- **Input**: User request to install WebMind MCP
- **Output**: Configured `.mcp.json` with webmind server
- **Tools Used**: Read, Edit, Write
- **Chains With**: Playwright MCP for browser control

## Troubleshooting

| Problem | Solution |
|---------|----------|
| server.js not found | Verify ONEDRIVE_MCP_PATH and rebuild server |
| Node not found | Install Node.js and ensure it's in PATH |
| DOM analysis fails | Check Ragic page is loaded correctly |
| Connection error | Verify target page URL is accessible |
