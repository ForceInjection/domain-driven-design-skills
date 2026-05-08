---
name: standards-testing
description: Comprehensive testing patterns for modern TypeScript applications covering Vitest, React Testing Library, Playwright E2E, and MSW API mocking.
---

# Testing Standards

Standards for unit, integration, and E2E testing in modern TypeScript applications.

## When to Use

- Writing unit tests for functions/components
- Setting up integration tests
- Creating E2E test suites
- Mocking APIs and external services

## Resources

| Resource | Use When |
|----------|----------|
| [test-patterns.md](resources/test-patterns.md) | Unit/integration test patterns |
| [coverage-guidelines.md](resources/coverage-guidelines.md) | Coverage targets and strategies |

## Quick Reference

### Test Structure (AAA Pattern)

```typescript
test('should add item to cart', async () => {
  // Arrange
  const user = userEvent.setup();
  render(<Cart />);
  
  // Act
  await user.click(screen.getByRole('button', { name: /add to cart/i }));
  
  // Assert
  expect(screen.getByText(/1 item in cart/i)).toBeInTheDocument();
});
```

### Vitest Setup

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [tsconfigPaths(), react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
    coverage: {
      provider: 'v8',
      thresholds: { lines: 80, functions: 80, branches: 75 },
    },
  },
});
```

```typescript
// vitest.setup.ts
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { afterEach, afterAll, beforeAll, vi } from 'vitest';
import { server } from './mocks/server';

// MSW server lifecycle
beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => {
  server.resetHandlers();
  cleanup();
});
afterAll(() => server.close());

// Mock browser APIs
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation((query) => ({
    matches: false,
    media: query,
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
  })),
});
```

### RTL Query Priority

```typescript
// ✅ Accessible queries (preferred)
screen.getByRole('button', { name: /submit/i });
screen.getByLabelText(/email address/i);
screen.getByText(/welcome back/i);

// ⚠️ Semantic queries (acceptable)
screen.getByAltText(/company logo/i);

// ❌ Test IDs (last resort)
screen.getByTestId('submit-button');
```

### Custom Render with Providers

```typescript
// test-utils.tsx
import { render, RenderOptions } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const createTestQueryClient = () =>
  new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });

export function renderWithProviders(ui: ReactElement, options: RenderOptions = {}) {
  const queryClient = createTestQueryClient();
  
  function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    );
  }
  
  return {
    user: userEvent.setup(),
    queryClient,
    ...render(ui, { wrapper: Wrapper, ...options }),
  };
}
```

### MSW Handlers

```typescript
// mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: '1', name: 'Alice' },
      { id: '2', name: 'Bob' },
    ]);
  }),
  
  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: '3', ...body }, { status: 201 });
  }),
];

// mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

### Runtime Handler Override

```typescript
test('handles server error', async () => {
  server.use(
    http.get('/api/users', () => {
      return HttpResponse.json({ message: 'Error' }, { status: 500 });
    })
  );
  
  render(<UserList />);
  
  await waitFor(() => {
    expect(screen.getByText(/error loading/i)).toBeInTheDocument();
  });
});
```

### Playwright E2E

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### Page Object Model

```typescript
// e2e/pages/login.page.ts
import { Page, Locator, expect } from '@playwright/test';

export class LoginPage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;

  constructor(private page: Page) {
    this.emailInput = page.getByLabel(/email/i);
    this.passwordInput = page.getByLabel(/password/i);
    this.submitButton = page.getByRole('button', { name: /sign in/i });
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}
```

### Coverage Targets

| Metric | Minimum | Notes |
|--------|---------|-------|
| Lines | 80% | Overall code coverage |
| Functions | 80% | All functions tested |
| Branches | 75% | Conditional paths covered |

### NPM Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:watch": "vitest --watch",
    "test:coverage": "vitest run --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  }
}
```

## Amp Tools to Use

- `finder` - Find existing test patterns
- `Read` - Check test file conventions
- `oracle` - Guidance on complex test scenarios

## Related Skills

- `standards-global` - TypeScript conventions
- `standards-frontend` - Component patterns to test
- `standards-backend` - API patterns to test
