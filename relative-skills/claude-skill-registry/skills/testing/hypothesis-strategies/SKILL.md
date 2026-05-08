---
name: hypothesis-strategies
description: Custom Hypothesis strategy patterns for property-based testing. Activated when designing test data generators or property tests.
---

# Hypothesis strategies

## Purpose

Guide for designing custom Hypothesis strategies for property-based testing. Covers strategy composition, custom generators, and shrinking behavior.

## When to use

This skill activates when:

- Creating custom data generators
- Composing complex test inputs
- Designing property-based tests
- Debugging shrinking behavior
- Generating domain-specific data

## Core concepts

### Basic strategies

```python
from hypothesis import strategies as st

# Basic types
text = st.text()
integers = st.integers()
floats = st.floats()
booleans = st.booleans()

# Constrained types
positive_ints = st.integers(min_value=1)
short_text = st.text(max_size=100)
ascii_text = st.text(alphabet=string.ascii_letters)
```

### Strategy composition

```python
from hypothesis import strategies as st

# Combine strategies
point = st.tuples(st.floats(), st.floats())
person = st.fixed_dictionaries({
    'name': st.text(min_size=1),
    'age': st.integers(min_value=0, max_value=150),
})

# One of multiple options
value = st.one_of(st.text(), st.integers(), st.booleans())

# Optional values
maybe_text = st.text() | st.none()
```

## Custom strategies

### Using @composite

```python
from hypothesis import strategies as st
from hypothesis.strategies import composite, DrawFn

@composite
def valid_identifiers(draw: DrawFn) -> str:
    """Generate valid Python identifiers."""
    first = draw(st.sampled_from(string.ascii_letters + '_'))
    rest = draw(st.text(
        alphabet=string.ascii_letters + string.digits + '_',
        max_size=30
    ))
    return first + rest

@composite
def valid_emails(draw: DrawFn) -> str:
    """Generate valid email addresses."""
    local = draw(st.text(
        alphabet=string.ascii_lowercase + string.digits + '._',
        min_size=1,
        max_size=64,
    ))
    domain = draw(st.text(
        alphabet=string.ascii_lowercase,
        min_size=1,
        max_size=20,
    ))
    tld = draw(st.sampled_from(['com', 'org', 'net', 'io']))
    return f"{local}@{domain}.{tld}"
```

### Building from existing strategies

```python
@composite
def config_dicts(draw: DrawFn) -> dict:
    """Generate valid configuration dictionaries."""
    name = draw(valid_identifiers())
    options = draw(st.lists(st.text(), max_size=10))
    enabled = draw(st.booleans())
    timeout = draw(st.integers(min_value=1, max_value=3600) | st.none())

    config = {
        'name': name,
        'options': options,
        'enabled': enabled,
    }

    if timeout is not None:
        config['timeout'] = timeout

    return config
```

### Recursive strategies

```python
@composite
def nested_dicts(draw: DrawFn, max_depth: int = 3) -> dict:
    """Generate nested dictionary structures."""
    if max_depth <= 0:
        # Base case: simple values only
        return draw(st.fixed_dictionaries({
            'value': st.one_of(st.text(), st.integers(), st.booleans())
        }))

    # Recursive case
    return draw(st.fixed_dictionaries({
        'value': st.one_of(st.text(), st.integers(), st.booleans()),
        'children': st.lists(
            st.deferred(lambda: nested_dicts(max_depth=max_depth - 1)),
            max_size=3
        )
    }))
```

## Strategy for domain types

### Dataclass strategies

```python
from dataclasses import dataclass
from hypothesis import strategies as st

@dataclass
class User:
    id: int
    name: str
    email: str
    active: bool

@composite
def users(draw: DrawFn) -> User:
    """Generate valid User instances."""
    return User(
        id=draw(st.integers(min_value=1)),
        name=draw(st.text(min_size=1, max_size=100)),
        email=draw(valid_emails()),
        active=draw(st.booleans()),
    )
```

### Enum strategies

```python
from enum import Enum

class Status(Enum):
    PENDING = 'pending'
    ACTIVE = 'active'
    COMPLETED = 'completed'

# Generate any status
status_strategy = st.sampled_from(Status)

# Generate only certain statuses
active_statuses = st.sampled_from([Status.PENDING, Status.ACTIVE])
```

## Using with @given

### Basic usage

```python
from hypothesis import given

@given(users())
def test_user_has_valid_id(user: User):
    """User IDs are always positive."""
    assert user.id > 0

@given(st.lists(users(), min_size=1))
def test_user_list_not_empty(users: list[User]):
    """Generated user lists have at least one user."""
    assert len(users) >= 1
```

### With assume

```python
from hypothesis import given, assume

@given(st.integers(), st.integers())
def test_division(a: int, b: int):
    """Test division with valid divisor."""
    assume(b != 0)
    result = a / b
    assert result * b == a
```

### Multiple strategies

```python
@given(
    user=users(),
    permissions=st.lists(st.sampled_from(['read', 'write', 'admin'])),
)
def test_user_with_permissions(user: User, permissions: list[str]):
    """Test user with various permission sets."""
    result = apply_permissions(user, permissions)
    assert all(p in result.permissions for p in permissions)
```

## Controlling shrinking

```python
@composite
def ids_with_checksum(draw: DrawFn) -> str:
    """Generate IDs where parts must stay together during shrinking."""
    # Use map to preserve relationships during shrinking
    parts = draw(st.lists(st.integers(min_value=0, max_value=9), min_size=4, max_size=4))
    checksum = sum(parts) % 10
    return ''.join(map(str, parts)) + str(checksum)
```

## Debugging strategies

```python
# See what a strategy generates
from hypothesis import settings, Verbosity

@settings(verbosity=Verbosity.verbose)
@given(users())
def test_debug_user_generation(user: User):
    """See generated values."""
    pass  # Values printed to output

# Generate examples without running tests
from hypothesis import find

# Find example that satisfies predicate
example = find(users(), lambda u: u.active and len(u.name) > 5)
```

## Checklist

- [ ] Strategy generates valid domain data
- [ ] Edge cases covered (empty, max size, special values)
- [ ] Constraints properly enforced
- [ ] Shrinking produces meaningful minimal examples
- [ ] Strategy is composable with others

---

**Additional resources:**

- [Hypothesis documentation](https://hypothesis.readthedocs.io/)
- [Strategy reference](https://hypothesis.readthedocs.io/en/latest/data.html)
