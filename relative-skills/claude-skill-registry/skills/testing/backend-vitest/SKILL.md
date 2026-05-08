---
name: backend-vitest
description: Fast unit testing framework for TypeScript/JavaScript. Use for testing tRPC procedures, Zod schemas, utility functions, and any TypeScript code. Built on Vite with native ESM, TypeScript support, and Jest-compatible API. Choose Vitest over Jest for modern TypeScript projects, especially with Vite-based setups.
allowed-tools: Read, Edit, Write, Bash (*)
---

# Vitest (Testing Framework)

## Overview

Vitest is a blazing fast unit test framework powered by Vite. Native TypeScript support, ESM by default, Jest-compatible API, and instant watch mode.

**Version**: v2.x (2024-2025)  
**Requirements**: Node ≥18

**Key Benefit**: Zero config for TypeScript, uses Vite's transform pipeline, 10-20x faster than Jest.

## When to Use This Skill

✅ **Use Vitest when:**
- Testing TypeScript code (tRPC, Zod, utilities)
- Working with Vite-based projects
- Need fast watch mode during development
- Want native ESM support
- Testing React components (with @testing-library)

❌ **Consider Jest when:**
- Existing Jest setup with many custom configs
- Need specific Jest ecosystem plugins
- Team unfamiliar with Vitest

---

## Quick Start

### Installation

```bash
npm install -D vitest @vitest/coverage-v8 vitest-mock-extended
npm install -D vite-tsconfig-paths  # For path aliases
```

### Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    globals: true,              // Use describe, it, expect without imports
    environment: 'node',        // or 'jsdom' for React
    include: ['**/*.test.ts'],
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      include: ['src/**/*.ts'],
      exclude: ['src/**/*.test.ts', 'src/test/**'],
    },
    mockReset: true,
    restoreMocks: true,
  },
});
```

### TypeScript Config (for globals)

```json
// tsconfig.json
{
  "compilerOptions": {
    "types": ["vitest/globals"]
  }
}
```

### Scripts

```json
// package.json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage"
  }
}
```

---

## Basic Test Structure

```typescript
// src/utils/math.test.ts
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { add, multiply } from './math';

describe('Math Utils', () => {
  describe('add', () => {
    it('should add two numbers', () => {
      expect(add(2, 3)).toBe(5);
    });

    it('should handle negative numbers', () => {
      expect(add(-1, 1)).toBe(0);
    });
  });

  describe('multiply', () => {
    it('should multiply two numbers', () => {
      expect(multiply(2, 3)).toBe(6);
    });
  });
});
```

---

## Testing tRPC Procedures

### Mock Context Setup

```typescript
// src/test/context.ts
import { PrismaClient } from '@prisma/client';
import { mockDeep, DeepMockProxy } from 'vitest-mock-extended';

export type MockContext = {
  prisma: DeepMockProxy<PrismaClient>;
  user: { id: string; role: string } | null;
};

export const createMockContext = (user = null): MockContext => ({
  prisma: mockDeep<PrismaClient>(),
  user,
});
```

### Testing with createCallerFactory

```typescript
// src/server/routers/user.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { createCallerFactory } from '../trpc';
import { userRouter } from './user';
import { createMockContext, MockContext } from '@/test/context';

describe('User Router', () => {
  let mockCtx: MockContext;
  const createCaller = createCallerFactory(userRouter);

  beforeEach(() => {
    mockCtx = createMockContext();
  });

  describe('getById', () => {
    it('should return user by id', async () => {
      const mockUser = { 
        id: '1', 
        email: 'test@example.com', 
        name: 'Test',
        role: 'USER',
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      
      mockCtx.prisma.user.findUnique.mockResolvedValue(mockUser);

      const caller = createCaller(mockCtx);
      const result = await caller.getById({ id: '1' });

      expect(result).toEqual(mockUser);
      expect(mockCtx.prisma.user.findUnique).toHaveBeenCalledWith({
        where: { id: '1' },
      });
    });

    it('should throw NOT_FOUND for missing user', async () => {
      mockCtx.prisma.user.findUnique.mockResolvedValue(null);

      const caller = createCaller(mockCtx);
      
      await expect(caller.getById({ id: '1' }))
        .rejects.toThrow('NOT_FOUND');
    });
  });

  describe('create (protected)', () => {
    it('should reject unauthenticated requests', async () => {
      const caller = createCaller(mockCtx); // user is null
      
      await expect(caller.create({ 
        email: 'new@example.com', 
        name: 'New' 
      })).rejects.toThrow('UNAUTHORIZED');
    });

    it('should create user when authenticated', async () => {
      mockCtx = createMockContext({ id: 'admin', role: 'ADMIN' });
      const mockUser = { id: '2', email: 'new@example.com', name: 'New' };
      mockCtx.prisma.user.create.mockResolvedValue(mockUser);

      const caller = createCaller(mockCtx);
      const result = await caller.create({ 
        email: 'new@example.com', 
        name: 'New' 
      });

      expect(result).toEqual(mockUser);
    });
  });
});
```

---

## Testing Zod Schemas

```typescript
// src/schemas/user.schema.test.ts
import { describe, it, expect } from 'vitest';
import { CreateUserSchema, EmailSchema } from './user.schema';

describe('CreateUserSchema', () => {
  it('should validate correct input', () => {
    const result = CreateUserSchema.safeParse({
      email: 'test@example.com',
      name: 'Test User',
      password: 'SecurePass123',
    });
    
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.email).toBe('test@example.com');
    }
  });

  it('should reject invalid email', () => {
    const result = CreateUserSchema.safeParse({
      email: 'invalid-email',
      name: 'Test',
      password: 'SecurePass123',
    });
    
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0].path).toEqual(['email']);
    }
  });

  it('should reject short password', () => {
    const result = CreateUserSchema.safeParse({
      email: 'test@example.com',
      name: 'Test',
      password: '123',
    });
    
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0].path).toEqual(['password']);
    }
  });
});

