---
name: hook-sdk-integration
description: LLM invocation patterns from hooks via SDK. Use when you need background agents, CLI calls, or cost optimization.
allowed-tools: ["Read", "Grep", "Glob"]
---

# Hook SDK Integration

Patterns for invoking LLM calls from hooks using u-llm-sdk/claude-only-sdk.

## IMPORTANT: SDK Detailed Guide

**Load when implementing SDK**:
```
Skill("skillmaker:llm-sdk-guide")
```

This skill covers SDK call pattern **interfaces**.
`llm-sdk-guide` covers SDK **detailed APIs and types**.

## Quick Start

```bash
# Background agent pattern (non-blocking)
(python3 sdk-agent.py "$INPUT" &)
echo '{"status": "started"}'
exit 0
```

## Key Findings (Verified: 2025-12-30)

| Item | Result |
|------|--------|
| SDK calls | Possible from hooks |
| Latency | ~30s (CLI session initialization) |
| Background | Non-blocking execution possible (0.01s return) |
| Cost | Included in subscription (no additional API cost) |

## Architecture

```
Hook (bash) → Background (&) → SDK (Python) → CLI → Subscription usage
     │                                                    │
     └─── Immediate return (0.01s) ───────────────────────┘
```

## Pattern Selection

| Situation | Pattern | Reason |
|-----------|---------|--------|
| Need fast evaluation | `type: "prompt"` | In-session execution, fast |
| Need isolation | Direct CLI call | Separate MCP config possible |
| Complex logic | SDK + Background | Type-safe, non-blocking |
| Cost reduction | Local LLM (ollama) | Free, privacy |

## SDK Configuration (Python)

```python
from u_llm_sdk import LLM, LLMConfig
from llm_types import Provider, ModelTier, AutoApproval

config = LLMConfig(
    provider=Provider.CLAUDE,
    tier=ModelTier.LOW,
    auto_approval=AutoApproval.FULL,
    timeout=60.0,
)

async with LLM(config) as llm:
    result = await llm.run("Your prompt")
```

## Cost Structure

| Method | Cost |
|--------|------|
| `type: "prompt"` | Included in subscription |
| Claude CLI | Included in subscription |
| SDK via CLI | Included in subscription |
| Direct API | Per-token billing |

## References

- **[LLM SDK Detailed Guide](../llm-sdk-guide/SKILL.md)** - SDK API details
- [SDK Integration Patterns](references/sdk-patterns.md)
- [Background Agent Implementation](references/background-agent.md)
- [Cost Optimization](references/cost-optimization.md)
- [Real-World Projects](references/real-world-projects.md)
