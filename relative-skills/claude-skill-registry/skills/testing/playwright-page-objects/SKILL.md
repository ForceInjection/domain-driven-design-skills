---
name: playwright-page-objects
description: Playwright Page Object Model including page classes, fixtures, helpers, and test organization. Use when structuring Playwright E2E tests or organizing test code.
---

# Playwright Page Objects

Expert guidance for organizing Playwright tests with Page Object Model.

## Quick Reference

| Concept | Pattern | Location |
|---------|---------|----------|
| Page Object | Class with Locators | `pages/*.page.ts` |
| Fixture | Extended test context | `fixtures/*.ts` |
| Helper | Utility functions | `helpers/*.ts` |
| Test Spec | Test logic using pages | `e2e/*.spec.ts` |
| Test Data | Data generators | `fixtures/test-data.ts` |

## What Do You Need?

1. **Page objects** - Classes representing pages/components
2. **Fixtures** - Auth, database, test setup
3. **Test data** - Generators, factories
4. **Helpers** - Navigation, assertions
5. **Organization** - File structure, naming

Specify a number or describe your test organization need.

## Routing

| Response | Reference to Read |
|----------|-------------------|
| 1, "page object", "class", "locator" | [page-objects.md](./references/page-objects.md) |
| 2, "fixture", "extend", "setup" | [fixtures.md](./references/fixtures.md) |
| 3, "test data", "factory", "generator" | [test-data.md](./references/test-data.md) |
| 4, "helper", "utility", "navigation" | [helpers.md](./references/helpers.md) |
| 5, "structure", "organization", "folder" | [structure.md](./references/structure.md) |

## Essential Principles

**Page Object Model**: Separate page structure (Locators) from test logic (assertions). Makes tests resilient to UI changes.

**Fixtures for setup**: Extend test context with authenticated pages, database seeders, or other test utilities.

**Helpers for reuse**: Extract common operations (navigation, waits) into helper functions.

**Test data factories**: Generate test data programmatically, not hardcoded values.

## File Structure

```
tests/
├── fixtures/
│   ├── auth.ts          # Authentication helpers
│   ├── database.ts      # Database seeding
│   └── test-data.ts     # Data generators
├── pages/
│   ├── login.page.ts    # Page objects
│   ├── dashboard.page.ts
│   └── ...
├── helpers/
│   ├── navigation.ts    # Navigation helpers
│   └── assertions.ts    # Custom assertions
├── e2e/
│   ├── auth.spec.ts     # Test specs
│   └── ...
└── playwright.config.ts
```

## Code Patterns

### Page Object
```typescript
// pages/login.page.ts
import { Page, Locator } from '@playwright/test'

export class LoginPage {
  readonly page: Page
  readonly emailInput: Locator
  readonly passwordInput: Locator
  readonly submitButton: Locator

  constructor(page: Page) {
    this.page = page
    this.emailInput = page.getByTestId('email-input')
    this.passwordInput = page.getByTestId('password-input')
    this.submitButton = page.getByTestId('submit-button')
  }

  async goto() {
    await this.page.goto('/login')
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email)
    await this.passwordInput.fill(password)
    await this.submitButton.click()
  }
}
```

### Auth Fixture
```typescript
// fixtures/auth.ts
import { test as base } from '@playwright/test'

type AuthFixtures = {
  authenticatedPage: Page
}

export const test = base.extend<AuthFixtures>({
  authenticatedPage: async ({ page }, use) => {
    const user = await createTestUser()

    await page.goto('/login')
    await page.getByTestId('email-input').fill(user.email)
    await page.getByTestId('password-input').fill(user.password)
    await page.getByTestId('submit-button').click()
    await page.waitForURL('/dashboard')

    await use(page)

    await deleteTestUser(user.id)
  },
})

export const expect = test.expect
```

### Using in Tests
```typescript
// e2e/auth.spec.ts
import { test, expect } from '../fixtures/auth'
import { LoginPage } from '../pages/login.page'

test.describe('Authentication', () => {
  test('successful login', async ({ page }) => {
    const loginPage = new LoginPage(page)
    await loginPage.goto()
    await loginPage.login('user@example.com', 'password123')

    await expect(page).toHaveURL('/dashboard')
  })
})
```

## Reference Index

| File | Topics |
|------|--------|
| [page-objects.md](./references/page-objects.md) | Class structure, Locators, methods |
| [fixtures.md](./references/fixtures.md) | Extend test, cleanup, setup |
| [test-data.md](./references/test-data.md) | Factories, generators, random data |
| [helpers.md](./references/helpers.md) | Navigation, custom assertions |
| [structure.md](./references/structure.md) | Folder layout, naming conventions |

## Success Criteria

Tests are well-organized when:
- Page objects separate Locators from test logic
- Fixtures handle setup/teardown automatically
- Test data generated, not hardcoded
- Helpers extract reusable operations
- Test specs read like documentation
