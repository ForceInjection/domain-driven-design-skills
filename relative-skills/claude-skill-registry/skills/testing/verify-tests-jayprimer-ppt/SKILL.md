---
name: verify-tests
description: Verify tests by following recorded trajectories in tests-in-verification.json. Use this skill during the verify stage to independently confirm test results by re-executing recorded steps.
---

# Verify Tests

## Reference Documentation

For test definition format and writing good steps, see [references/test-definitions.md](references/test-definitions.md).

Independently verify tests by following recorded trajectories in `tests-in-verification.json`.

## Context

This skill is part of the test execution pipeline:

```
tests-definition.json (READ-ONLY)
        |
        | load-tests.sh
        v
tests-in-progress.json (run_tests stage)
        |
        | verification-setup.sh (reset verified/passes/blocked, keep trajectory)
        v
tests-in-verification.json  <-- YOU ARE HERE (verify stage)
        |
        | merge-results.sh
        v
tests-results.json (final)
```

## Input File

**Location:** `docs/3-tests/tickets/{ticket_id}/tests-in-verification.json`

This file is created by `verification-setup.sh` from `tests-in-progress.json`:
- `trajectory` is **preserved** (what was done in run_tests)
- `verified`, `passes`, `blocked` are **reset to false**

### Input Format

```json
{
  "ticket": "T00015",
  "title": "Feature Implementation Tests",
  "tests": [
    {
      "id": "T00015-01",
      "name": "Feature works end-to-end",
      "description": "Verify feature implementation",
      "ticket-completion": true,
      "steps": [
        {
          "step": "Run 'uv sync' exits with code 0",
          "trajectory": [
            "Ran: uv sync",
            "Output: Resolved 15 packages...",
            "Exit code: 0 - MATCHES"
          ],
          "verified": false
        }
      ],
      "passes": false,
      "blocked": false
    }
  ]
}
```

## Your Task

For each test in `tests-in-verification.json`:

1. **Read trajectory** - Understand what was done in run_tests stage
2. **Re-execute** - Follow the same steps recorded in trajectory
3. **Confirm outcomes** - Verify results match expectations
4. **Set verified** - `true` only if outcome matches expectation
5. **Set passes** - `true` only if ALL steps have `verified: true`
6. **Set blocked** - `true` if blocking issue encountered

## Verification Process

### Step 1: Check for Test Scripts

Look for scripts referenced in trajectory:

```
Example trajectory: "Ran: python docs/3-tests/tickets/T00015/test_executor.py"
                                    |
                                    v
Action: Read test_executor.py, verify it tests the step, re-run it
```

### Step 2: Review Script Coverage

If script exists:
1. Read the script
2. Verify it covers the step as described
3. Re-run the script
4. Confirm output matches trajectory

### Step 3: Re-Execute and Confirm

For each step, follow the trajectory and verify:

**Script-based verification:**
```json
{
  "step": "Import ExecutorRegistry and check has('workflow')",
  "trajectory": [
    "Ran: python -c 'from pmc.executors import ExecutorRegistry; print(ExecutorRegistry.has(\"workflow\"))'",
    "Output: True"
  ],
  "verified": false
}
```

Action:
1. Run the same command from trajectory
2. Verify output is `True`
3. Set `verified: true` if matches

**Manual verification:**
```json
{
  "step": "Config file exists at ~/.config/app/settings.json",
  "trajectory": [
    "Checked: ~/.config/app/settings.json exists",
    "File found with 245 bytes - MATCHES"
  ],
  "verified": false
}
```

Action:
1. Check file exists
2. Verify it matches expectation
3. Set `verified: true` if matches

### Step 4: Handle Missing Scripts

If script is referenced but missing:
- Execute step manually following trajectory
- Or set `verified: false` with note in trajectory

## Strict Verification Rules

**Set `verified: true` ONLY when:**
- Re-execution produces **same outcome** as trajectory
- Outcome **exactly** meets step expectation
- You have **concrete evidence**

**Keep `verified: false` when:**
- Re-execution produces different result
- Cannot reproduce the trajectory
- Script missing or doesn't cover the step
- Uncertain or ambiguous outcome

### Examples

| Trajectory Says | Re-execution Result | verified |
|-----------------|---------------------|----------|
| `"Exit code: 0"` | Exit code 0 | `true` |
| `"Exit code: 0"` | Exit code 1 | `false` |
| `"Output: True"` | Output: True | `true` |
| `"Output: True"` | Output: False | `false` |
| `"File found"` | File exists | `true` |
| `"File found"` | File not found | `false` |

## Blocking Issues

If verification encounters blocking issues:

1. Set `blocked: true` on the test
2. Append to trajectory with verification context

```json
{
  "id": "T00015-03",
  "description": "Verify external API integration",
  "ticket-completion": true,
  "steps": [
    {
      "step": "POST /api/payment returns 200",
      "trajectory": [
        "Ran: python test_payment.py",
        "BLOCKING ISSUE: Payment API requires STRIPE_API_KEY",
        "VERIFICATION: Still blocked - STRIPE_API_KEY not set"
      ],
      "verified": false
    }
  ],
  "passes": false,
  "blocked": true
}
```

## Output Format

After verification, update `tests-in-verification.json`:

```json
{
  "ticket": "T00015",
  "title": "Feature Implementation Tests",
  "tests": [
    {
      "id": "T00015-01",
      "name": "Feature works end-to-end",
      "description": "Verify feature implementation",
      "ticket-completion": true,
      "steps": [
        {
          "step": "Run 'uv sync' exits with code 0",
          "trajectory": [
            "Ran: uv sync",
            "Output: Resolved 15 packages...",
            "Exit code: 0 - MATCHES",
            "VERIFIED: Re-ran uv sync, exit code 0 - CONFIRMED"
          ],
          "verified": true
        }
      ],
      "passes": true,
      "blocked": false
    }
  ]
}
```

## Workflow

1. **Read** `tests-in-verification.json` for given ticket
2. **For each test:**
   - Read trajectory from run_tests stage
   - Re-execute following trajectory
   - Confirm outcomes match
   - Update verified, passes, blocked
3. **Save** updated `tests-in-verification.json`
4. **Return** summary

## Return Summary

After completion, return:

```
Verify Tests Complete: T00015
- Verified: 5 tests
- Confirmed: 4
- Failed verification: 1
- Blocked: 0
```

## Visual Verification

For UI tests, re-capture screenshots and compare:

- **Desktop:** Use `screenshot-capture` skill or debug endpoint
- **Web:** Use `mcp chrome-devtools take_screenshot`

Compare with observations in trajectory.

## Key Differences from run-tests

| Aspect | run-tests | verify-tests |
|--------|-----------|--------------|
| Input file | tests-in-progress.json | tests-in-verification.json |
| Trajectory | Create new | Follow existing |
| Purpose | Execute and record | Confirm by re-execution |
| Evidence | Generate | Validate against recorded |
