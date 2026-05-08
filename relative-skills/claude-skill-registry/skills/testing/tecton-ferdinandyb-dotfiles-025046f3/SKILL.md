---
name: tecton
description: >-
  Run Tecton plan and tests via Pants in the data-science repo.
  Handles long-running commands with proper output capture to avoid truncation.
---

# Tecton Operations Skill

## Critical: Output Handling for Long Commands

Tecton commands (especially `tecton-plan`) produce very long output that gets truncated.
**Always use temp file capture pattern:**

```bash
TMPFILE=$(mktemp)
PANTS_CONCURRENT=True pants tecton-plan --workspace=<workspace> --skip-tests 2>&1 | tee "$TMPFILE"; echo "EXIT_CODE: $?"
# Inspect results
tail -200 "$TMPFILE"
# If needed, inspect more or search for specific errors
rg "error|Error|ERROR" "$TMPFILE"
# Clean up when done
rm -f "$TMPFILE"
```

**Key points:**
- Use `tee` to capture output to temp file while still streaming
- Check exit code with `echo "EXIT_CODE: $?"`
- Use `tail` or `rg` to inspect the temp file as needed
- **Always clean up the temp file** when done with the operation

## Environment

- Set `PANTS_CONCURRENT=True` when running multiple pants invocations concurrently
- All commands must be run from the data-science repo root

## Workspaces for Testing

- **`checkoutandsale-v1-staging`**: Staging workspace - check against this first
- **`bence-dev`**: Personal dev workspace for clarifying issues if staging fails with confusing errors

If staging passes, no need to check against `bence-dev`. Use `bence-dev` only when staging errors are unclear.

## Operations

### tecton-plan

Runs `tecton plan` against a workspace. Use `--skip-tests` to speed up iteration.

```bash
# Plan against staging (check this first)
TMPFILE=$(mktemp)
PANTS_CONCURRENT=True pants tecton-plan --workspace=checkoutandsale-v1-staging --skip-tests 2>&1 | tee "$TMPFILE"; echo "EXIT_CODE: $?"
tail -200 "$TMPFILE"
rm -f "$TMPFILE"

# Plan against dev workspace (only if staging errors are unclear)
TMPFILE=$(mktemp)
PANTS_CONCURRENT=True pants tecton-plan --workspace=bence-dev --skip-tests 2>&1 | tee "$TMPFILE"; echo "EXIT_CODE: $?"
tail -200 "$TMPFILE"
rm -f "$TMPFILE"
```

### tecton-test-run

Run Tecton tests using the pants test goal with `--tecton-test-run` flag.

```bash
# Run all tecton tests in a directory
pants test --tecton-test-run projects/features/repos/sig_tecton/tests/sig_tecton/datasources/orders/::

# Run a specific test file
pants test --tecton-test-run projects/features/repos/sig_tecton/tests/sig_tecton/datasources/orders/test_orders_datasources.py

# Run a specific test function
pants test --tecton-test-run projects/features/repos/sig_tecton/tests/path/to/test_file.py -- -k test_function_name
```

For long test runs, use the same temp file capture pattern:

```bash
TMPFILE=$(mktemp)
pants test --tecton-test-run projects/features/repos/sig_tecton/tests/:: 2>&1 | tee "$TMPFILE"; echo "EXIT_CODE: $?"
tail -200 "$TMPFILE"
rm -f "$TMPFILE"
```
