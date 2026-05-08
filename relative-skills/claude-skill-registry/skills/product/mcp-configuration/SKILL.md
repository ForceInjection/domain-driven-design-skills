---
name: MCP Configuration
description: MCP server configuration templates and setup scripts. Use when configuring MCP servers, setting up MCP environment, managing MCP configs, adding MCP servers, or when user mentions MCP setup, MCP configuration, server environment, or MCP installation.
allowed-tools: Read, Write, Bash
---

# MCP Configuration

This skill provides MCP server configuration templates, setup scripts, and environment management helpers for Claude Code MCP integration.

## What This Skill Provides

### 1. Configuration Templates
- `.mcp.json` template for MCP server definitions
- Server configuration examples (FastMCP, Node.js, Python)
- API key management patterns

### 2. Setup Scripts
- `setup-mcp-server.sh` - Configure MCP server in .mcp.json
- `validate-mcp-config.sh` - Validate MCP configuration
- `list-mcp-servers.sh` - List available MCP servers

### 3. Server Type Templates
- stdio servers (local process)
- HTTP servers (remote API)
- SSE servers (server-sent events)

## Instructions

### Adding MCP Server Configuration

When user wants to configure MCP servers:

1. Check if .mcp.json exists in project
2. Use template to create/update configuration
3. Add server definition with type, command, args
4. Configure environment variables if needed

Example structure:
- mcpServers object
- Server name as key
- type: "stdio" or "http"
- command and args for stdio
- url for http servers

### Validating Configuration

Execute validation script:

!{bash plugins/01-core/skills/mcp-configuration/scripts/validate-mcp-config.sh .mcp.json}

Checks for:
- Valid JSON format
- Required fields present
- Correct server type
- Valid command paths

### Environment Setup

For MCP servers requiring API keys:

1. Create .env file (if not exists)
2. Add API key variables
3. Reference in MCP server config
4. Ensure .env is in .gitignore

## Configuration Examples

**FastMCP Server (stdio):**
- type: stdio
- command: python
- args: ["-m", "server_name"]

**HTTP Server:**
- type: http
- url: https://api.example.com

**With Environment Variables:**
- env: { API_KEY: "${API_KEY}" }
- Reads from .env file

## Success Criteria

- ✅ Valid .mcp.json configuration
- ✅ Server definitions are correct
- ✅ Environment variables configured
- ✅ API keys secured in .env
- ✅ Configuration validated

---

**Plugin**: 01-core
**Skill Type**: Generator + Validator
**Auto-invocation**: Yes (via description matching)
