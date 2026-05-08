---
name: create-e2e-test
description: Create Playwright E2E tests for user flows. Use when testing complete user journeys, protected routes, form submissions, or cross-page navigation.
---

# Create E2E Test

## When to Use

- Testing complete user flows
- Testing protected routes and middleware
- Verifying form submissions
- User asks to "add E2E test" or "test user flow"

## Test Location

```
tests/
├── authentication.spec.ts
├── dashboard.spec.ts
└── profile.spec.ts
```

## Basic Test

```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature Name', () => {
    test('should do something', async ({ page }) => {
        await page.goto('/');
        await expect(page.getByRole('heading', { name: 'Title' })).toBeVisible();
    });
});
```

## Authentication Flow

```typescript
test('signs in and accesses dashboard', async ({ page }) => {
    await page.goto('/sign-in');
    await page.getByLabel(/email/i).fill('admin@iridium.com');
    await page.getByLabel(/password/i).fill('Admin123!');
    await page.getByRole('button', { name: /sign in/i }).click();

    await expect(page).toHaveURL(/dashboard/);
});
```

## Form Testing

```typescript
test('shows validation errors', async ({ page }) => {
    await page.goto('/sign-in');
    await page.getByRole('button', { name: /sign in/i }).click();

    await expect(page.getByText(/email is required/i)).toBeVisible();
});
```

## Selectors - Use Semantic

```typescript
// GOOD
page.getByRole('button', { name: /submit/i })
page.getByLabel(/email/i)
page.getByText(/success/i)

// BAD
page.locator('.btn-primary')
page.locator('#submit-button')
```

## Test Credentials

| Email | Password | Role |
|-------|----------|------|
| `admin@iridium.com` | `Admin123!` | ADMIN |
| `editor@iridium.com` | `Editor123!` | EDITOR |
| `user@iridium.com` | `User123!` | USER |

## Running Tests

```bash
npm run e2e           # Headless
npm run e2e:ui        # Visual UI (recommended)
npm run e2e:headed    # Browser visible
npm run e2e:debug     # Debug mode
```

## Common Assertions

```typescript
await expect(page).toHaveURL(/dashboard/);
await expect(page).toHaveTitle('Page Title');
await expect(page.getByText('Hello')).toBeVisible();
await expect(page.getByRole('button')).toBeDisabled();
```

## Checklist

1. [ ] Create `*.spec.ts` in `tests/` directory
2. [ ] Use semantic selectors (role, label, text)
3. [ ] Set up authentication if testing protected routes
4. [ ] Avoid hardcoded waits (`waitForTimeout`)

## Full Reference

See `.github/instructions/playwright.instructions.md` for:
- API response testing
- Role-based access testing
- CI/CD integration
- Debugging strategies
