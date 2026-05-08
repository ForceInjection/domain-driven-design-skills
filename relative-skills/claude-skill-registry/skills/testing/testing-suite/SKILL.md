---
name: testing-suite
description: Setup and configure testing infrastructure with Vitest, Playwright, and testing patterns. Use when users need to add tests, configure test runners, implement TDD workflows, or create E2E test suites. Covers unit, integration, and end-to-end testing strategies.
---

# Testing Suite

Complete testing infrastructure for modern TypeScript/JavaScript applications.

## Decision Tree

```
User request → What type of testing?
    │
    ├─ Unit Tests
    │   ├─ Runner?
    │   │   ├─ Vitest → Fast, Vite-native, ESM
    │   │   ├─ Jest → Mature, wide ecosystem
    │   │   └─ Bun test → Ultra-fast, built-in
    │   │
    │   └─ What to test?
    │       ├─ Functions → Pure logic, utilities
    │       ├─ Components → React Testing Library
    │       ├─ Hooks → @testing-library/react-hooks
    │       └─ API handlers → MSW for mocking
    │
    ├─ Integration Tests
    │   ├─ Database → Test containers, in-memory
    │   ├─ API → Supertest, actual endpoints
    │   └─ Services → Real dependencies
    │
    ├─ E2E Tests
    │   ├─ Playwright → Cross-browser, fast
    │   ├─ Cypress → Great DX, dashboard
    │   └─ What to test?
    │       ├─ User flows → Critical paths
    │       ├─ Visual regression → Screenshots
    │       └─ Accessibility → axe-core
    │
    └─ Test Strategy
        ├─ TDD → Red-green-refactor
        ├─ Coverage → Istanbul/c8
        └─ CI → GitHub Actions integration
```

## Quick Start

### Vitest Setup

```bash
# Install
pnpm add -D vitest @vitest/coverage-v8 @vitest/ui

# With React
pnpm add -D @testing-library/react @testing-library/jest-dom jsdom
```

```typescript
// vitest.config.ts
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: ["./src/test/setup.ts"],
    include: ["src/**/*.{test,spec}.{ts,tsx}"],
    coverage: {
      provider: "v8",
      reporter: ["text", "json", "html"],
      exclude: ["node_modules/", "src/test/"],
    },
  },
});
```

### Playwright Setup

```bash
# Install
pnpm add -D @playwright/test
npx playwright install
```

```typescript
// playwright.config.ts
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: "html",
  use: {
    baseURL: "http://localhost:3000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    { name: "firefox", use: { ...devices["Desktop Firefox"] } },
    { name: "webkit", use: { ...devices["Desktop Safari"] } },
  ],
  webServer: {
    command: "pnpm dev",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
  },
});
```

## Test Patterns

### Unit Test Example

```typescript
// utils/format.test.ts
import { describe, it, expect } from "vitest";
import { formatCurrency, formatDate } from "./format";

describe("formatCurrency", () => {
  it("formats USD correctly", () => {
    expect(formatCurrency(1234.56, "USD")).toBe("$1,234.56");
  });

  it("handles zero", () => {
    expect(formatCurrency(0, "USD")).toBe("$0.00");
  });

  it("handles negative values", () => {
    expect(formatCurrency(-50, "USD")).toBe("-$50.00");
  });
});
```

### Component Test Example

```typescript
// components/Button.test.tsx
import { render, screen, fireEvent } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";
import { Button } from "./Button";

describe("Button", () => {
  it("renders with text", () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole("button")).toHaveTextContent("Click me");
  });

  it("calls onClick when clicked", () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click</Button>);

    fireEvent.click(screen.getByRole("button"));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it("is disabled when loading", () => {
    render(<Button loading>Submit</Button>);
    expect(screen.getByRole("button")).toBeDisabled();
  });
});
```

### E2E Test Example

```typescript
// e2e/auth.spec.ts
import { test, expect } from "@playwright/test";

test.describe("Authentication", () => {
  test("user can login", async ({ page }) => {
    await page.goto("/login");

    await page.fill('[name="email"]', "user@example.com");
    await page.fill('[name="password"]', "password123");
    await page.click('button[type="submit"]');

    await expect(page).toHaveURL("/dashboard");
    await expect(page.locator("h1")).toContainText("Welcome");
  });

  test("shows error for invalid credentials", async ({ page }) => {
    await page.goto("/login");

    await page.fill('[name="email"]', "wrong@example.com");
    await page.fill('[name="password"]', "wrongpass");
    await page.click('button[type="submit"]');

    await expect(page.locator('[role="alert"]')).toContainText("Invalid");
  });
});
```

## Testing Strategy Guide

| Test Type | Coverage | Speed | Confidence |
|-----------|----------|-------|------------|
| Unit | High (70-80%) | Fast | Low-Medium |
| Integration | Medium (15-20%) | Medium | Medium-High |
| E2E | Low (5-10%) | Slow | High |

## Reference Files

- **Vitest Config**: See [references/vitest-config.md](references/vitest-config.md)
- **Playwright Patterns**: See [references/playwright-patterns.md](references/playwright-patterns.md)
- **Testing Best Practices**: See [references/testing-best-practices.md](references/testing-best-practices.md)
- **Mocking Strategies**: See [references/mocking.md](references/mocking.md)

## Best Practices

1. **Test behavior, not implementation**: Focus on what, not how
2. **Arrange-Act-Assert**: Clear test structure
3. **One assertion per test**: When possible
4. **Descriptive names**: `should return empty array when no items`
5. **Avoid test interdependence**: Each test should be isolated
6. **Mock external dependencies**: APIs, databases, time
7. **Use factories**: For test data generation
8. **Run tests in CI**: Every PR, every push
