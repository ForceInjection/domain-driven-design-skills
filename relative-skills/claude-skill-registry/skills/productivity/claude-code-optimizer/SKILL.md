---
name: claude-code-optimizer
description: "Claude Code productivity patterns including EPCC workflow, context management, and extended thinking triggers. Use when starting sessions or managing context."
---

# Claude Code Optimizer

Maximize productivity through proven workflow patterns.

## Critical Rule

**Never execute git commands.** Output all git commands for manual execution.

## EPCC Pattern

The core workflow for every session: **Explore → Plan → Code → Commit**

### 1. Explore (No code yet)
```
Read CLAUDE.md and relevant source files.
Summarize the current state. Do not write code yet.
```

### 2. Plan (Think first)
```
Think hard about implementing [feature].
Consider edge cases and affected files.
Output the plan. Do not implement yet.
```

### 3. Code (Execute)
```
Implement step 1 of the plan.
Run tests after changes.
```

### 4. Commit (Output only)
```
Generate git commands for manual execution.
Do not run git commands.
```

## Extended Thinking Triggers

| Phrase | Use For |
|--------|---------|
| "think hard" | Architecture decisions |
| "ultrathink" | Complex algorithms, security |
| "think step by step" | Multi-step procedures |
| "analyze thoroughly" | Refactoring, debugging |

## Context Management

### Monitor
```
/context
```

### Document & Clear
Before clearing:
```
Dump progress to progress-[project]-[date].md:
- What was accomplished
- Current state
- Next steps
- Git commands to run
```

After clearing:
```
/clear
Read CLAUDE.md and progress file. Continue with [next task].
```

### When to Clear
- After completing major task
- When switching projects
- Context >50% full
- Quality degradation noticed

## Troubleshooting

**Context overflow:** `/clear`, then read only essential files

**Stuck in loop:** "Stop. Summarize what's not working. Try different approach."

**Quality issues:** "Pause. Re-read requirements. Think hard. Start fresh."

See `references/claude-md-template.md` for CLAUDE.md template.
