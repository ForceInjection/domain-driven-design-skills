---
name: e2e
description: |
  Playwright E2E testing patterns with chrome-devtools MCP integration.
  Reference for integration tests, A11y validation, and visual regression.
---

# E2E Testing Skill

## Playwright Setup

```bash
pnpm add -D @playwright/test
pnpm exec playwright install
```

## playwright.config.ts

```typescript
import { defineConfig } from "@playwright/test"

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  timeout: 30000,
  // グローバルタイムアウト設定（個別指定を排除）
  expect: {
    timeout: 10000,
  },
  use: {
    baseURL: "http://localhost:5173",
    trace: "on-first-retry",
    actionTimeout: 5000,
    navigationTimeout: 10000,
  },
  webServer: {
    command: "pnpm dev",
    url: "http://localhost:5173",
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
})
```

### Timeout Configuration Principle

**Avoid per-test timeout specifications:**

```typescript
// ❌ BAD: Scattered timeout values
await expect(item).toBeVisible({ timeout: 5000 })
await page.waitForSelector('[role="tree"]', { timeout: 10000 })

// ✅ GOOD: Use global configuration
await expect(item).toBeVisible()
await page.waitForSelector('[role="tree"]')
```

Use global settings to keep test code simple and maintainable.

## Test Patterns

### Basic Structure

```typescript
// e2e/example.spec.ts
import { test, expect } from "@playwright/test"

test.describe("Feature", () => {
  test("displays correct ARIA structure", async ({ page }) => {
    await page.goto("/")

    const tree = page.getByRole("tree")
    await expect(tree).toBeVisible()
    await expect(tree).toHaveAttribute("aria-label", "File explorer")
  })

  test("keyboard navigation works", async ({ page }) => {
    await page.goto("/")

    const firstItem = page.getByRole("treeitem").first()
    await firstItem.focus()

    // ArrowDown moves to next
    await page.keyboard.press("ArrowDown")
    await expect(page.getByRole("treeitem").nth(1)).toBeFocused()

    // ArrowRight expands
    await page.keyboard.press("ArrowRight")
    await expect(firstItem).toHaveAttribute("aria-expanded", "true")
  })
})
```

### A11y Testing with axe-core

```typescript
import AxeBuilder from "@axe-core/playwright"

test("meets accessibility standards", async ({ page }) => {
  await page.goto("/")

  const results = await new AxeBuilder({ page }).analyze()
  expect(results.violations).toEqual([])
})
```

### Form Interaction

```typescript
test("submits form correctly", async ({ page }) => {
  await page.goto("/form")

  await page.getByLabel("Name").fill("John Doe")
  await page.getByLabel("Email").fill("john@example.com")
  await page.getByRole("button", { name: "Submit" }).click()

  await expect(page.getByText("Success")).toBeVisible()
})
```

## chrome-devtools MCP Integration

When running E2E verification via Claude Code:

```
1. Start the application:
   pnpm dev

2. Navigate to page:
   mcp__chrome-devtools__navigate_page
   url: "http://localhost:5173"

3. Take accessibility snapshot:
   mcp__chrome-devtools__take_snapshot
   → Get A11y tree

4. Verify:
   - role="tree" exists
   - aria-expanded attributes
   - aria-selected attributes

5. Test keyboard navigation:
   mcp__chrome-devtools__press_key
   key: "ArrowDown"

6. Verify focus movement:
   mcp__chrome-devtools__take_snapshot
   → Confirm focus changed
```

## Visual Regression

```typescript
test("visual regression", async ({ page }) => {
  await page.goto("/")
  await expect(page).toHaveScreenshot("homepage.png")
})

test("component visual regression", async ({ page }) => {
  await page.goto("/components/button")
  const button = page.getByRole("button", { name: "Primary" })
  await expect(button).toHaveScreenshot("button-primary.png")
})
```

### Updating Snapshots

```bash
pnpm e2e --update-snapshots
```

## Page Object Pattern

```typescript
// e2e/pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto("/login")
  }

  async login(email: string, password: string) {
    await this.page.getByLabel("Email").fill(email)
    await this.page.getByLabel("Password").fill(password)
    await this.page.getByRole("button", { name: "Sign in" }).click()
  }

  async expectError(message: string) {
    await expect(this.page.getByRole("alert")).toContainText(message)
  }
}

// e2e/auth.spec.ts
test("shows error for invalid credentials", async ({ page }) => {
  const loginPage = new LoginPage(page)
  await loginPage.goto()
  await loginPage.login("invalid@example.com", "wrong")
  await loginPage.expectError("Invalid credentials")
})
```

