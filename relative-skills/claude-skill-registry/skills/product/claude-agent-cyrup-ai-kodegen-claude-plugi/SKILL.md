---
name: claude-agent
description: >
  Spawn and manage Claude sub-agents for parallel or delegated tasks.
  WHEN: User needs parallel operations, multi-step autonomous research, or wants to delegate complex tasks to sub-agents. Use when task can be parallelized or requires independent exploration.
  WHEN NOT: Simple single-step operations, sequential dependencies, specific file reads (use fs_read_file), writing code directly (do it yourself).
version: 0.1.0
---

# Claude Agent - Sub-Agent Delegation

## Core Concept

`mcp__plugin_kg_kodegen__claude_agent` spawns independent Claude sub-sessions that can execute tasks autonomously. Each agent has its own conversation context, can use tools, and returns a final report. Perfect for parallel research, independent code analysis, or complex multi-step delegations.

## Five Actions

### SPAWN (Default)
Create a new agent session with initial prompt.

### SEND
Send additional prompt to existing agent.

### READ
Read current output from agent.

### LIST
List all active agent sessions.

### KILL
Terminate agent session and cleanup.

## Key Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `action` | string | No | SPAWN (default), SEND, READ, LIST, KILL |
| `agent` | number | No | Agent instance (0, 1, 2...), default: 0 |
| `prompt` | string | SPAWN/SEND | Task for the agent to perform |
| `system_prompt` | string | No | Custom system prompt for agent behavior |
| `await_completion_ms` | number | No | Timeout in ms (default: 300000 = 5 min) |
| `max_turns` | number | No | Max conversation turns (default: 10) |
| `allowed_tools` | array | No | Tools agent CAN use (allowlist) |
| `disallowed_tools` | array | No | Tools agent CANNOT use (blocklist) |
| `cwd` | string | No | Working directory for agent |
| `add_dirs` | array | No | Additional context directories |

## Usage Examples

### Spawn Research Agent
```json
{
  "action": "SPAWN",
  "prompt": "Research all error handling patterns in this codebase. Return a summary of patterns found with file locations.",
  "max_turns": 15
}
```

### Parallel Agents for Different Tasks
```json
// Agent 0: Research
{
  "agent": 0,
  "prompt": "Find all API endpoints and document their signatures"
}

// Agent 1: Analysis (concurrent)
{
  "agent": 1,
  "prompt": "Analyze test coverage and identify untested code paths"
}
```

### Restricted Agent (Read-Only)
```json
{
  "prompt": "Review this codebase for security vulnerabilities",
  "allowed_tools": ["fs_read_file", "fs_search", "fs_list_directory"],
  "disallowed_tools": ["terminal", "fs_write_file", "fs_delete_file"]
}
```

### Background Agent with Timeout
```json
{
  "prompt": "Deep dive into the authentication system architecture",
  "await_completion_ms": 60000,
  "max_turns": 20
}
```

### Check Agent Progress
```json
{"action": "READ", "agent": 0}
```

### List All Agents
```json
{"action": "LIST"}
```

### Terminate Agent
```json
{"action": "KILL", "agent": 0}
```

## When to Use What

| Scenario | Use Agent? | Why |
|----------|-----------|-----|
| Search for keyword in codebase | Yes | Agent explores autonomously |
| Read specific known file | No | Use fs_read_file directly |
| Parallel research tasks | Yes | Spawn multiple agents |
| Write code | No | Do it yourself |
| Complex multi-step analysis | Yes | Agent handles autonomously |
| Simple calculation | No | Overkill |

## Best Practices

1. **Be specific in prompts** - Tell agent exactly what to return
2. **Specify output format** - Request structured results
3. **Use tool restrictions** - Limit agent capabilities when appropriate
4. **Launch concurrently** - Multiple agents in single message for parallelism
5. **Trust agent output** - Results are generally reliable

## Remember

- Agents are **stateless** - each invocation is independent
- Agent results are **not visible to user** - you must summarize
- Prompts should be **highly detailed** - agent works autonomously
- **Launch multiple agents concurrently** for parallel work
- Specify if agent should **research only** vs write code
