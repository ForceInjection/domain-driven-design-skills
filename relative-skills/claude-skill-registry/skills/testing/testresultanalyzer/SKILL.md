---
name: test.result.analyzer
description: Parse ctest and sanitizer output, summarize failures, identify root causes, and track test coverage for Orpheus SDK builds.
---

# Test Result Analyzer

## Purpose

The Test Result Analyzer skill parses test output from ctest, Google Test, and sanitizers (ASan, TSan, UBSan) to provide actionable summaries of test failures and quality issues. This skill helps maintain Orpheus SDK's 98%+ test coverage standard and ensures sanitizer-clean builds.

**Core Capabilities:**

- Parse ctest and Google Test output
- Extract sanitizer error reports (AddressSanitizer, ThreadSanitizer, UBSan)
- Identify failing tests by module
- Suggest likely root causes
- Track coverage trends
- Generate concise failure summaries

## When to Use

**Trigger Patterns:**

- After running `ctest` or test suites
- CI/CD test failures
- Debugging test regressions
- Coverage analysis requests
- Keywords: "test", "ctest", "sanitizer", "ASan", "TSan", "UBSan", "coverage", "failures"
- File patterns: `Testing/Temporary/LastTest.log`, `build/test_output.txt`

**Do NOT Use When:**

- Analyzing production logs (not test output)
- Performance profiling (use profilers, not test output)
- Real-time safety auditing (use `rt.safety.auditor`)

**Use Alternative Skills:**

- For real-time violations → `rt.safety.auditor`
- For documentation → `orpheus.doc.gen`
- For CI troubleshooting → `ci.troubleshooter`

## Allowed Tools

- `read_file` - Read test output logs and reports
- `bash` - Run commands to extract test results (e.g., `ctest --output-on-failure`)
- `python` - Parse structured test output (JSON, XML, text logs)

**Access Level:** 1 (Local Execution - read + command execution)

**Rationale:**

- Read test logs from build directory
- Execute ctest/test commands to generate output
- Parse output with Python for structured analysis
- No file modification needed (read-only analysis)

**Explicitly Denied:**

- `write_file` - Analysis only, don't modify test files
- Network tools - Offline analysis only

## Expected I/O

**Input:**

- **Type:** Test output files or ctest command output
- **Format:** Text logs (ctest, Google Test), sanitizer reports
- **Constraints:**
  - Valid test output from ctest or test runner
  - Sanitizer output from ASan/TSan/UBSan-enabled builds

**Output:**

- **Type:** Test Analysis Report (Markdown)
- **Format:**

  ```markdown
  # Test Analysis Report - Build #X

  ## Summary

  - Total Tests: N
  - Passed: X (Y%)
  - Failed: Z (W%)
  - Coverage: X.X% (target: 98%)

  ## Failures

  ### Module X: [Module Name]

  **Test:** [test name]
  **Error:** [error message]
  **Analysis:** [root cause]
  **Location:** [file:line]
  **Suggested Fix:** [actionable fix]

  ## Sanitizer Reports

  ### AddressSanitizer: [CLEAN/ERRORS]

  ### ThreadSanitizer: [CLEAN/ERRORS]

  ### UBSan: [CLEAN/WARNINGS]

  ## Coverage Analysis

  - Overall: X.X%
  - By Module: [breakdown]

  ## Recommendations

  1. [Actionable items]
  ```

- **Validation:**
  - All failures include test name, error, and location
  - Root cause analysis provided for each failure
  - Sanitizer errors clearly extracted
  - Coverage metrics accurate

## Dependencies

**Required:**

- ctest (CMake test runner)
- Test output files (from build/Testing/Temporary/)
- Google Test framework (for Orpheus tests)

**Optional:**

- `lcov` or `gcov` (for coverage analysis)
- `python3` with standard library (for parsing scripts)

**Version Requirements:**

- ctest 3.20+
- Python 3.8+ (if using parser scripts)

## Examples

### Example 1: Parse ctest Output

**User:** "Analyze the latest test run output"

**Claude Process:**

1. Read ctest output: `cat build/Testing/Temporary/LastTest.log`
2. Parse test results (total, passed, failed)
3. Extract failing test details
4. Identify patterns and root causes
5. Generate report

**Output:**

````markdown
# Test Analysis Report - Build 2025-10-18

## Summary

- Total Tests: 47
- Passed: 46 (97.9%)
- Failed: 1 (2.1%)
- Duration: 3.2s
- Coverage: 98.1% (target: 98% - OK)

## Failures

### Module 3: AudioMixer

**Test:** AudioMixerTests.MixStereo
**Error:** Expected 0.5, got 0.4999847
**Analysis:** Floating-point precision issue in stereo mixing calculation
**Location:** src/modules/m3/audio_mixer.cpp:156
**Suggested Fix:**