## Fixtures

Centralize app initialization in fixtures to simplify test code:

```typescript
// e2e/fixtures.ts
import { test as base, expect } from "@playwright/test"

interface TestUtils {
  waitForApp: () => Promise<void>
  createFile: (name: string) => Promise<void>
  testId: string
}

export const test = base.extend<{ utils: TestUtils }>({
  utils: async ({ page }, use, testInfo) => {
    const testId = `${testInfo.workerIndex}-${Date.now()}`

    const utils: TestUtils = {
      testId,
      waitForApp: async () => {
        await page.waitForSelector('[role="tree"]')
      },
      createFile: async (name: string) => {
        // 共通のファイル作成ロジック
      },
    }

    // テスト前の初期化
    await page.goto("/")
    await utils.waitForApp()

    await use(utils)
  },
})

export { expect }
```

```typescript
// e2e/example.spec.ts
import { expect, test } from "./fixtures"

test("file creation", async ({ page, utils }) => {
  // App is automatically initialized when using utils
  await utils.createFile(`test-${utils.testId}.txt`)
  await expect(page.getByRole("button", { name: /test/ })).toBeVisible()
})

test("UI visibility check", async ({ page }) => {
  // Manual initialization when not using utils
  await page.goto("/")
  await page.waitForSelector('[role="tree"]')
  await expect(page.getByRole("tree")).toBeVisible()
})
```

## Commands

```bash
pnpm e2e            # Run E2E tests
pnpm e2e:headed     # Run with browser visible
pnpm e2e:debug      # Debug mode
pnpm e2e:ui         # Interactive UI mode
```

## When to Use E2E vs Other Test Types

### Test Pyramid Strategy

```
     ▲ E2E (Playwright)
    ╱ ╲   - Full user journeys
   ╱   ╲  - Cross-page flows
  ╱─────╲ - Critical paths only
 ╱       ╲
╱ Component╲  - Storybook play functions
╱  Tests    ╲ - Vitest Browser Mode
╱────────────╲- Isolated component behavior
╱              ╲
╱   Unit Tests   ╲ - Vitest
╱     (Base)      ╲- Pure functions, logic
╱──────────────────╲
```

### Decision Matrix

| Test Scope | Tool | When to Use |
|------------|------|-------------|
| **Unit** | Vitest | Pure functions, utilities, state logic |
| **Component** | Storybook + Vitest Browser | Single component behavior, props, states |
| **Integration** | Vitest Browser | Multiple components together |
| **E2E** | Playwright | Full user flows, multi-page, auth |

### E2E Test Selection Criteria (Testing Trophy)

**E2E for critical paths (happy paths) only:**
- Authentication/authorization flows
- Multi-page navigation
- Data persistence verification (OPFS, etc.)
- External API integrations

**Move to Vitest/Storybook:**
- Individual component variations
- Form validation rules
- Detailed keyboard navigation
- ARIA attribute verification
- UI state transitions

**Decision criteria:**
| Factor | E2E | Vitest/Storybook |
|--------|-----|------------------|
| Execution time | 2-5s/test | ~50ms/test |
| Maintenance | High | Low |
| Reliability | Medium (flaky) | High |
| Coverage | Wide | Narrow |

Minimize E2E tests; use Vitest + Storybook for detailed, fast testing.

### Cost-Benefit Analysis

| Factor | Unit | Component | E2E |
|--------|------|-----------|-----|
| Speed | ~1ms | ~50ms | ~2-5s |
| Reliability | High | High | Medium |
| Maintenance | Low | Low | High |
| Coverage | Narrow | Medium | Wide |
| Debug ease | Easy | Easy | Hard |

**Rule of thumb:** Maximize unit/component tests, minimize E2E to critical paths only.

## CI Integration

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2

      - name: Unit & Component Tests
        run: pnpm test

      - name: E2E Tests
        run: pnpm e2e
        env:
          CI: true
```

### Parallel E2E Execution

```typescript
// playwright.config.ts
export default defineConfig({
  workers: process.env.CI ? 2 : undefined,
  retries: process.env.CI ? 2 : 0,
  reporter: process.env.CI ? "github" : "list",
})
```

## References

- [Playwright Documentation](https://playwright.dev/docs/intro)
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
- [axe-core Playwright](https://github.com/dequelabs/axe-core-npm/tree/develop/packages/playwright)
- [Testing Trophy](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications)
