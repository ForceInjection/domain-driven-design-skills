---
name: tdd-red
description: Execute the RED phase of TDD by writing a failing test for the next unmarked item in PLAN.md. Writes tests with Korean descriptions and confirms test failure.
---

# TDD RED Phase

## Overview

This skill executes the RED phase of Test-Driven Development. It finds the next unmarked test in PLAN.md, writes a failing test that describes the desired behavior, and confirms the test fails as expected.

## When to Use

Use this skill when:
- Starting a new TDD cycle
- Ready to write the next failing test
- Following the TDD RED → GREEN → REFACTOR cycle
- Implementing a feature listed in PLAN.md

## Workflow

### Step 1: Locate Next Test

**Find the Test:**
1. Read PLAN.md to find the next unmarked test (without [x] or [ ])
2. If PLAN.md doesn't exist or is empty, ask the user what test to write
3. Understand the behavior being tested

**Mark the Test:**
- Mark the test with [ ] in PLAN.md to indicate it's in progress

### Step 2: Write the Failing Test

**Test Characteristics:**
- Has a clear, descriptive name that describes the behavior
- Uses Korean (ko-KR) for test descriptions as specified in LANG.md
- Tests only ONE small increment of functionality
- Will fail because the feature isn't implemented yet
- Uses meaningful assertions that clearly show expected vs actual

**Follow TDD Principles:**
- Write the SIMPLEST test that will fail
- Don't write production code yet
- Focus on defining the desired behavior
- Make the test expressive and easy to understand

### Step 3: Confirm RED Phase

**Run the Test:**
1. Execute the test suite (excluding long-running tests)
2. Confirm the new test fails for the RIGHT reason
3. Verify all other existing tests still pass
4. Check there are no compilation errors or warnings

**Report Results:**
- Show the failing test output
- Confirm we are in RED phase
- Prepare to move to GREEN phase

## Important Reminders

- **DO NOT** implement any production code in this phase
- **DO NOT** make existing tests pass - only write new failing test
- **ONLY** write ONE test at a time
- The test should fail because functionality is missing, not due to syntax errors
- Test name should clearly communicate what behavior is being tested

## Next Steps

After completing RED phase:
1. Verify the test fails for the expected reason
2. Move to GREEN phase to implement minimum code
3. Do not skip directly to implementation - follow the cycle
