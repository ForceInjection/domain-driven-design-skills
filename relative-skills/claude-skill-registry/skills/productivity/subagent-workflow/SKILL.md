---
name: subagent-workflow
description: >-
  Use when orchestrating subagents for implementation. Covers when to dispatch
  vs recall, how to scope tasks, session management, and handoff patterns.
  Load this before working with any subagent.
---

# Subagent Workflow

Orchestrate subagents effectively.

> **Announce:** "I'm using subagent-workflow to coordinate [subagent] for this task."

## Iron Law

```
TRACK SESSION IDs - RECALL FOR FOLLOW-UPS
```

When a subagent completes work and later issues are found, recall their session
instead of starting fresh. They have context.

## Available Subagents

### @supabase-expert

**Invoke for:**
- Database schema changes
- SQL function creation/modification
- RLS policy implementation
- PostGIS/pgvector operations

**What they know:**
- Source-based workflow (`supabase/db/` → `db:rebuild` → `test db`)
- This project's schema structure
- Game logic ownership (ALL business logic)

**What they DON'T know:**
- Frontend code or patterns
- Vue/TypeScript specifics

**Tools:** bash (db commands), edit, write, read, sequential-thinking

### @frontend-expert

**Invoke for:**
- Vue 3 component creation/modification
- shadcn-vue UI implementation
- Pinia store updates
- Composable creation

**What they know:**
- Vue 3 Composition API
- shadcn-vue components
- How to call `supabase.rpc()`

**What they DON'T know:**
- Database internals or SQL
- Game logic (will refuse to implement)

**Tools:** bash (lint/test), edit, write, read

### @code-reviewer

**Invoke for:**
- Post-implementation review
- Architecture compliance check
- Security audit

**What they do:**
- Review and report findings
- Do NOT make changes

**Tools:** read, glob, grep, list, sequential-thinking

### @researcher

**Invoke for:**
- Technical questions
- Comparing approaches
- Documentation exploration

**What they do:**
- Investigate and synthesize
- Advise on approaches
- Do NOT implement

**Tools:** read, glob, grep, webfetch, exa search, sequential-thinking

### @player

**Invoke for:**
- Manual gameplay testing
- UX verification

**Tools:** chrome-devtools only (no code access)

## Task Scoping

When dispatching a subagent, provide:

```
TASK: [One clear sentence]

CONTEXT:
- Relevant files: [list paths]
- Current state: [what exists]
- Expected outcome: [what should exist after]

CONSTRAINTS:
- [Any specific limitations]
- [Reference to spec if applicable]
```

**Good task:**
```
TASK: Add RLS policy for leaderboard_entries table that restricts 
reads to authenticated users.

CONTEXT:
- Table defined in: supabase/db/schema/leaderboard.sql
- Similar policy exists: supabase/db/schema/game_sessions.sql:45-52
- Expected: Only auth.uid() can read their own entries

CONSTRAINTS:
- Follow existing RLS patterns
- Add pgTAP test
```

**Bad task:**
```
TASK: Fix the leaderboard security
```

## Session Management

### Dispatching (Fresh Session)

Use for independent, new tasks:

```
Dispatching @supabase-expert for Task 2.1
[Provide scoped task]
→ Note session_id when they respond
```

### Recalling (Same Session)

Use when:
- Code review found issues in their work
- Follow-up question about their implementation
- Bug found in code they wrote

```
Recalling @supabase-expert session [session_id]:
Code review found RLS policy missing auth.uid() check in 
get_leaderboard function. Please fix.
```

The agent has full context of what they did - no re-reading needed.

### When to Recall vs Fresh

| Situation | Action |
|-----------|--------|
| Review found bugs in their work | RECALL |
| Follow-up question | RECALL |
| New independent task | FRESH |
| Different domain (DB issue, but need frontend fix) | FRESH with correct agent |

## Handoff Patterns

### Pattern 1: Sequential Implementation

```
1. Dispatch @supabase-expert for DB tasks → session_id: A
2. Dispatch @frontend-expert for UI tasks → session_id: B
3. Dispatch @code-reviewer for review
4. If DB issues found → Recall session A
5. If UI issues found → Recall session B
```

### Pattern 2: Blocked Subagent

If a subagent reports they're blocked:

```
@frontend-expert: "I need a new RPC function get_stats() but it 
doesn't exist. Pausing until backend is ready."

Main agent action:
1. Note frontend session_id: B
2. Dispatch @supabase-expert to create function → session_id: C
3. After completion, recall frontend session B:
   "The get_stats() function is now available. Please continue."
```

### Pattern 3: Cross-Domain Issue

If one agent finds issues in another's domain:

```
@frontend-expert: "The RPC call to get_leaderboard returns wrong 
data format. Expected {entries: []}, got []."

Main agent action:
1. Pause frontend (note session B)
2. Dispatch @supabase-expert to fix function
3. After fix, recall frontend session B to continue
```

## Post-Subagent Verification

After subagent returns:

1. **Review output:**
   - Did they complete the task?
   - Any issues reported?

2. **Consider review:**
   - For significant changes → dispatch @code-reviewer
   
3. **Report to user:**
   - Summarize what was done
   - Don't just pass through raw output

4. **Collect feedback (optional but valuable):**
   - If the task was complex or the agent struggled, recall and ask:
   ```
   STOP - Don't read any more files. Just reflect briefly:
   - What context was missing that would have helped?
   - What would have made this task easier?
   - Any suggestions for improving the task description?
   ```
   - Use this feedback to improve future task scoping and context
   - Consider updating skills or documentation based on patterns

## Red Flags - STOP

If you:
- Dispatch without clear task scope
- Forget to note session_id
- Start fresh when you should recall
- Trust output without verification

STOP. Follow the workflow.

## Common Mistakes

| Mistake | Why Bad | Do Instead |
|---------|---------|------------|
| Vague task scope | Subagent will guess wrong | Be explicit about files and outcomes |
| Forgetting session_id | Can't recall for follow-ups | Always note it |
| Fresh session for fix | Agent loses context | Recall original session |
| Trusting blindly | Subagents have blind spots | Verify with @code-reviewer |

## Anti-Pattern: Rewriting OpenSpec as Instructions

When an openspec change exists, do NOT rewrite its content as task instructions.

**WRONG:**
```
TASK: Update trigger to fire on INSERT OR UPDATE...
Change RAISE WARNING to RAISE EXCEPTION in these files...
[rewrites entire tasks.md content]
```

**RIGHT:**
```
Implement the approved openspec change: fix-learning-trigger-errors

Run `openspec show fix-learning-trigger-errors` to see the proposal and tasks.
Load skills_openspec_apply and follow the task list.
Report back when complete.
```

**Why this matters:**
- OpenSpec is the single source of truth
- Rewriting bypasses the agent's skill loading
- You're doing the agent's work, treating them as code-execution proxies
- Any discrepancy between your rewrite and openspec causes confusion

**When to provide detailed context:**
- Ad-hoc tasks with no openspec change
- Quick fixes that don't warrant a full proposal
- Exploratory investigation tasks

**When to just point to openspec:**
- Approved changes with tasks.md
- Any task that has formal specification
