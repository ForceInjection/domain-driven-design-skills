---
name: component-testing-mobile
description: Jest and React Native Testing Library patterns. Use when writing component tests.
---

# Component Testing Mobile Skill

This skill covers testing React Native components with Jest and RNTL.

## When to Use

Use this skill when:
- Writing unit tests for components
- Testing hooks and utilities
- Testing component interactions
- Mocking native modules

## Core Principle

**TEST BEHAVIOR** - Test what users see and do, not implementation details.

## Installation

```bash
npm install --save-dev @testing-library/react-native jest @types/jest
```

## Jest Configuration

```javascript
// jest.config.js
module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEnv: ['@testing-library/react-native/extend-expect'],
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?)|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg)',
  ],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
  },
  collectCoverageFrom: [
    '**/*.{ts,tsx}',
    '!**/node_modules/**',
    '!**/coverage/**',
    '!**/*.d.ts',
  ],
};
```

## Basic Component Test

```typescript
// components/__tests__/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react-native';
import { Button } from '../Button';

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Press me</Button>);

    expect(screen.getByText('Press me')).toBeOnTheScreen();
  });

  it('calls onPress when pressed', () => {
    const onPress = jest.fn();
    render(<Button onPress={onPress}>Press me</Button>);

    fireEvent.press(screen.getByText('Press me'));

    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it('is disabled when disabled prop is true', () => {
    const onPress = jest.fn();
    render(<Button onPress={onPress} disabled>Press me</Button>);

    fireEvent.press(screen.getByText('Press me'));

    expect(onPress).not.toHaveBeenCalled();
  });
});
```

## Testing with Accessibility

```typescript
import { render, screen } from '@testing-library/react-native';

describe('AccessibleButton', () => {
  it('has correct accessibility role', () => {
    render(<Button accessibilityRole="button">Submit</Button>);

    expect(screen.getByRole('button')).toBeOnTheScreen();
  });

  it('has accessibility label', () => {
    render(
      <Button accessibilityLabel="Submit form">
        <Icon name="check" />
      </Button>
    );

    expect(screen.getByLabelText('Submit form')).toBeOnTheScreen();
  });
});
```

## Testing Async Operations

```typescript
import { render, screen, waitFor } from '@testing-library/react-native';

describe('UserProfile', () => {
  it('shows loading state initially', () => {
    render(<UserProfile userId="123" />);

    expect(screen.getByText('Loading...')).toBeOnTheScreen();
  });

  it('shows user data after loading', async () => {
    render(<UserProfile userId="123" />);

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeOnTheScreen();
    });
  });

  it('shows error on fetch failure', async () => {
    server.use(
      rest.get('/api/users/123', (req, res, ctx) => {
        return res(ctx.status(500));
      })
    );

    render(<UserProfile userId="123" />);

    await waitFor(() => {
      expect(screen.getByText('Error loading user')).toBeOnTheScreen();
    });
  });
});
```

## Testing Forms

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react-native';
import { LoginForm } from '../LoginForm';

describe('LoginForm', () => {
  it('shows validation errors for empty submission', async () => {
    render(<LoginForm />);

    fireEvent.press(screen.getByText('Sign In'));

    await waitFor(() => {
      expect(screen.getByText('Email is required')).toBeOnTheScreen();
    });
  });

  it('submits with valid data', async () => {
    const onSubmit = jest.fn();
    render(<LoginForm onSubmit={onSubmit} />);

    fireEvent.changeText(
      screen.getByPlaceholderText('Email'),
      'test@example.com'
    );
    fireEvent.changeText(
      screen.getByPlaceholderText('Password'),
      'password123'
    );
    fireEvent.press(screen.getByText('Sign In'));

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });
  });
});
```

## Testing Lists

```typescript
import { render, screen, fireEvent } from '@testing-library/react-native';

describe('TodoList', () => {
  const items = [
    { id: '1', text: 'Buy groceries' },
    { id: '2', text: 'Walk the dog' },
  ];

  it('renders all items', () => {
    render(<TodoList items={items} />);

    expect(screen.getByText('Buy groceries')).toBeOnTheScreen();
    expect(screen.getByText('Walk the dog')).toBeOnTheScreen();
  });

  it('calls onItemPress with correct item', () => {
    const onItemPress = jest.fn();
    render(<TodoList items={items} onItemPress={onItemPress} />);

    fireEvent.press(screen.getByText('Buy groceries'));

    expect(onItemPress).toHaveBeenCalledWith(items[0]);
  });
});
```

## Mocking Native Modules

```typescript
// jest.setup.js
jest.mock('expo-secure-store', () => ({
  getItemAsync: jest.fn(),
  setItemAsync: jest.fn(),
  deleteItemAsync: jest.fn(),
}));

jest.mock('expo-router', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  }),
  useLocalSearchParams: () => ({}),
}));

jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock')
);
```

## Testing Hooks

```typescript
import { renderHook, act } from '@testing-library/react-native';
import { useCounter } from '../useCounter';

describe('useCounter', () => {
  it('starts with initial value', () => {
    const { result } = renderHook(() => useCounter(10));

    expect(result.current.count).toBe(10);
  });

  it('increments counter', () => {
    const { result } = renderHook(() => useCounter(0));

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });
});
```

## Testing with Providers

```typescript
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render } from '@testing-library/react-native';

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  });

  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}

describe('UserList', () => {
  it('fetches and displays users', async () => {
    render(<UserList />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeOnTheScreen();
    });
  });
});
```

## Testing Zustand Stores

```typescript
import { useAuthStore } from '../authStore';

describe('authStore', () => {
  beforeEach(() => {
    useAuthStore.setState({
      user: null,
      token: null,
      isAuthenticated: false,
    });
  });

  it('sets user on login', async () => {
    await useAuthStore.getState().login('test@test.com', 'password');

    expect(useAuthStore.getState().isAuthenticated).toBe(true);
    expect(useAuthStore.getState().user).toBeDefined();
  });

  it('clears state on logout', async () => {
    useAuthStore.setState({
      user: { id: '1', email: 'test@test.com' },
      isAuthenticated: true,
    });

    await useAuthStore.getState().logout();

    expect(useAuthStore.getState().user).toBeNull();
    expect(useAuthStore.getState().isAuthenticated).toBe(false);
  });
});
```

## Common Matchers

```typescript
// Element presence
expect(element).toBeOnTheScreen();
expect(element).not.toBeOnTheScreen();

// Text content
expect(element).toHaveTextContent('Hello');

// Accessibility
expect(element).toBeEnabled();
expect(element).toBeDisabled();
expect(element).toHaveAccessibilityValue({ text: '50%' });

// Style (with jest-native)
expect(element).toHaveStyle({ backgroundColor: 'red' });
```

## Running Tests

```bash
# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run specific file
npm test -- Button.test.tsx

# Watch mode
npm test -- --watch
```

## Notes

- Use `screen` for queries instead of destructuring from render
- Prefer `getByRole` and `getByLabelText` for accessibility
- Use `waitFor` for async operations
- Mock native modules in setup file
- Test behavior, not implementation
- Keep tests focused and isolated
