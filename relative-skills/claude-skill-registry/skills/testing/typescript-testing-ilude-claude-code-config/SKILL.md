---
name: typescript-testing
description: TypeScript/JavaScript testing practices with Bun's test runner. Activate when working with bun test, .test.ts, .test.js, .spec.ts, .spec.js, testing TypeScript/JavaScript, bunfig.toml, testing configuration, or test-related tasks in Bun projects.
---

# TypeScript Testing with Bun

TypeScript/JavaScript-specific testing patterns and best practices using Bun's built-in test runner, complementing general testing-workflow skill.

## CRITICAL: Bun Test Execution

**NEVER use jest, vitest, or other test runners in Bun projects:**

```bash
# ✅ CORRECT - Bun test execution
bun test
bun test --watch
bun test src/__tests__
bun test --coverage
bun test --bail
bun test tests/unit.test.ts

# ❌ WRONG - Never use jest in Bun projects
# ❌ jest
# ❌ jest --watch
# ❌ npm run test (if mapped to jest)

# ❌ WRONG - Never use vitest in Bun projects
# ❌ vitest
# ❌ vitest run
```

**Always use `bun test` directly** (never use jest/vitest in Bun projects).

---

## Test File Organization

### File Naming Conventions

Bun recognizes test files by standard conventions:

```
src/
├── utils/
│   ├── math.ts
│   ├── math.test.ts              # ✅ Standard .test.ts
│   ├── string-utils.spec.ts      # ✅ Alternative .spec.ts
│   └── validation/
│       ├── validator.ts
│       └── validator.test.ts
├── services/
│   ├── api.ts
│   └── __tests__/                # ✅ __tests__ directory
│       └── api.test.ts
└── components/
    ├── Button.tsx
    └── Button.test.tsx           # ✅ React component tests
```

### Discovery Patterns

Bun automatically finds tests matching:
- `*.test.ts` / `*.test.tsx`
- `*.test.js` / `*.test.jsx`
- `*.spec.ts` / `*.spec.tsx`
- `*.spec.js` / `*.spec.jsx`
- Files in `__tests__` directories

---

## Basic Test Structure

### Simple Test Example

```typescript
import { describe, it, expect } from "bun:test";
import { add, multiply } from "./math";

describe("Math utilities", () => {
  it("should add two numbers", () => {
    expect(add(2, 3)).toBe(5);
  });

  it("should multiply two numbers", () => {
    expect(multiply(4, 5)).toBe(20);
  });

  it("should handle negative numbers", () => {
    expect(add(-1, -2)).toBe(-3);
  });
});
```

### Describe Blocks

Organize tests with nested describe blocks:

```typescript
import { describe, it, expect } from "bun:test";
import { UserService } from "./user-service";

describe("UserService", () => {
  describe("create", () => {
    it("should create user with valid data", () => {
      // Test implementation
    });

    it("should throw error on invalid email", () => {
      // Test implementation
    });
  });

  describe("update", () => {
    it("should update user properties", () => {
      // Test implementation
    });

    it("should not update protected fields", () => {
      // Test implementation
    });
  });

  describe("delete", () => {
    it("should delete user by id", () => {
      // Test implementation
    });
  });
});
```

---

## Bun Test API

### Describe and It

```typescript
import { describe, it, expect } from "bun:test";

describe("Feature name", () => {
  it("should do something", () => {
    expect(true).toBe(true);
  });

  it("should handle edge case", () => {
    expect(() => riskyOperation()).toThrow();
  });
});
```

### Common Assertions

