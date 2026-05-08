---
name: web-testing-automation
description: Comprehensive web application testing automation using Playwright, including MCP integration, browser automation, E2E testing, visual regression testing, API testing, and CI/CD integration. Use when creating automated tests, setting up test frameworks, debugging test failures, implementing Page Object Model, or integrating testing into deployment pipelines.
---

# Web Testing Automation with Playwright

## Overview
This skill provides comprehensive guidance for automated web application testing using Playwright and related tools, including Microsoft's Playwright MCP integration for AI-powered testing capabilities.

## Core Technologies

### 1. Playwright - Primary Testing Framework

**Why Playwright?**
- Cross-browser support (Chromium, Firefox, WebKit)
- Auto-wait capabilities (no more flaky tests)
- Network interception and mocking
- Mobile emulation
- Screenshot and video recording
- Built-in test runner with parallel execution

**Installation:**
```bash
# Initialize new project with Playwright
npm init playwright@latest

# Or add to existing project
npm install -D @playwright/test
npx playwright install

# Install browsers
npx playwright install chromium firefox webkit
```

### 2. Playwright MCP (Model Context Protocol)

Microsoft's Playwright MCP allows AI-powered test generation and execution through Claude.

**Installation:**
```bash
# Install the Playwright MCP server
npx @playwright/mcp-server@latest
```

**Configuration for Claude:**
Add to your Claude MCP settings:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp-server"]
    }
  }
}
```

## Project Structure

```
tests/
├── playwright.config.ts          # Configuration
├── tests/
│   ├── auth/
│   │   ├── login.spec.ts        # Login tests
│   │   └── registration.spec.ts # Registration tests
│   ├── e2e/
│   │   ├── checkout.spec.ts     # E2E workflows
│   │   └── user-journey.spec.ts
│   ├── api/
│   │   └── api-tests.spec.ts    # API tests
│   └── visual/
│       └── visual-regression.spec.ts
├── pages/                        # Page Object Models
│   ├── BasePage.ts
│   ├── LoginPage.ts
│   └── DashboardPage.ts
├── fixtures/                     # Test data
│   ├── users.json
│   └── products.json
└── utils/                        # Helper utilities
    ├── test-helpers.ts
    └── custom-matchers.ts
```

## Configuration (playwright.config.ts)

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/results.json' }],
    ['junit', { outputFile: 'test-results/junit.xml' }]
  ],
  
  use: {
    // Configure based on your application type:
    // ColdFusion: http://localhost:8500
    // React: http://localhost:51xx (e.g., 5100)
    // PHP: http://localhost:4000
    baseURL: process.env.BASE_URL || 'http://localhost:8500',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 10000,
    navigationTimeout: 30000,
  },

  projects: [
    // Desktop browsers
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    
    // Mobile emulation
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    },
  ],

  // Optional: Auto-start your local dev server
  // Uncomment and configure for your application type
  // webServer: {
  //   command: 'npm run start',  // or 'php -S localhost:4000'
  //   url: 'http://localhost:4000',
  //   reuseExistingServer: !process.env.CI,
  // },
});
```

## Page Object Model (POM) Pattern

### BasePage.ts
```typescript
import { Page, Locator } from '@playwright/test';

export class BasePage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  async navigate(path: string) {
    await this.page.goto(path);
  }

  async waitForPageLoad() {
    await this.page.waitForLoadState('networkidle');
  }

  async takeScreenshot(name: string) {
    await this.page.screenshot({ path: `screenshots/${name}.png` });
  }

  async fillField(locator: string, value: string) {
    await this.page.fill(locator, value);
  }

  async clickButton(locator: string) {
    await this.page.click(locator);
  }

  async getText(locator: string): Promise<string> {
    return await this.page.textContent(locator) || '';
  }

  async waitForElement(locator: string, timeout: number = 5000) {
    await this.page.waitForSelector(locator, { timeout });
  }

  async isVisible(locator: string): Promise<boolean> {
    return await this.page.isVisible(locator);
  }
}
```

