---
name: browser-automation
description: Browser automation via Puppeteer MCP for JS-rendered content
---

# Browser Automation

Use Playwright or Puppeteer MCP for browser automation when WebFetch isn't sufficient.

## Overview

Browser automation provides headless browser control for:
- JS-rendered content extraction
- Screenshot capture
- Form filling and submission
- Interactive testing
- Auth-protected page access

## MCP Servers

### Playwright (Recommended)

Multi-browser support: Firefox, Chrome, WebKit. Same API across all browsers.

**Package:** `@anthropic/mcp-server-playwright`
**Transport:** stdio
**Install:** `claude mcp add playwright -- npx -y @anthropic/mcp-server-playwright`

```bash
# Also install browser binaries
npx playwright install firefox chromium webkit
```

### Puppeteer (Chrome Only)

**Package:** `puppeteer-mcp-server`
**Transport:** stdio
**Install:** `claude mcp add puppeteer -- npx -y puppeteer-mcp-server`

### Comparison

| Feature | Playwright | Puppeteer |
|---------|------------|-----------|
| Firefox | ✓ | ✗ |
| Chrome/Chromium | ✓ | ✓ |
| WebKit/Safari | ✓ | ✗ |
| API | Same across browsers | Chrome-specific |
| Maintenance | Microsoft (active) | Google |

## Available Tools

### Navigation

**`puppeteer_navigate`**
Navigate to a URL and wait for page load.
```
url: "https://example.com"
waitUntil: "networkidle0" | "domcontentloaded" | "load"
```

### Screenshots

**`puppeteer_screenshot`**
Capture the current page or specific element.
```
name: "screenshot-name"
selector: "#element-id"  (optional, full page if omitted)
fullPage: true  (optional)
```

### Interaction

**`puppeteer_click`**
Click an element by CSS selector.
```
selector: "button.submit"
```

**`puppeteer_fill`**
Fill an input field with text.
```
selector: "input[name=email]"
value: "user@example.com"
```

**`puppeteer_select`**
Select an option from a dropdown.
```
selector: "select#country"
value: "US"
```

**`puppeteer_hover`**
Hover over an element (for tooltips, dropdowns).
```
selector: ".menu-trigger"
```

### JavaScript Execution

**`puppeteer_evaluate`**
Run JavaScript in the page context and return results.
```
script: "document.title"
```

## Usage Patterns

### Extract JS-Rendered Content

```
1. puppeteer_navigate(url="https://spa-app.com/data")
2. puppeteer_evaluate(script="JSON.stringify(window.__DATA__)")
```

### Fill and Submit Form

```
1. puppeteer_navigate(url="https://example.com/login")
2. puppeteer_screenshot(name="before-login")
3. puppeteer_fill(selector="input[name=email]", value="user@example.com")
4. puppeteer_fill(selector="input[name=password]", value="secret")
5. puppeteer_click(selector="button[type=submit]")
6. puppeteer_screenshot(name="after-login")
```

### Capture Visual Evidence

```
1. puppeteer_navigate(url="https://example.com")
2. puppeteer_screenshot(name="homepage", fullPage=true)
3. puppeteer_click(selector=".open-modal")
4. puppeteer_screenshot(name="modal-open")
```

## Decision Tree

```
Need web content?
    │
    ├─ Static HTML? ──────────────────→ WebFetch
    │
    ├─ JS-rendered (React, Vue, etc.)? → Puppeteer
    │
    ├─ Need screenshot? ──────────────→ Puppeteer
    │
    ├─ Need to fill forms? ───────────→ Puppeteer
    │
    ├─ Auth-protected? ───────────────→ Puppeteer (can maintain session)
    │
    └─ Default ───────────────────────→ WebFetch (simpler, faster)
```

## Error Handling

### Element Not Found

If a selector doesn't match:
1. Take screenshot to see current page state
2. Use `puppeteer_evaluate` to check DOM
3. Try alternative selectors
4. Add wait time for dynamic content

### Timeout

If page takes too long:
1. Try `waitUntil: "domcontentloaded"` instead of `networkidle0`
2. Check if site blocks automation
3. Look for loading spinners/skeleton screens

### Session Management

- Browser sessions persist within the conversation
- Use for multi-step flows (login → navigate → action)
- Session cleared on conversation end

## Comparison with WebFetch

| Feature | WebFetch | Playwright | Puppeteer |
|---------|----------|------------|-----------|
| Speed | Fast | Slower | Slower |
| JS execution | No | Yes | Yes |
| Screenshots | No | Yes | Yes |
| Form filling | No | Yes | Yes |
| Session/cookies | No | Yes | Yes |
| Resource usage | Low | Higher | Higher |
| Firefox | N/A | Yes | No |
| WebKit/Safari | N/A | Yes | No |

## Best Practices

1. **Screenshot liberally** - Visual evidence helps debugging
2. **Use specific selectors** - IDs are most reliable
3. **Wait for content** - Dynamic sites need time to load
4. **Handle failures gracefully** - Not all elements exist
5. **Close when done** - Don't leave orphan sessions

## Troubleshooting

### "Element not found"
- Page may not be fully loaded
- Selector may be wrong
- Element may be in iframe

### "Navigation timeout"
- Site may be slow
- Site may block headless browsers
- Network issues

### "Click had no effect"
- Element may be covered by overlay
- May need to scroll into view
- May need to wait for animation
