---
name: run-integration-tests
description: Run integration tests validating cross-component requirements and system behavior. Executes BDD scenarios, API tests, and end-to-end tests. Use to validate integrated system or as pre-deployment quality gate.
allowed-tools: [Read, Bash, Grep, Glob]
---

# run-integration-tests

**Skill Type**: Test Runner
**Purpose**: Execute integration tests validating system behavior
**Prerequisites**: Integration tests exist (BDD scenarios, API tests, E2E tests)

---

## Agent Instructions

You are running **integration tests** to validate the integrated system.

**Integration tests validate**:
- Cross-component interactions
- End-to-end user flows
- API contracts
- Database integration
- External service integration
- BDD scenarios (Given/When/Then)

---

## Workflow

### Step 1: Discover Integration Tests

**Find all integration test files**:

```bash
# BDD scenarios
find features -name "*.feature"

# Integration test directories
find tests/integration -name "test_*.py"
find tests/e2e -name "test_*.py"
find tests/api -name "test_*.py"
```

---

### Step 2: Run BDD Scenarios

**Execute Gherkin scenarios**:

```bash
# Behave (Python)
behave features/ --format progress

# Cucumber (JavaScript)
npm run cucumber

# Cucumber (Java)
mvn test -Dcucumber.options="features/"
```

**Output**:
```
Feature: User Authentication
  Scenario: Successful login                    PASSED
  Scenario: Login fails with invalid email      PASSED
  Scenario: Account locks after 3 failures      PASSED

Feature: Payment Processing
  Scenario: Successful card payment             PASSED
  Scenario: Payment fails invalid card          PASSED

5 scenarios (5 passed)
27 steps (27 passed)
Duration: 2.3s
```

---

### Step 3: Run API Integration Tests

**Execute API test suite**:

```bash
# Python (pytest with requests)
pytest tests/integration/api/ -v

# JavaScript (supertest)
npm test tests/integration/api

# Java (RestAssured)
mvn test -Dtest=ApiIntegrationTest
```

**Example tests**:
```python
# tests/integration/api/test_auth_api.py
# Validates: <REQ-ID> (API integration)

def test_login_api_returns_token():
    response = requests.post(
        "http://localhost:8000/api/auth/login",
        json={"email": "user@example.com", "password": "SecurePass123!"}
    )
    assert response.status_code == 200
    assert "token" in response.json()

def test_login_api_rejects_invalid_email():
    response = requests.post(
        "http://localhost:8000/api/auth/login",
        json={"email": "invalid", "password": "SecurePass123!"}
    )
    assert response.status_code == 400
    assert response.json()["error"] == "Invalid email format"
```

---

### Step 4: Run Database Integration Tests

**Execute tests with real database**:

```python
# tests/integration/database/test_user_db.py
# Validates: <REQ-ID> (database integration)

def test_user_registration_persists_to_database(db_session):
    """Test user registration saves to database"""
    user = register("new@example.com", "SecurePass123!")

    # Verify user in database
    db_user = db_session.query(User).filter_by(email="new@example.com").first()
    assert db_user is not None
    assert db_user.email == "new@example.com"
```

---

### Step 5: Run End-to-End Tests

**Execute full user journeys**:

```python
# tests/e2e/test_user_flow.py
# Validates: INT-100 (complete user authentication flow)

def test_complete_registration_and_login_flow(browser):
    """Test complete user journey: register → login → access protected page"""

    # Register
    browser.visit("/register")
    browser.fill("email", "newuser@example.com")
    browser.fill("password", "SecurePass123!")
    browser.click("Register")
    assert browser.is_text_present("Registration successful")

    # Login
    browser.visit("/login")
    browser.fill("email", "newuser@example.com")
    browser.fill("password", "SecurePass123!")
    browser.click("Login")
    assert browser.is_text_present("Welcome")

    # Access protected page
    browser.visit("/dashboard")
    assert browser.is_text_present("Dashboard")  # Not redirected to login
```

