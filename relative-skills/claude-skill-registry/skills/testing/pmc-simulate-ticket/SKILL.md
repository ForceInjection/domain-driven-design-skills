---
name: pmc-simulate-ticket
description: Simulate the ticket handler workflow step-by-step with real ticket system. Executes setup, implementation, testing, and finalization with explicit ENTER/EXIT stage declarations. Use this skill to debug, understand, or manually run the ticket handler workflow.
---

# PMC Simulate Ticket

Manually simulate the ticket handler workflow step-by-step, executing shell scripts and implementation tasks with explicit stage declarations.

## Required Context

Before starting, you need:
- `ticket_id`: Ticket ID (e.g., T00001)
- `working_dir`: Project working directory

## Workflow Overview

```
ticket.handler
├── setup (claude) ─────────────────→ check_status
├── check_status (shell) ───────────→ finalize (0) | implement (1) | terminal_blocked (2)
├── implement (claude) ─────────────→ check_status (no_work) | test
├── test (workflow: tester) ────────→ evaluate
├── evaluate (shell) ───────────────→ check_status (0,2) | implement (1)
├── finalize (claude) ──────────────→ terminal_success
└── terminal_* (end states)
```

## Execution Instructions

For each state, declare entry and exit explicitly:

```
ENTER STAGE: ticket.handler.{state_name}
  [perform actions]
EXIT STAGE: ticket.handler.{state_name} → {next_state} (reason: {why})
```

---

## State: setup

**Type:** claude
**Session:** start

```
ENTER STAGE: ticket.handler.setup
```

**Setup ticket {ticket_id} for implementation:**

1. **Read existing ticket docs** in `docs/tickets/{ticket_id}/`:
   - `1-definition.md` (required - ticket definition)
   - `2-plan.md` (implementation plan)
   - `3-spec.md` (technical specification)
   - `4-test-development.md` (test development notes)
   - `5-progress-and-issues.md` (progress tracking)
   - `6-final.md` (completion summary - only at end)

2. **Create missing docs** using project-manager skill:

   | Document | Purpose | When to Create |
   |----------|---------|----------------|
   | `2-plan.md` | Implementation approach | If missing |
   | `3-spec.md` | Technical details | If missing |
   | `4-test-development.md` | Test strategy | If missing |
   | `5-progress-and-issues.md` | Progress log | If missing |

3. **Check/create test definition**:
   - Path: `docs/3-tests/tickets/{ticket_id}/tests-definition.json`
   - If missing, create based on ticket definition and plan

**Output JSON:**
```json
{
  "docs_present": ["1-definition.md", ...],
  "docs_created": ["2-plan.md", ...],
  "tests_exist": true|false,
  "tests_created": N
}
```

```
EXIT STAGE: ticket.handler.setup → check_status
```

---

## State: check_status

**Type:** shell
**Script:** `check-status.sh`

```
ENTER STAGE: ticket.handler.check_status
```

**Execute this logic:**

1. Set paths:
   ```
   RESULTS_FILE = {working_dir}/docs/3-tests/tickets/{ticket_id}/tests-results.json
   DEFINITION_FILE = {working_dir}/docs/3-tests/tickets/{ticket_id}/tests-definition.json
   ```

2. If `tests-results.json` doesn't exist:
   - If `tests-definition.json` doesn't exist → EXIT code 3 → `terminal_error`
   - Copy `tests-definition.json` to `tests-results.json`

3. Analyze test results:
   ```python
   total = len(tests)
   passed = 0
   failed = 0
   blocked = 0
   failed_non_blocked = 0

   for test in tests:
       if test.passes:
           passed += 1
       else:
           failed += 1
           if test.blocked:
               blocked += 1
           else:
               failed_non_blocked += 1
   ```

4. Decision logic:

   | Condition | Exit Code | Target | Message |
   |-----------|-----------|--------|---------|
   | `failed == 0` | 0 | `finalize` | All tests passing |
   | `failed_non_blocked > 0` | 1 | `implement` | {N} tests need work |
   | All failures blocked | 2 | `terminal_blocked` | All failing tests are blocked |

5. Print: `Total: {total}, Passed: {passed}, Failed: {failed}, Blocked: {blocked}`

```
EXIT STAGE: ticket.handler.check_status → {target} (exit_code: {N})
```

---

## State: implement

**Type:** claude
**Session:** start

```
ENTER STAGE: ticket.handler.implement
```

**Implement next failing test for ticket {ticket_id}:**

1. **Understand context:**
   - Use project-manager skill to understand ticket system
   - Read all docs in `docs/tickets/{ticket_id}`
   - Read `5-progress-and-issues.md` for current status

2. **Select test to implement:**
   - Read `tests-results.json`
   - Find FIRST test where:
     - `passes == false`
     - `blocked != true`
   - If no such test exists:
     - Output `{"no_work": true}`
     - Go to `check_status`

3. **Implement the feature:**
   - Write code to make the selected test pass
   - Follow patterns in `docs/0-patterns/`
   - Build if needed (use `builder` skill for desktop apps)

