---
name: memory-graph
description: Persistent memory graph skill using the MCP Memory server
audience: agents
visibility: project
---

# Memory Graph Skill

This skill teaches you how to create, update, search, and prune a persistent knowledge graph using the Model Context Protocol (MCP) Memory server.

When connected, Memory tools appear as MCP tools named like `mcp__memory__<tool>`. Use these tools proactively whenever you identify durable facts, entities, or relationships you want to persist across sessions.

See `operations.md` for exact tool I/O shapes and `playbooks.md` for common patterns and routing rules.

## When To Use
- New durable facts emerge (requirements, decisions, owners, IDs, endpoints)
- You meet a new entity (person, team, service, repository, dataset)
- You discover relationships ("Service A depends on Service B", "Alice owns Repo X")
- You want to reference prior sessions or quickly search memory
- You need to prune or correct stale memory

## Golden Rules
- Prefer small, well-typed entities over long notes
- Record relationships in active voice: `relationType` describes how `from` relates to `to`
- Add observations as atomic strings; include dates or sources when helpful
- Before creating, search existing nodes to avoid duplicates
- When correcting, prefer `delete_observations` then `add_observations` over overwriting

## Auto Triggers
- UserPromptSubmit adds a Memory Graph activation block when durable facts or explicit memory intents are detected. Disable with `LAZYDEV_DISABLE_MEMORY_SKILL=1`.
- PostToolUse emits lightweight suggestions when tool results include durable facts. Disable with `LAZYDEV_DISABLE_MEMORY_SUGGEST=1`.

## Tooling Summary (server "memory")
- `create_entities`, `add_observations`, `create_relations`
- `delete_entities`, `delete_observations`, `delete_relations`
- `read_graph`, `search_nodes`, `open_nodes`

Always call tools with the fully-qualified MCP name, for example: `mcp__memory__create_entities`.

## Minimal Flow
1) `mcp__memory__search_nodes` for likely duplicates
2) `mcp__memory__create_entities` as needed
3) `mcp__memory__add_observations` with concise facts
4) `mcp__memory__create_relations` to wire the graph
5) Optional: `mcp__memory__open_nodes` to verify saved nodes

## Error Handling
- If create fails due to existing name, switch to `add_observations`
- If `add_observations` fails (unknown entity), retry with `create_entities`
- All delete tools are safe on missing targets (no-op)

## Examples
See `examples.md` for end-to-end examples covering projects, APIs, and people.
