---
name: read-task
description: Read and execute task delegated from Claude. Use when user says read task, get task, or pick up claude task.
---

# Read Task Skill

Read and execute a task delegated from Claude Code.

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

### 1. Update Status

Write `working` to `$AGENT_COLLAB_DIR/status`

### 2. Read the Task

Read `$AGENT_COLLAB_DIR/requests/task.md` and parse:
- Task Type: CODE_REVIEW, IMPLEMENT, or PLAN_REVIEW
- All requirements and context

### 3. Read Shared Context

Also read `$AGENT_COLLAB_DIR/context/shared.md` for project context.

### 4. Execute Based on Task Type

#### CODE_REVIEW

Perform thorough code review:
- Analyze code line by line
- Look for bugs, logic errors, edge cases
- Check for security vulnerabilities
- Identify performance problems
- Check error handling
- Suggest concrete improvements with code examples

Be thorough - take your time.

#### IMPLEMENT

Implement the requested feature:
- Follow all requirements exactly
- Match existing code patterns
- Write clean, well-structured code
- Handle edge cases and errors
- Write code to specified target files

Take time for high-quality implementation.

#### PLAN_REVIEW

Critically analyze the plan:
- Evaluate overall approach
- Identify failure modes
- Consider scalability/maintainability
- Suggest alternatives if applicable
- Point out missing considerations
- Assess risks
- Provide concrete recommendations

### 5. Write Response

Write complete response to `$AGENT_COLLAB_DIR/responses/response.md`:

```markdown
# Codex Response

## Task Type
[Task type handled]

## Completed At
[Timestamp]

## Summary
[Brief summary]

## Detailed Findings/Output

[For CODE_REVIEW:]
### Critical Issues
[List with severity]

### Security Concerns
[Security issues]

### Suggestions
[Improvements with examples]

---

[For IMPLEMENT:]
### Implementation Overview
[What was implemented]

### Files Created/Modified
[List of files]

### Integration Notes
[How to integrate]

---

[For PLAN_REVIEW:]
### Overall Assessment
[Is plan sound?]

### Concerns
[Issues identified]

### Recommendations
[Specific suggestions]
```

### 6. Update Status

Write `done` to `$AGENT_COLLAB_DIR/status`

### 7. Notify

Tell user response is ready and Claude can read it with `/codex-read`.
