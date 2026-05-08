---
name: create-e2e-test
description: Create Playwright E2E tests for user flows. Use when testing complete user journeys, protected routes, form submissions, or cross-page navigation.
---

# Create E2E Test

Creates Playwright end-to-end tests following Iridium testing patterns.

## When to Use

- Testing complete user flows (sign-in → action → sign-out)
- Testing protected routes and middleware
- Verifying form submissions and validation
- User asks to "add E2E test", "test user flow", or "integration test"

## Test Location & Naming

```
tests/
├── authentication.spec.ts    # Auth flow tests
├── dashboard.spec.ts         # Dashboard feature tests
├── profile.spec.ts           # Profile management tests
└── home.spec.ts              # Public page tests
```

**Naming:** `*.spec.ts` for all Playwright tests

## Basic Test Structure

```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature Name', () => {
    test('should do something', async ({ page }) => {
        await page.goto('/');

        await expect(
            page.getByRole('heading', { name: 'Title' }),
        ).toBeVisible();
    });
});
```

## Pattern 1: Testing Public Pages

```typescript
import { test, expect } from '@playwright/test';

test.describe('Landing Page', () => {
    test('displays hero content', async ({ page }) => {
        await page.goto('/');

        await expect(
            page.getByRole('heading', { name: /welcome/i }),
        ).toBeVisible();
        await expect(page.getByText(/get started/i)).toBeVisible();
    });

    test('has correct meta tags', async ({ page }) => {
        await page.goto('/');

        await expect(page).toHaveTitle('Iridium');

        const metaDescription = page.locator('meta[name="description"]');
        await expect(metaDescription).toHaveAttribute(
            'content',
            /production-ready/i,
        );
    });

    test('navigates to sign-in page', async ({ page }) => {
        await page.goto('/');

        await page.getByRole('link', { name: /sign in/i }).click();

        await expect(page).toHaveURL(/sign-in/);
    });
});
```

## Pattern 2: Testing Protected Routes

```typescript
import { test, expect } from '@playwright/test';

test.describe('Protected Routes', () => {
    test('redirects unauthenticated users to sign-in', async ({ page }) => {
        await page.goto('/dashboard');

        // Middleware should redirect to sign-in
        await expect(page).toHaveURL(/sign-in/);
    });

    test('displays dashboard for authenticated users', async ({ page }) => {
        // Login first (see authentication pattern below)
        await page.goto('/sign-in');
        await page.getByLabel(/email/i).fill('admin@iridium.com');
        await page.getByLabel(/password/i).fill('Admin123!');
        await page.getByRole('button', { name: /sign in/i }).click();

        // Wait for redirect to dashboard
        await expect(page).toHaveURL(/dashboard/);
        await expect(page.getByText(/welcome/i)).toBeVisible();
    });
});
```

## Pattern 3: Testing Form Interactions

```typescript
import { test, expect } from '@playwright/test';

test.describe('Sign In Form', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('/sign-in');
    });

    test('shows validation errors for empty submission', async ({ page }) => {
        await page.getByRole('button', { name: /sign in/i }).click();

        await expect(page.getByText(/email is required/i)).toBeVisible();
        await expect(page.getByText(/password is required/i)).toBeVisible();
    });

    test('shows error for invalid credentials', async ({ page }) => {
        await page.getByLabel(/email/i).fill('wrong@example.com');
        await page.getByLabel(/password/i).fill('wrongpassword');
        await page.getByRole('button', { name: /sign in/i }).click();

        await expect(page.getByText(/invalid/i)).toBeVisible();
    });

    test('signs in successfully with valid credentials', async ({ page }) => {
        await page.getByLabel(/email/i).fill('admin@iridium.com');
        await page.getByLabel(/password/i).fill('Admin123!');
        await page.getByRole('button', { name: /sign in/i }).click();

        await expect(page).toHaveURL(/dashboard/);
    });
});
```

## Pattern 4: Testing API Calls via UI

