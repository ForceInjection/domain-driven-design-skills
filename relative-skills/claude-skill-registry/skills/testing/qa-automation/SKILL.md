---
name: qa-automation
description: Write E2E tests using Playwright with Cucumber/Gherkin for this project. Use when creating tests, writing test cases, testing UI flows, API testing, or when user mentions e2e, playwright, cucumber, gherkin, bdd, test automation, or QA.
---

# Playwright E2E Testing with Cucumber/Gherkin

## Project Setup
- Feature files: `tests/e2e/features/*.feature`
- Step definitions: `tests/e2e/steps/*.steps.ts`
- Config: `playwright.config.ts`
- Base URL: `http://localhost:3000`

## Gherkin Syntax

### Feature File Structure
```gherkin
Feature: Feature Name
  As a [role]
  I want [feature]
  So that [benefit]

  Background:
    Given some precondition that applies to all scenarios

  Scenario: Scenario name
    Given some initial context
    When an action is performed
    Then an expected outcome occurs

  Scenario Outline: Parameterized scenario
    Given a user with <role> role
    When they access <page>
    Then they should see <expected>

    Examples:
      | role    | page       | expected        |
      | student | /dashboard | "My Courses"    |
      | writer  | /dashboard | "Create Course" |
```

### Gherkin Keywords
- **Feature**: High-level description of a software feature
- **Background**: Steps run before each scenario in the feature
- **Scenario**: A concrete example of system behavior
- **Scenario Outline**: Template with Examples for data-driven tests
- **Given**: Precondition/initial context
- **When**: Action/event
- **Then**: Expected outcome/assertion
- **And/But**: Continue previous step type

## Step Definitions

### Basic Structure
```typescript
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';
import { getPage } from '../support/world';

Given('I am on the login page', async function () {
  const page = getPage(this);
  await page.goto('/login');
});

When('I enter valid credentials', async function () {
  const page = getPage(this);
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Login' }).click();
});

Then('I should see the dashboard', async function () {
  const page = getPage(this);
  await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
});
```

### Parameterized Steps
```typescript
Given('I am logged in as a {string} user', async function (role: string) {
  const page = getPage(this);
  // Login with role-specific credentials
  await loginAs(page, role);
});

When('I navigate to {string}', async function (path: string) {
  const page = getPage(this);
  await page.goto(path);
});

Then('I should see {int} atoms in the endpoint', async function (count: number) {
  const page = getPage(this);
  await expect(page.locator('[data-testid="atom"]')).toHaveCount(count);
});
```

### Data Tables
```gherkin
Scenario: Create a course with endpoints
  Given I am logged in as a writer
  When I create a course with the following endpoints:
    | name              | passThreshold |
    | HTML Fundamentals | 50            |
    | CSS Basics        | 60            |
  Then the course should have 2 endpoints
```

```typescript
When('I create a course with the following endpoints:', async function (dataTable) {
  const page = getPage(this);
  const endpoints = dataTable.hashes(); // [{name: 'HTML...', passThreshold: '50'}, ...]

  for (const endpoint of endpoints) {
    await page.getByRole('button', { name: 'Add Endpoint' }).click();
    await page.getByLabel('Endpoint Name').fill(endpoint.name);
    await page.getByLabel('Pass Threshold').fill(endpoint.passThreshold);
    await page.getByRole('button', { name: 'Save' }).click();
  }
});
```

## Example Feature Files

### Authentication Feature
```gherkin
Feature: User Authentication
  As a user
  I want to log in to my organization
  So that I can access the learning platform

  Background:
    Given an organization "test-org" exists
    And a student user exists in the organization

  Scenario: Successful login
    Given I am on the login page for "test-org"
    When I enter valid credentials
    And I click the login button
    Then I should be redirected to the dashboard
    And I should see a welcome message

  Scenario: Failed login with wrong password
    Given I am on the login page for "test-org"
    When I enter an invalid password
    And I click the login button
    Then I should see an error message "Invalid credentials"
    And I should remain on the login page

  Scenario Outline: Role-based dashboard
    Given I am logged in as a <role> user
    When I view the dashboard
    Then I should see <section>

    Examples:
      | role    | section          |
      | student | "My Learning"    |
      | writer  | "My Courses"     |
      | admin   | "Organization"   |
```

