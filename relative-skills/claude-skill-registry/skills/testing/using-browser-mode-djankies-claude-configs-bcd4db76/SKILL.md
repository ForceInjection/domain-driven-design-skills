---
name: using-browser-mode
description: Set up Vitest browser mode with Playwright or WebDriverIO providers, use page and userEvent APIs, test components. Use when testing browser-specific code or UI components.
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# Using Browser Mode

This skill teaches Vitest browser mode setup, configuration, and testing patterns.

## Browser Mode Overview

Browser mode runs tests in actual browsers instead of Node.js environments, enabling:

- Real browser APIs (DOM, fetch, localStorage, etc.)
- Visual regression testing
- Component testing with real rendering
- User interaction testing

## Provider Packages

Vitest 4.x requires separate provider packages:

### Playwright Provider (Recommended)

```bash
npm install -D vitest @vitest/browser-playwright
```

**Use when:** Need Chromium, Firefox, and WebKit support with modern APIs

### WebDriverIO Provider

```bash
npm install -D vitest @vitest/browser-webdriverio
```

**Use when:** Need broader browser compatibility or existing WebDriverIO infrastructure

### Preview Provider

```bash
npm install -D vitest @vitest/browser-preview
```

**Use when:** Local development preview (not recommended for CI)

For detailed provider setup with all options, see [references/provider-setup.md](./references/provider-setup.md)

## Quick Setup

### Basic Playwright Configuration

```typescript
import { defineConfig } from 'vitest/config';
import { playwright } from '@vitest/browser-playwright';

export default defineConfig({
  test: {
    browser: {
      enabled: true,
      provider: playwright(),
      instances: [{ browser: 'chromium' }],
      headless: true,
    },
  },
});
```

### Multiple Browsers

```typescript
instances: [
  { browser: 'chromium' },
  { browser: 'firefox' },
  { browser: 'webkit' },
]
```

## Browser Test APIs

### Importing APIs

**Correct (Vitest 4.x):**
```typescript
import { page, userEvent } from 'vitest/browser';
```

**Incorrect (Vitest 3.x):**
```typescript
import { page, userEvent } from '@vitest/browser/context';
```

### Page Locators

```typescript
import { page } from 'vitest/browser';

const button = page.getByRole('button', { name: /submit/i });
const input = page.getByLabelText(/username/i);
const heading = page.getByRole('heading');
const text = page.getByText('Welcome');
```

### User Interactions

```typescript
import { userEvent } from 'vitest/browser';

await userEvent.fill(input, 'Bob');
await userEvent.click(checkbox);
await userEvent.selectOptions(select, 'value');
await userEvent.hover(element);
```

### Element Assertions

```typescript
import { expect } from 'vitest';

await expect.element(element).toBeInTheDocument();
await expect.element(element).toBeVisible();
await expect.element(element).toBeEnabled();
await expect.element(element).toHaveTextContent('text');
```

For complete browser API reference, see [references/browser-apis.md](./references/browser-apis.md)

## Component Testing

### React Components

```typescript
import { render } from 'vitest-browser-react';

test('submits form', async () => {
  const screen = render(<LoginForm />);

  await screen.getByLabelText(/email/i).fill('user@example.com');
  await screen.getByRole('button').click();
});
```

For testing React components in browser mode with Vitest, use the testing-components skill for patterns integrating with @testing-library/react and React 19 APIs.

### Vue Components

```typescript
import { render } from 'vitest-browser-vue';

test('component renders', async () => {
  const screen = render(Component, { props: { name: 'Alice' } });

  await expect.element(screen.getByText('Hi, my name is Alice')).toBeInTheDocument();
});
```

## Common Testing Patterns

### Form Testing

```typescript
test('form submission', async () => {
  await userEvent.fill(page.getByLabelText(/email/i), 'user@example.com');
  await userEvent.fill(page.getByLabelText(/password/i), 'password123');
  await userEvent.click(page.getByRole('button', { name: /submit/i }));

  await expect.element(page.getByText('Success')).toBeInTheDocument();
});
```

For browser-mode testing of Server Action forms, use the securing-server-actions skill for patterns on validation, authentication, and error handling in server actions.

### Navigation Testing

```typescript
test('navigation', async () => {
  await userEvent.click(page.getByRole('link', { name: /about/i }));

  await expect.element(page.getByRole('heading', { name: /about us/i })).toBeInTheDocument();
});
```

### Modal Testing

```typescript
test('modal dialog', async () => {
  await userEvent.click(page.getByRole('button', { name: /open/i }));

  const dialog = page.getByRole('dialog');
  await expect.element(dialog).toBeVisible();
});
```

For complete testing patterns including forms, navigation, modals, and more, see [references/testing-patterns.md](./references/testing-patterns.md)

## Visual Regression Testing

```typescript
test('visual regression', async () => {
  await page.goto('http://localhost:3000');

  const main = page.getByRole('main');
  await expect(main).toMatchScreenshot();
});
```

## Running Browser Tests

### CLI Commands

```bash
vitest --browser.enabled
vitest --browser.name chromium
vitest --browser.headless=false
```

### Run Specific Project

```bash
vitest --project browser
```

## Debugging

### Visual Debugging

```bash
vitest --browser.headless=false
```

### Enable Traces

```bash
vitest --browser.trace on
```

View traces in Playwright Trace Viewer.

## Configuration Options

### Headless Mode

```typescript
browser: {
  headless: process.env.CI ? true : false,
}
```

### Traces

```typescript
browser: {
  trace: 'retain-on-failure',
}
```

### Viewport

```typescript
instances: [
  {
    browser: 'chromium',
    context: {
      viewport: { width: 1280, height: 720 },
    },
  },
]
```

## Common Mistakes

1. **Using wrong import path**: Use `vitest/browser`, not `@vitest/browser/context`
2. **Missing provider package**: Install `@vitest/browser-playwright` or `@vitest/browser-webdriverio`
3. **Wrong browser instance config**: Use `instances: [{ browser: 'chromium' }]`, not `name: 'chromium'`
4. **Not awaiting interactions**: Always `await` user events
5. **Not using expect.element**: Use `expect.element()` for element assertions

## Migration from Vitest 3.x

**Old config:**
```typescript
browser: {
  enabled: true,
  name: 'chromium',
  provider: 'playwright',
}
```

**New config:**
```typescript
import { playwright } from '@vitest/browser-playwright';

browser: {
  enabled: true,
  provider: playwright(),
  instances: [{ browser: 'chromium' }],
}
```

**Old imports:**
```typescript
import { page } from '@vitest/browser/context';
```

**New imports:**
```typescript
import { page } from 'vitest/browser';
```

## References

For detailed browser mode documentation:
- [Provider Setup](./references/provider-setup.md) - Playwright, WebDriverIO, Preview setup
- [Browser APIs](./references/browser-apis.md) - Complete API reference with examples
- [Testing Patterns](./references/testing-patterns.md) - Common patterns for forms, modals, navigation

For configuration patterns, see `@vitest-4/skills/configuring-vitest-4`

For migration guide, see `@vitest-4/skills/migrating-to-vitest-4`

For complete API reference, see `@vitest-4/knowledge/vitest-4-comprehensive.md`