```typescript
import { test, expect } from '@playwright/test';

test.describe('Profile Update', () => {
    test('saves profile changes successfully', async ({ page }) => {
        // Login first
        await page.goto('/sign-in');
        await page.getByLabel(/email/i).fill('admin@iridium.com');
        await page.getByLabel(/password/i).fill('Admin123!');
        await page.getByRole('button', { name: /sign in/i }).click();
        await expect(page).toHaveURL(/dashboard/);

        // Navigate to profile
        await page.goto('/portal');

        // Listen for API response
        const responsePromise = page.waitForResponse(
            (response) =>
                response.url().includes('/api/profile') &&
                response.status() === 200,
        );

        // Fill form and submit
        await page.getByLabel(/name/i).fill('New Name');
        await page.getByRole('button', { name: /save/i }).click();

        // Verify API was called
        await responsePromise;

        // Verify success message
        await expect(page.getByText(/updated/i)).toBeVisible();
    });
});
```

## Pattern 5: Testing Role-Based Access

```typescript
import { test, expect } from '@playwright/test';

test.describe('Role-Based Access', () => {
    test('admin can access admin routes', async ({ page }) => {
        // Login as admin
        await page.goto('/sign-in');
        await page.getByLabel(/email/i).fill('admin@iridium.com');
        await page.getByLabel(/password/i).fill('Admin123!');
        await page.getByRole('button', { name: /sign in/i }).click();

        await page.goto('/admin');
        await expect(page.getByText(/admin panel/i)).toBeVisible();
    });

    test('regular user cannot access admin routes', async ({ page }) => {
        // Login as regular user
        await page.goto('/sign-in');
        await page.getByLabel(/email/i).fill('user@iridium.com');
        await page.getByLabel(/password/i).fill('User123!');
        await page.getByRole('button', { name: /sign in/i }).click();

        await page.goto('/admin');

        // Should show forbidden or redirect
        await expect(page.getByText(/forbidden|not authorized/i)).toBeVisible();
    });
});
```

## Selectors - Best Practices

**DO use semantic selectors:**
```typescript
page.getByRole('button', { name: /submit/i })
page.getByRole('heading', { name: /welcome/i })
page.getByLabel(/email/i)
page.getByText(/success/i)
page.getByRole('link', { name: /sign in/i })
```

**DON'T use CSS selectors:**
```typescript
// ❌ Avoid these
page.locator('.btn-primary')
page.locator('#submit-button')
page.locator('div.form-field input')
```

## Running E2E Tests

```bash
npm run e2e           # Headless mode (CI)
npm run e2e:ui        # Visual UI mode (recommended for dev)
npm run e2e:headed    # See browser during tests
npm run e2e:debug     # Step-by-step debugging
npm run e2e:report    # View HTML report
```

## Test Credentials

From `prisma/seed.ts`:

| Email | Password | Role |
|-------|----------|------|
| `admin@iridium.com` | `Admin123!` | ADMIN |
| `editor@iridium.com` | `Editor123!` | EDITOR |
| `user@iridium.com` | `User123!` | USER |

## Configuration

Tests are configured in `playwright.config.ts`:
- **Base URL:** `http://localhost:5173`
- **Browsers:** Chromium, Firefox, WebKit
- **Auto-start:** Playwright starts dev server automatically

## Common Assertions

```typescript
// URL assertions
await expect(page).toHaveURL(/dashboard/);
await expect(page).toHaveURL('http://localhost:5173/profile');

// Title assertion
await expect(page).toHaveTitle('Dashboard - Iridium');

// Element visibility
await expect(page.getByText('Hello')).toBeVisible();
await expect(page.getByRole('button')).toBeDisabled();

// Count assertions
await expect(page.getByRole('listitem')).toHaveCount(5);

// Attribute assertions
await expect(page.locator('input')).toHaveValue('test@example.com');
```

## CI/CD Integration

E2E tests run in GitHub Actions. Key points:
- Uses SQLite in-memory for Prisma client generation
- Playwright auto-starts dev server
- HTML reports uploaded as artifacts

## Anti-Patterns

- Using CSS class selectors instead of semantic selectors
- Hardcoding wait times (`page.waitForTimeout(1000)`)
- Testing implementation details
- Not waiting for elements before interacting
- Missing authentication setup for protected routes

## Full Reference

See `.github/instructions/playwright.instructions.md` for comprehensive documentation.
