---
name: write-playwright-test
description: Write Playwright E2E tests using fixtures and best practices. Use when creating E2E tests, writing browser automation tests, or testing user flows.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Write Playwright Tests

Write end-to-end tests using Playwright fixtures, Page Object Model, and accessibility-first queries.

## Core Principles

Follow Kent C. Dodds' testing philosophy:

> "The more your tests resemble the way your software is used, the more confidence they can give you."

### Test User Behavior, Not Implementation

- Test what users see and do
- Avoid testing internal state or methods
- Focus on outcomes, not mechanisms

## Query Priority (Accessibility-First)

Use queries in this order of preference:

### 1. Role Queries (Best)

```typescript
// Buttons, links, headings
await page.getByRole('button', { name: /submit/i })
await page.getByRole('link', { name: /home/i })
await page.getByRole('heading', { level: 1 })

// Form elements
await page.getByRole('textbox', { name: /email/i })
await page.getByRole('checkbox', { name: /remember me/i })
await page.getByRole('combobox', { name: /country/i })

// With state
await page.getByRole('checkbox', { checked: true })
await page.getByRole('tab', { selected: true })
```

### 2. Label Queries (Forms)

```typescript
await page.getByLabel(/email address/i)
await page.getByLabel(/password/i)
await page.getByLabel(/phone number/i)
```

### 3. Text Queries (Content)

```typescript
await page.getByText(/welcome back/i)
await page.getByText('Exact Match')
```

### 4. Placeholder Queries (Fallback)

```typescript
await page.getByPlaceholder('Search...')
```

### 5. Test ID (Last Resort)

```typescript
// Only when no accessible alternative exists
await page.getByTestId('complex-widget')
```

## Fixtures

### Why Use Fixtures?

- **Encapsulation**: Setup and teardown in one place
- **Reusability**: Share across all tests
- **Isolation**: Fresh state per test
- **Auto-cleanup**: Teardown runs automatically

### Basic Custom Fixture

```typescript
// tests/e2e/fixtures/test-fixtures.ts
import { test as base } from '@playwright/test'

type MyFixtures = {
  testUser: { email: string; password: string }
}

export const test = base.extend<MyFixtures>({
  testUser: async ({}, use) => {
    // Setup: Create test data
    const user = {
      email: `test-${Date.now()}@example.com`,
      password: 'TestPassword123!',
    }

    // Provide to test
    await use(user)

    // Teardown: Cleanup (runs after test)
    // await deleteUser(user.email)
  },
})

export { expect } from '@playwright/test'
```

### Authentication Fixture

```typescript
// tests/e2e/fixtures/auth-fixtures.ts
import { test as base, type Page } from '@playwright/test'

type AuthFixtures = {
  authenticatedPage: Page
}

export const test = base.extend<AuthFixtures>({
  authenticatedPage: async ({ page }, use) => {
    // Login before test
    await page.goto('/login')
    await page.getByLabel(/email/i).fill('user@example.com')
    await page.getByLabel(/password/i).fill('password123')
    await page.getByRole('button', { name: /sign in/i }).click()
    await page.waitForURL('/dashboard')

    // Provide authenticated page
    await use(page)

    // Logout after test (optional)
    // await page.goto('/logout')
  },
})
```

### Database Fixture with Cleanup

```typescript
// tests/e2e/fixtures/db-fixtures.ts
import { test as base } from '@playwright/test'

type DbFixtures = {
  insertTestData: (data: TestData) => Promise<string>
}

export const test = base.extend<DbFixtures>({
  insertTestData: async ({ request }, use) => {
    const createdIds: string[] = []

    // Provide factory function
    await use(async (data) => {
      const response = await request.post('/api/test-data', { data })
      const { id } = await response.json()
      createdIds.push(id)
      return id
    })

    // Cleanup all created data
    for (const id of createdIds) {
      await request.delete(`/api/test-data/${id}`)
    }
  },
})
```

### Worker-Scoped Fixture (Shared Across Tests)

