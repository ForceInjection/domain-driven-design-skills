---
name: mcp-memory-server-surgery
description: "Use when modifying MCP servers that touch repo memory (especially docs-memory). Includes protocol guardrails, validation ladder, and how to store new capabilities as Skills so future agents don’t re-learn painful details. Triggers: docs-memory, mcp-server.js, tools/list, tools/call, stdio, headerless, JSON-RPC, protocol." 
---

# Skill: MCP Memory Server Surgery (Safe Modification)

## Scope

This Skill covers changes to MCP servers that expose or mutate the repo memory system, especially:
- `tools/mcp/docs-memory/mcp-server.js`
- Stdio framing/headerless parsing
- Tool registry shape (`tools/list`, `tools/call`) and compatibility

It does **not** cover:
- Adding unrelated business logic
- Rewriting MCP protocol handling from scratch

## Inputs

- What new capability you want (tool name(s), arguments, return shape)
- Backward-compat constraints (do we need to keep old tool names?)
- Validation targets (check scripts, focused tests)

## Procedure

### 1) Retrieve prior art (mandatory)

Use the memory retrieval ritual:

- Skills:
  - `mcp_docs-memory_docs_memory_recommendSkills({ topic: "mcp docs-memory server change" })`
  - `mcp_docs-memory_docs_memory_searchSkills({ query: "docs-memory" })`
- Sessions:
  - `mcp_docs-memory_docs_memory_searchSessions({ query: "docs-memory mcp-server", maxResults: 10 })`

If MCP tools are unavailable, fall back:
- `node tools/dev/md-scan.js --dir docs/agi --search "docs-memory" "mcp-server" --json`
- `node tools/dev/md-scan.js --dir docs/sessions --search "docs-memory" "check-stdio" --json`

### 2) Define the tool contract first

Before coding, write down:
- Tool name: `docs_memory_<verbNoun>`
- JSON input schema (fields + defaults)
- JSON output schema
- Error modes (missing files, invalid args)

Rule: prefer **small composable tools** over one mega-tool.

### 3) Implement with protocol guardrails

- Keep `tools/list` stable and additive.
- Preserve headerless stdio support (agents/tools may rely on it).
- Avoid introducing long-running server behavior in checks/tests.

### 4) Validation ladder (non-negotiable)

Run the smallest checks that prove protocol + tool surface:

1. MCP server health (when relevant):
   - `node tools/dev/mcp-check.js --quick --json`
2. docs-memory stdio compatibility:
   - `node tools/mcp/docs-memory/check-stdio.js`
3. Focused Jest (add a test if missing):
   - `npm run test:by-path tests/tools/__tests__/docs-memory-mcp.test.js`

Stop if any step fails; fix before proceeding.

### 5) Write back into memory (make it cheaper next time)

When the change is done:
- Add/extend a Skill if you introduced a new recurring workflow.
- Record evidence in the active session `WORKING_NOTES.md`.

## Validation (success criteria)

- `node tools/mcp/docs-memory/check-stdio.js` passes.
- A focused Jest test for the new tool(s) passes.
- `docs/agi/AGENT_MCP_ACCESS_GUIDE.md` remains accurate for tool names.

## References

- MCP access + naming: `docs/agi/AGENT_MCP_ACCESS_GUIDE.md`
- Skills registry: `docs/agi/SKILLS.md`
- docs-memory server: `tools/mcp/docs-memory/mcp-server.js`
- stdio check: `tools/mcp/docs-memory/check-stdio.js`
