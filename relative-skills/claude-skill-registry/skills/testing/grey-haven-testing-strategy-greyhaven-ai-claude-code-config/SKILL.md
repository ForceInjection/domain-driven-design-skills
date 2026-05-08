---
name: grey-haven-testing-strategy
description: "Grey Haven's comprehensive testing strategy - Vitest unit/integration/e2e for TypeScript, pytest markers for Python, >80% coverage requirement, fixture patterns, and Doppler for test environments. Use when writing tests, setting up test infrastructure, running tests, debugging test failures, improving coverage, configuring CI/CD, or when user mentions 'test', 'testing', 'pytest', 'vitest', 'coverage', 'TDD', 'test-driven development', 'unit test', 'integration test', 'e2e', 'end-to-end', 'test fixtures', 'mocking', 'test setup', 'CI testing'."
# v2.0.43: Skills to auto-load for testing work
skills:
  - grey-haven-code-style
  - grey-haven-test-generation
  - grey-haven-tdd-orchestration
# v2.0.74: Tools for testing work
allowed-tools:
  - Read
  - Write
  - MultiEdit
  - Bash
  - Grep
  - Glob
  - TodoWrite
---

# Grey Haven Testing Strategy

**Comprehensive testing approach for TypeScript (Vitest) and Python (pytest) projects.**

Follow these standards when writing tests, setting up test infrastructure, or improving test coverage in Grey Haven codebases.

## Supporting Documentation

- **[EXAMPLES.md](EXAMPLES.md)** - Copy-paste test examples for Vitest and pytest
- **[REFERENCE.md](REFERENCE.md)** - Complete configurations, project structures, and CI setup
- **[templates/](templates/)** - Ready-to-use test templates
- **[checklists/](checklists/)** - Testing quality checklists
- **[scripts/](scripts/)** - Helper scripts for coverage and test execution

## Testing Philosophy

### Coverage Requirements

- **Minimum: 80% code coverage** for all projects (enforced in CI)
- **Target: 90%+ coverage** for critical paths
- **100% coverage** for security-critical code (auth, payments, multi-tenant isolation)

### Test Types (Markers)

Grey Haven uses consistent test markers across languages:

1. **unit**: Fast, isolated tests of single functions/classes
2. **integration**: Tests involving multiple components or external dependencies
3. **e2e**: End-to-end tests through full user flows
4. **benchmark**: Performance tests measuring speed/memory

## TypeScript Testing (Vitest)

### Quick Setup

**Project Structure:**

```
tests/
├── unit/                    # Fast, isolated tests
├── integration/             # Multi-component tests
└── e2e/                    # Playwright tests
```

**Key Configuration:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: ["./tests/setup.ts"],
    coverage: {
      thresholds: { lines: 80, functions: 80, branches: 80, statements: 80 },
    },
  },
});
```

**Running Tests:**

```bash
bun run test                 # Run all tests
bun run test:coverage        # With coverage report
bun run test:watch           # Watch mode
bun run test:ui              # UI mode
bun run test tests/unit/     # Unit tests only
```

**See [EXAMPLES.md](EXAMPLES.md#vitest-examples) for complete test examples.**

## Python Testing (pytest)

### Quick Setup

**Project Structure:**

```
tests/
├── conftest.py             # Shared fixtures
├── unit/                   # @pytest.mark.unit
├── integration/            # @pytest.mark.integration
├── e2e/                   # @pytest.mark.e2e
└── benchmark/             # @pytest.mark.benchmark
```

**Key Configuration:**

```toml
# pyproject.toml
[tool.pytest.ini_options]
addopts = ["--cov=app", "--cov-fail-under=80"]
markers = [
    "unit: Fast, isolated unit tests",
    "integration: Tests involving multiple components",
    "e2e: End-to-end tests through full flows",
    "benchmark: Performance tests",
]
```

**Running Tests:**

```bash
# ⚠️ ALWAYS activate virtual environment first!
source .venv/bin/activate

# Run with Doppler for environment variables
doppler run -- pytest                      # All tests
doppler run -- pytest --cov=app            # With coverage
doppler run -- pytest -m unit              # Unit tests only
doppler run -- pytest -m integration       # Integration tests only
doppler run -- pytest -m e2e               # E2E tests only
doppler run -- pytest -v                   # Verbose output
```

**See [EXAMPLES.md](EXAMPLES.md#pytest-examples) for complete test examples.**

## Test Markers Explained

### Unit Tests

**Characteristics:**
- Fast execution (< 100ms per test)
- No external dependencies (database, API, file system)
- Mock all external services
- Test single function/class in isolation

**Use for:**
- Utility functions
- Business logic
- Data transformations
- Component rendering (React Testing Library)

### Integration Tests

**Characteristics:**
- Test multiple components together
- May use real database/Redis (with cleanup)
- Test API endpoints with FastAPI TestClient
- Test React Query + server functions

**Use for:**
- API endpoint flows
- Database operations with repositories
- Authentication flows
- Multi-component interactions

### E2E Tests

**Characteristics:**
- Test complete user flows
- Use Playwright (TypeScript) or httpx (Python)
- Test from user perspective
- Slower execution (seconds per test)

**Use for:**
- Registration/login flows
- Critical user journeys
- Form submissions
- Multi-page workflows

### Benchmark Tests

**Characteristics:**
- Measure performance metrics
- Track execution time
- Monitor memory usage
- Detect performance regressions

**Use for:**
- Database query performance
- Algorithm optimization
- API response times
- Batch operations

## Environment Variables with Doppler

**⚠️ CRITICAL: Grey Haven uses Doppler for ALL environment variables.**

```bash
# Install Doppler
brew install dopplerhq/cli/doppler