```typescript
// tests/e2e/fixtures/worker-fixtures.ts
import { test as base } from '@playwright/test'

type WorkerFixtures = {
  sharedAccount: { username: string; token: string }
}

export const test = base.extend<{}, WorkerFixtures>({
  sharedAccount: [
    async ({ browser }, use, workerInfo) => {
      // Create unique account per worker
      const username = `worker-${workerInfo.workerIndex}`

      // Setup runs once per worker
      const page = await browser.newPage()
      await page.goto('/signup')
      // ... create account ...
      await page.close()

      await use({ username, token: 'token' })

      // Teardown when worker shuts down
      // await deleteAccount(username)
    },
    { scope: 'worker' },
  ],
})
```

### Combining Multiple Fixtures

```typescript
// tests/e2e/fixtures/index.ts
import { mergeTests } from '@playwright/test'
import { test as authTest } from './auth-fixtures'
import { test as dbTest } from './db-fixtures'
import { test as pageTest } from './page-fixtures'

export const test = mergeTests(authTest, dbTest, pageTest)
export { expect } from '@playwright/test'
```

## Page Object Model

### Page Object Structure

```typescript
// tests/e2e/pages/checkout.page.ts
import { type Page, type Locator, expect } from '@playwright/test'

export class CheckoutPage {
  readonly page: Page

  // Locators
  readonly cartItems: Locator
  readonly subtotal: Locator
  readonly checkoutButton: Locator
  readonly promoCodeInput: Locator
  readonly applyPromoButton: Locator
  readonly errorMessage: Locator

  constructor(page: Page) {
    this.page = page
    this.cartItems = page.getByRole('list', { name: /cart items/i })
    this.subtotal = page.getByTestId('subtotal')
    this.checkoutButton = page.getByRole('button', { name: /checkout/i })
    this.promoCodeInput = page.getByLabel(/promo code/i)
    this.applyPromoButton = page.getByRole('button', { name: /apply/i })
    this.errorMessage = page.getByRole('alert')
  }

  async goto() {
    await this.page.goto('/checkout')
  }

  async applyPromoCode(code: string) {
    await this.promoCodeInput.fill(code)
    await this.applyPromoButton.click()
  }

  async proceedToCheckout() {
    await this.checkoutButton.click()
  }

  async expectItemCount(count: number) {
    await expect(this.cartItems.getByRole('listitem')).toHaveCount(count)
  }

  async expectSubtotal(amount: string) {
    await expect(this.subtotal).toHaveText(amount)
  }
}
```

### Using Page Objects with Fixtures

```typescript
// tests/e2e/fixtures/page-fixtures.ts
import { test as base } from '@playwright/test'
import { CheckoutPage } from '../pages/checkout.page'
import { LoginPage } from '../pages/login.page'

type PageFixtures = {
  checkoutPage: CheckoutPage
  loginPage: LoginPage
}

export const test = base.extend<PageFixtures>({
  checkoutPage: async ({ page }, use) => {
    await use(new CheckoutPage(page))
  },

  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page))
  },
})
```

## Writing Tests

### Basic Test Structure

```typescript
// tests/e2e/checkout.spec.ts
import { test, expect } from './fixtures'

test.describe('Checkout Flow', () => {
  test('user can complete purchase', async ({ page, checkoutPage }) => {
    // Given: User has items in cart
    await checkoutPage.goto()
    await checkoutPage.expectItemCount(2)

    // When: User proceeds to checkout
    await checkoutPage.proceedToCheckout()

    // Then: User sees payment form
    await expect(page).toHaveURL('/payment')
    await expect(
      page.getByRole('heading', { name: /payment/i })
    ).toBeVisible()
  })

  test('user can apply valid promo code', async ({ checkoutPage }) => {
    await checkoutPage.goto()

    await checkoutPage.applyPromoCode('SAVE20')

    await expect(
      checkoutPage.page.getByText(/20% discount applied/i)
    ).toBeVisible()
  })

  test('user sees error for invalid promo code', async ({ checkoutPage }) => {
    await checkoutPage.goto()

    await checkoutPage.applyPromoCode('INVALID')

    await expect(checkoutPage.errorMessage).toHaveText(/invalid promo code/i)
  })
})
```

### Test with Authentication Fixture

```typescript
import { test, expect } from './fixtures'

test.describe('Dashboard', () => {
  test('authenticated user sees dashboard', async ({ authenticatedPage }) => {
    await authenticatedPage.goto('/dashboard')

    await expect(
      authenticatedPage.getByRole('heading', { name: /dashboard/i })
    ).toBeVisible()
    await expect(
      authenticatedPage.getByText(/welcome back/i)
    ).toBeVisible()
  })
})
```

