---
name: create-coverage-report
description: Generate comprehensive coverage report with requirement traceability mapping. Shows coverage per REQ-*, gaps, trends, and recommendations. Use for status dashboards, quality reviews, or compliance audits.
allowed-tools: [Read, Write, Bash, Grep, Glob]
---

# create-coverage-report

**Skill Type**: Reporter
**Purpose**: Generate comprehensive coverage report with REQ-* mapping
**Prerequisites**: Tests have run, coverage data available

---

## Agent Instructions

You are generating a **comprehensive coverage report** with requirement traceability.

**Report includes**:
1. Overall coverage statistics
2. Coverage per requirement (REQ-*)
3. Coverage gaps and recommendations
4. Coverage trends (if historical data)
5. Quality gate status

---

## Report Structure

### Section 1: Executive Summary

```markdown
# Test Coverage Report

**Generated**: 2025-11-20 15:30:00
**Project**: Customer Portal
**Branch**: main
**Commit**: abc123

## Executive Summary

**Overall Coverage**: 87.5% ✅ (Target: 80%)
**Requirements Tested**: 36/42 (85.7%)
**Critical Path Coverage**: 95.2% ⚠️ (Target: 100%)

**Status**: ⚠️ MINOR GAPS (3 requirements below threshold)

**Quality Gate**: ✅ PASS (overall > 80%)
```

---

### Section 2: Coverage by Requirement

```markdown
## Coverage by Requirement

| REQ-* | Description | Files | Coverage | Tests | Status |
|-------|-------------|-------|----------|-------|--------|
| <REQ-ID> | User login | 2 files | 97.6% | 12 | ✅ |
| <REQ-ID> | Password reset | 1 file | 100% | 8 | ✅ |
| <REQ-ID> | Payment processing | 3 files | 72.1% | 6 | ⚠️ |
| REQ-F-CART-001 | Shopping cart | 1 file | 45.8% | 2 | ❌ |
| REQ-NFR-PERF-001 | Response time | 2 files | 100% | 5 | ✅ |
| ... | ... | ... | ... | ... | ... |

**Legend**:
- ✅ Green: Coverage >= 80%
- ⚠️ Yellow: Coverage 50-79%
- ❌ Red: Coverage < 50%
```

---

### Section 3: Coverage Gaps

```markdown
## Coverage Gaps

### Requirements Below 80% (3)

**<REQ-ID>**: Payment processing (72.1%)
- Files: src/payments/payment.py
- Uncovered: 28 lines (error handling, edge cases)
- Missing Tests:
  - Edge case: amount = 0
  - Error case: invalid card token
  - Boundary: amount at limits
- **Recommendation**: Invoke 'generate-missing-tests' skill

**REQ-F-CART-001**: Shopping cart (45.8%)
- Files: src/cart/cart.py
- Uncovered: 87 lines (most logic untested)
- Missing Tests: Most functionality
- **Recommendation**: Write comprehensive test suite using TDD

**REQ-F-NOTIF-001**: Email notifications (0%)
- Files: None (not implemented)
- **Recommendation**: Implement requirement using TDD workflow

### Requirements Without Tests (6)

1. REQ-F-PROFILE-001 (code exists, no tests)
2. REQ-F-PROFILE-002 (code exists, no tests)
3. REQ-F-EXPORT-001 (no code, no tests)
... (3 more)
```

---

### Section 4: Coverage by File

```markdown
## Coverage by File

| File | Lines | Covered | Coverage | Requirements |
|------|-------|---------|----------|--------------|
| src/auth/login.py | 87 | 85 | 97.7% | <REQ-ID> |
| src/payments/payment.py | 142 | 102 | 71.8% | <REQ-ID> |
| src/cart/cart.py | 98 | 45 | 45.9% | REQ-F-CART-001 |
| src/auth/validators.py | 65 | 65 | 100% | BR-001, BR-002 |

**Files Below 80%**:
- src/payments/payment.py (71.8%)
- src/cart/cart.py (45.9%)
```

---

### Section 5: Test Statistics

```markdown
## Test Statistics

**Unit Tests**:
- Total: 156 tests
- Passing: 156 (100%)
- Duration: 0.8s
- Coverage Contribution: 75%

**Integration Tests**:
- BDD Scenarios: 12 scenarios, 67 steps
- API Tests: 24 tests
- Database Tests: 15 tests
- E2E Tests: 6 tests
- Total: 57 tests
- Passing: 57 (100%)
- Duration: 59.6s
- Coverage Contribution: 12.5%

**Total Tests**: 213 tests (156 unit + 57 integration)
**Pass Rate**: 100%
**Total Duration**: 60.4s
```

