---
name: e2e-test-runner
description: Runs and debugs Detox E2E tests for MigraineTracker React Native app. Use when the user asks to run E2E tests, debug test failures, or investigate UI test issues. Automatically captures logs, analyzes screenshots, and diagnoses common failure patterns. Kills tests early on first failure to save time.
---

# E2E Test Runner and Debugger

## Overview

Specialized skill for running, monitoring, and debugging Detox E2E tests in the MigraineTracker React Native application. Automatically captures diagnostics, analyzes failures, and provides solutions based on known patterns.

## When to Use This Skill

Invoke this skill when:
- User asks to run E2E tests or UI tests
- User mentions "test:ui", "detox", or E2E testing
- E2E tests are failing and need debugging
- User asks to investigate test failures
- User mentions screenshots, test artifacts, or test logs

## Core Workflow

### Step 1: Run Tests with Diagnostics

**IMPORTANT: Always capture output and kill tests early on first failure**

```bash
cd /Users/vfilby/Projects/MigraineTracker/app

# Run with output capture and monitoring
npm run test:ui -- e2e/specificTest.test.js 2>&1 | tee /tmp/e2e-test-output.log &
TEST_PID=$!

# Monitor for errors in real-time (in background)
tail -f /tmp/e2e-test-output.log | grep --line-buffered -E "FAIL|Error|Failed|constraint" &
MONITOR_PID=$!

# Wait for test or manually kill when first error appears
wait $TEST_PID
TEST_EXIT_CODE=$?

# Clean up monitoring
kill $MONITOR_PID 2>/dev/null || true
```

**Key principle**: Don't wait for all tests to complete if you see an error. Kill early and investigate immediately.

### Step 2: Find Most Recent Test Artifacts

```bash
# Locate the most recent test run directory
LATEST_ARTIFACTS=$(ls -td app/e2e/artifacts/ios.sim.debug.* 2>/dev/null | head -1)
echo "Latest artifacts: $LATEST_ARTIFACTS"

# List failed tests
ls "$LATEST_ARTIFACTS" | grep "✗"
```

### Step 3: Check Multiple Log Sources

**Critical: Check ALL of these sources in order:**

#### A. Captured Console Output
```bash
# Search for full error messages
grep -A 20 "Failed\|Error code\|constraint" /tmp/e2e-test-output.log

# Look for TestHelpers errors (database reset issues)
grep -B 5 -A 10 "TestHelpers" /tmp/e2e-test-output.log

# Look for specific patterns
grep -E "NOT NULL|foreign key|UNIQUE constraint" /tmp/e2e-test-output.log
```

#### B. Detox Log Artifacts
```bash
# Find log files in artifacts (enabled in .detoxrc.js)
find "$LATEST_ARTIFACTS" -name "*.log" -o -name "*device*"

# Read device logs for failed tests
FAILED_TEST=$(ls "$LATEST_ARTIFACTS" | grep "✗" | head -1)
cat "$LATEST_ARTIFACTS/$FAILED_TEST"/*.log 2>/dev/null
```

#### C. Screenshots (Visual Analysis)
```bash
# Find failure screenshots
find "$LATEST_ARTIFACTS" -name "*Failure*.png" -o -name "testFnFailure.png"

# Use Read tool to visually analyze screenshots
# Look for: Error toasts, wrong screens, missing UI elements
```

#### D. Live Simulator Logs (if needed)
```bash
# Get current simulator ID
SIMULATOR_ID=$(xcrun simctl list devices | grep "Booted" | grep -oE '[A-F0-9-]{36}' | head -1)

# Stream live logs
xcrun simctl spawn "$SIMULATOR_ID" log stream \
  --predicate 'eventMessage contains "TestHelpers" OR eventMessage contains "Error"' \
  --level debug \
  2>&1 | tee /tmp/simulator-logs.txt
```

### Step 4: Analyze Failure Patterns

After collecting logs and screenshots, identify the failure pattern. See `references/known-issues.md` for common patterns and solutions.