- Use epsilon comparison for floating-point equality
- Or use fixed-point arithmetic for deterministic results

```cpp
EXPECT_NEAR(result, 0.5, 1e-6);  // Use NEAR instead of EQ
```
````

## Sanitizer Reports

### AddressSanitizer: CLEAN ✓

### ThreadSanitizer: CLEAN ✓

### UndefinedBehaviorSanitizer: CLEAN ✓

## Coverage Analysis

- Overall: 98.1% (↑0.2% from last build)
- Module 1 (Foundation): 100%
- Module 2 (Core): 99.1%
- Module 3 (Mixer): 97.2% (↓0.5% - investigate)
- Module 4 (Effects): 98.8%

## Recommendations

1. Fix AudioMixerTests.MixStereo floating-point comparison
2. Investigate Module 3 coverage decrease (was 97.7%, now 97.2%)
3. Consider adding integration test for multi-channel mixing

````

### Example 2: Parse Sanitizer Error

**User:** "Check for AddressSanitizer errors in test output"

**Output:**
```markdown
# Test Analysis Report - Sanitizer Check

## AddressSanitizer: 1 ERROR

### Error: Heap-use-after-free
**Location:** src/modules/m2/sample_buffer.cpp:89
**Details:**
````

==12345==ERROR: AddressSanitizer: heap-use-after-free on address 0x602000000010
READ of size 4 at 0x602000000010 thread T0
#0 SampleBuffer::read() src/modules/m2/sample_buffer.cpp:89
#1 TransportController::process() src/modules/m1/transport_controller.cpp:134

```

**Analysis:** Buffer is being accessed after deallocation.
Likely cause: Buffer lifetime management issue - buffer deleted while still referenced.

**Suggested Fix:**
1. Use shared_ptr or unique_ptr for ownership
2. Ensure buffer outlives all references
3. Add RAII wrapper for buffer lifecycle
4. Check destructor order in containing class

**Priority:** CRITICAL - Must fix before merge
```

### Example 3: Coverage Trend Analysis

**User:** "Show test coverage trends for the last 5 builds"

**Output:**

```markdown
# Test Coverage Trends

## Overall Coverage
```

Build #120: 97.9%
Build #121: 98.0%
Build #122: 98.1% ← Current
Build #123: 98.1%
Build #124: 98.2%

```

**Trend:** ↑ Increasing (good)

## Module Breakdown
- Module 1: Stable at 100%
- Module 2: 99.1% (↓ from 99.3%)
- Module 3: 97.2% (↓ from 97.7%) ⚠
- Module 4: 98.8% (stable)

## Recommendations
1. Module 3 coverage declining - investigate new code without tests
2. Overall trend positive, maintain 98%+ target
3. Module 2 slight decrease - review recent changes
```

## Limitations

**Known Edge Cases:**

- Cannot parse non-standard test output formats
- Requires Google Test format for detailed analysis
- Sanitizer output parsing assumes standard format (may vary by version)
- Coverage analysis requires lcov/gcov integration

**Performance Constraints:**

- Large test logs (>10MB) may be slow to parse
- Full coverage analysis requires compilation with coverage flags

**Security Boundaries:**

- Read-only access to test output files
- No modification of test code or results

**Scope Limitations:**

- Analyzes test output, doesn't run tests (use `ctest` directly for that)
- Cannot fix tests, only suggest fixes
- Coverage metrics require build with coverage instrumentation

## Validation Criteria

**Success Metrics:**

1. **Accuracy:** Correctly parse all test failures and sanitizer errors
2. **Completeness:** Extract all relevant information (test name, error, location)
3. **Actionability:** Provide root cause analysis and suggested fixes
4. **Performance:** Parse 1000 test results in <5 seconds

**Failure Modes:**

- **Parse errors:** Unrecognized test output format (update parser)
- **Missing data:** Incomplete error messages (request verbose test output)
- **Incorrect analysis:** Wrong root cause (improve pattern matching)

**Recovery:**

- For parse errors: Fall back to raw output display
- For missing data: Request re-run with `--output-on-failure` flag
- For incorrect analysis: Provide raw error for manual review

## Related Skills

**Dependencies:**

- None (standalone skill)

**Composes With:**

- `rt.safety.auditor` - Check if test failures are real-time violations
- `ci.troubleshooter` - Integrate test analysis into CI failure reports
- `orpheus.doc.gen` - Document test fixes and improvements

**Alternative Skills:**

- Manual test review - Human expertise for complex failures
- External CI tools - GitHub Actions, Jenkins (for automation)

## Maintenance

**Owner:** Orpheus Team
**Review Cycle:** Monthly (update parsers as test framework evolves)
**Last Updated:** 2025-10-18
**Version:** 1.0

**Revision Triggers:**

- Test framework changes (Google Test updates)
- New sanitizer versions
- Coverage tool updates
- New test output formats
