---
name: pytest-testing
description: Guide for writing pytest tests following this project's patterns including fixtures, mocking, and test organization.
---
# Pytest Testing

Use this skill when writing tests for this FastAPI application. Follow these patterns for consistency.

For comprehensive testing guidelines, see `tests/AGENTS.md`.

## Test Organization

| Category | Path | Focus |
|----------|------|-------|
| Unit | `tests/unit/` | Models, config, services, middleware |
| Integration | `tests/integration/` | API routes with mocked services |
| E2E | `tests/e2e/` | Real Firebase emulator tests |

Additional directories:
- `tests/helpers/` - Factory functions, auth helpers, assertion utilities
- `tests/mocks/` - Fake Firestore client, Firebase mocks, service stubs

Mirror the `app/` structure in test directories.

## Unit vs Integration vs E2E: The Simple Rule

> **If your test uses the `client` fixture (real app TestClient), it's an integration test.**
> **If your test uses Firebase emulators, it's an E2E test.**
> **Everything else is a unit test.**

| Criterion | Unit Test | Integration Test | E2E Test |
|-----------|-----------|------------------|----------|
| Uses `client` fixture? | No | Yes | Yes |
| Mocks ProfileService? | N/A | Yes | No |
| Uses real Firestore? | No | No | Yes (emulator) |
| Included in CI? | Yes | Yes | No |

## Integration Test Pattern

Integration tests use the FastAPI TestClient with mocked services via `tests/integration/conftest.py`:

```python
"""
Integration tests for resource endpoints.
"""

from unittest.mock import AsyncMock

import pytest
from fastapi.testclient import TestClient

from app.exceptions import ResourceAlreadyExistsError, ResourceNotFoundError
from tests.helpers.resources import make_resource, make_resource_payload_dict

BASE_URL = "/v1/resource"


class TestCreateResource:
    """
    Tests for POST /v1/resource.
    """

    def test_returns_201_on_success(
        self,
        client: TestClient,
        with_fake_user: None,
        mock_resource_service: AsyncMock,
    ) -> None:
        """
        Verify successful resource creation returns 201.
        """
        mock_resource_service.create_resource.return_value = make_resource()

        response = client.post(BASE_URL, json=make_resource_payload_dict())

        assert response.status_code == 201
        assert "Location" in response.headers
        mock_resource_service.create_resource.assert_awaited_once()

    def test_returns_409_when_duplicate(
        self,
        client: TestClient,
        with_fake_user: None,
        mock_resource_service: AsyncMock,
    ) -> None:
        """
        Verify duplicate resource returns 409 Conflict.
        """
        mock_resource_service.create_resource.side_effect = ResourceAlreadyExistsError()

        response = client.post(BASE_URL, json=make_resource_payload_dict())

        assert response.status_code == 409
        body = response.json()
        assert body["title"] == "Resource already exists"

    def test_returns_401_without_auth(
        self,
        client: TestClient,
        mock_resource_service: AsyncMock,
    ) -> None:
        """
        Verify unauthenticated request returns 401.
        """
        response = client.post(BASE_URL, json=make_resource_payload_dict())

        assert response.status_code == 401
```

## Integration Fixtures

The `tests/integration/conftest.py` provides:
- `client` - TestClient with mocked services injected via `dependency_overrides`
- `fake_user` - Simple fake FirebaseUser
- `with_fake_user` - Override auth dependency to return fake user
- `mock_resource_service` - AsyncMock of service for assertion

```python
# tests/integration/conftest.py
@pytest.fixture
def mock_resource_service() -> AsyncMock:
    """
    Mocked ResourceService for integration tests.
    """
    return AsyncMock(spec=ResourceService)


@pytest.fixture
def client(mock_resource_service: AsyncMock) -> Generator[TestClient]:
    """
    TestClient with mocked services (no Firebase/Firestore).
    """
    from app.main import app

    with (
        patch("app.main.initialize_firebase"),
        patch("app.main.setup_logging"),
        patch("app.main.close_async_firestore_client"),
    ):
        app.dependency_overrides[get_resource_service] = lambda: mock_resource_service
        with TestClient(app, raise_server_exceptions=False) as c:
            yield c
        app.dependency_overrides.clear()


@pytest.fixture
def with_fake_user(fake_user: FirebaseUser) -> Generator[None]:
    """
    Override auth to return fake user.
    """
    from app.main import app

    app.dependency_overrides[verify_firebase_token] = lambda: fake_user
    yield
    app.dependency_overrides.pop(verify_firebase_token, None)
```