```typescript
import { expect } from "bun:test";

// Equality
expect(value).toBe(5);              // Strict equality (===)
expect(obj).toEqual({ a: 1 });      // Deep equality
expect(value).toStrictEqual(5);     // Strict deep equality

// Truthiness
expect(value).toBeTruthy();         // Truthy value
expect(value).toBeFalsy();          // Falsy value
expect(value).toBeNull();           // null
expect(value).toBeUndefined();      // undefined
expect(value).toBeDefined();        // Not undefined

// Numbers
expect(number).toBeGreaterThan(5);
expect(number).toBeGreaterThanOrEqual(5);
expect(number).toBeLessThan(10);
expect(number).toBeLessThanOrEqual(10);
expect(0.1 + 0.2).toBeCloseTo(0.3); // Float comparison

// Strings
expect(string).toMatch(/pattern/);
expect(string).toContain("substring");

// Arrays
expect(array).toContain(value);
expect(array).toHaveLength(3);

// Objects
expect(obj).toHaveProperty("key");
expect(obj).toHaveProperty("key", expectedValue);

// Exceptions
expect(() => throwError()).toThrow();
expect(() => throwError()).toThrow(CustomError);
expect(() => throwError()).toThrow(/error message/);
```

### Skipping and Only

```typescript
import { it, describe } from "bun:test";

describe("Feature", () => {
  it("should test this", () => {
    // Runs
  });

  it.skip("should skip this test", () => {
    // Skipped
  });

  it.only("should run only this test", () => {
    // Only this runs in the suite
  });

  describe.skip("skipped suite", () => {
    it("won't run", () => {});
  });
});
```

### Test.todo

```typescript
import { it } from "bun:test";

it.todo("feature not yet implemented");
it.todo("edge case to handle");
```

---

## Setup and Teardown

### beforeEach and afterEach

```typescript
import { describe, it, beforeEach, afterEach, expect } from "bun:test";
import { Database } from "./database";

describe("Database operations", () => {
  let db: Database;

  beforeEach(() => {
    // Setup before each test
    db = new Database(":memory:");
    db.initialize();
  });

  afterEach(() => {
    // Cleanup after each test
    db.close();
  });

  it("should insert and retrieve data", () => {
    db.insert("users", { id: 1, name: "John" });
    const user = db.query("SELECT * FROM users WHERE id = 1");
    expect(user.name).toBe("John");
  });
});
```

### beforeAll and afterAll

```typescript
import { describe, it, beforeAll, afterAll, expect } from "bun:test";
import { setupExpensiveResource } from "./resources";

describe("Resource-intensive operations", () => {
  let resource: any;

  beforeAll(() => {
    // Setup once for entire suite
    resource = setupExpensiveResource();
  });

  afterAll(() => {
    // Cleanup once after entire suite
    resource.teardown();
  });

  it("uses expensive resource", () => {
    expect(resource.isReady()).toBe(true);
  });

  it("performs operation", () => {
    const result = resource.process("data");
    expect(result).toBeDefined();
  });
});
```

### Nested Hooks

```typescript
import { describe, it, beforeEach } from "bun:test";

describe("Outer suite", () => {
  let value = 0;

  beforeEach(() => {
    value = 10;
  });

  it("test in outer", () => {
    expect(value).toBe(10);
  });

  describe("Inner suite", () => {
    beforeEach(() => {
      value *= 2;  // Runs after outer beforeEach
    });

    it("test in inner", () => {
      expect(value).toBe(20);  // 10 * 2
    });
  });
});
```

---

## Mocking with Bun

### Using mock()

```typescript
import { mock } from "bun:test";
import { fetchUser } from "./api";

const mockFetch = mock((userId: string) => {
  return { id: userId, name: "Mock User" };
});

// Test mock behavior
const result = mockFetch("123");
expect(result.name).toBe("Mock User");
expect(mockFetch.mock.calls.length).toBe(1);
expect(mockFetch.mock.calls[0]).toEqual(["123"]);
```

### Mock Objects and Modules

```typescript
import { describe, it, expect, mock } from "bun:test";

describe("Service with mocked dependency", () => {
  it("should use mocked database", () => {
    const mockDb = {
      query: mock((sql: string) => [{ id: 1, name: "Test" }]),
      close: mock(() => {}),
    };

    const service = new Service(mockDb);
    const result = service.getUser(1);

    expect(result.name).toBe("Test");
    expect(mockDb.query.mock.calls.length).toBe(1);
  });
});
```

### Module Mocking

