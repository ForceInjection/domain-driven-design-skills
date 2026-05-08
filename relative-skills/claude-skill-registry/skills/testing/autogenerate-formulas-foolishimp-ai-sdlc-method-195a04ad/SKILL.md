---
name: autogenerate-formulas
description: Autogenerate formula implementations from formula specifications (F-*). Converts mathematical formulas, calculations, and algorithms into production code with tests. Use when F-* includes formula specifications.
allowed-tools: [Read, Write, Edit]
---

# autogenerate-formulas

**Skill Type**: Actuator (Code Generation)
**Purpose**: Generate formula implementations from F-* specifications
**Prerequisites**:
- Formula specifications (F-*) with mathematical definitions

---

## Agent Instructions

You are **autogenerating formulas** from **formula specifications**.

Your goal is to transform **structured F-* formulas** into **calculation functions** with tests.

---

## Generation Patterns

### Pattern 1: Simple Arithmetic Formulas

**Input**:
```yaml
F-001: Stripe fee calculation
  Formula: fee = (amount * 0.029) + 0.30
  Inputs: amount (float)
  Output: fee (float, rounded to 2 decimals)
```

**Generated**:
```python
# Generated from: F-001
STRIPE_PERCENTAGE_FEE = 0.029  # 2.9%
STRIPE_FIXED_FEE = 0.30        # $0.30

def calculate_stripe_fee(amount: float) -> float:
    """
    Calculate Stripe processing fee.

    Generated from: F-001 (Stripe fee calculation)

    Formula: fee = (amount * 0.029) + 0.30

    Args:
        amount: Payment amount in dollars

    Returns:
        Processing fee in dollars (rounded to 2 decimals)

    Examples:
        >>> calculate_stripe_fee(100.00)
        3.20
        >>> calculate_stripe_fee(1000.00)
        29.30
    """
    # Implements: F-001
    fee = (amount * STRIPE_PERCENTAGE_FEE) + STRIPE_FIXED_FEE
    return round(fee, 2)

# Generated tests
def test_calculate_stripe_fee_100_dollars():
    assert calculate_stripe_fee(100.00) == 3.20

def test_calculate_stripe_fee_1000_dollars():
    assert calculate_stripe_fee(1000.00) == 29.30

def test_calculate_stripe_fee_minimum_charge():
    # For $0.01, fee is still $0.30 fixed + 0.0003% ≈ $0.30
    assert calculate_stripe_fee(0.01) == 0.30
```

---

### Pattern 2: Date/Time Calculations

**Input**:
```yaml
F-002: Password reset token expiry
  Formula: expiry_time = issue_time + (60 * 60) seconds
  Inputs: issue_time (datetime)
  Output: expiry_time (datetime)
```

**Generated**:
```python
# Generated from: F-002
from datetime import datetime, timedelta

TOKEN_EXPIRY_SECONDS = 60 * 60  # 1 hour

def calculate_token_expiry(issue_time: datetime) -> datetime:
    """
    Calculate password reset token expiry time.

    Generated from: F-002 (Token expiry calculation)

    Formula: expiry_time = issue_time + 3600 seconds

    Args:
        issue_time: When token was issued

    Returns:
        Expiry time (1 hour after issue)

    Examples:
        >>> issue = datetime(2025, 11, 20, 10, 0, 0)
        >>> expiry = calculate_token_expiry(issue)
        >>> expiry
        datetime(2025, 11, 20, 11, 0, 0)
    """
    # Implements: F-002
    return issue_time + timedelta(seconds=TOKEN_EXPIRY_SECONDS)

# Generated tests
def test_token_expiry_one_hour():
    issue = datetime(2025, 11, 20, 10, 0, 0)
    expiry = calculate_token_expiry(issue)
    assert expiry == datetime(2025, 11, 20, 11, 0, 0)

def test_token_expiry_across_day_boundary():
    issue = datetime(2025, 11, 20, 23, 30, 0)
    expiry = calculate_token_expiry(issue)
    assert expiry == datetime(2025, 11, 21, 0, 30, 0)
```

---

### Pattern 3: Compound Interest / Growth Formulas

**Input**:
```yaml
F-010: Compound interest
  Formula: A = P(1 + r/n)^(nt)
  Inputs:
    - P: principal amount
    - r: annual interest rate (decimal)
    - n: compounding frequency (times per year)
    - t: time in years
  Output: A (final amount, rounded to 2 decimals)
```

