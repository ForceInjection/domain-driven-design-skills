---
name: rpi
description: Use when implementing features from Jira tickets, PRDs, or user requirements. Orchestrates Research-Plan-Implement workflow with quality gates for hallucination, overengineering, and underengineering detection.
---

# RPI - Research, Plan, Implement (Orchestrator)

Full workflow orchestrator that **invokes individual skills** in sequence with quality gates.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           RPI WORKFLOW                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   INPUT              RESEARCH           AUDIT            PLAN               │
│  ┌──────┐           ┌──────┐          ┌──────┐         ┌──────┐            │
│  │ Jira │──────────▶│      │─────────▶│      │────────▶│      │            │
│  │ PRD  │           │      │  PASS?   │      │  PASS?  │      │            │
│  │Prompt│           │      │          │      │         │      │            │
│  └──────┘           └──────┘          └──────┘         └──────┘            │
│                         │                                  │                │
│                         ▼                                  ▼                │
│                    research.md                         plan.md              │
│                                                                             │
│                     AUDIT             IMPLEMENT         REVIEW              │
│                    ┌──────┐          ┌──────┐         ┌──────┐             │
│               ────▶│      │─────────▶│      │────────▶│      │             │
│                    │      │  PASS?   │      │         │      │             │
│                    │      │          │      │         │      │             │
│                    └──────┘          └──────┘         └──────┘             │
│                                          │                │                 │
│                                          ▼                ▼                 │
│                                       CODE            APPROVED              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Agent Compatibility

- OUTPUT_DIR: `.claude/output` for Claude Code, `.codex/output` for Codex CLI.
- Slash commands like `/rpi` and "Use Skill tool" are Claude Code syntax; in Codex CLI, invoke the skill by name in the prompt.
- TodoWrite: use the tool in Claude Code; in Codex CLI, use `update_plan` or a simple checklist.

## When to Use

Use this skill when:
- User provides a Jira issue key (e.g., KB-1234)
- User provides a Confluence PRD URL
- User describes a feature to implement
- User says "implement", "build", "create feature", or similar

---

## Workflow - Skill Invocations

The RPI orchestrator invokes individual skills in sequence:

```
/rpi {input}
    │
    ├── Step 0: Create Session (automatic)
    │   └── Generate session ID: rpi-{feature}-{YYYYMMDD}-{hash}
    │   └── Initialize session tracking
    │
    ├── Step 1: Invoke /research {input}
    │   └── Output: research-{feature}.md
    │
    ├── Step 2: Invoke /audit research
    │   └── Gate: Confidence ≥60%, Hallucination ≤20%
    │   └── If FAIL: Stop and request clarification
    │
    ├── Step 3: Invoke /plan
    │   └── Output: plan-{feature}.md
    │
    ├── Step 4: Invoke /audit plan
    │   └── Gate: Traceability 100%, Balance ≥70%
    │   └── If FAIL: Revise plan
    │
    ├── Step 5: User Approval
    │   └── Present plan summary
    │   └── Wait for explicit approval
    │
    ├── Step 6: Invoke /implement
    │   └── Output: Code changes
    │
    └── Step 7: Invoke /code-review
        └── Output: Review with P0/P1/P2 findings
```

---

## Instructions

### Step 0: Session Creation (MANDATORY - DO THIS FIRST)

**CRITICAL: You MUST execute these steps BEFORE any other processing. Do NOT skip this step.**

If `--session resume {id}` is passed, skip to "Resume Existing Session" below. Otherwise, create a new session:

#### 0.1 Parse Input & Generate Session ID

First, derive the feature name from the input:
- **Jira key** (e.g., KB-1234) → feature = `kb-1234` (lowercase)
- **Confluence URL** → feature = sanitized page title (lowercase, spaces to hyphens)
- **Direct prompt** → feature = short slug (e.g., "export-feature", max 30 chars)

Then generate a 6-character random hash and create the session ID:
```
rpi-{feature-slug}-{YYYYMMDD}-{6-char-hash}
```
Example: `rpi-kb-1234-20260104-a1b2c3`

#### 0.2 Create Session Directory

**Use the Bash tool:**
```bash
mkdir -p ~/.claude/sessions/{session-id}
```

#### 0.3 Create session.json

**Use the Write tool** to create `~/.claude/sessions/{session-id}/session.json` with this content (replace placeholders):

