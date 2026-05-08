---
name: julien-mcp-veyrax
description: Install VeyraX MCP server. Use when user needs VeyraX integration via Smithery.
category: mcp
triggers:
  - install veyrax mcp
  - veyrax
  - smithery mcp
---

# MCP VeyraX Installer

This skill installs the VeyraX MCP server into the current project.

## Installation Procedure

When the user asks to install VeyraX MCP:

1. **Check for existing `.mcp.json`** in the project root
2. **Merge configuration** - Add this server to `mcpServers`:

```json
{
  "veyrax": {
    "command": "cmd",
    "args": ["/c", "npx", "-y", "@smithery/cli@latest", "run", "@VeyraX/veyrax-mcp", "--key", "${JINA_API_KEY}"]
  }
}
```

3. **If `.mcp.json` doesn't exist**, create it with the full structure:

```json
{
  "mcpServers": {
    "veyrax": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@smithery/cli@latest", "run", "@VeyraX/veyrax-mcp", "--key", "${JINA_API_KEY}"]
    }
  }
}
```

## Environment Variables Required

- `JINA_API_KEY`: Your API key for VeyraX via Smithery

## Usage After Installation

Restart Claude Code to activate the MCP server.

## Skill Chaining

- **Input**: User request to install VeyraX MCP
- **Output**: Configured `.mcp.json` with veyrax server
- **Tools Used**: Read, Edit, Write
- **Chains With**: Jina MCP for content extraction

## Troubleshooting

| Problem | Solution |
|---------|----------|
| API key invalid | Get new key from VeyraX/Smithery |
| `npx` not found | Install Node.js and ensure npm is in PATH |
| Smithery CLI error | Try `npm cache clean --force` |
| Rate limit exceeded | Check VeyraX plan limits |
