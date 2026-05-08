---
name: spawning-agents-on-the-command-line
description: Use when subagents need to delegate work but can't use Task tool, or when needing to test skills in isolated context - spawns Claude instances via CLI backgrounding with JSON responses
---

# Spawning Agents via CLI

## Overview

**Subagents don't have access to the Task tool.** When you need to delegate work as a subagent, spawn Claude instances via CLI backgrounding:

```bash
cat [prompt-file] | claude -p --output-format json
```

**Core principle:** Spawn fresh Claude instances with clean context for independent work, get structured JSON responses.

## When to Use

**Use when:**
- You're a subagent and need to delegate work (can't use Task tool)
- Context budget is tight and delegation would be more efficient
- You need parallel analysis of independent items
- Task benefits from fresh context without conversation history

**Don't use when:**
- You're the main Claude instance (use Task tool instead)
- You can efficiently do the work yourself with available tools
- The task requires shared conversation context that's hard to serialize
- **You were just spawned to do a specific task** - do the work, don't spawn another level

**Recursion guard:** If you were spawned via this technique, do the work you were spawned for. Don't spawn yet another agent unless the task genuinely requires parallel delegation.

## Core Pattern

**Before (baseline failure):**
```
Subagent receives large analysis task
→ Tries to do everything itself
→ Burns context budget on work that could be delegated
→ May hit limits or inefficiency
```

**After (with spawning):**
```
Subagent receives large analysis task
→ Writes focused prompt to file
→ Backgrounds: cat prompt.txt | claude -p --output-format json
→ Polls BashOutput until complete
→ Parses JSON response and continues work
```

## Quick Reference

| Step | Command | Notes |
|------|---------|-------|
| 1. Write prompt | `Write` tool | Clear, focused task description |
| 2. Background spawn | `cat prompt.txt \| claude -p --output-format json` | Use `run_in_background: true` |
| 3. Poll output | `BashOutput` on bash_id | System reminder when ready |
| 4. Parse response | Extract from `stdout` | JSON with `result` field |

## Implementation

### Step 1: Write Focused Prompt

```markdown
**Role:** You are analyzing TypeScript error patterns.

**Task:**
Search /path/to/code for all files with TypeScript errors and categorize by error type.

**Deliver:**
A JSON object with error categories and file counts.
```

**Context passing:**
- Use `--add-dir /path/to/files` if spawned agent needs file access
- Use `--tools "Read,Grep,Glob"` to limit available tools if needed
- Leave `--system-prompt` alone - let spawned agent use normal prompts

### Step 2: Background the Spawn

```bash
cat task-prompt.txt | claude -p --output-format json
```

Use `run_in_background: true` in Bash tool. Capture the bash_id.

### Step 3: Poll for Completion

**System reminders notify you when output available:**

```
<system-reminder>
Background Bash abc123 (...) Has new output available.
</system-reminder>
```

Poll with `BashOutput` tool:

```typescript
BashOutput({ bash_id: "abc123" })
// Returns: { status: "completed", exit_code: 0, stdout: "{...}" }
```

**Polling strategy:**
- Wait 3-5 seconds between polls (use `sleep` command)
- System reminder appears when output ready
- Process ends when work complete, not at timeout

### Step 4: Parse JSON Response

```json
{
  "type": "result",
  "subtype": "success",
  "is_error": false,
  "result": "your actual answer here",
  "session_id": "...",
  "duration_ms": 7125,
  "total_cost_usd": 0.18
}
```

Extract the `result` field for the actual answer.

**Error handling:**
- Check `is_error: true` for failures
- Check `exit_code` from BashOutput (0 = success)
- Empty/malformed JSON = spawned agent failed

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I can just do this myself" | You'll burn context budget on work that should be delegated |
| "Spawning seems complicated" | 4 steps: write prompt, background, poll, parse. Takes ~10 seconds. |
| "I should spawn an agent for this simple task" | If YOU were just spawned, do the work. Don't recurse infinitely. |
| "I'll load the files directly" | Loading large files wastes context. Spawn agent with file access instead. |

## Common Mistakes

### ❌ Forgetting You Don't Have Task Tool
```
You are a subagent
→ Tries Task tool
→ Tool not available
```

**Fix:** Use CLI spawning instead.

### ❌ Not Passing File Access
```
cat prompt.txt | claude -p --output-format json
→ Spawned agent: "I don't have access to /some/path"
```

**Fix:** Add `--add-dir /some/path` to command.

### ❌ Constant Polling Without Sleep
```
while not complete:
    check BashOutput every few milliseconds
    → Burns through tool calls
```

**Fix:** Use `sleep 3` between polls. System reminders notify when ready.

### ❌ Not Handling JSON Parse Errors
```
Parse stdout directly
→ Malformed JSON crashes
```

**Fix:** Check `exit_code: 0` and `is_error: false` before parsing.

## Real-World Impact

**Context efficiency:** Spawning agents with fresh context can be 50-100x more efficient than loading large files into current context.

**Parallel work:** Spawn multiple agents for independent tasks, poll all, gather results.

**Subagent capability:** Subagents can now delegate just like main instances (via different mechanism).
