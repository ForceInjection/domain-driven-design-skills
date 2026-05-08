---
name: write-scenario
description: Write BDD scenarios in Gherkin format (Given/When/Then) in pure business language. Use when creating acceptance tests, user story scenarios, or stakeholder-readable specifications.
allowed-tools: [Read, Write, Edit, Grep, Glob]
---

# write-scenario

**Skill Type**: Actuator (BDD Workflow)
**Purpose**: Write behavior scenarios in Gherkin format (Given/When/Then)
**Prerequisites**:
- Requirement key (REQ-*) with details
- Understanding of user behavior to test

---

## Agent Instructions

You are in the **SCENARIO** phase of BDD (SCENARIO → STEP DEFINITIONS → IMPLEMENT → REFACTOR).

Your goal is to write scenarios in **pure business language** using **Given/When/Then** format.

**Critical**: Use **NO technical jargon**. Business stakeholders should understand every word.

---

## Workflow

### Step 1: Understand the Requirement

**Parse the requirement**:
- What user behavior needs to be validated?
- What are the business rules (BR-*)?
- What are the acceptance criteria?
- Who is the user (persona)?

**Example**:
```yaml
<REQ-ID>: User login with email and password

Business Rules:
- BR-001: Email must be valid format
- BR-002: Password minimum 12 characters
- BR-003: Max 3 login attempts, 15min lockout

Acceptance Criteria:
- User can log in with valid credentials
- User sees error with invalid email
- User account locks after 3 failed attempts
```

---

### Step 2: Identify Scenarios

**Create scenarios for**:
1. **Happy path** - User achieves goal successfully
2. **Business rules** - Each BR-* gets at least 1 scenario
3. **Error cases** - User makes mistakes, sees helpful errors
4. **Edge cases** - Boundary conditions

**Example scenarios for <REQ-ID>**:
```
Scenario 1: Successful login (happy path)
Scenario 2: Login fails with invalid email (BR-001)
Scenario 3: Login fails with short password (BR-002)
Scenario 4: Account locks after 3 failed attempts (BR-003)
Scenario 5: User can login after lockout expires
```

---

### Step 3: Determine Feature File Location

**Follow BDD framework conventions**:

**Cucumber (JavaScript/TypeScript/Java)**:
```
features/authentication.feature
features/payments/credit-card.feature
features/admin/user-management.feature
```

**Behave (Python)**:
```
features/authentication.feature
features/payments/credit_card.feature
features/admin/user_management.feature
```

**If unsure**: Use `features/<domain>/<feature-name>.feature`

---

### Step 4: Write Feature File in Gherkin

**Template**:

```gherkin
# features/authentication.feature

# Validates: <REQ-ID>
# Business Rules: BR-001, BR-002, BR-003

Feature: User Login
  As a registered user
  I want to log in with my email and password
  So that I can access my account

  Background:
    Given the application is running
    And I am on the login page

  Scenario: Successful login with valid credentials
    # Validates: <REQ-ID> (happy path)
    Given I am a registered user with email "user@example.com"
    And my password is "SecurePassword123!"
    When I enter email "user@example.com"
    And I enter password "SecurePassword123!"
    And I click the "Login" button
    Then I should see "Welcome back"
    And I should be redirected to the dashboard

  Scenario: Login fails with invalid email format
    # Validates: BR-001 (email validation)
    Given I am on the login page
    When I enter email "invalid-email"
    And I enter password "SecurePassword123!"
    And I click the "Login" button
    Then I should see "Invalid email format"
    And I should remain on the login page

  Scenario: Login fails with password too short
    # Validates: BR-002 (password minimum length)
    Given I am on the login page
    When I enter email "user@example.com"
    And I enter password "short"
    And I click the "Login" button
    Then I should see "Password must be at least 12 characters"
    And I should remain on the login page

  Scenario: Account locks after three failed login attempts
    # Validates: BR-003 (account lockout)
    Given I am a registered user with email "user@example.com"
    And my password is "CorrectPassword123!"
    When I attempt to login with email "user@example.com" and password "WrongPassword1!"
    And I attempt to login with email "user@example.com" and password "WrongPassword2!"
    And I attempt to login with email "user@example.com" and password "WrongPassword3!"
    Then my account should be locked
    When I attempt to login with email "user@example.com" and password "CorrectPassword123!"
    Then I should see "Account locked. Try again in 15 minutes"

  Scenario: User can login after lockout expires
    # Validates: BR-003 (lockout expiry)
    Given I am a registered user with email "user@example.com"
    And my account was locked 16 minutes ago
    When I enter email "user@example.com"
    And I enter password "CorrectPassword123!"
    And I click the "Login" button
    Then I should see "Welcome back"
    And my account should be unlocked
```

**Key elements**:
- ✅ Comment at top: `# Validates: <REQ-ID>`
- ✅ Feature description with user story (As a... I want... So that...)
- ✅ Background section (common preconditions)
- ✅ Each scenario tagged with what it validates
- ✅ Pure business language (no code terms)
- ✅ Clear, descriptive scenario names

---

### Step 5: Validate Business Language

**Check each scenario**:

