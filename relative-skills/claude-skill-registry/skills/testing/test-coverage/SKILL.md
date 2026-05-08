---
name: test-coverage
description: Analyze test coverage and generate a detailed coverage report
---

# Test Coverage Report Skill

This skill analyzes test coverage for the codebase and generates a detailed report.

## Instructions

When this skill is invoked, you should:

1. **Parse the coverage data if it exists**:
   - If it does not exist, run tests first
   - If it still does not exist, **do not proceed further**
   - Read the coverage file: `coverage/lcov-buttercup.info`
   - Parse LCOV format to extract:
     - Lines with execution counts (DA:line_number,count)
     - Total lines and covered lines
     - Coverage percentage

2. **Identify covered code sections**:
   - Find which line ranges are covered (count > 0)
   - Group consecutive covered lines into ranges
   - Read the source file to identify which functions are covered

3. **Generate a comprehensive report** including:
   - Test execution summary (pass/fail count, execution time)
   - Overall coverage statistics (lines covered, percentage)
   - List of tested functions with their line ranges
   - List of untested functions
   - Coverage trend if previous coverage data is available
   - Recommendations for next testing priorities

4. **Format the output** with:
   - Clear sections and headers
   - Tables for statistics
   - Easy-to-read formatting using markdown

## Coverage Calculation Formula

```
Coverage % = (Lines with count > 0) / (Total lines) * 100
```

## Example Output Format

```markdown
## Test Coverage Report

### Test Execution
- ✅ All X tests passed
- Execution time: Y ms

### Coverage Statistics
- Lines covered: X/Y (Z%)
- Previous coverage: A/B (C%)
- Change: +D lines (+E%)

### Tested Functions
1. function-name (lines X-Y) - Z lines covered
2. another-function (lines A-B) - C lines covered

### Coverage Gaps
- untested-function (lines X-Y) - D lines
- another-untested (lines A-B) - E lines

### Recommendations
The next most valuable functions to test are:
...
```

## Notes

- Always verify the coverage directory exists before attempting to read it
- Handle missing or malformed coverage data gracefully
- Provide actionable recommendations based on function importance and coverage impact
