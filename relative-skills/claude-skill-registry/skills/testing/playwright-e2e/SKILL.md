---
name: playwright-e2e
description: Visual E2E testing workflow for frontend UI changes. Use after modifying Svelte components, layouts, or styles to verify the UI renders correctly.
allowed-tools: Bash, Read, Glob
---

# Playwright E2E Testing

Visual testing workflow for the Strieber chat UI frontend.

## When to Use

After making changes to:
- Svelte components (`frontend/src/**/*.svelte`)
- CSS/styles (`frontend/src/app.css`, Tailwind classes)
- Layout structure
- Any visible UI element

## Run Tests

```bash
docker compose run --rm playwright-test
```

This builds the production bundle and runs Playwright tests in headless Chromium.

## View Screenshots

After tests complete, read the screenshots:

```
frontend/test-results/screenshots/layout-desktop.png  # 1280x720 desktop view
frontend/test-results/screenshots/layout-mobile.png   # 375x667 mobile view
```

Use the Read tool on these PNG files to visually verify the UI.

## Verification Checklist

1. Layout renders correctly (sidebar, main area)
2. Colors/theme applied properly
3. Responsive behavior works (mobile hides sidebar)
4. No visual regressions from previous state
5. Text is readable and properly positioned

## Adding New Tests

Create tests in `frontend/e2e/<feature>.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';

test('my feature test', async ({ page }) => {
  await page.goto('/');

  // Take screenshot for visual verification
  await page.screenshot({
    path: 'test-results/screenshots/my-feature.png',
    fullPage: true
  });

  // Add assertions
  await expect(page.locator('.my-element')).toBeVisible();
});
```

## Test Locations

- Config: `frontend/playwright.config.ts`
- Tests: `frontend/e2e/*.spec.ts`
- Results: `frontend/test-results/` (gitignored)