### LoginPage.ts
```typescript
import { Page, expect } from '@playwright/test';
import { BasePage } from './BasePage';

export class LoginPage extends BasePage {
  // Locators
  readonly usernameInput: string = '#username';
  readonly passwordInput: string = '#password';
  readonly loginButton: string = 'button[type="submit"]';
  readonly errorMessage: string = '.error-message';
  readonly successMessage: string = '.success-message';

  constructor(page: Page) {
    super(page);
  }

  async goto() {
    await this.navigate('/login');
    await this.waitForPageLoad();
  }

  async login(username: string, password: string) {
    await this.fillField(this.usernameInput, username);
    await this.fillField(this.passwordInput, password);
    await this.clickButton(this.loginButton);
  }

  async getErrorMessage(): Promise<string> {
    await this.waitForElement(this.errorMessage);
    return await this.getText(this.errorMessage);
  }

  async isLoginSuccessful(): Promise<boolean> {
    return await this.isVisible(this.successMessage);
  }

  async verifyLoginPage() {
    await expect(this.page).toHaveURL(/.*login/);
    await expect(this.page.locator(this.usernameInput)).toBeVisible();
    await expect(this.page.locator(this.passwordInput)).toBeVisible();
  }
}
```

## Test Examples

### Basic E2E Test
```typescript
import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';

test.describe('User Authentication', () => {
  let loginPage: LoginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.goto();
  });

  test('should login with valid credentials', async ({ page }) => {
    await loginPage.login('testuser@example.com', 'Password123!');
    
    // Verify successful login
    await expect(page).toHaveURL(/.*dashboard/);
    await expect(page.locator('.welcome-message')).toContainText('Welcome');
  });

  test('should show error with invalid credentials', async () => {
    await loginPage.login('invalid@example.com', 'wrongpassword');
    
    // Verify error message
    const errorMessage = await loginPage.getErrorMessage();
    expect(errorMessage).toContain('Invalid credentials');
  });

  test('should validate empty fields', async ({ page }) => {
    await loginPage.clickButton(loginPage.loginButton);
    
    // Check validation messages
    await expect(page.locator('input:invalid')).toHaveCount(2);
  });
});
```

### API Testing
```typescript
import { test, expect } from '@playwright/test';

test.describe('API Tests', () => {
  const baseURL = 'https://api.example.com';

  test('should fetch user data', async ({ request }) => {
    const response = await request.get(`${baseURL}/users/1`);
    
    expect(response.ok()).toBeTruthy();
    expect(response.status()).toBe(200);
    
    const data = await response.json();
    expect(data).toHaveProperty('id', 1);
    expect(data).toHaveProperty('email');
  });

  test('should create new user', async ({ request }) => {
    const newUser = {
      name: 'Test User',
      email: 'test@example.com',
      password: 'SecurePass123!'
    };

    const response = await request.post(`${baseURL}/users`, {
      data: newUser
    });

    expect(response.status()).toBe(201);
    
    const data = await response.json();
    expect(data.email).toBe(newUser.email);
    expect(data).toHaveProperty('id');
  });

  test('should handle authentication', async ({ request }) => {
    // Login to get token
    const loginResponse = await request.post(`${baseURL}/auth/login`, {
      data: {
        email: 'test@example.com',
        password: 'password123'
      }
    });

    const { token } = await loginResponse.json();

    // Use token for authenticated request
    const response = await request.get(`${baseURL}/users/me`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    expect(response.ok()).toBeTruthy();
  });
});
```

### Visual Regression Testing
```typescript
import { test, expect } from '@playwright/test';

test.describe('Visual Regression Tests', () => {
  test('homepage should match snapshot', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Take screenshot and compare
    await expect(page).toHaveScreenshot('homepage.png', {
      fullPage: true,
      maxDiffPixels: 100
    });
  });

  test('button should match snapshot', async ({ page }) => {
    await page.goto('/components');
    
    const button = page.locator('.primary-button').first();
    await expect(button).toHaveScreenshot('primary-button.png');
  });

  test('mobile viewport should match snapshot', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    
    await expect(page).toHaveScreenshot('homepage-mobile.png', {
      fullPage: true
    });
  });
});
```

### Network Interception and Mocking
```typescript
import { test, expect } from '@playwright/test';

test.describe('Network Mocking', () => {
  test('should mock API response', async ({ page }) => {
    // Intercept API call and return mock data
    await page.route('**/api/users', route => {
      route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([
          { id: 1, name: 'Mock User 1' },
          { id: 2, name: 'Mock User 2' }
        ])
      });
    });

    await page.goto('/users');
    
    // Verify mock data is displayed
    await expect(page.locator('.user-list')).toContainText('Mock User 1');
  });

  test('should handle API errors', async ({ page }) => {
    // Mock API error
    await page.route('**/api/users', route => {
      route.fulfill({
        status: 500,
        body: JSON.stringify({ error: 'Internal Server Error' })
      });
    });

    await page.goto('/users');
    
    // Verify error handling
    await expect(page.locator('.error-message')).toBeVisible();
  });

  test('should intercept and log requests', async ({ page }) => {
    const requests: string[] = [];

    // Log all API requests
    page.on('request', request => {
      if (request.url().includes('/api/')) {
        requests.push(request.url());
      }
    });

    await page.goto('/dashboard');
    
    // Verify expected API calls were made
    expect(requests).toContain(expect.stringContaining('/api/user'));
    expect(requests).toContain(expect.stringContaining('/api/stats'));
  });
});
```

