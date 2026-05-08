---
name: mcp-tester
description: Test MCP server connectivity and tool execution. Use when adding new MCP servers, debugging tool integration, or verifying tool availability. Supports stdio, http, and sse server types.
allowed-tools: Read, Bash, Grep
---

# MCP Server Testing

Test and debug MCP (Model Context Protocol) server connections.

## Server Types

| Type | Transport | Use Case |
|------|-----------|----------|
| `stdio` | Standard I/O | Local processes, CLI tools |
| `http` | HTTP/HTTPS | Remote APIs, cloud services |
| `sse` | Server-Sent Events | Streaming endpoints |

## Test Categories

### 1. Connection Test

Verify server is reachable and initializes correctly.

```bash
# Test stdio server
npx -y @modelcontextprotocol/inspector stdio -- npx -y @modelcontextprotocol/server-filesystem /tmp

# Test HTTP server
curl -X POST https://mcp.service.com/initialize \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{},"id":1}'
```

### 2. Tool Discovery

List available tools from a connected server.

```bash
# Using MCP inspector
npx -y @modelcontextprotocol/inspector stdio -- python ./mcp_servers/my_server.py

# Check tool listing
curl -X POST https://mcp.service.com/tools/list \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","params":{},"id":2}'
```

### 3. Tool Execution

Test individual tool invocation.

```python
# Python test script
import asyncio
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def test_tool():
    server_params = StdioServerParameters(
        command="npx",
        args=["-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
    )

    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()

            # List tools
            tools = await session.list_tools()
            print(f"Available tools: {[t.name for t in tools.tools]}")

            # Execute tool
            result = await session.call_tool(
                "read_file",
                {"path": "/tmp/test.txt"}
            )
            print(f"Result: {result.content}")

asyncio.run(test_tool())
```

### 4. Error Handling

Verify graceful error handling.

```python
# Test invalid tool call
try:
    result = await session.call_tool("nonexistent_tool", {})
except Exception as e:
    print(f"Expected error: {e}")

# Test invalid parameters
try:
    result = await session.call_tool("read_file", {"invalid": "param"})
except Exception as e:
    print(f"Expected error: {e}")
```

## Configuration Validation

### .mcp.json Schema

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio | http | sse",
      "command": "string (for stdio)",
      "args": ["array", "of", "args"],
      "env": {
        "VAR": "value or ${ENV_VAR}"
      },
      "url": "string (for http/sse)",
      "headers": {
        "Authorization": "Bearer ${TOKEN}"
      }
    }
  }
}
```

### Environment Variable Expansion

```json
{
  "env": {
    "API_KEY": "${MY_API_KEY}",
    "BASE_URL": "${BASE_URL:-http://localhost:8080}"
  }
}
```

## Debugging Commands

```bash
# Check if server process starts
npx -y @modelcontextprotocol/server-filesystem /tmp

# Verbose mode for debugging
DEBUG=mcp:* npx -y @modelcontextprotocol/inspector stdio -- ./my_server

# Check environment variables
env | grep -E 'API_KEY|TOKEN|URL'

# Test HTTP endpoint
curl -v https://mcp.service.com/health
```

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Connection refused | Server not running | Start server process |
| Tool not found | Wrong tool name | Check `tools/list` response |
| Auth error | Missing/invalid token | Set environment variable |
| Timeout | Server slow/hanging | Check server logs |
| Parse error | Invalid JSON-RPC | Validate request format |

## Health Check Endpoint

```python
@app.get("/health")
async def health_check():
    """MCP server health check."""
    return {"status": "healthy", "version": "1.0.0"}
```
