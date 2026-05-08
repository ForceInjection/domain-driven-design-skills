---
name: toolscript
description: Discover and execute MCP tools via gateway. Use when user asks to "call tool", "list tools", or before performing tasks that might have specialized MCP capabilities.
---

# Toolscript Skill

Discover and execute MCP tools through the toolscript gateway.

**Use proactively:** Before operations, search for specialized MCP tools.

## Quick Start

```bash
# 1. Search for tools and get TypeScript code
toolscript search "what you need" --output types

# 2. Execute - single line
toolscript exec 'import {tools} from "toolscript"; console.log(await tools.server.toolName({param: "value"}))'

# 3. Execute - multi-line (use Write tool for /tmp/<filename>.ts)
toolscript exec -f /tmp/<filename>.ts
```

## Toolscript Format

```typescript
import { tools } from "toolscript";
const result = await tools.serverName.toolName({param: "value"});
console.log(result)
```

## Alternative Workflows

- **Direct access:** Use `toolscript get-types --filter <tool-name>,<2nd-tool-name>` if you know the tools
- **Browse discovery:** Use `toolscript list-servers` and `toolscript list-tools <server>`

## References

- `references/commands.md` - All commands and options
- `references/examples.md` - Working examples and workflows
- `references/configuration.md` - Gateway and server setup
- `references/troubleshooting.md` - Diagnostics and fixes
