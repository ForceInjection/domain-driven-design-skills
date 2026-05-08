---
name: claude-optimization
description: |
  Maximizing Claude Code capabilities and efficiency.
  Use when helping users discover features, optimize workflows, or improve their Claude Code experience.
---

# Claude Code Optimization Guide

## Feature Discovery Checklist

When working with users, watch for opportunities to suggest:

### Underutilized Power Features

| Feature | Trigger | Benefit |
|---------|---------|---------|
| **Parallel agents** | 3+ independent tasks | 3x faster completion |
| **Background agents** | Long task blocking work | Continue working while it runs |
| **Episodic memory** | "What did we decide about..." | Recall past sessions |
| **MCP servers** | Need external data | Direct API access |
| **Custom hooks** | Repetitive validation | Automatic quality checks |
| **Subagents** | Task needs focus | Isolated context, specialized tools |
| **Skills** | Repeated patterns | Consistent approach |

### Quick Wins to Suggest

1. **Parallel Tool Calls**: "I can run these searches simultaneously"
2. **Agent Delegation**: "Let me spawn a specialized agent for this"
3. **Memory Search**: "Let me check if we've solved this before"
4. **Background Tasks**: "I'll run this in background while we continue"

## Efficiency Patterns

### Pattern 1: Parallel Exploration

```
Instead of:
  Search for X → Wait → Search for Y → Wait → Search for Z

Do:
  Search for X, Y, Z simultaneously → Continue when all complete
```

**When to use**: Independent searches, file reads, or exploratory tasks

### Pattern 2: Agent Specialization

```
Instead of:
  One conversation doing: research + code + review + test

Do:
  Explore agent → does research
  Main context → writes code
  Code-reviewer agent → reviews changes
  Test agent → writes/runs tests
```

**When to use**: Complex tasks with distinct phases

### Pattern 3: Progressive Disclosure

```
Instead of:
  Dump all context upfront

Do:
  Provide essential context first
  Load detailed references when needed
  Use skills for domain knowledge
```

**When to use**: Large codebases, complex domains

### Pattern 4: Background Processing

```
Instead of:
  Run slow task → Wait → Continue

Do:
  Start task in background → Continue other work → Check results later
```

**When to use**: Long builds, extensive tests, large exports

## Model Selection Strategy

| Task Type | Recommended Model | Reasoning |
|-----------|-------------------|-----------|
| Quick file search | Haiku | Speed > depth |
| Code exploration | Haiku/Sonnet | Balance |
| Complex refactoring | Sonnet | Good reasoning |
| Architecture decisions | Opus | Maximum capability |
| Simple edits | Haiku | Cost efficiency |
| Code review | Sonnet | Balanced analysis |

## MCP Server Recommendations

### High-Value Integrations

| Server | Use Case | Setup |
|--------|----------|-------|
| **GitHub** | PR review, issues | `claude mcp add --transport http github https://api.githubcopilot.com/mcp/` |
| **Sentry** | Error debugging | `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp` |
| **PostgreSQL** | Database queries | `claude mcp add --transport stdio postgres -- npx -y @database-mcp` |
| **Filesystem** | Advanced file ops | Built-in or custom |

### When to Suggest MCP

- User mentions needing data from external service
- Repeated manual data fetching
- Integration with team tools
- Debugging production issues

## Hook Automation Opportunities

### Pre-Tool Hooks (Before Claude acts)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "echo 'About to modify: $FILE'" }]
      }
    ]
  }
}
```

**Use cases**:
- Lint before edit
- Backup before overwrite
- Validate paths

### Post-Tool Hooks (After Claude acts)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "npx biome check $FILE --write" }]
      }
    ]
  }
}
```

**Use cases**:
- Auto-format after changes
- Run tests after edits
- Update checksums

## Workflow Optimization Patterns

### Pattern: Task Breakdown with Todos

```
User: "Implement feature X"

Optimized approach:
1. Create todo list with subtasks
2. Mark first task in_progress
3. Complete and mark done
4. Move to next task
5. User has visibility throughout
```

### Pattern: Exploratory Research First

```
User: "Fix the bug in checkout"

Optimized approach:
1. Use Explore agent to understand codebase
2. Search episodic memory for related issues
3. Gather full context before proposing fix
4. Make minimal, targeted changes
```

### Pattern: Review After Implementation

```
User: "Add authentication"

Optimized approach:
1. Implement feature
2. Spawn code-reviewer agent
3. Address review feedback
4. Spawn security-auditor if auth-related
5. Final verification
```

## Context Management

### Keeping Context Focused

- Use subagents for isolated tasks
- Compact context when it grows large
- Save decisions to CLAUDE.md
- Use skills for repeated patterns

### Cross-Session Continuity

1. **Episodic memory**: Search past conversations
2. **CLAUDE.md**: Document project-level decisions
3. **Todo lists**: Track incomplete work
4. **Git commits**: Clear commit messages for context

## Performance Tips

### Reduce Token Usage

- Use glob patterns instead of listing files
- Read specific line ranges, not whole files
- Use grep before read to find relevant sections
- Delegate to haiku agents for simple tasks

### Increase Speed

- Parallel tool calls for independent operations
- Background agents for long tasks
- Cached results from previous sessions
- Specialized agents for focused work

## Quality Assurance Automation

### Suggested Workflow Hooks

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          { "type": "command", "command": "npx biome check $FILE --write" },
          { "type": "command", "command": "npx tsc --noEmit" }
        ]
      }
    ]
  }
}
```

### Suggested Agent Chain

1. **Before coding**: `Plan` agent researches
2. **During coding**: Main context implements
3. **After coding**: `code-reviewer` checks quality
4. **Before commit**: `security-auditor` scans
5. **After commit**: Tests run automatically

## Proactive Suggestions Script

When observing user behavior, suggest:

| Observation | Suggestion |
|-------------|------------|
| Manual file searching | "Use Explore agent or glob patterns" |
| Repeated similar tasks | "Create a custom slash command" |
| Same validation steps | "Set up a hook for automatic validation" |
| External data fetching | "Add an MCP server for direct access" |
| Context getting long | "Delegate to subagent for isolation" |
| Cross-session work | "Search episodic memory for context" |
