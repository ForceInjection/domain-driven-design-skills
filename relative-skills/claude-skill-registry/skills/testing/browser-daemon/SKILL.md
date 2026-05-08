---
name: Browser Daemon
description: Persistent browser automation via Playwright daemon. Keep a browser window open and send it commands (navigate, execute JS, inspect console). Perfect for interactive debugging, development, and testing web applications. Use when you need to interact with a browser repeatedly without opening/closing it.
version: 6.0.0
author: noiv
tags: [browser, automation, debugging, playwright, daemon, console-logs]
---

# Browser Daemon - Persistent Browser Automation

Persistent browser daemon that keeps Chrome open and accepts commands via file-based IPC.

## Quick Start

### Start the daemon (once per session)

```bash
cd ~/.claude/skills/playwright-skill
node browser-daemon.js
```

Or ask: "Start the browser daemon in the background"

The browser window opens and stays open.

### Send commands

Use absolute paths (cleaner, no directory changes):

```bash
# Navigate
~/.claude/skills/playwright-skill/browser-client.js navigate "http://localhost:8080/..."

# Execute JavaScript
~/.claude/skills/playwright-skill/browser-client.js exec "document.title"
~/.claude/skills/playwright-skill/browser-client.js exec "document.querySelectorAll('div').length"

# Console logs
~/.claude/skills/playwright-skill/browser-client.js console
~/.claude/skills/playwright-skill/browser-client.js console-clear

# Status
~/.claude/skills/playwright-skill/browser-client.js status

# Resize viewport
~/.claude/skills/playwright-skill/browser-client.js resize 1920 1080
```

Both scripts have shebangs and are executable, so they can be called directly.

## Architecture

```
Claude (Bash tool)
    ↓
browser-client.js (writes .browser-command)
    ↓
browser-daemon.js (polls, executes, writes .browser-result)
    ↓
Chrome Browser (Playwright-controlled)
```

**IPC Files:**
- `.browser-command` - Command input (JSON)
- `.browser-result` - Command output (JSON)
- `.browser-ready` - Ready signal (exists when daemon is running)

Files created/deleted automatically during operation.

## Commands

### navigate
Navigate to URL and wait for page load.
```bash
node browser-client.js navigate "http://localhost:8080/page"
```
Returns: `{ success: true, url: string, title: string }`

### exec
Execute JavaScript in browser context.
```bash
node browser-client.js exec "document.querySelectorAll('div').length"
```
Returns: `{ success: true, result: any }`

### console
Get all captured console logs.
```bash
node browser-client.js console
```
Returns: `{ success: true, logs: [{ type, text, location }] }`

### console-clear
Clear console log buffer.
```bash
node browser-client.js console-clear
```
Returns: `{ success: true }`

### status
Check daemon status and current page info.
```bash
node browser-client.js status
```
Returns: `{ success: true, url, title, consoleLogsCount }`

### resize
Resize browser viewport.
```bash
node browser-client.js resize 1920 1080
```
Returns: `{ success: true, width, height }`

## Daemon Behavior

- Launches Chrome (not Chromium) for H.264 codec support
- Viewport set to full available screen size on startup
- Automatically captures all console output (log, warn, error, debug, pageerror)
- Polls for commands every 100ms
- Lazy restart: When browser is closed and command is sent, daemon detects closure, restarts browser, restores last URL, then executes command

## Browser Configuration

```javascript
chromium.launch({
  channel: 'chrome',      // Use Google Chrome, not Chromium
  headless: false,        // Visible window
  args: ['--start-maximized']
})
```

## Important Quirks

**Manual window resizing does NOT work:**
- Playwright controls viewport independently from window
- Manually resizing browser window does NOT change viewport
- Window resize does NOT trigger JavaScript resize events
- Use `resize` command instead: `node browser-client.js resize 1024 768`

**DevTools overlay:**
- Opening DevTools does NOT resize viewport - overlays on top
- Does NOT trigger resize events
- Does NOT change `window.innerWidth/Height`

**Viewport vs Window:**
- `window.innerWidth/Height` - The viewport (controlled by Playwright)
- `window.outerWidth/Height` - The window size
- Only viewport can be changed via `resize` command

## Use Cases

**Interactive development:** Keep browser open while testing changes, reload and check console without manual interaction.

**Debugging console logs:** Track down log sources with automatic source location capture.

**Inspecting page state:** Query DOM, check element counts, inspect computed styles via JavaScript execution.

**Testing workflows:** Automate multi-step browser interactions (navigate, fill forms, submit, check results).

## Troubleshooting

**Daemon not responding:**
```bash
ls ~/.claude/skills/playwright-skill/.browser-ready
cd ~/.claude/skills/playwright-skill && node browser-daemon.js
```

**Commands timing out:**
- Check if browser window is still open
- Kill daemon and restart
- Clean up stuck files: `rm -f .browser-command .browser-result`

**Browser window closed:**
- Kill daemon (Ctrl+C)
- Restart: `node browser-daemon.js`
- Or send any command - lazy restart will trigger automatically

## Setup (First Time)

```bash
cd ~/.claude/skills/playwright-skill
npm install
```

This installs Playwright and downloads Chrome browser.

## Advanced Capabilities

See `META_COMMANDS.md` for comprehensive reference of Playwright's meta-level capabilities beyond basic testing:
- Page events (console, network, dialogs, workers, frames, lifecycle)
- Content capture (screenshots, PDFs, HTML, video)
- Network control (interception, mocking, HAR replay, WebSockets)
- Script injection and Node.js function exposure
- Performance metrics and garbage collection
- Chrome DevTools Protocol (CDP) access for low-level browser control
- Browser context events and meta methods

## Integration Notes

When user requests browser interaction:
1. Check if daemon is running (`.browser-ready` file exists)
2. If not, offer to start as background task
3. Use `browser-client.js` commands to perform actions
4. Report results back to user

User can request additional features - the codebase is straightforward and well-documented for extensions.