# Authenticate and setup
doppler login
doppler setup

# Run tests with Doppler
doppler run -- bun run test          # TypeScript
doppler run -- pytest                # Python

# Use specific config
doppler run --config test -- pytest
```

**Doppler provides:**
- `DATABASE_URL_TEST` - Test database connection
- `REDIS_URL` - Redis for tests (separate DB)
- `BETTER_AUTH_SECRET` - Auth secrets
- `STRIPE_SECRET_KEY` - External service keys (test mode)
- `PLAYWRIGHT_BASE_URL` - E2E test URL

**See [REFERENCE.md](REFERENCE.md#doppler-configuration) for complete setup.**

## Test Fixtures and Factories

### TypeScript Factories

```typescript
// tests/factories/user.factory.ts
import { faker } from "@faker-js/faker";

export function createMockUser(overrides = {}) {
  return {
    id: faker.string.uuid(),
    tenant_id: faker.string.uuid(),
    email_address: faker.internet.email(),
    name: faker.person.fullName(),
    ...overrides,
  };
}
```

### Python Fixtures

```python
# tests/conftest.py
@pytest.fixture
async def test_user(session, tenant_id):
    """Create test user with tenant isolation."""
    user = User(
        tenant_id=tenant_id,
        email_address="test@example.com",
        name="Test User",
    )
    session.add(user)
    await session.commit()
    return user
```

**See [EXAMPLES.md](EXAMPLES.md#test-factories-and-fixtures) for more patterns.**

## Multi-Tenant Testing

**⚠️ ALWAYS test tenant isolation in multi-tenant projects:**

```python
@pytest.mark.unit
async def test_tenant_isolation(session, test_user, tenant_id):
    """Verify queries filter by tenant_id."""
    repo = UserRepository(session)

    # Should find with correct tenant
    user = await repo.get_by_id(test_user.id, tenant_id)
    assert user is not None

    # Should NOT find with different tenant
    different_tenant = uuid4()
    user = await repo.get_by_id(test_user.id, different_tenant)
    assert user is None
```

## Continuous Integration

**GitHub Actions with Doppler:**

```yaml
# .github/workflows/test.yml
- name: Run tests with Doppler
  env:
    DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN_TEST }}
  run: doppler run --config test -- bun run test:coverage
```

**See [REFERENCE.md](REFERENCE.md#github-actions-configuration) for complete workflow.**

## When to Apply This Skill

Use this skill when:

- ✅ Writing new tests for features
- ✅ Setting up test infrastructure (Vitest/pytest)
- ✅ Configuring CI/CD test pipelines
- ✅ Debugging failing tests
- ✅ Improving test coverage (<80%)
- ✅ Reviewing test code quality
- ✅ Setting up Doppler for test environments
- ✅ Creating test fixtures and factories
- ✅ Implementing TDD workflow
- ✅ User mentions: "test", "testing", "pytest", "vitest", "coverage", "TDD", "unit test", "integration test", "e2e", "test setup", "CI testing"

## Template References

These testing patterns come from Grey Haven production templates:

- **Frontend**: `cvi-template` (Vitest + Playwright + React Testing Library)
- **Backend**: `cvi-backend-template` (pytest + FastAPI TestClient + async fixtures)

## Critical Reminders

1. **Coverage: 80% minimum** (enforced in CI, blocks merge)
2. **Test markers**: unit, integration, e2e, benchmark (use consistently)
3. **Doppler**: ALWAYS use for test environment variables (never commit .env!)
4. **Virtual env**: MUST activate for Python tests (`source .venv/bin/activate`)
5. **Tenant isolation**: ALWAYS test multi-tenant scenarios
6. **Fixtures**: Use factories for test data generation (faker library)
7. **Mocking**: Mock external services in unit tests (use vi.mock or pytest mocks)
8. **CI**: Run tests with `doppler run --config test`
9. **Database**: Use separate test database (Doppler provides `DATABASE_URL_TEST`)
10. **Cleanup**: Clean up test data after each test (use fixtures with cleanup)

## Next Steps

- **Need test examples?** See [EXAMPLES.md](EXAMPLES.md) for copy-paste code
- **Need configurations?** See [REFERENCE.md](REFERENCE.md) for complete configs
- **Need templates?** See [templates/](templates/) for starter files
- **Need checklists?** Use [checklists/](checklists/) for systematic test reviews
- **Need to run tests?** Use [scripts/](scripts/) for helper utilities