```json
{
  "id": "{session-id}",
  "version": "1.0",
  "created_at": "{current ISO timestamp}",
  "updated_at": "{current ISO timestamp}",
  "agent": "claude-code",
  "input": {
    "type": "{jira|confluence|prompt}",
    "source": "{original input}",
    "feature_name": "{feature-slug}"
  },
  "phase": {
    "current": "research",
    "research": { "status": "pending" },
    "plan": { "status": "pending" },
    "implement": { "status": "pending", "current_task": null, "tasks_completed": [], "tasks_remaining": [] },
    "review": { "status": "pending" }
  },
  "progress": {
    "percentage": 0,
    "tasks_total": 0,
    "tasks_done": 0,
    "quality_gates": {
      "research_audit": { "passed": null, "score": null },
      "plan_audit": { "passed": null, "score": null },
      "code_review": { "passed": null, "score": null }
    }
  },
  "artifacts": {},
  "context": { "key_decisions": [], "blockers": [], "notes": "" },
  "continuation": {
    "last_action": "Session created",
    "next_action": "Start research phase",
    "resume_prompt": "Continue RPI session {session-id}. Phase: research. Progress: 0%"
  }
}
```

#### 0.4 Update Session Registry

**Use the Read tool** to read `~/.claude/sessions/index.json`.

**Use the Edit tool** to update it:
1. Add `"{session-id}"` to the `sessions` array
2. Set `active_session` to `"{session-id}"`

If index.json doesn't exist, **use the Write tool** to create it:
```json
{
  "version": "1.0",
  "sessions": ["{session-id}"],
  "active_session": "{session-id}"
}
```

#### 0.5 Announce Session

Output to the user:
```
✓ Session created: {session-id}
  Proceeding with research phase...
```

**Only after completing steps 0.1-0.5, proceed to Step 1.**

---

#### Resume Existing Session

If `--session resume` or `--session resume {id}` is used:

1. **Read** `~/.claude/sessions/index.json` to get `active_session` (if no ID provided)
2. **Read** `~/.claude/sessions/{session-id}/session.json`
3. **Check** `phase.current` to determine where to resume
4. **Announce**: `Resuming session: {session-id} at phase: {phase}`
5. **Skip to** the appropriate step based on `phase.current`

---

### Step 1: Input Detection & Feature Naming

Detect input source and derive feature name:

```
Input Sources:
├── Jira Issue (KB-1234)
│   └── Use mcp__atlassian__getJiraIssue to fetch
│   └── Feature name = ticket key (e.g., "kb-1234")
│
├── Confluence Page (URL)
│   └── Use mcp__atlassian__getConfluencePage to fetch
│   └── Feature name = sanitized page title
│
└── Direct Prompt ("Add export feature")
    └── Parse requirements from message
    └── Feature name = short slug (e.g., "export-feature")
```

Store feature name for all subsequent skill invocations.

### Step 2: Research Phase

**Invoke the /research skill:**

```
Use Skill tool:
  skill: "research"
  args: "{input}" (the original Jira key, URL, or prompt)
```

Wait for research skill to complete. It will produce:
- `OUTPUT_DIR/research-{feature}.md`

### Step 3: Research Audit

**Invoke the /audit skill for research:**

```
Use Skill tool:
  skill: "audit"
  args: "research"
```

**Quality Gate Check:**
| Metric | Threshold | Action if FAIL |
|--------|-----------|----------------|
| Confidence | ≥ 60% | Ask user for clarification |
| Hallucination | ≤ 20% | Remove phantom requirements |
| Coverage | ≥ 80% | Identify missing information |

**If audit FAILS:**
```
STOP the workflow.
Report findings to user.
Ask for clarification or additional information.
Re-run /research after user provides info.
```

**If audit PASSES:**
```
Proceed to Step 4.
```

### Step 4: Plan Phase

**Invoke the /plan skill:**

```
Use Skill tool:
  skill: "plan"
```

Wait for plan skill to complete. It will produce:
- `OUTPUT_DIR/plan-{feature}.md`

### Step 5: Plan Audit

**Invoke the /audit skill for plan:**

```
Use Skill tool:
  skill: "audit"
  args: "plan"
```

**Quality Gate Check:**
| Metric | Threshold | Action if FAIL |
|--------|-----------|----------------|
| Traceability | 100% | Map missing requirements to tasks |
| Balance Score | ≥ 70% | Reduce over/underengineering |
| Pattern Compliance | ≥ 90% | Fix pattern violations |

