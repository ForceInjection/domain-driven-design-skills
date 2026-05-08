---
name: testing-engineering
description: >-
  Domain specialist for testing strategies, test frameworks, TDD/BDD methodologies, and quality assurance.
  Scope: unit testing, integration testing, end-to-end testing, test doubles, test pyramid, coverage strategies, test quality assessment.
  Excludes: code implementation, architecture, performance.
  Triggers: "testing", "test", "unit test", "integration test", "e2e test", "TDD", "BDD", "test-driven", "behavior-driven", "mock", "stub", "fake", "test double", "coverage", "PHPUnit", "Jest", "PyTest", "RSpec", "Cypress", "Playwright", "test pyramid".
---

## Overview

Domain specialist for testing strategies, test frameworks, TDD/BDD methodologies, and quality assurance. Expertise includes unit testing, integration testing, end-to-end testing, test doubles (mocks, stubs, fakes), test pyramid, coverage strategies, and test quality assessment.

## Trigger Words

- testing, test, unit test, integration test, e2e test
- TDD, BDD, test-driven, behavior-driven
- mock, stub, fake, test double
- coverage, test coverage
- PHPUnit, Jest, PyTest, RSpec, Cypress, Playwright
- test pyramid, test smells, test quality

## Detection

### Framework Detection

**PHP:**
- PHPUnit (`phpunit.xml`, `tests/` directory, `use PHPUnit\Framework\TestCase`)
- Pest (`Pest.php`, `use PHPUnit\Framework\TestCase` with `test()` functions)
- Codeception (`codeception.yml`, `_support/` directory)
- Behat/Gherkin (`.feature` files, `FeatureContext.php`)

**JavaScript/TypeScript:**
- Jest (`__tests__/`, `*.test.js`, `*.spec.js`, `jest.config.js`)
- Mocha (`describe()`, `it()`, `before()`, `after()`)
- Vitest (`vitest.config.ts`, `import { test, expect } from 'vitest'`)
- Jasmine (`describe()`, `it()`, `spyOn()`)
- Cucumber.js (`.feature` files)
- Cypress (`cypress/`, `cy.` commands)
- Playwright (`playwright.config.ts`, `test()`, `page.`)
- Puppeteer (`puppeteer` imports, `page.evaluate()`)

**Python:**
- PyTest (`conftest.py`, `def test_`, `@pytest.fixture`)
- unittest (`unittest.TestCase`, `self.assertEqual()`)
- Nose2 (`nose2.cfg`)
- Behave (`.feature` files, `behave` command)
- Locust (locustfile.py, `@task`)
- Robot Framework (`.robot` files)

**Ruby:**
- RSpec (`spec/` directory, `describe()`, `it()`, `expect().to`)
- Minitest (`test/` directory, `class Test* < Minitest::Test`)
- Cucumber (`.feature` files, `Given/When/Then`)

**Go:**
- testing (`_test.go`, `func Test*`, `testing.T`)
- testify (`assert.Equal()`, `testify/suite`)
- ginkgo (`Describe()`, `It()`)

**Java:**
- JUnit (`@Test`, `org.junit.jupiter.api.Test`)
- TestNG (`@Test`, `org.testng.annotations.Test`)
- Mockito (`Mockito.mock()`, `when().thenReturn()`)

**C#:**
- NUnit (`[Test]`, `Assert.AreEqual()`)
- xUnit (`[Fact]`, `[Theory]`, `Assert.Equal()`)
- Moq (`Mock<T>()`, `.Setup()`)

---

## Mode Detection

### Write Mode (Progressive Guidance)

**Trigger:** `mode=write` or no explicit testing task

**Load Progressive Files:**
1. `TEST-PYRAMID.md` - Understand testing strategy
2. `AAA-PATTERNS.md` - Learn test structure
3. `UNIT-TESTING.md` - Unit testing fundamentals
4. `TEST-FRAMEWORKS.md` - Framework-specific guidance

**Behavior:**
- Provide concise examples
- Focus on getting started quickly
- Progressive complexity (simple → advanced)
- Framework-specific guidance

### Review Mode (Exhaustive Checklists)

