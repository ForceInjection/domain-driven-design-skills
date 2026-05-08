---
name: create-plugin
description: Create Hamr launcher plugins with proper JSON protocol, testing, and manifest structure
license: MIT
compatibility: opencode
metadata:
  project: hamr
  type: plugin-development
---

# Creating Hamr Plugins

This skill helps you create plugins for the Hamr launcher. Plugins communicate via JSON over stdin/stdout.

## Reference Documentation

For complete protocol details, see:
- `plugins/README.md` - Full JSON protocol reference, response types, and examples
- `plugins/AGENTS.md` - Condensed reference for AI agents

## Plugin Structure

### Simple Action (Script)

Single executable file in `~/.config/hamr/plugins/`:

```bash
#!/bin/bash
notify-send "Hello!"
```

### Multi-Step Workflow (Folder)

```
my-plugin/
├── manifest.json   # Plugin metadata
├── handler.py      # Main handler (executable)
└── test.sh         # Test script
```

## manifest.json

```json
{
  "name": "My Plugin",
  "description": "What it does",
  "icon": "material_icon_name",
  "trigger": "/myplugin"
}
```

Optional fields:
- `"handler": "handler.js"` - Custom handler filename
- `"poll": 2000` - Auto-refresh interval in ms
- `"index": {"enabled": true}` - Enable launcher indexing

## Handler Template (Python)

```python
#!/usr/bin/env python3
import json
import os
import sys

TEST_MODE = os.environ.get("HAMR_TEST_MODE") == "1"

def main():
    input_data = json.load(sys.stdin)
    step = input_data.get("step", "initial")
    query = input_data.get("query", "").strip()
    selected = input_data.get("selected", {})
    action = input_data.get("action", "")
    context = input_data.get("context", "")

    if step == "initial":
        print(json.dumps({
            "type": "results",
            "results": [
                {"id": "item1", "name": "First Item", "icon": "star"},
            ],
            "placeholder": "Search..."
        }))
        return

    if step == "search":
        # Filter based on query
        print(json.dumps({
            "type": "results",
            "results": [...],
            "inputMode": "realtime"
        }))
        return

    if step == "action":
        item_id = selected.get("id", "")
        
        if item_id == "__back__":
            # Handle back navigation
            print(json.dumps({
                "type": "results",
                "results": get_initial_results(),
                "clearInput": True
            }))
            return

        # Execute action
        print(json.dumps({
            "type": "execute",
            "execute": {
                "command": ["notify-send", f"Selected: {item_id}"],
                "close": True
            }
        }))

if __name__ == "__main__":
    main()
```

## JSON Protocol

### Input (stdin)

```python
{
    "step": "initial|search|action|index|poll",
    "query": "user text",
    "selected": {"id": "item-id"},
    "action": "action-button-id",
    "context": "your-state",
    "session": "session-id",
    "replay": true
}
```

### Response Types

**1. results** - Show list:
```python
{
    "type": "results",
    "results": [
        {
            "id": "unique-id",
            "name": "Display Name",
            "description": "Subtitle",
            "icon": "material_icon",
            "actions": [{"id": "copy", "name": "Copy", "icon": "content_copy"}]
        }
    ],
    "inputMode": "realtime",
    "placeholder": "Search...",
    "pluginActions": [{"id": "add", "name": "Add", "icon": "add_circle"}]
}
```

**2. execute** - Run command:
```python
{
    "type": "execute",
    "execute": {
        "command": ["xdg-open", "/path"],
        "notify": "Done",
        "close": True
    }
}
```

**3. card** - Rich content:
```python
{
    "type": "card",
    "card": {"content": "**Markdown**", "markdown": True}
}
```

**4. imageBrowser** - Image grid:
```python
{
    "type": "imageBrowser",
    "imageBrowser": {
        "directory": "~/Pictures",
        "title": "Select Image",
        "actions": [{"id": "set", "name": "Set", "icon": "check"}]
    }
}
```

**5. error** - Show error:
```python
{"type": "error", "message": "Something went wrong"}
```

## Input Modes

| Mode | Behavior |
|------|----------|
| `realtime` | Every keystroke triggers search |
| `submit` | Only Enter triggers search |

## Testing

Use the test-harness:

```bash
export HAMR_TEST_MODE=1
./plugins/test-harness ./plugins/my-plugin/handler.py initial
./plugins/test-harness ./plugins/my-plugin/handler.py search --query "test"
./plugins/test-harness ./plugins/my-plugin/handler.py action --id "item1"
```

### Test Script Template

```bash
#!/bin/bash
export HAMR_TEST_MODE=1
source "$(dirname "$0")/../test-helpers.sh"

TEST_NAME="My Plugin Tests"
HANDLER="$(dirname "$0")/handler.py"

test_initial() {
    local result=$(hamr_test initial)
    assert_type "$result" "results"
}

run_tests test_initial
```

## Mock Data Pattern

Always check `HAMR_TEST_MODE` for testing:

```python
TEST_MODE = os.environ.get("HAMR_TEST_MODE") == "1"

def get_data():
    if TEST_MODE:
        return [{"id": "mock", "name": "Mock Item"}]
    return fetch_real_data()
```

## Plugin Indexing

Enable searchable items in main launcher:

```json
{
  "index": {
    "enabled": true,
    "watchFiles": ["~/.config/my-data.json"]
  }
}
```

Handle `step == "index"`:

```python
if step == "index":
    print(json.dumps({
        "type": "index",
        "items": [
            {
                "id": "item1",
                "name": "Searchable Item",
                "keywords": ["alias"],
                "execute": {"command": ["xdg-open", "url"]}
            }
        ]
    }))
```

## Common Patterns

### Plugin Actions (Toolbar)

```python
"pluginActions": [
    {"id": "add", "name": "Add", "icon": "add_circle"},
    {"id": "wipe", "name": "Wipe", "icon": "delete_sweep", "confirm": "Are you sure?"}
]
```

Handle with `selected.get("id") == "__plugin__"`.

### Context for State

```python
# Set context
{"type": "results", "context": "__edit__:item1", "inputMode": "submit"}

# Read context in search
if context.startswith("__edit__:"):
    item_id = context.split(":")[1]
```

### History Tracking

```python
{
    "type": "execute",
    "execute": {
        "command": ["xdg-open", url],
        "name": "Open Example",  # Required for history
        "icon": "link",
        "close": True
    }
}
```

## Icon Types

- **Material** (default): `star`, `folder`, `content_copy`
- **System**: Set `"iconType": "system"` for desktop app icons

## Development Workflow

1. Create `manifest.json` with name, description, icon
2. Create `handler.py` with shebang, make executable
3. Test with `HAMR_TEST_MODE=1 ./plugins/test-harness`
4. Add mock data for test mode
5. Create `test.sh` for CI
6. Plugin auto-loads on file save