4. **Commit changes:**
   - Message format: `{ticket_id}: [brief description]`
   - Example: `T00001: Add user login validation`

5. **Update progress:**
   - Update `5-progress-and-issues.md` with:
     - What was implemented
     - Current test status
     - Any issues encountered

**Capture:** Save `current_test` for next state

**Output JSON:**
```json
{
  "current_test": "T0000N-XX",
  "description": "what was implemented",
  "files_modified": ["path", ...],
  "committed": true|false,
  "no_work": false
}
```

**Transition:**
- If `no_work == true` → `check_status`
- Else → `test`

```
EXIT STAGE: ticket.handler.implement → {target} (current_test: {id})
```

---

## State: test

**Type:** workflow (tester.workflow)

```
ENTER STAGE: ticket.handler.test → tester.workflow
```

**Execute tester workflow** with inputs:
- `ticket_id`: {ticket_id}
- `mode`: "single"
- `test_id`: {current_test}
- `working_dir`: {working_dir}

**Option 1:** Use `pmc-simulate-tester` skill to simulate step-by-step

**Option 2:** Execute tester workflow states directly:
1. `load_tests` - Filter to single test
2. `run_tests` - Execute test (use `run-tests` skill)
3. `verification_setup` - Prepare verification
4. `verify` - Verify test (use `verify-tests` skill)
5. `merge` - Merge results
6. `report` - Generate report

```
EXIT STAGE: ticket.handler.test → evaluate
```

---

## State: evaluate

**Type:** shell
**Script:** `evaluate.sh`

```
ENTER STAGE: ticket.handler.evaluate
```

**Execute this logic:**

1. Get current test ID: `{current_test}`

2. Read `tests-results.json`

3. Find test with matching ID:
   - If not found → EXIT code 3 → `terminal_error`

4. Evaluate result:

   **If test passed (`passes == true`):**
   ```python
   test['fail_count'] = 0
   test['blocked'] = False
   ```
   - Print: `PASSED: {current_test} - reset fail_count`
   - EXIT code 0 → `check_status`

   **If test failed (`passes == false`):**
   ```python
   fail_count = test.get('fail_count', 0) + 1
   test['fail_count'] = fail_count

   if fail_count >= 3:
       test['blocked'] = True
       # EXIT code 2 → check_status
   else:
       # EXIT code 1 → implement (retry)
   ```
   - Print: `FAILED: {current_test} - attempt {fail_count}/3` or `BLOCKED: {current_test} - failed {fail_count} times`

5. Write updated `tests-results.json`

**Decision table:**

| Condition | Exit Code | Target | Action |
|-----------|-----------|--------|--------|
| Test passed | 0 | `check_status` | Reset fail_count |
| Test failed, fail_count < 3 | 1 | `implement` | Retry implementation |
| Test failed, fail_count >= 3 | 2 | `check_status` | Mark blocked |
| Test not found | 3 | `terminal_error` | Error |

```
EXIT STAGE: ticket.handler.evaluate → {target} (exit_code: {N}, fail_count: {N})
```

---

## State: finalize

**Type:** claude
**Session:** continue

```
ENTER STAGE: ticket.handler.finalize
```

**Finalize ticket {ticket_id} - all tests passing:**

1. **Create `6-final.md`:**
   ```markdown
   # T0000N: [Title] - Final

   ## Summary
   [Brief description of what was implemented]

   ## Tests Passed
   - T0000N-01: [test description]
   - T0000N-02: [test description]
   ...

   ## Notes
   [Any important notes, gotchas, or follow-up items]
   ```

2. **Commit:**
   - Message: `{ticket_id}: Complete - all tests passing`

3. **Update `5-progress-and-issues.md`:**
   - Add COMPLETED status
   - Record completion timestamp
   - Final test count

**Output JSON:**
```json
{
  "status": "COMPLETED",
  "tests_passed": N,
  "summary": "brief description"
}
```

```
EXIT STAGE: ticket.handler.finalize → terminal_success
```

---

## Terminal States

```
ENTER STAGE: ticket.handler.terminal_success
  Status: success
  Message: "All tests passing - ticket complete"
EXIT STAGE: ticket.handler.terminal_success (handler complete)

ENTER STAGE: ticket.handler.terminal_blocked
  Status: blocked
  Message: "Some tests blocked after 3 consecutive failures"
EXIT STAGE: ticket.handler.terminal_blocked (handler blocked)

ENTER STAGE: ticket.handler.terminal_error
  Status: failure
  Message: "Ticket handler encountered an error"
EXIT STAGE: ticket.handler.terminal_error (handler failed)
```

---

## Implementation Loop Diagram

