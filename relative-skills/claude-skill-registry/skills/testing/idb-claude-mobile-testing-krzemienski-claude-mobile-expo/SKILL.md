---
name: idb-claude-mobile-testing
description: Use when testing Claude Code Mobile app on iOS simulator with IDB CLI, when xc-mcp tools unavailable, or when needing testID-based UI automation - provides systematic workflow for finding elements by testID, tapping, typing, and verifying interactions using IDB accessibility tree
---

# IDB CLI Testing for Claude Code Mobile

## Overview

**Systematic UI automation using IDB CLI for Claude Code Mobile app testing.**

**Core principle:** Use IDB accessibility tree to find elements by testID (AXUniqueId), extract coordinates, then interact. No guessing coordinates. No MCP dependencies.

**When to use:** xc-mcp unavailable, expo-mcp local tools unavailable, need autonomous Gate 4A testing

## Prerequisites Check

```bash
# Verify IDB installed
which idb && which idb_companion

# Start idb_companion (if not running)
ps aux | grep idb_companion || idb_companion &

# Verify simulator booted
idb list-targets | grep Booted

# Verify IDB connected
idb list-apps --udid booted | head -5
```

**Must show**: IDB commands working, companion running, simulator booted

## Core Workflow: Find by testID → Tap

### Step 1: Get UI Tree with testIDs

```bash
# Get complete accessibility tree (includes all AXUniqueId = testID)
idb ui describe-all --udid booted > /tmp/ui-tree.json

# Or save to project
idb ui describe-all --udid booted > logs/ui-tree.json
```

**Returns**: JSON array of ALL UI elements with:
- `AXUniqueId`: The testID from React Native
- `frame`: {x, y, width, height} for tapping
- `AXLabel`: Visual label text
- `enabled`: Whether element is interactive
- `type`: Button, TextArea, StaticText, etc.

### Step 2: Find Element by testID

**Use jq to parse** (or Python/Node.js):

```bash
# Find send-button testID
cat logs/ui-tree.json | jq '.[] | select(.AXUniqueId == "send-button")'

# Extract just coordinates
cat logs/ui-tree.json | jq '.[] | select(.AXUniqueId == "send-button") | .frame'
# Returns: {"x":350, "y":798, "width":36, "height":36}
```

**Or find in output directly**:

```bash
idb ui describe-all --udid booted | grep -A 3 '"AXUniqueId":"send-button"'
```

### Step 3: Calculate Tap Coordinates

**Tap at CENTER of element**:

```
center_x = frame.x + (frame.width / 2)
center_y = frame.y + (frame.height / 2)
```

**Example**:
- Frame: {x:350, y:798, width:36, height:36}
- Center: x=368, y=816

### Step 4: Tap the Element

```bash
# Tap send button (calculated center coordinates)
idb ui tap --udid booted 368 816
```

**Verify** with screenshot:

```bash
xcrun simctl io booted screenshot logs/after-tap.png
```

## Complete Test Workflows

### Test 1: Tap Message Input and Type

```bash
# 1. Get UI tree
idb ui describe-all --udid booted > logs/ui-tree.json

# 2. Find message-input coordinates
INPUT_COORDS=$(cat logs/ui-tree.json | jq -r '.[] | select(.AXUniqueId == "message-input") | "\(.frame.x + .frame.width/2) \(.frame.y + .frame.height/2)"')

# 3. Tap input field (split coordinates)
IDB_X=$(echo $INPUT_COORDS | cut -d' ' -f1)
IDB_Y=$(echo $INPUT_COORDS | cut -d' ' -f2)
idb ui tap --udid booted $IDB_X $IDB_Y

# 4. Type text
idb ui text --udid booted "Hello Claude"

# 5. Screenshot to verify
xcrun simctl io booted screenshot logs/message-typed.png
```

### Test 2: Tap Send Button

```bash
# 1. Find send-button (same process)
SEND_COORDS=$(cat logs/ui-tree.json | jq -r '.[] | select(.AXUniqueId == "send-button") | "\(.frame.x + .frame.width/2) \(.frame.y + .frame.height/2)"')

# 2. Tap send button
idb ui tap --udid booted $(echo $SEND_COORDS | cut -d' ' -f1) $(echo $SEND_COORDS | cut -d' ' -f2)

# 3. Screenshot result
xcrun simctl io booted screenshot logs/message-sent.png
```

### Test 3: Navigate to Settings

```bash
# 1. Get fresh UI tree (in case elements moved)
idb ui describe-all --udid booted > logs/ui-tree-2.json

# 2. Find settings-button
SETTINGS_COORDS=$(cat logs/ui-tree-2.json | jq -r '.[] | select(.AXUniqueId == "settings-button") | "\(.frame.x + .frame.width/2) \(.frame.y + .frame.height/2)"')

# 3. Tap settings
idb ui tap --udid booted $(echo $SETTINGS_COORDS | cut -d' ' -f1) $(echo $SETTINGS_COORDS | cut -d' ' -f2)

# 4. Wait for navigation animation
sleep 1

# 5. Screenshot Settings screen
xcrun simctl io booted screenshot logs/settings-screen.png
```

