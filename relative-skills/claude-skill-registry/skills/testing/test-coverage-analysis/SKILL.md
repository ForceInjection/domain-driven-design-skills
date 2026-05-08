---
name: "Test Coverage Analysis"
description: "Measure and improve test coverage by identifying untested code paths and prioritizing high-risk areas for testing"
category: "testing"
required_tools: ["Read", "Bash", "Grep"]
---

# Test Coverage Analysis

## Purpose
Measure and improve test coverage to ensure code is adequately tested and identify untested areas that may contain bugs.

## When to Use
- Evaluating test suite quality
- Identifying untested code paths
- Setting testing goals
- Validating test completeness

## Key Capabilities
1. **Coverage Measurement** - Run coverage tools and interpret results
2. **Gap Analysis** - Identify critical untested code
3. **Prioritization** - Focus on high-risk areas first

## Approach
1. Run coverage tool on test suite
2. Review coverage report (line, branch, function coverage)
3. Identify uncovered critical paths
4. Prioritize based on risk and complexity
5. Write tests for important gaps
6. Re-run coverage to validate improvement

## Example
**Context**: Coverage report shows 75% line coverage
````
Analysis:
- Core business logic: 95% covered ✓
- Error handling: 45% covered ⚠️
- Edge cases: 30% covered ⚠️
- UI code: 60% covered

Priority:
1. Add tests for error handling (high risk)
2. Cover common edge cases
3. UI testing (lower priority)
````

## Best Practices
- ✅ Aim for 80%+ coverage on critical code
- ✅ Focus on meaningful tests, not just coverage numbers
- ✅ Test edge cases and error paths
- ❌ Avoid: Chasing 100% coverage on trivial code