---
name: post-ticket-completion
description: Handle post-ticket completion tasks including test exports, planning doc updates, and learning reflection. Use this skill after a ticket's tests all pass and 6-final.md exists.
---

# Post-Ticket Completion

Tasks to perform after a ticket is successfully completed.

## Post-Completion Tasks

### Step 1: Update Core Tests (if applicable)

Check: Does this ticket affect a core feature?

**If YES:**
1. Identify essential tests from `docs/3-tests/tickets/T0000N/`
2. Copy selection to `docs/3-tests/core/{app}/{feature}/tests-definition.json`
3. Selection criteria:
   - Only consider `ticket-completion: true` tests
   - Select 3-5 essential tests (not all)
   - Focus on end-to-end functionality
   - Skip implementation-detail tests

**Example:**
```
# From ticket T00003 (user authentication)
docs/3-tests/tickets/T00003/tests-definition.json
  → docs/3-tests/core/backend/auth/tests-definition.json

# Only copy essential tests like:
- "User can login with valid credentials"
- "User session persists across requests"
# Skip implementation details like:
- "Password hash uses bcrypt"
```

### Step 2: Update Smoke Tests (rare)

Check: Does this ticket affect app startup or critical path?

**If YES:**
1. Update `docs/3-tests/smoke/{app}-smoke/tests-definition.json`
2. Smoke tests should be minimal (3-5 per app)
3. Only add if this is truly a critical path change

**Smoke test criteria:**
- App launches successfully
- Critical user path works (e.g., login, main feature)
- External dependencies reachable

### Step 3: Update Planning Docs (docs/2-current/)

Read and update the planning documents:

1. **Read `docs/2-current/00-overall-plan.md`:**
   - Understand current roadmap and priorities
   - Mark completed ticket as done
   - Note next ticket in sequence

2. **Update `docs/2-current/00-overall-plan.md`:**
   - Mark ticket as completed (e.g., `[x] T00001: Description`)
   - Update next ticket priorities if needed
   - Adjust timeline/roadmap if applicable

3. **Update `docs/2-current/02-completed.md`:**
   - Add one-liner summary of completed feature
   - Format: `- T0000N: [Brief description] (YYYY-MM-DD)`

4. **Check `docs/2-current/01-deferred-features.md`:**
   - Any deferred features now unblocked by this ticket?
   - If yes, note for next ticket consideration

5. **Archive ticket if needed:**
   - Move to `docs/tickets/archive/` if no longer active
   - Update `docs/tickets/index.md`

### Step 4: Find Next Ticket

Determine the next ticket to process:

1. **Parse current ticket ID** (e.g., T00001 → number 1)
2. **Increment** to next ticket (T00002)
3. **Check bounds:**
   - If `ending_ticket_id` is set and next > ending → no more tickets
   - If `ending_ticket_id` is empty/null → single ticket mode, no more tickets
4. **Check existence:** Does `{working_dir}/docs/tickets/T0000X/` exist?
5. **Return result:**
   - `has_next: true` + `next_ticket_id` if found
   - `has_next: false` + `reason` if no more tickets

### Step 5: Reflect on Learnings

After ticket completion, reflect on what was learned.

#### Review: Gather Context

Before reflecting, review the ticket journey:

1. **Ticket docs** - Read all 6 documents in `docs/tickets/T0000N/`:
   - `1-definition.md` - Original requirements
   - `2-plan.md` - Implementation approach
   - `3-spec.md` - Technical specifications
   - `4-test-development.md` - Test strategy
   - `5-progress-and-issues.md` - Issues encountered
   - `6-final.md` - Completion summary

2. **Test trajectories** - Review `tests-results.json`:
   - Which tests failed initially?
   - How many attempts (`fail_count`) before passing?
   - Any tests marked `blocked: true`?
   - What do trajectories reveal about implementation challenges?

3. **Git commit history** - Review commits for this ticket:
   ```bash
   git log --oneline --grep="T0000N"
   ```
   - How many iterations to complete?
   - What was refactored or fixed?
   - Any reverts or significant changes?

Use these insights to inform the reflection steps below.

#### 5a: New Patterns?

Ask yourself:
- Did debugging reveal reusable solutions?
- Is this pattern reusable for future work?
- Did we discover a better way to do something?

**If YES:** Create/update `docs/0-patterns/{pattern-name}.md`

Pattern file template:
```markdown
# {Pattern Name}

## Problem
What problem does this solve?

## Solution
How to apply this pattern.

## Example
Code or configuration example.

## When to Use
Conditions where this pattern applies.
```

#### 5b: Workflow Improvements?

Ask yourself:
- Did the user refine processes or expectations?
- Are there skill improvements needed?
- Did a skill fail or need enhancement?

**If YES:** Update relevant skills in `.claude/skills/`

#### 5c: Project Knowledge?

Ask yourself:
- Is there project-specific knowledge to preserve?
- Did we learn something about the codebase structure?
- Are there gotchas future sessions should know?

**If YES:** Update `.claude/CLAUDE.md` or repo `CLAUDE.md`

#### 5d: Record Changes of .claude/ files

**CRITICAL:** Log every update done to .claude/ files to `.claude/history.md`:

```markdown
## YYYY-MM-DD: [Brief Title]
- **Type:** pattern | skill | claude-md
- **Files:** [list of files updated]
- **Summary:** [what was learned/changed]
- **Trigger:** T0000N
```

This history ensures future sessions understand why changes were made.

### Step 6: Commit

Commit all changes.

## Output JSON

When invoked by workflow, output:

```json
{
  "core_tests_exported": true|false,
  "core_tests_count": N,
  "smoke_tests_updated": true|false,
  "planning_docs_updated": true|false,
  "patterns_created": ["pattern-name", ...],
  "skills_updated": ["skill-name", ...],
  "history_logged": true|false,
  "has_next": true|false,
  "next_ticket_id": "T0000X" or null,
  "reason": "why no next ticket" or null
}
```

## Quick Checklist

- [ ] Core tests exported (if applicable)
- [ ] Smoke tests updated (if critical path)
- [ ] `00-overall-plan.md` updated
- [ ] `02-completed.md` updated
- [ ] `01-deferred-features.md` checked
- [ ] Ticket archived (if appropriate)
- [ ] Patterns documented (if discovered)
- [ ] Skills updated (if improvements found)
- [ ] History logged in `.claude/history.md`
- [ ] Next ticket identified and returned

## References

- `references/test-structure.md` - Test layer organization (smoke, core, tickets)
- `references/ticket-workflow.md` - Full ticket lifecycle and document structure