**Trigger:** `mode=review`, "review tests", "audit tests", "check test quality", "assess testing"

**Load Review Files:**
1. `TEST-QUALITY.md` - Quality assessment checklist
2. `TEST-SMELLS.md` - Test anti-patterns detection
3. `COVERAGE.md` - Coverage metrics and thresholds
4. `COVERAGE-STRATEGIES.md` - Coverage strategy assessment

**Behavior:**
- Exhaustive review checklists
- Identify test smells
- Coverage analysis
- Quality metrics
- Gap identification

---

## Skill Loading Strategy

### Initial Load

```javascript
function loadTestingEngineeringSkill(context) {
    const mode = context.mode || 'write';

    if (mode === 'review') {
        // Load review-mode files
        loadProgressive([
            'TEST-QUALITY.md',
            'TEST-SMELLS.md',
            'COVERAGE.md',
            'COVERAGE-STRATEGIES.md'
        ]);
    } else {
        // Load write-mode files
        loadProgressive([
            'TEST-PYRAMID.md',
            'AAA-PATTERNS.md',
            'UNIT-TESTING.md',
            'TEST-FRAMEWORKS.md'
        ]);
    }

    // Always load core concepts based on query keywords
    if (context.query.match(/tdd|test-driven/i)) {
        load('TDD.md');
    }

    if (context.query.match(/bdd|behavior-driven|cucumber|behave|gherkin/i)) {
        load('BDD.md');
    }

    if (context.query.match(/mock|stub|fake|test-double/i)) {
        loadProgressive(['TEST-DOUBLES.md', 'MOCKING.md']);
    }

    if (context.query.match(/coverage/i)) {
        loadProgressive(['COVERAGE.md', 'COVERAGE-STRATEGIES.md']);
    }

    if (context.query.match(/integration/i)) {
        load('INTEGRATION-TESTING.md');
    }

    if (context.query.match(/e2e|end-to-end|cypress|playwright|puppeteer/i)) {
        load('E2E-TESTING.md');
    }

    if (context.query.match(/unit/i)) {
        load('UNIT-TESTING.md');
    }
}
```

---

## Progressive Disclosure Files

### Philosophies (Progressive)

1. `TDD.md` - Test-Driven Development methodology
2. `BDD.md` - Behavior-Driven Development methodology
3. `TEST-PYRAMID.md` - Testing strategy pyramid (unit > integration > e2e)

### Frameworks (Progressive)

4. `TEST-FRAMEWORKS.md` - Framework detection and setup (PHPUnit, Jest, PyTest, RSpec)
5. `FRAMEWORK-PATTERNS.md` - Common framework patterns

### Writing Tests (Progressive)

6. `AAA-PATTERNS.md` - Arrange-Act-Assert test structure
7. `MOCKING.md` - Mocking frameworks and best practices
8. `TEST-DOUBLES.md` - Test doubles (mocks, stubs, fakes, spies)

### Test Types (Progressive)

9. `UNIT-TESTING.md` - Unit testing fundamentals
10. `INTEGRATION-TESTING.md` - Integration testing strategies
11. `E2E-TESTING.md` - End-to-end testing with Cypress/Playwright

### Coverage & Quality (Progressive)

12. `COVERAGE.md` - Coverage metrics and thresholds
13. `COVERAGE-STRATEGIES.md` - Coverage strategy and goals
14. `TEST-QUALITY.md` - Test quality assessment checklist
15. `TEST-SMELLS.md` - Test anti-patterns and refactoring

---

## Quick Reference

### Test Pyramid

```
        E2E Tests
       (Small %)
       ↑ Low value
       ↓ Slow
    Integration Tests
      (Medium %)
      ↑ Medium value
      ↓ Medium speed
      Unit Tests
     (Largest %)
     ↑ High value
     ↓ Fast
```

### Testing Layers

| Layer | Scope | Speed | Cost | Isolation |
|-------|-------|-------|------|-----------|
| Unit | Single function/class | Fast (<100ms) | Low | Yes |
| Integration | Multiple components | Medium (<5s) | Medium | Partial |
| E2E | Full user flow | Slow (>10s) | High | No |

