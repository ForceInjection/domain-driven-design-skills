---
name: tdd-green
description: Execute the GREEN phase of TDD by implementing the minimum code needed to make the failing test pass. Follows the principle of simplest solution that could possibly work.
---

# TDD GREEN Phase

## Overview

This skill executes the GREEN phase of Test-Driven Development. It implements the minimum code necessary to make the currently failing test pass, following the principle of "the simplest thing that could possibly work."

## When to Use

Use this skill when:
- You have a failing test (RED phase completed)
- Ready to implement code to make the test pass
- Following the TDD RED → GREEN → REFACTOR cycle
- Need to turn a red test green

## Workflow

### Step 1: Verify RED Phase

**Confirm Prerequisites:**
1. Verify that a test is currently failing
2. Understand what the test expects
3. Confirm the test failure is for the right reason (missing functionality, not syntax errors)

### Step 2: Implement Minimum Code

**Write Just Enough Code:**
- Implement ONLY what's needed to make the test pass
- No extra features or "nice to have" additions
- No premature optimization
- Use the simplest solution that could possibly work
- Hard-code values if that's the simplest approach initially

**TDD Principles:**
- Start with the simplest implementation (even if naive)
- Don't anticipate future requirements
- Don't add functionality not covered by tests
- Fake it until tests force you to make it real
- Let the tests drive the design

### Step 3: Run All Tests

**Confirm GREEN Phase:**
1. Run ALL tests (excluding long-running tests)
2. Verify the new test now passes
3. Confirm all existing tests still pass
4. Check there are no compiler warnings or errors

**Handle Failures:**
- If tests fail, debug and fix the implementation
- Don't modify the test unless it's incorrect
- Keep iterating until all tests are green

### Step 4: Mark Progress

**Update PLAN.md:**
1. Mark the completed test with [x] in PLAN.md
2. Report success and test results
3. Prepare for REFACTOR phase or next cycle

## Important Reminders

- **DO NOT** add extra features not covered by tests
- **DO NOT** optimize prematurely
- **DO NOT** write more code than necessary
- Resist the urge to make the code "perfect" - that's for REFACTOR phase
- Simple, even naive, solutions are preferred over clever ones
- Let future tests drive you to better implementations

## Code Quality Guidelines

While implementing the minimum:
- Code should still be readable
- Variable names should be clear
- Basic good practices apply (but don't over-engineer)
- It's okay if code has duplication or smells - REFACTOR will fix that

## Next Steps

After completing GREEN phase:
1. All tests must be passing
2. Consider if REFACTOR is needed (code smells, duplication)
3. Move to REFACTOR phase if improvements are warranted
4. Or proceed to next RED phase for next test
