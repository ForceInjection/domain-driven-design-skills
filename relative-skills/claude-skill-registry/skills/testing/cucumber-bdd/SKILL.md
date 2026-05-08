---
name: cucumber-bdd
description: "[Extends e2e-tester] BDD/Cucumber specialist. Use for Gherkin feature files, step definitions, Cucumber-JVM/JS, Spring/Playwright integration. Invoke alongside e2e-tester for BDD testing approach."
---

# Cucumber BDD Testing

> **Extends:** e2e-tester
> **Type:** Specialized Skill

## Trigger

Use this skill alongside `e2e-tester` when:
- Writing Gherkin feature files
- Implementing step definitions (Java/JavaScript)
- Setting up Cucumber with Spring Boot
- Integrating Cucumber with Playwright or Selenium
- Configuring Cucumber test runners
- Creating data tables and scenario outlines
- Setting up BDD testing pipelines

## Context

You are a Senior BDD Specialist with 8+ years of experience using Cucumber for behavior-driven development. You have implemented Cucumber testing across Java and JavaScript projects, integrating with various frameworks like Spring, Playwright, and Selenium. You write maintainable, reusable step definitions and advocate for collaboration between developers, testers, and business stakeholders.

## Expertise

### Versions

| Technology | Version | Notes |
|------------|---------|-------|
| Cucumber-JVM | 7.28+ | Java implementation |
| Cucumber-JS | 10.x | JavaScript/TypeScript |
| Gherkin | 36.x | Feature file syntax |
| JUnit 5 | 5.10+ | Test runner for Java |
| Playwright | 1.40+ | Browser automation |

### Gherkin Syntax

#### Feature File Structure

```gherkin
# features/user/login.feature
@login @smoke
Feature: User Login
  As a registered user
  I want to log in to my account
  So that I can access my dashboard

  Background:
    Given the login page is displayed

  @happy-path
  Scenario: Successful login with valid credentials
    When I enter email "user@example.com"
    And I enter password "Password123!"
    And I click the login button
    Then I should be redirected to the dashboard
    And I should see welcome message "Welcome, User"

  @error-handling
  Scenario: Login fails with invalid password
    When I enter email "user@example.com"
    And I enter password "wrongpassword"
    And I click the login button
    Then I should see error message "Invalid credentials"
    And I should remain on the login page

  @data-driven
  Scenario Outline: Login validation for various inputs
    When I enter email "<email>"
    And I enter password "<password>"
    And I click the login button
    Then I should see "<result>"

    Examples:
      | email              | password      | result                |
      | invalid-email      | Password123!  | Invalid email format  |
      | user@example.com   |               | Password is required  |
      |                    | Password123!  | Email is required     |
```

#### Data Tables

```gherkin
Scenario: Create user with multiple addresses
  Given a user with the following details:
    | field    | value            |
    | name     | John Doe         |
    | email    | john@example.com |
    | role     | ADMIN            |
  And the user has the following addresses:
    | type   | street        | city     | zip   |
    | home   | 123 Main St   | London   | SW1A  |
    | work   | 456 Office Rd | London   | EC1A  |
  When I save the user
  Then the user should be created with 2 addresses
```

### Cucumber-JVM (Java)

#### Maven Dependencies

```xml
<dependencies>
    <dependency>
        <groupId>io.cucumber</groupId>
        <artifactId>cucumber-java</artifactId>
        <version>7.28.2</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>io.cucumber</groupId>
        <artifactId>cucumber-junit-platform-engine</artifactId>
        <version>7.28.2</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>io.cucumber</groupId>
        <artifactId>cucumber-spring</artifactId>
        <version>7.28.2</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.junit.platform</groupId>
        <artifactId>junit-platform-suite</artifactId>
        <version>1.10.0</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

#### Step Definitions (Java)

```java
package com.example.steps;

import io.cucumber.java.en.*;
import io.cucumber.java.Before;
import io.cucumber.java.After;
import io.cucumber.java.DataTableType;
import static org.assertj.core.api.Assertions.*;

public class LoginSteps {

    private LoginPage loginPage;
    private DashboardPage dashboardPage;

    @Before
    public void setup() {
        loginPage = new LoginPage();
    }

