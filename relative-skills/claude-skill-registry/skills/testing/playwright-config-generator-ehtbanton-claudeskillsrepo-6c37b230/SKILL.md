---
name: playwright-config-generator
description: Generate Playwright configuration files for cross-browser E2E testing. Triggers on "create playwright config", "generate playwright configuration", "playwright setup", "browser testing config".
---

# Playwright Config Generator

Generate Playwright configuration files for comprehensive cross-browser E2E testing.

## Output Requirements

**File Output:** `playwright.config.ts`
**Format:** Valid Playwright configuration
**Standards:** Playwright 1.40+

## When Invoked

Immediately generate a complete Playwright configuration with browser projects and test settings.

## Configuration Template

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  use: {
    baseURL: 'http://localhost:3000',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});
```

## Example Invocations

**Prompt:** "Create playwright config for multi-browser testing"
**Output:** Complete `playwright.config.ts` with Chrome, Firefox, Safari projects.
