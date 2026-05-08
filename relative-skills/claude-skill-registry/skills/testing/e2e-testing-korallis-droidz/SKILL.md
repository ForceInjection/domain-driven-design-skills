---
name: e2e-testing
description: End-to-end browser testing patterns with Playwright. Use when writing integration tests, user flow testing, or browser automation.
allowed-tools: Read, Write, Edit, Bash
---

# End-to-End Testing Skill

This skill covers browser-based end-to-end testing patterns using Playwright for testing complete user flows.

## Philosophy

E2E tests should:

1. **Test user flows** - Not implementation details
2. **Be reliable** - No flaky tests
3. **Be fast** - Parallel execution, smart waiting
4. **Be maintainable** - Page objects, clear selectors

---

## Setup

### Installation

```bash
npm install -D @playwright/test
npx playwright install
```

### Configuration

```javascript
// playwright.config.js
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 30000,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  use: {
    baseURL: 'http://localhost:3000',
    screenshot: 'only-on-failure',
    trace: 'on-first-retry',
  },

  projects: [
    { name: 'chromium', use: { browserName: 'chromium' } },
    { name: 'firefox', use: { browserName: 'firefox' } },
    { name: 'webkit', use: { browserName: 'webkit' } },
  ],

  webServer: {
    command: 'npm run serve',
    port: 3000,
    reuseExistingServer: !process.env.CI,
  },
});
```

---

## Test Structure

### Basic Test

```javascript
// e2e/homepage.spec.js
import { test, expect } from '@playwright/test';

test.describe('Homepage', () => {
  test('has correct title', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/My App/);
  });

  test('navigation works', async ({ page }) => {
    await page.goto('/');
    await page.click('a[href="/about"]');
    await expect(page).toHaveURL('/about');
  });
});
```

### Test Hooks

```javascript
test.describe('User Dashboard', () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test
    await page.goto('/login');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/dashboard');
  });

  test.afterEach(async ({ page }) => {
    // Cleanup if needed
  });

  test('shows user name', async ({ page }) => {
    await expect(page.locator('[data-user-name]')).toContainText('Test User');
  });
});
```

---

## Locator Strategies

### Preferred Selectors (in order)

| Priority | Selector Type | Example |
|----------|--------------|---------|
| 1 | Role | `getByRole('button', { name: 'Submit' })` |
| 2 | Label | `getByLabel('Email')` |
| 3 | Placeholder | `getByPlaceholder('Enter email')` |
| 4 | Text | `getByText('Welcome')` |
| 5 | Test ID | `getByTestId('submit-btn')` |
| 6 | CSS | `page.locator('.submit-button')` |

### Role-Based Selectors (Best Practice)

```javascript
// Buttons
await page.getByRole('button', { name: 'Submit' }).click();
await page.getByRole('button', { name: /cancel/i }).click();

// Links
await page.getByRole('link', { name: 'About Us' }).click();

// Form elements
await page.getByRole('textbox', { name: 'Email' }).fill('test@example.com');
await page.getByRole('checkbox', { name: 'Remember me' }).check();

// Navigation
await page.getByRole('navigation').getByRole('link', { name: 'Home' }).click();

// Headings
await expect(page.getByRole('heading', { level: 1 })).toHaveText('Dashboard');
```

### Test IDs for Complex Cases

```html
<!-- In HTML -->
<div data-testid="user-card">...</div>
```

```javascript
// In test
await page.getByTestId('user-card').click();
```

---

## Common Actions

### Navigation

```javascript
await page.goto('/');
await page.goto('/products/123');
await page.goBack();
await page.goForward();
await page.reload();
```

### Clicking

```javascript
await page.click('button');
await page.dblclick('button');
await page.click('button', { button: 'right' });
await page.click('button', { modifiers: ['Shift'] });
```

### Form Filling

```javascript
await page.fill('[name="email"]', 'test@example.com');
await page.fill('[name="password"]', 'secret');

// Clear and type
await page.locator('[name="search"]').clear();
await page.locator('[name="search"]').type('query');

// Select dropdown
await page.selectOption('select[name="country"]', 'US');

// Checkbox and radio
await page.check('[name="agree"]');
await page.uncheck('[name="newsletter"]');
```

### Keyboard

```javascript
await page.keyboard.press('Enter');
await page.keyboard.press('Tab');
await page.keyboard.type('Hello World');
await page.keyboard.press('Control+A');
```

---

## Assertions

### Page Assertions

```javascript
await expect(page).toHaveTitle('Dashboard');
await expect(page).toHaveURL('/dashboard');
await expect(page).toHaveURL(/\/products\/\d+/);
```

### Element Assertions

```javascript
const button = page.getByRole('button', { name: 'Submit' });

await expect(button).toBeVisible();
await expect(button).toBeEnabled();
await expect(button).toBeDisabled();
await expect(button).toHaveText('Submit');
await expect(button).toHaveAttribute('type', 'submit');
await expect(button).toHaveClass(/primary/);
await expect(button).toHaveCSS('background-color', 'rgb(37, 99, 235)');
```

### List Assertions

```javascript
const items = page.getByRole('listitem');

await expect(items).toHaveCount(5);
await expect(items.first()).toHaveText('First item');
await expect(items.nth(2)).toContainText('Third');
```

### Negation

```javascript
await expect(button).not.toBeVisible();
await expect(page.locator('.error')).not.toBeAttached();
```

---

## Waiting Strategies