---

### Step 6: Aggregate Results

**Collect all test results**:

```
Integration Test Summary:

BDD Scenarios:
  ✓ 12 scenarios, all passing
  ✓ 67 steps, all passing
  ✓ Duration: 5.2s

API Integration Tests:
  ✓ 24 tests passing
  ✓ Duration: 3.8s

Database Integration Tests:
  ✓ 15 tests passing
  ✓ Duration: 8.1s

End-to-End Tests:
  ✓ 6 tests passing
  ✓ Duration: 42.5s

Total: 57 integration tests
Pass Rate: 100%
Total Duration: 59.6s
```

---

### Step 7: Map Tests to Requirements

**Show which requirements validated**:

```
Requirements Validated by Integration Tests:

<REQ-ID> (User login):
  ✓ BDD: features/authentication.feature (3 scenarios)
  ✓ API: tests/integration/api/test_auth_api.py (5 tests)
  ✓ E2E: tests/e2e/test_user_flow.py (1 test)
  Total: 9 integration tests ✅

<REQ-ID> (Payment processing):
  ✓ BDD: features/payments.feature (2 scenarios)
  ✓ API: tests/integration/api/test_payment_api.py (8 tests)
  Total: 10 integration tests ✅

REQ-NFR-PERF-001 (Performance):
  ✗ No integration tests ❌
  Recommendation: Add performance tests

Coverage: 90% of requirements have integration tests
```

---

## Output Format

```
[RUN INTEGRATION TESTS]

Test Suites Executed:

✅ BDD Scenarios (features/):
   12 scenarios (12 passed)
   67 steps (67 passed)
   Duration: 5.2s

✅ API Integration (tests/integration/api/):
   24 tests (24 passed)
   Duration: 3.8s

✅ Database Integration (tests/integration/database/):
   15 tests (15 passed)
   Duration: 8.1s

✅ End-to-End (tests/e2e/):
   6 tests (6 passed)
   Duration: 42.5s

Total Integration Tests: 57
Pass Rate: 100% (57/57) ✅
Total Duration: 59.6s

Requirements Coverage (Integration Tests):
  ✅ <REQ-ID>: 9 tests
  ✅ <REQ-ID>: 7 tests
  ✅ <REQ-ID>: 10 tests
  ⚠️ REQ-NFR-PERF-001: 0 tests (missing)

Integration Test Coverage: 90% (27/30 requirements)

Homeostasis Status: ⚠️ MINOR DEVIATION
  - 3 requirements without integration tests
  - Recommend: Add integration tests for REQ-NFR-PERF-001, etc.

✅ Integration Tests Complete!
   All tests passing
   Minor gaps identified
```

---

## Prerequisites Check

Before invoking:
1. Integration test files exist
2. Test dependencies installed (behave, requests, selenium, etc.)
3. Test environment available (database, services running)

---

## Configuration

```yaml
plugins:
  - name: "@aisdlc/testing-skills"
    config:
      integration_tests:
        auto_run_on_commit: false
        timeout_seconds: 300
        parallel_execution: true
        frameworks:
          bdd: "behave"
          api: "pytest"
          e2e: "selenium"
        require_for_deploy: true
```

---

## Notes

**Why integration tests?**
- **Validate system behavior** (not just unit behavior)
- **Catch integration bugs** (component A + B works, but A+B+C fails)
- **Validate user flows** (BDD scenarios)
- **Pre-deployment quality gate**

**Integration vs Unit Tests**:
```
Unit Tests: Test individual functions/classes
  - Fast (milliseconds)
  - Many tests (hundreds)
  - Run frequently (every save)

Integration Tests: Test components together
  - Slower (seconds/minutes)
  - Fewer tests (dozens)
  - Run on commits/deployments
```

**Homeostasis Goal**:
```yaml
desired_state:
  all_integration_tests_passing: true
  all_requirements_have_integration_tests: true
```

**"Excellence or nothing"** 🔥
