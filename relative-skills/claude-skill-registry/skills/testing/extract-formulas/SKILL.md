---
name: extract-formulas
description: Extract mathematical formulas (F-*) from requirements - calculations, algorithms, conversions. Enables autogeneration of calculation functions with tests. Use when requirements involve math, dates, percentages, or algorithms.
allowed-tools: [Read, Write, Edit]
---

# extract-formulas

**Skill Type**: Actuator (Requirements Disambiguation)
**Purpose**: Extract F-* formulas from REQ-* requirements
**Prerequisites**: REQ-* requirement exists

---

## Agent Instructions

You are extracting **formulas** (F-*) from requirements.

**Formulas** are:
- Mathematical calculations (fee = amount * rate)
- Date/time calculations (expiry = issue_time + duration)
- Conversions (celsius = (fahrenheit - 32) * 5/9)
- Algorithms (hash, scoring, ranking)

**Goal**: Identify formulas precise enough for code autogeneration.

---

## F-* Categories

### 1. Arithmetic Formulas

```yaml
F-001: Stripe processing fee
  - Formula: fee = (amount * 0.029) + 0.30
  - Inputs: amount (float)
  - Output: fee (float, rounded to 2 decimals)
  - Autogenerate: calculate_stripe_fee(amount) -> float
```

### 2. Date/Time Calculations

```yaml
F-010: Token expiry time
  - Formula: expiry = issue_time + (60 * 60) seconds
  - Inputs: issue_time (datetime)
  - Output: expiry (datetime)
  - Autogenerate: calculate_token_expiry(issue_time) -> datetime
```

### 3. Percentage/Ratio Calculations

```yaml
F-020: Discount amount
  - Formula: discount = original_price * discount_percentage
  - Inputs: original_price (float), discount_percentage (float 0.0-1.0)
  - Output: discount (float, rounded to 2 decimals)
  - Autogenerate: calculate_discount(price, percentage) -> float
```

### 4. Hash/Checksum Algorithms

```yaml
F-030: Idempotency key
  - Formula: key = SHA256(merchant_id + timestamp + amount)
  - Inputs: merchant_id (str), timestamp (int), amount (float)
  - Output: key (hex string, 64 chars)
  - Autogenerate: generate_idempotency_key(...) -> str
```

---

## Extraction Process

Identify formulas by looking for:
- Calculations: "calculate", "compute", "determine"
- Operators: +, -, *, /, %, ^
- Functions: SHA256, round, abs, max, min
- Time: "expires after", "duration", "timeout"
- Money: "fee", "tax", "discount", "total"

---

## Output Format

```
[EXTRACT FORMULAS - <REQ-ID>]

Requirement: Payment processing

Formulas Extracted (3):
  ✓ F-001: Stripe processing fee calculation
  ✓ F-002: Idempotency key generation
  ✓ F-003: Transaction timeout calculation

Updated: docs/requirements/payments.md
  Added: Formulas section with 3 F-*

✅ Formula Extraction Complete!
```

---

**"Excellence or nothing"** 🔥
