---
name: backend-dev
description: This skill should be used when developing backend services for Manjha using Encore.ts, implementing agents, writing E2E tests, or working with the message-driven architecture. It ensures adherence to TDD practices, type safety, proper logging, and Manjha's development principles.
license: MIT
---

# Backend Development Skill for Manjha

This skill provides guidance for developing backend services in the Manjha project using Encore.ts, LangGraph agents, and PostgreSQL.

## When to Use This Skill

Use this skill when:
- Creating new Encore.ts services or agents
- Writing E2E tests for backend flows
- Implementing message classification or agent orchestration
- Working with the database schema
- Setting up logging or configuration
- Debugging backend issues
- Ensuring type safety across services

## Core Principles

### 1. Spec-Driven Development
Every feature starts with a spec in `/specs` folder before any code is written.

### 2. Red-Green-Refactor TDD
Follow this cycle religiously:
1. **Red**: Write E2E test that fails
2. **Green**: Implement feature until test passes
3. **Refactor**: Clean up while keeping tests green

### 3. Type Safety (Non-Negotiable)
- **Zero tolerance for `any` types**
- Use explicit interfaces and types (see `contracts/api.types.ts` and `contracts/database.types.ts`)
- Prefer enums over string unions
- Linter must enforce type safety

### 4. Centralized Logging
All logging goes through the common logging module at `common/logging/logger.ts`. Never use `console.log`.

## Architecture Overview

### Encore.ts Services
Manjha uses Encore.ts for all backend services. Each service follows this structure:

```
service-name/
├── encore.service.ts  # Service definition & API endpoints
├── agent.ts           # Agent logic (if applicable)
├── db.ts              # Database operations (if applicable)
└── migrations/        # SQL migrations (if applicable)
```

### Agent-as-Service Pattern
Backend services are modular agents:
- `message-classifier`: Routes messages to appropriate agents
- `finance-agent`: Handles financial queries
- `general-agent`: Handles general queries
- `agent-orchestrator`: Orchestrates multi-agent workflows using LangGraph

### Service Communication
Services communicate through Encore's generated clients:
```typescript
import { getAuthData } from "encore.dev/auth";
import * as classifier from "~encore/clients/message-classifier";
```

## E2E Test Development

### Test Structure
E2E tests live in `backend/tests/e2e/` and follow this format:

```typescript
import { describe, it, expect, beforeEach } from "vitest";

/**
 * PURPOSE: Clear statement of what invariants/behaviors are being validated
 * Format: "User did X → System did Y → UI shows Z → Gucci ✓"
 */
describe("Feature Name", () => {
  beforeEach(async () => {
    // Setup: Create test data, reset state
  });

  it("validates the happy path flow", async () => {
    // Arrange: Set up preconditions
    // Act: Execute the behavior
    // Assert: Verify outcomes
  });

  it("handles edge case: specific scenario", async () => {
    // Test edge cases and error conditions
  });
});
```

### Test Principles
1. **Test USER-FACING behavior**, not implementation details
2. Each test should validate complete flows, not petty unit tests
3. Use descriptive names that explain the scenario
4. Include PURPOSE comments explaining what invariants are being tested
5. Tests should be independent and idempotent

### Running Tests
```bash
cd backend
encore test                 # ONLY correct way to run tests (sets up runtime environment)
```

**CRITICAL**: Never use `npm test` directly. Always use `encore test` as it properly initializes the Encore runtime environment.

## Creating New Services

### Step 1: Define Service Structure
Create the service directory with `encore.service.ts`:

```typescript
import { Service } from "encore.dev/service";

export default new Service("service-name");
```

### Step 2: Define API Endpoints
```typescript
import { api } from "encore.dev/api";
import { Header } from "encore.dev/api";
import type { APIResponse } from "../contracts/api.types";

interface RequestPayload {
  // Strong types, no 'any'
}

interface ResponsePayload {
  // Strong types, no 'any'
}

/**
 * PURPOSE: Explain why this endpoint exists in the codebase
 */
export const endpointName = api(
  { method: "POST", path: "/path", expose: true, auth: false },
  async (payload: RequestPayload): Promise<APIResponse<ResponsePayload>> => {
    // Implementation
  }
);
```

### Step 3: Add Database Operations (if needed)
Create migrations in `migrations/` directory:
- `001_create_table.up.sql` - Migration
- `001_create_table.down.sql` - Rollback

Define database operations in `db.ts` using the patterns from `chat-gateway/db.ts`.

### Step 4: Implement Agent Logic (if applicable)
For agent services, create `agent.ts` with clear separation of concerns.

### Step 5: Add to Contracts
Update `contracts/api.types.ts` and `contracts/database.types.ts` with new types.

## Working with Agents

### LangGraph Integration
Agent orchestration uses LangGraph. See `agent-orchestrator/graph.ts` for patterns.

### Agent State Management
Define strongly-typed state interfaces:
```typescript
interface AgentState {
  messages: Array<{ role: string; content: string }>;
  context: Record<string, unknown>; // Use specific types when possible
  // Never use 'any'
}
```

### Message Classification
The `message-classifier` service routes messages to appropriate agents. When adding new message types:
1. Update the classifier logic in `message-classifier/classifier.ts`
2. Add enum values (not string unions)
3. Update tests to cover new message types

## Configuration & Constants

All configuration lives in `common/config/constants.ts`:
- API keys (from environment variables)
- Model configurations
- Rate limits
- Timeouts

Reference the file in `references/` for complete patterns.

## Logging Best Practices

```typescript
import { logger } from "../common/logging/logger";

// Info level for normal operations
logger.info("Processing request", { userId, requestId });

// Error level with context
logger.error("Failed to process", { error, context });

// Debug level for development
logger.debug("Detailed state", { state });
```

## Type Safety Checklist

Before committing:
- [ ] No `any` types anywhere
- [ ] All interfaces defined in `contracts/`
- [ ] Enums used instead of string unions where appropriate
- [ ] Function signatures have explicit return types
- [ ] Error types are strongly typed
- [ ] Linter passes with no type warnings

## Quality Gates

Every backend change must:
- ✓ Have a spec in `/specs`
- ✓ Have E2E test(s) that pass
- ✓ Use proper logging via common module
- ✓ Have zero `any` types (linter enforced)
- ✓ Follow file organization rules

## Common Patterns

### API Response Pattern
```typescript
import type { APIResponse } from "../contracts/api.types";

// Success
return { success: true, data: result };

// Error
return { success: false, error: { code: "ERROR_CODE", message: "Description" } };
```

### Error Handling Pattern
```typescript
try {
  // Operation
  logger.info("Operation succeeded", { context });
  return { success: true, data };
} catch (error) {
  logger.error("Operation failed", { error, context });
  return { 
    success: false, 
    error: { code: "OPERATION_ERROR", message: error.message } 
  };
}
```

### Database Query Pattern
See `chat-gateway/db.ts` for established patterns on:
- Transaction handling
- Connection pooling
- Query parameterization
- Error handling

## References

See the `references/` directory for:
- Complete Encore.ts patterns
- Database schema documentation
- Testing patterns and examples
- LangGraph agent patterns

## Next Steps After Using This Skill

1. Review the E2E test to ensure it covers the feature
2. Verify type safety (run linter)
3. Check logging is through common module
4. Confirm spec exists and is up-to-date
5. Update this skill with any new patterns discovered