### Adaptive Learning Feature
```gherkin
Feature: Adaptive Learning Flow
  As a student
  I want the system to adapt to my learning
  So that I can learn more effectively

  Background:
    Given I am enrolled in a course "Frontend Developer"
    And the course has an endpoint "HTML Basics" with 5 atoms

  Scenario: Complete atom successfully
    Given I am on atom 1 of endpoint "HTML Basics"
    When I read the atom content
    And I answer the assessment correctly
    Then I should see a success message
    And I should proceed to atom 2

  Scenario: Fail atom and get AI assistance
    Given I am on atom 3 of endpoint "HTML Basics"
    When I read the atom content
    And I answer the assessment incorrectly
    Then the AI chat assistant should open
    And I should see an explanation of the concept
    When I ask a question about the concept
    Then I should receive a helpful response
    When I retry the assessment and answer correctly
    Then the chat should close
    And I should proceed to atom 4

  Scenario: Fail endpoint and receive injected atoms
    Given I have completed endpoint "HTML Basics" with 40% score
    And the pass threshold is 50%
    Then the system should analyze my knowledge gaps
    And inject additional atoms into the endpoint
    When I view the endpoint
    Then I should see the injected atoms
    And the atoms should be contextually relevant
```

### Course Creation Feature
```gherkin
Feature: AI-Assisted Course Creation
  As a writer
  I want to upload materials and have AI generate a course
  So that I can create courses without manual structuring

  Scenario: Upload materials and generate course structure
    Given I am logged in as a writer
    And I am on the course creation page
    When I upload the following materials:
      | type  | file                    |
      | pdf   | web-development.pdf     |
      | video | intro-to-html.mp4       |
    And I click "Analyze Materials"
    Then I should see a loading indicator
    When the analysis completes
    Then I should see a proposed course structure
    And the structure should include endpoints
    And each endpoint should contain atoms

  Scenario: Customize pass threshold
    Given I have a proposed course structure
    When I set the pass threshold for "HTML Basics" to 70%
    And I publish the course
    Then students enrolling should have 70% pass requirement for that endpoint
```

## Commands

```bash
# Run all tests
npx playwright test

# Run specific feature file
npx playwright test tests/e2e/features/auth.feature

# Run tests with specific tag
npx playwright test --grep @smoke

# Run in UI mode
npx playwright test --ui

# Debug mode
npx playwright test --debug

# Generate HTML report
npx playwright test --reporter=html
```

## Tags

Use tags to organize and filter tests:
```gherkin
@smoke
Feature: Critical Path Tests

@wip
Scenario: Work in progress test

@slow
Scenario: Long-running test

@api
Scenario: API-only test
```

## Best Practices

1. **Write features from user perspective** - Use business language, not technical jargon
2. **Keep scenarios independent** - Each scenario should be self-contained
3. **Use Background wisely** - Only for truly common setup across ALL scenarios
4. **One behavior per scenario** - Don't combine multiple behaviors
5. **Use meaningful names** - Scenario names should describe the behavior being tested
6. **Prefer user-facing locators** - `getByRole`, `getByText`, `getByLabel`, `getByTestId`
7. **Avoid implementation details** - Focus on what, not how

## Test Maintenance Rules

**IMPORTANT: Keep tests in sync with code changes.**

When modifying application code, you MUST:
1. Check if existing features cover the modified code
2. Update affected scenarios and step definitions
3. Add new scenarios for new functionality
4. Run `npx playwright test` to verify all tests pass
5. Never leave broken tests behind

When adding new features:
- Create corresponding feature file if none exists
- Add scenarios for happy path and error cases
- Test edge cases and validation
- Include both UI and API scenarios where applicable

When fixing bugs:
- Add a regression scenario that reproduces the bug first
- Verify the fix makes the test pass

## Domain Terminology

Use correct MentorChik terminology in tests:
- **Course** (not "class" or "module") - The complete learning roadmap
- **Endpoint** (not "section" or "chapter") - A milestone with atoms
- **Atom** (not "lesson" or "skill") - Smallest learning unit with assessment
- **Pass Threshold** - Minimum % to pass an endpoint (default 50%)
- **AI Chat** - Assistant that opens on atom failure
- **Atom Injection** - Adding atoms for struggling students
