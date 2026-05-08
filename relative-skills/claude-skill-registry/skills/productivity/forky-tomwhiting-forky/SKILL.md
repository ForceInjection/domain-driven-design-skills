---
name: forky
description: Fork Claude sessions to handle side tasks in parallel. Use when the user wants to spawn a parallel Claude session, delegate a task to a background agent, monitor forked sessions, or when they mention "forky", "fork", "spawn", or "parallel task".
---

# Forky - Parallel Claude Session Manager

Forky lets you spawn parallel Claude sessions to handle side tasks without interrupting your main workflow.

## CRITICAL: Never Wait for Forks

**Forks are fire-and-forget.** After spawning, IMMEDIATELY continue with the next task. NEVER:
- Say "I'll wait for the fork to complete"
- Poll the fork status
- Defer work pending fork completion

Forks notify you when done. Just spawn and move on.

## Spawning a Fork

**ALWAYS run forky spawn as a background shell operation.** This ensures you don't block waiting for the spawn to complete.

```bash
# Use run_in_background=true with the Bash tool
~/bin/forky spawn "your task description here"
```

The binary is at `~/bin/forky` (NOT ~/.forky/bin/).

## Model Selection

**Always use Opus (the default).** Do NOT use `-m haiku` or `-m sonnet` without asking the user first.

## When to Fork

**Good:**
- Code review while continuing development
- Research while implementing
- Test generation for code you just wrote
- Documentation tasks
- Any independent background work

**Avoid:**
- Tasks requiring immediate user input
- Modifying same files (use `--worktree` if needed)
- Very short tasks (overhead > benefit)

## Monitoring

```bash
~/bin/forky serve              # Start observability UI
~/bin/forky list forks         # List all forks
~/bin/forky messages <id>      # View fork messages
```

## For Forked Agents

If you ARE a fork (check your callback instruction), call done when finished:

```bash
~/bin/forky done <your-fork-id> "summary of what was accomplished"
```
