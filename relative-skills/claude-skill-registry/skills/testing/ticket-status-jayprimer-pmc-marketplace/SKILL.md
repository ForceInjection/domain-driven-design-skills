---
name: ticket-status
description: |
  Programmatic verification of KB state: tickets, phases, tests, integrity.
  Provides scripts for automated checking at each workflow stage.

  SCRIPTS:
  - check_ticket.py: Ticket docs, tests, final status → next step
  - check_phase.py: Phase progress, all tickets complete?
  - check_tests.py: Trajectory, RED verification, coverage vs spec
  - check_integrity.py: Index.md matches dirs, roadmap has all active items

  Use when:
  - Checking ticket/phase completion
  - Validating before commit/archive
  - CI/CD automation
  - User says "status", "check", "verify"
---

# Ticket Status

Programmatic verification scripts for KB workflow.

## Prerequisites

**ALWAYS run /pmc:kb first** to understand ticket structure and TDD workflow.

## Scripts Overview

| Script | Purpose | Use When |
|--------|---------|----------|
| `check_ticket.py` | Ticket docs + tests + status | Per-ticket verification |
| `check_phase.py` | Phase progress + all tickets | Before phase archive |
| `check_tests.py` | Trajectory + RED + coverage | After TDD cycle |
| `check_integrity.py` | Index + roadmap consistency | Before commit |

---

## check_ticket.py

Check individual ticket completion status.

```bash
python scripts/check_ticket.py T00001
python scripts/check_ticket.py T00001 --json
```

## Status Flow

```
missing-docs → needs-spec → needs-tests → red-phase → needs-impl → needs-final → complete
                                              ↓              ↓
                                        tests-blocked   tests-failing
                                              ↓              ↓
                                           blocked      (retry impl)
```

## Next Step Indicators

| Step | Meaning | Action |
|------|---------|--------|
| `missing-docs` | Required docs missing | Create 1-definition.md, 2-plan.md, 3-spec.md |
| `needs-spec` | 3-spec.md empty | Write test specification |
| `needs-tests` | No tests.json | Create tests.json from 3-spec.md |
| `red-phase` | Tests not RED verified | Run tests, verify they fail, set red_verified |
| `needs-impl` | RED done, needs code | Implement to make tests pass |
| `tests-failing` | Implementation incomplete | Fix code until tests pass |
| `tests-blocked` | Tests need human input | Resolve blocked_reason |
| `needs-final` | Tests pass, no 5-final.md | Create 5-final.md with Status: COMPLETE |
| `blocked` | Marked BLOCKED | Resolve blocker or escalate |
| `complete` | All done | Archive ticket |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Complete |
| 1 | In progress (needs work) |
| 2 | Blocked |

## Document Checks

Required documents (must exist):
- `1-definition.md` - What: scope, success criteria
- `2-plan.md` - How: steps, decisions
- `3-spec.md` - TDD: test cases, edge cases

Optional documents:
- `4-progress.md` - Log: TDD cycles, notes (created during work)
- `5-final.md` - Done: status, learnings (required for completion)

## Test Checks

For TDD tickets (default), verifies:
1. `tests.json` exists in `.pmc/docs/tests/tickets/T0000N/`
2. Tests have `red_verified` timestamp (RED phase done)
3. All `required: true` tests have `status: passed`
4. No tests have `status: blocked`

## Example Output

```
# Ticket Status: T00001

## Documents

| Document | Exists | Content |
|----------|--------|---------|
| 1-definition.md | OK | OK |
| 2-plan.md | OK | OK |
| 3-spec.md | OK | OK |
| 4-progress.md | OK | OK |
| 5-final.md | MISSING | - |

## TDD: enabled

## Tests

Total: 3 | Passed: 2 | Failed: 1 | Blocked: 0 | Pending: 0
Required: 2/2 passed
RED verified: all

| Test | Status | Required | RED |
|------|--------|----------|-----|
| T00001-01 | passed | yes | OK |
| T00001-02 | passed | yes | OK |
| T00001-03 | failed | no | OK |

## Status

5-final.md: not set

## Next Step

**FIX TESTS**
Failing tests: T00001-03
```

## JSON Output

```json
{
  "ticket_id": "T00001",
  "exists": true,
  "docs": {
    "1-definition.md": {"exists": true, "has_content": true},
    "2-plan.md": {"exists": true, "has_content": true},
    "3-spec.md": {"exists": true, "has_content": true},
    "4-progress.md": {"exists": true, "has_content": true},
    "5-final.md": {"exists": false, "has_content": false}
  },
  "final_status": null,
  "tests": {
    "exists": true,
    "total": 3,
    "passed": 2,
    "failed": 1,
    "blocked": 0,
    "pending": 0,
    "required_passed": 2,
    "required_total": 2,
    "all_red_verified": true
  },
  "next_step": "tests-failing",
  "next_step_detail": "Failing tests: T00001-03",
  "tdd_enabled": true
}
```