```typescript
import { describe, it, expect, mock } from "bun:test";
import { getUserFromAPI } from "./api";

// Mock entire modules
mock.module("./api", () => ({
  getUserFromAPI: mock((id: string) => ({
    id,
    name: "Mocked User",
  })),
}));

describe("API integration", () => {
  it("should work with mocked API", async () => {
    const user = await getUserFromAPI("123");
    expect(user.name).toBe("Mocked User");
  });
});
```

### Spy on Function Calls

```typescript
import { describe, it, expect, mock } from "bun:test";

describe("Spy on calls", () => {
  it("should track function calls", () => {
    const originalFunc = (x: number) => x * 2;
    const spied = mock(originalFunc);

    const result1 = spied(5);
    const result2 = spied(10);

    expect(result1).toBe(10);
    expect(result2).toBe(20);
    expect(spied.mock.calls.length).toBe(2);
    expect(spied.mock.results[0].value).toBe(10);
    expect(spied.mock.results[1].value).toBe(20);
  });
});
```

### Mock Return Values

```typescript
import { describe, it, expect, mock } from "bun:test";

describe("Mock return values", () => {
  it("should return configured values", () => {
    const mockFunc = mock();

    // Set return values for specific calls
    mockFunc.mock.returns = [
      { value: "first" },
      { value: "second" },
      { value: "third" },
    ];

    expect(mockFunc()).toEqual({ value: "first" });
    expect(mockFunc()).toEqual({ value: "second" });
  });

  it("should throw errors when configured", () => {
    const errorMock = mock(() => {
      throw new Error("Mocked error");
    });

    expect(() => errorMock()).toThrow("Mocked error");
  });
});
```

---

## Async Testing

### Async/Await in Tests

```typescript
import { describe, it, expect } from "bun:test";
import { fetchUser } from "./api";

describe("Async operations", () => {
  it("should fetch user data", async () => {
    const user = await fetchUser("123");
    expect(user.id).toBe("123");
    expect(user.name).toBeDefined();
  });

  it("should handle fetch errors", async () => {
    expect(fetchUser("invalid")).rejects.toThrow();
  });
});
```

### Promise Testing

```typescript
import { describe, it, expect } from "bun:test";

describe("Promise handling", () => {
  it("should resolve with data", () => {
    const promise = Promise.resolve({ id: 1, name: "User" });
    return expect(promise).resolves.toEqual({ id: 1, name: "User" });
  });

  it("should reject with error", () => {
    const promise = Promise.reject(new Error("Failed"));
    return expect(promise).rejects.toThrow("Failed");
  });
});
```

### Concurrent Async Tests

```typescript
import { describe, it, expect } from "bun:test";

describe("Concurrent operations", () => {
  it("should handle multiple concurrent requests", async () => {
    const results = await Promise.all([
      fetchData("1"),
      fetchData("2"),
      fetchData("3"),
    ]);

    expect(results).toHaveLength(3);
    expect(results[0].id).toBe("1");
    expect(results[1].id).toBe("2");
    expect(results[2].id).toBe("3");
  });

  it("should race multiple promises", async () => {
    const winner = await Promise.race([
      slowOperation(100),
      slowOperation(50),
      slowOperation(200),
    ]);

    expect(winner).toBeDefined();
  });
});
```

---

## Test Fixtures and Utilities

### Shared Test Data

```typescript
// tests/fixtures/users.ts
export const testUsers = {
  admin: {
    id: "1",
    email: "admin@example.com",
    role: "admin",
  },
  user: {
    id: "2",
    email: "user@example.com",
    role: "user",
  },
  guest: {
    id: "3",
    email: "guest@example.com",
    role: "guest",
  },
};

export const invalidUsers = {
  noEmail: { id: "4" },
  invalidEmail: { id: "5", email: "not-an-email" },
  noId: { email: "test@example.com" },
};

// In test file
import { describe, it, expect } from "bun:test";
import { testUsers } from "./fixtures/users";

describe("User roles", () => {
  it("should verify admin role", () => {
    expect(testUsers.admin.role).toBe("admin");
  });
});
```

### Fixture Setup Function

