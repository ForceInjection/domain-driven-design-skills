---
name: cypress-test-generator
description: Generate Cypress E2E test files and configuration for web application testing. Triggers on "create cypress test", "generate cypress config", "e2e test for", "cypress setup".
---

# Cypress Test Generator

Generate Cypress E2E test files and configuration for comprehensive web application testing.

## Output Requirements

**File Output:** `cypress.config.ts`, `cypress/e2e/*.cy.ts`
**Format:** Valid Cypress configuration and test files
**Standards:** Cypress 13.x

## When Invoked

Immediately generate Cypress configuration and sample test files for the specified application.

## Configuration Template

```typescript
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    supportFile: 'cypress/support/e2e.ts',
  },
});
```

## Example Invocations

**Prompt:** "Create cypress config and login test"
**Output:** Complete `cypress.config.ts` and `cypress/e2e/login.cy.ts`.
