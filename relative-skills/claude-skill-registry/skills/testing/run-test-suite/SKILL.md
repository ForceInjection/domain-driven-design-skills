---
name: run-test-suite
description: Automatically run the test suite when code changes are made to ensure all tests pass before proceeding. This skill runs pytest for backend projects and Playwright for frontend projects, and reports test results, coverage, and any failures.
when_to_invoke: |
  Invoke this skill automatically when:
  - Any Python file (.py) is modified in hotel-de-ville/backend/, shadow-api/app/, or stellaris/backend/
  - Any TypeScript/TSX file is modified in hotel-de-ville/frontend/ or stellaris/frontend/
  - User asks to "run tests", "test this", "check if tests pass", or similar
  - Before suggesting a commit if code changes were made
  - After implementing a new feature or fixing a bug
  - When user asks "does this work?" or "is this correct?"
agent: qa-engineer
context: fork
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
hooks:
  Stop:
    - type: command
      command: "echo '📊 Test execution complete. Results captured.'"
---

You are responsible for running the test suite to verify code quality and correctness.

## Your Task

1. **Identify the project** - Determine if changes are in hotel-de-ville, shadow-api, or stellaris
2. **Identify component** - Backend (pytest) or frontend (Playwright/vitest)
3. **Navigate to project directory**
4. **Activate virtual environment** if backend, or install deps if frontend
5. **Run appropriate tests**
6. **Report results** clearly

## Docker Isolation (Preferred)

**When Docker is available, prefer running tests in containers for isolation.**

### Docker Test Protocol

```bash
1. Check for Docker availability:
   if command -v docker &> /dev/null && docker info &> /dev/null; then
       USE_DOCKER=true
   fi

2. Check for Dockerfile:
   if [ -f "Dockerfile" ] || [ -f "Dockerfile.test" ]; then
       DOCKER_AVAILABLE=true
   fi

3. If Docker available:
   # Build test image
   docker build -t test-runner:latest -f Dockerfile.test .

   # Run tests in container
   docker run --rm -v $(pwd):/app test-runner:latest pytest -v

   # Compare deps in container vs requirements.txt
   docker run --rm test-runner:latest pip freeze > /tmp/container_deps.txt
   diff requirements.txt /tmp/container_deps.txt

4. If Docker NOT available:
   # Warn prominently
   echo "⚠️ WARNING: Running tests on host, not in Docker container"
   echo "Dependencies may differ from production environment"
   # Fall back to host execution
```

### Dependency Verification

When using Docker, verify dependencies match:

```bash
# Get installed packages in container
docker run --rm test-runner pip freeze | sort > /tmp/container.txt

# Get requirements
sort requirements.txt > /tmp/required.txt

# Check for undeclared dependencies (in container but not in requirements)
comm -23 /tmp/container.txt /tmp/required.txt > /tmp/undeclared.txt

if [ -s /tmp/undeclared.txt ]; then
    echo "⚠️ UNDECLARED DEPENDENCIES FOUND:"
    cat /tmp/undeclared.txt
    echo ""
    echo "These packages are installed but not in requirements.txt"
    echo "Tests may pass locally but fail in production"
fi
```

### Docker vs Host Decision Matrix

| Condition | Action |
|-----------|--------|
| Docker + Dockerfile available | Run in Docker (preferred) |
| Docker available, no Dockerfile | Run on host with warning |
| Docker unavailable | Run on host with prominent warning |
| CI/CD environment | Always use Docker |

---

## Execution Steps (Host Fallback)

### For hotel-de-ville/backend

```bash
cd /home/user/jf-private/hotel-de-ville/backend

# Warn if not using Docker
echo "⚠️ Running tests on host (Docker not available)"

# Activate venv if exists
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Run tests with coverage
pytest -v --tb=short
```

### For shadow-api

```bash
cd /home/user/jf-private/shadow-api

# Warn if not using Docker
echo "⚠️ Running tests on host (Docker not available)"

# Activate venv if exists
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Run tests with coverage
pytest -v --tb=short
```

### For stellaris/backend

```bash
cd /home/user/jf-private/stellaris/backend

# Warn if not using Docker
echo "⚠️ Running tests on host (Docker not available)"

# Activate venv if exists
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Run tests with coverage
pytest -v --tb=short
```

### For stellaris/frontend (Playwright E2E tests)

```bash
cd /home/user/jf-private/stellaris/frontend

# Install dependencies if needed
npm install

# Run Playwright tests
npx playwright test --reporter=list
```

**IMPORTANT for Stellaris Frontend:** Playwright tests exist in `stellaris/frontend/tests/` and test:
- Chapter selection behavior
- Training mode navigation
- Session completion
- Stats persistence
- Vocabulary browser

## Reporting Results

After running tests, provide a clear summary:

**If all tests pass:**
```
✅ Test Suite Passed

Project: hotel-de-ville/backend
Tests run: 23
Passed: 23
Failed: 0
Duration: 2.3s

All tests passed successfully. Code is ready for commit.
```

**If tests fail:**
```
❌ Test Suite Failed

Project: shadow-api
Tests run: 15
Passed: 12
Failed: 3

Failed tests:
1. test_pipeline.py::test_atomize_stage - AssertionError: BLUF missing
2. test_retrieval.py::test_dual_embedding - IndexError: list index out of range
3. test_integration.py::test_full_pipeline - ValueError: Invalid source_type

⚠️ Fix these failures before committing.
```

## Additional Checks

If tests pass, you may also:
- Check for warnings in test output
- Note if coverage has decreased (if pytest-cov is available)
- Suggest running specific test files if only partial changes were made

## When NOT to Invoke

- For non-code changes (markdown files, documentation only)
- When user explicitly says "skip tests" or "don't run tests"
- For trivial changes like comment updates or formatting

## Priority

This is a **HIGH PRIORITY** skill. Code quality depends on passing tests. Always run tests before suggesting commits or marking features as complete.
