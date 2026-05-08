---
name: writing-test-using-vitest
description: Write Vitest unit tests and browser mode component tests for TypeScript projects. Use when asked to write tests, create test files, add test coverage, fix failing tests, test React components with browser mode, or work with Vitest testing patterns. Handles both unit testing with Given-When-Then pattern and React component testing with vitest-browser-react.
---

# Vitest TypeScript Testing

## Core Testing Principles

Follow these fundamental patterns when writing Vitest tests:

**Imports**: Explicitly import all testing functions:

```typescript
import { describe, test, expect, vi, beforeEach, afterEach } from "vitest";
```

**Test Structure**: Use `test()` instead of `it()`. Organize with `describe()` blocks (max 4 levels). Structure tests using the Given-When-Then pattern (setup, execution, assertion) but **do not write Given/When/Then comments in the actual code**:

```typescript
describe("ComponentName", () => {
  describe("method name", () => {
    test("does something specific", () => {
      const input = createTestData();

      const result = methodName(input);

      expect(result).toStrictEqual(expected);
    });
  });
});
```

**Assertions**: Prefer single comprehensive assertions over multiple partial assertions:

```typescript
// ✅ Good - single comprehensive assertion
expect(result).toStrictEqual({ id: 1, name: "test", active: true });

// ❌ Avoid - multiple partial assertions
expect(result.id).toBe(1);
expect(result.name).toBe("test");
expect(result.active).toBe(true);
```

**Snapshots**: Use `toMatchInlineSnapshot()` to verify values should not change unexpectedly:

```typescript
expect(computed).toMatchInlineSnapshot(`
  {
    "key": "value",
  }
`);
```

Update snapshots when values intentionally change:

```bash
vitest --update
```

**File Location**: Place test files next to implementation:

- `render.ts` → `render.test.ts` in same directory

**Prohibited**: Never use `test.skip()`, `test.only()`, or `test.todo()` in test modifications. Tests must always run completely.

## Unit Testing Patterns

### Basic Unit Test Structure

```typescript
import { describe, test, expect } from "vitest";
import { functionToTest } from "./module";

describe("functionToTest", () => {
  test("returns expected result", () => {
    const result = functionToTest("input");
    expect(result).toStrictEqual({ output: "expected" });
  });
});
```

### Async Testing

Use `resolves` and `rejects` for promise assertions:

```typescript
import { describe, test, expect } from "vitest";

describe("async function", () => {
  test("resolves with correct value", async () => {
    await expect(asyncFunction()).resolves.toEqual({ data: "value" });
  });

  test("rejects with error", async () => {
    await expect(failingFunction()).rejects.toThrow("message");
  });
});
```

### Type Narrowing with Discriminated Unions

Use `assert()` to narrow types safely:

```typescript
import { describe, test, expect, assert } from "vitest";

type Result =
  | { type: "success"; data: string }
  | { type: "error"; message: string };

describe("handleResult", () => {
  test("handles success case", () => {
    const result: Result = getResult();

    assert(result.type === "success");

    expect(result.data).toBe("expected");
  });
});
```

**Critical**: Never use conditional assertions without type narrowing. Always use `assert()` for discriminated union branches to enable type narrowing.

### Mocking

**Mocking should be used as a last resort.** Before mocking, consider refactoring the implementation to make it more testable. If the implementation can be changed to be easier to test without mocks, suggest that refactoring instead.

Basic mocking example:

```typescript
import { describe, test, expect, vi } from "vitest";

describe("with mocks", () => {
  test("mocks function call", () => {
    const mockFn = vi.fn();

    mockFn("arg");

    expect(mockFn).toHaveBeenCalledWith("arg");
  });
});
```

## Browser Mode Component Testing

### Setup

Browser mode tests require explicit import configuration:

```typescript
import { describe, test, expect } from "vitest";
import { render } from "vitest-browser-react";
import { page, userEvent } from "vitest/browser";
```

**Critical**: Always use `userEvent` from `vitest/browser` for user interactions, not direct element methods.

### Basic Component Test