**Generated**:
```python
# Generated from: F-010
import math

def calculate_compound_interest(
    principal: float,
    rate: float,
    compounding_frequency: int,
    years: float
) -> float:
    """
    Calculate compound interest.

    Generated from: F-010 (Compound interest formula)

    Formula: A = P(1 + r/n)^(nt)

    Args:
        principal: Initial principal amount
        rate: Annual interest rate (decimal, e.g., 0.05 for 5%)
        compounding_frequency: Times compounded per year (e.g., 12 for monthly)
        years: Time period in years

    Returns:
        Final amount (rounded to 2 decimals)

    Examples:
        >>> calculate_compound_interest(1000, 0.05, 12, 1)
        1051.16
        >>> calculate_compound_interest(1000, 0.05, 1, 5)
        1276.28
    """
    # Implements: F-010
    amount = principal * math.pow(
        1 + (rate / compounding_frequency),
        compounding_frequency * years
    )
    return round(amount, 2)

# Generated tests
def test_compound_interest_monthly_one_year():
    # $1000 at 5% compounded monthly for 1 year
    result = calculate_compound_interest(1000, 0.05, 12, 1)
    assert result == 1051.16

def test_compound_interest_annually_five_years():
    # $1000 at 5% compounded annually for 5 years
    result = calculate_compound_interest(1000, 0.05, 1, 5)
    assert result == 1276.28
```

---

### Pattern 4: Percentage Calculations

**Input**:
```yaml
F-020: Discount calculation
  Formula: discounted_price = original_price * (1 - discount_percentage)
  Inputs:
    - original_price: float
    - discount_percentage: float (0.0 to 1.0)
  Output: discounted_price (float, rounded to 2 decimals)
  Constraints: discount_percentage must be 0.0 to 1.0
```

**Generated**:
```python
# Generated from: F-020
def calculate_discounted_price(original_price: float, discount_percentage: float) -> float:
    """
    Calculate discounted price.

    Generated from: F-020 (Discount calculation)

    Formula: discounted_price = original_price * (1 - discount_percentage)

    Args:
        original_price: Original price before discount
        discount_percentage: Discount as decimal (0.0 to 1.0)

    Returns:
        Discounted price (rounded to 2 decimals)

    Raises:
        ValueError: If discount_percentage not in range [0.0, 1.0]

    Examples:
        >>> calculate_discounted_price(100.00, 0.20)
        80.00
        >>> calculate_discounted_price(50.00, 0.50)
        25.00
    """
    # Implements: F-020
    # Constraint: discount_percentage must be 0.0 to 1.0
    if not 0.0 <= discount_percentage <= 1.0:
        raise ValueError("Discount percentage must be between 0.0 and 1.0")

    discounted = original_price * (1 - discount_percentage)
    return round(discounted, 2)

# Generated tests
def test_discount_20_percent():
    assert calculate_discounted_price(100.00, 0.20) == 80.00

def test_discount_50_percent():
    assert calculate_discounted_price(50.00, 0.50) == 25.00

def test_discount_0_percent():
    assert calculate_discounted_price(100.00, 0.00) == 100.00

def test_discount_100_percent():
    assert calculate_discounted_price(100.00, 1.00) == 0.00

def test_discount_invalid_negative():
    with pytest.raises(ValueError):
        calculate_discounted_price(100.00, -0.10)

def test_discount_invalid_over_100():
    with pytest.raises(ValueError):
        calculate_discounted_price(100.00, 1.50)
```

---

### Pattern 5: Hash/Checksum Formulas

**Input**:
```yaml
F-030: Idempotency key generation
  Formula: key = SHA256(merchant_id + timestamp + amount + card_last4)
  Inputs:
    - merchant_id: string
    - timestamp: int (unix timestamp)
    - amount: float
    - card_last4: string (last 4 digits)
  Output: key (hex string)
```

