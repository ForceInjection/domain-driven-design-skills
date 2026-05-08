---
name: testing-hooks
description: Teaches testing custom hooks in React 19 using renderHook from React Testing Library. Use when testing custom hooks or hook behavior.
allowed-tools: Read, Write, Edit
version: 1.0.0
---

# Testing Custom Hooks

## Basic Hook Testing

For hook testing with Vitest fixtures and describe/test patterns, use vitest-4/skills/writing-vitest-tests which covers test structure and fixture patterns.

```javascript
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

test('useCounter increments', () => {
  const { result } = renderHook(() => useCounter());

  expect(result.current.count).toBe(0);

  act(() => {
    result.current.increment();
  });

  expect(result.current.count).toBe(1);
});
```

## Testing Hooks with Props

```javascript
import { renderHook } from '@testing-library/react';
import { useUser } from './useUser';

test('useUser fetches user data', async () => {
  const { result } = renderHook(() => useUser('123'));

  expect(result.current.loading).toBe(true);

  await waitFor(() => {
    expect(result.current.loading).toBe(false);
  });

  expect(result.current.user).toEqual({ id: '123', name: 'Alice' });
});
```

## Testing Hooks with Context

```javascript
import { renderHook } from '@testing-library/react';
import { ThemeProvider } from './ThemeContext';
import { useTheme } from './useTheme';

test('useTheme returns theme from context', () => {
  const wrapper = ({ children }) => (
    <ThemeProvider value="dark">{children}</ThemeProvider>
  );

  const { result } = renderHook(() => useTheme(), { wrapper });

  expect(result.current.theme).toBe('dark');
});
```

For comprehensive hook testing patterns, see: React Testing Library documentation.

## References

- [@vitest-4/skills/writing-vitest-tests](/vitest-4/skills/writing-vitest-tests/SKILL.md) - Fixture patterns and setup