**If audit FAILS:**
```
Report specific issues.
Revise plan to address findings.
Re-run /audit plan.
```

**If audit PASSES:**
```
Proceed to Step 6.
```

### Step 6: User Approval

**Present plan summary and request approval:**

```markdown
## Implementation Plan Summary

**Feature**: {feature name}
**Tasks**: {count} tasks
**Files**: {new count} new, {modified count} modified
**Complexity**: {low/medium/high}

### Key Decisions
{List architectural decisions}

### Task Overview
{List of tasks in sequence}

### Quality Gates Passed
- Research Audit: PASS (Confidence: X%, Hallucination: Y%)
- Plan Audit: PASS (Traceability: 100%, Balance: Z%)

---

**Proceed with implementation?** (yes/no)
```

**Wait for explicit user approval before proceeding.**

If user says "no" or requests changes:
- Address feedback
- Re-run relevant phase
- Present updated summary

### Step 7: Implementation Phase

**Invoke the /implement skill:**

```
Use Skill tool:
  skill: "implement"
```

The implement skill will:
- Read AGENTS.md and project patterns
- Execute tasks in dependency order
- Track progress with TodoWrite (Claude Code) or `update_plan` (Codex CLI)
- Run `flutter analyze` after changes
- Produce code changes

### Step 8: Code Review

**Invoke the /code-review skill:**

```
Use Skill tool:
  skill: "code-review"
```

The code-review skill will:
- Review all new/modified files
- Report P0/P1/P2 findings
- Check AGENTS.md compliance

**Handle Review Findings:**

| Severity | Action |
|----------|--------|
| P0 (Critical) | MUST fix before completing |
| P1 (Important) | SHOULD fix, discuss with user |
| P2 (Nice-to-have) | Note for future improvement |

If P0 issues found:
```
Fix all P0 issues.
Re-run /code-review to verify fixes.
```

---

## Quality Gates Summary

| Gate | Phase | Metrics | Threshold |
|------|-------|---------|-----------|
| Gate 1 | Research | Confidence | ≥ 60% |
| Gate 1 | Research | Hallucination | ≤ 20% |
| Gate 1 | Research | Coverage | ≥ 80% |
| Gate 2 | Plan | Traceability | 100% |
| Gate 2 | Plan | Balance Score | ≥ 70% |
| Gate 2 | Plan | Pattern Compliance | ≥ 90% |
| Gate 3 | Implementation | Lint | PASS |
| Gate 3 | Implementation | P0 Issues | 0 |

---

## Output Files

All outputs saved to OUTPUT_DIR:

| File | Produced By | Description |
|------|-------------|-------------|
| `research-{feature}.md` | /research | Research findings |
| `audit-{feature}.md` | /audit | Audit reports (multiple) |
| `plan-{feature}.md` | /plan | Implementation plan |
| `review-{feature}.md` | /code-review | Code review report |

---

## Error Handling

### Research Fails Audit
```
1. Report specific findings (hallucinations, low confidence)
2. Ask user for clarification
3. Re-invoke /research with additional context
4. Re-invoke /audit research
```

### Plan Fails Audit
```
1. Report specific findings (missing coverage, overengineering)
2. Revise plan based on findings
3. Re-invoke /audit plan
```

### Implementation Fails
```
1. Stop at failing task
2. Diagnose issue
3. Options:
   a. Fix and continue (minor issue)
   b. Re-invoke /plan (design issue)
   c. Re-invoke /research (fundamental issue)
```

### Code Review Finds P0
```
1. List all P0 issues
2. Fix each P0 issue
3. Re-invoke /code-review
4. Repeat until P0 count = 0
```

---

## Example Execution

