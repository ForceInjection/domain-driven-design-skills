---
name: julien-mcp-notion-internal
description: Install Notion Internal API MCP. Use when user needs advanced Notion features via internal API.
category: mcp
triggers:
  - install notion internal mcp
  - notion internal api
  - advanced notion
---

# MCP Notion Internal API Installer

This skill installs the Notion Internal API MCP server into the current project.

## Installation Procedure

When the user asks to install Notion Internal MCP:

1. **Check for existing `.mcp.json`** in the project root
2. **Merge configuration** - Add this server to `mcpServers`:

```json
{
  "notion-internal": {
    "command": "${ONEDRIVE_MCP_PATH}/mcp-notion-internal-api/.venv/Scripts/python.exe",
    "args": ["${ONEDRIVE_MCP_PATH}/mcp-notion-internal-api/main_server.py"]
  }
}
```

3. **If `.mcp.json` doesn't exist**, create it with the full structure:

```json
{
  "mcpServers": {
    "notion-internal": {
      "command": "${ONEDRIVE_MCP_PATH}/mcp-notion-internal-api/.venv/Scripts/python.exe",
      "args": ["${ONEDRIVE_MCP_PATH}/mcp-notion-internal-api/main_server.py"]
    }
  }
}
```

## Environment Variables Required

- `ONEDRIVE_MCP_PATH`: Path to MCP servers folder

## Usage After Installation

Restart Claude Code to activate the MCP server.

## Skill Chaining

- **Input**: User request to install Notion Internal MCP
- **Output**: Configured `.mcp.json` with notion-internal server
- **Tools Used**: Read, Edit, Write
- **Chains With**: Notion MCP, Notion Pro MCP

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Auth failed | Update Notion cookies in config |
| Path not found | Verify ONEDRIVE_MCP_PATH environment variable |
| venv not found | Create venv with `python -m venv .venv` |
| API changed | Check for updates to internal API wrapper |
