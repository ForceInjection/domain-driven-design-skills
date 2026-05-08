---
name: e2e-tests
description: Create and maintain Playwright E2E tests following project patterns. Use when adding new tests, debugging test failures, or understanding test structure.
---

# E2E Test Creation Skill

This skill helps you write and maintain Playwright end-to-end tests following the established patterns in this codebase.

## When to Use This Skill

Invoke this skill when:
- Creating a new e2e test file
- Adding tests to an existing test file
- Debugging flaky or failing tests
- User asks about e2e test patterns or best practices
- User wants to test a new feature end-to-end

## Framework Overview

| Property | Value |
|----------|-------|
| Framework | Playwright (`@playwright/test` v1.56.1) |
| Location | `/e2e/` directory |
| Config | `playwright.config.ts` |
| Run command | `npm run test:e2e` |
| Total tests | 80+ tests across 13 files |

## Two Authentication Modes

The project uses a two-tier authentication system:

### 1. Authenticated Tests (Default - Most Tests)

- Run with project `chromium-authenticated`
- Use cached auth state from `.auth/student.json`
- **No login needed** - tests start authenticated
- Excludes: `auth.spec.ts`, `registration.spec.ts`

### 2. Unauthenticated Tests

- Run with project `chromium-unauthenticated`
- For testing login/registration flows
- Files: `auth.spec.ts`, `registration.spec.ts`
- Must handle cookie banner dismissal

## File Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Test file | `{feature}.spec.ts` | `practice.spec.ts` |
| Setup file | `*.setup.ts` | `auth.setup.ts` |
| Helper file | `helpers/{name}.ts` | `helpers/auth.ts` |

---

## Creating a New Test File

### Step 1: Determine Authentication Mode

Ask: Does this test need to start from a logged-out state?
- **YES** → Use unauthenticated pattern, add to `testMatch` in config
- **NO** → Use authenticated pattern (default)

### Step 2: Create File Structure

```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature Name', () => {
  // Authentication handled via storageState in playwright.config.ts
  // No beforeEach login needed for authenticated tests

  test('should describe expected behavior', async ({ page }) => {
    await page.goto('/feature-path', { waitUntil: 'domcontentloaded' });

    // Test implementation
  });
});
```

### Step 3: Apply Selector Strategy

Priority order:
1. `data-testid` attributes (most reliable)
2. `getByRole` (semantic, accessible)
3. `getByText` (user-visible text)
4. CSS selectors (last resort)

→ See `selectors-guide.md` for detailed guidance.

### Step 4: Apply Wait Patterns

**NEVER** use `waitForTimeout` for synchronization.

Use event-based waits:
```typescript
// Wait for element visibility
await expect(element).toBeVisible({ timeout: 5000 });

// Wait for URL change
await page.waitForURL(/\/dashboard/, { timeout: 5000 });

// Wait for network
await page.waitForLoadState('networkidle');
```

→ See `anti-patterns.md` for common mistakes.

---

## Selector Strategy Quick Reference

```typescript
// PREFERRED: data-testid
await page.getByTestId('mode-zen').click();

// GOOD: Role-based
await page.getByRole('button', { name: /Siguiente/i }).click();
await page.getByRole('heading', { name: /Dashboard/i });

// ACCEPTABLE: Text-based
await page.getByText(/Práctica PAES/i).toBeVisible();

// LAST RESORT: CSS selectors
await page.locator('.specific-class').click();
```

→ See `selectors-guide.md` for comprehensive guidance.

---

## Test Configuration Quick Reference

```typescript
// Extend timeout for long tests
test('long flow', async ({ page }) => {
  test.setTimeout(60000); // 60 seconds
});

// Retry flaky tests
test('registration', { retries: 2 }, async ({ page }) => {});

// Scope auth to describe block
test.describe('Admin features', () => {
  test.use({ storageState: '.auth/admin.json' });
});

// Skip in CI
test.skip(process.env.CI === 'true', 'Local only');
```

