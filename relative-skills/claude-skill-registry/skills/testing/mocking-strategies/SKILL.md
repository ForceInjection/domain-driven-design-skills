---
name: mocking-strategies
description: Test mocking strategies with Vitest. Use when mocking dependencies in tests.
---

# Mocking Strategies Skill

This skill covers mocking strategies for Vitest testing.

## When to Use

Use this skill when:
- Isolating units under test
- Mocking external dependencies
- Creating test doubles
- Stubbing API responses

## Core Principle

**MOCK BOUNDARIES, NOT INTERNALS** - Mock external dependencies (APIs, databases) not internal implementation.

## vi.fn() - Function Mocks

### Basic Mock Function

```typescript
import { vi, describe, it, expect } from 'vitest';

const mockFn = vi.fn();

// Call the mock
mockFn('arg1', 'arg2');

// Assertions
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
expect(mockFn).toHaveBeenCalledTimes(1);
```

### Mock Return Values

```typescript
const mockFn = vi.fn();

// Return specific value
mockFn.mockReturnValue('result');

// Return different values on subsequent calls
mockFn
  .mockReturnValueOnce('first')
  .mockReturnValueOnce('second')
  .mockReturnValue('default');

// Return resolved promise
mockFn.mockResolvedValue({ data: 'value' });

// Return rejected promise
mockFn.mockRejectedValue(new Error('Failed'));
```

### Mock Implementation

```typescript
const mockFn = vi.fn().mockImplementation((a: number, b: number) => a + b);

expect(mockFn(1, 2)).toBe(3);

// One-time implementation
mockFn.mockImplementationOnce(() => 'special');
```

## vi.spyOn() - Method Spies

### Spy on Object Methods

```typescript
import { vi, describe, it, expect, afterEach } from 'vitest';

const calculator = {
  add(a: number, b: number): number {
    return a + b;
  },
};

describe('calculator', () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('should spy on add method', () => {
    const spy = vi.spyOn(calculator, 'add');

    calculator.add(1, 2);

    expect(spy).toHaveBeenCalledWith(1, 2);
    expect(spy).toHaveReturnedWith(3);
  });

  it('should mock return value', () => {
    vi.spyOn(calculator, 'add').mockReturnValue(100);

    expect(calculator.add(1, 2)).toBe(100);
  });
});
```

### Spy on Class Methods

```typescript
class UserService {
  async getUser(id: string): Promise<User> {
    // Real implementation
  }
}

it('should spy on class method', async () => {
  const service = new UserService();
  const spy = vi.spyOn(service, 'getUser').mockResolvedValue({
    id: '123',
    name: 'Test User',
  });

  const user = await service.getUser('123');

  expect(spy).toHaveBeenCalledWith('123');
  expect(user.name).toBe('Test User');
});
```

## vi.mock() - Module Mocking

### Auto-Mock Module

```typescript
import { vi, describe, it, expect } from 'vitest';
import { fetchUser } from './api';

// Mock entire module
vi.mock('./api');

describe('with mocked api', () => {
  it('should use mocked function', async () => {
    // fetchUser is now a mock
    vi.mocked(fetchUser).mockResolvedValue({ id: '1', name: 'Mock User' });

    const user = await fetchUser('1');
    expect(user.name).toBe('Mock User');
  });
});
```

### Manual Mock Implementation

```typescript
vi.mock('./api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: '1', name: 'Mock User' }),
  fetchPosts: vi.fn().mockResolvedValue([]),
}));
```

### Partial Mock

```typescript
vi.mock('./utils', async (importOriginal) => {
  const actual = await importOriginal<typeof import('./utils')>();
  return {
    ...actual,
    // Only mock specific exports
    formatDate: vi.fn().mockReturnValue('mocked date'),
  };
});
```

## Mocking External Modules

### Mock Node.js Modules