## Python Helper Script (Recommended)

**For complex testing, use Python**:

```python
#!/usr/bin/env python3
import json
import subprocess
import sys

def get_ui_tree(udid="booted"):
    """Get UI accessibility tree"""
    result = subprocess.run(
        ["idb", "ui", "describe-all", "--udid", udid],
        capture_output=True, text=True
    )
    return json.loads(result.stdout)

def find_element_by_testid(tree, testid):
    """Find element by AXUniqueId (testID)"""
    for element in tree:
        if element.get("AXUniqueId") == testid:
            return element
    return None

def get_tap_coordinates(element):
    """Calculate center coordinates for tapping"""
    frame = element["frame"]
    x = frame["x"] + frame["width"] / 2
    y = frame["y"] + frame["height"] / 2
    return int(x), int(y)

def tap_element(testid, udid="booted"):
    """Find element by testID and tap it"""
    tree = get_ui_tree(udid)
    element = find_element_by_testid(tree, testid)

    if not element:
        print(f"Element with testID '{testid}' not found")
        return False

    if not element.get("enabled", False):
        print(f"Element '{testid}' found but not enabled")
        return False

    x, y = get_tap_coordinates(element)
    print(f"Tapping '{testid}' at ({x}, {y})")

    subprocess.run(["idb", "ui", "tap", "--udid", udid, str(x), str(y)])
    return True

def type_text(text, udid="booted"):
    """Type text into focused field"""
    subprocess.run(["idb", "ui", "text", "--udid", udid, text])

# Usage examples
if __name__ == "__main__":
    # Tap message input
    tap_element("message-input")

    # Type message
    type_text("Hello Claude")

    # Tap send button
    tap_element("send-button")
```

**Save as**: `scripts/idb-test-helper.py`

**Use**:
```bash
python scripts/idb-test-helper.py
```

## Claude Code Mobile testIDs

**All interactive elements have testIDs** (from codebase review):

**ChatScreen**:
- `chat-header` - Header container
- `connection-status` - Connection indicator
- `settings-button` - Settings gear icon
- `message-list` - Messages FlatList
- `message-bubble-{id}` - Individual message
- `message-input` - Text input field
- `send-button` - Send button
- `slash-command-menu` - Command menu
- `slash-command-{name}` - Individual command

**SettingsScreen**:
- `settings-header` - Header
- `back-button` - Back navigation
- `server-url-input` - Server URL field
- `project-path-input` - Project path field
- `auto-scroll-toggle` - Auto-scroll switch
- `haptic-toggle` - Haptic feedback switch
- `view-sessions-button` - View sessions button

**Other Screens**:
- `filebrowser-header`, `file-search-input`, `file-list`, `file-item-{path}`
- `codeviewer-header`, `code-content`
- `sessions-header`, `sessions-list`, `session-item-{id}`

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Try xc-mcp first" | WRONG if unavailable. Check IDB directly. |
| "Guess coordinates" | WRONG. Always get UI tree first. |
| "Tap without verifying enabled" | WRONG. Check `enabled: true` in tree. |
| "Use old UI tree" | WRONG. Elements move. Get fresh tree before each tap. |
| "Tap corner of element" | WRONG. Tap CENTER for reliability. |

## Red Flags

- "xc-mcp should work" → WRONG if "Not connected". Use IDB.
- "I know where button is" → WRONG. Get UI tree.
- "Coordinates won't change" → WRONG. Re-fetch for accuracy.

## Integration with Gate 4A

**Complete Gate 4A workflow**:

```bash
# 1. Screenshot initial state
xcrun simctl io booted screenshot logs/01-initial.png

# 2. Tap message input
idb ui describe-all --udid booted > logs/ui.json
TAP_X=$(cat logs/ui.json | jq '.[] | select(.AXUniqueId == "message-input") | .frame.x + .frame.width/2')
TAP_Y=$(cat logs/ui.json | jq '.[] | select(.AXUniqueId == "message-input") | .frame.y + .frame.height/2')
idb ui tap --udid booted $TAP_X $TAP_Y

# 3. Type message
idb ui text --udid booted "test message"
xcrun simctl io booted screenshot logs/02-typed.png

# 4. Tap send
# (same process with send-button testID)

# 5. Navigate to Settings
# (same process with settings-button testID)

# 6. Verify all 5 screens
# (repeat for each screen's navigation buttons)
```

## Next Steps After Skill

Once skill is created and tested:
1. Use this skill to complete Gate 4A testing
2. Test all 12 Gate 4A criteria autonomously
3. Document results with screenshots
4. Declare Gate 4A PASS/FAIL based on evidence
