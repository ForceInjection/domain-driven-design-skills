---
name: Creating Feature Tests
description: Automates the creation of behavior-driven, fail-first feature tests for user-facing behaviors. Works across any language or framework. Use when features lack behavioral tests, implementing fail-first TDD, ensuring user-facing functionality has comprehensive test coverage, or when the user mentions BDD, feature tests, or user behavior testing.
---

# Creating Feature Tests

Create behavior-driven, fail-first feature tests for user-facing behaviors.

## What you should do

1. **Collect behavior scenario from user** – Extract the core user-facing behavior to validate. If unspecified, analyze the codebase for primary user flows (e.g., authentication, form submission, navigation) and select a behavior that lacks clear test coverage.

2. **Analyze feature dependencies and requirements** – Examine the target feature's implementation to identify:
   - External services, APIs, or databases required for the feature
   - Authentication or authorization dependencies
   - UI components, forms, or user interaction elements
   - Configuration, environment variables, or feature flags
   - Third-party integrations or external systems

3. **Check for existing test coverage** – Search the `tests/features/` directory or equivalent for files or test cases related to the behavior. If the behavior is already tested, skip to Step 10 to optionally refactor, expand, or annotate the test.

4. **Scaffold test file and imports** – Generate or open a test file under `tests/features/`:
   - Import necessary testing framework components and utilities
   - Import or reference the feature components being tested
   - Set up any required test configuration or environment setup
   - Import mocking libraries or test helpers as needed

5. **Create mocks and test doubles for external dependencies** – For each external system identified:
   - Generate mock implementations for APIs, databases, or external services
   - Create stub responses for network calls or file system operations
   - Mock authentication systems or user session management
   - Set up test data fixtures for realistic scenario testing

6. **Create minimal failing behavioral test** – Generate a new test focused on user-facing behavior:
   - Use behavioral test names that describe expected outcomes (e.g., `test_should_send_reset_email_when_valid_user`)
   - Write a failing test that would actually validate the behavior when implemented
   - Include any necessary setup using the mocks and stubs created
   - Focus on what the user experiences, not internal implementation

   Example (generic):

   ```plaintext
   test_should_send_reset_email_when_valid_user:
       user = create_test_user("test@example.com")
       reset_password(user.email)
       assert email_was_sent_to("test@example.com")  // Will fail until implemented
   ```

   Python (PyTest) example:

   ```python
   def test_should_send_reset_email_when_valid_user():
       user = create_test_user("test@example.com")
       reset_password(user.email)
       assert email_service.last_sent_email.to == "test@example.com"
   ```

7. **Validate test failure (Red)** – Run the test suite and confirm the new test fails as expected. This is a critical step to ensure the test is correctly targeting the missing behavior. If it passes, the test is not valid and must be revised.

8. **Implement logic to pass test (Green)** – Write the minimum amount of code required to make the failing test pass.

9. **Re-run tests to validate success** – Execute the test suite again and confirm that the new test now passes and no other tests have broken.

10. **Annotate and document test** – Add an inline comment, docstring, or metadata annotation summarizing the user-facing behavior being tested. Use tags or decorators (e.g., `@feature`, `# Scenario:`) as appropriate for the language or test framework. Update any centralized test index or coverage tool if in use.

    Python (PyTest) specifics:

    - Decorate with `@pytest.mark.feature` for clarity.
    - Prefer fixtures in `conftest.py` for shared setup.
    - Handy commands:
      - Run features: `pytest -q tests/features/`
      - Verbose: `pytest -v tests/features/`

11. **Extend with edge cases and variations** – Add parameterized tests or test cases with real-world inputs to ensure the feature handles diverse scenarios. Use test fixtures, mocks, or setup methods where needed to keep tests isolated and deterministic.

12. **Workflow summary** – Confirm the feature is now covered by a descriptive, passing test that documents behavior and is safely committed. Recommend repeating the process for additional untested or critical behaviors.