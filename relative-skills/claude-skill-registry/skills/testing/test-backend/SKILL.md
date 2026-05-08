---
name: Test Backend
description: Run and verify backend tests for the FastAPI/Python application.
---

# Test Backend

Run and verify backend tests using pytest and pytest-asyncio. This skill handles test execution, watches for changes, generates coverage reports, and helps diagnose test failures.

## Instructions

### Prerequisites

- Python 3.12+ installed
- uv package manager installed
- Backend dependencies installed (`uv sync` in `backend/` directory)
- Project uses pytest with asyncio support
- Tests located in `backend/tests/` with `unit/` and `integration/` subdirectories

### Workflow

1. Navigate to the `backend/` directory
2. Choose appropriate test command based on user needs:
   - `make test` or `uv run pytest` - Run all tests once (CI/CD mode)
   - `bash scripts/test.sh` - Run tests with test environment variables from `.env.test`
   - `bash scripts/test.sh <path>` - Run specific test file or directory
   - `uv run pytest --cov` - Run tests with coverage report
   - `uv run pytest -v` - Run tests in verbose mode
   - `uv run pytest -s` - Run tests with print output visible
   - `uv run pytest -k <pattern>` - Run tests matching pattern
3. Analyze test results and report findings to user
4. If tests fail, investigate failures and suggest fixes
5. If requested, help write or update tests using pytest patterns

### Testing Stack

- **Test Runner**: pytest 8.4.1+
- **Async Testing**: pytest-asyncio 1.1.0+
- **Mocking**: pytest-mock 3.14.0+
- **HTTP Mocking**: respx 0.22.0+
- **Coverage**: pytest-cov (optional)
- **Framework**: FastAPI with SQLAlchemy

### Test Organization

- `backend/tests/unit/` - Unit tests for services, repos, utilities
- `backend/tests/integration/` - Integration tests for routes and full workflows
- `backend/tests/mock/` - Mock data and fixtures
- `backend/tests/conftest.py` - Shared pytest fixtures and configuration

### pytest Configuration

Key settings from `pyproject.toml`:
- Python path: Current directory (`.`)
- Asyncio fixture scope: `session`
- Filters deprecation warnings from passlib

## Examples

### Example 1: Run All Tests

User: "Run the backend tests"
Assistant: I'll run the backend test suite.
[Executes: `cd backend && make test`]
[Reports results and any failures]

### Example 2: Run Tests with Coverage

User: "Check test coverage for the backend"
Assistant: I'll run the tests with coverage reporting.
[Executes: `cd backend && uv run pytest --cov --cov-report=term-missing`]
[Reports coverage percentages and identifies untested code]

### Example 3: Debug Test Failure

User: "The tool service tests are failing"
Assistant: Let me run the tests and investigate the failures.
[Executes: `cd backend && uv run pytest tests/unit/services/test_tool_service.py -v`]
[Analyzes failure output, reads test file if needed]
[Suggests fixes based on error messages]

### Example 4: Run Integration Tests Only

User: "Run only the integration tests"
Assistant: I'll run the integration test suite.
[Executes: `cd backend && uv run pytest tests/integration/ -v`]
[Reports results from integration tests]

### Example 5: Run Specific Test Pattern

User: "Run all tests related to projects"
Assistant: I'll run tests matching the project pattern.
[Executes: `cd backend && uv run pytest -k project -v`]
[Shows all tests with 'project' in their name]

### Example 6: Run with Test Environment

User: "Run tests with the test environment configuration"
Assistant: I'll use the test.sh script to load test environment variables.
[Executes: `cd backend && bash scripts/test.sh`]
[Tests run with .env.test configuration]

## Common pytest Options

- `-v` or `--verbose` - Increase verbosity
- `-s` - Disable output capturing (show prints)
- `-x` - Stop on first failure
- `--lf` - Run last failed tests
- `--ff` - Run failed tests first, then others
- `-k <expression>` - Run tests matching keyword expression
- `--markers` - Show available test markers
- `--cov=<path>` - Measure coverage for specified path
- `--cov-report=html` - Generate HTML coverage report
- `-n <num>` - Run tests in parallel (requires pytest-xdist)

## Writing Tests

Tests should follow these patterns:
- Use descriptive test names: `test_<function>_<scenario>_<expected_result>`
- Use pytest fixtures for setup/teardown (defined in conftest.py)
- Use async fixtures for async code: `@pytest.fixture(scope="session")`
- Mock external dependencies (database, APIs) in unit tests
- Use `pytest.mark.asyncio` for async test functions
- Organize tests to mirror source structure
