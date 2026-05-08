---
name: chrome-automation
description: Launch and control Chrome with AT-SPI2 accessibility for browser automation. Use when asked to start chrome, open browser, launch chrome, begin browser automation, or control web pages.
---

# Chrome Automation

Launch Chrome with accessibility features enabled for programmatic control via AT-SPI2.

## Quick Start

### Check if Chrome is Running
```bash
~/.claude/skills/chrome-automation/scripts/launch.sh status
```
Or manually:
```bash
pgrep -f "chrome.*no-sandbox" && echo "Running" || echo "Not running"
```

### Launch Chrome
```bash
~/.claude/skills/chrome-automation/scripts/launch.sh [URL]
```
The script automatically checks if Chrome is already running.

Or launch manually:
```bash
export DISPLAY=:1
export GTK_MODULES=gail:atk-bridge
export NO_AT_BRIDGE=0
export GNOME_ACCESSIBILITY=1

google-chrome \
    --no-sandbox \
    --disable-gpu \
    --start-maximized \
    --force-renderer-accessibility \
    --no-first-run \
    "https://google.com" &
```

### Restart Chrome
```bash
~/.claude/skills/chrome-automation/scripts/launch.sh restart [URL]
```

### Control Chrome (after launching)

List clickable elements:
```bash
chrome-a11y list
```

Click an element:
```bash
chrome-a11y click "Button Name"
```

Navigate to URL:
```bash
chrome-a11y navigate "https://example.com"
```

Type text:
```bash
chrome-a11y type "search query"
```

Send keyboard shortcut:
```bash
chrome-a11y key "ctrl+t"   # New tab
chrome-a11y key "ctrl+l"   # Focus address bar
```

### Stop Chrome
```bash
pkill -9 chrome
```

## Important Notes

1. **Must run in background** with `&` to avoid blocking
2. **`--force-renderer-accessibility`** is required for AT-SPI2 control
3. **`--no-sandbox`** is required when running as root
4. **Wait 3-5 seconds** after launch before using chrome-a11y

## Prerequisites

Ensure these are installed:
- TigerVNC running on `:1`
- AT-SPI2 packages: `gir1.2-atspi-2.0`, `at-spi2-core`, `python3-gi`
- The `chrome-a11y` tool in PATH

For detailed documentation, see [REFERENCE.md](REFERENCE.md).
