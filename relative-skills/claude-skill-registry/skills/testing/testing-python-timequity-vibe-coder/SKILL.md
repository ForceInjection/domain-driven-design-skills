---
name: testing-python
description: |
  Python testing best practices with pytest. Covers unit, integration, async tests, mocking, fixtures.
  Triggers: "напиши тесты", "write tests", "add tests", "test coverage", "pytest"
---

# Python Testing

Modern Python testing with pytest ecosystem.

## Tooling

**ALWAYS use:**
- `pytest` — test runner
- `pytest-cov` — coverage
- `pytest-asyncio` — async tests
- `pytest-mock` — mocking (wraps unittest.mock)
- `hypothesis` — property-based testing (when appropriate)
- `respx` / `pytest-httpx` — HTTP mocking for httpx
- `aioresponses` — HTTP mocking for aiohttp

**NEVER use:**
- `unittest` style (use pytest native)
- `nose` (deprecated)
- `mock` standalone (use pytest-mock)

## Quick Start

### Install

```bash
uv add --dev pytest pytest-cov pytest-asyncio pytest-mock
```

### pyproject.toml

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
asyncio_default_fixture_loop_scope = "function"
addopts = [
    "-ra",
    "-q",
    "--strict-markers",
    "--strict-config",
]
markers = [
    "slow: marks tests as slow",
    "integration: marks tests as integration tests",
]

[tool.coverage.run]
source = ["src"]
branch = true

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
]
```

### Directory Structure

```
project/
├── src/
│   └── mypackage/
│       ├── __init__.py
│       └── service.py
└── tests/
    ├── conftest.py          # Shared fixtures
    ├── unit/
    │   └── test_service.py
    └── integration/
        └── test_api.py
```

## Patterns

### Basic Test

```python
# tests/unit/test_calculator.py
import pytest
from mypackage.calculator import add, divide

def test_add_positive_numbers():
    assert add(2, 3) == 5

def test_add_negative_numbers():
    assert add(-1, -1) == -2

def test_divide_by_zero_raises():
    with pytest.raises(ZeroDivisionError):
        divide(1, 0)
```

### Parametrized Tests

```python
import pytest

@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("World", "WORLD"),
    ("", ""),
    ("123", "123"),
])
def test_uppercase(input, expected):
    assert input.upper() == expected


@pytest.mark.parametrize("a,b,expected", [
    (1, 2, 3),
    (0, 0, 0),
    (-1, 1, 0),
])
def test_add(a, b, expected):
    assert add(a, b) == expected
```

### Fixtures

```python
# tests/conftest.py
import pytest
from mypackage.database import Database

@pytest.fixture
def sample_user():
    """Simple data fixture."""
    return {"id": 1, "name": "Test User", "email": "test@example.com"}


@pytest.fixture
def db():
    """Setup/teardown fixture."""
    database = Database(":memory:")
    database.connect()
    yield database
    database.disconnect()


@pytest.fixture(scope="module")
def expensive_resource():
    """Shared across module (use sparingly)."""
    resource = create_expensive_resource()
    yield resource
    resource.cleanup()
```

### Async Tests

```python
import pytest
from mypackage.api import fetch_user

# With asyncio_mode = "auto", no decorator needed
async def test_fetch_user():
    user = await fetch_user(1)
    assert user["id"] == 1


# Async fixture
@pytest.fixture
async def async_client():
    async with AsyncClient() as client:
        yield client


async def test_with_async_client(async_client):
    response = await async_client.get("/users")
    assert response.status_code == 200
```

### Mocking

```python
from unittest.mock import AsyncMock
import pytest

def test_send_email(mocker):
    """Mock external service."""
    mock_send = mocker.patch("mypackage.email.send_email")
    mock_send.return_value = True

    result = notify_user("test@example.com", "Hello")

    assert result is True
    mock_send.assert_called_once_with("test@example.com", "Hello")


async def test_external_api(mocker):
    """Mock async function."""
    mock_fetch = mocker.patch(
        "mypackage.client.fetch_data",
        new_callable=AsyncMock,
        return_value={"data": "mocked"}
    )

    result = await process_data()

    assert result["data"] == "mocked"
    mock_fetch.assert_awaited_once()
```

### HTTP Mocking (httpx)

```python
import pytest
import httpx
import respx

@respx.mock
async def test_api_call():
    respx.get("https://api.example.com/users/1").respond(
        json={"id": 1, "name": "John"}
    )

    async with httpx.AsyncClient() as client:
        response = await client.get("https://api.example.com/users/1")

    assert response.json()["name"] == "John"


# Or as fixture
@pytest.fixture
def mock_api():
    with respx.mock:
        yield respx


async def test_with_fixture(mock_api):
    mock_api.get("https://api.example.com/data").respond(json={"ok": True})
    # ... test code
```

### Exception Testing

```python
import pytest
from mypackage.validator import validate_email

def test_invalid_email_raises():
    with pytest.raises(ValueError) as exc_info:
        validate_email("not-an-email")

    assert "Invalid email format" in str(exc_info.value)


def test_specific_exception_attributes():
    with pytest.raises(ValidationError) as exc_info:
        validate_input({"bad": "data"})

    assert exc_info.value.field == "email"
    assert exc_info.value.code == "required"
```

### Markers

```python
import pytest

@pytest.mark.slow
def test_complex_calculation():
    """Run with: pytest -m slow"""
    result = heavy_computation()
    assert result is not None


@pytest.mark.integration
async def test_database_connection():
    """Run with: pytest -m integration"""
    async with get_connection() as conn:
        assert await conn.ping()


@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    pass


@pytest.mark.skipif(sys.platform == "win32", reason="Unix only")
def test_unix_specific():
    pass
```

## Running Tests

```bash
# Run all tests
pytest

# With coverage
pytest --cov --cov-report=term-missing

# Specific file/test
pytest tests/unit/test_service.py
pytest tests/unit/test_service.py::test_specific_function

# By marker
pytest -m "not slow"
pytest -m integration

# Verbose with print output
pytest -v -s

# Stop on first failure
pytest -x

# Run last failed
pytest --lf

# Parallel (requires pytest-xdist)
pytest -n auto
```

## Coverage

```bash
# Terminal report
pytest --cov=src --cov-report=term-missing

# HTML report
pytest --cov=src --cov-report=html
open htmlcov/index.html

# Fail if below threshold
pytest --cov=src --cov-fail-under=80
```

## Best Practices

### DO:
- One assertion per test (usually)
- Descriptive test names: `test_<what>_<condition>_<expected>`
- Use fixtures for setup/teardown
- Test edge cases: empty, None, negative, boundary values
- Test error paths, not just happy paths
- Keep tests fast (mock external services)
- Use `pytest.raises` for exception testing

### DON'T:
- Test implementation details
- Use `time.sleep()` in tests
- Share state between tests
- Test private methods directly
- Write tests that depend on execution order
- Mock everything (some integration is good)

## References

- [Pytest Fixtures](./references/fixtures.md)
- [Async Testing](./references/async-testing.md)
- [Mocking Patterns](./references/mocking.md)

## Agent

Use the **python-test-writer** agent for generating comprehensive tests:

```
Task: python-test-writer
Prompt: Write tests for src/mypackage/service.py
```

See [agents/python-test-writer.md](./agents/python-test-writer.md)
