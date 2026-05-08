---
name: julien-mcp-playwright
description: Install Playwright MCP for browser automation. Use when user needs web testing/scraping capabilities.
category: mcp
triggers:
  - install playwright mcp
  - browser automation mcp
  - playwright
---

# MCP Playwright Installer

This skill installs the Playwright MCP server into the current project.

## Installation Procedure

When the user asks to install Playwright MCP:

1. **Check for existing `.mcp.json`** in the project root
2. **Merge configuration** - Add this server to `mcpServers`:

```json
{
  "playwright": {
    "command": "cmd",
    "args": ["/c", "npx", "-y", "@playwright/mcp@latest"]
  }
}
```

3. **If `.mcp.json` doesn't exist**, create it with the full structure:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@playwright/mcp@latest"]
    }
  }
}
```

## Prerequisites

- Node.js and npm installed
- Playwright browsers will be auto-installed on first use

## Usage After Installation

Restart Claude Code to activate the MCP server. Provides browser automation capabilities.

## Example Usage

After installation, use in Claude Code:
```
"Navigate to example.com and take a screenshot"
"Fill in the login form and click submit"
```

## Skill Chaining

- **Input**: User request to install Playwright MCP
- **Output**: Configured `.mcp.json` with playwright server
- **Tools Used**: Read, Edit, Write
- **Chains With**: Chrome DevTools MCP for debugging

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Browser not found | Run `npx playwright install` manually |
| `npx` not found | Install Node.js and ensure npm is in PATH |
| Timeout errors | Increase timeout in playwright config |
| Permission denied | Run terminal as administrator on Windows |