**Common patterns to look for:**
1. Database constraint errors (NOT NULL, foreign key, UNIQUE)
2. Missing test fixtures ("Test Topiramate" not found)
3. Database reset failures
4. Navigation issues (wrong screen)
5. Timeout waiting for UI elements

### Step 5: Kill Tests Early

**Don't wait for all tests to finish if you found the error!**

```bash
# Kill the test process immediately
pkill -f "jest.*e2e"

# Or if you have the PID
kill $TEST_PID
```

This saves time and gives you the error logs faster.

### Step 6: Implement Fix and Verify

After identifying the root cause:
1. Implement the fix
2. Run ONLY the failing test to verify
3. If fixed, run full test suite

```bash
# Run single test
npm run test:ui -- e2e/specificTest.test.js

# If passing, run full suite
npm run test:ui
```

## Debugging Checklist

When debugging a test failure, systematically check:

- [ ] Read captured console output (`/tmp/e2e-test-output.log`)
- [ ] Check Detox artifact logs (`.log` files in artifacts directory)
- [ ] Visually analyze failure screenshots (Read tool)
- [ ] Search for error patterns (constraint, foreign key, etc.)
- [ ] Check if test fixtures loaded correctly
- [ ] Verify database reset completed successfully
- [ ] Compare with known issues in `references/known-issues.md`

## Key Detox Commands

```bash
# Run all E2E tests
npm run test:ui

# Run specific test file
npm run test:ui -- e2e/medicationTracking.test.js

# Rebuild app and run tests (if native changes)
npm run test:ui:rebuild

# List available simulators
xcrun simctl list devices | grep iPhone

# Take manual screenshot
xcrun simctl io booted screenshot /tmp/debug-screenshot.png

# Get simulator logs
xcrun simctl spawn booted log collect --output /tmp/sim.logarchive
log show /tmp/sim.logarchive | grep -i error
```

## Important Project Context

### Test Infrastructure
- **Framework**: Detox for E2E testing
- **Device**: iPhone 16 Pro Max simulator (primary)
- **Test Location**: `app/e2e/*.test.js`
- **Artifacts**: `app/e2e/artifacts/ios.sim.debug.*`
- **Deep Links**: Tests use `migraine-tracker://test/*` for database control

### Database Reset Mechanism
Tests reset the database via deep links:
```javascript
// In test helpers
await device.openURL({
  url: 'migraine-tracker://test/reset?token=detox&fixtures=true'
});
```

This is handled by `src/utils/testDeepLinks.ts` which calls `src/utils/testHelpers.ts`.

### Common Test Fixtures
- Test Topiramate (preventative medication)
- Test Ibuprofen (rescue medication)
- Medication schedules with specific times
- Past episodes for history testing

## Output Format

When reporting test results:

**If tests pass:**
```
✅ All E2E tests passed
- Test file: [name]
- Duration: [time]
- Tests: [count] passed
```

**If tests fail:**
```
❌ E2E tests failed

Root Cause: [specific error identified]
Location: [file:line or component]

Evidence:
- Console: [relevant log excerpt]
- Screenshot: [what the screenshot shows]

Recommended Fix: [specific code change needed]
```

## Best Practices

1. **Always capture console output** - errors might only appear there
2. **Kill tests early** - don't waste time on subsequent failures
3. **Read screenshots visually** - use Read tool to see UI state
4. **Check multiple log sources** - console, artifacts, simulator
5. **Look for root cause** - don't fix symptoms
6. **Verify fixes with single test** - before running full suite
7. **Check known issues first** - many patterns repeat

## Related Files

- `.detoxrc.js` - Detox configuration (artifacts, devices)
- `e2e/helpers.js` - Test helper functions
- `src/utils/testHelpers.ts` - Database reset and fixtures
- `src/utils/testDeepLinks.ts` - Deep link handlers for testing
- `references/known-issues.md` - Common failure patterns
