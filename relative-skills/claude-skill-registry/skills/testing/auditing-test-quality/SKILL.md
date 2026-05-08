---
name: Auditing Test Quality
description: Automates test quality assessment, identifies vanity tests, and guides systematic improvement of test suites. Use when reviewing test suites, identifying shallow tests, enforcing behavioral test standards, or when the user mentions test quality, vanity tests, or test effectiveness.
---

# Auditing Test Quality

Systematically audit test quality to identify vanity tests and guide improvement.

## What you should do
Automate test quality assessment, identify vanity tests, and guide systematic improvement of test suites.

## Prerequisites
- Test audit script available (usually `scripts/audit_tests.py` or `make audit-tests`)
- Project follows behavioral test naming conventions
- Mock and assertion counting tools configured

## Workflow

### Step 1: Run test quality audit

```bash
# Run the audit script
python scripts/audit_tests.py
# or
make audit-tests
# or
npm run audit:tests
```

Expected output format:
```
Test Quality Audit Report
=========================

ISSUES FOUND: 12

tests/unit/test_user_service.py:
  - test_save_user: Non-behavioral test name
  - test_get_user: Too many mocks (7)
  - test_update_user: Poor mock-to-assertion ratio (1/4)

tests/integration/test_api.py:
  - test_endpoint: Non-behavioral test name
  - test_auth: Poor mock-to-assertion ratio (2/6)

SUMMARY:
  Total tests examined: 45
  Tests with issues: 12 (26.7%)
  Issues by type:
    - Non-behavioral names: 8
    - Too many mocks: 2
    - Poor mock ratio: 4
    - Vanity tests: 3
```

### Step 2: Prioritize issues by severity

**High priority (fix immediately):**
- Tests with >5 mocks
- Tests with only mock assertions (no behavior verification)
- Tests that would pass with broken functionality

**Medium priority (fix this sprint):**
- Tests with poor mock-to-assertion ratio (<3:1)
- Tests with implementation-focused names
- Tests mocking internal business logic

**Low priority (fix when touching code):**
- Tests with vague names but correct behavior
- Tests with minor mock discipline violations

### Step 3: Fix high-priority issues

For each high-priority test:

1. **Analyze the test purpose**: What behavior should it verify?
2. **Identify true dependencies**: What actually needs mocking?
3. **Rewrite the test**:
   - Use behavioral naming: `test_should_X_when_Y`
   - Reduce mocks to external dependencies only
   - Add meaningful assertions about outcomes
   - Verify the test fails when functionality breaks

Example transformation:
```python
# BEFORE (vanity test)
def test_save_user():
    mock_db = Mock()
    service = UserService(mock_db)
    service.save(user_data)
    mock_db.save.assert_called_once_with(user_data)

# AFTER (behavioral test)
def test_should_return_user_id_when_saving_valid_user():
    # Use real objects where possible
    service = UserService(in_memory_repository)
    user_data = {"name": "John", "email": "john@example.com"}

    user_id = service.save(user_data)

    # Verify actual behavior
    assert user_id is not None
    assert service.find_by_id(user_id).name == "John"
    assert service.find_by_id(user_id).email == "john@example.com"
```

### Step 4: Fix medium-priority issues

**Improving mock-to-assertion ratios:**
```python
# BEFORE: Poor ratio (1 assertion, 3 mocks)
def test_user_creation():
    mock_db = Mock()
    mock_email = Mock()
    mock_logger = Mock()
    service = UserService(mock_db, mock_email, mock_logger)

    service.create_user({"email": "test@example.com"})

    mock_db.save.assert_called_once()  # Only 1 assertion

# AFTER: Good ratio (4+ assertions, 3 mocks)
def test_should_create_user_and_send_welcome_email_when_valid_data():
    mock_db = Mock()
    mock_email = Mock()
    mock_logger = Mock()
    service = UserService(mock_db, mock_email, mock_logger)

    result = service.create_user({"email": "test@example.com"})

    # Multiple meaningful assertions
    assert result["status"] == "created"
    assert result["user_id"] is not None
    mock_db.save.assert_called_once()
    mock_email.send_welcome.assert_called_once_with("test@example.com")
    assert mock_logger.info.call_count >= 1
```