## Helper Functions

Create factory functions in `tests/helpers/`:

```python
# tests/helpers/resources.py
from datetime import UTC, datetime

from app.models.resource import Resource, ResourceCreate


def make_resource(
    resource_id: str = "test-resource-123",
    **kwargs: object,
) -> Resource:
    """
    Create a Resource instance for testing.
    """
    now = datetime.now(UTC)
    base = {
        "name": "Test Resource",
        "active": True,
        "created_at": now,
        "updated_at": now,
    }
    return Resource(id=resource_id, **{**base, **kwargs})


def make_resource_payload_dict(
    *,
    overrides: dict[str, object] | None = None,
    omit: list[str] | None = None,
) -> dict[str, object]:
    """
    Build a plain dict payload for POST/PUT requests.
    """
    payload: dict[str, object] = {
        "name": "Test Resource",
        "active": True,
    }
    if overrides:
        payload.update(overrides)
    if omit:
        for key in omit:
            payload.pop(key, None)
    return payload
```

## Parametrized Tests

Use `@pytest.mark.parametrize` for data-driven tests:

```python
@pytest.mark.parametrize(
    "missing_field",
    ["name", "email", "phone_number"],
)
def test_returns_422_for_missing_fields(
    self,
    client: TestClient,
    with_fake_user: None,
    missing_field: str,
) -> None:
    """
    Verify missing required fields return 422.
    """
    payload = make_resource_payload_dict(omit=[missing_field])

    response = client.post(BASE_URL, json=payload)

    assert response.status_code == 422
```

## Async Tests

With `asyncio_mode = "auto"` in pyproject.toml, no decorator is needed:

```python
async def test_async_operation() -> None:
    """
    Async test runs automatically without @pytest.mark.asyncio.
    """
    result = await some_async_function()
    assert result is not None
```

## Mocking Patterns

Use `pytest-mock` (`mocker` fixture) for patching:

```python
def test_with_mock(mocker: MockerFixture) -> None:
    mock_client = mocker.patch("app.services.resource.get_async_firestore_client")
    mock_client.return_value = FakeAsyncClient()
    # ... test code
```

Use `monkeypatch` for environment variables:

```python
def test_with_env(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("DEBUG", "true")
    get_settings.cache_clear()
    # ... test code
```

## Test Naming

Pattern: `test_<what>_<condition/scenario>`

```python
def test_create_resource_returns_201_on_success() -> None: ...
def test_get_resource_returns_404_when_not_found() -> None: ...
def test_update_resource_with_invalid_email_returns_422() -> None: ...
```

## URL Conventions

Always use paths without trailing slashes to match routes:

```python
# Correct - use versioned path without trailing slash
response = client.get("/v1/resource")

# Wrong - trailing slash returns 404 (redirect_slashes=False)
response = client.get("/v1/resource/")
```

## HTTP Mocking with pytest-httpx

Use the `httpx_mock` fixture to mock outbound HTTP requests:

```python
from pytest_httpx import HTTPXMock

def test_outbound_call(httpx_mock: HTTPXMock) -> None:
    httpx_mock.add_response(
        method="GET",
        url="https://example.com/api/status",
        json={"ok": True},
        status_code=200,
    )

    resp = httpx.get("https://example.com/api/status")
    assert resp.json() == {"ok": True}
```

## Fake Firestore for Unit Tests

Use `tests/mocks/firestore.py` for service unit tests:

```python
from pytest_mock import MockerFixture
from tests.mocks.firestore import FakeAsyncClient

@pytest.fixture
def fake_db(mocker: MockerFixture) -> FakeAsyncClient:
    db = FakeAsyncClient()
    mocker.patch("app.services.resource.get_async_firestore_client", return_value=db)
    return db


class TestResourceServiceGetResource:
    async def test_returns_resource_when_exists(self, fake_db: FakeAsyncClient) -> None:
        fake_db._store["user-123"] = _make_resource_data(user_id="user-123")
        service = ResourceService()
        resource = await service.get_resource("user-123")
        assert resource.id == "user-123"
```

## Running Tests

```bash
just test               # Unit + integration (CI-compatible)
just test-unit          # Unit tests only
just test-integration   # Integration tests only
just test-e2e           # E2E tests (requires: just emulators)
just cov                # Coverage report
```
