---
name: generate-missing-tests
description: Homeostatic actuator auto-generating missing tests for requirements with low coverage. Creates unit tests, edge cases, and error cases for REQ-* without sufficient test coverage. Use when validate-test-coverage detects gaps.
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# generate-missing-tests

**Skill Type**: Actuator (Homeostasis)
**Purpose**: Auto-generate missing tests to achieve coverage goals
**Prerequisites**: Requirements exist, code exists, coverage gaps detected

---

## Agent Instructions

You are an **Actuator** correcting test coverage deviations.

**Desired State**: `coverage >= 80%` for all requirements

Your goal is to **generate missing tests** to close coverage gaps.

---

## Workflow

### Step 1: Receive Coverage Gaps

**Input from sensor** (`validate-test-coverage`):

```yaml
coverage_gaps:
  - req: <REQ-ID>
    code: src/payments/payment.py
    current_coverage: 72.1%
    target_coverage: 80%
    uncovered_lines: [45, 67-72, 89]
    missing_tests:
      - Edge case: amount = 0
      - Error case: invalid card token
      - Boundary: amount = max_limit

  - req: REQ-F-CART-001
    code: src/cart/cart.py
    current_coverage: 0%
    target_coverage: 80%
    missing_tests: ALL
```

---

### Step 2: Analyze Uncovered Code

**For each gap, determine what tests are needed**:

```python
# Uncovered code in src/payments/payment.py:45
def process_payment(amount: float, card_token: str) -> PaymentResult:
    if amount <= 0:  # Line 45 - UNCOVERED
        return PaymentResult(success=False, error="Invalid amount")

    # ... rest of implementation

# Missing test:
def test_payment_fails_with_zero_amount():
    # Validates: <REQ-ID> (edge case)
    result = process_payment(0.0, "tok_visa")
    assert result.success == False
    assert result.error == "Invalid amount"
```

---

### Step 3: Generate Test Cases

**Test generation patterns**:

**Pattern 1: Happy Path** (if missing):
```python
# Validates: <REQ-ID>
def test_process_payment_success():
    """Test successful payment processing"""
    result = process_payment(100.00, "tok_visa")
    assert result.success == True
    assert result.charge_id is not None
```

**Pattern 2: Edge Cases**:
```python
# Validates: <REQ-ID> (edge case: zero amount)
def test_payment_with_zero_amount():
    result = process_payment(0.0, "tok_visa")
    assert result.success == False

# Validates: <REQ-ID> (edge case: max amount)
def test_payment_at_max_limit():
    result = process_payment(10000.00, "tok_visa")
    assert result.success == True
```

**Pattern 3: Error Cases**:
```python
# Validates: <REQ-ID> (error: invalid token)
def test_payment_with_invalid_token():
    result = process_payment(100.00, "invalid_token")
    assert result.success == False
    assert "invalid" in result.error.lower()
```

**Pattern 4: Boundary Tests**:
```python
# Validates: <REQ-ID>, BR-005 (boundary: min amount)
def test_payment_below_minimum():
    result = process_payment(0.005, "tok_visa")  # Below $0.01 minimum
    assert result.success == False

def test_payment_at_minimum():
    result = process_payment(0.01, "tok_visa")  # Exactly at $0.01
    assert result.success == True
```

---

### Step 4: Write Test File

**Create or update test file**:

```python
# tests/payments/test_payment.py
# Generated tests for <REQ-ID>

# Validates: <REQ-ID>
# Business Rules: BR-001, BR-002, BR-003, BR-004, BR-005
# Generated: 2025-11-20 by generate-missing-tests skill

import pytest
from src.payments.payment import process_payment, PaymentResult


class TestPaymentProcessing:
    """Tests for <REQ-ID>: Payment processing"""

    def test_process_payment_success(self):
        """Test successful payment (happy path)"""
        # Validates: <REQ-ID>
        result = process_payment(100.00, "tok_visa")
        assert result.success == True
        assert result.charge_id is not None

    def test_payment_with_zero_amount(self):
        """Test payment fails with zero amount"""
        # Validates: <REQ-ID> (edge case)
        # Generated to cover line 45
        result = process_payment(0.0, "tok_visa")
        assert result.success == False
        assert result.error == "Invalid amount"

    def test_payment_with_negative_amount(self):
        """Test payment fails with negative amount"""
        # Validates: <REQ-ID> (edge case)
        result = process_payment(-50.00, "tok_visa")
        assert result.success == False

    def test_payment_with_invalid_token(self):
        """Test payment fails with invalid card token"""
        # Validates: <REQ-ID> (error case)
        # Generated to cover lines 67-72
        result = process_payment(100.00, "invalid_token")
        assert result.success == False

    def test_payment_below_minimum_amount(self):
        """Test payment below $0.01 minimum"""
        # Validates: BR-005 (boundary test)
        result = process_payment(0.005, "tok_visa")
        assert result.success == False

    def test_payment_at_minimum_amount(self):
        """Test payment exactly at $0.01"""
        # Validates: BR-005 (boundary test)
        result = process_payment(0.01, "tok_visa")
        assert result.success == True

    def test_payment_at_maximum_amount(self):
        """Test payment at $10,000 limit"""
        # Validates: BR-005 (boundary test)
        result = process_payment(10000.00, "tok_visa")
        assert result.success == True

    def test_payment_above_maximum_amount(self):
        """Test payment above $10,000 limit"""
        # Validates: BR-005 (boundary test)
        # Generated to cover line 89
        result = process_payment(10001.00, "tok_visa")
        assert result.success == False
```

