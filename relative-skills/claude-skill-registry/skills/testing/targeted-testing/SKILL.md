---
name: targeted-testing
description: Pick and run the smallest correct validation step (checks → focused Jest by path → broader suites). Use whenever you modify code and need confidence quickly.
---

# Targeted Testing

## Scope

- Select the smallest test/check that proves the change
- Prevent slow, flaky, or irrelevant test runs
- Capture evidence in session notes

## Inputs

- Files changed
- Whether the change is UI server / CLI / DB adapter / crawler
- Existing check scripts near the code

## Procedure

1. Prefer a local check script first (fast, deterministic, exits cleanly).
2. Then run the smallest Jest suite by path.
3. Only then widen to broader suites if needed.
4. Record the exact commands and outcomes in `WORKING_NOTES.md`.

If you need browser semantics but don’t want full Jest E2E yet, prefer the single-browser scenario runner:

- `node tools/dev/ui-scenario-suite.js --suite=scripts/ui/scenarios/<suite>.suite.js --scenario=001 --print-logs-on-failure`

## Validation

- Official Jest invocation rule (repo policy): use `npm run test:by-path <file>`.

## Escalation / Research request

Ask for dedicated research if:

- there is no obvious “smallest check” and you need a new check harness
- the feature spans multiple systems and you need a validation ladder proposal

## References

- Testing quick reference: `docs/TESTING_QUICK_REFERENCE.md`
- Validation ladder guidance: `AGENTS.md`