```typescript
import { describe, test, expect } from "vitest";
import { render } from "vitest-browser-react";
import { page } from "vitest/browser";
import { UserGreeting } from "./UserGreeting";

describe("UserGreeting", () => {
  test("renders greeting with user name", async () => {
    await render(<UserGreeting name="Alice" />);

    await expect.element(page.getByText("Hello, Alice!")).toBeInTheDocument();
  });

  test("renders default greeting when no name provided", async () => {
    await render(<UserGreeting />);

    await expect.element(page.getByText("Hello, Guest!")).toBeInTheDocument();
  });
});
```

### Component Interaction Testing

```typescript
import { describe, test, expect } from "vitest";
import { render } from "vitest-browser-react";
import { page, userEvent } from "vitest/browser";

describe("Counter", () => {
  test("increments count on button click", async () => {
    await render(<Counter initialCount={0} />);
    await expect.element(page.getByText("Count: 0")).toBeInTheDocument();

    await userEvent.click(page.getByRole("button", { name: "Increment" }));

    await expect.element(page.getByText("Count: 1")).toBeInTheDocument();
  });
});
```

### Form Testing

```typescript
import { describe, test, expect } from "vitest";
import { render } from "vitest-browser-react";
import { page, userEvent } from "vitest/browser";

describe("LoginForm", () => {
  test("submits with user input", async () => {
    await render(<LoginForm />);

    await userEvent.fill(page.getByLabelText("Username"), "testuser");
    await userEvent.fill(page.getByLabelText("Password"), "password123");
    await userEvent.click(page.getByRole("button", { name: "Submit" }));

    await expect
      .element(page.getByText("Welcome testuser"))
      .toBeInTheDocument();
  });
});
```

### Testing with Context Providers

```typescript
import { describe, test, expect } from "vitest";
import { render } from "vitest-browser-react";
import { page } from "vitest/browser";
import { ThemeProvider } from "./ThemeProvider";

describe("ThemedButton", () => {
  test("renders with theme", async () => {
    await render(<ThemedButton>Click Me</ThemedButton>, {
      wrapper: ({ children }) => (
        <ThemeProvider theme="dark">{children}</ThemeProvider>
      ),
    });

    await expect
      .element(page.getByRole("button"))
      .toHaveAttribute("data-theme", "dark");
  });
});
```

### Hook Testing

```typescript
import { describe, test, expect } from "vitest";
import { renderHook } from "vitest-browser-react";

describe("useCounter", () => {
  test("increments counter", async () => {
    const { result, act } = await renderHook(() => useCounter());

    expect(result.current.count).toBe(0);

    await act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });
});
```

## Common Patterns Reference

### Hierarchical Test Organization

```typescript
import { describe, test, expect } from "vitest";

describe("Calculator", () => {
  describe("add", () => {
    test("adds two positive numbers", () => {
      expect(add(2, 3)).toBe(5);
    });

    test("adds negative numbers", () => {
      expect(add(-2, -3)).toBe(-5);
    });
  });

  describe("subtract", () => {
    test("subtracts numbers", () => {
      expect(subtract(5, 3)).toBe(2);
    });
  });
});
```

### Test Fixtures with test.extend

Prefer `test.extend` over `beforeEach`/`afterEach` for setup and teardown:

```typescript
import { test as base, expect } from "vitest";

interface Fixtures {
  testData: TestData;
}

const test = base.extend<Fixtures>({
  testData: async ({}, use) => {
    const data = createTestData();

    await use(data);

    cleanup(data);
  },
});

describe("with fixtures", () => {
  test("uses test data", ({ testData }) => {
    expect(testData).toBeDefined();
  });
});
```

## Test Execution

**Prefer npm scripts over direct CLI execution.** Vitest CLI runs in interactive mode by default, which is problematic for automated execution.

When running tests directly via CLI, always use the `--run` option to disable interactive mode:

```bash
vitest --run
```

For CI/CD or automated workflows, use npm scripts defined in package.json:

```bash
npm test
# or
npm run test
```

## Lint Error Resolution

If test code produces lint errors, resolve them before proceeding. Common fixes:

- Add missing imports
- Fix type errors
- Remove unused variables
- Correct assertion patterns
