---
name: Browser Daemon
description: Persistent browser automation via Playwright daemon. Keep a browser window open and send it commands (navigate, execute JS, inspect console). Perfect for interactive debugging, development, and testing web applications. Use when you need to interact with a browser repeatedly without opening/closing it.
version: 7.2.0
author: hypatia-earth
tags: [browser, automation, debugging, playwright, daemon, console-logs, screenshots]
---

# Browser Daemon - Persistent Browser Automation

Persistent browser daemon that keeps Chrome open and accepts commands via file-based IPC.

## Quick Start

### Start the daemon (once per session)

```bash
cd ~/.claude/skills/playwright-skill
node browser-daemon.js [--size=quarter|dev|full|WIDTHxHEIGHT] [--persist]
```

**Options:**
- `--size=dev` - Fixed 900×860 viewport (default, good for development)
- `--size=quarter` - Screen size divided by 2 (e.g., 1512×948 → 756×474)
- `--size=full` - Full screen size
- `--size=1024x768` - Custom width×height
- `--persist` - Preserve IndexedDB, localStorage, cookies across restarts

Or ask: "Start the browser daemon in the background"

The browser window opens and stays open.

### Send commands

```bash
cd ~/.claude/skills/playwright-skill

# Navigate
node browser-client.js navigate "http://localhost:8080/..."

# Reload current page
node browser-client.js reload

# Execute JavaScript
node browser-client.js exec "document.title"
node browser-client.js exec "document.querySelectorAll('div').length"

# Console logs
node browser-client.js console
node browser-client.js console-clear

# Status & Inspection
node browser-client.js status
node browser-client.js inspect
node browser-client.js list

# Screenshots
node browser-client.js screenshot /path/to/output.png
node browser-client.js screenshot /path/to/output.png fullpage

# Resize viewport
node browser-client.js resize 1920 1080

# Shutdown
node browser-client.js shutdown
```

### Window close behavior

**New: Close window = shutdown daemon**
- Closing the browser window (Cmd-W or red X button) automatically shuts down the daemon
- No restart - daemon exits completely
- Clean shutdown with proper cleanup of state files

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
Navigate to URL and wait for page load. Clears console logs.
```bash
node browser-client.js navigate "http://localhost:8080/page"
```
Returns: `{ success: true, url: string, title: string }`

### reload
Reload current page (like F5 or Cmd-R). Clears console logs.
```bash
node browser-client.js reload
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

### inspect
Get detailed daemon status information.
```bash
node browser-client.js inspect
```
Returns detailed status including:
- Process: PID, uptime, memory usage, size preset
- Browser: connection status, type, version
- Page: URL, title, viewport dimensions
- Console log count

### list
Check if daemon is running and show basic info.
```bash
node browser-client.js list
```
Shows daemon status and suggests how to start if not running.

### screenshot ⚠️ Requires Permission
Capture screenshot of current page.

**IMPORTANT:** This command writes files to disk and requires explicit user permission before use.

```bash
node browser-client.js screenshot /path/to/output.png
node browser-client.js screenshot /path/to/output.png fullpage
node browser-client.js screenshot /path/to/output.png .selector
```
Returns: `{ success: true, path: string, selector?: string }`

Options:
- Default: Captures viewport only
- `fullpage`: Captures entire scrollable page
- `.selector`: Captures specific element only

### screenshot-clean ⚠️ Requires Permission
Capture canvas/element screenshot without UI overlay.

**IMPORTANT:** This command writes files to disk and requires explicit user permission before use.

Temporarily hides UI elements, captures the canvas, then restores UI. Perfect for WebGPU/WebGL canvas screenshots without overlaid controls.

```bash
node browser-client.js screenshot-clean /path/to/output.png
node browser-client.js screenshot-clean /path/to/output.png .scene-canvas
node browser-client.js screenshot-clean /path/to/output.png .scene-canvas #app
```
Returns: `{ success: true, path: string, selector: string, hidden: string }`

Arguments:
- `path`: Output file path (required)
- `canvas-selector`: Element to capture (default: `.scene-canvas`)
- `hide-selector`: Element to hide during capture (default: `#app`)

### resize
Resize browser viewport.
```bash
node browser-client.js resize 1920 1080
```
Returns: `{ success: true, width, height }`

### shutdown
Gracefully shutdown the daemon.
```bash
node browser-client.js shutdown
```
Returns: `{ success: true, message: string }`

Closes browser and exits daemon process cleanly.

### wait-for-load (helper script)
Wait for page to signal it's loaded via console marker.
```bash
./wait-for-load.sh
```