```typescript
import { vi } from 'vitest';
import fs from 'node:fs';

vi.mock('node:fs');

it('should mock fs.readFile', async () => {
  vi.mocked(fs.readFile).mockImplementation((path, callback) => {
    callback(null, 'mocked content');
  });
});
```

### Mock npm Packages

```typescript
vi.mock('axios', () => ({
  default: {
    get: vi.fn().mockResolvedValue({ data: { id: 1 } }),
    post: vi.fn().mockResolvedValue({ data: { success: true } }),
  },
}));
```

## Timer Mocks

### Mock setTimeout/setInterval

```typescript
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest';

describe('timer tests', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('should advance timers', () => {
    const callback = vi.fn();
    setTimeout(callback, 1000);

    expect(callback).not.toHaveBeenCalled();

    vi.advanceTimersByTime(1000);

    expect(callback).toHaveBeenCalled();
  });

  it('should run all timers', () => {
    const callback = vi.fn();
    setTimeout(callback, 1000);
    setTimeout(callback, 2000);

    vi.runAllTimers();

    expect(callback).toHaveBeenCalledTimes(2);
  });
});
```

### Mock Date

```typescript
beforeEach(() => {
  vi.useFakeTimers();
  vi.setSystemTime(new Date('2024-01-01'));
});

afterEach(() => {
  vi.useRealTimers();
});

it('should use mocked date', () => {
  expect(new Date().toISOString()).toBe('2024-01-01T00:00:00.000Z');
});
```

## Mock Assertions

```typescript
const mockFn = vi.fn();

// Call count
expect(mockFn).toHaveBeenCalledTimes(3);
expect(mockFn).toHaveBeenCalledOnce();

// Call arguments
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
expect(mockFn).toHaveBeenLastCalledWith('last', 'args');
expect(mockFn).toHaveBeenNthCalledWith(2, 'second', 'call');

// Return values
expect(mockFn).toHaveReturned();
expect(mockFn).toHaveReturnedWith('value');
expect(mockFn).toHaveLastReturnedWith('last');

// Access call info
expect(mockFn.mock.calls[0]).toEqual(['first', 'call']);
expect(mockFn.mock.results[0].value).toBe('result');
```

## Reset and Restore

```typescript
const mockFn = vi.fn();

// Clear call history (keeps implementation)
mockFn.mockClear();
// or
vi.clearAllMocks();

// Reset to initial state (clears implementation)
mockFn.mockReset();
// or
vi.resetAllMocks();

// Restore original implementation (for spies)
mockFn.mockRestore();
// or
vi.restoreAllMocks();
```

## Test Doubles Patterns

### Stub - Provides Canned Answers

```typescript
const userRepository = {
  findById: vi.fn().mockResolvedValue({ id: '1', name: 'Test' }),
};
```

### Spy - Records Calls

```typescript
const analytics = {
  track: vi.fn(),
};

// Act
performAction();

// Assert calls were made
expect(analytics.track).toHaveBeenCalledWith('action', { type: 'click' });
```

### Fake - Working Implementation

```typescript
class FakeUserRepository implements UserRepository {
  private users = new Map<string, User>();

  async save(user: User): Promise<void> {
    this.users.set(user.id, user);
  }

  async findById(id: string): Promise<User | null> {
    return this.users.get(id) ?? null;
  }
}
```

## Best Practices Summary

1. **Mock at boundaries** - APIs, databases, file system
2. **Don't mock what you own** - Test your own code directly
3. **Clear mocks between tests** - Use beforeEach/afterEach
4. **Use vi.mocked() for type safety** - TypeScript-aware mocking
5. **Prefer spies over mocks** - When you need real behavior
6. **Keep mocks simple** - Complex mocks indicate design issues
7. **Restore after tests** - Prevent test pollution

## Code Review Checklist

- [ ] Mocks cleared between tests
- [ ] Only external dependencies mocked
- [ ] vi.mocked() used for type safety
- [ ] Spies restored after use
- [ ] Mock assertions verify behavior
- [ ] No unnecessary mocking
- [ ] Fake implementations for complex scenarios
