---
name: e2e-testing-standards
description: Implement robust E2E tests with Playwright or Cypress using Page Object Model, proper waits, and CI/CD integration. Covers selector strategies, flaky test prevention, and cross-browser testing patterns.
---

# E2E Testing Standards

End-to-end testing validates complete user workflows across the entire application stack, simulating real user interactions to ensure system reliability.

## Quick Reference

### Framework Comparison

| Feature | Playwright | Cypress |
|---------|-----------|---------|
| Browsers | Chromium, Firefox, WebKit | Chromium (Firefox experimental) |
| Auto-waiting | Built-in | Built-in |
| Debugging | Trace viewer | Time-travel |
| Best for | Cross-browser, complex scenarios | Rapid development, visual debugging |

### Page Object Model Pattern

```typescript
// Page Object
class LoginPage {
  constructor(private page: Page) {}

  async login(username: string, password: string) {
    await this.page.fill('[data-testid="username"]', username);
    await this.page.fill('[data-testid="password"]', password);
    await this.page.click('[data-testid="login-button"]');
  }
}

// Test
test('user can login', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.login('user@example.com', 'password');
  await expect(page).toHaveURL('/dashboard');
});
```

### Essential Checklist

**Selectors (Priority Order)**

1. `data-testid` attributes (most reliable)
2. Accessibility roles/labels
3. Text content
4. CSS selectors (last resort)

**Waits**

- Rely on framework auto-waiting
- Use explicit waits for specific conditions
- Never use hard-coded `sleep()` or `wait(ms)`

**Test Data**

- Use test-specific data (not production)
- Clean up after tests
- Use API calls for setup when possible

---

## Framework Setup

### Playwright Setup

```bash
npm init playwright@latest
```

**Project Structure**

```
tests/
  e2e/
    auth/login.spec.ts
    fixtures/test-data.ts
  page-objects/
    LoginPage.ts
    BasePage.ts
playwright.config.ts
```

**Configuration**

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  reporter: [['html'], ['junit', { outputFile: 'test-results/junit.xml' }]],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
});
```

### Cypress Setup

```bash
npm install --save-dev cypress
npx cypress open
```

**Configuration**

```typescript
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: true,
  },
  retries: { runMode: 2, openMode: 0 },
});
```

---

## Page Object Model

### Base Page Pattern

```typescript
import { Page } from '@playwright/test';

export abstract class BasePage {
  constructor(protected page: Page) {}

  async navigate(path: string = '') {
    await this.page.goto(path);
  }

  async waitForPageLoad() {
    await this.page.waitForLoadState('networkidle');
  }
}
```

### Feature Page Object

```typescript
import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

export class LoginPage extends BasePage {
  readonly usernameInput: Locator;
  readonly passwordInput: Locator;
  readonly loginButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    super(page);
    this.usernameInput = page.getByTestId('username-input');
    this.passwordInput = page.getByTestId('password-input');
    this.loginButton = page.getByRole('button', { name: 'Log in' });
    this.errorMessage = page.getByTestId('error-message');
  }

  async login(username: string, password: string) {
    await this.usernameInput.fill(username);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }

  async getErrorText(): Promise<string> {
    return await this.errorMessage.textContent() || '';
  }
}
```

---

## Locator Strategies

### Best Practices

```typescript
// 1. Test IDs (Recommended)
await page.getByTestId('submit-button').click();
cy.get('[data-testid="submit-button"]').click();

// 2. Accessibility Attributes
await page.getByRole('button', { name: 'Submit' }).click();
await page.getByLabel('Email address').fill('user@example.com');

// 3. Text Content
await page.getByText('Welcome back').click();
cy.contains('Welcome back').click();

// 4. CSS Selectors (Last Resort)
await page.locator('.submit-btn.primary').click();
```

### Good vs Bad Examples

```typescript
// Good: Resilient to UI changes
await page.getByRole('navigation').getByRole('link', { name: 'Products' });

// Bad: Brittle, breaks with styling changes
await page.locator('#nav > ul > li:nth-child(2) > a');

// Good: Semantic and accessible
await page.getByLabel('Search').fill('laptops');

// Bad: Depends on implementation details
await page.locator('input[name="q"][type="text"]').fill('laptops');
```

---

## Waits and Timing

### Auto-Waiting

Both frameworks automatically wait for elements to be:

- Present in DOM
- Visible
- Enabled (for interactions)
- Stable (not animating)

```typescript
// No explicit wait needed
await page.click('button'); // Waits for button to be clickable
cy.get('button').click();   // Waits for button to be clickable
```

### Explicit Waits

```typescript
// Wait for element state
await page.waitForSelector('[data-testid="results"]', { state: 'visible' });
cy.get('[data-testid="results"]').should('be.visible');

