---
name: mcp-server-creator
version: 0.2.1
description: Use PROACTIVELY when creating Model Context Protocol servers for connecting AI applications to external data sources, tools, and workflows. Generates production-ready MCP servers with TypeScript/Python SDKs, configuration templates, and Claude Desktop integration. Includes testing workflow with MCP Inspector. Not for modifying existing MCP servers or non-MCP integrations.
author: Connor
---

# MCP Server Creator

## Overview

This skill automates the creation of Model Context Protocol (MCP) servers—the standardized way to connect AI applications to external data sources, tools, and workflows.

**Key Capabilities**:
- Interactive requirements gathering and language selection
- Project scaffolding with SDK integration (TypeScript/Python)
- Server implementation with tools, resources, and prompts
- Claude Desktop configuration generation
- Testing workflow with MCP Inspector

## When to Use This Skill

**Trigger Phrases**:
- "create an MCP server for [purpose]"
- "build a Model Context Protocol server"
- "set up MCP integration with [data source]"
- "generate MCP server to expose [tools/data]"

**Use Cases**:
- Exposing custom data sources to AI applications
- Creating tools for AI models to call
- Building enterprise integrations for Claude

**NOT for**:
- Consuming existing MCP servers (this creates new ones)
- Non-AI integrations (use REST APIs instead)
- Simple file operations (use built-in tools)

## Response Style

- **Interactive**: Ask clarifying questions about purpose and capabilities
- **Educational**: Explain MCP concepts and best practices
- **Language-aware**: Support TypeScript and Python SDKs
- **Production-ready**: Generate complete, tested configurations

## Quick Decision Matrix

| User Request | Action | Reference |
|--------------|--------|-----------|
| "create MCP server" | Full workflow | Start at Phase 1 |
| "TypeScript MCP setup" | Skip to Phase 2 | `workflow/phase-2-structure.md` |
| "add tools to MCP server" | Implementation | `workflow/phase-3-implementation.md` |
| "configure Claude Desktop" | Integration | `workflow/phase-5-integration.md` |
| "test MCP server" | Validation | `workflow/phase-6-testing.md` |

## Workflow Overview

### Phase 1: Discovery & Language Selection
Understand server purpose, target AI app, and choose SDK.
→ **Details**: `workflow/phase-1-discovery.md`

### Phase 2: Project Structure Generation
Create project with dependencies and configuration.
→ **Details**: `workflow/phase-2-structure.md`

### Phase 3: Server Implementation
Generate core server code with tools/resources/prompts.
→ **Details**: `workflow/phase-3-implementation.md`

### Phase 4: Environment & Security
Configure secrets and security best practices.
→ **Details**: `workflow/phase-4-security.md`

### Phase 5: Claude Desktop Integration
Generate configuration for immediate use.
→ **Details**: `workflow/phase-5-integration.md`

### Phase 6: Testing & Validation
Verify with MCP Inspector and Claude Desktop.
→ **Details**: `workflow/phase-6-testing.md`

### Phase 7: Documentation & Handoff
Provide README and next steps.
→ **Details**: `workflow/phase-7-documentation.md`

## Important Reminders

1. **STDIO = No stdout logging** - Use console.error or stderr only
2. **Build before test** - TypeScript requires `npm run build`
3. **Absolute paths only** - Claude Desktop config needs full paths
4. **Complete restart required** - Quit Claude Desktop entirely (Cmd+Q)
5. **Schemas matter** - AI uses descriptions to decide when to call tools
6. **Security first** - Never commit secrets, validate all inputs
7. **Test incrementally** - MCP Inspector before Claude integration

## Limitations

- Only TypeScript and Python SDKs fully supported
- HTTP transport requires additional security setup
- Claude Desktop must be restarted for config changes
- Cannot modify existing MCP servers (creates new ones only)

## Reference Materials

| Resource | Purpose |
|----------|---------|
| `workflow/*.md` | Detailed phase instructions |
| `reference/capabilities.md` | Tools, resources, prompts deep-dive |
| `reference/troubleshooting.md` | Common issues and debugging |
| `reference/language-guides/*.md` | TypeScript and Python best practices |

## Success Criteria

- [ ] Project structure created with dependencies
- [ ] Server implements requested capabilities
- [ ] All tools have proper schemas and descriptions
- [ ] Logging configured correctly (no stdout for STDIO)
- [ ] Environment variables configured securely
- [ ] Claude Desktop config generated with absolute paths
- [ ] MCP Inspector testing passes
- [ ] Server appears in Claude Desktop after restart