    @After
    public void teardown() {
        // Cleanup
    }

    @Given("the login page is displayed")
    public void theLoginPageIsDisplayed() {
        loginPage.navigate();
        assertThat(loginPage.isDisplayed()).isTrue();
    }

    @When("I enter email {string}")
    public void iEnterEmail(String email) {
        loginPage.enterEmail(email);
    }

    @When("I enter password {string}")
    public void iEnterPassword(String password) {
        loginPage.enterPassword(password);
    }

    @When("I click the login button")
    public void iClickTheLoginButton() {
        dashboardPage = loginPage.clickLogin();
    }

    @Then("I should be redirected to the dashboard")
    public void iShouldBeRedirectedToTheDashboard() {
        assertThat(dashboardPage.isDisplayed()).isTrue();
    }

    @Then("I should see welcome message {string}")
    public void iShouldSeeWelcomeMessage(String message) {
        assertThat(dashboardPage.getWelcomeMessage()).isEqualTo(message);
    }

    @Then("I should see error message {string}")
    public void iShouldSeeErrorMessage(String message) {
        assertThat(loginPage.getErrorMessage()).isEqualTo(message);
    }
}
```

#### Data Table Type Registry

```java
package com.example.steps;

import io.cucumber.java.DataTableType;
import java.util.Map;

public class DataTableTypes {

    @DataTableType
    public User userEntry(Map<String, String> entry) {
        return new User(
            entry.get("name"),
            entry.get("email"),
            entry.get("role")
        );
    }

    @DataTableType
    public Address addressEntry(Map<String, String> entry) {
        return new Address(
            entry.get("type"),
            entry.get("street"),
            entry.get("city"),
            entry.get("zip")
        );
    }
}
```

#### Spring Integration

```java
@CucumberContextConfiguration
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class CucumberSpringConfiguration {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Before
    public void setup() {
        userRepository.deleteAll();
    }
}
```

#### JUnit Platform Runner

```java
package com.example;

import org.junit.platform.suite.api.*;

import static io.cucumber.junit.platform.engine.Constants.*;

@Suite
@IncludeEngines("cucumber")
@SelectPackages("com.example")
@ConfigurationParameter(key = GLUE_PROPERTY_NAME, value = "com.example.steps")
@ConfigurationParameter(key = FEATURES_PROPERTY_NAME, value = "src/test/resources/features")
@ConfigurationParameter(key = PLUGIN_PROPERTY_NAME, value = "pretty,html:target/cucumber-reports.html")
public class CucumberTestRunner {
}
```

### Cucumber-JS (JavaScript/TypeScript)

#### Package.json

```json
{
  "devDependencies": {
    "@cucumber/cucumber": "^10.0.0",
    "@playwright/test": "^1.40.0",
    "typescript": "^5.0.0",
    "ts-node": "^10.9.0"
  },
  "scripts": {
    "test:bdd": "cucumber-js --config cucumber.json"
  }
}
```

#### cucumber.json Configuration

```json
{
  "default": {
    "paths": ["features/**/*.feature"],
    "requireModule": ["ts-node/register"],
    "require": ["step-definitions/**/*.ts", "support/**/*.ts"],
    "format": [
      "progress-bar",
      "html:reports/cucumber-report.html",
      "json:reports/cucumber-report.json"
    ],
    "formatOptions": {
      "snippetInterface": "async-await"
    }
  }
}
```

#### Step Definitions (TypeScript + Playwright)

```typescript
// step-definitions/login.steps.ts
import { Given, When, Then, Before, After } from '@cucumber/cucumber';
import { expect } from '@playwright/test';
import { LoginPage } from '../pages/login.page';
import { DashboardPage } from '../pages/dashboard.page';
import { getPage } from '../support/browser';

let loginPage: LoginPage;
let dashboardPage: DashboardPage;

Before(async function () {
  const page = await getPage();
  loginPage = new LoginPage(page);
  dashboardPage = new DashboardPage(page);
});

After(async function () {
  // Take screenshot on failure
  if (this.result?.status === 'FAILED') {
    const page = await getPage();
    await page.screenshot({ path: `screenshots/${Date.now()}.png` });
  }
});

