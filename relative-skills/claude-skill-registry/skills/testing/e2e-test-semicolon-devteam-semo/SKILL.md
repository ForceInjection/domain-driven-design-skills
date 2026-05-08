---
name: e2e-test
description: End-to-end testing with Playwright. Use when writing E2E tests, implementing page objects, setting up test fixtures, handling authentication in tests, adding visual regression testing, or configuring E2E tests for CI. Covers when to use E2E vs integration tests, critical path identification, page object pattern, test isolation, and CI considerations.
---

# E2E Testing with Playwright

E2E tests verify critical user journeys through the entire stack. Highest confidence, slowest to run, most expensive to maintain.

## When to Use E2E

**Use for:** Critical revenue flows, auth flows, multi-step journeys, paths that cannot break in production.

**Don't use for:** Business logic (unit), API validation (integration), edge cases (unit/integration), component behavior (component tests).

**Rule:** If integration tests catch it, don't write E2E. E2E is for happy paths and critical flows only.

## Critical Path Identification

**Tier 1 (Must):** Signup/signin, core product actions, revenue flows
**Tier 2 (Should):** Team features, secondary features, admin ops
**Tier 3 (Nice):** Settings, edge workflows, power user features

Start with Tier 1. One signup test > 20 preference tests.

## Page Object Pattern

Encapsulate page selectors and interactions for maintainability.

```typescript
export class LoginPage {
  constructor(private readonly page: Page) {}

  readonly emailInput = () => this.page.locator('input[type="email"]');
  readonly submitButton = () => this.page.locator('button[type="submit"]');

  async goto() { await this.page.goto('/sign-in'); }
  async login(email: string) {
    await this.emailInput().fill(email);
    await this.submitButton().click();
  }
  async assertLoggedIn() { await this.page.waitForURL('/workouts'); }
}
```

**Principles:**
- Selectors as methods (lazy, prevents stale elements)
- Actions return void
- Assertions in page objects only if reused
- One page object per logical page, not per route

## Test Fixtures & Setup

```typescript
// fixtures/auth.ts
export const TEST_USER = { email: 'e2e@test.com', password: 'Test123!' };

export async function loginAsTestUser(page: Page) {
  await page.goto('/sign-in');
  await page.getByLabel(/email/i).fill(TEST_USER.email);
  await page.getByRole('button', { name: /sign in/i }).click();
  await page.waitForURL(/\/(workouts|dashboard)/);
}
```

```typescript
// global-setup.ts - runs once before all tests
async function globalSetup() { await seedTestUsers(); }
```

**Key:** Pre-seed test users in global setup. Faster and more reliable than creating per-test.

## Test Isolation

**Strategy 1: Reset per test** (slowest) - `beforeEach(() => resetDB())`
**Strategy 2: Unique data** (recommended) - `const name = \`Test-${Date.now()}\``
**Strategy 3: Read-only** (fastest) - global seed, no mutations

Use Strategy 2. Move to 1 only if tests interfere.

## Authentication

**Strategy 1: Login each test** - Simple, slow (2-3s/test)
**Strategy 2: Session storage** - Save once, reuse. Caveat: expires mid-run
**Strategy 3: API auth** - Fastest, bypass UI

```typescript
// Strategy 2: global-setup.ts
await page.context().storageState({ path: '.auth/user.json' });

// Strategy 3: beforeEach
const session = await createSessionViaAPI(TEST_USER);
await page.context().addCookies([{ name: 'session', value: session.token }]);
```

**Use Strategy 3 for most tests. Use Strategy 1 only to test login flow itself.**

## Visual Regression

```typescript
test('page looks correct', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('baseline.png');
});
```

**Best practices:**
- Disable animations: `page.emulateMedia({ reducedMotion: 'reduce' })`
- Stabilize dynamic content (mock timestamps/randomness)
- Use sparingly (brittle, slow)
- Focus on critical UI only (login, checkout)

Don't screenshot every page. Do screenshot where design regressions are risky.

## CI Configuration

```typescript
// playwright.config.ts
export default defineConfig({
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? '50%' : undefined,
  reporter: process.env.CI ? [['blob'], ['github']] : [['html']],
});
```

**Flakiness mitigation:**
- Explicit waits: `await page.waitForSelector('.result')` before asserting
- Semantic selectors: `getByRole('button', { name: /submit/i })`
- Retry in CI: 2 retries catches transient issues

**Speed:**
- Parallelize (4+ workers in CI)
- API for setup (bypass UI)
- Shard across machines
- Run on critical branches only (main, release)

## Decision Tree

Single function → Unit | API endpoint → Integration | Multi-page flow → E2E | Business logic → Integration

## WODsmith Structure

```
e2e/
├── fixtures/auth.ts      # Login helpers
├── pages/login.ts        # Page objects
├── auth.spec.ts          # Test specs
├── global-setup.ts       # DB seeding
└── playwright.config.ts
```

Global setup seeds DB. Fixtures provide auth. Page objects encapsulate UI. Specs test journeys.

## Common Pitfalls

**Testing too much:** 10-step test fails at step 7 → unclear what broke. Split into focused tests.

**No cleanup:** Use unique data (`Test-${Date.now()}`) instead of cleanup. No conflicts, faster.

**Implicit waits:** Always `waitForSelector()` before assertions. Prevents race conditions.

## References

See WODsmith `e2e/` directory for real patterns: fixtures, page objects, global setup.
