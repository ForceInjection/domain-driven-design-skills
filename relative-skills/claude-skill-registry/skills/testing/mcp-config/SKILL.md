---
name: mcp-config
description: Configure MCP servers including Context7 and Playwright. Use when the user asks about MCP configuration, setting up Context7, configuring Playwright MCP, or managing MCP servers for this project.
---

# MCP Configuration

This skill provides instructions for configuring MCP (Model Context Protocol) servers used in this project.

## Available MCP Servers

### Context7 MCP

See [upstash/context7](https://github.com/upstash/context7) for setup instructions for Context7 MCP.

```bash
claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key YOUR_API_KEY
```

### Playwright MCP

See [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp) for setup instructions for Playwright MCP.

```bash
claude mcp add playwright npx @playwright/mcp@latest
```