Polls console logs for `[PAGE_LOADED]` marker (30s timeout).
Useful for automation - ensures page is fully initialized before taking screenshots or running tests.

## Complete Screenshot Workflow

**Automated sequence: open → navigate → wait → screenshot → cleanup**

```bash
# Start daemon with dev size viewport
node browser-daemon.js --size=dev &

# Wait for daemon to start
sleep 3

# Navigate to target URL
node browser-client.js navigate http://localhost:8080

# Wait for page to signal it's loaded (smart wait)
./wait-for-load.sh

# Take screenshot
node browser-client.js screenshot /path/to/screenshot.png

# Clean shutdown
node browser-client.js shutdown
```

**Alternative: Manual timing**
```bash
# Navigate to target URL
node browser-client.js navigate http://localhost:8080

# Wait for page to fully load (fixed wait)
sleep 5

# Verify page loaded by checking console
node browser-client.js console | tail -20
```

This workflow is perfect for:
- Automated visual regression testing
- Documentation screenshots
- CI/CD screenshot capture
- Periodic monitoring snapshots

## Daemon Behavior

- Launches Chrome (not Chromium) for H.264 codec support
- Viewport size configured at startup via `--size` flag
- Automatically captures all console output (log, warn, error, debug, pageerror)
- Polls for commands every 100ms
- Window close detection: Closing browser window shuts down daemon completely
- Single instance: Each daemon controls one browser window

## Browser Configuration

```javascript
chromium.launch({
  channel: 'chrome',      // Use Google Chrome, not Chromium
  headless: false,        // Visible window
  args: ['--start-maximized']
})
```

Viewport size set after launch based on `--size` preset or calculated from screen dimensions.

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

**Window close behavior:**
- Closing browser window (Cmd-W or red X) triggers clean shutdown
- No automatic restart - daemon exits completely
- All state files cleaned up on exit

## Use Cases

**Interactive development:** Keep browser open while testing changes, reload and check console without manual interaction.

**Debugging console logs:** Track down log sources with automatic source location capture.

**Inspecting page state:** Query DOM, check element counts, inspect computed styles via JavaScript execution.

**Testing workflows:** Automate multi-step browser interactions (navigate, fill forms, submit, check results).

**Automated screenshots:** Capture page state for documentation, testing, or monitoring.

**Visual regression testing:** Take screenshots before/after changes to detect visual differences.

## Troubleshooting

**Daemon not responding:**
```bash
# Check if daemon is running
node browser-client.js list

# Or check for ready file
ls ~/.claude/skills/playwright-skill/.browser-ready

# Restart daemon
cd ~/.claude/skills/playwright-skill && node browser-daemon.js
```

**Commands timing out:**
- Check if browser window is still open
- Use `shutdown` command to cleanly stop daemon
- Clean up stuck files: `rm -f .browser-command .browser-result .browser-ready`

**Multiple instances running:**
```bash
# List running daemons
ps aux | grep browser-daemon

# Kill all instances
pkill -f browser-daemon

# Clean up state files
rm -f ~/.claude/skills/playwright-skill/.browser-*
```

**Browser window closed accidentally:**
- Daemon automatically shuts down when window is closed
- Start new daemon: `node browser-daemon.js [--size=...]`

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
1. Check if daemon is running: `node browser-client.js list`
2. If not running, start daemon **in background** (it never returns):
   ```bash
   node ~/.claude/skills/playwright-skill/browser-daemon.js --size=dev &
   ```
3. Use `browser-client.js` commands (these return quickly):
   ```bash
   node ~/.claude/skills/playwright-skill/browser-client.js navigate "http://example.com"
   ```
4. Report results back to user
5. Shutdown when done: `browser-client.js shutdown` (or let user close window)

**Important:** The daemon process runs forever until shutdown. Always start with `&` or as a background task.

User can request additional features - the codebase is straightforward and well-documented for extensions.

## Version History

**v7.2.0 (Current)**
- `--persist` flag: preserves IndexedDB, localStorage, cookies across restarts
- Data stored in `.browser-data/` directory

**v7.1.0**
- New `screenshot-clean` command: captures canvas without UI overlay
- `screenshot` now supports element selector (e.g., `.scene-canvas`)
- Perfect for WebGPU/WebGL canvas screenshots

**v7.0.0**
- Added viewport size presets (`--size=quarter|dev|full|WxH`)
- Window close detection triggers daemon shutdown
- New commands: `inspect`, `shutdown`, `list`
- Improved single-instance behavior
- Enhanced screenshot workflow documentation

**v6.0.0**
- Initial documented version with core functionality
