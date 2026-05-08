---
name: pytest-api-testing
description: Write pytest tests for FastAPI endpoints using TestClient including request/response testing, authentication, and error handling. Use when testing REST API endpoints.
---

# Pytest API Testing Specialist

Specialized in testing FastAPI endpoints with pytest and TestClient.

## When to Use This Skill

- Testing REST API endpoints
- Testing request/response validation
- Testing authentication and authorization
- Testing error responses
- Testing query parameters and pagination
- Integration testing of API flows

## Core Principles

- **Test First (TDD)**: Write tests before implementing endpoints
- **Test Client Pattern**: Use FastAPI's TestClient
- **Status Code Validation**: Always verify HTTP status codes
- **Response Schema Validation**: Validate response structure
- **Authentication Testing**: Test both authenticated and unauthenticated requests
- **Edge Case Coverage**: Test error conditions and edge cases

## Implementation Guidelines

### Basic API Endpoint Testing

```python
# tests/test_api_users.py
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_create_user_success():
    """Should create user with valid data."""
    # Arrange
    user_data = {
        "email": "test@example.com",
        "name": "Test User",
        "age": 30
    }

    # Act
    response = client.post("/users", json=user_data)

    # Assert
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == user_data["email"]
    assert data["name"] == user_data["name"]
    assert "id" in data

def test_create_user_invalid_email():
    """Should return 422 for invalid email."""
    user_data = {
        "email": "invalid",  # Invalid email format
        "name": "Test User"
    }

    response = client.post("/users", json=user_data)

    assert response.status_code == 422
    error = response.json()
    assert "email" in str(error).lower()

def test_get_user_success():
    """Should return user by ID."""
    # Create user first
    create_response = client.post("/users", json={
        "email": "get@example.com",
        "name": "Get User"
    })
    user_id = create_response.json()["id"]

    # Get user
    response = client.get(f"/users/{user_id}")

    assert response.status_code == 200
    data = response.json()
    assert data["id"] == user_id
    assert data["email"] == "get@example.com"

def test_get_user_not_found():
    """Should return 404 for non-existent user."""
    response = client.get("/users/99999")

    assert response.status_code == 404
    error = response.json()
    assert "not found" in error["error"].lower()
```

### Testing with Fixtures

```python
# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.database import Database

@pytest.fixture
def client():
    """Provide TestClient for API testing."""
    return TestClient(app)

@pytest.fixture
def test_database():
    """Provide test database with cleanup."""
    db = Database(":memory:")
    db.setup()
    yield db
    db.cleanup()

@pytest.fixture
def sample_user_data():
    """Provide sample user data."""
    return {
        "email": "fixture@example.com",
        "name": "Fixture User",
        "age": 25
    }

# tests/test_api_users.py
def test_create_user_with_fixtures(client, sample_user_data):
    """Test user creation using fixtures."""
    response = client.post("/users", json=sample_user_data)

    assert response.status_code == 201
    assert response.json()["email"] == sample_user_data["email"]
```

### Testing Authentication

```python
import pytest
from fastapi.testclient import TestClient

@pytest.fixture
def auth_headers(client):
    """Provide authentication headers.

    WHY: Create reusable authentication for protected endpoints.
    """
    # Create user and login
    client.post("/users", json={
        "email": "auth@example.com",
        "name": "Auth User",
        "password": "SecurePass123"
    })

    login_response = client.post("/auth/login", json={
        "email": "auth@example.com",
        "password": "SecurePass123"
    })

    token = login_response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}

def test_get_current_user_authenticated(client, auth_headers):
    """Should return current user with valid token."""
    response = client.get("/users/me", headers=auth_headers)

    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "auth@example.com"

def test_get_current_user_unauthenticated(client):
    """Should return 401 without authentication."""
    response = client.get("/users/me")

    assert response.status_code == 401

def test_get_current_user_invalid_token(client):
    """Should return 401 with invalid token."""
    response = client.get(
        "/users/me",
        headers={"Authorization": "Bearer invalid_token"}
    )

    assert response.status_code == 401
```

### Testing Query Parameters

```python
def test_list_users_default_pagination(client):
    """Should return users with default pagination."""
    # Create test users
    for i in range(5):
        client.post("/users", json={
            "email": f"user{i}@example.com",
            "name": f"User {i}"
        })

    response = client.get("/users")

    assert response.status_code == 200
    data = response.json()
    assert "users" in data
    assert "total" in data
    assert data["page"] == 1
    assert data["page_size"] == 20

def test_list_users_custom_pagination(client):
    """Should respect custom pagination parameters."""
    response = client.get("/users?page=2&page_size=10")

    assert response.status_code == 200
    data = response.json()
    assert data["page"] == 2
    assert data["page_size"] == 10

def test_list_users_search(client):
    """Should filter users by search query."""
    # Create users
    client.post("/users", json={"email": "john@example.com", "name": "John Doe"})
    client.post("/users", json={"email": "jane@example.com", "name": "Jane Smith"})

    response = client.get("/users?search=john")

    assert response.status_code == 200
    data = response.json()
    assert len(data["users"]) == 1
    assert data["users"][0]["name"] == "John Doe"
```

### Testing Request Validation

```python
import pytest

@pytest.mark.parametrize("invalid_data,expected_error", [
    (
        {"name": "No Email"},
        "email"
    ),
    (
        {"email": "test@example.com"},  # Missing name
        "name"
    ),
    (
        {"email": "invalid", "name": "Test"},
        "email"
    ),
    (
        {"email": "test@example.com", "name": "A"},  # Name too short
        "name"
    ),
])
def test_create_user_validation_errors(client, invalid_data, expected_error):
    """Should return 422 for invalid user data."""
    response = client.post("/users", json=invalid_data)

    assert response.status_code == 422
    error_detail = str(response.json())
    assert expected_error in error_detail.lower()
```

