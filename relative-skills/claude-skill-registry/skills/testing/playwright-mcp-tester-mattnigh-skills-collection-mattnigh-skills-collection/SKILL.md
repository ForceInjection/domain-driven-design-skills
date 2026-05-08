---
name: Playwright MCP Tester
description: Iterative UI testing using Playwright MCP server for automated browser interaction and visual verification
model: haiku
---

# Playwright MCP Tester

## Purpose

This skill enables iterative UI testing using the Playwright MCP server. Instead of manually copying/pasting screenshots, the agent can:
1. Launch a browser and navigate to the app
2. Take screenshots programmatically
3. Interact with UI elements (click, type, etc.)
4. Verify visual state and fix issues in a loop

## Setup

### 1. Install Playwright MCP Server

```bash
# Install the official Playwright MCP server (in project)
bun add -d @playwright/mcp
# or globally
npm install -g @playwright/mcp
```

### 2. Configure MCP Server

Create a project-level `.mcp.json` in the workspace root:

```json
{
  "servers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

Or add to Claude Desktop settings (`~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

### 3. Restart Claude/IDE

After adding the MCP config, restart to load the server.

## Prerequisites

- Playwright MCP server must be configured (see Setup above)
- Dev server must be running (e.g., `bun dev` on port 5173)

## MCP Server Commands

### Browser Management

```
playwright_navigate
  - url: string (required) - URL to navigate to
  
playwright_screenshot
  - name: string (required) - Name for the screenshot
  - selector?: string - CSS selector to screenshot (optional, defaults to full page)
  - fullPage?: boolean - Capture full scrollable page
  
playwright_click
  - selector: string (required) - CSS selector to click
  
playwright_fill
  - selector: string (required) - CSS selector of input
  - value: string (required) - Value to fill
  
playwright_select
  - selector: string (required) - CSS selector of select element
  - value: string (required) - Value to select
  
playwright_hover
  - selector: string (required) - CSS selector to hover
  
playwright_evaluate
  - script: string (required) - JavaScript to execute in browser context
```

## Iterative Testing Workflow

```
┌─────────────────────────────────────────────────────────────┐
│              PLAYWRIGHT ITERATIVE TEST LOOP                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. START dev server (if not running)                       │
│     ↓                                                       │
│  2. NAVIGATE to app URL                                     │
│     playwright_navigate → http://localhost:5173             │
│     ↓                                                       │
│  3. SCREENSHOT current state                                │
│     playwright_screenshot → "initial-state"                 │
│     ↓                                                       │
│  4. ANALYZE screenshot for issues                           │
│     - Check if UI renders correctly                         │
│     - Check for error messages                              │
│     - Check if data displays                                │
│     ↓                                                       │
│  5. EVALUATE results:                                       │
│     ├── All good? → Test complete ✅                        │
│     └── Issues? → Fix code, goto step 3                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Commands

### "Test UI"
Runs the iterative test loop:
1. Starts dev server if needed
2. Navigates to app
3. Takes screenshot
4. Analyzes and reports issues

### "Debug UI"
Interactive debugging:
1. Navigate to specific page
2. Click elements
3. Fill forms
4. Take targeted screenshots

### "Visual regression"
Compare current state to expected:
1. Take screenshot
2. Compare to baseline
3. Report differences

## Example Usage

### Basic UI Test

```
User: "Test UI"

Agent:
1. Run: bun dev (background)
2. Wait for server ready
3. playwright_navigate → http://localhost:5173
4. playwright_screenshot → "app-loaded"
5. Analyze: "Chart area is empty, no candlesticks visible"
6. Fix: Edit CandlestickChart.svelte
7. playwright_screenshot → "after-fix-1"
8. Analyze: "Charts now display data correctly"
9. Report: ✅ UI test passed
```

### Interactive Element Test

```
User: "Test crypto selector"

Agent:
1. playwright_navigate → http://localhost:5173
2. playwright_screenshot → "before-click"
3. playwright_click → "button:has-text('ETH')"
4. Wait 2 seconds for data load
5. playwright_screenshot → "after-eth-selected"
6. Analyze: "ETH data loaded, chart updated"
7. Report: ✅ Crypto selector works
```

### Console Error Check

```
User: "Check for JS errors"

Agent:
1. playwright_navigate → http://localhost:5173
2. playwright_evaluate → "window.__errors = []; window.onerror = (m) => __errors.push(m)"
3. Wait for app to load
4. playwright_evaluate → "return window.__errors"
5. Report errors found (if any)
```

## Integration with Assembler

The Playwright tester integrates with the Assembler iteration loop:

```
┌─────────────────────────────────────────────────────────────┐
│           ASSEMBLER + PLAYWRIGHT INTEGRATION                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  FOR each Work Order:                                       │
│    1. IMPLEMENT code changes                                │
│    2. RUN Playwright test:                                  │
│       - Navigate to app                                     │
│       - Screenshot                                          │
│       - Check for errors                                    │
│       - Verify acceptance criteria                          │
│    3. EVALUATE:                                             │
│       ├── Pass? → Next WO                                   │
│       └── Fail? → Fix and re-test                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Selectors Reference

### Common Selectors for crypto-viz

```javascript
// Navigation
'nav button'                    // Nav buttons
'button:has-text("BTC")'        // Crypto selector buttons
'button:has-text("ETH")'

// Charts
'.bg-surface'                   // Chart containers
'[style*="height: 400px"]'      // Main chart
'[style*="height: 150px"]'      // Indicator charts

// Settings
'.text-sm:has-text("Settings")' // Settings panel
'input[type="range"]'           // Sliders
'input[type="checkbox"]'        // Toggles

// Events
'.text-sm:has-text("Detected Events")' // Event list
```

## Error Handling

### Common Issues

| Issue | Detection | Resolution |
|-------|-----------|------------|
| Blank page | Screenshot shows empty | Check console errors |
| Chart not rendering | No canvas content | Check data loading |
| API error | Error message visible | Check network/CORS |
| Layout broken | Elements misaligned | Check CSS/Tailwind |

### Timeout Handling

```
If page doesn't load in 10 seconds:
1. Check if dev server is running
2. Check port availability
3. Restart server and retry
```

## Best Practices

1. **Always screenshot before and after** changes
2. **Wait for data to load** before taking screenshots (2-3 seconds)
3. **Check console for errors** using playwright_evaluate
4. **Use specific selectors** to target elements
5. **Name screenshots descriptively** (e.g., "chart-after-eth-click")

## Related Skills

- `assembler-agent/ITERATION.md` — Iteration loop integration
- `validator-agent/SKILL.md` — Validation report generation
