---
name: castella-mcp
description: Enable AI agents to introspect and control Castella UIs via MCP. Create MCP servers, expose UI resources, handle MCP tools, and use semantic IDs.
---

# Castella MCP Integration

MCP (Model Context Protocol) enables AI agents to introspect and control Castella UIs programmatically. This provides a standard protocol for AI-UI interaction.

**When to use**: "enable MCP for Castella", "MCP server", "semantic ID", "MCP resources", "MCP tools", "SSE transport", "CastellaMCPServer", "control UI with MCP"

## Quick Start

Create an MCP-enabled Castella app:

```python
from castella import App, Column, Button, Input, Text
from castella.frame import Frame
from castella.mcp import CastellaMCPServer

# Build UI with semantic IDs
ui = Column(
    Text("Hello MCP!").semantic_id("greeting"),
    Input("").semantic_id("name-input"),
    Button("Submit").semantic_id("submit-btn"),
)

app = App(Frame("MCP Demo", 800, 600), ui)

# Create MCP server
mcp = CastellaMCPServer(app, name="my-castella-app")
mcp.run_in_background()  # Run MCP in background thread

app.run()  # Run UI on main thread
```

## Installation

```bash
uv sync --extra mcp   # MCP dependencies
```

## Semantic IDs

Assign stable, human-readable identifiers to widgets:

```python
Button("Submit").semantic_id("submit-btn")
Input("").semantic_id("email-input")
CheckBox(state).semantic_id("newsletter-checkbox")
Text("Status").semantic_id("status-text")
```

Auto-generated IDs (if not specified): `button_0`, `input_1`, etc.

### Best Practices for Semantic IDs

- Use descriptive names: `submit-form-btn`, not `btn1`
- Use kebab-case: `user-name-input`
- Include widget type: `email-input`, `save-btn`
- Match action/purpose: `login-btn`, `search-input`

## MCP Resources

Read-only data available to AI agents:

| URI | Description |
|-----|-------------|
| `ui://tree` | Complete UI tree structure |
| `ui://focus` | Currently focused element |
| `ui://elements` | All interactive elements |
| `ui://element/{id}` | Specific element details |
| `a2ui://surfaces` | A2UI surfaces (if A2UI enabled) |

### Example: UI Tree Resource

```json
{
  "type": "tree",
  "root": {
    "id": "root",
    "type": "Column",
    "children": [
      {"id": "greeting", "type": "Text", "value": "Hello MCP!"},
      {"id": "name-input", "type": "Input", "value": "", "interactive": true},
      {"id": "submit-btn", "type": "Button", "label": "Submit", "interactive": true}
    ]
  }
}
```

## MCP Tools

Actions AI agents can perform:

| Tool | Description | Parameters |
|------|-------------|------------|
| `click` | Click/tap element | `element_id` |
| `type_text` | Type into input | `element_id`, `text`, `replace` |
| `focus` | Set focus | `element_id` |
| `scroll` | Scroll container | `element_id`, `direction`, `amount` |
| `toggle` | Toggle checkbox/switch | `element_id` |
| `select` | Select in picker/tabs | `element_id`, `value` |
| `list_actionable` | List interactive elements | - |
| `send_a2ui` | Send A2UI message | `message` |

### Tool Examples

```python
# Click a button
click(element_id="submit-btn")

# Type into input (replace existing text)
type_text(element_id="name-input", text="Alice", replace=True)

# Type into input (append)
type_text(element_id="name-input", text=" Smith", replace=False)

# Toggle checkbox
toggle(element_id="newsletter-checkbox")

# Select tab
select(element_id="main-tabs", value="settings")

# Scroll down
scroll(element_id="message-list", direction="down", amount=100)
```

## Transports

### stdio (Default)

For MCP clients that communicate via stdin/stdout:

```python
mcp = CastellaMCPServer(app, name="my-app")
mcp.run_in_background()  # Uses stdio transport
```

### SSE (HTTP)

For HTTP-based MCP clients (Claude Desktop, web clients):

```python
mcp = CastellaMCPServer(app, name="my-app")
mcp.run_sse_in_background(host="localhost", port=8765)
```

SSE endpoints:
- `GET /sse` - SSE event stream
- `POST /message` - Send MCP messages
- `GET /health` - Health check

## Example: MCP Client (Python)

Control a Castella app via HTTP:

```python
import json
import urllib.request

def call_tool(name: str, **kwargs) -> dict:
    message = {
        "type": "call_tool",
        "params": {"name": name, "arguments": kwargs}
    }
    data = json.dumps(message).encode("utf-8")
    req = urllib.request.Request(
        "http://localhost:8765/message",
        data=data,
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read())

# Type into input
call_tool("type_text", element_id="name-input", text="Alice", replace=True)

# Click button
call_tool("click", element_id="submit-btn")

# Toggle checkbox
call_tool("toggle", element_id="newsletter-checkbox")

# List all interactive elements
result = call_tool("list_actionable")
print(result)
```

## A2UI + MCP Integration

Combine A2UI rendering with MCP control:

```python
from castella.a2ui import A2UIRenderer, A2UIComponent
from castella.mcp import CastellaMCPServer

renderer = A2UIRenderer(on_action=on_action)
renderer.render_json(a2ui_json)
surface = renderer.get_surface("default")

app = App(Frame("A2UI + MCP", 800, 600), A2UIComponent(surface))

# MCP with A2UI renderer for bidirectional integration
mcp = CastellaMCPServer(app, a2ui_renderer=renderer)
mcp.run_sse_in_background(port=8766)

app.run()
```

A2UI component IDs automatically become MCP semantic IDs.

### send_a2ui Tool

When A2UI renderer is provided, the `send_a2ui` tool becomes available:

```python
send_a2ui(message={
    "updateDataModel": {
        "surfaceId": "default",
        "data": {"/counter": 42}
    }
})
```

## API Reference

### CastellaMCPServer

```python
from castella.mcp import CastellaMCPServer

mcp = CastellaMCPServer(
    app=app,                    # Castella App instance
    name="my-app",              # MCP server name
    version="1.0.0",            # Version string
    a2ui_renderer=None,         # Optional A2UIRenderer
)

# Blocking methods
mcp.run()                       # Run stdio (blocks)
mcp.run_sse(host, port)         # Run SSE (blocks)

# Background methods
mcp.run_in_background()         # Run stdio in thread
mcp.run_sse_in_background(host, port)  # Run SSE in thread

# Management
mcp.refresh_registry()          # Refresh widget registry
mcp.stop()                      # Stop server
```

### ElementInfo

Information about a UI element:

```python
element = {
    "id": "submit-btn",
    "type": "Button",
    "label": "Submit",
    "value": None,
    "bounds": {"x": 10, "y": 100, "width": 80, "height": 40},
    "interactive": True,
    "focused": False,
}
```

## Best Practices

1. **Use descriptive semantic IDs** for all interactive elements
2. **Refresh registry** after major UI changes: `mcp.refresh_registry()`
3. **Use SSE transport** for remote/HTTP clients
4. **Combine with A2UI** for full agent-UI integration
5. **Handle errors** in tool calls gracefully

## Reference

- `references/resources.md` - Complete resource URI reference
- `references/tools.md` - Complete tool reference
- `references/types.md` - ElementInfo, UITreeNode types
- `scripts/` - Executable examples (mcp_basic.py, mcp_sse.py)
