---
name: e2e-test-design
description: Design E2E tests following user-story-driven patterns with verification checkpoints. Use when creating end-to-end tests, validating complete user journeys, or designing Playwright/Cypress test patterns.
allowed-tools: Read, Grep
---

# E2E Test Design Skill

Design end-to-end tests that validate complete user journeys.

## When to Use

- Creating E2E tests for new features
- Designing regression tests for critical paths
- Building automated user flow validation
- Documenting expected user behavior

## E2E Test Specification Template

```markdown
# E2E Test: [Test Name]

## User Story

As a [user type]
I want to [action]
So that [benefit]

## Test Steps

1. Navigate to [URL]
2. Take screenshot of initial state
3. **Verify** [element/condition] is present
4. [Action] - Click/Enter/Select
5. Take screenshot of [state]
6. **Verify** [expected result]
7. [Continue steps...]

## Success Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]
```

## Design Workflow

### Step 1: Define User Story

Start with the user's perspective:

```markdown
## User Story

As a registered user
I want to reset my password
So that I can regain access to my account
```

### Step 2: Map the User Journey

Identify each step the user takes:

1. User navigates to login page
2. User clicks "Forgot Password"
3. User enters email
4. User submits form
5. User receives confirmation message
6. User checks email (out of scope for E2E)

### Step 3: Add Verification Points

Mark critical checkpoints with **Verify**:

```markdown
## Test Steps

1. Navigate to /login
2. Take screenshot of login page
3. **Verify** "Forgot Password" link is visible
4. Click "Forgot Password" link
5. **Verify** password reset form appears
6. Enter email: "test@example.com"
7. Take screenshot of filled form
8. Click "Send Reset Link" button
9. **Verify** success message appears
10. Take screenshot of confirmation
```

### Step 4: Define Success Criteria

Clear pass/fail conditions:

```markdown
## Success Criteria

- [ ] Forgot password link is accessible
- [ ] Form accepts valid email
- [ ] Success message displayed after submission
- [ ] No error states encountered
- [ ] 3 screenshots captured
```

### Step 5: Add Structured Output

Define the expected result format:

```json
{
  "test_name": "Password Reset Flow",
  "status": "passed|failed",
  "screenshots": [
    "screenshots/01_login_page.png",
    "screenshots/02_filled_form.png",
    "screenshots/03_confirmation.png"
  ],
  "error": null
}
```

## Common E2E Test Patterns

### Authentication Flow

```markdown
# E2E Test: User Login

## User Story
As a user, I want to log in so I can access my account.

## Test Steps
1. Navigate to /login
2. **Verify** login form is visible
3. Enter username
4. Enter password
5. Click "Login" button
6. **Verify** redirected to /dashboard
7. **Verify** user name displayed in header
```

### Form Submission

```markdown
# E2E Test: Contact Form

## User Story
As a visitor, I want to submit a contact form.

## Test Steps
1. Navigate to /contact
2. **Verify** form has all required fields
3. Fill name, email, message
4. Click "Submit"
5. **Verify** success message appears
6. **Verify** form is reset
```

### Error Handling

```markdown
# E2E Test: Invalid Login

## User Story
As a user, I want to see clear errors for invalid credentials.

## Test Steps
1. Navigate to /login
2. Enter invalid credentials
3. Click "Login"
4. **Verify** error message appears
5. **Verify** still on login page
6. **Verify** password field is cleared
```

### Security Boundary

```markdown
# E2E Test: SQL Injection Protection

## User Story
As a user, I should be protected from injection attacks.

## Test Steps
1. Navigate to search page
2. Enter: "'; DROP TABLE users; --"
3. Click search
4. **Verify** error or sanitized response
5. **Verify** no database damage
```

## Screenshot Best Practices

1. **Capture at key states**: Initial, after action, final
2. **Name descriptively**: `01_initial_state.png`, `02_after_click.png`
3. **Organize by test**: `screenshots/test-name/`
4. **Keep for debugging**: Screenshots help diagnose failures

## E2E Test Output Format

For automation and resolution:

```json
{
  "test_name": "User Login",
  "status": "passed",
  "screenshots": [
    "screenshots/user-login/01_login_page.png",
    "screenshots/user-login/02_dashboard.png"
  ],
  "error": null,
  "duration_ms": 3450
}
```

For failures:

```json
{
  "test_name": "User Login",
  "status": "failed",
  "screenshots": [
    "screenshots/user-login/01_login_page.png"
  ],
  "error": "Step 6 failed: Expected redirect to /dashboard, got /error",
  "failed_step": 6,
  "duration_ms": 2100
}
```

## Memory References

- @e2e-test-patterns.md - Full E2E pattern documentation
- @closed-loop-anatomy.md - Using E2E in feedback loops
- @validation-commands.md - Integrating E2E into validation stack

## Version History

- **v1.0.0** (2025-12-26): Initial release

---

## Last Updated

**Date:** 2025-12-26
**Model:** claude-opus-4-5-20251101
