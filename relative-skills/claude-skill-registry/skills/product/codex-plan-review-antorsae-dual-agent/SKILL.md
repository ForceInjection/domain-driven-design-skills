---
name: codex-plan-review
description: Send implementation plan to Codex for critique and validation. Use PROACTIVELY after you produce a non-trivial plan (including after /plan mode) unless the user opts out, or when the user says review plan, codex plan review, or wants architectural feedback.
---

# Codex Plan Review Skill

Send an implementation plan to Codex for critical analysis and validation.

## When to Use

- Before implementing complex features
- When architectural decisions need validation
- User wants second opinion on approach
- After you generate a non-trivial plan (multi-step or multi-file), unless the user explicitly asks to skip the review
- If plan mode is declined or unavailable for non-trivial work, produce a short plan summary and still run this review before implementation
- If you are in plan mode and have a plan, run this review *before* presenting the final plan or asking "Ready to code?"

## Steps

Before any file operations, resolve the `.agent-collab` directory so commands work outside the project root:

```bash
AGENT_COLLAB_DIR="${AGENT_COLLAB_DIR:-}"
if [ -n "$AGENT_COLLAB_DIR" ]; then
  if [ -d "$AGENT_COLLAB_DIR/.agent-collab" ]; then
    AGENT_COLLAB_DIR="$AGENT_COLLAB_DIR/.agent-collab"
  elif [ ! -d "$AGENT_COLLAB_DIR" ]; then
    AGENT_COLLAB_DIR=""
  fi
fi

if [ -z "$AGENT_COLLAB_DIR" ]; then
  AGENT_COLLAB_DIR="$(pwd)"
  while [ "$AGENT_COLLAB_DIR" != "/" ] && [ ! -d "$AGENT_COLLAB_DIR/.agent-collab" ]; do
    AGENT_COLLAB_DIR="$(dirname "$AGENT_COLLAB_DIR")"
  done
  AGENT_COLLAB_DIR="$AGENT_COLLAB_DIR/.agent-collab"
fi
```

If `$AGENT_COLLAB_DIR` does not exist, stop and ask for the project root.

### 1. Gather the Plan

Ensure plan includes:
- Overall approach
- Step-by-step strategy
- Files to create/modify
- Key architectural decisions
- Potential risks

If no plan exists, help user create one first. If you just produced a plan, reuse it directly without re-asking.
If plan mode is declined or you are not in plan mode, write a concise plan summary (5-10 bullets) before running this review.
If you are in plan mode, do not finalize or present the plan yet. Delegate to Codex first, then integrate the feedback into the final plan and only then ask the user to proceed.

If the user explicitly says to skip plan review, do not run this skill.

### 2. Write Review Request

Write to `$AGENT_COLLAB_DIR/requests/task.md`:

```markdown
# Task Request for Codex

## Task Type: PLAN_REVIEW

## Timestamp
[Current timestamp]

## Plan Title
[Brief title]

## The Plan
[Full plan content]

## Review Questions
- Is this approach sound?
- Are there edge cases not considered?
- Is the architecture appropriate?
- Are there simpler alternatives?
- What are the risks?

## Specific Concerns
[Areas of uncertainty]

## Constraints
[Constraints to respect]
```

### 3. Update Status

Write `pending` to `$AGENT_COLLAB_DIR/status`

### 4. Trigger Codex

```bash
tmux send-keys -t 1 '$read-task' && sleep 0.5 && tmux send-keys -t 1 Enter Enter
```

### 5. Notify User

Tell user briefly that plan was sent to Codex for review and that you'll return with feedback before implementation. Do not ask the user to proceed yet.

### 6. Wait for Codex (Background Polling)

Start a background polling loop to wait for Codex to complete. Run this EXACT bash command (with `$AGENT_COLLAB_DIR/status`) using the Bash tool with `run_in_background: true`:

```bash
while [ "$(cat "$AGENT_COLLAB_DIR/status")" != "done" ]; do sleep 3; done; echo "CODEX_COMPLETE"
```

CRITICAL: Use the resolved `$AGENT_COLLAB_DIR/status` path so polling works outside the project root. Use background execution so you can continue helping the user while waiting.

### 7. Auto-Read Response

When poll completes, automatically:
1. Read `$AGENT_COLLAB_DIR/responses/response.md`
2. Present Codex's critique clearly
3. Suggest plan refinements based on feedback
4. Reset `$AGENT_COLLAB_DIR/status` to `idle`
