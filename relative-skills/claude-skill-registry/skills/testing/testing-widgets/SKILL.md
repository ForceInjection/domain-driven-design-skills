---
name: testing-widgets
description: Testing StickerNest widgets and components. Use when the user asks to test widgets, write tests, add tests, create test cases, run tests, debug tests, or verify widget functionality. Covers Playwright E2E tests, Vitest unit tests, widget integration testing, and pipeline testing.
---

# Testing StickerNest Widgets

This skill covers testing patterns for StickerNest widgets and components using Playwright (E2E) and Vitest (unit tests).

## Test Stack Overview

| Tool | Purpose | Location |
|------|---------|----------|
| **Playwright** | E2E browser tests | `tests/*.spec.ts` |
| **Vitest** | Unit tests | `src/**/*.test.ts` |

## Running Tests

```bash
# E2E Tests (Playwright)
npm run test              # Run all E2E tests
npm run test:ui           # Interactive UI mode
npm run test:headed       # Tests with visible browser

# Unit Tests (Vitest)
npm run test:unit         # Run all unit tests
npm run test:unit:watch   # Watch mode
```

---

## Playwright E2E Tests

### Test File Structure

```typescript
// tests/my-widget.spec.ts
import { test, expect } from '@playwright/test';

test.describe('My Widget', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    // Wait for app to load
    await page.waitForSelector('[data-testid="canvas"]');
  });

  test('should load and display correctly', async ({ page }) => {
    // Test implementation
  });
});
```

### Common Test Patterns

#### Adding Widget to Canvas

```typescript
test('should add widget to canvas', async ({ page }) => {
  // Open widget library
  await page.click('[data-testid="library-tab"]');

  // Search for widget
  await page.fill('[data-testid="widget-search"]', 'my-widget');

  // Click to add
  await page.click('[data-testid="widget-card-my-widget"]');

  // Verify widget appears on canvas
  await expect(page.locator('[data-widget-id*="my-widget"]')).toBeVisible();
});
```

#### Testing Widget Interactions

```typescript
test('should respond to clicks', async ({ page }) => {
  // Add widget first...

  // Get widget iframe
  const widgetFrame = page.frameLocator('[data-widget-id*="my-widget"] iframe');

  // Click element inside widget
  await widgetFrame.locator('#button').click();

  // Verify result
  await expect(widgetFrame.locator('#count')).toHaveText('1');
});
```

#### Testing Widget Communication

```typescript
test('should emit events to connected widgets', async ({ page }) => {
  // Add source widget
  await addWidget(page, 'counter');

  // Add target widget
  await addWidget(page, 'display');

  // Create connection (via UI or programmatically)
  await createConnection(page, 'counter', 'valueChanged', 'display', 'data.set');

  // Interact with source
  const counterFrame = page.frameLocator('[data-widget-id*="counter"] iframe');
  await counterFrame.locator('#increment').click();

  // Verify target received data
  const displayFrame = page.frameLocator('[data-widget-id*="display"] iframe');
  await expect(displayFrame.locator('#value')).toHaveText('1');
});
```

#### Testing Widget State Persistence

```typescript
test('should persist state across reload', async ({ page }) => {
  // Add widget and modify state
  const widgetFrame = page.frameLocator('[data-widget-id*="counter"] iframe');
  await widgetFrame.locator('#increment').click();
  await widgetFrame.locator('#increment').click();

  // Save canvas
  await page.click('[data-testid="save-canvas"]');

  // Reload page
  await page.reload();
  await page.waitForSelector('[data-testid="canvas"]');

  // Verify state persisted
  const reloadedFrame = page.frameLocator('[data-widget-id*="counter"] iframe');
  await expect(reloadedFrame.locator('#count')).toHaveText('2');
});
```

### Test Helpers

Create reusable helpers in `tests/helpers.ts`:

```typescript
import { Page, expect } from '@playwright/test';

export async function addWidget(page: Page, widgetId: string) {
  await page.click('[data-testid="library-tab"]');
  await page.fill('[data-testid="widget-search"]', widgetId);
  await page.click(`[data-testid="widget-card-${widgetId}"]`);
  await page.waitForSelector(`[data-widget-id*="${widgetId}"]`);
}

export async function getWidgetFrame(page: Page, widgetId: string) {
  return page.frameLocator(`[data-widget-id*="${widgetId}"] iframe`);
}

export async function waitForWidgetReady(page: Page, widgetId: string) {
  await page.waitForFunction(
    (id) => {
      const widget = document.querySelector(`[data-widget-id*="${id}"]`);
      return widget?.getAttribute('data-lifecycle') === 'ready';
    },
    widgetId,
    { timeout: 5000 }
  );
}

export async function createConnection(
  page: Page,
  sourceId: string,
  sourcePort: string,
  targetId: string,
  targetPort: string
) {
  // Implementation depends on your connection UI
  // This is a placeholder for programmatic connection
}
```

---

## Vitest Unit Tests

### Test File Structure

```typescript
// src/widgets/builtin/MyWidget.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { MyWidgetManifest } from './MyWidget';

describe('MyWidget', () => {
  describe('Manifest', () => {
    it('should have valid id format', () => {
      expect(MyWidgetManifest.id).toMatch(/^stickernest\.[a-z-]+$/);
    });

    it('should have required fields', () => {
      expect(MyWidgetManifest.id).toBeDefined();
      expect(MyWidgetManifest.name).toBeDefined();
      expect(MyWidgetManifest.version).toBeDefined();
      expect(MyWidgetManifest.entry).toBeDefined();
    });

    it('should have valid version format', () => {
      expect(MyWidgetManifest.version).toMatch(/^\d+\.\d+\.\d+$/);
    });
  });
});
```

### Testing Manifest Validation

```typescript
import { validateManifest } from '../../runtime/ManifestValidator';

describe('Manifest Validation', () => {
  it('should pass validation', () => {
    const result = validateManifest(MyWidgetManifest);
    expect(result.valid).toBe(true);
    expect(result.errors).toHaveLength(0);
  });

  it('should have matching input/output declarations', () => {
    const { inputs, outputs, io } = MyWidgetManifest;

    // Check io.inputs have corresponding input ports
    if (io?.inputs) {
      io.inputs.forEach(inputId => {
        const baseId = inputId.split('.')[0];
        expect(inputs).toHaveProperty(baseId);
      });
    }

    // Check io.outputs have corresponding output ports
    if (io?.outputs) {
      io.outputs.forEach(outputId => {
        const baseId = outputId.split('.')[0];
        expect(outputs).toHaveProperty(baseId);
      });
    }
  });
});
```

### Testing Port Compatibility

```typescript
import { isPortCompatible } from '../../runtime/PortCompatibility';

describe('Port Compatibility', () => {
  it('should allow same types', () => {
    expect(isPortCompatible('string', 'string')).toBe(true);
    expect(isPortCompatible('number', 'number')).toBe(true);
  });

  it('should allow any type to receive all', () => {
    expect(isPortCompatible('string', 'any')).toBe(true);
    expect(isPortCompatible('number', 'any')).toBe(true);
    expect(isPortCompatible('object', 'any')).toBe(true);
  });

  it('should reject incompatible types', () => {
    expect(isPortCompatible('string', 'number')).toBe(false);
    expect(isPortCompatible('trigger', 'string')).toBe(false);
  });
});
```

### Testing Pipeline Runtime

```typescript
import { PipelineRuntime } from '../../runtime/PipelineRuntime';
import { EventBus } from '../../runtime/EventBus';

describe('PipelineRuntime', () => {
  let runtime: PipelineRuntime;
  let eventBus: EventBus;

  beforeEach(() => {
    eventBus = new EventBus();
    runtime = new PipelineRuntime({ eventBus });
  });

  it('should route events between connected widgets', async () => {
    const received: any[] = [];

    // Subscribe to target
    eventBus.on('widget:input', (event) => {
      if (event.targetWidgetId === 'widget-b') {
        received.push(event);
      }
    });

    // Create connection
    runtime.addConnection({
      id: 'conn-1',
      sourceNodeId: 'widget-a',
      sourcePortId: 'output',
      targetNodeId: 'widget-b',
      targetPortId: 'input',
    });

    // Emit from source
    runtime.handleOutput('widget-a', 'output', { value: 42 });

    expect(received).toHaveLength(1);
    expect(received[0].payload.value).toBe(42);
  });
});
```