```
User: /rpi KB-1234

Agent: Starting RPI workflow for KB-1234...

## Step 1: Input Detection
Detected: Jira Issue
Fetching KB-1234...
Feature name: kb-1234

## Step 2: Research
Invoking /research KB-1234...
[Research skill executes]
Created: OUTPUT_DIR/research-kb-1234.md

## Step 3: Research Audit
Invoking /audit research...
[Audit skill executes]

Results:
- Confidence: 75% ✓
- Hallucination: 12% ✓
- Coverage: 85% ✓

Gate 1: PASSED

## Step 4: Plan
Invoking /plan...
[Plan skill executes]
Created: OUTPUT_DIR/plan-kb-1234.md

## Step 5: Plan Audit
Invoking /audit plan...
[Audit skill executes]

Results:
- Traceability: 100% ✓
- Balance: 78% ✓
- Pattern Compliance: 95% ✓

Gate 2: PASSED

## Step 6: User Approval
[Present plan summary]

Proceed with implementation? (yes/no)

User: yes

## Step 7: Implementation
Invoking /implement...
[Implement skill executes]
Code changes complete.

## Step 8: Code Review
Invoking /code-review...
[Code review skill executes]

Results:
- P0: 0 ✓
- P1: 2
- P2: 3

Gate 3: PASSED

## Workflow Complete

Feature KB-1234 has been implemented successfully.

Summary:
- Research: PASSED
- Plan: PASSED
- Implementation: COMPLETE
- Code Review: APPROVED

Files changed:
- Created: 5 files
- Modified: 3 files

P1 issues noted for follow-up:
1. {issue}
2. {issue}
```

---

## Quick Reference

### Full Workflow (Auto-creates session)
```
/rpi KB-1234              # From Jira (auto-creates new session)
/rpi {confluence-url}     # From Confluence (auto-creates new session)
/rpi Add export feature   # From prompt (auto-creates new session)
```

### Session Commands
```
/rpi --session resume {id}      # Resume by session ID
/rpi --session resume           # Resume active session
/rpi --session list             # List all sessions
/rpi --session status           # Show current session status (CLI tracker)
```

### Resume/Retry Commands
```
/rpi --resume             # Resume from last checkpoint
/rpi --from research      # Restart from research
/rpi --from plan          # Restart from plan
/rpi --from implement     # Restart from implementation
```

---

## Session Tracking System

Sessions enable cross-session continuity and progress tracking.

### Session ID Format
```
rpi-{feature-slug}-{YYYYMMDD}-{short-hash}
Example: rpi-kb-4149-20260103-a1b2c3
```

### Session Storage (Global)
```
~/.claude/sessions/               # Global location (works from any project)
  index.json                      # Session registry
  {session-id}/
    session.json                  # Core session data
    context-summary.md            # Human-readable context
```

### Session Schema
```json
{
  "id": "rpi-{feature}-{date}-{hash}",
  "version": "1.0",
  "created_at": "ISO timestamp",
  "updated_at": "ISO timestamp",
  "agent": "claude-code",

  "input": {
    "type": "jira|confluence|prompt",
    "source": "KB-1234",
    "feature_name": "kb-1234"
  },

  "phase": {
    "current": "research|plan|implement|review|complete",
    "research": { "status": "pending|in_progress|complete|failed" },
    "plan": { "status": "..." },
    "implement": {
      "status": "...",
      "current_task": "T3",
      "tasks_completed": ["T1", "T2"],
      "tasks_remaining": ["T4", "T5"]
    },
    "review": { "status": "..." }
  },

  "progress": {
    "percentage": 45,
    "tasks_total": 5,
    "tasks_done": 2,
    "quality_gates": {
      "research_audit": { "passed": true, "score": 95 },
      "plan_audit": { "passed": true, "score": 88 },
      "security_audit": { "passed": null },
      "performance_audit": { "passed": null },
      "code_review": { "passed": null }
    }
  },

  "artifacts": {
    "research": ".claude/output/research-{feature}.md",
    "plan": ".claude/output/plan-{feature}.md"
  },

  "context": {
    "key_decisions": [],
    "blockers": [],
    "notes": ""
  },

  "continuation": {
    "last_action": "Completed T2: Create domain model",
    "next_action": "Start T3: Create service layer",
    "resume_prompt": "Continue RPI session {id}. Last: T2. Next: T3."
  }
}
```

### Session Management Instructions

**Starting a New Session (Automatic with any /rpi {input}):**
```
Sessions are automatically created when running /rpi with any input.
No need for --session new flag.

1. Generate session ID: rpi-{feature-slug}-{YYYYMMDD}-{6-char-hash}
2. Create directory: ~/.claude/sessions/{session-id}/
3. Initialize session.json with input details
4. Update index.json: add to sessions[], set active_session
5. Announce session creation to user
6. Proceed with normal RPI workflow
7. Update session.json after each phase completion
```

