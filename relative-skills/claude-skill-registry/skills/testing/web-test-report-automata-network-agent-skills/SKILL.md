---
name: web-test-report
description: Generate test report with clear visual indicators - ✅ for pass, ❌ for fail. Summarize results, document failures, provide recommendations.
license: MIT
compatibility: Node.js 18+
metadata:
  author: AI Agent
  version: 2.0.0
allowed-tools: Bash Read Write Glob
---

# Test Report Generation

Generate a clear, visually scannable test report.

## Visual Indicators (MUST USE)

| Status | Symbol | Usage |
|--------|--------|-------|
| Pass | ✅ | Test passed successfully |
| Fail | ❌ | Test failed |
| Skip | ⏭️ | Test skipped |
| Warning | ⚠️ | Test passed with issues |
| Blocked | 🚫 | Test blocked by dependency |

**DO NOT use plain text like "PASS" or "FAIL" - always use symbols!**

## Report Structure

### Section 1: Header & Summary

```markdown
# Test Report

📅 **Executed:** 2024-01-15 14:30:25
⏱️ **Duration:** 8m 32s
🌐 **Project:** [Project Name]
🔗 **URL:** http://localhost:3000
🔗 **Is Web3:** Yes / No
📄 **Report File:** test-report-20240115-143025.md

---

## Summary

| | Count |
|---|---:|
| ✅ Passed | 8 |
| ❌ Failed | 2 |
| ⏭️ Skipped | 1 |
| **Total** | **11** |

**Pass Rate: 80%**

**Overall: ❌ FAILED** (or ✅ PASSED if all pass)
```

### Section 2: Results Table

**Use a clear table with status symbols:**

```markdown
## Test Results

| Status | ID | Test Name | Notes |
|:------:|:---|:----------|:------|
| ✅ | TC-001 | Homepage Load | Loaded in 1.2s |
| ✅ | TC-002 | Navigation | All links work |
| ✅ | TC-003 | Login Form | Successfully logged in |
| ❌ | TC-004 | Submit Order | Button not clickable |
| ❌ | TC-005 | Payment | Timeout waiting for response |
| ⏭️ | TC-006 | Admin Panel | Requires admin access |
| ✅ | TC-007 | Logout | Session cleared |
```

### Section 3: Failed Tests Detail

**For each failed test, provide details:**

```markdown
## ❌ Failed Tests

### TC-004: Submit Order

| | |
|---|---|
| **Status** | ❌ FAILED |
| **Screenshot** | [tc004-error.jpg](screenshots/tc004-error.jpg) |

**Expected:** Order submits successfully
**Actual:** Submit button disabled, cannot click

**Steps to Reproduce:**
1. Add item to cart
2. Go to checkout
3. Fill in details
4. Click "Submit Order" ← Button is disabled

---

### TC-005: Payment

| | |
|---|---|
| **Status** | ❌ FAILED |
| **Screenshot** | [tc005-timeout.jpg](screenshots/tc005-timeout.jpg) |

**Expected:** Payment processes within 30s
**Actual:** Timeout after 30s, no response

**Error:** `TimeoutError: waiting for selector ".payment-success"`
```

### Section 4: Web3 Results (if applicable)

```markdown
## 🔗 Web3 Test Results

### Wallet Connection
| | |
|---|---|
| **Status** | ✅ Connected |
| **Wallet** | MetaMask |
| **Address** | 0x1234...abcd |
| **Network** | Ethereum |

### Transactions

| Status | Test | Tx Type | Popups | Notes |
|:------:|:-----|:--------|:------:|:------|
| ✅ | SWAP-001 | Swap ETH→USDC | 1 | Success |
| ✅ | SWAP-002 | Swap USDC→ETH | 2 | Approve + Swap |
| ❌ | SWAP-003 | Large Swap | 0 | Insufficient balance error not shown |
```

### Section 5: Issues Found

```markdown
## 🐛 Issues Found

### Issue #1: Submit Button Disabled
| | |
|---|---|
| **Severity** | 🔴 High |
| **Test** | TC-004 |
| **Screenshot** | [tc004-error.jpg](screenshots/tc004-error.jpg) |

**Description:** Submit order button remains disabled after filling all required fields

**Reproduce:**
1. Add item to cart
2. Complete checkout form
3. Observe submit button state

---

### Issue #2: Payment Timeout
| | |
|---|---|
| **Severity** | 🔴 High |
| **Test** | TC-005 |

**Description:** Payment API does not respond within timeout
```

### Section 6: Recommendations