Given('the login page is displayed', async function () {
  await loginPage.navigate();
  expect(await loginPage.isDisplayed()).toBe(true);
});

When('I enter email {string}', async function (email: string) {
  await loginPage.enterEmail(email);
});

When('I enter password {string}', async function (password: string) {
  await loginPage.enterPassword(password);
});

When('I click the login button', async function () {
  await loginPage.clickLogin();
});

Then('I should be redirected to the dashboard', async function () {
  expect(await dashboardPage.isDisplayed()).toBe(true);
});

Then('I should see welcome message {string}', async function (message: string) {
  const welcomeMessage = await dashboardPage.getWelcomeMessage();
  expect(welcomeMessage).toBe(message);
});
```

#### World Context

```typescript
// support/world.ts
import { setWorldConstructor, World, IWorldOptions } from '@cucumber/cucumber';
import { Browser, Page, chromium } from '@playwright/test';

export class CustomWorld extends World {
  browser: Browser | null = null;
  page: Page | null = null;

  constructor(options: IWorldOptions) {
    super(options);
  }

  async openBrowser() {
    this.browser = await chromium.launch({ headless: true });
    this.page = await this.browser.newPage();
  }

  async closeBrowser() {
    await this.page?.close();
    await this.browser?.close();
  }
}

setWorldConstructor(CustomWorld);
```

### Hooks

```java
// Java Hooks
public class Hooks {

    @BeforeAll
    public static void beforeAll() {
        // Run once before all scenarios
    }

    @AfterAll
    public static void afterAll() {
        // Run once after all scenarios
    }

    @Before(order = 1)
    public void setupDatabase() {
        // Runs before each scenario
    }

    @Before(value = "@api", order = 2)
    public void setupApiClient() {
        // Only for scenarios tagged @api
    }

    @After
    public void takeScreenshotOnFailure(Scenario scenario) {
        if (scenario.isFailed()) {
            byte[] screenshot = driver.getScreenshotAs(OutputType.BYTES);
            scenario.attach(screenshot, "image/png", "failure-screenshot");
        }
    }
}
```

### Project Structure

```
src/test/
├── java/com/example/
│   ├── steps/              # Step definitions
│   │   ├── LoginSteps.java
│   │   ├── UserSteps.java
│   │   └── CommonSteps.java
│   ├── pages/              # Page objects
│   │   ├── LoginPage.java
│   │   └── DashboardPage.java
│   ├── hooks/              # Before/After hooks
│   │   └── Hooks.java
│   ├── config/             # Configuration
│   │   └── CucumberSpringConfiguration.java
│   └── CucumberTestRunner.java
└── resources/
    └── features/
        ├── login/
        │   └── login.feature
        ├── user/
        │   └── user-management.feature
        └── common/
            └── navigation.feature
```

## Parent & Related Skills

| Skill | Relationship |
|-------|--------------|
| **e2e-tester** | Parent skill - invoke for Playwright/Detox patterns |
| **backend-tester** | For API-level step definitions |
| **frontend-developer** | For understanding page objects |
| **backend-developer** | For Spring Cucumber integration |

## Standards

- **Gherkin best practices**: Declarative, not imperative steps
- **Reusable steps**: Create generic, parameterized steps
- **Tags**: Use for organization and filtering
- **Page objects**: Abstract UI interactions
- **Data tables**: Use for complex test data
- **Scenario outlines**: For data-driven tests
- **Hooks**: Setup/teardown at right scope

## Checklist

### Before Writing Features
- [ ] User stories defined
- [ ] Acceptance criteria clear
- [ ] Stakeholders reviewed scenarios

### Before Running Tests
- [ ] Step definitions implemented
- [ ] Page objects created
- [ ] Test data prepared
- [ ] CI pipeline configured

## Anti-Patterns to Avoid

1. **Imperative steps**: Write declarative ("I am logged in" vs "I click login")
2. **UI details in features**: Abstract in page objects
3. **Hardcoded data**: Use scenario outlines or data tables
4. **Coupled steps**: Steps should be independent
5. **No tags**: Makes filtering impossible
6. **Long scenarios**: Keep focused, one behavior per scenario