**Resuming a Session:**
```
1. If ID provided: Load ~/.claude/sessions/{id}/session.json
2. If no ID: Load active_session from index.json
3. Read continuation.resume_prompt for context
4. Resume from phase.current
5. Continue tracking progress
```

**Session Auto-Save Points:**
```
- After research completion
- After audit pass/fail
- After plan completion
- After each implementation task
- After code review
- On any error or blocker
```

**Displaying Session Status:**
```
Run: skills/scripts/rpi-tracker.sh [session-id]
Or:  skills/scripts/rpi-status.sh (one-liner)
```

---

## Progress Tracking (MANDATORY)

**CRITICAL: You MUST update progress after EVERY phase transition and task completion.**

### Progress Formula

| Phase | Action | Progress |
|-------|--------|----------|
| Research | Phase started | 5% |
| Research | Research complete | 10% |
| Research | Audit PASS | 15% |
| Plan | Plan started | 20% |
| Plan | Plan complete | 25% |
| Plan | Audit PASS | 30% |
| Approval | User approved | 35% |
| Implement | Per task | 35% + (55% / tasks_total) per task |
| Review | Review started | 90% |
| Complete | Review PASS | 100% |

### Update Commands

Use Bash to run the progress update script:

```bash
# When starting a phase
~/.claude/skills/scripts/rpi-progress.sh --phase research --status in_progress

# When completing a phase
~/.claude/skills/scripts/rpi-progress.sh --phase research --status complete

# When audit passes
~/.claude/skills/scripts/rpi-progress.sh --audit research --passed true --score 85

# When setting total tasks (before implementation)
~/.claude/skills/scripts/rpi-progress.sh --tasks-total 5

# When starting a task
~/.claude/skills/scripts/rpi-progress.sh --task-start T1 --last "Starting T1" --next "Complete T1"

# When completing a task
~/.claude/skills/scripts/rpi-progress.sh --task-done T1 --last "Completed T1" --next "Start T2"

# When moving to implementation
~/.claude/skills/scripts/rpi-progress.sh --phase implement --tasks-total 5
```

### Progress Update Checkpoints

**You MUST run progress updates at these exact points:**

1. **After Step 0 (Session Created)**
   ```bash
   ~/.claude/skills/scripts/rpi-progress.sh --phase research --status pending
   ```

2. **After Step 2 (Research Complete)**
   ```bash
   ~/.claude/skills/scripts/rpi-progress.sh --phase research --status complete
   ```

3. **After Step 3 (Research Audit)**
   ```bash
   ~/.claude/skills/scripts/rpi-progress.sh --audit research --passed true --score {score}
   ```

4. **After Step 4 (Plan Complete)**
   ```bash
   ~/.claude/skills/scripts/rpi-progress.sh --phase plan --status complete
   ```

5. **After Step 5 (Plan Audit)**
   ```bash
   ~/.claude/skills/scripts/rpi-progress.sh --audit plan --passed true --score {score}
   ```

6. **After Step 6 (User Approval)**
   ```bash
   ~/.claude/skills/scripts/rpi-progress.sh --set 35 --last "User approved plan" --next "Start implementation"
   ```

7. **Before Step 7 (Implementation Start)**
   ```bash
   ~/.claude/skills/scripts/rpi-progress.sh --phase implement --tasks-total {count}
   ```

8. **After EACH task in Step 7**
   ```bash
   ~/.claude/skills/scripts/rpi-progress.sh --task-done T{n} --last "Completed T{n}" --next "Start T{n+1}"
   ```

9. **After Step 8 (Code Review)**
   ```bash
   ~/.claude/skills/scripts/rpi-progress.sh --audit code_review --passed true --score {score}
   ~/.claude/skills/scripts/rpi-progress.sh --phase complete
   ```

---

## Integration with Individual Skills

This orchestrator uses these skills (each can also be run standalone):

| Skill | Trigger | Use Case |
|-------|---------|----------|
| Research | `/research` | Explore before committing to implementation |
| Audit | `/audit` | Validate any artifact independently |
| Plan | `/plan` | Create plan when scope is clear |
| Implement | `/implement` | Execute when plan is ready |
| Code Review | `/code-review` | Review any code changes |

**When to use individual skills vs /rpi:**
- Use `/rpi` for complete feature implementation
- Use individual skills for targeted tasks or exploration
