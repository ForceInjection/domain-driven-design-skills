---
name: mcp-gateway-patterns
description: MCP Gateway design patterns for Agent Gateway, Subprocess, and Daemon isolation. Use when designing MCP integrations.
allowed-tools: ["Read", "Write", "Bash", "Grep", "Glob"]
---

# MCP Gateway Patterns

Heavy MCP servers consume context tokens. Three isolation strategies exist.

## Critical Knowledge

### MCP Registration Methods

| Method | File Location | Correct? |
|--------|---------------|----------|
| `claude mcp add --scope user` | `~/.claude.json` | ✅ |
| `claude mcp add --scope project` | `.mcp.json` | ✅ |
| Manual `~/.claude/mcp_servers.json` | Legacy file | ❌ NOT READ |

**Correct Registration:**
```bash
claude mcp add --transport stdio --scope user <name> -- <command> [args...]
```

---

### Agent MCP Access Rules

| `tools:` Setting | MCP Access | Example |
|------------------|------------|---------|
| Empty/Omitted | ✅ All tools | `tools:` |
| Explicit list (no MCP) | ❌ NO access | `tools: ["Read", "Write"]` |
| Explicit list (with MCP) | ✅ Listed only | `tools: ["Read", "mcp__serena__*"]` |

---

### MCP Tool Naming Convention

| Registration Type | Tool Name Pattern |
|-------------------|-------------------|
| Plugin MCP | `mcp__plugin_<server>_<server>__<tool>` |
| User MCP | `mcp__<server>__<tool>` |

---

## Strategy Selection (Empirically Verified)

> **📌 Default Recommendation: Daemon (SSE)**
>
> Daemon pattern provides the best balance: **fast startup (1-2s)** + **zero token overhead** + **state sharing**.
> Only use alternatives when specific constraints apply.

| Criteria | Daemon (SSE) ⭐ | Agent Gateway | Subprocess |
|----------|----------------|---------------|------------|
| Startup latency | **1-2s** | ~1s | 30-60s |
| Token overhead | **Zero** | ~350/tool | Zero |
| State sharing | ✅ Yes | ✅ Yes | ❌ No |
| Setup effort | Medium | Low | Low |

### Decision Guide

```
Start with Daemon (default)
    │
    ├── Can't run background process? → Agent Gateway
    │       (serverless, restricted env)
    │
    ├── Air-gapped / offline only? → Subprocess
    │       (no network, rare use)
    │
    └── Simple project, token OK? → Agent Gateway
            (quick setup preferred)
```

### When to Use Alternatives

| Constraint | Alternative |
|------------|-------------|
| Cannot run background daemon | Agent Gateway |
| Serverless environment (Lambda, Cloud Functions) | Agent Gateway |
| Offline/air-gapped environment | Subprocess |
| MCP used < 2 times per session | Subprocess |
| Quick prototype, token budget OK | Agent Gateway |

### Token Savings by MCP (Measured)

| MCP | Tools | Overhead | Subprocess Benefit |
|-----|-------|----------|-------------------|
| Serena | 29 | ~10,150 | ✅ High |
| Playwright | 25 | ~6,250 | ✅ High |
| Greptile | 12 | ~3,600 | ⚠️ Medium |
| Context7 | 2 | ~400 | ❌ Not worth it |

**Rule**: If `tools × 350 > 5,000`, consider subprocess isolation.

---

## 2-Layer Protocol

**Layer 1 - Intent** (common across MCPs):
| Intent | Effect | Use |
|--------|--------|-----|
| QUERY | READ_ONLY | Search, lookup |
| ANALYZE | READ_ONLY | Interpret, impact |
| MODIFY | MUTATING | Change files |
| EXECUTE | EXTERNAL_EXEC | External calls |

**Layer 2 - Action**: MCP-specific tool names

---

## Gateway Template

```yaml
---
name: {mcp}-gateway
tools:  # Empty = all tools including MCP
model: sonnet
---
```

Responsibilities:
1. Context activation
2. Pre-validation for MODIFY
3. Atomic JSON responses

---

## Common Issues

### "MCP tools not visible"
- **Cause:** Session not restarted after `claude mcp add`
- **Fix:** Restart Claude Code

### "Tool not found in subagent"
- **Cause:** Agent has explicit `tools:` list without MCP
- **Fix:** Empty `tools:` or add MCP tools to list

### "Wrong tool name format"
- **Cause:** Mixing plugin (`mcp__plugin_x_x__`) and user (`mcp__x__`) formats
- **Fix:** Check `claude mcp list` for actual server name prefix

---

## Daemon Quick Start

```bash
# 1. Start daemon (one time)
uvx --from git+https://github.com/oraios/serena \
  serena start-mcp-server --transport sse --port 8765 --project-from-cwd &

# 2. Register with Claude Code
claude mcp add --transport sse --scope user serena-daemon http://127.0.0.1:8765

# 3. Restart Claude Code, then use normally
```

---

## References

### Core Patterns
- [Agent Gateway Template](references/agent-gateway-template.md) - Standard inherited MCP
- [Subprocess Gateway](references/subprocess-gateway.md) - Per-call isolation
- [**Daemon Shared Server**](references/daemon-shared-server.md) - Persistent HTTP/SSE server

### Research & Analysis
- [Subprocess Research Report](references/subprocess-research-report.md) - Empirical findings
- [**Approach Comparison Appendix**](references/approach-comparison-appendix.md) - All approaches with pros/cons

### Setup & Validation
- [Protocol Schema](references/protocol-schema.md)
- [Setup Automation](references/setup-automation.md)
- [Validation Patterns](references/validation-patterns.md)