```typescript
// tests/fixtures/setup.ts
export function createMockUser(overrides: Partial<User> = {}): User {
  return {
    id: "test-id",
    email: "test@example.com",
    name: "Test User",
    role: "user",
    createdAt: new Date(),
    ...overrides,
  };
}

export function createMockDatabase() {
  const users: User[] = [];

  return {
    addUser: (user: User) => {
      users.push(user);
      return user;
    },
    getUser: (id: string) => users.find(u => u.id === id),
    getAllUsers: () => [...users],
    clear: () => users.splice(0),
  };
}

// In test
import { describe, it, beforeEach, expect } from "bun:test";
import { createMockUser, createMockDatabase } from "./fixtures/setup";

describe("User repository", () => {
  let db: ReturnType<typeof createMockDatabase>;

  beforeEach(() => {
    db = createMockDatabase();
  });

  it("should add and retrieve users", () => {
    const user = createMockUser({ name: "John Doe" });
    db.addUser(user);

    expect(db.getUser(user.id)?.name).toBe("John Doe");
  });
});
```

---

## Coverage with Bun

### Running Coverage

```bash
# Generate coverage report
bun test --coverage

# Coverage with specific files
bun test --coverage src/

# HTML coverage report
bun test --coverage --coverage-html
```

### Configuration in bunfig.toml

```toml
[test]
# Enable coverage
coverage = true

# Coverage reporting format
coverageFormat = ["text", "html", "json"]

# Files to report on
coverageThreshold = 80

# Exclude from coverage
coverageIgnore = ["**/node_modules/**", "**/dist/**"]

# Root directory for coverage
coverageRoot = "src"
```

### Coverage Reports

```bash
# Text report
bun test --coverage

# Generate HTML report in coverage/
bun test --coverage --coverage-html

# JSON report for CI/CD
bun test --coverage coverage/coverage.json
```

---

## Integration Testing

### Testing HTTP APIs

```typescript
import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { startServer, stopServer } from "./server";

describe("API Integration", () => {
  let baseUrl: string;

  beforeAll(async () => {
    const server = await startServer();
    baseUrl = `http://localhost:${server.port}`;
  });

  afterAll(async () => {
    await stopServer();
  });

  it("should create a user", async () => {
    const response = await fetch(`${baseUrl}/api/users`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: "test@example.com" }),
    });

    expect(response.status).toBe(201);
    const data = await response.json();
    expect(data.id).toBeDefined();
  });

  it("should retrieve user", async () => {
    const response = await fetch(`${baseUrl}/api/users/1`);
    expect(response.status).toBe(200);
  });
});
```

### Database Integration

```typescript
import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { Database } from "./database";

describe("Database operations", () => {
  let db: Database;

  beforeAll(async () => {
    db = new Database(":memory:");
    await db.initialize();
    await db.runMigrations();
  });

  afterAll(async () => {
    await db.close();
  });

  it("should perform CRUD operations", async () => {
    // Create
    const user = await db.users.create({
      email: "test@example.com",
      name: "Test User",
    });
    expect(user.id).toBeDefined();

    // Read
    const retrieved = await db.users.findById(user.id);
    expect(retrieved.email).toBe("test@example.com");

    // Update
    await db.users.update(user.id, { name: "Updated" });
    const updated = await db.users.findById(user.id);
    expect(updated.name).toBe("Updated");

    // Delete
    await db.users.delete(user.id);
    const deleted = await db.users.findById(user.id);
    expect(deleted).toBeNull();
  });
});
```

---

## Testing TypeScript Types

### Type Testing with TypeScript

```typescript
import { describe, it, expectTypeOf } from "bun:test";
import { processUser } from "./user-processor";

describe("Type safety", () => {
  it("should have correct return type", () => {
    const result = processUser({ name: "John", age: 30 });

    // Check type at compile time
    expectTypeOf(result).toMatchTypeOf<{ success: boolean }>();
  });

  it("should enforce parameter types", () => {
    // TypeScript will catch these at compile time
    // @ts-expect-error - wrong type
    processUser({ name: 123 });

    // @ts-expect-error - missing required field
    processUser({ age: 30 });
  });
});
```

---

## Configuration in bunfig.toml

### Complete Test Configuration

```toml
[test]
# Test file patterns
root = "."
prefix = ""
suffix = [".test", ".spec"]
testNamePattern = ""