→ See `advanced-patterns.md` for complete configuration options.

---

## Common Test Patterns

### Pattern 1: Navigation Test

```typescript
test('should navigate to feature page', async ({ page }) => {
  await page.goto('/feature', { waitUntil: 'domcontentloaded' });

  await expect(page.getByRole('heading', { name: /Feature Title/i })).toBeVisible();
  await expect(page.getByTestId('main-content')).toBeVisible();
});
```

### Pattern 2: Form Interaction

```typescript
test('should submit form successfully', async ({ page }) => {
  await page.goto('/form-page', { waitUntil: 'domcontentloaded' });

  await page.getByTestId('input-field').fill('value');
  await page.getByRole('button', { name: /Submit/i }).click();

  await expect(page.getByText(/Success/i)).toBeVisible();
});
```

### Pattern 3: API Interception

```typescript
test('should handle API errors gracefully', async ({ page }) => {
  await page.route('**/api/endpoint', route => {
    route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'Server error' }),
    });
  });

  await page.goto('/page');
  await expect(page.getByText(/error/i)).toBeVisible();
});
```

### Pattern 4: Cookie Banner Dismissal

```typescript
// For unauthenticated tests - add at start of test or beforeEach
await page.evaluate(() => {
  localStorage.setItem('cookie-consent', 'accepted');
});
```

→ See `templates.md` for 12 complete copy-paste templates.
→ See `advanced-patterns.md` for resilience, loops, and advanced waits.

---

## Quality Gates

Before completing any test file:

- [ ] Uses `data-testid` for critical elements
- [ ] No `waitForTimeout` for synchronization (only for animations)
- [ ] All waits are event-based
- [ ] Test names start with "should"
- [ ] Uses `test.describe()` for grouping
- [ ] Handles both success and error cases
- [ ] Cookie banner dismissed if needed (unauthenticated tests)
- [ ] No hardcoded credentials (use test users from db-setup)

---

## Running Tests

```bash
# Run all e2e tests
npm run test:e2e

# Run specific test file
npx playwright test e2e/practice.spec.ts

# Run with UI mode (interactive)
npx playwright test --ui

# Run with headed browser (visible)
npx playwright test --headed

# Debug a specific test
npx playwright test --debug -g "test name"

# Run tests matching pattern
npx playwright test -g "should login"
```

---

## Test Categories

Current test file organization:

| Category | Files | Purpose |
|----------|-------|---------|
| Auth | `auth.spec.ts`, `registration.spec.ts` | Login, registration flows |
| Practice | `practice.spec.ts`, `adaptive-practice.spec.ts` | Quiz modes (Zen, Rapid Fire) |
| Progress | `progress.spec.ts` | Analytics, history, skills |
| Profile | `profile.spec.ts` | User profile, stats |
| Curriculum | `curriculum.spec.ts` | M1/M2 curriculum pages |
| Lessons | `mini-lesson-*.spec.ts` | Interactive mini-lessons |
| Subscription | `subscription-trial.spec.ts` | Pricing, trials, paywalls |
| Live | `live-practice.spec.ts` | Real-time sessions |
| AI | `ai-tutor.spec.ts` | AI tutor functionality |
| Knowledge | `knowledge-declarations.spec.ts` | Skill declarations |

---

## Test Credentials

| Role | Email | Password |
|------|-------|----------|
| Student | `student@test.com` | `StudentTest123!` |
| Admin | `admin@test.com` | `AdminTest123!` |

→ See `helpers-reference.md` for complete helper documentation.

---

## Related Files

- → `advanced-patterns.md` - Test config, waits, assertions, resilience patterns
- → `anti-patterns.md` - Common mistakes to avoid
- → `templates.md` - 12 copy-paste test templates
- → `selectors-guide.md` - Selector strategy deep-dive
- → `helpers-reference.md` - Auth and DB helper documentation