**Generated**:
```python
# Generated from: F-030
import hashlib

def generate_idempotency_key(
    merchant_id: str,
    timestamp: int,
    amount: float,
    card_last4: str
) -> str:
    """
    Generate idempotency key for payment.

    Generated from: F-030 (Idempotency key generation)

    Formula: SHA256(merchant_id + timestamp + amount + card_last4)

    Args:
        merchant_id: Merchant identifier
        timestamp: Unix timestamp
        amount: Payment amount
        card_last4: Last 4 digits of card

    Returns:
        SHA256 hex digest as idempotency key

    Examples:
        >>> key = generate_idempotency_key("merch_123", 1637000000, 100.00, "4242")
        >>> len(key)
        64
    """
    # Implements: F-030
    data = f"{merchant_id}{timestamp}{amount}{card_last4}"
    return hashlib.sha256(data.encode()).hexdigest()

# Generated tests
def test_idempotency_key_deterministic():
    # Same inputs → same key
    key1 = generate_idempotency_key("merch_123", 1637000000, 100.00, "4242")
    key2 = generate_idempotency_key("merch_123", 1637000000, 100.00, "4242")
    assert key1 == key2

def test_idempotency_key_different_timestamp():
    # Different timestamp → different key
    key1 = generate_idempotency_key("merch_123", 1637000000, 100.00, "4242")
    key2 = generate_idempotency_key("merch_123", 1637000001, 100.00, "4242")
    assert key1 != key2

def test_idempotency_key_length():
    key = generate_idempotency_key("merch_123", 1637000000, 100.00, "4242")
    assert len(key) == 64  # SHA256 hex = 64 chars
```

---

### Pattern 6: Conversion Formulas

**Input**:
```yaml
F-040: Temperature conversion
  Formula: celsius = (fahrenheit - 32) * 5/9
  Inputs: fahrenheit (float)
  Output: celsius (float, rounded to 1 decimal)
```

**Generated**:
```python
# Generated from: F-040
def fahrenheit_to_celsius(fahrenheit: float) -> float:
    """
    Convert Fahrenheit to Celsius.

    Generated from: F-040 (Temperature conversion)

    Formula: celsius = (fahrenheit - 32) * 5/9

    Args:
        fahrenheit: Temperature in Fahrenheit

    Returns:
        Temperature in Celsius (rounded to 1 decimal)

    Examples:
        >>> fahrenheit_to_celsius(32.0)
        0.0
        >>> fahrenheit_to_celsius(212.0)
        100.0
        >>> fahrenheit_to_celsius(98.6)
        37.0
    """
    # Implements: F-040
    celsius = (fahrenheit - 32) * 5 / 9
    return round(celsius, 1)

# Generated tests
def test_fahrenheit_to_celsius_freezing():
    assert fahrenheit_to_celsius(32.0) == 0.0

def test_fahrenheit_to_celsius_boiling():
    assert fahrenheit_to_celsius(212.0) == 100.0

def test_fahrenheit_to_celsius_body_temp():
    assert fahrenheit_to_celsius(98.6) == 37.0
```

---

## Test Generation Strategy

**For every formula, generate**:
1. **Known value tests**: Use example values with known results
2. **Boundary tests**: Test formula at edges (0, max, min)
3. **Inverse tests**: If inverse formula exists, verify `f(f_inv(x)) == x`
4. **Edge cases**: Test with special values (0, negative, very large)

---

## Output Format

```
[FORMULA GENERATION]

Input: 5 formulas

Generated Formulas:
  ✓ calculate_stripe_fee() from F-001
  ✓ calculate_token_expiry() from F-002
  ✓ generate_idempotency_key() from F-030
  ✓ calculate_compound_interest() from F-010
  ✓ fahrenheit_to_celsius() from F-040

Generated Constants:
  ✓ STRIPE_PERCENTAGE_FEE = 0.029
  ✓ STRIPE_FIXED_FEE = 0.30
  ✓ TOKEN_EXPIRY_SECONDS = 3600

Generated Tests:
  ✓ 20 tests (5 formulas × 4 tests average)

Running tests...
  ✓ All 20 tests PASSING

Files:
  + src/calculations.py (5 formulas, 145 lines)
  + tests/test_calculations.py (20 tests, 127 lines)
```

---

## Prerequisites Check

Before invoking this skill, ensure:
1. Formulas (F-*) exist with complete specifications
2. Formula includes: inputs, formula expression, output format

If F-* too vague:
- Ask user: "F-001 says 'fee calculation' - what's the formula?"

---

## Notes

**Why autogenerate formulas?**
- **Accuracy**: No manual coding errors in calculations
- **Documentation**: Formula is in code + docstring
- **Testability**: Generated tests verify formula correctness
- **Consistency**: All formulas follow same pattern

**Formula complexity handling**:
- **Simple formulas** (F = ma): Direct translation
- **Complex formulas** (compound interest): Use math library
- **Multi-step formulas**: Break into helper functions

**Homeostasis Goal**:
```yaml
desired_state:
  all_formulas_have_code: true
  all_formula_code_has_tests: true
  all_tests_passing: true
  formulas_documented: true
```

**"Excellence or nothing"** 🔥