### Mocking WidgetAPI

```typescript
import { vi } from 'vitest';

function createMockWidgetAPI() {
  return {
    onMount: vi.fn(),
    onDestroy: vi.fn(),
    onInput: vi.fn(),
    onStateChange: vi.fn(),
    setState: vi.fn(),
    emitOutput: vi.fn(),
    emit: vi.fn(),
    on: vi.fn(),
    log: vi.fn(),
    getAssetUrl: vi.fn((path) => `/assets/${path}`),
  };
}

describe('Widget HTML Logic', () => {
  let mockAPI: ReturnType<typeof createMockWidgetAPI>;

  beforeEach(() => {
    mockAPI = createMockWidgetAPI();
    (global as any).window = { WidgetAPI: mockAPI };
  });

  it('should register mount handler', () => {
    // Execute widget script logic
    // ...
    expect(mockAPI.onMount).toHaveBeenCalled();
  });
});
```

---

## Testing Patterns by Widget Type

### Display Widget Tests

```typescript
test('should update display when content changes', async ({ page }) => {
  const frame = await getWidgetFrame(page, 'basic-text');

  // Send input via debug panel or programmatically
  await sendWidgetInput(page, 'basic-text', 'text.set', 'New Content');

  await expect(frame.locator('#text')).toHaveText('New Content');
});
```

### Interactive Widget Tests

```typescript
test('should handle user interaction', async ({ page }) => {
  const frame = await getWidgetFrame(page, 'counter');

  // Initial state
  await expect(frame.locator('#count')).toHaveText('0');

  // Click increment
  await frame.locator('#increment').click();

  // Verify update
  await expect(frame.locator('#count')).toHaveText('1');
});
```

### Timer Widget Tests

```typescript
test('should count down correctly', async ({ page }) => {
  const frame = await getWidgetFrame(page, 'timer');

  // Start timer
  await frame.locator('#start').click();

  // Wait for countdown
  await page.waitForTimeout(1100); // 1 second + buffer

  // Verify time decreased
  const timeText = await frame.locator('#time').textContent();
  expect(parseInt(timeText || '60')).toBeLessThan(60);
});
```

---

## Existing Test Files Reference

| File | Tests |
|------|-------|
| `tests/widget-basics.spec.ts` | Widget loading, lifecycle |
| `tests/widget-integration.spec.ts` | Cross-widget communication |
| `tests/pipeline-routing.spec.ts` | Pipeline connections |
| `tests/pipeline-creation.spec.ts` | Pipeline UI |
| `tests/ai-pipeline-integration.spec.ts` | AI widget generation |
| `tests/widget-generation.spec.ts` | Widget creation |
| `src/runtime/PipelineRuntime.test.ts` | Pipeline unit tests |
| `src/runtime/PortCompatibility.test.ts` | Port compatibility |
| `src/runtime/EventBus.test.ts` | Event bus unit tests |
| `src/state/usePanelsStore.test.ts` | Store tests |

---

## Debugging Tests

### Playwright Debug Mode

```bash
# Run with debug UI
npx playwright test --debug

# Run specific test file
npx playwright test tests/my-widget.spec.ts

# Run with trace on failure
npx playwright test --trace on
```

### Vitest Debug

```bash
# Run specific test file
npx vitest run src/widgets/builtin/MyWidget.test.ts

# Watch specific file
npx vitest watch src/widgets/builtin/MyWidget.test.ts
```

### Console Logging in E2E Tests

```typescript
test('debug widget', async ({ page }) => {
  // Capture console logs
  page.on('console', msg => console.log('PAGE LOG:', msg.text()));

  // Capture errors
  page.on('pageerror', err => console.error('PAGE ERROR:', err));

  // Your test...
});
```

---

## Test Configuration

### Playwright Config

Located at `playwright.config.ts`:

```typescript
export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry',
  },
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
  },
});
```

### Vitest Config

Located in `vite.config.ts`:

```typescript
export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    include: ['src/**/*.test.ts'],
  },
});
```