// Wait for network
await page.waitForResponse(
  response => response.url().includes('/api/users') && response.status() === 200
);

// Cypress intercept
cy.intercept('GET', '/api/users').as('getUsers');
cy.wait('@getUsers');
```

### Anti-Patterns

```typescript
// NEVER: Hard-coded delays
await page.waitForTimeout(5000); // Brittle and slow

// BETTER: Wait for specific condition
await page.waitForSelector('[data-testid="loaded"]');
```

---

## Flaky Test Prevention

### Common Causes and Solutions

**1. Race Conditions**

```typescript
// Flaky
await page.goto('/dashboard');
await page.click('[data-testid="menu-button"]');

// Stable
await page.goto('/dashboard');
await page.waitForLoadState('networkidle');
await page.getByTestId('menu-button').click();
```

**2. Test Interdependence**

```typescript
// Flaky: Tests share state
test('create item', async ({ page }) => {
  // Creates item in shared database
});

test('list items', async ({ page }) => {
  // Depends on previous test!
});

// Stable: Each test is independent
test('create item', async ({ page }) => {
  await createItemViaAPI(); // Setup
  await page.goto('/items');
  await deleteItemViaAPI(); // Teardown
});
```

**3. Network Instability**

```typescript
// Flaky: Depends on real API
await page.goto('/profile');
await expect(page.getByTestId('username')).toContainText('John');

// Stable: Mock API responses
await page.route('/api/user', route => {
  route.fulfill({
    status: 200,
    body: JSON.stringify({ name: 'John' }),
  });
});
await page.goto('/profile');
```

---

## CI/CD Integration

### GitHub Actions

```yaml
name: E2E Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        browser: [chromium, firefox, webkit]
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
      - run: npm ci
      - run: npx playwright install --with-deps ${{ matrix.browser }}
      - run: npx playwright test --project=${{ matrix.browser }}
      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report-${{ matrix.browser }}
          path: playwright-report/
```

### Running Tests

```bash
# All browsers
npx playwright test

# Specific browser
npx playwright test --project=firefox

# Test sharding (parallel machines)
npx playwright test --shard=1/4
```

---

## Test Data Management

### Fixtures

```typescript
export const testUsers = {
  admin: { email: 'admin@test.com', password: 'Admin123!', role: 'admin' },
  user: { email: 'user@test.com', password: 'User123!', role: 'user' },
};
```

### API Setup/Teardown

```typescript
import { test as base } from '@playwright/test';

export const test = base.extend({
  authenticatedUser: async ({ request }, use) => {
    // Setup: Create user via API
    const response = await request.post('/api/auth/register', {
      data: { email: `test-${Date.now()}@example.com`, password: 'Test123!' },
    });
    const { token, userId } = await response.json();

    await use({ token, userId });

    // Teardown: Delete user via API
    await request.delete(`/api/users/${userId}`, {
      headers: { Authorization: `Bearer ${token}` },
    });
  },
});
```

---

## Advanced Patterns

### Authentication State Reuse

```typescript
// auth.setup.ts
setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="username"]', process.env.TEST_USER!);
  await page.fill('[data-testid="password"]', process.env.TEST_PASSWORD!);
  await page.click('[data-testid="login-button"]');
  await page.context().storageState({ path: 'auth-state.json' });
});
```

### Network Mocking

```typescript
test('handles API error gracefully', async ({ page }) => {
  await page.route('/api/products', route => {
    route.fulfill({
      status: 500,
      body: JSON.stringify({ error: 'Internal Server Error' }),
    });
  });

  await page.goto('/products');
  await expect(page.getByTestId('error-message'))
    .toContainText('Failed to load products');
});
```

### Accessibility Testing

```typescript
import AxeBuilder from '@axe-core/playwright';

test('homepage has no accessibility violations', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```

---

## Deep Dive Resources

For complete examples and advanced configurations, see:

- **REFERENCE.md** - Complete test suites, advanced page objects, visual testing, Docker integration
- **Playwright Docs**: https://playwright.dev/docs/intro
- **Cypress Docs**: https://docs.cypress.io/guides/overview/why-cypress

### Related Skills

- unit-testing
- integration-testing
- accessibility-testing
