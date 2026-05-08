---
name: fastmcp-integration
description: Examples and patterns for integrating FastMCP Cloud servers with Claude Agent SDK using HTTP transport
---

# FastMCP Cloud Integration Skill

This skill provides examples and troubleshooting for FastMCP Cloud integration.

## Critical Pattern: Use HTTP Transport

**FastMCP Cloud uses HTTP, NOT SSE!**

### ✅ Correct Configuration

**Example: Basic FastMCP Cloud Integration**

```python
import os
import asyncio
from dotenv import load_dotenv
from claude_agent_sdk import query
from claude_agent_sdk.types import ClaudeAgentOptions

load_dotenv()

ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")
FASTMCP_CLOUD_API_KEY = os.getenv("FASTMCP_CLOUD_API_KEY")

async def main():
    async for message in query(
        prompt="List available tools from the MCP server",
        options=ClaudeAgentOptions(
            model="claude-sonnet-4-20250514",

            # ✅ CRITICAL: Use HTTP for FastMCP Cloud
            mcp_servers={
                "your-server": {
                    "type": "http",  # ← Must be "http" not "sse"
                    "url": "https://your-server.fastmcp.app/mcp",
                    "headers": {
                        "Authorization": f"Bearer {FASTMCP_CLOUD_API_KEY}"
                    }
                }
            },

            # Allow MCP tools
            allowed_tools=["mcp__your-server__*"],

            # Pass API keys via env
            env={
                "ANTHROPIC_API_KEY": ANTHROPIC_API_KEY,
                "FASTMCP_CLOUD_API_KEY": FASTMCP_CLOUD_API_KEY
            }
        )
    ):
        if hasattr(message, 'type') and message.type == 'text':
            print(message.text)

if __name__ == "__main__":
    asyncio.run(main())
```

**Example: Multiple FastMCP Cloud Servers**

```python
mcp_servers={
    "cats": {
        "type": "http",
        "url": "https://catsmcp.fastmcp.app/mcp",
        "headers": {"Authorization": f"Bearer {FASTMCP_CLOUD_API_KEY}"}
    },
    "github": {
        "type": "http",
        "url": "https://github-mcp.fastmcp.app/mcp",
        "headers": {"Authorization": f"Bearer {FASTMCP_CLOUD_API_KEY}"}
    }
}

allowed_tools=[
    "mcp__cats__*",      # All CATS tools
    "mcp__github__*",    # All GitHub tools
]
```

**Example: Checking MCP Connection Status**

```python
async for message in query(...):
    if hasattr(message, 'type') and message.type == 'system':
        if hasattr(message, 'data') and 'mcp_servers' in message.data:
            for server in message.data['mcp_servers']:
                status = server.get('status', 'unknown')
                name = server.get('name', 'unknown')
                print(f"✅ MCP Server '{name}': {status}")

                if status == 'failed':
                    print("❌ Connection failed!")
                    print("   Check: 1) Using 'type': 'http'")
                    print("   Check: 2) FASTMCP_CLOUD_API_KEY is valid")
                    print("   Check: 3) URL is correct")
```

### ❌ Common Mistakes

**Wrong transport type:**
```python
"type": "sse"  # ❌ Doesn't work with FastMCP Cloud
```

**Missing API key:**
```python
# ❌ Not passing FASTMCP_CLOUD_API_KEY
env={"ANTHROPIC_API_KEY": ANTHROPIC_API_KEY}
```

**Wrong package:**
```python
from anthropic_agent_sdk import query  # ❌ Wrong!
# Should be:
from claude_agent_sdk import query  # ✅ Correct
```

## Troubleshooting

### Symptom: `'mcp_servers': [{'name': 'cats', 'status': 'failed'}]`

**Causes:**
1. Using `"type": "sse"` instead of `"type": "http"`
2. Missing or invalid `FASTMCP_CLOUD_API_KEY`
3. Wrong URL format

**Fix:**
- Change to `"type": "http"`
- Verify API key is correct and passed in `env` parameter
- Ensure URL is `https://your-server.fastmcp.app/mcp` (with `/mcp` endpoint)

### Symptom: `ImportError: No module named 'anthropic_agent_sdk'`

**Cause:** Wrong package name

**Fix:**
```bash
pip uninstall anthropic-agent-sdk  # Remove wrong package
pip install claude-agent-sdk       # Install correct package
```

## Complete Example

See `examples/python/fastmcp-cloud-http.py` for a full working example.

