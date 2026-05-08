---
name: vitest
# prettier-ignore
description: Use when writing or configuring Vitest tests - assertions, mocking, coverage, and workspace-aware testing for TypeScript projects
---

# Vitest Testing Framework

## Quick Start

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('Calculator', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('adds numbers correctly', () => {
    expect(add(2, 3)).toBe(5);
  });

  it('handles async operations', async () => {
    const result = await fetchData();
    expect(result).toMatchObject({ id: 1 });
  });

  it('mocks dependencies', () => {
    const mockFn = vi.fn().mockReturnValue(42);
    expect(mockFn()).toBe(42);
    expect(mockFn).toHaveBeenCalledOnce();
  });
});
```

## Core Assertions

| Assertion | Purpose |
|-----------|---------|
| `toBe(value)` | Strict equality (===) |
| `toEqual(value)` | Deep equality |
| `toMatchObject(obj)` | Partial object match |
| `toContain(item)` | Array/string contains |
| `toThrow(error?)` | Function throws |
| `toMatchSnapshot()` | Snapshot testing |
| `toHaveBeenCalledWith()` | Mock call verification |

## Mocking

```typescript
// Mock module
vi.mock('./api', () => ({ fetchUser: vi.fn() }));

// Spy on method
const spy = vi.spyOn(object, 'method');

// Mock implementation
mockFn.mockImplementation((x) => x * 2);
mockFn.mockResolvedValue({ data: [] });
mockFn.mockRejectedValue(new Error('fail'));
```

## Configuration (vitest.config.ts)

```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['**/*.test.ts'],
    coverage: { provider: 'v8', reporter: ['text', 'html'] }
  }
});
```

## CLI Commands

- `vitest` - Watch mode
- `vitest run` - Single run
- `vitest run --coverage` - With coverage
- `vitest --workspace` - Monorepo mode
