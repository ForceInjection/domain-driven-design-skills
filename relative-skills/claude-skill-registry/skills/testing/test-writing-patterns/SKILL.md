---
name: test-writing-patterns
description: Guide experienced developers on test structure, patterns, assertions, and test doubles for effective test-driven development
license: Complete terms in LICENSE.txt
---

# Test Writing Patterns
**Version:** {{VERSION}}

## When to Use

- User needs guidance on test structure
- Questions about test organization
- Need test double (mock/stub/fake) guidance
- Uncertainty about assertion strategies

## Test Structure Patterns

### AAA Pattern (Arrange-Act-Assert)

```
ARRANGE: Set up test conditions and inputs
ACT: Execute the behavior being tested
ASSERT: Verify the expected outcome
```

### Given-When-Then Pattern (BDD Style)

```
GIVEN: Initial context/preconditions
WHEN: Action/event occurs
THEN: Expected outcomes
```

## Test Organization

### File Organization

```
Production:
  src/services/user_service

Tests:
  tests/services/test_user_service
```

### Test Naming

```
test_[unit]_[scenario]_[expected]

Examples:
- test_add_positive_numbers_returns_sum
- test_get_user_when_not_found_returns_null
```

## Assertion Strategies

### Single Concept Per Test

**Good:** All assertions verify the same concept
**Poor:** Multiple unrelated assertions in one test

### Common Assertion Types

- **Equality:** `assert actual == expected`
- **Truthiness:** `assert condition is true`
- **Comparison:** `assert value > 0`
- **Collection:** `assert item in collection`
- **Exception:** `assert raises(ExpectedException)`

## Test Doubles

### Types

| Type | Purpose | When to Use |
|------|---------|-------------|
| **Stub** | Provide predetermined responses | Control dependency behavior |
| **Mock** | Verify interactions/calls | Check method was called |
| **Fake** | Working simplified implementation | Integration testing |
| **Spy** | Record calls while delegating | Need real behavior + verification |

### Selection Guide

```
Need to control response? -> Stub
Need to verify call made? -> Mock
Need working but simple version? -> Fake
Need real behavior + verification? -> Spy
```

## Test Isolation

Each test should:
- Set up its own data
- Clean up after itself
- Run in any order
- Not depend on other tests

## Test Data Strategies

### Explicit Test Data
```
Good: user = create_user(name="Alice", age=30)
Poor: user = create_user(name=random_string())
```

### Minimal Test Data
Use simplest data that tests the behavior.

## Testing Strategies by Type

### Unit Tests
- Test single unit
- Fast execution
- No external dependencies

### Integration Tests
- Test multiple units together
- May use real dependencies

### End-to-End Tests
- Test complete user workflows
- Use real system

## Test Coverage

**Coverage shows:**
- Which code is executed by tests
- Which code is NOT executed

**Coverage does NOT mean:**
- All behaviors tested
- Tests are good quality
- Code is correct

## Test Smells

| Smell | Fix |
|-------|-----|
| Test does too much | Split into focused tests |
| Tests are brittle | Test behavior, not implementation |
| Tests are slow | Use test doubles, optimize setup |
| Tests are unclear | Better naming, clear AAA structure |
| Tests depend on each other | Ensure test isolation |

## Parameterized Tests

```
test_add_numbers:
  parameters:
    (2, 3, 5)
    (-2, -3, -5)
    (0, 0, 0)

  for each (a, b, expected):
    assert add(a, b) == expected
```

## Resources

- `resources/aaa-pattern-template.md`
- `resources/test-doubles-guide.md`
- `resources/assertion-patterns.md`
- `resources/test-organization-examples.md`

---

**End of Test Writing Patterns Skill**