## Advanced Testing Patterns

### Custom Fixtures
```typescript
import { test as base } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';

type MyFixtures = {
  loginPage: LoginPage;
  authenticatedPage: Page;
};

export const test = base.extend<MyFixtures>({
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await use(loginPage);
  },

  authenticatedPage: async ({ page }, use) => {
    // Automatically login before each test
    await page.goto('/login');
    await page.fill('#username', 'testuser@example.com');
    await page.fill('#password', 'password123');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/dashboard');
    
    await use(page);
  },
});

export { expect } from '@playwright/test';
```

### Test Data Management

**fixtures/users.json:**
```json
{
  "validUser": {
    "email": "test@example.com",
    "password": "SecurePassword123!",
    "name": "Test User"
  },
  "adminUser": {
    "email": "admin@example.com",
    "password": "AdminPass123!",
    "name": "Admin User",
    "role": "admin"
  }
}
```

**Using Test Data:**
```typescript
import { test, expect } from '@playwright/test';
import users from '../fixtures/users.json';

test('login with test data', async ({ page }) => {
  await page.goto('/login');
  await page.fill('#email', users.validUser.email);
  await page.fill('#password', users.validUser.password);
  await page.click('button[type="submit"]');
  
  await expect(page).toHaveURL(/.*dashboard/);
});
```

## Debugging Tests

### Debug Mode
```bash
# Run in debug mode with Playwright Inspector
npx playwright test --debug

# Run specific test in debug mode
npx playwright test login.spec.ts --debug

# Debug from specific line
npx playwright test --debug-line 25
```

### Trace Viewer
```typescript
// playwright.config.ts
use: {
  trace: 'on-first-retry', // or 'on', 'off', 'retain-on-failure'
}

// View trace
// npx playwright show-trace trace.zip
```

### Screenshots and Videos
```typescript
test('capture on failure', async ({ page }) => {
  // Automatic screenshot on failure if configured
  await page.goto('/');
  
  // Manual screenshot
  await page.screenshot({ path: 'screenshot.png', fullPage: true });
});

// playwright.config.ts
use: {
  screenshot: 'only-on-failure',
  video: 'retain-on-failure',
}
```

## CI/CD Integration

### GitHub Actions
```yaml
name: Playwright Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Install Playwright browsers
      run: npx playwright install --with-deps
    
    - name: Run Playwright tests
      run: npx playwright test
      env:
        BASE_URL: ${{ secrets.BASE_URL }}
    
    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: playwright-report
        path: playwright-report/
        retention-days: 30
    
    - name: Upload test videos
      uses: actions/upload-artifact@v3
      if: failure()
      with:
        name: test-videos
        path: test-results/
```

### Docker Integration
```dockerfile
FROM mcr.microsoft.com/playwright:v1.40.0-focal

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

CMD ["npx", "playwright", "test"]
```

## Performance Testing

```typescript
import { test, expect } from '@playwright/test';

test('page load performance', async ({ page }) => {
  const startTime = Date.now();
  
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  
  const loadTime = Date.now() - startTime;
  console.log(`Page loaded in ${loadTime}ms`);
  
  // Assert load time is acceptable
  expect(loadTime).toBeLessThan(3000);
});

test('API response time', async ({ request }) => {
  const startTime = Date.now();
  
  const response = await request.get('/api/users');
  
  const responseTime = Date.now() - startTime;
  console.log(`API responded in ${responseTime}ms`);
  
  expect(response.ok()).toBeTruthy();
  expect(responseTime).toBeLessThan(500);
});
```

## Accessibility Testing

