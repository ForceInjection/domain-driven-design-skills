---
name: vitest-config-generator
description: Generate Vitest configuration files for fast unit testing of JavaScript/TypeScript projects. Triggers on "create vitest config", "generate vitest configuration", "vitest setup", "unit test config".
---

# Vitest Config Generator

Generate Vitest configuration files for fast unit and integration testing.

## Output Requirements

**File Output:** `vitest.config.ts`
**Format:** Valid Vitest configuration
**Standards:** Vitest 1.x

## When Invoked

Immediately generate a complete Vitest configuration with test environment, coverage, and setup files.

## Configuration Template

```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
  },
});
```

## Example Invocations

**Prompt:** "Create vitest config for React with coverage"
**Output:** Complete `vitest.config.ts` with jsdom and coverage settings.
