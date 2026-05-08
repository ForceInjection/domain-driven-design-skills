---
name: julien-mcp-brave
description: Install Brave Search MCP for web search capabilities. Use when user needs to add Brave Search API to their project.
category: mcp
triggers:
  - install brave mcp
  - brave search
  - web search mcp
---

# MCP Brave Search Installer

This skill installs the Brave Search MCP server into the current project.

## Installation Procedure

When the user asks to install Brave MCP:

1. **Check for existing `.mcp.json`** in the project root
2. **Merge configuration** - Add the following server to `mcpServers`:

```json
{
  "brave": {
    "command": "cmd",
    "args": ["/c", "npx", "-y", "@modelcontextprotocol/server-brave-search"],
    "env": {
      "BRAVE_API_KEY": "${BRAVE_API_KEY}"
    }
  }
}
```

3. **If `.mcp.json` doesn't exist**, create it with the full structure:

```json
{
  "mcpServers": {
    "brave": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      }
    }
  }
}
```

## Environment Variables Required

- `BRAVE_API_KEY`: Your Brave Search API key

## Usage After Installation

Restart Claude Code to activate the MCP server. The Brave Search tools will then be available.

## Example Usage

After installation, use in Claude Code:
```
"Search for the latest React documentation"
"Find npm packages for authentication"
```

## Skill Chaining

- **Input**: User request to install Brave Search MCP
- **Output**: Configured `.mcp.json` with brave server
- **Tools Used**: Read, Edit, Write
- **Chains With**: Any skill needing web search capabilities

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `npx` not found | Install Node.js and ensure npm is in PATH |
| API key invalid | Verify BRAVE_API_KEY in environment variables |
| Server not starting | Check Claude Code logs, restart after config change |
| Permission denied | Run terminal as administrator on Windows |
