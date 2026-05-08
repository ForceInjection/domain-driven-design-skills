---
name: writing-vitest-tests
description: Write Vitest tests with describe/test blocks, expect assertions, vi mocking, async testing, and parameterized tests. Use when creating or modifying test files.
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# Writing Vitest Tests

This skill teaches test structure and patterns for writing effective Vitest tests.

## Quick Start

### Basic Test

```typescript
import { test, expect } from 'vitest';

test('adds numbers correctly', () => {
  expect(1 + 2).toBe(3);
});
```

### Test Suite

```typescript
import { describe, test, expect } from 'vitest';

describe('Math utilities', () => {
  test('adds numbers', () => {
    expect(1 + 2).toBe(3);
  });

  test('subtracts numbers', () => {
    expect(5 - 2).toBe(3);
  });
});
```

For complete test organization patterns, see [references/test-organization.md](./references/test-organization.md)

## Essential Assertions

### Basic Matchers

```typescript
expect(value).toBe(expected);
expect(value).toEqual(expected);
expect(value).toBeTruthy();
expect(value).toBeFalsy();
```

### Arrays and Objects

```typescript
expect(array).toContain(item);
expect(array).toHaveLength(3);
expect(object).toHaveProperty('key');
expect(object).toMatchObject({ key: 'value' });
```

### Strings and Numbers

```typescript
expect(string).toMatch(/pattern/);
expect(number).toBeGreaterThan(3);
expect(number).toBeCloseTo(0.3, 5);
```

For complete assertion API, see [references/assertions.md](./references/assertions.md)

## Mocking with vi

### Mock Functions

```typescript
import { vi, test, expect } from 'vitest';

test('calls callback', () => {
  const callback = vi.fn();

  callback('arg1', 'arg2');

  expect(callback).toHaveBeenCalledWith('arg1', 'arg2');
  expect(callback).toHaveBeenCalledTimes(1);
});
```

### Mock Return Values

```typescript
const mockFn = vi.fn();
mockFn.mockReturnValue('result');

expect(mockFn()).toBe('result');
```

### Mock Implementation

```typescript
const mockFn = vi.fn();
mockFn.mockImplementation((a, b) => a + b);

expect(mockFn(1, 2)).toBe(3);
```

For testing runtime type validation with Zod, use the using-runtime-checks skill for patterns on schema validation, error handling, and type inference.

### Mock Promises

```typescript
const mockFn = vi.fn();
mockFn.mockResolvedValue('data');

const result = await mockFn();
expect(result).toBe('data');
```

For testing code that validates external data with Zod, use the validating-external-data skill for patterns on API response validation, error handling, and type-safe validation flows.

For complete mocking patterns, see [references/mocking.md](./references/mocking.md)

## Module Mocking

### Basic Module Mock

```typescript
vi.mock('./module', () => ({
  method: vi.fn(),
  constant: 'mocked',
}));
```

### Partial Module Mock

```typescript
vi.mock(import('./module'), async (importOriginal) => {
  const mod = await importOriginal();
  return {
    ...mod,
    specificMethod: vi.fn(),
  };
});
```

For testing Zod validation of database inputs in Vitest, use the validating-query-inputs skill for patterns on Zod schema validation before Prisma operations.

## Async Testing

### Async/Await

```typescript
test('fetches data', async () => {
  const data = await fetchData();
  expect(data).toBeDefined();
});
```

### Promise Assertions

```typescript
test('promise resolves', async () => {
  await expect(fetchData()).resolves.toBe('data');
});

test('promise rejects', async () => {
  await expect(fetchBadData()).rejects.toThrow('error');
});
```

## Parameterized Tests

### test.each with Arrays

```typescript
test.each([
  [1, 1, 2],
  [1, 2, 3],
  [2, 1, 3],
])('add(%i, %i) -> %i', (a, b, expected) => {
  expect(a + b).toBe(expected);
});
```

### test.each with Objects

```typescript
test.each([
  { a: 1, b: 1, expected: 2 },
  { a: 1, b: 2, expected: 3 },
  { a: 2, b: 1, expected: 3 },
])('$a + $b should equal $expected', ({ a, b, expected }) => {
  expect(a + b).toBe(expected);
});
```