```markdown
## 📋 Recommendations

### 🔴 High Priority
1. Fix submit button disabled state logic
2. Add timeout handling for payment API

### 🟡 Medium Priority
1. Add loading indicators for async operations
2. Improve error messages

### 🟢 Low Priority
1. Add keyboard shortcuts
2. Optimize image loading
```

## Example Complete Report

```markdown
# Test Report

📅 **Executed:** 2024-01-15 14:30:25
⏱️ **Duration:** 12m 45s
🌐 **Project:** MyShop
🔗 **URL:** http://localhost:3000
🔗 **Is Web3:** No
📄 **Report File:** test-report-20240115-143025.md

---

## Summary

| | Count |
|---|---:|
| ✅ Passed | 5 |
| ❌ Failed | 2 |
| ⏭️ Skipped | 0 |
| **Total** | **7** |

**Pass Rate: 71%**

**Overall: ❌ FAILED**

---

## Test Results

| Status | ID | Test Name | Notes |
|:------:|:---|:----------|:------|
| ✅ | TC-001 | Homepage Load | 1.2s |
| ✅ | TC-002 | Product List | 15 products shown |
| ✅ | TC-003 | Add to Cart | Item added |
| ✅ | TC-004 | View Cart | Correct items |
| ❌ | TC-005 | Checkout | Form validation error |
| ❌ | TC-006 | Payment | Timeout |
| ✅ | TC-007 | Contact Form | Sent successfully |

---

## ❌ Failed Tests

### TC-005: Checkout
| | |
|---|---|
| **Status** | ❌ FAILED |
| **Screenshot** | [screenshots/tc005.jpg](screenshots/tc005.jpg) |

**Expected:** Proceed to payment
**Actual:** "Invalid phone number" error for valid input

---

### TC-006: Payment
| | |
|---|---|
| **Status** | ❌ FAILED |
| **Screenshot** | [screenshots/tc006.jpg](screenshots/tc006.jpg) |

**Expected:** Payment completes
**Actual:** Timeout after 30s

---

## 🐛 Issues Found

### Issue #1: Phone Validation Bug
| | |
|---|---|
| **Severity** | 🔴 High |
| **Test** | TC-005 |

Valid phone numbers rejected by validation.

### Issue #2: Payment API Timeout
| | |
|---|---|
| **Severity** | 🔴 High |
| **Test** | TC-006 |

Payment API not responding.

---

## 📋 Recommendations

### 🔴 High Priority
1. Fix phone number validation regex
2. Check payment API endpoint health

---

## 📸 Screenshots

| Test | File |
|------|------|
| TC-001 | [tc001-homepage.jpg](screenshots/tc001-homepage.jpg) |
| TC-005 | [tc005-checkout-error.jpg](screenshots/tc005-checkout-error.jpg) |
| TC-006 | [tc006-payment-timeout.jpg](screenshots/tc006-payment-timeout.jpg) |
```

## Instructions

1. **Generate timestamped filename** - Use `test-report-$(date +%Y%m%d-%H%M%S).md`
2. **Record execution time** - Include start time and duration in header
3. **Read test cases** - Load test case IDs from `./tests/test-cases.yaml`
4. **Collect results** - Match results to test case IDs
5. **Use symbols** - ✅ ❌ ⏭️ for every test status
6. **Create table** - Summary table with counts
7. **Detail failures** - Each failed test with screenshots and steps
8. **List issues** - With severity indicators
9. **Add recommendations** - Prioritized action items
10. **Report file location** - Tell user where the report was saved

## Input

Read test case definitions from:
- `./tests/config.yaml` - Project configuration
- `./tests/test-cases.yaml` - Test case definitions with IDs

## Output

**File naming with timestamp (IMPORTANT):**

Each test run generates a NEW report file with timestamp to preserve history:

```
./test-output/test-report-YYYYMMDD-HHMMSS.md
```

**Example:**
```
./test-output/test-report-20241215-143025.md
./test-output/test-report-20241215-160512.md
./test-output/test-report-20241216-091030.md
```

**Generate filename:**
```bash
REPORT_FILE="./test-output/test-report-$(date +%Y%m%d-%H%M%S).md"
echo "Report will be saved to: $REPORT_FILE"
```

**Why timestamped files:**
- Preserves test history across multiple runs
- User can compare results between runs
- Avoids overwriting previous test results
- Allows tracking of test improvements over time

## Related Skills

| Skill | Relationship |
|-------|--------------|
| web-test | Runs tests, calls this skill to generate report |
| web-test-case-gen | Generates test cases that this skill references |
| web-test-cleanup | Clean up after report (use --keep-data) |
