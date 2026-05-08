---
name: managing-agent-lifecycles
description: Implements persistent agent lifecycle management with 6 lifespans (ephemeral, turn, context, session, workflow, project). Use when creating agents that survive across turns, managing workflow-scoped execution, or needing automatic cleanup at lifecycle boundaries.
---

# Managing Agent Lifecycles

Persistent agent lifecycle management for Claude Code projects. Creates agents with defined lifespans and automatic disposal.

## When to Use

- Creating agents that persist beyond a single call
- Managing workflow-scoped agents (story execution, feature development)
- Automatic agent cleanup at lifecycle boundaries (Stop, SessionEnd)
- Building systems with multiple cooperating agents

## Quick Start

```typescript
import { AgentRegistry } from 'claude-agent-lifecycle';

const registry = new AgentRegistry();

// Create session-scoped agent (survives until session ends)
const { agent, isNew } = await registry.create({
  lifespan: 'session',
  name: 'my-advisor',
  model: 'haiku',
});

// Resume later in same session
const advisor = await registry.resume('my-advisor');
```

## The 6 Lifespans

| Lifespan | Auto-Disposal | Use Case |
|----------|---------------|----------|
| `ephemeral` | Immediately | Fire-and-forget tasks |
| `turn` | Stop event | Per-response helpers |
| `context` | Context reset | Multi-turn conversations |
| `session` | SessionEnd | Knowledge advisors |
| `workflow` | Manual/complete | Story/feature execution |
| `project` | Manual only | Singleton services |

### Choosing a Lifespan

```
How long should the agent live?
├── Just this one call? → ephemeral
├── Until response completes? → turn
├── Until context resets? → context
├── Until session ends? → session
├── Until work unit completes? → workflow
└── Forever (manual disposal)? → project
```

## Implementation Checklist

When implementing agent lifecycle management:

- [ ] Install package: `bun add claude-agent-lifecycle`
- [ ] Choose appropriate lifespan for each agent type
- [ ] Configure hooks for automatic disposal (Stop, SessionEnd)
- [ ] Use descriptive agent names (e.g., `backend-dev` not `agent1`)
- [ ] Store role and capabilities in metadata
- [ ] Test with debug mode enabled

## Common Patterns

### Pattern 1: Session-Scoped Advisor

For agents persisting throughout a Claude Code session:

```typescript
const { agent, isNew } = await registry.create({
  lifespan: 'session',
  name: 'shadow-advisor',
  model: 'haiku',
  metadata: { role: 'knowledge-retrieval' },
});
```

### Pattern 2: Workflow-Scoped Execution

For agents tied to a unit of work:

```typescript
// Start executor for story
await registry.startWorkflow({
  lifespan: 'workflow',
  workflowId: 'FEAT-001',
  name: 'executor',
});

// Add specialists
await registry.startWorkflow({
  lifespan: 'workflow',
  workflowId: 'FEAT-001',
  name: 'backend-dev',
});

// Complete when done (disposes all workflow agents)
await registry.completeWorkflow('FEAT-001');
```

### Pattern 3: Turn-Scoped Helper

For short-lived per-response agents:

```typescript
const { agent } = await registry.create({
  lifespan: 'turn',
  name: 'code-analyzer',
});
// Automatically disposed when Stop hook fires
```

See `patterns.md` for detailed implementations.

## Hook Integration

Hooks automatically dispose agents at lifecycle boundaries.

### hooks/hooks.json

```json
{
  "Stop": [{
    "hooks": [{
      "type": "command",
      "command": "bun \"${CLAUDE_PLUGIN_ROOT}/hooks/lifecycle-manager.ts\""
    }]
  }],
  "SessionEnd": [{
    "hooks": [{
      "type": "command",
      "command": "bun \"${CLAUDE_PLUGIN_ROOT}/hooks/lifecycle-manager.ts\""
    }]
  }]
}
```

### hooks/lifecycle-manager.ts

```typescript
import { AgentRegistry } from 'claude-agent-lifecycle';
import { getHookEvent } from 'claude-hooks-sdk';

const event = getHookEvent();
const registry = new AgentRegistry();

if (event.type === 'Stop') {
  await registry.disposeByLifespan('turn');
}

if (event.type === 'SessionEnd') {
  await registry.disposeByScope(event.session.sessionId);
}
```

## Storage Structure

```
.agent/agents/
├── session/{session-id}/{agent-name}.json
├── workflow/{workflow-id}/{agent-name}.json
└── project/{agent-name}.json
```

## Debug Mode

Enable for troubleshooting:

```bash
AGENT_LIFECYCLE_DEBUG=true claude
```

Output:
```
[agent-lifecycle] Created: shadow-advisor (session)
[agent-lifecycle] Stop: Disposed 1 turn-scoped agents
```

## API Summary

| Method | Purpose |
|--------|---------|
| `create(config)` | Create or resume agent |
| `resume(name)` | Resume by name |
| `dispose(id)` | Dispose specific agent |
| `startWorkflow(config)` | Start workflow agent |
| `completeWorkflow(id)` | Complete and dispose workflow |

See `api-reference.md` for complete API documentation.

## Installation

```bash
# As plugin (recommended)
/plugin marketplace add hgeldenhuys/claude-agent-lifecycle
/plugin install claude-agent-lifecycle

# As package
bun add claude-agent-lifecycle
```

## Related Files

- `api-reference.md` - Complete API documentation
- `patterns.md` - Detailed pattern implementations
- `examples.md` - Real-world usage examples