## TDD Opt-Out

Tickets with `TDD: no` in 1-definition.md skip test checks:
- No tests.json required
- Goes directly: docs → needs-final → complete

## Integration

### CI/CD Usage

```bash
# Check all active tickets
for dir in .pmc/docs/tickets/T*/; do
  ticket=$(basename "$dir")
  python scripts/check_ticket.py "$ticket" --json
done

# Fail CI if ticket not complete
python scripts/check_ticket.py T00001
if [ $? -ne 0 ]; then
  echo "Ticket not complete"
  exit 1
fi
```

### Workflow Integration

Before archiving a ticket:
```bash
python scripts/check_ticket.py T00001
# Only archive if exit code is 0
```

---

## check_phase.py

Check phase completion - all tickets in phase done?

```bash
python scripts/check_phase.py 1
python scripts/check_phase.py 1 --json
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Phase complete |
| 1 | In progress |
| 2 | Has blocked tickets |
| 3 | Phase not found |

### Example Output

```
# Phase 1 Status

**Goal:** Implement user authentication

Progress: [████████████░░░░░░░░] 60%

## Summary

| Status | Count |
|--------|-------|
| Complete | 3 |
| Blocked | 0 |
| In Progress | 2 |
| **Total** | **5** |

## Next Step

**2 ticket(s) remaining - next: T00004**
```

---

## check_tests.py

Detailed test verification: trajectory, RED markers, coverage.

```bash
python scripts/check_tests.py T00001
python scripts/check_tests.py T00001 --json
```

### Checks Performed

- tests.json exists and valid
- Each test has `red_verified` timestamp
- Passed tests have trajectory with [RED] and [GREEN] markers
- Coverage: tests vs 3-spec.md test cases

### Example Output

```
# Test Status: T00001

## Summary

| Metric | Value |
|--------|-------|
| Total tests | 4 |
| Passed | 3 |
| Failed | 1 |
| RED verified | incomplete |
| Trajectories | incomplete |

## Tests

| ID | Name | Status | RED | Trajectory | Issues |
|----|------|--------|-----|------------|--------|
| T00001-01 | Login flow | passed | + | 12 | - |
| T00001-02 | Logout flow | passed | + | 8 | - |
| T00001-03 | Session timeout | failed | x | none | Missing RED |
| T00001-04 | Remember me | passed | + | 5 | - |

## Coverage vs 3-spec.md

Coverage: 75%

| Spec Case | Covered | Test |
|-----------|---------|------|
| login_valid | + | T00001-01 |
| login_invalid | + | T00001-01 |
| session_timeout | x | - |
| remember_me | + | T00001-04 |

## Next Step

**Run RED phase for tests missing red_verified**
```

---

## check_integrity.py

Verify KB consistency: indexes match directories, roadmap has all active items.

```bash
python scripts/check_integrity.py
python scripts/check_integrity.py --json
```

### Checks Performed

- All ticket directories have entry in `tickets/index.md`
- All active tickets are in `roadmap.md`
- No archived items still in roadmap (stale references)

### Example Output

```
# KB Integrity Check

## Summary

| Type | Active | Archived | In Index | In Roadmap |
|------|--------|----------|----------|------------|
| Tickets | 5 | 12 | 5 | 4 |

## Issues Found

| Type | Item | Detail |
|------|------|--------|
| missing_roadmap | T00021 | T00021 is active but not in roadmap.md |

## Result

**INVALID** - 1 issues found
```

---

## Verification Checkpoints

Use these scripts at each workflow stage:

| Stage | Script | Check |
|-------|--------|-------|
| After PLAN | `check_integrity.py` | Ticket in index + roadmap |
| After create tests.json | `check_tests.py` | Tests defined |
| After RED phase | `check_tests.py` | red_verified set |
| After GREEN phase | `check_tests.py` | Trajectory complete |
| Before 5-final.md | `check_ticket.py` | All tests pass |
| Before archive | `check_ticket.py` | Status: COMPLETE |
| Before phase archive | `check_phase.py` | All tickets complete |
| Before commit | `check_integrity.py` | Index + roadmap valid |

---

## All Scripts Usage

```bash
# Full verification sequence
python scripts/check_integrity.py           # KB consistent?
python scripts/check_ticket.py T00001       # Ticket status?
python scripts/check_tests.py T00001        # Tests valid?
python scripts/check_phase.py 1             # Phase done?

# JSON for automation
python scripts/check_ticket.py T00001 --json | jq '.next_step'
python scripts/check_phase.py 1 --json | jq '.phase_complete'
```
