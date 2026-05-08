---
name: test-executor
description: Execute tests adaptively, analyze failures, generate detailed failure reports, and iterate until tests pass. This skill should be used when running tests from a test plan, working with any language, framework, or test type (E2E, API, unit, integration, performance).
---

# Test Executor Skill

## Purpose

Execute tests in adaptive loops, analyze test results, generate structured failure reports, and iterate with fixes until all tests pass. Works universally with any testing framework or project structure through intelligent adaptation and discovery.

## When to Use This Skill

Use this skill when:

- Test plan is ready (from `test-plan-generator` or manual creation)
- Ready to execute tests for implemented features
- Need to validate implementation correctness
- Want systematic test execution with detailed failure reporting
- Need to iterate on test failures with clear diagnostics
- Running tests as part of implementation validation

## Test Execution Workflow

### Phase 1: Preparation

1. **Read Test Plan**
   - Locate test-plan.md or equivalent
   - Identify tests to execute
   - Group tests by type (E2E, API, unit, integration, performance)
   - Determine execution order

2. **Discover Project Test Setup**
   - Identify testing framework
   - Find test commands
   - Locate test files
   - Check for test configuration

3. **Ensure Services are Running**
   - Identify required services (backend, frontend, database, etc.)
   - Check if services are running
   - Start services if needed
   - Verify service health

### Phase 2: Test Execution Loop

For each test in plan:

1. **Execute Test**
   - Run appropriate test command
   - Capture output (stdout, stderr)
   - Record execution time
   - Determine pass/fail status

2. **Analyze Results**
   - Parse test output
   - Extract error messages
   - Identify failure causes
   - Categorize failure type

3. **If Test Passes:**
   - Mark test as complete in plan: `- [x]`
   - Continue to next test

4. **If Test Fails:**
   - Generate failure report
   - Add to test-failures.md
   - Continue to next test (or stop if critical failure)

5. **Update Progress**
   - Track: X/Y tests passed
   - Update test plan with results

### Phase 3: Report Generation

1. **Create Test Failure Report**
   - Document failed tests
   - Include error messages and stack traces
   - Identify probable causes
   - Suggest fixes
   - Save as `test-failures.md`

2. **Summary Statistics**
   - Total tests run
   - Passed / Failed / Skipped
   - Execution time
   - Success rate

## Adaptive Test Discovery

### Discovering Test Framework

**Backend/Unit Tests:**
```bash
# Look for config files and dependencies
package.json → "jest", "mocha", "vitest"
requirements.txt → "pytest", "unittest"
*.csproj → MSTest, xUnit, NUnit
Cargo.toml → built-in Rust tests
go.mod → built-in Go tests
```

**Frontend/E2E Tests:**
```bash
# Look for E2E frameworks
package.json → "playwright", "cypress", "puppeteer"
Check for test directories: e2e/, tests/, __tests__/
```

**API Tests:**
```bash
# Look for API test patterns
*.http files (REST Client)
*.test.ts with fetch/axios calls
curl commands in scripts
Postman collections
```

### Discovering Test Commands

**Strategy:**
1. **Check package.json scripts:**
   ```json
   {
     "scripts": {
       "test": "jest",
       "test:e2e": "playwright test",
       "test:unit": "vitest run"
     }
   }
   ```

2. **Check Makefile:**
   ```makefile
   test:
       pytest tests/

   test-e2e:
       npm run test:e2e
   ```

3. **Check CI/CD config:**
   - `.github/workflows/*.yml`
   - `.gitlab-ci.yml`
   - `azure-pipelines.yml`

4. **Try common patterns:**
   ```bash
   npm test
   dotnet test
   pytest
   go test ./...
   cargo test
   make test
   ```

5. **Ask user if uncertain:**
   "How do you run tests in this project?"

## Test Types and Execution

### 1. E2E (End-to-End) Tests

**Characteristics:**
- Test complete user flows
- Require running frontend + backend
- Use browser automation (Playwright, Cypress, etc.)
- Typically slowest tests

**Execution with MCP Playwright:**
```bash
# If using Playwright via MCP
# Tests are executed through MCP Playwright tools
# Navigate, click, fill forms, assert results
```