### Testing Error Responses

```python
def test_update_user_not_found(client, auth_headers):
    """Should return 404 when updating non-existent user."""
    response = client.put(
        "/users/99999",
        json={"name": "Updated Name"},
        headers=auth_headers
    )

    assert response.status_code == 404
    error = response.json()
    assert "not found" in error["error"].lower()

def test_delete_user_unauthorized(client):
    """Should return 401 when deleting without authentication."""
    response = client.delete("/users/1")

    assert response.status_code == 401

def test_create_duplicate_user(client):
    """Should return 409 for duplicate email."""
    user_data = {
        "email": "duplicate@example.com",
        "name": "Test User"
    }

    # Create first user
    response1 = client.post("/users", json=user_data)
    assert response1.status_code == 201

    # Try to create duplicate
    response2 = client.post("/users", json=user_data)
    assert response2.status_code == 409
    error = response2.json()
    assert "already exists" in error["error"].lower()
```

### Testing Database Interactions

```python
import pytest
from app.database import Database

@pytest.fixture
def db_client(test_database):
    """Provide TestClient with test database.

    WHY: Isolate tests with separate database instance.
    """
    from app.main import app
    from app.dependencies import get_database

    # Override database dependency
    app.dependency_overrides[get_database] = lambda: test_database

    client = TestClient(app)
    yield client

    # Cleanup
    app.dependency_overrides.clear()

def test_create_user_persists_to_database(db_client, test_database):
    """Should persist user to database."""
    user_data = {
        "email": "persist@example.com",
        "name": "Persist User"
    }

    response = db_client.post("/users", json=user_data)
    user_id = response.json()["id"]

    # Verify in database
    user = test_database.get_user(user_id)
    assert user is not None
    assert user.email == user_data["email"]
```

### Integration Testing

```python
@pytest.mark.integration
def test_user_registration_flow(client):
    """Test complete user registration and login flow.

    WHY: Integration test verifying multiple endpoints work together.
    """
    # Register user
    register_response = client.post("/users", json={
        "email": "flow@example.com",
        "name": "Flow User",
        "password": "SecurePass123"
    })
    assert register_response.status_code == 201
    user_id = register_response.json()["id"]

    # Login
    login_response = client.post("/auth/login", json={
        "email": "flow@example.com",
        "password": "SecurePass123"
    })
    assert login_response.status_code == 200
    token = login_response.json()["access_token"]

    # Access protected endpoint
    headers = {"Authorization": f"Bearer {token}"}
    me_response = client.get("/users/me", headers=headers)
    assert me_response.status_code == 200
    assert me_response.json()["id"] == user_id

@pytest.mark.integration
def test_order_creation_flow(client, auth_headers):
    """Test order creation with inventory update."""
    # Create order
    order_data = {
        "items": [
            {"product_id": 1, "quantity": 2},
            {"product_id": 2, "quantity": 1}
        ]
    }

    response = client.post(
        "/orders",
        json=order_data,
        headers=auth_headers
    )

    assert response.status_code == 201
    order = response.json()
    assert order["status"] == "pending"
    assert len(order["items"]) == 2

    # Verify order can be retrieved
    order_id = order["id"]
    get_response = client.get(f"/orders/{order_id}", headers=auth_headers)
    assert get_response.status_code == 200
```

### Testing Async Endpoints

```python
import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.asyncio
async def test_async_endpoint():
    """Test async endpoint with async client."""
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/users")
        assert response.status_code == 200
```

## Tools to Use

- `Write`: Create new test files
- `Edit`: Modify existing tests
- `Bash`: Run pytest for API tests

### Bash Commands

```bash
# Run API tests
pytest tests/test_api_users.py

# Run with verbose output
pytest tests/test_api_users.py -v

# Run specific test
pytest tests/test_api_users.py::test_create_user_success

# Run integration tests only
pytest -m integration

# Run with coverage
pytest --cov=app tests/
```

## Workflow

1. **Understand API Requirements**: Clarify endpoint behavior
2. **Write Test First**: Write failing test (Red)
3. **Verify Test Fails**: Confirm test fails correctly
4. **Commit Test**: Commit the failing test
5. **Implementation**: Implement endpoint (use `python-api-development`)
6. **Run Tests**: Verify tests pass (Green)
7. **Test Edge Cases**: Add tests for error conditions
8. **Refactor**: Improve code quality
9. **Commit**: Create atomic commit

## Related Skills

- `python-api-development`: For implementing endpoints being tested
- `pytest-testing`: For unit testing business logic
- `python-core-development`: For core Python code

## Testing Fundamentals

See [Pytest Fundamentals](../_shared/pytest-fundamentals.md)

## Coding Standards

See [Python Coding Standards](../_shared/python-coding-standards.md)

## TDD Workflow

Follow [Python TDD Workflow](../_shared/python-tdd-workflow.md)

## Key Reminders

- Write tests BEFORE implementing endpoints (TDD)
- Always verify HTTP status codes
- Test both success and error cases
- Use fixtures for authentication and test data
- Test request validation with parametrize
- Use TestClient for synchronous tests
- Override dependencies for database isolation
- Test complete flows with integration tests
- Verify response schema structure
- Commit tests separately from implementation