# Coverage
coverage = true
coverageFormat = ["text", "html", "json"]
coverageThreshold = 80
coverageRoot = "src"
coverageIgnore = ["**/node_modules/**"]

# Test execution
bail = false
timeout = 30000
reportFailures = true

# Reporters
reporters = ["spec"]  # or ["tap", "junit"]

# Output
preloadModules = []
```

### With npm scripts in package.json

```json
{
  "scripts": {
    "test": "bun test",
    "test:watch": "bun test --watch",
    "test:coverage": "bun test --coverage",
    "test:ui": "bun test --coverage --coverage-html",
    "test:single": "bun test tests/unit.test.ts",
    "test:bail": "bun test --bail",
    "test:debug": "bun test --inspect-brk"
  }
}
```

---

## React Component Testing

### Testing React Components

```typescript
import { describe, it, expect } from "bun:test";
import { render, screen } from "bun:test:dom";
import { Button } from "./Button";

describe("Button component", () => {
  it("should render button with text", () => {
    render(<Button label="Click me" />);

    const button = screen.getByRole("button", { name: "Click me" });
    expect(button).toBeDefined();
  });

  it("should call onClick handler", async () => {
    const handleClick = mock();
    render(<Button label="Click" onClick={handleClick} />);

    const button = screen.getByRole("button");
    button.click();

    expect(handleClick.mock.calls.length).toBe(1);
  });

  it("should disable button when disabled prop is true", () => {
    render(<Button label="Disabled" disabled={true} />);

    const button = screen.getByRole("button") as HTMLButtonElement;
    expect(button.disabled).toBe(true);
  });
});
```

---

## Common Testing Patterns

### Arrange-Act-Assert

```typescript
import { describe, it, expect } from "bun:test";
import { calculateTotal } from "./calculator";

describe("calculateTotal", () => {
  it("should sum array of numbers", () => {
    // Arrange - Set up test data
    const items = [
      { price: 10, quantity: 2 },
      { price: 5, quantity: 3 },
    ];

    // Act - Execute functionality
    const total = calculateTotal(items);

    // Assert - Verify results
    expect(total).toBe(35);  // (10*2) + (5*3)
  });
});
```

### Testing Error Conditions

```typescript
import { describe, it, expect } from "bun:test";
import { validateEmail } from "./validators";

describe("validateEmail", () => {
  it("should validate correct email", () => {
    expect(validateEmail("test@example.com")).toBe(true);
  });

  it("should reject invalid emails", () => {
    expect(validateEmail("not-an-email")).toBe(false);
    expect(validateEmail("@example.com")).toBe(false);
    expect(validateEmail("test@")).toBe(false);
  });

  it("should throw on null input", () => {
    expect(() => validateEmail(null as any)).toThrow();
  });
});
```

### Testing Class Methods

```typescript
import { describe, it, expect, beforeEach } from "bun:test";
import { Counter } from "./counter";

describe("Counter class", () => {
  let counter: Counter;

  beforeEach(() => {
    counter = new Counter();
  });

  it("should increment", () => {
    counter.increment();
    expect(counter.value).toBe(1);
  });

  it("should decrement", () => {
    counter.increment();
    counter.decrement();
    expect(counter.value).toBe(0);
  });

  it("should reset to zero", () => {
    counter.increment();
    counter.increment();
    counter.reset();
    expect(counter.value).toBe(0);
  });
});
```

---

## Edge Case Testing

### Common Edge Cases for TypeScript

```typescript
import { describe, it, expect } from "bun:test";
import { processArray } from "./processor";

