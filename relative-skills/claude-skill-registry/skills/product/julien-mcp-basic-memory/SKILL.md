---
name: julien-mcp-basic-memory
description: Install Basic Memory MCP for persistent memory between Claude sessions. Use when user needs memory/context persistence via uvx.
category: mcp
triggers:
  - install basic memory mcp
  - persistent memory
  - memory mcp
---

# MCP Basic Memory Installer

This skill installs the Basic Memory MCP server into the current project.

## Installation Procedure

When the user asks to install Basic Memory MCP:

1. **Check for existing `.mcp.json`** in the project root
2. **Merge configuration** - Add this server to `mcpServers`:

```json
{
  "basic-memory": {
    "command": "uvx",
    "args": ["basic-memory", "mcp"]
  }
}
```

3. **If `.mcp.json` doesn't exist**, create it with the full structure:

```json
{
  "mcpServers": {
    "basic-memory": {
      "command": "uvx",
      "args": ["basic-memory", "mcp"]
    }
  }
}
```

## Prerequisites

- `uvx` must be installed (comes with `uv`)

## Usage After Installation

Restart Claude Code to activate the MCP server.

## Skill Chaining

- **Input**: User request to install Basic Memory MCP
- **Output**: Configured `.mcp.json` with basic-memory server
- **Tools Used**: Read, Edit, Write
- **Chains With**: Context7 MCP for enhanced context

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `uvx` not found | Install `uv` from astral.sh |
| Memory corrupt | Delete and recreate memory database |
| Package not found | Run `uv cache clean` |
| Permission denied | Check write permissions on data directory |
