---
name: phoenix-truth-case-orchestrator
description:
  'End-to-end truth-case orchestration for the Phoenix VC fund-modeling
  platform. Use when running tests/truth-cases/runner.test.ts, computing
  module-level pass rates, updating docs/phase0-validation-report.md and
  docs/failure-triage.md, or deciding between Phase 1A/1B/1C.'
---

# Phoenix Truth-Case Orchestrator

You coordinate all truth-case work for the Phoenix VC fund model. The Phoenix
Execution Plan defines 6 calculation modules and 119 truth-case scenarios; treat
those JSON files plus the production code as the joint spec.

## When to Use

Invoke this skill when:

- Running or modifying `tests/truth-cases/runner.test.ts`
- Updating module-level pass rates or Phase 0 / Phase 1A reports
- Classifying failures as CODE BUG / TRUTH CASE ERROR / MISSING FEATURE
- Making path decisions (Phase 1A vs 1B vs 1C) based on gate thresholds

Do **not** use this skill for:

- Fixing calculation precision (use `phoenix-precision-guard`)
- Changing core waterfall semantics (use `phoenix-waterfall-ledger-semantics`)

## Files You Own

- Truth-case JSONs:
  - `docs/xirr.truth-cases.json`
  - `docs/waterfall-tier.truth-cases.json`
  - `docs/waterfall-ledger.truth-cases.json`
  - `docs/fees.truth-cases.json`
  - `docs/capital-allocation.truth-cases.json`
  - `docs/exit-recycling.truth-cases.json`
- Runner + helpers:
  - `tests/truth-cases/runner.test.ts` (build via `/dev` if missing)
  - `tests/truth-cases/validation-helpers.ts` (build via `/dev` if missing)
- Reports:
  - `docs/phase0-validation-report.md`
  - `docs/failure-triage.md` (create if missing)

## Core Workflow

### 1. Run the Truth-Case Suite

Preferred:

```bash
/test-smart truth-cases
```

Fallback:

```bash
npm test -- tests/truth-cases/runner.test.ts --run --reporter=verbose
```

Capture:

- Per-module pass/fail counts
- Overall pass rate
- List of failing scenarios and error messages

### 2. Compute Module-Level Pass Rates

For each module:

- Count scenarios from the corresponding `docs/*.truth-cases.json`
- Count passing vs failing tests from the runner output
- Update the **Module-Level Pass Rates** table in
  `docs/phase0-validation-report.md` with:
  - `X / Total (Y%)`
  - PASS/FAIL relative to 1A/1B/1C thresholds
  - Recommended path per module

### 3. Classify Failures

For every failing scenario:

1. Read the error message
2. Inspect the production code implementing that module
3. Inspect the truth-case JSON

Classify each as:

- `CODE BUG`
- `TRUTH CASE ERROR`
- `MISSING FEATURE`

Record each scenario under the appropriate heading in `docs/failure-triage.md`.

### 4. Fix Truth-Case Errors First

If you determine a `TRUTH CASE ERROR`:

- Fix the JSON
- Re-run only that scenario:

  ```bash
  npm test -- tests/truth-cases/runner.test.ts -t "<scenario-name>"
  ```

- Confirm it passes and doesn't break other scenarios

Only after JSON is correct should you propose code changes.

### 5. Apply Gate Logic for Phase Routing

Using the thresholds defined in the Phoenix Execution Plan, decide:

- Phase 1A (cleanup), 1B (bug fix), or 1C (rebuild)

Update `docs/phase0-validation-report.md` with:

- Module-level pass rates
- Overall test pass rate
- Chosen path (1A/1B/1C) and rationale

## Numeric & Structural Semantics

When working in `validation-helpers.ts` or the runner:

- Use `toBeCloseTo(expected, 6)` for all numeric comparisons
- Ignore `notes` fields in expected JSON
- Treat `null` in expected `gpClawback` as "expect `undefined` in code"
- For min/max ranges (e.g., recycled_min/max), assert:
  - `actual >= min`
  - `actual <= max`
- Support both:
  - Aggregate `totals`
  - Row-level assertions (e.g., ledger rows)

## Invariants

- Never reduce the overall truth-case pass rate without explanation
- Never change truth-case semantics silently: update both JSON and docs
- Always re-run the truth-case suite after modifying code or JSON
