---
name: test-writer
description: Guides test creation for Polibase following strict testing standards. Activates when writing tests or creating test files. Enforces external service mocking (no real API calls), async/await patterns, test independence, and proper use of pytest-asyncio to prevent CI failures and API costs.
---

# Test Writer

## Purpose
Guide test creation following Polibase testing standards with proper mocking, async/await patterns, and independence from external services.

## When to Activate
This skill activates automatically when:
- Writing new tests
- Creating test files in `tests/` directory
- User mentions "test", "pytest", or "testing"
- Reviewing existing test code

## ⚡ TDD Workflow (Test-First Development)

**ALWAYS write tests BEFORE implementation!**

### Red-Green-Refactor Cycle

1. **🔴 Red**: Write a failing test
   ```python
   # Write test first - it will fail (no implementation yet)
   @pytest.mark.asyncio
   async def test_create_politician_saves_to_repository():
       mock_repo = AsyncMock(spec=IPoliticianRepository)
       mock_repo.create.return_value = Politician(id=1, name="山田太郎")

       usecase = CreatePoliticianUseCase(mock_repo)
       result = await usecase.execute(CreatePoliticianInputDTO(name="山田太郎"))

       mock_repo.create.assert_awaited_once()
   ```

2. **🟢 Green**: Write minimal code to pass
   ```python
   # Now implement just enough to make test pass
   class CreatePoliticianUseCase:
       async def execute(self, input_dto):
           politician = Politician(name=input_dto.name)
           await self.repository.create(politician)
   ```

3. **♻️ Refactor**: Improve code while keeping tests green
   ```python
   # Refactor with confidence - tests verify behavior
   class CreatePoliticianUseCase:
       async def execute(self, input_dto):
           # Add validation
           if not input_dto.name:
               raise ValueError("Name required")
           # Extract to method
           politician = self._create_entity(input_dto)
           return await self.repository.create(politician)
   ```

### TDD Benefits
- ✅ Forces you to think about API design before implementation
- ✅ Tests serve as documentation
- ✅ Refactoring is safe (tests catch regressions)
- ✅ Code is naturally testable (designed for testing)

**Remember**: If you write implementation first, you're not doing TDD!

## 🚫 CRITICAL: Never Call External Services

**ABSOLUTELY FORBIDDEN in tests:**
- ❌ Real API calls to Google Gemini or any LLM
- ❌ Actual HTTP requests to external websites
- ❌ Real database connections (except integration tests)
- ❌ File system operations outside temp directories
- ❌ Network connections of any kind

**Why?**
- Tests must run in CI/CD without API keys
- Tests must be fast (< 1 second per test)
- Tests must be deterministic (same result every time)
- Tests must not incur API costs

## Quick Checklist

Before committing tests:

- [ ] **No External Calls**: All external services mocked
- [ ] **Fast Execution**: Each test runs in < 1 second
- [ ] **Isolated**: Tests don't depend on each other
- [ ] **Deterministic**: Same result every time
- [ ] **Clear Names**: Test name describes what it tests
- [ ] **Arrange-Act-Assert**: Clear test structure
- [ ] **Async Properly**: Uses `@pytest.mark.asyncio` and `AsyncMock`
- [ ] **Mock Verification**: Asserts mock calls when relevant
- [ ] **Type Hints**: Complete type annotations

## Test Structure

```
tests/
├── unit/              # Fast, isolated tests
│   ├── domain/       # Domain entities and services
│   ├── application/  # Use cases (with mocks)
│   └── infrastructure/  # External services (with mocks)
├── integration/       # Tests with real database
├── evaluation/       # LLM evaluation (manual only, not in CI)
└── conftest.py       # Shared fixtures
```

## Core Testing Patterns

### 1. Mocking External Services

**Always use `AsyncMock` with `spec=` parameter:**
```python
from unittest.mock import AsyncMock

@pytest.fixture
def mock_llm_service():
    # ALWAYS use spec= to catch typos and wrong method calls
    mock = AsyncMock(spec=ILLMService)
    mock.generate_text.return_value = "Mocked response"
    return mock
```

**⚠️ Why `spec=` is CRITICAL:**
```python
# ❌ WITHOUT spec= - typos go undetected
mock = AsyncMock()
await mock.genrate_text("prompt")  # Typo! Test still passes!

# ✅ WITH spec= - typos caught immediately
mock = AsyncMock(spec=ILLMService)
await mock.genrate_text("prompt")  # AttributeError!
```

**Use `AsyncMock` for async methods, never `MagicMock`:**
```python
# ❌ WRONG - MagicMock for async function
mock_repo = MagicMock(spec=IPoliticianRepository)
result = await mock_repo.create(politician)  # Error!

# ✅ CORRECT - AsyncMock for async function
mock_repo = AsyncMock(spec=IPoliticianRepository)
result = await mock_repo.create(politician)  # Works!
```

### 2. Async Tests

**Use pytest-asyncio:**
```python
@pytest.mark.asyncio
async def test_async_function(mock_repo):
    result = await usecase.execute(input_dto)
    assert result.success
```

### 3. Test Independence

**Each test is self-contained:**
```python
def test_create_politician(mock_repo):
    # Setup mock
    mock_repo.save.return_value = Politician(id=1, name="Test")

    # Execute
    result = usecase.execute(input_dto)

    # Assert
    assert result.success
```

## Templates

Use templates in `templates/` directory for:
- Domain service tests
- Use case tests with mocks
- Repository integration tests
- External service tests with mocks

## Detailed Reference

For comprehensive testing patterns, mocking strategies, and best practices, see [reference.md](reference.md).

## Examples

See [examples.md](examples.md) for concrete test examples at each layer.

## Running Tests

```bash
# Run all tests
docker compose -f docker/docker-compose.yml [-f docker/docker-compose.override.yml] exec sagebase uv run pytest

# Run specific test file
docker compose -f docker/docker-compose.yml [-f docker/docker-compose.override.yml] exec sagebase uv run pytest tests/unit/domain/test_speaker_domain_service.py

# Run with coverage
docker compose -f docker/docker-compose.yml [-f docker/docker-compose.override.yml] exec sagebase uv run pytest --cov=src

# Run only unit tests
docker compose -f docker/docker-compose.yml [-f docker/docker-compose.override.yml] exec sagebase uv run pytest tests/unit/
```

## Common Anti-Patterns

1. **❌ Real API Calls**: Most common mistake!
2. **❌ Testing Implementation Details**: Test public interfaces
3. **❌ Test Dependencies**: Each test must be independent
4. **❌ Missing Async/Await**: Forget `@pytest.mark.asyncio`
5. **❌ No Mock Verification**: Don't check if mocks were called

See [reference.md](reference.md) for detailed explanations and fixes.
