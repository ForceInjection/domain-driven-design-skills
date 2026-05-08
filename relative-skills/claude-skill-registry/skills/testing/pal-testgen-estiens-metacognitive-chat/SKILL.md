---
name: pal-testgen
description: Comprehensive test suite generation with edge case coverage using PAL MCP. Use for creating tests, improving coverage, or identifying untested paths. Triggers on test generation requests, coverage improvement, or testing strategy.
---

# PAL Test Generation

Create comprehensive test suites with edge case coverage.

## When to Use

- Generating tests for new code
- Improving test coverage
- Identifying edge cases
- Creating regression tests
- Testing complex business logic
- Framework-specific test generation

## Quick Start

```python
result = mcp__pal__testgen(
    step="Analyzing payment processor for test coverage",
    step_number=1,
    total_steps=2,
    next_step_required=True,
    findings="Identifying critical paths, edge cases, failure modes",
    relevant_files=[
        "/app/payments/processor.py",
        "/app/payments/validation.py"
    ],
    confidence="exploring"
)
```

## Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `step` | string | Test planning narrative |
| `step_number` | int | Current step |
| `total_steps` | int | Estimated total |
| `next_step_required` | bool | More planning needed? |
| `findings` | string | Test scenarios identified |

## Optional Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hypothesis` | string | Testing strategy |
| `confidence` | enum | exploring → certain |
| `relevant_files` | list | Files needing tests |
| `files_checked` | list | All files examined |
| `issues_found` | list | Coverage gaps found |
| `continuation_id` | string | Continue session |

## What to Document in Findings

### Functionality Coverage
- Core business logic paths
- Input validation
- Error handling
- Edge cases

### Test Categories
- **Unit tests** - Individual functions/methods
- **Integration tests** - Component interactions
- **Edge cases** - Boundary conditions
- **Error cases** - Failure scenarios

## Example: API Endpoint Tests

```python
mcp__pal__testgen(
    step="""
    Analyzing user registration endpoint for test coverage

    Identified paths:
    1. Happy path - valid registration
    2. Validation - email format, password strength
    3. Duplicates - existing email handling
    4. Rate limiting - abuse prevention
    5. Error cases - database failures
    """,
    step_number=1,
    total_steps=2,
    next_step_required=True,
    findings="""
    Critical test cases:
    - Valid registration creates user and returns token
    - Invalid email format returns 400
    - Weak password returns 400 with requirements
    - Duplicate email returns 409
    - Rate limit exceeded returns 429
    - Database error returns 500 and logs error

    Edge cases:
    - Unicode characters in name
    - Maximum length inputs
    - Empty string vs null vs missing field
    - SQL injection attempts (should be sanitized)
    """,
    relevant_files=[
        "/app/api/auth/register.py",
        "/app/models/user.py",
        "/tests/api/test_auth.py"
    ],
    confidence="medium"
)
```

## Test Template Patterns

### Unit Test
```python
def test_calculate_total_with_discount():
    # Arrange
    cart = Cart(items=[Item(price=100)])
    discount = Discount(percent=10)

    # Act
    total = cart.calculate_total(discount)

    # Assert
    assert total == 90
```

### Edge Case Test
```python
@pytest.mark.parametrize("input,expected", [
    ("", ValidationError),
    (None, ValidationError),
    ("a" * 1000, ValidationError),
    ("valid@email.com", "valid@email.com"),
])
def test_email_validation(input, expected):
    if isinstance(expected, type) and issubclass(expected, Exception):
        with pytest.raises(expected):
            validate_email(input)
    else:
        assert validate_email(input) == expected
```

## Best Practices

1. **Test behavior, not implementation** - Focus on what, not how
2. **One assertion per test** - Clear failure messages
3. **Descriptive names** - `test_user_cannot_access_admin_without_role`
4. **Arrange-Act-Assert** - Clear test structure
5. **Cover edge cases** - Boundaries, nulls, empty values
6. **Test error paths** - Failures are features too