describe("processArray edge cases", () => {
  it("should handle empty array", () => {
    expect(processArray([])).toEqual([]);
  });

  it("should handle single item", () => {
    expect(processArray([1])).toEqual([1]);
  });

  it("should handle undefined values", () => {
    const result = processArray([1, undefined, 3]);
    expect(result).toContain(1);
    expect(result).toContain(3);
  });

  it("should handle null values", () => {
    const result = processArray([1, null, 3]);
    expect(result.length).toBeLessThanOrEqual(3);
  });

  it("should handle very large numbers", () => {
    const large = Number.MAX_SAFE_INTEGER;
    expect(processArray([large, large])).toBeDefined();
  });

  it("should handle special values", () => {
    expect(processArray([0, -0, NaN])).toBeDefined();
  });
});
```

### Null/Undefined Handling

```typescript
import { describe, it, expect } from "bun:test";
import { getUser } from "./user-service";

describe("Null/undefined handling", () => {
  it("should return null for missing user", async () => {
    const user = await getUser("nonexistent");
    expect(user).toBeNull();
  });

  it("should handle undefined optional fields", async () => {
    const user = await getUser("123");
    if (user) {
      expect(user.middleName).toBeUndefined();
    }
  });

  it("should distinguish null from undefined", () => {
    const nullValue = null;
    const undefinedValue = undefined;

    expect(nullValue).toBeNull();
    expect(undefinedValue).toBeUndefined();
    expect(nullValue).not.toBe(undefinedValue);
  });
});
```

---

## Zero-Warnings Policy

### Treat Warnings as Errors

Running tests should produce zero warnings:

```bash
# Run tests and fail on any warnings
bun test

# If warnings appear, identify and fix them
# Common causes:
# - Deprecated API usage
# - Unhandled promise rejections
# - Memory leaks in tests
# - Resource cleanup issues
```

### Configuration for Warnings

```toml
[test]
# Fail on warnings (if available in your Bun version)
reportFailures = true

# Configure reporters to show warnings
reporters = ["spec"]
```

### Handling Expected Warnings

If a library produces unavoidable warnings:

```typescript
import { describe, it, expect } from "bun:test";

describe("Feature with expected warning", () => {
  it("should work despite library warning", () => {
    // This test runs code that produces a library warning
    // Document why the warning is acceptable
    expect(unsafeLibraryFunction()).toBeDefined();
  });
});
```

---

## Makefile Integration

### Test Targets

```makefile
.PHONY: test test-watch test-coverage test-single test-bail

# Run all tests
test:
	bun test

# Watch mode - rerun on file changes
test-watch:
	bun test --watch

# Run with coverage
test-coverage:
	bun test --coverage

# View HTML coverage report
test-ui:
	bun test --coverage --coverage-html
	@echo "Coverage report: coverage/index.html"

# Run single test file
test-single:
	bun test tests/specific.test.ts

# Fail on first error
test-bail:
	bun test --bail

# Debug tests
test-debug:
	bun test --inspect-brk

# Full test suite with checks
check: test lint type-check
	@echo "All checks passed!"
```

---

## Project Structure Patterns

### Organized Test Structure

```
src/
├── utils/
│   ├── math.ts
│   ├── math.test.ts         # Colocated with source
│   └── string.ts
├── services/
│   ├── api.ts
│   └── api.test.ts
├── __tests__/               # Alternative: centralized tests
│   ├── fixtures/
│   │   ├── users.ts
│   │   └── setup.ts
│   ├── unit/
│   │   └── math.test.ts
│   ├── integration/
│   │   └── api.test.ts
│   └── e2e/
│       └── workflow.test.ts
└── index.ts
```

### Test Fixtures Directory

```
tests/
├── fixtures/
│   ├── users.ts            # Test user data
│   ├── database.ts         # Test database setup
│   ├── api-responses.ts    # Mock API responses
│   └── setup.ts            # Fixture functions
└── helpers/
    ├── assertions.ts       # Custom assertions
    └── mocks.ts           # Mock utilities
```

---

## Dependency Installation

### Adding Test Dependencies

```bash
# Core testing (already built-in with Bun)
# No installation needed - use "bun:test"

# Additional testing utilities (optional)
bun add --dev @types/bun

# React testing (if using React)
bun add --dev jsdom

# HTTP testing utilities
bun add --dev node-fetch @types/node

# Test data generation
bun add --dev faker
```

---

**Note:** For general testing principles and strategies not specific to TypeScript/JavaScript, see the testing-workflow skill.
