---
name: qa-testing-methodology
description: QA best practices and test design patterns. Use when designing test cases to ensure comprehensive coverage with equivalence partitioning, boundary analysis, and accessibility testing.
---

# QA Testing Methodology Skill

Apply proven test design patterns for comprehensive test coverage.

## Test Case Design Order

Always design tests in this order:

1. **Happy Path** - Main success scenarios
2. **Validation Tests** - Required fields, format validation
3. **Edge Cases** - Boundary conditions, limits
4. **Error Scenarios** - Invalid inputs, system errors
5. **Permission Tests** - Access control, authorization

## Equivalence Partitioning

Divide input data into partitions where all values should behave identically.

### Example: Age Input Field (18-65)

| Partition | Values | Expected Behavior |
|-----------|--------|-------------------|
| Below minimum | 0-17 | Reject with "Must be 18+" |
| Valid range | 18-65 | Accept |
| Above maximum | 66+ | Reject with "Maximum age is 65" |
| Invalid | -1, "abc", empty | Reject with validation error |

**Test Strategy**: Test ONE value from each partition, not every value.

## Boundary Value Analysis

Focus testing on boundaries where behavior changes.

### Example: Password (8-20 characters)

| Boundary | Test Values | Expected |
|----------|-------------|----------|
| Just below minimum | 7 chars | Reject |
| At minimum | 8 chars | Accept |
| Just above minimum | 9 chars | Accept |
| Just below maximum | 19 chars | Accept |
| At maximum | 20 chars | Accept |
| Just above maximum | 21 chars | Reject |

## Test Prioritization Matrix

Prioritize tests based on risk and frequency:

| Priority | Risk | User Impact | Test Frequency |
|----------|------|-------------|----------------|
| **Critical** | Data loss, security breach | All users blocked | Every build |
| **High** | Feature broken | Major workflow impacted | Every release |
| **Medium** | Inconvenient | Workaround available | Weekly |
| **Low** | Minor annoyance | Cosmetic issues | Monthly |

## Accessibility Testing Checklist

Include in every test procedure:

### Keyboard Navigation
- [ ] All interactive elements focusable with Tab
- [ ] Focus order is logical (left-to-right, top-to-bottom)
- [ ] Focus indicator is visible
- [ ] No keyboard traps

### Screen Reader
- [ ] All images have alt text
- [ ] Form fields have labels
- [ ] Error messages announced
- [ ] Headings structured correctly (h1 → h2 → h3)

### Visual
- [ ] Color contrast meets WCAG AA (4.5:1 for text)
- [ ] Information not conveyed by color alone
- [ ] Text resizable to 200% without loss
- [ ] No content flashes more than 3 times/second

## Performance Considerations

Note performance during manual testing:

| Metric | Acceptable | Needs Investigation |
|--------|------------|---------------------|
| Page load | < 3 seconds | > 3 seconds |
| Button response | < 100ms | > 300ms |
| Form submission | < 2 seconds | > 5 seconds |
| Search results | < 1 second | > 2 seconds |

## Test Data Guidelines

### DO
- Use realistic but fake data
- Document exact test data in test cases
- Use consistent test accounts
- Reset test data between runs when needed

### DON'T
- Use production data
- Use generic placeholders ("enter something")
- Share test credentials in plain text
- Assume data from previous tests exists

### Test Data Examples

```
Email: test.user@example.com
Password: Test@1234! (in password manager)
Phone: +1-555-0100 (test range)
Credit Card: 4111-1111-1111-1111 (test card)
Address: 123 Test Street, Test City, TS 12345
```

## Regression Testing

When to run regression tests:

| Trigger | Regression Scope |
|---------|------------------|
| Bug fix | Related feature + integration points |
| New feature | All features that share data/UI |
| Dependency update | Full regression |
| Release candidate | Critical + High priority tests |

## State-Based Testing

Test all valid state transitions:

```
Example: Order Status
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌───────────┐
│ Created │ ──▶ │ Pending │ ──▶ │ Shipped │ ──▶ │ Delivered │
└─────────┘     └─────────┘     └─────────┘     └───────────┘
                     │                               │
                     ▼                               ▼
               ┌───────────┐                  ┌────────────┐
               │ Cancelled │                  │  Returned  │
               └───────────┘                  └────────────┘
```

Test:
- Valid transitions (Created → Pending)
- Invalid transitions (Delivered → Created)
- Edge cases (Cancel while shipping)

## Error Message Verification

Check error messages for:

1. **Clarity**: User understands what went wrong
2. **Actionability**: User knows how to fix it
3. **Tone**: Professional, not blaming
4. **Security**: No sensitive information exposed

### Good vs Bad Error Messages

| Bad | Good |
|-----|------|
| "Error 500" | "Something went wrong. Please try again." |
| "Invalid input" | "Email must be in format: name@example.com" |
| "User not found in database" | "No account found with this email" |
| "Password must match regex..." | "Password needs 8+ characters with a number" |

## Cross-Browser Testing Matrix

Minimum browser coverage:

| Browser | Desktop | Mobile |
|---------|---------|--------|
| Chrome | Latest, Latest-1 | Android |
| Safari | Latest | iOS |
| Firefox | Latest | - |
| Edge | Latest | - |

## Test Documentation Patterns

### When to Screenshot

- Initial state before test
- After critical actions
- Error states
- Final/success state
- Any unexpected behavior

### Writing Clear Steps

**Bad**: Click the button
**Good**: Click the blue "Submit" button in the bottom-right of the form

**Bad**: Enter your details
**Good**: Enter "test@example.com" in the Email field

**Bad**: Verify it works
**Good**: Verify success message "Order placed successfully" appears

## Mobile Testing Considerations

- Test touch targets (minimum 44x44 pixels)
- Test swipe gestures where applicable
- Test orientation changes (portrait ↔ landscape)
- Test with on-screen keyboard visible
- Test with poor network (3G simulation)
