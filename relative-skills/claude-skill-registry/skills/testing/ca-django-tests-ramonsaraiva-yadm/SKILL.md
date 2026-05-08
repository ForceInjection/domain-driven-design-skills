---
name: ca-django-tests
description: ALWAYS use this skill proactively for Consumer Affairs Django repositories (located in ../ca/ directory) when ANY of these occur - (1) User mentions coverage, codecov, test coverage, partial coverage, branch coverage, or uncovered lines/code (2) User asks to write tests, add tests, run tests, or fix test failures (3) User asks to implement features, fix bugs, or modify code in CA repos and tests are needed (4) User provides a file path containing 'test' or 'tests' in CA repos (5) After writing new code in CA repos that needs test coverage. This skill handles Django test execution using the 'ca magictest' command and ensures 100% code coverage for CI requirements.
---

# CA Django Testing Skill

This skill helps write and run Django unit tests in Consumer Affairs repositories with a focus on achieving 100% code coverage.

## When to Use This Skill

**AUTOMATIC ACTIVATION TRIGGERS** - Activate this skill immediately when:

- ✅ User mentions ANY coverage-related terms: "coverage", "codecov", "test coverage", "partial coverage", "branch coverage", "uncovered lines", "missing coverage", "BrPart", "line X is not covered", "partially covered"
- ✅ User asks to write tests for CA repository code
- ✅ User wants to add test coverage for existing functions
- ✅ User needs to run tests in CA repos
- ✅ User mentions fixing test failures or improving coverage
- ✅ User references specific test files or test paths in CA repos
- ✅ User says "use the test skill" or similar phrases

**PROACTIVE USE** - Also use this skill proactively (without being asked) when:

- After implementing new features in CA repos that need tests
- After fixing bugs in CA repos that need test verification
- When analyzing code that lacks proper test coverage

## Writing Tests

### Test File Location Strategy

**CRITICAL**: Always prioritize using existing test modules unless creating a new code module:

1. **Check for existing test files** first before creating new ones
2. **Add tests to existing test modules** that are related to the code being tested
3. **Only create new test files** when:
   - Creating a completely new code module
   - The existing test file would become too large (>1000 lines)
   - The new functionality is logically separate from existing tests

### Test Structure Requirements

All tests MUST follow these principles:

#### 1. Test base class

Some repositories might have their own baseclass extending Django's `TestCase` class.

- Look for other test modules and make sure you're using the same base class as they
- If you don't find test modules examples, try finding if we're extending Django's base `TestClass` with our own

#### 2. Unit Test Each Function Separately

- Each function/method should have its own test class
- Test one function at a time in isolation
- Use mocking for dependencies and external calls

#### 3. Cover Every Code Path

**THIS IS CRITICAL**: You must write tests for:

- ✅ Happy path (expected inputs)
- ✅ Edge cases (empty inputs, None values, boundary conditions)
- ✅ Error conditions (exceptions, invalid inputs)
- ✅ Each branch in if/else statements
- ✅ Each iteration scenario in loops
- ✅ Each return statement path
- ✅ Early returns and guard clauses

**Goal: 100% code coverage** - codecov must pass in CI

#### 4. Test Naming Convention

```python
def test_<function_name>_<scenario>_<expected_outcome>(self):
    """Clear description of what is being tested"""
```

Examples:

- `test_calculate_total_with_valid_items_returns_sum()`
- `test_calculate_total_with_empty_list_returns_zero()`
- `test_calculate_total_with_negative_values_raises_error()`

### Testing Best Practices

#### Use Mocking Appropriately

```python
from unittest.mock import patch, Mock, MagicMock

class MyServiceTestCase(TestCase):
    @patch('app.module.external_api_call')
    def test_service_with_mocked_api(self, mock_api):
        mock_api.return_value = {'status': 'success'}
        # Test your code
```

#### Use Fixtures and Setup

```python
class MyTestCase(TestCase):
    def setUp(self):
        """Set up test fixtures that are reused across tests"""
        self.user = User.objects.create(username='testuser')

    def tearDown(self):
        """Clean up after tests if needed"""
        pass
```

#### Test Database Interactions

```python
from django.test import TestCase

class ModelTestCase(TestCase):
    def test_model_creation(self):
        instance = MyModel.objects.create(field='value')
        self.assertEqual(instance.field, 'value')
        self.assertIsNotNone(instance.pk)
```

## Running Tests

### Priority Order for Running Tests

Use the `ca` helper script with the following priority:

#### 1. First Try: `ca magictest` (PREFERRED)

```bash
ca magictest path.to.the.tests.folder.or.module
```

Examples:

- `ca magictest app.api.tests.test_views`
- `ca magictest app.api.tests`
- `ca magictest .` (run all tests)

**This is the preferred method** - it uses containers that are already running.

#### 2. If magictest fails: `ca pytest`

```bash
ca pytest path/to/the/tests/folder/or/module
```

Use this if the repo has pytest support:

- `ca pytest app/api/tests/test_views.py`
- `ca pytest app/api/tests/`

#### 3. If pytest not available: `ca test`

```bash
ca test path.to.the.tests.folder.or.module
```

Fallback to Django's test runner:

- `ca test app.api.tests.test_views`

### IMPORTANT: Container Usage

- **DO NOT** use `docker compose run` - this starts a separate container
- **DO USE** the `ca` script - it uses already running containers
- The containers should already be running before executing tests

### Running Specific Tests

To run a single test method:

```bash
ca magictest app.api.tests.test_views.MyTestCase.test_specific_method
```

## Workflow Example

When user asks to "write tests for the authenticate function":

1. **Locate the function** to understand its code paths
2. **Find existing test file** for that module (e.g., if function is in `app/api/auth.py`, look for `app/api/tests/test_auth.py`)
3. **Analyze all code paths** in the function:
   - Note all branches (if/else, try/except)
   - Note all return statements
   - Note edge cases
4. **Write comprehensive tests** covering each path:
   - Create test class for the function
   - Write individual test methods for each code path
   - Use mocking for external dependencies
5. **Run tests** using `ca magictest`:

   ```bash
   ca magictest app.api.tests.test_auth
   ```

6. **Verify coverage** - ensure all lines are covered
7. **Fix any failures** and re-run

## Coverage Requirements

- **Target: 100% code coverage**
- Every line of code must be executed by at least one test
- Every branch must be tested
- Codecov CI check must pass
- Use coverage reports to identify untested code paths

## Common Patterns in CA Repos

### Testing API Views

```python
from django.test import TestCase, RequestFactory
from unittest.mock import patch

class ViewTestCase(TestCase):
    def setUp(self):
        self.factory = RequestFactory()

    def test_view_returns_200(self):
        request = self.factory.get('/api/endpoint/')
        response = my_view(request)
        self.assertEqual(response.status_code, 200)
```

### Testing with Authentication

```python
from django.contrib.auth.models import User

class AuthenticatedTestCase(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass'
        )
        self.client.login(username='testuser', password='testpass')
```

### Testing Async Code

```python
from django.test import TestCase
import asyncio

class AsyncTestCase(TestCase):
    def test_async_function(self):
        result = asyncio.run(my_async_function())
        self.assertEqual(result, expected_value)
```

## Remember

✅ Check for existing test files first
✅ Cover every single code path
✅ Use `ca magictest` for running tests
✅ Aim for 100% coverage
✅ Mock external dependencies
✅ Test error conditions, not just happy paths
✅ Use descriptive test names
✅ Keep tests focused and isolated
