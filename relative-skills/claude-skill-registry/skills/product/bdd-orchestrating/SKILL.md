---
name: bdd-orchestrating
description: BDD orchestrator for feature-level work. Use when user says 'add', 'implement', 'build', 'feature', 'iteration', 'story', 'phase', 'resume', 'continue', or references a ticket/iteration/story. Also use when work touches 3+ files with new state/flows, or when user runs /bdd. Do NOT use for bug fixes, typos, config changes, or 1-2 file tasks.
allowed-tools: '*'
---

# BDD Orchestrator

Behavior-first development for features. Discovery → Scenarios → Implementation.

**Iron Law:** DEFINE BEHAVIOR BEFORE IMPLEMENTATION

## Phase Tracking

Features progress through phases. Track in ticket frontmatter:

```yaml
---
type: feature
phase: implement # intake | define-behavior | scenario-gate | decomposition | implement | done
---
```

**Phase meanings:**

| Phase             | What happens                         | Details          |
| ----------------- | ------------------------------------ | ---------------- |
| `intake`          | Context check, discovery (Phase 0-2) | DISCOVERY.md     |
| `define-behavior` | Writing Given/When/Then (Phase 3)    | SCENARIOS.md     |
| `scenario-gate`   | Validating scenarios (Phase 4)       | SCENARIOS.md     |
| `decomposition`   | Task breakdown (Phase 5)             | DECOMPOSITION.md |
| `implement`       | Outside-in TDD (Phase 6)             | TDD.md           |
| `done`            | Cleanup, verification (Phase 7)      | DONE.md          |

**Update phase when:**

- Completing a BDD phase → set next phase
- Handing off to TDD → set `implement`
- All scenarios pass → set `done`

---

## Resume Logic

When user references a ticket, resume work:

1. **Read ticket** → get current `phase:`
2. **Find progress** → first unchecked `[ ]` in test-definitions
3. **Check context** → read last work log entry
4. **Announce resume** → "Resuming at [phase]. Last: [log entry]."

**Resume by phase:**

| Phase             | Resume action                          |
| ----------------- | -------------------------------------- |
| `intake`          | Start context check (Phase 0-2)        |
| `define-behavior` | Continue drafting scenarios            |
| `scenario-gate`   | Continue validating scenarios          |
| `decomposition`   | Continue task breakdown                |
| `implement`       | Find first unchecked scenario, run TDD |
| `done`            | Run /done and /audit checks            |

---

## Current Behavior

1. Detect work level (see SAFEWORD.md "Work Level Detection")
2. **If user references iteration/story/phase from a spec:**
   - Check if child ticket exists for that iteration
   - If not → create ticket, run full BDD
   - If yes → resume at current phase
3. Announce with override hint
4. **If ticket exists:** Read phase, resume at appropriate point
5. **Artifact-first rule:** Before doing work, create/verify the phase artifact:
   - Phase 0-2 → ticket at `.safeword-project/tickets/{id}-{slug}/ticket.md`
   - Phase 3 → test-definitions at `.safeword-project/tickets/{id}-{slug}/test-definitions.md`
   - Phase 5 → task breakdown in ticket
6. **Execute phase** using the appropriate phase file
7. **Update phase** in ticket when transitioning

---

## Phase Files

Load the appropriate file based on current phase:

| Phase             | File             |
| ----------------- | ---------------- |
| `intake`          | DISCOVERY.md     |
| `define-behavior` | SCENARIOS.md     |
| `scenario-gate`   | SCENARIOS.md     |
| `decomposition`   | DECOMPOSITION.md |
| `implement`       | TDD.md           |
| `done`            | DONE.md          |

For splitting large features, see SPLITTING.md.

---

## Key Takeaways

- **patch/task** → TDD directly (RED → GREEN → REFACTOR)
- **feature** → full BDD flow (Phases 0-7), track in ticket `phase:` field
- **Resume** → read ticket, find first unchecked scenario, continue
- **Split** → check thresholds at Entry, Phase 3, Phase 5; user decides (see SPLITTING.md)
- **Done gate** → run /done before marking ticket complete
- When unsure → default to task, user can `/bdd` to override