```
                    ┌─────────────────────────────────────┐
                    │                                     │
                    ▼                                     │
┌─────────┐    ┌────────────┐    ┌───────────┐    ┌──────┴─────┐
│  setup  │───▶│check_status│───▶│ implement │───▶│    test    │
└─────────┘    └────────────┘    └───────────┘    └────────────┘
                    │                   │                 │
                    │ all pass          │ no_work         │
                    ▼                   │                 ▼
               ┌──────────┐            │           ┌──────────┐
               │ finalize │◀───────────┘           │ evaluate │
               └──────────┘                        └──────────┘
                    │                                    │
                    │                         ┌──────────┼──────────┐
                    │                         │          │          │
                    ▼                    pass (0)   fail (1)   blocked (2)
               ┌─────────┐                    │          │          │
               │ SUCCESS │◀───────────────────┘          │          │
               └─────────┘                               │          │
                                             ┌───────────┘          │
                                             │                      │
                                             ▼                      │
                                        (retry implement)           │
                                                                    │
                    ┌─────────┐◀────────────────────────────────────┘
                    │ BLOCKED │
                    └─────────┘
```

---

## Example Simulation Output

```
=== TICKET HANDLER WORKFLOW SIMULATION ===
Context: ticket_id=T00001, working_dir=/project

ENTER STAGE: ticket.handler.setup
  Reading docs/tickets/T00001/
  Found: 1-definition.md
  Missing: 2-plan.md, 3-spec.md, 4-test-development.md, 5-progress-and-issues.md
  Creating missing docs using project-manager skill...
  Creating tests-definition.json with 5 tests
  Output: {
    "docs_present": ["1-definition.md"],
    "docs_created": ["2-plan.md", "3-spec.md", "4-test-development.md", "5-progress-and-issues.md"],
    "tests_exist": false,
    "tests_created": 5
  }
EXIT STAGE: ticket.handler.setup → check_status

ENTER STAGE: ticket.handler.check_status
  tests-results.json exists: NO (creating from definition)
  Analysis: Total=5, Passed=0, Failed=5, Blocked=0
  Status: 5 tests need work
EXIT STAGE: ticket.handler.check_status → implement (exit_code: 1)

ENTER STAGE: ticket.handler.implement
  Selected test: T00001-01 "User can open login page"
  Implementing feature...
  Files modified: src/pages/login.tsx, src/routes.ts
  Committed: T00001: Add login page route and component
  Updated 5-progress-and-issues.md
  Output: {
    "current_test": "T00001-01",
    "description": "Added login page route and basic component",
    "files_modified": ["src/pages/login.tsx", "src/routes.ts"],
    "committed": true,
    "no_work": false
  }
EXIT STAGE: ticket.handler.implement → test (current_test: T00001-01)

ENTER STAGE: ticket.handler.test → tester.workflow
  Executing tester workflow...
  [See pmc-simulate-tester for detailed steps]
  Test T00001-01 result: PASSED
EXIT STAGE: ticket.handler.test → evaluate

ENTER STAGE: ticket.handler.evaluate
  Test: T00001-01
  Result: passes=true
  Action: Reset fail_count to 0
EXIT STAGE: ticket.handler.evaluate → check_status (exit_code: 0, fail_count: 0)

ENTER STAGE: ticket.handler.check_status
  Analysis: Total=5, Passed=1, Failed=4, Blocked=0
  Status: 4 tests need work
EXIT STAGE: ticket.handler.check_status → implement (exit_code: 1)

[... loop continues until all tests pass or blocked ...]

ENTER STAGE: ticket.handler.check_status
  Analysis: Total=5, Passed=5, Failed=0, Blocked=0
  Status: All tests passing
EXIT STAGE: ticket.handler.check_status → finalize (exit_code: 0)

ENTER STAGE: ticket.handler.finalize
  Creating 6-final.md
  Committing: T00001: Complete - all tests passing
  Updating 5-progress-and-issues.md with COMPLETED status
  Output: {
    "status": "COMPLETED",
    "tests_passed": 5,
    "summary": "Implemented user authentication with login page"
  }
EXIT STAGE: ticket.handler.finalize → terminal_success

ENTER STAGE: ticket.handler.terminal_success
  Message: "All tests passing - ticket complete"
EXIT STAGE: ticket.handler.terminal_success (handler complete)
```

---

## Quick Reference

| State | Type | Exit Code → Target |
|-------|------|-------------------|
| setup | claude | default → check_status |
| check_status | shell | 0 → finalize, 1 → implement, 2 → terminal_blocked, 3 → terminal_error |
| implement | claude | no_work → check_status, else → test |
| test | workflow | default → evaluate |
| evaluate | shell | 0 → check_status, 1 → implement, 2 → check_status, 3 → terminal_error |
| finalize | claude | default → terminal_success |

## Ticket Documents Reference

| Document | Purpose | Created By |
|----------|---------|------------|
| `1-definition.md` | Requirements, acceptance criteria | User/PM |
| `2-plan.md` | Implementation approach | setup state |
| `3-spec.md` | Technical specification | setup state |
| `4-test-development.md` | Test strategy | setup state |
| `5-progress-and-issues.md` | Progress log | setup/implement states |
| `6-final.md` | Completion summary | finalize state |

## Related Skills

- `pmc-simulate-tester` - For detailed tester workflow simulation
- `run-tests` - Execute tests and record trajectory
- `verify-tests` - Verify tests by following trajectory
- `builder` - Build applications before testing
- `project-manager` - Ticket and document management
