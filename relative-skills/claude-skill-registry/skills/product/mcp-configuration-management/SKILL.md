---
name: MCP Configuration Management
description: Comprehensive MCP server configuration templates, .mcp.json management, API key handling, and server installation helpers. Use when configuring MCP servers, managing .mcp.json files, setting up API keys, installing MCP servers, validating MCP configs, or when user mentions MCP setup, server configuration, MCP environment, API key storage, or MCP installation.
allowed-tools: Read, Write, Bash, Grep, Glob
---

# MCP Configuration Management

This skill provides comprehensive tooling for managing MCP (Model Context Protocol) server configurations, including templates, validation scripts, API key management, and installation helpers.

## What This Skill Provides

### 1. Helper Scripts (13 scripts - v2.1 added 7)

**Registry Management (v2.1+):**
- `scripts/registry-init.sh` - Initialize universal MCP registry at ~/.claude/mcp-registry/
- `scripts/registry-add.sh` - Add server to universal registry
- `scripts/registry-list.sh` - List all servers in registry
- `scripts/registry-sync.sh` - Sync registry to target format(s)
- `scripts/transform-claude.sh` - Transform registry → .mcp.json (Claude Code format)
- `scripts/transform-vscode.sh` - Transform registry → .vscode/mcp.json (VS Code format)

**Configuration Management:**
- `scripts/init-mcp-config.sh` - Initialize .mcp.json with proper structure
- `scripts/add-mcp-server.sh` - Add new MCP server to existing config
- `scripts/validate-mcp-config.sh` - Validate .mcp.json structure and server definitions
- `scripts/manage-api-keys.sh` - Securely manage API keys in project .env files (v2.1: .env-only mode)
- `scripts/install-mcp-server.sh` - Install and configure MCP server packages

### 2. Configuration Templates (8 templates - v2.1 added 2)

**Server Type Templates:**
- `templates/basic-mcp-config.json` - Basic .mcp.json structure
- `templates/stdio-server.json` - stdio MCP server configuration
- `templates/http-server.json` - HTTP MCP server configuration
- `templates/python-fastmcp.json` - Python FastMCP server setup
- `templates/typescript-server.json` - TypeScript MCP server setup
- `templates/multi-server-config.json` - Multiple MCP servers configuration

**Registry Templates (v2.1+):**
- `templates/.env.example` - Complete .env template with all known MCP API keys
- Global: `~/.claude/mcp-registry/marketplace.json` - VS Code marketplace servers reference

### 3. Usage Examples (5 examples)

**Documentation:**
- `examples/basic-setup.md` - Basic MCP configuration setup
- `examples/api-key-management.md` - Secure API key handling patterns
- `examples/multiple-servers.md` - Managing multiple MCP servers
- `examples/troubleshooting.md` - Common issues and solutions
- `examples/production-config.md` - Production-ready MCP configurations

## Instructions

### RECOMMENDED: Universal Registry Workflow (v2.1+)

**Best Practice**: Use the universal registry for managing MCP servers across multiple formats (Claude Code, VS Code, Gemini, Qwen, Codex).

#### Step 1: Initialize Registry (One-time)

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-init.sh
```

Creates:
- `~/.claude/mcp-registry/servers.json` - Universal server definitions
- `~/.claude/mcp-registry/marketplace.json` - VS Code marketplace reference
- `~/.claude/mcp-registry/backups/` - Automatic backups
- `~/.claude/mcp-registry/README.md` - Documentation

#### Step 2: Add Servers to Registry

```bash
# stdio server example (most common)
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-add.sh context7 \
  --transport stdio \
  --command npx \
  --args "-y,@upstash/context7-mcp" \
  --env "CONTEXT7_API_KEY=\${CONTEXT7_API_KEY}" \
  --description "Up-to-date library documentation"

# http-remote server example
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-add.sh supabase \
  --transport http-remote \
  --url "https://mcp.supabase.com/mcp" \
  --description "Supabase database access"

# http-remote-auth server example (VS Code only)
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-add.sh github \
  --transport http-remote-auth \
  --url "https://api.githubcopilot.com/mcp/" \
  --header "Authorization: Bearer \${GITHUB_TOKEN}" \
  --description "GitHub Copilot MCP API"