For testing Zod schema validation in Vitest, use the testing-zod-schemas skill for patterns testing validation logic, error messages, and transformations.

## Lifecycle Hooks

```typescript
import { describe, test, beforeEach, afterEach, beforeAll, afterAll } from 'vitest';

describe('User service', () => {
  beforeAll(() => {
  });

  afterAll(() => {
  });

  beforeEach(() => {
  });

  afterEach(() => {
  });

  test('creates user', () => {
  });
});
```

## Test Modifiers

```typescript
test.skip('skipped test', () => {});
test.only('run only this test', () => {});
test.todo('implement later');
test.fails('should fail', () => {});
test.concurrent('runs in parallel', async () => {});
```

For testing Server Actions in isolation with Vitest, use the testing-server-actions skill for patterns on mocking authentication, database, and form data.

For testing form validation in React components with Vitest, use the validating-forms skill for patterns on form validation, useActionState, and error handling.

## Timer Mocking

### Fake Timers

```typescript
import { vi } from 'vitest';

vi.useFakeTimers();

const callback = vi.fn();
setTimeout(callback, 1000);

vi.advanceTimersByTime(1000);
expect(callback).toHaveBeenCalled();

vi.useRealTimers();
```

### Date Mocking

```typescript
vi.setSystemTime(new Date(2022, 0, 1));

expect(Date.now()).toBe(new Date(2022, 0, 1).getTime());

vi.useRealTimers();
```

## Snapshot Testing

```typescript
test('matches snapshot', () => {
  const result = generateOutput();
  expect(result).toMatchSnapshot();
});
```

**Update snapshots:** `vitest -u`

## Error Testing

```typescript
test('throws error', () => {
  expect(() => {
    throw new Error('failed');
  }).toThrow('failed');
});

test('async throws', async () => {
  await expect(async () => {
    throw new Error('failed');
  }).rejects.toThrow('failed');
});
```

## Fixtures

```typescript
import { test as baseTest } from 'vitest';

const test = baseTest.extend({
  todos: async ({}, use) => {
    const todos = [];
    await use(todos);
    todos.length = 0;
  },
});

test('adds item', ({ todos }) => {
  todos.push('item');
  expect(todos).toHaveLength(1);
});
```

For testing custom React hooks with Vitest, use the testing-hooks skill for renderHook patterns and hook-specific assertions.

## Mock Cleanup

### Per-Test Cleanup

```typescript
import { afterEach, vi } from 'vitest';

afterEach(() => {
  vi.restoreAllMocks();
});
```

### Config-Based Cleanup

```typescript
export default defineConfig({
  test: {
    restoreMocks: true,
    clearMocks: true,
  },
});
```

## Component Testing

For testing React 19 components with Vitest browser mode, use the testing-components skill for patterns using @testing-library/react and handling useActionState, Server Actions, and React 19 hooks.

## Best Practices

1. **One assertion per test**: Keep tests focused
2. **Descriptive test names**: Explain what is being tested
3. **AAA pattern**: Arrange, Act, Assert
4. **Clean up mocks**: Restore after each test
5. **Test behavior, not implementation**: Focus on public API
6. **Avoid test interdependence**: Tests should run independently
7. **Use fixtures for shared setup**: Reduce duplication

## Common Mistakes

1. **Not awaiting async operations**: Use `async/await`
2. **Not cleaning up mocks**: Use `afterEach` or config options
3. **Testing implementation details**: Test public behavior
4. **Overly complex tests**: Break into smaller tests
5. **Not using parameterized tests**: Reduce duplication

## References

For detailed testing patterns:
- [Test Organization](./references/test-organization.md) - Structure, hooks, fixtures, patterns
- [Assertions](./references/assertions.md) - Complete matcher API reference
- [Mocking](./references/mocking.md) - vi, modules, timers, globals

For configuration options, see `@vitest-4/skills/configuring-vitest-4`

For browser testing, see `@vitest-4/skills/using-browser-mode`

For complete API reference, see `@vitest-4/knowledge/vitest-4-comprehensive.md`
