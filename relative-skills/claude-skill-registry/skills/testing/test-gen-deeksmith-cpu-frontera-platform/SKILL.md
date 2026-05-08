---
name: test-gen
description: Generate tests following Frontera test patterns. Use when user says "write tests", "add tests", "test this", "create unit tests", "generate tests", or asks to test a component/function/API.
---

# Test Generator Skill

Generates tests following the established Frontera test framework patterns.

## When to Use

Activate when user requests:
- "write tests for"
- "add tests"
- "test this component"
- "create unit tests"
- "generate tests"

## Test Types

### 1. Unit Tests (Vitest)

Location: `tests/unit/`

Pattern:
```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('FunctionName', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should do expected behavior', () => {
    // Arrange
    // Act
    // Assert
    expect(result).toBe(expected);
  });
});
```

### 2. Component Tests (React Testing Library)

Location: `tests/unit/components/`

Pattern:
```typescript
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from 'tests/helpers/test-utils';
import userEvent from '@testing-library/user-event';
import { ComponentName } from '@/components/feature/ComponentName';

describe('ComponentName', () => {
  it('should render correctly', () => {
    render(<ComponentName />);
    expect(screen.getByText('Expected')).toBeInTheDocument();
  });

  it('should handle user interaction', async () => {
    const user = userEvent.setup();
    render(<ComponentName />);
    await user.click(screen.getByRole('button'));
    expect(screen.getByText('Result')).toBeVisible();
  });
});
```

### 3. Integration Tests (API Routes)

Location: `tests/integration/api/`

Pattern:
```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { NextRequest } from 'next/server';

// Mock dependencies
vi.mock('@clerk/nextjs/server', () => ({
  auth: vi.fn(),
}));

vi.mock('@supabase/supabase-js', () => ({
  createClient: vi.fn(),
}));

describe('GET /api/feature', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should return 401 when unauthorized', async () => {
    mockAuth.mockResolvedValue({ userId: null, orgId: null });
    const response = await GET(new NextRequest('http://localhost/api/feature'));
    expect(response.status).toBe(401);
  });
});
```

### 4. E2E Tests (Playwright)

Location: `tests/e2e/specs/`

Pattern:
```typescript
import { test, expect } from '@playwright/test';
import { FeaturePage } from '../pages/FeaturePage';

test.describe('Feature Name', () => {
  test('should complete user journey', async ({ page }) => {
    const featurePage = new FeaturePage(page);
    await featurePage.goto();
    await featurePage.performAction();
    await expect(featurePage.resultElement).toBeVisible();
  });
});
```

Page Object Model in `tests/e2e/pages/`:
```typescript
import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

export class FeaturePage extends BasePage {
  readonly resultElement: Locator;

  constructor(page: Page) {
    super(page);
    this.resultElement = page.getByTestId('result');
  }

  async performAction() {
    await this.page.getByRole('button', { name: /action/i }).click();
  }
}
```

### 5. BDD Tests (Cucumber/Gherkin)

Feature file in `tests/bdd/features/`:
```gherkin
@feature-tag
Feature: Feature Name
  As a user
  I want to do something
  So that I achieve a goal

  Scenario: User completes action
    Given I am logged in
    When I perform the action
    Then I should see the result
```

Step definitions in `tests/bdd/step-definitions/`:
```typescript
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';
import { CustomWorld } from '../support/world';

When('I perform the action', async function (this: CustomWorld) {
  await this.page?.getByRole('button').click();
});

Then('I should see the result', async function (this: CustomWorld) {
  await expect(this.page!.getByText('Result')).toBeVisible();
});
```

## Mock Utilities

Import from `tests/mocks`:
```typescript
import { mockClerkModule, mockSupabaseModule, mockAnthropicModule } from 'tests/mocks';
import { createMockConversation, createMockClient } from 'tests/mocks/factories';
```

## Coverage Target

Maintain 90%+ coverage.