### Test with Data Fixture

```typescript
import { test, expect } from './fixtures'

test.describe('Products', () => {
  test('user can view product details', async ({ page, insertTestData }) => {
    // Create test product (auto-cleaned up after test)
    const productId = await insertTestData({
      name: 'Test Product',
      price: 99.99,
    })

    await page.goto(`/products/${productId}`)

    await expect(page.getByRole('heading')).toHaveText('Test Product')
    await expect(page.getByText('$99.99')).toBeVisible()
  })
})
```

## Web-First Assertions

Always use web-first assertions that auto-wait:

```typescript
// GOOD - Auto-waits and retries
await expect(page.getByText('Success')).toBeVisible()
await expect(page.getByRole('button')).toBeEnabled()
await expect(page).toHaveURL('/dashboard')
await expect(page).toHaveTitle(/Dashboard/)

// BAD - Manual check, no retry
const isVisible = await page.getByText('Success').isVisible()
expect(isVisible).toBe(true)
```

### Common Assertions

```typescript
// Visibility
await expect(locator).toBeVisible()
await expect(locator).toBeHidden()

// Text content
await expect(locator).toHaveText('exact text')
await expect(locator).toContainText('partial')

// Attributes
await expect(locator).toHaveAttribute('href', '/path')
await expect(locator).toHaveClass(/active/)

// Form state
await expect(locator).toBeEnabled()
await expect(locator).toBeDisabled()
await expect(locator).toBeChecked()
await expect(locator).toHaveValue('input value')

// Count
await expect(locator).toHaveCount(5)

// Page
await expect(page).toHaveURL('/path')
await expect(page).toHaveTitle('Page Title')
```

## Soft Assertions

Continue test even if assertion fails:

```typescript
test('multiple checks', async ({ page }) => {
  await page.goto('/dashboard')

  // Soft assertions don't stop the test
  await expect.soft(page.getByTestId('status')).toHaveText('Active')
  await expect.soft(page.getByTestId('count')).toHaveText('10')

  // Test continues even if above fail
  await page.getByRole('link', { name: /settings/i }).click()
})
```

## Common Patterns

### Wait for Network

```typescript
// Wait for specific API response
await page.goto('/dashboard')
await page.waitForResponse((response) =>
  response.url().includes('/api/data') && response.status() === 200
)
```

### File Upload

```typescript
const fileInput = page.getByLabel(/upload file/i)
await fileInput.setInputFiles('./test-data/file.pdf')
```

### Handling Dialogs

```typescript
page.on('dialog', (dialog) => dialog.accept())
await page.getByRole('button', { name: /delete/i }).click()
```

### Screenshot on Specific Step

```typescript
await page.goto('/dashboard')
await page.screenshot({ path: 'dashboard.png' })
```

## What NOT to Do

- **DON'T** use `page.locator('.class-name')` - prefer role/label queries
- **DON'T** use `page.waitForTimeout(1000)` - use web-first assertions
- **DON'T** test implementation details - test user behavior
- **DON'T** repeat login flow in every test - use fixtures
- **DON'T** hardcode test data - generate unique data
- **DON'T** skip error scenarios - test unhappy paths

## Test Organization

```
tests/e2e/
├── fixtures/
│   ├── index.ts              # Combined fixtures export
│   ├── auth-fixtures.ts      # Authentication
│   ├── db-fixtures.ts        # Database operations
│   └── page-fixtures.ts      # Page objects
├── pages/
│   ├── login.page.ts
│   ├── dashboard.page.ts
│   └── checkout.page.ts
├── auth.setup.ts             # Auth setup project
├── auth.spec.ts              # Auth tests (one login flow)
├── dashboard.spec.ts
├── checkout.spec.ts
└── search.spec.ts
```

## Tips for Reliable Tests

1. **Use unique test data** - Avoid conflicts between parallel tests
2. **Clean up after tests** - Use fixture teardown
3. **Wait for stability** - Use web-first assertions
4. **Isolate tests** - Each test should work independently
5. **Test one thing** - Keep tests focused
6. **Use descriptive names** - `user can complete checkout` not `test1`
