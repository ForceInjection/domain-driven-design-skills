---
name: julien-mcp-context7
description: Install Context7 MCP for contextual search. Use when user needs Upstash Context7 integration.
category: mcp
triggers:
  - install context7 mcp
  - context7
  - upstash context
---

# MCP Context7 Installer

This skill installs the Context7 MCP server into the current project.

## Installation Procedure

When the user asks to install Context7 MCP:

1. **Check for existing `.mcp.json`** in the project root
2. **Merge configuration** - Add this server to `mcpServers`:

```json
{
  "context7": {
    "command": "cmd",
    "args": ["/c", "npx", "-y", "@upstash/context7-mcp@latest", "--api-key", "${CONTEXT_7_API_KEY}"]
  }
}
```

3. **If `.mcp.json` doesn't exist**, create it with the full structure:

```json
{
  "mcpServers": {
    "context7": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@upstash/context7-mcp@latest", "--api-key", "${CONTEXT_7_API_KEY}"]
    }
  }
}
```

## Environment Variables Required

- `CONTEXT_7_API_KEY`: Your Context7 API key

## Usage After Installation

Restart Claude Code to activate the MCP server.

## Skill Chaining

- **Input**: User request to install Context7 MCP
- **Output**: Configured `.mcp.json` with context7 server
- **Tools Used**: Read, Edit, Write
- **Chains With**: Basic Memory MCP for persistence

## Troubleshooting

| Problem | Solution |
|---------|----------|
| API key invalid | Get new key from Upstash dashboard |
| `npx` not found | Install Node.js and ensure npm is in PATH |
| Connection timeout | Check network and Upstash service status |
| Index not found | Create index in Upstash Context7 console |
