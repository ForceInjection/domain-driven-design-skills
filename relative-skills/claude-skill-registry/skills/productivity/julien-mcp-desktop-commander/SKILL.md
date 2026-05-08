---
name: julien-mcp-desktop-commander
description: Install Desktop Commander MCP for desktop automation. Use when user needs file/app/command control.
category: mcp
triggers:
  - install desktop commander
  - desktop automation mcp
  - file control mcp
---

# MCP Desktop Commander Installer

This skill installs the Desktop Commander MCP server into the current project.

## Installation Procedure

When the user asks to install Desktop Commander MCP:

1. **Check for existing `.mcp.json`** in the project root
2. **Merge configuration** - Add this server to `mcpServers`:

```json
{
  "desktop-commander": {
    "command": "cmd",
    "args": ["/c", "npx", "-y", "@wonderwhy-er/desktop-commander"]
  }
}
```

3. **If `.mcp.json` doesn't exist**, create it with the full structure:

```json
{
  "mcpServers": {
    "desktop-commander": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@wonderwhy-er/desktop-commander"]
    }
  }
}
```

## Prerequisites

- Node.js and npm installed

## Usage After Installation

Restart Claude Code to activate the MCP server. Provides desktop automation capabilities.

## Skill Chaining

- **Input**: User request to install Desktop Commander MCP
- **Output**: Configured `.mcp.json` with desktop-commander server
- **Tools Used**: Read, Edit, Write
- **Chains With**: Playwright MCP for browser automation

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `npx` not found | Install Node.js and ensure npm is in PATH |
| Permission denied | Run terminal as administrator on Windows |
| Command not found | Check Desktop Commander supports the command |
| File access error | Verify file path exists and is accessible |
