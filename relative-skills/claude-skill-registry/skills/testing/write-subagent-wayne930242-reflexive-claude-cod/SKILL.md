---
name: write-subagent
description: Create Claude Code subagent configurations for .claude/agents/. Defines specialized agents with isolated contexts. Use when creating dedicated agents for code review, testing, or domain-specific tasks.
---

# Subagent Creator

Create specialized subagents that run in isolated contexts via the Task tool.

## Core Principles

1. **Isolated Context** - Each subagent has its own context window
2. **Specialized Role** - One clear responsibility per subagent
3. **Minimal Tools** - Grant only necessary tool access
4. **Clear Trigger** - Description must indicate when to use

## Subagent Structure

```
.claude/agents/
├── code-reviewer.md      # Project-level
├── test-runner.md
└── domain-expert.md
```

User-level agents go in `~/.claude/agents/`.

## File Format

```yaml
---
name: agent-name
description: What this agent does. Use proactively when [triggers].
tools: Read, Grep, Glob, Bash
model: sonnet
skills: skill1, skill2
permissionMode: default
---

System prompt for the agent.

## Role
[Clear description of the agent's role]

## Process
[Steps the agent should follow]

## Output Format
[Expected output structure]
```

## Configuration Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Lowercase with hyphens: `code-reviewer` |
| `description` | Yes | Include "Use proactively when..." for auto-invoke |
| `tools` | No | CSV list; omit to inherit all tools |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit` |
| `skills` | No | Auto-load skills when invoked |
| `permissionMode` | No | `default`, `acceptEdits`, `bypassPermissions`, `plan` |

## Model Selection

| Model | Use Case |
|-------|----------|
| `haiku` | Fast exploration, simple tasks |
| `sonnet` | Balanced capability (default) |
| `opus` | Complex reasoning, architecture |
| `inherit` | Use main conversation's model |

## Tool Recommendations

| Subagent Type | Recommended Tools |
|---------------|-------------------|
| Code reviewer | `Read, Grep, Glob, Bash` |
| Test runner | `Read, Bash, Grep` |
| Explorer | `Read, Glob, Grep, Bash` |
| Writer | `Read, Edit, Write, Bash` |

## Trigger Patterns

For **automatic invocation**, include in description:
- "Use proactively when..."
- "Use immediately after..."
- "MUST BE USED when..."

For **manual invocation**, omit proactive triggers.

## Validation Checklist

- [ ] Name is lowercase with hyphens
- [ ] Description has clear trigger
- [ ] Tools are minimal and appropriate
- [ ] No overlapping responsibility with other agents
- [ ] System prompt is focused and actionable

## References

- [examples.md](references/examples.md) - Subagent templates
- [tools.md](references/tools.md) - Available tools reference