## Environment Variables

Required in `.env`:
```env
ANTHROPIC_API_KEY=sk-ant-api03-...
FASTMCP_CLOUD_API_KEY=fmcp_...
```

Must be passed via `env` parameter:
```python
env={
    "ANTHROPIC_API_KEY": os.getenv("ANTHROPIC_API_KEY"),
    "FASTMCP_CLOUD_API_KEY": os.getenv("FASTMCP_CLOUD_API_KEY")
}
```

## What The Output Actually Looks Like

### Example: Successful Connection

When you run your agent, you'll see system messages like this:

```python
# System message with connection status
SystemMessage(
    subtype='init',
    data={
        'type': 'system',
        'session_id': 'c8feee3e-bb62-4dcc-92bc-042b507e614a',
        'mcp_servers': [{'name': 'cats', 'status': 'connected'}],  # ✅ Connected!
        'tools': ['mcp__cats__search_candidates', 'mcp__cats__get_candidate', ...],
        'model': 'claude-sonnet-4-20250514',
        ...
    }
)
```

**What this means:**
- `'status': 'connected'` ✅ - Your HTTP configuration worked!
- `'tools': [...]` - All 163 CATS tools are now available
- Agent can now use `mcp__cats__search_candidates`, etc.

### Example: Failed Connection

If you use wrong transport type, you'll see:

```python
SystemMessage(
    data={
        'mcp_servers': [{'name': 'cats', 'status': 'failed'}],  # ❌ Failed!
        'tools': ['Task', 'Bash', 'Read', ...],  # Only built-in tools, no MCP tools
        ...
    }
)
```

**What this means:**
- `'status': 'failed'` ❌ - Connection didn't work
- No `mcp__cats__*` tools available
- Common cause: Using `"type": "sse"` instead of `"type": "http"`

### Example: Tool Call

When Claude uses an MCP tool:

```python
# Claude decides to call search_candidates
AssistantMessage(
    content=[
        ToolUseBlock(
            id='toolu_01HhvXi5wyvVa2DWtbP8KvJw',
            name='mcp__cats__search_candidates',
            input={'search_string': 'heavy duty mechanic'}
        )
    ]
)

# Tool result comes back
UserMessage(
    content=[
        ToolResultBlock(
            tool_use_id='toolu_01HhvXi5wyvVa2DWtbP8KvJw',
            content='{"count":2,"total":3540,"_embedded":{"candidates":[...]}}'
        )
    ]
)

# Claude responds with analysis
AssistantMessage(
    content=[
        TextBlock(
            text="I found 3,540 heavy duty mechanic candidates. Here are the first 2..."
        )
    ]
)
```

### Real Output From Working Demo

```
================================================================================
CATS Multi-Tool Agent Demo - Claude Agent SDK
================================================================================

🔌 MCP Server Status:
--------------------------------------------------------------------------------
✅ cats: CONNECTED

📦 Available CATS Tools: 163
   - search_candidates
   - get_candidate
   - list_candidate_custom_fields
   - list_candidate_attachments
   - parse_resume
   ... and 158 more

💬 Claude:
--------------------------------------------------------------------------------
I'll search for heavy duty mechanics using the CATS database...

💬 Claude:
--------------------------------------------------------------------------------
I found 3,540 heavy duty mechanic candidates in the system. Here are the
first 2 results with their Red Seal certification status:

1. **Sahlan Samsuddin**
   - Email: sahlansamsuddin11@gmail.com
   - Location: Mimika, Papua
   - Red Seal Status: Not found in "Notes on Qualifications" field
   - Tags: None

2. **[Next candidate]**
   ...
```

## Additional Examples

See the `examples/` directory in this skill:
- `examples/multi-server.py` - Connecting to multiple FastMCP Cloud servers
- `examples/connection-status.py` - Testing and troubleshooting connections
- `@plugins/claude-agent-sdk/examples/python/complete-example-with-output.py` - Full example with output

## Related Resources

- Basic example: `@plugins/claude-agent-sdk/examples/python/basic-query.py`
- FastMCP Cloud example: `@plugins/claude-agent-sdk/examples/python/fastmcp-cloud-http.py`
- Examples README: `@plugins/claude-agent-sdk/examples/README.md`
- Agent SDK Docs: `@plugins/claude-agent-sdk/docs/sdk-documentation.md`
- FastMCP Cloud: https://fastmcp.com
- MCP Protocol: https://modelcontextprotocol.io
