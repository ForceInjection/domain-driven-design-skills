---
name: bead-workflow
description: Manage beads correctly including claiming, closing, announcements, and dependencies. Use when starting work on a task, when finishing a task, when the user mentions beads or tasks, or when coordinating with other agents on task ownership.
---

# Bead Workflow

Proper bead lifecycle: claim → work → close.

---

## When This Applies

| Signal | Action |
|--------|--------|
| Starting work on a task | Run claim protocol |
| Finishing a task | Run close protocol |
| User says "claim" or "start" | Run claim protocol |
| User says "done" or "close" | Run close protocol |
| Multiple agents active | Extra care on announcements |

---

## Claim Protocol

```
1. CHECK
   Inbox, reservations, blockers
        ↓
2. CLAIM
   Parent + ALL sub-beads + assignee
        ↓
3. RESERVE
   Files you'll touch
        ↓
4. ANNOUNCE
   [CLAIMED] message to all agents
```

### Step 1: Check

```bash
# What's ready?
bd ready --json

# What's recommended?
bv --robot-next

# Who's active? (multi-agent)
# ReadMcpResourceTool: resource://agents/{project}

# What's reserved?
# Check file_reservation_status
```

### Step 2: Claim

**CRITICAL: Claim parent AND all sub-beads together.**

```bash
bd update {id} --status in_progress --assignee {YOUR_NAME}
bd update {id}.1 --status in_progress --assignee {YOUR_NAME}
bd update {id}.2 --status in_progress --assignee {YOUR_NAME}
# ... all sub-beads
```

Why: If you only claim parent, other agents see sub-beads as "ready" → conflict.

### Step 3: Reserve Files

```python
file_reservation_paths(
    project_key=PROJECT_PATH,
    agent_name=YOUR_NAME,
    paths=["src/module/**", "tests/test_module.py"],
    ttl_seconds=3600,
    exclusive=True,
    reason="{bead-id}: {description}"
)
```

### Step 4: Announce

```python
send_message(
    project_key=PROJECT_PATH,
    sender_name=YOUR_NAME,
    to=[ALL_AGENTS],
    subject="[CLAIMED] {id} - {title}",
    body_md="Starting work on **{id}**.\n\nSub-beads: .1, .2, .3\nFiles: `src/module/**`",
    importance="normal",
    thread_id="{id}"
)
```

---

## Close Protocol

```
1. VERIFY
   Tests pass, ubs clean
        ↓
2. COMMIT
   Include .beads/issues.jsonl
        ↓
3. CLOSE
   Sub-beads FIRST, then parent
        ↓
4. RELEASE
   File reservations
        ↓
5. ANNOUNCE
   [CLOSED] message
```

### Step 1: Verify (MANDATORY GATES)

```bash
# Run tests
pytest  # or your test command

# Security gate (MANDATORY - do not skip)
ubs --staged
```

**Gate requirements:**
- All tests must pass
- `ubs --staged` must return zero high/critical findings
- Medium findings require documented justification

**If `ubs` reports issues:** Fix them. This counts toward your 3-iteration cap.

### Step 2: Commit

```bash
git add -A  # Includes .beads/issues.jsonl
git commit -m "Implement {feature}

Closes {bead-id}"
```

### Step 3: Close

**CRITICAL: Close sub-beads FIRST, then parent.**

```bash
bd close {id}.1 --reason "Completed: {summary}"
bd close {id}.2 --reason "Completed: {summary}"
bd close {id} --reason "Completed: {summary}"
```

### Step 4: Release

```python
release_file_reservations(
    project_key=PROJECT_PATH,
    agent_name=YOUR_NAME
)
```

### Step 5: Announce

```python
send_message(
    project_key=PROJECT_PATH,
    sender_name=YOUR_NAME,
    to=[ALL_AGENTS],
    subject="[CLOSED] {id} - {title}",
    body_md="Completed **{id}**.\n\nFiles changed: ...\nTests: passing\nReservations released.",
    thread_id="{id}"
)
```

---

## TDD-First & Security Gates (2025 Research)

Based on `research/052-llm-security-vulnerabilities.md`, `research/053-feedback-loop-security.md`, and `research/054-tdd-ai-code-gen.md`:

### Before Starting Any Bead

1. **Check if tests exist in bead description**
2. If not, **write tests FIRST** (do not implement without tests)
3. TDD yields 45.97% higher pass@1 rate—this is not optional

### During Implementation

**Max 3 repair iterations per bead.**

After 3 attempts:
1. **STOP** implementation immediately
2. **Spawn spike bead** to investigate root cause
3. **Notify operator** via Agent Mail with `importance: high`

```python
send_message(
    project_key=PROJECT_PATH,
    sender_name=YOUR_NAME,
    to=["operator"],  # or broadcast
    subject="[BLOCKED] {id} - Needs investigation",
    body_md="Bead {id} failed after 3 repair attempts.\n\nLast error: ...\nSpike created: {spike-id}",
    importance="high",
    thread_id="{id}"
)
```

**Why the cap?** Security degrades with repeated self-correction. Models flip-flop on correct answers. Failing fast is safer than debugging loops.

### Before Closing Any Bead

1. Run `ubs --staged`
2. If findings, fix them (counts toward 3-iteration cap)
3. Only close when `ubs` passes with zero high/critical

**Gate:** Bead cannot close if `ubs --staged` reports high/critical findings.

---

## Quick Reference

```bash
# Find work
bd ready --json
bv --robot-next

# Claim (always include sub-beads + assignee)
bd update {id} --status in_progress --assignee YOUR_NAME

# Close (sub-beads first)
bd close {id}.1 --reason "..."
bd close {id} --reason "..."

# Dependencies
bd dep add {child} {blocker} --type blocks
bd dep tree {id}
bd blocked
```

---

## Anti-Patterns

| Don't | Why | Do Instead |
|-------|-----|------------|
| Claim only parent | Sub-beads appear "ready" to others | Claim all sub-beads |
| Skip assignee | Can't track who's working | Always `--assignee` |
| Skip [CLAIMED] | Duplicate work | Always announce |
| Skip [CLOSED] | Stale state | Always announce |
| Close parent first | Sub-beads orphaned | Close sub-beads first |
| Hoard tasks | Blocks others | One task at a time |
| Skip file reservations | Merge conflicts | Reserve before editing |
| **Implement before tests** | 45.97% lower success rate | **TDD-first always** |
| **Skip `ubs --staged`** | ~40% of LLM code has vulnerabilities | **Mandatory gate** |
| **Unlimited repair loops** | Security degrades, models flip-flop | **Max 3 iterations** |
| **Continue after 3 failures** | Wastes time, introduces bugs | **Stop, spike, escalate** |

---

## See Also

- `dependencies.md` — Dependency management patterns
- `multi-agent.md` — Coordination with other agents