**❌ Technical Language (Avoid)**:
```gherkin
When I POST to "/api/auth/login" endpoint
Then HTTP status code should be 200
And JWT token should be in response header
```

**✅ Business Language (Use)**:
```gherkin
When I enter my credentials and submit
Then I should see "Welcome back"
And I should be logged into my account
```

**Rule**: If a stakeholder can't understand it, rewrite it.

---

### Step 6: Run Scenarios (Expect FAILURE)

**Run BDD framework**:

```bash
# Cucumber (JavaScript)
npm run cucumber

# Behave (Python)
behave features/authentication.feature

# Cucumber (Java)
mvn test -Dcucumber.options="features/authentication.feature"
```

**Expected output**:
```
Feature: User Login

  Scenario: Successful login with valid credentials    # UNDEFINED
  Scenario: Login fails with invalid email format      # UNDEFINED
  Scenario: Login fails with password too short        # UNDEFINED
  Scenario: Account locks after three failed attempts  # UNDEFINED

4 scenarios (4 undefined)

You can implement step definitions for undefined steps with these snippets:

@given('I am a registered user with email {email}')
def step_impl(context, email):
    raise NotImplementedError()
```

**✅ This is GOOD!** Scenarios undefined because step definitions don't exist yet.

---

### Step 7: Commit Scenarios

**Create commit**:

```bash
git add features/authentication.feature
git commit -m "SCENARIO: Add scenarios for <REQ-ID>

Write BDD scenarios for user login functionality in business language.

Scenarios cover:
- Successful login (happy path)
- BR-001: Email validation
- BR-002: Password minimum length
- BR-003: Account lockout after 3 attempts
- BR-003: Lockout expiry

Scenarios: 5 scenarios (all undefined as expected - SCENARIO phase)

Validates: <REQ-ID>
"
```

---

## Output Format

When you complete the SCENARIO phase, show:

```
[SCENARIO Phase - <REQ-ID>]

Requirement: User login with email and password

Scenarios Created:
  ✓ Successful login (happy path)
  ✓ Login fails with invalid email (BR-001)
  ✓ Login fails with short password (BR-002)
  ✓ Account locks after 3 failed attempts (BR-003)
  ✓ User can login after lockout expires (BR-003)

Feature File: features/authentication.feature (5 scenarios, 67 lines)

Business Language Check:
  ✓ No technical jargon ✓
  ✓ Stakeholder-readable ✓
  ✓ User story format ✓

Running scenarios...
  Scenario: Successful login              UNDEFINED
  Scenario: Login fails invalid email     UNDEFINED
  Scenario: Login fails short password    UNDEFINED
  Scenario: Account locks after 3 fails   UNDEFINED
  Scenario: Login after lockout expires   UNDEFINED

Result: 5 scenarios UNDEFINED ✓ (expected - SCENARIO phase)

Commit: SCENARIO: Add scenarios for <REQ-ID>

✅ SCENARIO Phase Complete!
   Next: Invoke implement-step-definitions skill
```

---

## Prerequisites Check

Before invoking this skill, ensure:
1. Requirement key (REQ-*) exists
2. Requirement details available (what to test)
3. BDD framework available or can be installed

If prerequisites not met:
- No REQ-* → Invoke `requirement-extraction` skill
- No requirement details → Ask user for clarification

---

## Next Steps

After SCENARIO phase completes:
1. **Do NOT implement step definitions yet** (that's next phase)
2. Invoke `implement-step-definitions` skill to create step definitions
3. Scenarios should become PENDING (step definitions exist but implementation missing)

---

## Gherkin Best Practices

### Good Scenario Writing

**✅ Declarative (What, not How)**:
```gherkin
When I log in with valid credentials
Then I should see my dashboard
```

**❌ Imperative (Too detailed)**:
```gherkin
When I type "user@example.com" in the email field
And I type "password123" in the password field
And I move my mouse to the login button
And I click the login button
Then I should see a div with class "dashboard"
```

### Good Step Writing

**✅ Reusable**:
```gherkin
Given I am logged in as "user@example.com"
```

**❌ Too specific**:
```gherkin
Given there is a user "user@example.com" with password "pass123" in the database
And I navigate to "/login"
And I enter "user@example.com" in "#email-input"
And I enter "pass123" in "#password-input"
And I click "#login-button"
```

### Background vs Scenario

**Use Background** for common preconditions:
```gherkin
Background:
  Given I am on the login page

Scenario: ...
  # Don't repeat "Given I am on the login page"
```

---

## Notes

**Why business language?**
- Stakeholders can validate requirements
- Non-technical product owners can review
- Living documentation everyone understands
- Tests become communication tool

**Gherkin keywords**:
- `Feature`: High-level capability
- `Background`: Common preconditions
- `Scenario`: Specific test case
- `Given`: Preconditions (setup)
- `When`: Actions (what user does)
- `Then`: Expected outcomes (assertions)
- `And`/`But`: Continue previous keyword

**Homeostasis Goal**:
```yaml
desired_state:
  scenarios_in_business_language: true
  scenarios_cover_all_business_rules: true
  stakeholder_readable: true
```

**"Excellence or nothing"** 🔥
