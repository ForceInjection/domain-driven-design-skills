---
name: test-writing-patterns
version: 1.0.0
description: Test structure, patterns, assertions, and test doubles
---
# Test Writing Patterns
## When to Use
- Need test structure guidance
- Questions about test doubles (mock/stub/fake/spy)
- Test organization questions
- Framework-agnostic test patterns

## Test Structure Patterns
### AAA Pattern (Arrange-Act-Assert)
```
# Arrange - Set up test data and preconditions
user = User(name="alice")
calculator = Calculator()

# Act - Execute behavior being tested
result = calculator.add(2, 3)

# Assert - Verify expected outcome
assert result == 5
```

### Given-When-Then (BDD Style)
```
# Given - Preconditions
given_user_exists("alice")

# When - Action
result = login("alice", "password")

# Then - Verification
then_user_is_authenticated(result)
```

## Test Doubles
| Type | Purpose | When to Use |
|------|---------|-------------|
| **Mock** | Verify interactions | Check method was called |
| **Stub** | Provide canned responses | Replace dependency output |
| **Fake** | Working implementation | Lightweight replacement |
| **Spy** | Record calls | Verify calls while keeping behavior |

### Mock Example
```python
mock_db = Mock()
service = UserService(db=mock_db)
service.create_user("alice")
mock_db.save.assert_called_once_with("alice")
```

### Stub Example
```python
stub_api = Mock()
stub_api.get_user.return_value = {"name": "alice"}
result = service.fetch_user(api=stub_api)
assert result["name"] == "alice"
```

## Assertion Patterns
### Good Assertions
- Specific expected values
- Descriptive failure messages
- One concept per assertion
```python
assert result == 5, f"Expected 5, got {result}"
assert user.is_active is True
assert "error" in response.json()
```

### Poor Assertions
```python
assert result  # Not specific
assert True  # Always passes
assert result != None  # Use is not None
```

## Test Organization
```
tests/
├── unit/           # Fast, isolated tests
├── integration/    # Component interaction tests
└── e2e/           # Full system tests
```

### Naming Convention
```
test_[unit]_[scenario]_[expected]

test_add_two_positive_numbers_returns_sum
test_login_invalid_password_returns_error
test_create_user_duplicate_email_raises_exception
```

## Common Test Patterns
### Setup/Teardown
- `setUp()` / `tearDown()` for each test
- Fixtures for shared resources
- Clean state between tests

### Parameterized Tests
Run same test with different data:
```python
@pytest.mark.parametrize("a,b,expected", [(1,2,3), (0,0,0), (-1,1,0)])
def test_add(a, b, expected):
    assert add(a, b) == expected
```

### Test Independence
- Tests don't depend on each other
- Tests can run in any order
- Each test sets up its own state

## Anti-Patterns
❌ Tests depending on other tests
❌ Testing implementation details
❌ Slow tests in unit suite
❌ No assertions
❌ Commenting out failing tests
