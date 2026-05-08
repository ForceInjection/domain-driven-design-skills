---
name: validate-test-coverage
description: Homeostatic sensor validating test coverage percentage and detecting requirements without tests. Calculates coverage per requirement (REQ-*) and overall. Use as quality gate or continuous coverage monitoring.
allowed-tools: [Read, Grep, Glob, Bash]
---

# validate-test-coverage

**Skill Type**: Sensor (Homeostasis)
**Purpose**: Validate test coverage and detect gaps
**Prerequisites**: Code and tests exist

---

## Agent Instructions

You are a **Sensor** in the homeostasis system validating test coverage.

**Desired State**: `coverage >= 80%` overall, `100%` for critical paths

Your goal is to:
1. Calculate test coverage percentage
2. Identify requirements without tests
3. Detect code without test coverage
4. Signal deviations if coverage < threshold

---

## Workflow

### Step 1: Run Coverage Tool

**Execute coverage measurement**:

```bash
# Python (pytest-cov)
pytest --cov=src --cov-report=term-missing --cov-report=json

# JavaScript (Jest)
npm test -- --coverage --coverageReporters=json

# Java (JaCoCo)
mvn test jacoco:report
```

**Parse coverage data**:
```json
{
  "totals": {
    "percent_covered": 87.5,
    "covered_lines": 350,
    "total_lines": 400
  },
  "files": {
    "src/auth.py": {"percent_covered": 95.2},
    "src/payments.py": {"percent_covered": 72.1}
  }
}
```

---

### Step 2: Calculate Per-Requirement Coverage

**For each REQ-*, find associated code and check coverage**:

```bash
# Find files implementing <REQ-ID>
grep -rl "# Implements: <REQ-ID>" src/

# For each file, check coverage
# Output:
src/auth/login.py: 95.2% coverage
src/auth/validators.py: 100% coverage
Average for <REQ-ID>: 97.6% ✅
```

**Coverage by requirement**:
```
<REQ-ID>: 97.6% ✅ (2 files, high coverage)
<REQ-ID>: 72.1% ⚠️ (1 file, below threshold)
REQ-F-CART-001: 0% ❌ (1 file, no tests)
```

---

### Step 3: Find Requirements Without Tests

**Cross-reference requirements with test tags**:

```bash
# Find all requirements
grep -rho "REQ-[A-Z-]*-[0-9]*" docs/requirements/ | sort -u

# For each, check if tests exist
for req in $(cat requirements.txt); do
  if ! grep -q "# Validates: $req" tests/ features/; then
    echo "$req: NO TESTS"
  fi
done
```

**Output**:
```
Requirements Without Tests:
- <REQ-ID> (has code, no tests) ❌
- REQ-F-CART-001 (has code, no tests) ❌
- REQ-F-PROFILE-001 (no code, no tests) ⚠️
```

---

### Step 4: Detect Critical Path Coverage

**Identify critical paths** (from requirements priority):

```yaml
Critical Requirements (P0):
- <REQ-ID>: 97.6% ✅ (Pass)
- <REQ-ID>: 72.1% ❌ (Fail - critical path needs 100%)
- REQ-NFR-SEC-001: 100% ✅ (Pass)
```

**Critical path rule**: P0 requirements must have 100% coverage

---

### Step 5: Calculate Coverage Gaps

**Gap analysis**:

```
Overall Coverage: 87.5%
  ✅ Above 80% threshold

Coverage by Priority:
  P0 (Critical): 89.7% ❌ (3 requirements, 1 below 100%)
  P1 (High): 92.3% ✅
  P2 (Medium): 78.5% ⚠️ (below threshold)

Coverage by Requirement Type:
  REQ-F-* (Functional): 85.2% ✅
  REQ-NFR-* (Non-Functional): 92.8% ✅
  REQ-DATA-* (Data): 65.0% ❌ (below threshold)

Gap: P0 critical path and REQ-DATA-* need improvement
```

---

## Output Format

When validation finds deviations:

```
[VALIDATE TEST COVERAGE - DEVIATION DETECTED]

Overall Coverage: 87.5% ✅ (threshold: 80%)

Coverage by Requirement:
  ✅ <REQ-ID>: 97.6% (2 files)
  ⚠️ <REQ-ID>: 72.1% (below 80%)
  ❌ REQ-F-CART-001: 0% (no tests)

Critical Path Coverage (P0):
  ✅ <REQ-ID>: 97.6%
  ❌ <REQ-ID>: 72.1% (Critical! Needs 100%)
  ✅ REQ-NFR-SEC-001: 100%

Requirements Without Tests (2):
  1. <REQ-ID>
     Code: src/payments/payment.py (72.1% coverage)
     Missing: Unit tests for edge cases

  2. REQ-F-CART-001
     Code: src/cart/cart.py
     Missing: All tests

Homeostasis Deviation:
  - Critical path <REQ-ID> below 100%
  - 2 requirements without sufficient tests
  - Data requirements (REQ-DATA-*) at 65%

Recommended Actions:
  1. Invoke 'generate-missing-tests' for <REQ-ID>, REQ-F-CART-001
  2. Focus on critical path (P0) requirements
  3. Improve REQ-DATA-* coverage (65% → 80%)

Homeostasis Status: ⚠️ DEVIATION DETECTED
Target: coverage >= 80%, critical >= 100%
Current: overall 87.5% ✅, critical 89.7% ❌
```

When homeostasis achieved:

```
[VALIDATE TEST COVERAGE - HOMEOSTASIS ACHIEVED]

Overall Coverage: 94.2% ✅

Coverage by Requirement:
  ✅ All requirements >= 80%
  ✅ All P0 requirements = 100%

Critical Path: 100% ✅
Data Requirements: 91.3% ✅

Homeostasis Status: ✅ STABLE
All quality gates: PASS
```

---

## Homeostasis Behavior

**When deviation detected**:
1. **Report**: Coverage below threshold, requirements without tests
2. **Signal**: "Need tests for {REQ-KEYS}"
3. **Recommend**: Invoke `generate-missing-tests` actuator
4. **Wait**: User confirmation or auto-invoke if configured

---

## Prerequisites Check

Before invoking:
1. Tests exist (can be zero, but test infrastructure present)
2. Coverage tool available (pytest-cov, jest, jacoco)

---

## Configuration

```yaml
plugins:
  - name: "@aisdlc/testing-skills"
    config:
      coverage:
        minimum_percentage: 80
        require_per_requirement: true
        critical_paths_coverage: 100
        exclude_patterns: ["**/migrations/**"]
```

---

## Notes

**Why validate coverage?**
- **Quality gate**: Don't deploy without adequate tests
- **Homeostasis**: Continuous monitoring detects when coverage drops
- **Requirement focus**: Coverage per REQ-* ensures all features tested

**Homeostasis Goal**:
```yaml
desired_state:
  overall_coverage: >= 80%
  critical_path_coverage: 100%
  all_requirements_have_tests: true
```

**"Excellence or nothing"** 🔥