```typescript
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('Accessibility Tests', () => {
  test('should not have accessibility violations', async ({ page }) => {
    await page.goto('/');
    
    const accessibilityScanResults = await new AxeBuilder({ page })
      .analyze();
    
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test('should have proper ARIA labels', async ({ page }) => {
    await page.goto('/');
    
    const button = page.locator('button.primary');
    await expect(button).toHaveAttribute('aria-label');
  });

  test('should be keyboard navigable', async ({ page }) => {
    await page.goto('/');
    
    // Test tab navigation
    await page.keyboard.press('Tab');
    const firstFocusable = await page.evaluate(() => 
      document.activeElement?.tagName
    );
    
    expect(firstFocusable).toBeTruthy();
  });
});
```

## Best Practices

### 1. Use Stable Selectors
```typescript
// ❌ Bad - Fragile selectors
await page.click('div > div > button:nth-child(2)');
await page.click('.css-1234567');

// ✅ Good - Stable selectors
await page.click('[data-testid="submit-button"]');
await page.click('button[aria-label="Submit form"]');
await page.click('button:has-text("Submit")');
```

### 2. Auto-Waiting
```typescript
// ❌ Bad - Manual waits
await page.waitForTimeout(5000);
await page.click('button');

// ✅ Good - Let Playwright auto-wait
await page.click('button'); // Automatically waits for button to be actionable
```

### 3. Assertions
```typescript
// ✅ Use specific assertions
await expect(page.locator('.message')).toBeVisible();
await expect(page.locator('.message')).toContainText('Success');
await expect(page).toHaveURL(/.*dashboard/);
await expect(page).toHaveTitle('Dashboard');
```

### 4. Test Isolation
```typescript
// Each test should be independent
test.beforeEach(async ({ page }) => {
  // Reset state
  await page.goto('/');
  // Clear cookies/storage if needed
  await page.context().clearCookies();
});
```

## Using Playwright MCP with Claude

When Playwright MCP is installed, you can ask Claude to:

1. **Generate tests from descriptions:**
   - "Create a test that verifies login with valid credentials"
   - "Write tests for the checkout flow"

2. **Debug failing tests:**
   - "This test is failing: [paste test code]. Help me debug and fix it."

3. **Convert manual test cases:**
   - "Convert these manual test steps into Playwright tests"

4. **Improve existing tests:**
   - "Review this test and suggest improvements"

## Common Issues and Solutions

### Flaky Tests
```typescript
// Issue: Test sometimes passes, sometimes fails

// ❌ Bad
await page.click('button');
const text = await page.textContent('.result'); // May not be ready

// ✅ Good - Wait for element
await page.click('button');
await expect(page.locator('.result')).toContainText('Expected');
```

### Timeout Issues
```typescript
// Increase timeout for specific actions
await page.click('button', { timeout: 30000 });

// Or in config
test.setTimeout(60000);
```

### Element Not Found
```typescript
// Wait for element to be available
await page.waitForSelector('.my-element', { state: 'visible' });

// Or use getBy methods with auto-wait
await page.getByRole('button', { name: 'Submit' }).click();
```

## Testing Checklist

- [ ] Tests are isolated and independent
- [ ] Using stable, semantic selectors
- [ ] Page Object Model implemented
- [ ] API tests cover main endpoints
- [ ] Visual regression tests for critical UI
- [ ] Accessibility tests included
- [ ] Mobile viewport tests
- [ ] Cross-browser tests configured
- [ ] CI/CD pipeline integrated
- [ ] Test data fixtures organized
- [ ] Error scenarios covered
- [ ] Performance metrics validated
- [ ] Screenshots/videos on failure
- [ ] Tests run in parallel

## Useful Commands

```bash
# Run all tests
npx playwright test

# Run specific test file
npx playwright test login.spec.ts

# Run tests in headed mode
npx playwright test --headed

# Run tests in specific browser
npx playwright test --project=chromium

# Run in debug mode
npx playwright test --debug

# Generate code (record actions)
npx playwright codegen https://example.com

# Show test report
npx playwright show-report

# View trace
npx playwright show-trace trace.zip

# Update snapshots
npx playwright test --update-snapshots
```

## Notes for Claude

When helping users with Playwright testing:

1. **Prefer Page Object Model** for maintainability
2. **Use auto-waiting** instead of manual waits
3. **Write atomic tests** that are independent
4. **Use semantic selectors** (data-testid, role, text)
5. **Include proper error handling** and debugging info
6. **Suggest visual regression tests** for UI components
7. **Recommend CI/CD integration** for automated testing
8. **Check for accessibility** in test suggestions
9. **Consider mobile viewports** when relevant
10. **Use MCP features** when available for enhanced capabilities
