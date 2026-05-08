---
name: test-file
description: Use this skill every user want to create test file.
---

# Test File

# General Rules
1) Do NOT generate / create any helper file, fixture file, and other, Always Remember that test file will execute on runner, So each test file must be independent; do not call helpers from other files (helpers must be inlined in the file).
2) Do NOT use `waitForTimeout` alone when a request is triggered, MUST use `page.waitForLoadState('networkidle');` followed by `page.waitForTimeout(500)`.
3) Add `page.waitForTimeout(500)` after every click action to prevent race conditions.
4) Follow this test file template:
```
// Components :
// - You must add all "Component Path" from plan markdown

import { test, expect, type Page } from '@playwright/test';

const BASE_URL = process.env.BASE_URL || 'http://localhost:5173';
const AUTH_EMAIL = process.env.AUTH_EMAIL || 'tantowi@gmail.com';
const AUTH_PASSWORD = process.env.AUTH_PASSWORD || 'Bismillah1407*';

// @INFO Create function mockData() to generate dynamic mock for test data. Dont add any test data into environment.
function mockData() {
    // @TODO generate mock test data here
    const name = "wahyu" + Date.now();
    return {
        name: name
    }
}

async function login(page: Page) {
  await page.goto(`${BASE_URL}/auth/login`);
  await page.waitForLoadState('networkidle');

  // @TODO(verified): Change with real selector from playwright-e2e probe
  await page.locator('input[name="email"]').fill(AUTH_EMAIL);
  await page.locator('input[name="password"]').fill(AUTH_PASSWORD);
  await page.locator('button[type="submit"]').click();

  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);
}

test.describe('SCN-1: User Management - View Users List', () => {
  test('SCN-1: User Management - View Users List end-to-end', async ({ page }) => {
    await login(page);

    await test.step('should display users list with correct elements', async () => {
        // @TODO Do any step and assertion
    });

    // @TODO fill with next step
  })
})
```

# Selector Rules
1) Do NOT make assumptions about selectors, You must read codebase that relate with context / scenario
2) Do NOT use `getByLabel`.
3) Do NOT use `getByText`.
4) Use semantic HTML elements such as `button`, `input`, `textarea`, `select`, `table`, `td`, `tr`, `th` and etc.
5) Preferred selectors are `data-testid` and `getByRole`.
6) All selectors must come from your snapshot.
7) Must re make sure selectors is exist using tool `evaluate` for assertion `*.toBeVisible()`