**Execution with npm:**
```bash
npm run test:e2e
# or
npx playwright test
npx cypress run
```

**Services Required:**
- Frontend dev server (e.g., http://localhost:5174)
- Backend API server (e.g., http://localhost:5001)
- Database (e.g., PostgreSQL on :5432)

**Example Test from Plan:**
```markdown
- [ ] E2E: User can submit form and see confirmation
```

**Execution:**
1. Ensure all services running
2. Run E2E test command
3. Parse output for pass/fail
4. Capture screenshots if failed

### 2. API Tests

**Characteristics:**
- Test backend endpoints directly
- Don't require frontend
- Use HTTP requests (curl, httpie, fetch, etc.)
- Faster than E2E tests

**Execution with curl:**
```bash
# Example from test plan:
# "Test POST /api/forms creates form in database"

curl -X POST http://localhost:5001/api/forms \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Form","description":"Test"}'

# Check response status code
# Verify response body
# Query database to confirm creation
```

**Execution with test framework:**
```bash
# If project has API test suite
npm run test:api
dotnet test --filter Category=API
pytest tests/api/
```

**Services Required:**
- Backend API server
- Database

### 3. Unit Tests

**Characteristics:**
- Test individual functions/components
- No external dependencies
- Fast execution
- Largest quantity typically

**Execution:**
```bash
# JavaScript/TypeScript
npm test
npm run test:unit
jest
vitest run

# .NET
dotnet test
dotnet test --filter Category=Unit

# Python
pytest tests/unit/
python -m pytest

# Go
go test ./...

# Rust
cargo test
```

**Services Required:**
- None (unit tests are isolated)

### 4. Integration Tests

**Characteristics:**
- Test component interactions
- May require database or external services
- Medium execution speed

**Execution:**
```bash
# Similar to unit tests but may need services
dotnet test --filter Category=Integration
pytest tests/integration/
npm run test:integration
```

**Services Required:**
- Database (often)
- External APIs (sometimes)

### 5. Performance Tests

**Characteristics:**
- Test response time, throughput, resource usage
- Require production-like environment
- Generate metrics

**Execution:**
```bash
# Load testing tools
# ab (Apache Bench), wrk, k6, JMeter

# Example: 100 requests, 10 concurrent
ab -n 100 -c 10 http://localhost:5001/api/forms

# Parse output for:
# - Requests per second
# - Response times (mean, median, p95, p99)
# - Failures
```

## Service Management

### Starting Required Services

**Adaptive Service Detection:**

1. **Frontend:**
   ```bash
   # Detection: package.json with "dev" script
   # Start: npm run dev (background)
   # Health check: curl http://localhost:5174
   ```

2. **Backend:**
   ```bash
   # .NET: dotnet run (background)
   # Node: npm start or node server.js
   # Python: python app.py or flask run
   # Go: go run main.go
   ```

3. **Database:**
   ```bash
   # Detection: docker-compose.yml
   # Start: docker-compose up -d postgres
   # Health check: pg_isready or curl health endpoint
   ```

**Start Services Script (template in bundled resources):**
```bash
#!/bin/bash
# scripts/start_services.sh (customizable)

echo "Starting services..."

# Start database
docker-compose up -d postgres
sleep 2

# Start backend
cd backend && dotnet run &
BACKEND_PID=$!
sleep 5

# Start frontend
npm run dev &
FRONTEND_PID=$!
sleep 3

echo "Services started"
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
```

### Checking Service Health

```bash
# Backend health check
curl http://localhost:5001/health || echo "Backend not ready"

# Frontend health check
curl http://localhost:5174 || echo "Frontend not ready"

# Database health check
docker exec postgres pg_isready -U user -d db
```

## Test Output Parsing

### Parse Strategy

Different testing frameworks have different output formats. Parse adaptively:

**Jest/Vitest Output:**
```
PASS  tests/unit/EmailService.test.ts
  ✓ sends email successfully (45ms)
  ✓ handles errors gracefully (12ms)

Test Suites: 1 passed, 1 total
Tests:       2 passed, 2 total
```

**Parsing:**
- Look for `PASS` or `FAIL`
- Extract test names and times
- Count passed/failed

**dotnet test Output:**
```
Passed!  - Failed:     0, Passed:    10, Skipped:     0, Total:    10, Duration: 2 s
```

**Parsing:**
- Extract counts: Failed, Passed, Skipped
- Extract duration

**pytest Output:**
```
====== 5 passed, 2 failed in 3.42s ======
```

**Parsing:**
- Extract passed/failed counts
- Extract duration

**Script: `scripts/parse_test_output.py`** (bundled) can parse common formats.

## Failure Analysis

### Categorizing Failures

**1. Timeout Errors**
- **Symptom:** "Timeout waiting for...", "Request timeout"
- **Probable Cause:** Service not started, slow response
- **Suggested Fix:** Check services running, increase timeout

**2. Assertion Failures**
- **Symptom:** "Expected X but got Y"
- **Probable Cause:** Logic error, incorrect test expectations
- **Suggested Fix:** Debug logic, verify test correctness

**3. Connection Errors**
- **Symptom:** "Connection refused", "Cannot connect to..."
- **Probable Cause:** Service not running, wrong port/URL
- **Suggested Fix:** Start services, check configuration

**4. Authentication Errors**
- **Symptom:** "401 Unauthorized", "403 Forbidden"
- **Probable Cause:** Missing/invalid token, expired credentials
- **Suggested Fix:** Verify auth flow, refresh tokens

**5. Data Errors**
- **Symptom:** "Null reference", "Undefined property"
- **Probable Cause:** Missing data, incorrect data shape
- **Suggested Fix:** Check data fixtures, verify API responses

## Failure Report Format

### test-failures.md Template

```markdown
# Test Failure Report

**Date:** [Date]
**Execution:** [Run #X]

## Summary

- **Total Tests:** X
- **Passed:** Y
- **Failed:** Z
- **Success Rate:** Y/X %

---

## Failed Test #1: [Test Name]

**Test File:** `path/to/test.spec.ts`

**Failure Type:** [Timeout / Assertion / Connection / etc.]

**Error Message:**
```
[Full error message and stack trace]
```

**Probable Cause:**
[Analysis of why test failed]

**Suggested Fix:**
[Specific actions to fix]

**Related Code:**
- `src/path/to/component.ts:line`
- `backend/path/to/service.cs:line`

---

## Failed Test #2: [Test Name]

[Same structure as above]

---

## Next Steps

1. [Action 1 to fix failures]
2. [Action 2 to fix failures]
3. Re-run tests after fixes

---

**Report for:** `test-fixer` skill
```

## Iteration Strategy

### Test-Driven Iteration

1. **Run all tests** → Generate failure report
2. **Use `test-fixer` skill** → Fix failures
3. **Re-run failed tests** → Verify fixes
4. **Repeat** until all pass

### Batch vs Individual

**Batch Execution (default):**
- Run all tests at once
- Generate one consolidated report
- More efficient

**Individual Execution:**
- Run one test at a time
- Generate report per test
- Use when tests interfere with each other

### Stop on First Failure

Optional strategy for critical tests:
- Run tests sequentially
- Stop on first failure
- Fix before continuing
- Use for smoke tests or critical path tests

## Tips for Effective Test Execution

1. **Start Services First**: Always verify services are running
2. **Run in Order**: Execute tests in logical order (unit → integration → E2E)
3. **Parse Carefully**: Extract meaningful error messages
4. **Categorize Failures**: Identify failure patterns
5. **Detailed Reports**: Provide enough info for test-fixer skill
6. **Track Progress**: Update test plan with results
7. **Retry Flaky Tests**: Some tests may be flaky, retry once
8. **Isolate Failures**: Determine if failures are related
9. **Performance Baseline**: Track test execution time
10. **Clean State**: Ensure clean database/state between test runs

## Bundled Resources

- `scripts/parse_test_output.py` - Parse test output to structured format
- `scripts/start_services.sh` - Template for starting project services
- `references/test-report-template.md` - Template for failure reports
- `references/test-execution-patterns.md` - Execution patterns by test type
