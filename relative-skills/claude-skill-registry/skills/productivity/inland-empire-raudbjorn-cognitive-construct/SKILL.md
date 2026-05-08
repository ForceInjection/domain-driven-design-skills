---
name: inland-empire
description: Unified memory substrate. Store facts, patterns, and context. Query with remember, consult, and stats commands.
license: MIT
metadata:
  version: 1.0.0
  dependencies:
    required:
      - memory_libsql
      - memory_graph
    optional:
      - openmemory
  env_vars:
    required: []
    optional:
      - LIBSQL_URL
      - LIBSQL_AUTH_TOKEN
      - MEM0_API_KEY
      - POSTGRES_URL
      - INLAND_EMPIRE_STATE_DIR
      - INLAND_EMPIRE_EVENT_HOME
membrane:
  version: 1
  absorbs:
    - event_type: action.completed
      priority: normal
    - event_type: rhetoric.pattern.detected
      priority: normal
    - event_type: feedback.useful
      priority: high
    - event_type: feedback.not_useful
      priority: high
  emits:
    - event_type: memory.fact.stored
    - event_type: memory.pattern.stored
    - event_type: memory.context.stored
    - event_type: memory.consulted
    - event_type: memory.evicted
  rate_limits:
    max_absorb_per_minute: 100
    max_emit_per_minute: 50
---

# Inland Empire

> "This is your gut feeling. The raw data of the soul. When logic fails, consult the Empire."

## Capabilities

The **Inland Empire** unifies three memory backends but only exposes sanitized aliases
(`fact_memory`, `pattern_memory`, `context_memory`). Internals (MCP, mem0, JSONL) are hidden.

| Alias | Memory Type | Backend | Storage | Notes |
|-------|-------------|---------|---------|-------|
| `fact_memory` | `fact` | mcp-memory-libsql | Graph entities/relations | Defaults to local SQLite fallback |
| `pattern_memory` | `pattern` | mem0 | Hosted API (MEM0_API_KEY) or self-hosted Postgres (POSTGRES_URL) |
| `context_memory` | `context` | JSONL | Local file (session_memory.jsonl) | Always available |

### Backend detection
- **mem0 hosted**: `MEM0_API_KEY` present
- **mem0 self-hosted**: `POSTGRES_URL` present
- **mem0 disabled**: neither credential; pattern memory gracefully skipped
- `LIBSQL_URL` optional; if missing, a local SQLite file powers fact memory
- `INLAND_EMPIRE_STATE_DIR` overrides the storage directory (tests, sandboxes, multi-project)

## Commands

### remember
Store a memory across configured backends.

```bash
python3 inland-empire.py remember "<text>" [--type fact|pattern|context]
```

**Examples:**
```bash
python3 inland-empire.py remember "User prefers verbose error messages"
python3 inland-empire.py remember "The auth flow has race conditions" --type pattern
```

### consult
Query stored memories with optional depth and type filters. Results contain backend aliases,
partial-result indicators, and normalized metadata.

```bash
python3 inland-empire.py consult "<query>" [--depth shallow|deep] [--type fact|pattern|context]
```

**Example:**
```bash
python3 inland-empire.py consult "user preferences" --depth deep --type pattern
```

**Response shape**
```json
{
  "status": "ok",
  "command": "consult",
  "result": {
    "query": "user preferences",
    "depth": "deep",
    "results": [
      {
        "origin": "pattern",
        "summary": "User prefers verbose error messages",
        "score": 0.812,
        "observed_at": null,
        "backend": "pattern_memory",
        "partial": false,
        "metadata": {
          "id": "mem0_123",
          "user_id": "agent_subconscious",
          "created_at": "2024-01-15T10:30:00Z",
          "updated_at": "2024-01-15T10:30:00Z",
          "mode": "hosted"
        }
      }
    ],
    "metadata": {
      "requested_backends": ["fact_memory", "pattern_memory"],
      "completed_backends": ["pattern_memory"],
      "timed_out_backends": ["fact_memory"],
      "partial": true
    }
  }
}
```

### stats
Display backend health, detection mode, and basic counts (context entries).

```bash
python3 inland-empire.py stats
```

## When to Use

- Store hunches, preferences, and soft context that doesn't belong in files
- Recall project context after breaks
- Detect patterns across sessions
- Build institutional memory for recurring issues