```

#### Step 3: Sync Registry to Project

```bash
# Sync to Claude Code format (.mcp.json)
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-sync.sh claude

# Sync to VS Code format (.vscode/mcp.json)
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-sync.sh vscode

# Sync to both formats
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-sync.sh both
```

#### Step 4: Configure API Keys

```bash
# Add API keys to project .env
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/manage-api-keys.sh \
  --action add \
  --key-name CONTEXT7_API_KEY

# Use templates/.env.example as reference
```

#### Step 5: List and Search Registry

```bash
# List all servers
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-list.sh

# Or use jq directly
jq -r '.servers | to_entries[] | "\(.key) - \(.value.transport) - \(.value.description)"' \
  ~/.claude/mcp-registry/servers.json
```

### Initial MCP Configuration Setup (Direct Mode - Backward Compatible)

When user wants to set up MCP configuration:

1. **Check for existing configuration:**
   - Look for `.mcp.json` in project root or `~/.claude/` directory
   - Check if server is already configured

2. **Initialize configuration:**
   ```bash
   bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/init-mcp-config.sh [path]
   ```

3. **Use appropriate template:**
   - Read template from `templates/` directory
   - Customize based on server type (stdio, HTTP, Python, TypeScript)
   - Replace placeholder values with actual configuration

### Adding MCP Servers

To add a new MCP server to existing configuration:

1. **Execute add-mcp-server script:**
   ```bash
   bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/add-mcp-server.sh \
     --name "server-name" \
     --type "stdio|http" \
     --command "python" \
     --args "-m server_module" \
     --config-path ".mcp.json"
   ```

2. **Server types supported:**
   - **stdio**: Local process communication (most common)
   - **http**: Remote HTTP API servers
   - **sse**: Server-sent events (streaming)

3. **Common stdio configurations:**
   - Python FastMCP: `python -m fastmcp server_name`
   - TypeScript: `node dist/index.js`
   - Shell scripts: `bash ./server.sh`

### API Key Management

For servers requiring API keys or secrets:

1. **Create/update .env file:**
   ```bash
   bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/manage-api-keys.sh \
     --action add \
     --key-name "OPENAI_API_KEY" \
     --env-file ".env"
   ```

2. **Reference in MCP config:**
   - Use `${API_KEY}` syntax in .mcp.json
   - Keys are loaded from .env at runtime
   - Script ensures .env is in .gitignore

3. **Security best practices:**
   - Never commit API keys to version control
   - Use .env files for local development
   - Use environment variables in production
   - Rotate keys regularly

### Validating Configuration

Before using MCP configuration:

1. **Run validation script:**
   ```bash
   bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/validate-mcp-config.sh .mcp.json
   ```

2. **Validation checks:**
   - Valid JSON syntax
   - Required fields present (mcpServers object)
   - Server type is valid (stdio, http, sse)
   - Command paths exist for stdio servers
   - URLs are valid for HTTP servers
   - Environment variables are defined
   - No duplicate server names

3. **Auto-fix common issues:**
   - Script can suggest fixes for common problems
   - Validates against MCP schema

### Installing MCP Servers

To install MCP server packages:

1. **Use installation script:**
   ```bash
   bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/install-mcp-server.sh \
     --type "python|typescript|npm" \
     --package "fastmcp" \
     --global
   ```

2. **Installation types:**
   - Python: Uses pip/pip3, optionally in venv
   - TypeScript: Uses npm/pnpm/yarn
   - npm: Global or local package installation

3. **Post-installation:**
   - Adds server to .mcp.json automatically
   - Verifies installation success
   - Provides configuration examples

## Configuration Structure

### Basic .mcp.json Structure

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio",
      "command": "python",
      "args": ["-m", "server_module"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

### Environment Variables

MCP configs support variable substitution:
- `${VAR_NAME}` - Reads from environment or .env file
- Loaded at runtime by Claude Code
- Keeps secrets out of config files

## Common Use Cases

### Use Case 1: First-time MCP Setup
```bash
# Initialize config
bash scripts/init-mcp-config.sh ~/.claude/.mcp.json

