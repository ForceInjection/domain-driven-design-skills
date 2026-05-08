---
name: Resolving Test Failures in Parallel
description: Specialized test resolution that works in parallel to fix specific test failures, enabling faster resolution of test suite issues through isolated fixes without conflicts. Use when multiple test failures need fixing, maximizing development velocity, or when the user mentions parallel test fixing or multiple test failures.
---

# Resolving Test Failures in Parallel

Fix specific test failures in parallel for faster test suite resolution.

## What you should do

**CRITICAL TEST INTEGRITY**: This workflow NEVER bypasses test failures to achieve user goals. Tests exist to improve code quality and prevent regressions—they are not obstacles to be removed when inconvenient. Only fix tests when intended behavior changes, never to accommodate bugs.

**CRITICAL CONSTRAINTS:**
- Fix ONLY the specific test failure assigned to you
- Do NOT make broad changes that could conflict with other parallel agents
- Focus on minimal, targeted fixes that restore test functionality
- Communicate completion status clearly for orchestration
- You MUST address the the issue directly
- NEVER bypass, override, or use other shortcuts unless the user give you EXPLICIT permission

**SPECIALIZATION:**
- Isolate and diagnose specific test failures
- Apply surgical fixes with minimal scope
- Validate fixes without affecting other tests
- Work efficiently within parallel execution constraints

When invoked with a specific test failure:

1. **Isolate the assigned test failure** – Run only the specific failing test to understand the exact issue without noise from other failures.

   ```bash
   [test-runner] path/to/test/file [specific-test-selector]
   ```

2. **Analyze failure root cause** – Examine the test output, stack trace, and error messages to identify the precise cause:
   - Implementation bug in source code
   - Outdated test assertions or expectations  
   - Mock/stub configuration issues
   - Data setup or teardown problems
   - Environment or dependency issues

3. **Determine fix scope** – Classify the required change:
   - **Source fix**: Minimal code change to fix implementation bug
   - **Test update**: Adjust test expectations, mocks, or setup
   - **Data fix**: Update test data or fixtures
   - **Configuration fix**: Adjust test environment or settings

4. **Apply targeted fix** – Make the minimal change required to fix the specific failure:
   - For source fixes: Change only the affected function/method
   - For test updates: Modify only the failing test's assertions or setup
   - Avoid refactoring or broader changes that could affect other tests

5. **Validate the specific fix** – Re-run the isolated test to confirm resolution:

   ```bash
   [test-runner] path/to/test/file [specific-test-selector]
   ```

6. **Check for immediate regressions** – Run related tests in the same file/module to ensure no immediate conflicts:

   ```bash
   [test-runner] path/to/test/file
   ```

7. **Report completion** – Provide clear status for orchestration:
   - Test failure name/identifier
   - Fix applied (source/test/data/config)
   - Files modified with line numbers
   - Validation status (pass/fail)
   - Any warnings about potential broader impacts

**PARALLEL EXECUTION GUIDELINES:**

- **File-level isolation**: Prefer working on different test files than other agents
- **Function-level precision**: When working on the same file, target different functions/methods
- **Minimal change principle**: Make the smallest possible fix to resolve the failure
- **No shared state changes**: Avoid modifying global configurations, shared utilities, or common test helpers
- **Clear communication**: Report exactly what was changed for conflict detection

**ANTI-PATTERNS TO AVOID:**

- ❌ Refactoring code beyond the immediate fix
- ❌ Updating shared test utilities or helpers  
- ❌ Making style or formatting changes
- ❌ Fixing multiple unrelated test failures
- ❌ Broad architectural changes
- ❌ Updating package dependencies

**SUCCESS METRICS:**

- Specific test failure resolved with minimal changes
- No new test failures introduced in the same module
- Clear documentation of changes made
- Fast execution time (typically < 5 minutes per failure)
- High success rate when working in parallel with other agents

The orchestrating agent should spawn multiple instances of this workflow to handle different test failures simultaneously, dramatically reducing the time required for test suite resolution and removing the primary bottleneck in development velocity.