describe('EmailSchema', () => {
  it.each([
    ['test@example.com', true],
    ['user.name@domain.org', true],
    ['invalid', false],
    ['@missing.com', false],
    ['no-domain@', false],
  ])('should validate "%s" as %s', (email, expected) => {
    const result = EmailSchema.safeParse(email);
    expect(result.success).toBe(expected);
  });
});
```

---

## Mocking Patterns

### Mock Functions

```typescript
import { vi, describe, it, expect } from 'vitest';

// Mock a function
const mockFn = vi.fn();
mockFn.mockReturnValue(42);
mockFn.mockResolvedValue(42);      // For async
mockFn.mockRejectedValue(new Error('fail'));

// Verify calls
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
expect(mockFn).toHaveBeenCalledTimes(1);
```

### Mock Modules

```typescript
import { vi, describe, it, expect } from 'vitest';

// Mock entire module
vi.mock('@/lib/email', () => ({
  sendEmail: vi.fn().mockResolvedValue({ success: true }),
}));

import { sendEmail } from '@/lib/email';

it('should send email', async () => {
  await sendEmail('test@example.com', 'Subject', 'Body');
  expect(sendEmail).toHaveBeenCalled();
});
```

### Spy on Methods

```typescript
import { vi, describe, it, expect } from 'vitest';

const obj = {
  method: () => 'original',
};

const spy = vi.spyOn(obj, 'method');
spy.mockReturnValue('mocked');

expect(obj.method()).toBe('mocked');
expect(spy).toHaveBeenCalled();

spy.mockRestore(); // Restore original
```

---

## Test Boundaries

| Type | Scope | Database | Speed | Use |
|------|-------|----------|-------|-----|
| **Unit** | Single function | Mocked | Fast | tRPC procedures, utils |
| **Integration** | Router + DB | Real test DB | Medium | Full flow testing |
| **E2E** | HTTP stack | Real test DB | Slow | API contracts |

---

## Setup Files

```typescript
// src/test/setup.ts
import { beforeAll, afterAll, afterEach } from 'vitest';

// Global setup
beforeAll(async () => {
  // Connect to test database, etc.
});

afterAll(async () => {
  // Cleanup
});

afterEach(() => {
  // Reset mocks between tests
});
```

---

## Common Assertions

```typescript
// Equality
expect(value).toBe(exact);           // ===
expect(value).toEqual(deepEqual);    // Deep equality
expect(value).toStrictEqual(strict); // Including undefined props

// Truthiness
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeDefined();

// Numbers
expect(value).toBeGreaterThan(3);
expect(value).toBeLessThanOrEqual(10);
expect(value).toBeCloseTo(0.3, 5);   // Float precision

// Strings
expect(value).toMatch(/regex/);
expect(value).toContain('substring');

// Arrays/Objects
expect(array).toContain(item);
expect(array).toHaveLength(3);
expect(object).toHaveProperty('key', 'value');

// Errors
expect(() => fn()).toThrow();
expect(() => fn()).toThrow('message');
await expect(asyncFn()).rejects.toThrow();
```

---

## Rules

### Do ✅

- Use `describe` blocks to organize related tests
- Use `beforeEach` for fresh mock context
- Mock external dependencies (DB, APIs)
- Test edge cases and error paths
- Use `it.each` for parameterized tests
- Keep unit tests fast and isolated

### Avoid ❌

- Testing implementation details
- Skipping error case tests
- Sharing mutable state between tests
- Over-mocking (test real logic)
- Tests that depend on other tests

---

## Troubleshooting

```yaml
"Cannot find module":
  → Check vite-tsconfig-paths plugin
  → Verify path aliases in tsconfig
  → Restart Vitest

"Mock not working":
  → Ensure vi.mock() is at top level (hoisted)
  → Check mockReset/restoreMocks in config
  → Use vi.mocked() for type inference

"Async test timeout":
  → Increase timeout: it('test', async () => {}, 10000)
  → Check for unresolved promises
  → Verify mocks return resolved values

"Coverage not accurate":
  → Use v8 provider (faster, more accurate)
  → Exclude test files from coverage
  → Run with --coverage flag
```

---

## File Structure

```
src/
├── server/routers/
│   ├── user.ts
│   └── user.test.ts      # Co-located tests
├── schemas/
│   ├── user.schema.ts
│   └── user.schema.test.ts
├── utils/
│   ├── helpers.ts
│   └── helpers.test.ts
└── test/
    ├── setup.ts          # Global setup
    └── context.ts        # Mock context factory

vitest.config.ts          # Vitest configuration
```

## References

- https://vitest.dev — Official documentation
- https://vitest.dev/api — API reference
- https://vitest.dev/guide/mocking — Mocking guide
