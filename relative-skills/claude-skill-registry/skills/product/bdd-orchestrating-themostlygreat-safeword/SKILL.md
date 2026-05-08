---
name: bdd-orchestrating
description: BDD orchestrator for feature-level work requiring multiple scenarios. Use when user says 'add', 'implement', 'build', 'feature', 'iteration', 'phase', or work touches 3+ files with new state/flows. Also use when user runs /bdd. Do NOT use for bug fixes, typos, config changes, or 1-2 file tasks—use safeword-tdd-enforcing directly.
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

| Phase             | What happens                         |
| ----------------- | ------------------------------------ |
| `intake`          | Context check, discovery (Phase 0-2) |
| `define-behavior` | Writing Given/When/Then (Phase 3)    |
| `scenario-gate`   | Validating scenarios (Phase 4)       |
| `decomposition`   | Task breakdown (Phase 5)             |
| `implement`       | Outside-in TDD (Phase 6)             |
| `done`            | Cleanup, verification (Phase 7)      |

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
| `done`            | Run /verify and /audit checks          |

---

## Phase 3: Define Behavior

**Entry:** Agent enters `define-behavior` phase (after detection or resume)

**Prerequisite check:**

- If no spec exists → create minimal spec (goal, scope from user request)
- If no ticket exists → create ticket with `phase: define-behavior`

**Draft scenarios:**

1. Read spec goal/scope
2. Draft Given/When/Then scenarios covering:
   - Happy path (main success)
   - Failure modes (what can go wrong)
   - Edge cases (boundaries, empty states)
3. Present scenarios to user
4. User can add/modify/remove scenarios
5. Save to `.safeword-project/test-definitions/feature-{slug}.md`
6. Each scenario gets `[ ]` checkbox for implementation tracking

**Exit:** User approves scenario list → update ticket to `phase: scenario-gate`

---

## Phase 4: Scenario Quality Gate

**Entry:** Agent enters `scenario-gate` phase

**Validate each scenario against three criteria:**

| Criterion         | Check                          | Red flag                        |
| ----------------- | ------------------------------ | ------------------------------- |
| **Atomic**        | Tests ONE behavior             | Multiple When/Then pairs        |
| **Observable**    | Has externally visible outcome | Internal state only             |
| **Deterministic** | Same result on repeated runs   | Time/random/external dependency |

**Report issues:**

- Group by type (atomicity, observability, determinism)
- Suggest fix for each issue
- Example: "Scenario 3 tests login AND session creation. Split into two scenarios."

**Exit options:**

- All pass → update ticket to `decomposition`
- Issues found → user fixes or acknowledges → update ticket to `decomposition`

---

## Phase 5: Technical Decomposition

**Entry:** Agent enters `decomposition` phase (after scenarios validated)

**Analyze scenarios for implementation:**

1. **Identify components** — What parts of the system does each scenario touch?
   - UI components
   - API endpoints
   - Data models
   - Business logic modules
2. **Assign test layers** — For each component:
   - Pure logic (no I/O) → unit test
   - API boundaries, database → integration test
   - User flows → E2E test
3. **Create task breakdown** — Order by dependencies:
   - Data models first
   - Business logic second
   - API endpoints third
   - UI components fourth
   - E2E tests last (prove everything works)
4. **Present to user** — Show components, test layers, task order

**Exit:** User approves breakdown → update ticket to `phase: implement`

---

## Phase 6 Entry: TDD Handoff

**Entry:** Agent enters `implement` phase

**Handoff protocol:**

1. Announce: "Entering implementation. TDD mode for each scenario."
2. Invoke `safeword-tdd-enforcing` skill
3. TDD skill takes over for RED → GREEN → REFACTOR cycles

**For each scenario:**

1. Write E2E test first (from scenario Given/When/Then)
2. E2E fails (RED) — expected, nothing implemented yet
3. TDD loop builds pieces until E2E passes
4. Mark scenario `[x]` when E2E is GREEN

**Walking skeleton (first scenario only):**

If project has no E2E infrastructure, build skeleton first:

- Thinnest possible slice proving architecture works
- Form → API → response → UI (no real logic)
- This becomes foundation for all scenarios

---

## Current Behavior (Iteration 4)

1. Detect work level (see SAFEWORD.md "Work Level Detection")
2. Announce with override hint
3. **If ticket exists:** Read phase, resume at appropriate point
4. **Phase 3:** Draft scenarios from spec, save to test-definitions
5. **Phase 4:** Validate scenarios (atomic, observable, deterministic)
6. **Phase 5:** Decompose into components, assign test layers, create task breakdown
7. **Phase 6 Entry:** Hand off to `safeword-tdd-enforcing` for implementation
8. **Update phase** in ticket when transitioning
9. **REFACTOR:** Verify against guides before marking iteration complete

Future iterations add: context check, discovery.

---

## Key Takeaways

- **patch/task** → delegate to TDD immediately
- **feature** → BDD phases first, track in ticket `phase:` field
- **Resume** → read ticket, find first unchecked scenario, continue
- When unsure → default to task, user can `/bdd` to override