---

### Section 6: Coverage Trends

```markdown
## Coverage Trends (Last 7 Days)

| Date | Coverage | Change | Requirements | Tests |
|------|----------|--------|--------------|-------|
| 2025-11-20 | 87.5% | +2.3% ↑ | 42 | 213 |
| 2025-11-19 | 85.2% | +1.1% ↑ | 42 | 198 |
| 2025-11-18 | 84.1% | -0.5% ↓ | 40 | 187 |
| 2025-11-17 | 84.6% | +3.2% ↑ | 38 | 175 |

**Trend**: ✅ Improving (87.5% → 85.2% → 84.1%)
**New Requirements**: +2 this week
**New Tests**: +38 this week
```

---

### Section 7: Recommendations

```markdown
## Recommendations

### High Priority

1. **Fix REQ-F-CART-001 Coverage** (45.8% → 80%)
   - Action: Generate missing tests
   - Command: Invoke 'generate-missing-tests' for REQ-F-CART-001
   - Estimated: +34.2% coverage, ~15 tests

2. **Improve <REQ-ID> Coverage** (72.1% → 80%)
   - Action: Add edge case tests
   - Missing: Zero amount, negative amount, max limit
   - Estimated: +7.9% coverage, ~5 tests

3. **Implement REQ-F-NOTIF-001**
   - Action: Use TDD workflow
   - Status: Not started (0% coverage)

### Medium Priority

4. **Add Integration Tests for REQ-NFR-PERF-001**
   - Action: Write performance integration tests
   - Missing: Load tests, response time validation

5. **Improve Critical Path Coverage** (95.2% → 100%)
   - Action: Test remaining P0 edge cases
   - Gap: 4.8%
```

---

## Output Formats

### Console Output (Quick Summary)

```
[COVERAGE REPORT]

Overall: 87.5% ✅ (350/400 lines)

By Requirement:
  ✅ 33 requirements >= 80%
  ⚠️ 3 requirements 50-79%
  ❌ 0 requirements < 50%
  📝 6 requirements not implemented

Quality Gate: ✅ PASS (87.5% > 80%)

Top Gaps:
  1. REQ-F-CART-001: 45.8% (needs 15 tests)
  2. <REQ-ID>: 72.1% (needs 5 tests)
  3. REQ-F-PROFILE-001: 0% (not implemented)

Recommendation: Fix 3 gaps to reach 95%+ coverage
```

---

### HTML Report (Full Detail)

**Generate HTML file**:

```bash
# Python
pytest --cov=src --cov-report=html
# Creates: htmlcov/index.html

# JavaScript
npm test -- --coverage --coverageReporters=html
# Creates: coverage/index.html
```

**Enhanced with REQ-* mapping**:
- Each file shows which REQ-* it implements
- Click REQ-* to see all files/tests for that requirement
- Coverage heatmap by requirement priority

---

### JSON Report (Machine Readable)

```json
{
  "generated": "2025-11-20T15:30:00Z",
  "overall_coverage": 87.5,
  "requirements": [
    {
      "req_key": "<REQ-ID>",
      "description": "User login",
      "files": ["src/auth/login.py", "src/auth/validators.py"],
      "coverage": 97.6,
      "tests": 12,
      "status": "pass"
    },
    {
      "req_key": "<REQ-ID>",
      "description": "Payment processing",
      "files": ["src/payments/payment.py"],
      "coverage": 72.1,
      "tests": 6,
      "status": "warning",
      "gap": 7.9,
      "recommended_tests": 5
    }
  ],
  "quality_gate": "pass"
}
```

---

## Prerequisites Check

Before invoking:
1. Tests have been run (coverage data exists)
2. Coverage tool available (pytest-cov, jest, jacoco)

---

## Configuration

```yaml
plugins:
  - name: "@aisdlc/testing-skills"
    config:
      reporting:
        format: "html"                    # html | json | markdown
        include_req_mapping: true         # Map coverage to REQ-*
        include_gap_analysis: true        # Show what's missing
        include_trends: true              # Show historical trends
        output_path: "coverage-reports/"
```

---

## Notes

**Why coverage reports?**
- **Visibility**: See coverage at a glance
- **Requirement focus**: Coverage per REQ-* (not just per file)
- **Compliance**: Auditors need proof of testing
- **Trends**: Track coverage over time

**Homeostasis Goal**:
```yaml
desired_state:
  coverage_report_available: true
  coverage_per_requirement_visible: true
  gaps_identified: true
```

**"Excellence or nothing"** 🔥
