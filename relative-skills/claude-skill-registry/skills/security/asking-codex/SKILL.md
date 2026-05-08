---
name: asking-codex
description: Code review, security audits, bug detection, alternative implementations, second opinions via OpenAI Codex. Use when user asks for code review, security analysis, implementation advice, bug detection, code patterns, or wants a second opinion on code. Supports uncommitted changes review. Do not use for architecture design or web searches.
allowed-tools: Task
---

# Codex Consultation

Spawn the **codex-assistant** agent for code-focused questions.

## Foreground (blocking)

```
Task(subagent_type="codex-assistant", prompt="[mode]: <question>")
```

## Background (for context efficiency)

```
Task(subagent_type="codex-assistant", prompt="[mode]: <question>", run_in_background=true)
```

Use `TaskOutput(task_id="<id>")` to retrieve results.

**Modes:** exec (default), review, plan, implement (add --auto for file changes)

The agent uses Codex MCP tools (`mcp__codex__spawn_agent`, `mcp__codex__spawn_agents_parallel`) directly.