**Improving test names:**
```python
# BEFORE: Implementation-focused names
def test_uses_bcrypt_hash()
def test_calls_api_endpoint()
def test_saves_to_database()

# AFTER: Behavior-focused names
def test_should_hash_password_when_user_registers()
def test_should_return_user_data_when_valid_token_provided()
def test_should_persist_user_when_registration_completes()
```

### Step 5: Remove vanity tests

For tests that only verify mocks were called:
1. **Check if behavior is covered elsewhere**: If yes, delete the vanity test
2. **If not covered**: Rewrite to test actual behavior
3. **Consider integration tests**: Some behaviors need higher-level testing

### Step 6: Re-run audit and verify improvements

```bash
# Run audit again to confirm fixes
python scripts/audit_tests.py

# Verify tests still pass
make test

# Check that tests fail when functionality breaks
# (Temporarily break a function and confirm its tests fail)
```

### Step 7: Update audit baseline

```bash
# Update the expected audit results
python scripts/audit_tests.py --update-baseline

# Or commit the new audit report as baseline
git add audit_results.json
git commit -m "test: update quality audit baseline after improvements"
```

## Automation setup

### Pre-commit hook
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: test-quality-audit
        name: Test quality audit
        entry: python scripts/audit_tests.py
        language: system
        pass_filenames: false
        files: ^tests/.*\.py$
```

### CI integration
```yaml
# .github/workflows/test-quality.yml
name: Test Quality
on: [push, pull_request]
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: 3.9
      - name: Run test quality audit
        run: |
          python scripts/audit_tests.py
          if [ $? -ne 0 ]; then
            echo "Test quality issues found. See report above."
            exit 1
          fi
```

### Makefile target
```makefile
audit-tests: ## Run test quality audit
	@echo "Running test quality audit..."
	@python scripts/audit_tests.py
	@if [ $$? -eq 0 ]; then \
		echo "✅ All tests pass quality checks"; \
	else \
		echo "❌ Test quality issues found"; \
		exit 1; \
	fi
```

## Audit script customization

### Language-specific configurations

**Python (pytest):**
```python
MOCK_PATTERNS = ['mock', 'Mock', 'patch', 'MagicMock']
ASSERTION_PATTERNS = ['assert', 'assertEqual', 'assertTrue']
BEHAVIORAL_KEYWORDS = ['should', 'when', 'given', 'returns', 'rejects']
```

**JavaScript (Jest):**
```javascript
const MOCK_PATTERNS = ['jest.fn', 'mock', 'spy', 'stub'];
const ASSERTION_PATTERNS = ['expect', 'toBe', 'toEqual', 'assert'];
const BEHAVIORAL_KEYWORDS = ['should', 'when', 'given', 'returns', 'rejects'];
```

**Java (JUnit):**
```java
List<String> MOCK_PATTERNS = Arrays.asList("mock", "spy", "when", "verify");
List<String> ASSERTION_PATTERNS = Arrays.asList("assert", "verify", "assertEquals");
```

### Custom quality rules

Projects can extend the audit with domain-specific rules:
- Performance test naming patterns
- Database test cleanup verification
- API test status code checking
- Security test coverage requirements

## Quality metrics tracking

Track improvements over time:
```bash
# Generate quality report
python scripts/audit_tests.py --report=json > quality_report_$(date +%Y%m%d).json

# Track metrics:
# - Percentage of behavioral test names
# - Average mock-to-assertion ratio
# - Number of vanity tests eliminated
# - Test maintenance effort (time to update when requirements change)
```

## Benefits

1. **Prevent test debt**: Catch quality issues before they accumulate
2. **Improve debugging**: Better tests make failures easier to understand
3. **Reduce maintenance**: Behavioral tests are more resilient to refactoring
4. **Increase confidence**: Quality tests actually catch regressions
5. **Standardize practices**: Consistent quality across team members