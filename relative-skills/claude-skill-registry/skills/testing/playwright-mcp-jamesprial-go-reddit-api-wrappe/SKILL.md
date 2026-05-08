---
name: playwright-mcp
description: Programmatic browser automation using Playwright MCP server. Use when building Claude Code tools or applications that need web automation, testing, scraping, or browser interaction. Provides structured accessibility-based automation without screenshots or vision models.
---

# Playwright MCP

Programmatic interface for Playwright MCP server - enables browser automation in Node.js applications using structured accessibility snapshots.

## Installation

```bash
npm install @playwright/mcp @modelcontextprotocol/sdk
```

## Basic Usage

```javascript
import http from 'http';
import { createConnection } from '@playwright/mcp';
import { SSEServerTransport } from '@modelcontextprotocol/sdk/server/sse.js';

// Create MCP server with browser configuration
const connection = await createConnection({ 
  browser: { 
    launchOptions: { headless: true } 
  } 
});

// Connect with SSE transport
const transport = new SSEServerTransport('/messages', res);
await connection.connect(transport);
```

## Configuration Options

See [references/configuration.md](references/configuration.md) for full browser and server configuration options.

## Available Tools

See [references/tools.md](references/tools.md) for complete tool documentation including:
- Core automation (click, type, navigate, etc.)
- Tab management
- Screenshots and PDF generation
- JavaScript evaluation
- Network and console inspection

## Common Patterns

**Headless automation:**
```javascript
const connection = await createConnection({
  browser: { launchOptions: { headless: true } }
});
```

**With browser channel:**
```javascript
const connection = await createConnection({
  browser: { 
    launchOptions: { 
      channel: 'chrome',
      headless: false 
    } 
  }
});
```

**Isolated contexts:**
```javascript
const connection = await createConnection({
  browser: { 
    isolated: true,
    contextOptions: {
      storageState: 'path/to/storage.json'
    }
  }
});
```

## Documentation

- GitHub: https://github.com/microsoft/playwright-mcp
- Playwright Docs: https://playwright.dev
- MCP Protocol: https://modelcontextprotocol.io