**Generated**: 8 tests to cover all uncovered lines and business rules

---

### Step 5: Run Generated Tests

**Verify generated tests pass**:

```bash
pytest tests/payments/test_payment.py -v
```

**Expected**: All generated tests PASS ✅

**If tests fail**: Fix implementation (test found a bug!)

---

### Step 6: Re-Check Coverage

**Run coverage again**:

```bash
pytest --cov=src/payments/payment.py tests/payments/test_payment.py
```

**Results**:
```
Before: 72.1% coverage (28 uncovered lines)
After: 95.3% coverage (2 uncovered lines - error handling)

Improvement: +23.2% coverage
Remaining gaps: 2 lines (acceptable or generate more tests)
```

---

### Step 7: Commit Generated Tests

```bash
git add tests/payments/test_payment.py
git commit -m "GEN: Generate missing tests for <REQ-ID>

Auto-generate tests to improve coverage from 72.1% to 95.3%.

Tests Generated (8):
- Happy path: test_process_payment_success
- Edge cases: zero amount, negative amount
- Error cases: invalid token
- Boundary tests: min/max amounts (4 tests)

Coverage Improvement:
- Before: 72.1% (28 uncovered lines)
- After: 95.3% (2 uncovered lines)
- Improvement: +23.2%

Generated by: generate-missing-tests skill
Triggered by: validate-test-coverage sensor (detected gap)
Validates: <REQ-ID>, BR-005
Tests: 8 tests, all passing ✓
"
```

---

## Output Format

```
[GENERATE MISSING TESTS - <REQ-ID>]

Coverage Gap Detected:
  Current: 72.1%
  Target: 80%
  Gap: -7.9%

Uncovered Lines: 28 lines
  - Lines 45: Zero amount check
  - Lines 67-72: Invalid token handling
  - Line 89: Amount above maximum

Test Generation Strategy:
  ✓ Happy path (1 test)
  ✓ Edge cases (2 tests: zero, negative)
  ✓ Error cases (1 test: invalid token)
  ✓ Boundary tests (4 tests: min/max boundaries)

Generated Tests (8):
  ✓ test_process_payment_success (happy path)
  ✓ test_payment_with_zero_amount (edge case)
  ✓ test_payment_with_negative_amount (edge case)
  ✓ test_payment_with_invalid_token (error case)
  ✓ test_payment_below_minimum_amount (boundary)
  ✓ test_payment_at_minimum_amount (boundary)
  ✓ test_payment_at_maximum_amount (boundary)
  ✓ test_payment_above_maximum_amount (boundary)

Running generated tests...
  ✓ All 8 tests PASSING

Coverage Re-Check:
  Before: 72.1%
  After: 95.3%
  Improvement: +23.2% ✅

Remaining Uncovered: 2 lines (error handling - acceptable)

Commit: GEN: Generate missing tests for <REQ-ID>

✅ Test Generation Complete!
   Coverage goal achieved (95.3% > 80%)
   Homeostasis achieved ✓
```

---

## Prerequisites Check

Before invoking:
1. Coverage gaps identified (from validate-test-coverage)
2. Code to test exists
3. Requirement details available (REQ-*, BR-*)

---

## Test Generation Strategies

### Strategy 1: From Business Rules

**Use BR-* to generate tests**:
```
BR-005: Amount between $0.01 and $10,000
  → Generate:
    - test_amount_below_min (0.005)
    - test_amount_at_min (0.01)
    - test_amount_valid (100.00)
    - test_amount_at_max (10000.00)
    - test_amount_above_max (10001.00)
```

### Strategy 2: From Uncovered Lines

**Analyze uncovered code paths**:
```python
if amount <= 0:  # UNCOVERED
    return error()

→ Generate: test with amount = 0, amount = -1
```

### Strategy 3: From Code Structure

**Identify test patterns from code**:
- If/else branches → Test both paths
- Try/except → Test exception path
- Loops → Test empty, single, multiple
- Return values → Test all possible returns

---

## Notes

**Why auto-generate tests?**
- **Closes coverage gaps** automatically
- **Saves developer time** (no manual test writing)
- **Consistent quality** (all tests follow same pattern)
- **Homeostasis** (system self-corrects to desired coverage)

**Generated tests are starting point**:
- Review and improve generated tests
- Add domain-specific assertions
- Refine test data for realism

**Homeostasis Goal**:
```yaml
desired_state:
  coverage: >= 80%
  all_requirements_tested: true
  critical_paths: 100%
```

**"Excellence or nothing"** 🔥
