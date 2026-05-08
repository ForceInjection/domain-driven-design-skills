---
name: Electron Integration
description: This skill should be used when the user asks about "Electron", "WebContentsView", "BrowserView", "preload script", "contextIsolation", "IPC", or needs to work with Electron-specific functionality in XSky.
version: 1.0.0
---

# Electron Integration in XSky

This skill provides knowledge for Electron integration in XSky.

## Package Location

`packages/ai-agent-electron/` - Electron adapter package

## Key Files

```
ai-agent-electron/src/
├── browser.ts      # BrowserAgent implementation
├── file.ts         # FileAgent for Electron
├── index.ts        # Package exports
├── preload.ts      # Preload script template
└── mcp/
    └── index.ts    # MCP client for Electron
```

## BrowserAgent Constructor

```typescript
import { BrowserAgent } from "@xsky/ai-agent-electron";

const browserAgent = new BrowserAgent(
  detailView,           // WebContentsView instance
  mcpClient,            // Optional MCP client
  customPrompt,         // Optional system prompt
  {
    useContextIsolation: true,
    preloadPath: path.join(__dirname, 'preload.js')
  }
);
```

## Security Options

```typescript
interface BrowserAgentSecurityOptions {
  useContextIsolation?: boolean;  // Recommended for production
  preloadPath?: string;           // Required when contextIsolation true
}
```

## Preload Script Setup

Create preload.js:
```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('xskyAgent', {
  executeScript: async (fnString, args) => {
    // Safe script execution via IPC
    return await ipcRenderer.invoke('xsky:execute-script', fnString, args);
  }
});
```

## WebContentsView Setup

```typescript
import { WebContentsView } from 'electron';

const view = new WebContentsView({
  webPreferences: {
    contextIsolation: true,
    nodeIntegration: false,
    sandbox: true,
    preload: path.join(__dirname, 'preload.js')
  }
});

mainWindow.contentView.addChildView(view);
view.setBounds({ x: 0, y: 0, width: 800, height: 600 });
```

## Script Execution

With contextIsolation (secure):
```typescript
// Uses preload API
await window.xskyAgent.executeScript(fn.toString(), args);
```

Without contextIsolation (legacy):
```typescript
// Direct executeJavaScript
await webContents.executeJavaScript(code, true);
```

## Screenshot Capture

```typescript
protected async screenshot(ctx: AgentContext) {
  const image = await this.detailView.webContents.capturePage();
  return {
    imageBase64: image.toDataURL(),
    imageType: "image/jpeg"
  };
}
```

## PDF Support

BrowserAgent includes PDF extraction:
```typescript
// Automatically detects PDF pages
// Uses pdf.js for content extraction
const content = await agent.extract_page_content(ctx);
// Returns: { title, page_url, page_content, total_pages, content_type: 'pdf' }
```

## Key Source Files

| File | Purpose |
|------|---------|
| `packages/ai-agent-electron/src/browser.ts` | BrowserAgent |
| `packages/ai-agent-electron/src/file.ts` | FileAgent |
| `packages/ai-agent-electron/src/preload.ts` | Preload template |
| `packages/ai-agent-electron/src/mcp/stdio.ts` | MCP STDIO client |