### Auto-Waiting (Default)

Playwright auto-waits for elements to be actionable:

```javascript
// Automatically waits for button to be visible and enabled
await page.click('button');
```

### Explicit Waits

```javascript
// Wait for element
await page.waitForSelector('.loading', { state: 'hidden' });
await page.waitForSelector('.content', { state: 'visible' });

// Wait for navigation
await page.waitForURL('/dashboard');

// Wait for network
await page.waitForResponse('/api/data');
await page.waitForLoadState('networkidle');

// Wait for function
await page.waitForFunction(() => document.title === 'Ready');
```

### Timeout Configuration

```javascript
// Per-action timeout
await page.click('button', { timeout: 5000 });

// Per-test timeout
test('slow test', async ({ page }) => {
  test.setTimeout(60000);
  // ...
});
```

---

## Page Object Pattern

### Page Object Class

```javascript
// e2e/pages/login-page.js
export class LoginPage {
  constructor(page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign in' });
    this.errorMessage = page.getByRole('alert');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email, password) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message) {
    await expect(this.errorMessage).toContainText(message);
  }
}
```

### Using Page Objects

```javascript
// e2e/auth.spec.js
import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/login-page.js';

test.describe('Authentication', () => {
  test('successful login redirects to dashboard', async ({ page }) => {
    const loginPage = new LoginPage(page);

    await loginPage.goto();
    await loginPage.login('user@example.com', 'password');

    await expect(page).toHaveURL('/dashboard');
  });

  test('invalid credentials show error', async ({ page }) => {
    const loginPage = new LoginPage(page);

    await loginPage.goto();
    await loginPage.login('user@example.com', 'wrong');

    await loginPage.expectError('Invalid credentials');
  });
});
```

---

## Testing Patterns

### Form Submission

```javascript
test('contact form submission', async ({ page }) => {
  await page.goto('/contact');

  await page.getByLabel('Name').fill('John Doe');
  await page.getByLabel('Email').fill('john@example.com');
  await page.getByLabel('Message').fill('Hello!');

  await page.getByRole('button', { name: 'Send' }).click();

  await expect(page.getByRole('alert')).toHaveText('Message sent!');
});
```

### Modal Dialogs

```javascript
test('delete confirmation', async ({ page }) => {
  await page.goto('/items/123');

  await page.getByRole('button', { name: 'Delete' }).click();

  // Wait for modal
  const dialog = page.getByRole('dialog');
  await expect(dialog).toBeVisible();
  await expect(dialog).toContainText('Are you sure?');

  await dialog.getByRole('button', { name: 'Confirm' }).click();

  await expect(dialog).not.toBeVisible();
  await expect(page).toHaveURL('/items');
});
```

### Table Data

```javascript
test('products table displays correctly', async ({ page }) => {
  await page.goto('/products');

  const table = page.getByRole('table');
  const rows = table.getByRole('row');

  await expect(rows).toHaveCount(11); // Header + 10 items

  // Check first data row
  const firstRow = rows.nth(1);
  await expect(firstRow.getByRole('cell').first()).toHaveText('Product A');
});
```

### File Upload

```javascript
test('profile picture upload', async ({ page }) => {
  await page.goto('/settings');

  const fileInput = page.locator('input[type="file"]');
  await fileInput.setInputFiles('./fixtures/avatar.png');

  await page.getByRole('button', { name: 'Upload' }).click();
  await expect(page.getByRole('img', { name: 'Profile' })).toBeVisible();
});
```

---

## Accessibility Testing

```javascript
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('homepage is accessible', async ({ page }) => {
  await page.goto('/');

  const results = await new AxeBuilder({ page }).analyze();

  expect(results.violations).toEqual([]);
});

test('form is accessible', async ({ page }) => {
  await page.goto('/contact');

  const results = await new AxeBuilder({ page })
    .include('form')
    .analyze();

  expect(results.violations).toEqual([]);
});
```

---

## Visual Regression Testing

```javascript
test('homepage visual', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png');
});

test('component visual', async ({ page }) => {
  await page.goto('/components');
  const card = page.getByTestId('product-card');
  await expect(card).toHaveScreenshot('product-card.png');
});
```

---

## Running Tests

```bash
# Run all tests
npx playwright test

# Run specific file
npx playwright test e2e/auth.spec.js

# Run specific test
npx playwright test -g "successful login"

# Run in headed mode (see browser)
npx playwright test --headed

# Run in UI mode (interactive)
npx playwright test --ui

# Run specific browser
npx playwright test --project=chromium

# Debug mode
npx playwright test --debug

# Generate report
npx playwright show-report
```

---

## Checklist

When writing E2E tests:

- [ ] Use role-based selectors over CSS selectors
- [ ] Test user flows, not implementation
- [ ] Use Page Object pattern for complex pages
- [ ] Add data-testid only when roles/labels insufficient
- [ ] Avoid hardcoded waits (use auto-waiting)
- [ ] Include accessibility checks
- [ ] Test error states and edge cases
- [ ] Keep tests independent (no shared state)
- [ ] Use meaningful test descriptions
- [ ] Run tests in CI with retries

## Related Skills

- **unit-testing** - Write unit tests for JavaScript files using Node.js nativ...
- **forms** - HTML-first form patterns with CSS-only validation
- **accessibility-checker** - Ensure WCAG2AA accessibility compliance
- **vitest** - Write and run tests with Vitest for Vite-based projects