# Add filesystem server
bash scripts/add-mcp-server.sh --name filesystem --type stdio \
  --command npx --args "@modelcontextprotocol/server-filesystem /path/to/files"

# Validate
bash scripts/validate-mcp-config.sh ~/.claude/.mcp.json
```

### Use Case 2: Adding API-based Server
```bash
# Add API key to .env
bash scripts/manage-api-keys.sh --action add --key-name OPENAI_API_KEY

# Add server with API key
bash scripts/add-mcp-server.sh --name openai --type http \
  --url "https://api.openai.com" --env-var OPENAI_API_KEY
```

### Use Case 3: Python FastMCP Server
```bash
# Install FastMCP
bash scripts/install-mcp-server.sh --type python --package fastmcp

# Use Python template
# Read: templates/python-fastmcp.json
# Customize and add to .mcp.json
```

## Templates Overview

| Template | Purpose | Use When |
|----------|---------|----------|
| basic-mcp-config.json | Minimal structure | Starting fresh |
| stdio-server.json | Local process | Most MCP servers |
| http-server.json | Remote API | Cloud services |
| python-fastmcp.json | Python FastMCP | Python MCP dev |
| typescript-server.json | TypeScript MCP | TS/Node MCP dev |
| multi-server-config.json | Multiple servers | Complex setups |

## Success Criteria

When configuration is complete:

- ✅ .mcp.json exists with valid JSON structure
- ✅ All server definitions have required fields
- ✅ Server types are valid (stdio, http, sse)
- ✅ Commands/paths exist for stdio servers
- ✅ API keys are in .env, not committed to git
- ✅ .env is in .gitignore
- ✅ Configuration passes validation script
- ✅ Servers can be loaded by Claude Code

## Error Handling

Common issues and solutions:

**Invalid JSON:**
- Run validation script for syntax errors
- Use templates as reference for correct structure

**Command not found:**
- Verify command exists: `which python` or `which node`
- Use absolute paths if needed: `/usr/bin/python`

**API key errors:**
- Verify .env file exists and is readable
- Check environment variable names match
- Ensure .env is in same directory as .mcp.json or parent

**Server not loading:**
- Check Claude Code logs for errors
- Validate configuration with script
- Test server command manually first

## Registry vs Direct Management

### Use Registry When:
- Working with multiple projects that share MCP servers
- Using multiple tools (Claude Code + VS Code)
- Need to track marketplace servers separately
- Want single source of truth for all configs
- Planning to add Gemini, Qwen, or Codex support

### Use Direct Management When:
- Single project, single tool (Claude Code only)
- Quick prototyping or testing
- Prefer simpler workflow without registry layer
- Backward compatibility requirements

## Format Conversion Reference

| Feature | Claude Code (.mcp.json) | VS Code (.vscode/mcp.json) |
|---------|-------------------------|---------------------------|
| Root key | `mcpServers` | `servers` |
| stdio support | ✅ Best | ✅ Good |
| http-local support | ⚠️ Manual start required | ✅ Full support |
| http-remote support | ✅ Partial | ✅ Full |
| http-remote-auth support | ❌ Not supported | ✅ Full support |
| Environment variables | `${VAR}` required | Direct or `${VAR}` |
| Marketplace servers | Not applicable | Pre-installed |

## Known MCP Servers

From `templates/.env.example`:
- context7 - Library documentation (stdio, API key)
- github-copilot - GitHub API (http-remote-auth, token)
- filesystem - Local file access (stdio)
- memory - OpenMemory/Mem0 (http-remote, API key)
- supabase - Database access (http-remote, credentials)
- playwright - Browser automation (marketplace, VS Code only)
- puppeteer - Browser control (stdio/marketplace)
- shadcn - Component library (stdio)

## Related Skills

- `project-detection` - Detect project type for appropriate MCP servers
- `environment-setup` - Verify tools and environment variables
- `version-management` - Manage MCP server versions

---

**Plugin**: foundation
**Skill Type**: Configuration Management + Validation + Registry
**Version**: 2.1.0 (Registry support added)
**Auto-invocation**: Yes (via description matching)
