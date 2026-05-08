---
name: test-workflow
description: Automated testing workflow for backend and frontend. Use when writing tests, fixing test failures, or validating code changes. Runs pytest for backend and jest/vitest for frontend.
---

# Testing Workflow

Complete testing strategy for the full-stack application.

## When to use this skill

- After making code changes
- Before creating pull requests
- Fixing test failures
- Writing new test cases
- Validating bug fixes

## Quick Commands

### Backend Testing
```bash
make test                    # Run all backend tests
make test-watch              # Run tests in watch mode (if available)
uv run pytest tests/         # Run specific test directory
uv run pytest tests/test_auth.py  # Run specific test file
uv run pytest tests/test_auth.py::test_login  # Run specific test
uv run pytest -v             # Verbose output
uv run pytest --lf           # Run last failed tests
uv run pytest -x             # Stop on first failure
```

### Frontend Testing
```bash
cd frontend
pnpm test                    # Run frontend tests
pnpm test:watch              # Run in watch mode
pnpm test:coverage           # Generate coverage report
```

### Type Checking
```bash
make check-backend           # Run basedpyright on backend
make check-frontend          # Run TypeScript type checking
make check-all               # Run all checks (backend + frontend)
```

### Linting
```bash
make lint-backend            # Ruff check and format Python
make lint-frontend           # ESLint for TypeScript/React
```

## Testing Workflow Steps

1. **Before writing code**: Understand existing test patterns
   - Look at similar test files
   - Check test fixtures in `conftest.py`
   - Review test database setup

2. **While writing code**: Run related tests frequently
   ```bash
   uv run pytest tests/test_myfeature.py -v
   ```

3. **After code changes**: Run full test suite
   ```bash
   make test
   make check-all
   ```

4. **Before committing**: Ensure all checks pass
   ```bash
   make check-all  # Type checking + linting for both platforms
   make test       # Backend tests
   ```

## Test Structure

### Backend Tests (pytest + asyncio)
- Location: `backend/tests/`
- Fixtures: `backend/tests/conftest.py`
- Pattern: `test_*.py` or `*_test.py`
- Run with: `make test`

### Test Database
- Uses separate test database: `manageros_test`
- Auto-created and migrated in test fixtures
- Isolated from development database
- Connection string: `postgresql://postgres:postgres@localhost:5433/manageros_test`

### Writing Backend Tests

```python
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_create_user(client: AsyncClient) -> None:
    """Test user creation endpoint."""
    response = await client.post(
        "/api/users",
        json={"email": "test@example.com", "name": "Test User"}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
```

## Common Test Patterns

### Testing API Endpoints
1. Use `AsyncClient` fixture for HTTP requests
2. Test success cases (200, 201, 204)
3. Test error cases (400, 401, 403, 404)
4. Verify response schemas
5. Check database state changes

### Testing Database Operations
1. Use test database fixtures
2. Test CRUD operations
3. Verify relationships and constraints
4. Test RLS policies (row-level security)
5. Clean up test data

### Testing Background Tasks
1. Import task functions directly
2. Mock external dependencies
3. Test task logic independently
4. Verify task enqueueing

## Debugging Failed Tests

1. **Read the error message carefully**
   - Check assertion failures
   - Look at stack traces
   - Review test data

2. **Run single test with verbose output**
   ```bash
   uv run pytest tests/test_file.py::test_name -vv
   ```

3. **Use print debugging or breakpoints**
   ```python
   import pdb; pdb.set_trace()  # Add breakpoint
   ```

4. **Check test fixtures and setup**
   - Review `conftest.py`
   - Verify test database state
   - Check fixture dependencies

## Pre-Release Checklist

Use the `/check-all` skill or run:
```bash
make check-all  # Runs all type checking and linting
make test       # Runs backend test suite
```

This ensures:
- Backend type checking passes (basedpyright)
- Frontend type checking passes (TypeScript)
- Backend linting passes (ruff)
- Frontend linting passes (ESLint)
- All backend tests pass (pytest)