### Coverage Goals

| Type | Minimum | Target | Notes |
|------|---------|--------|-------|
| Statement | 70% | 80% | Lines executed |
| Branch | 60% | 75% | Conditional branches |
| Function | 80% | 90% | Functions/methods called |
| Line | 70% | 80% | Executable lines |

### Common Test Frameworks

| Language | Unit | Integration | E2E | BDD |
|----------|------|-------------|-----|-----|
| PHP | PHPUnit, Pest | PHPUnit, Codeception | Codeception | Behat |
| JS/TS | Jest, Vitest | Jest, Supertest | Cypress, Playwright | Cucumber.js |
| Python | PyTest, unittest | PyTest, Django test | Playwright | Behave |
| Ruby | RSpec, Minitest | RSpec, Capybara | Capybara | Cucumber |
| Go | testing, testify | testing, testify | - | Ginkgo |
| Java | JUnit, TestNG | JUnit, Spring Test | Selenium | Cucumber-JVM |
| C# | xUnit, NUnit | xUnit, NUnit | Selenium | SpecFlow |

---

## Core Concepts

### AAA Pattern

```javascript
// Arrange - Setup test data
const user = { id: 1, name: 'John' };
const expected = 'John';

// Act - Execute code under test
const result = getUserById(user.id);

// Assert - Verify results
expect(result.name).toBe(expected);
```

### Test Doubles

- **Stub** - Pre-programmed responses
- **Mock** - Expectations verification
- **Fake** - Working implementation (in-memory)
- **Spy** - Record method calls

### TDD Cycle

1. **Red** - Write failing test
2. **Green** - Make test pass (minimal code)
3. **Refactor** - Improve code

---

## Common Testing Commands

### PHP
```bash
# PHPUnit
./vendor/bin/phpunit
./vendor/bin/phpunit --filter testUserLogin

# Pest
./vendor/bin/pest
./vendor/bin/pest --filter testUserLogin

# Codeception
vendor/bin/codecept run
vendor/bin/codecept run functional

# Behat
vendor/bin/behat
```

### JavaScript/TypeScript
```bash
# Jest
npm test
npm test -- --watch
npm test -- --coverage

# Vitest
npm run test
npm run test:watch

# Cypress
npx cypress open
npx cypress run

# Playwright
npx playwright test
npx playwright test --headed
```

### Python
```bash
# PyTest
pytest
pytest --cov=src
pytest -k test_user_login

# unittest
python -m unittest
python -m unittest discover

# Behave
behave
```

### Ruby
```bash
# RSpec
rspec
rspec --format documentation
rspec --only-failures

# Minitest
rails test
rails test:units

# Cucumber
cucumber
cucumber features/login.feature
```

---

## When to Use This Skill

**Use When:**
- User mentions testing, tests, TDD, BDD
- Reviewing test quality or coverage
- Setting up test framework
- Writing unit/integration/e2e tests
- Refactoring test code
- Assessing test strategy

**Do Not Use For:**
- Code refactoring (use `software-engineering`)
- Performance optimization (use `performance-engineering`)
- Database queries (use `database-engineering`)
- Security vulnerabilities (use `secops-engineering`)

---

## Internal References

This skill does NOT reference other skills. All testing concepts are self-contained.

---

## File Structure

```
~/.config/opencode/skill/testing-engineering/
├── SKILL.md (this file)
├── philosophies/
│   ├── TDD.md
│   ├── BDD.md
│   └── TEST-PYRAMID.md
├── frameworks/
│   ├── TEST-FRAMEWORKS.md
│   └── FRAMEWORK-PATTERNS.md
├── patterns/
│   ├── AAA-PATTERNS.md
│   ├── MOCKING.md
│   └── TEST-DOUBLES.md
├── types/
│   ├── UNIT-TESTING.md
│   ├── INTEGRATION-TESTING.md
│   └── E2E-TESTING.md
└── quality/
    ├── COVERAGE.md
    ├── COVERAGE-STRATEGIES.md
    ├── TEST-QUALITY.md
    └── TEST-SMELLS.md
```
