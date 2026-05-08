---
name: react-native-testing
description: Generate and write tests for React Native applications using React Native Testing Library (RNTL), Jest, and userEvent. Use this skill when the user asks to write tests, create test files, add unit tests, add component tests, or generate test suites for React Native or Expo projects. Also use when working with .test.tsx files, jest.config.js, or when the user mentions testing React Native components, screens, hooks, or forms. Covers getByRole, getByText, getByLabelText queries, userEvent.press, userEvent.type interactions, waitFor, findBy async patterns, and toBeOnTheScreen matchers.
---

# React Native Testing

Complete toolkit for testing React Native applications with React Native Testing Library (RNTL), Jest, and modern testing best practices.

## Quick Start

### Main Capabilities

This skill provides three core capabilities through automated scripts:

```bash
# Script 1: Component Test Generator
node scripts/component-test-generator.js [component-path] [options]

# Script 2: Test Coverage Analyzer
node scripts/coverage-analyzer.js [project-path] [options]

# Script 3: Test Suite Scaffolder
node scripts/test-suite-scaffolder.js [project-path] [options]
```

## Core Concepts

### Query Priority (Most Accessible First)

React Native Testing Library promotes testing from the user's perspective. Use queries in this order:

1. **`*ByRole`** - Best for accessibility (buttons, headings, switches)
2. **`*ByLabelText`** - For form inputs with labels
3. **`*ByPlaceholderText`** - For inputs with placeholders
4. **`*ByText`** - For visible text content
5. **`*ByDisplayValue`** - For current input values
6. **`*ByHintText`** - For accessibility hints
7. **`*ByTestId`** - Last resort escape hatch

### Query Variants

| Variant | Single | Multiple | Use Case |
|---------|--------|----------|----------|
| `getBy*` | `getByText` | `getAllByText` | Element MUST exist (sync) |
| `queryBy*` | `queryByText` | `queryAllByText` | Element may NOT exist |
| `findBy*` | `findByText` | `findAllByText` | Element appears ASYNC |

**Decision Guide:**
- `getBy*`: "I know this element exists right now"
- `queryBy*`: "This element might not exist, and that's okay"
- `findBy*`: "This element will exist soon (after async operation)"

## Core Testing Patterns

### 1. Basic Component Testing

```typescript
import { render, screen } from '@testing-library/react-native';

describe('MyComponent', () => {
  it('renders correctly', () => {
    render(<MyComponent />);

    // Use semantic queries for accessibility
    expect(screen.getByRole('header', { name: 'Welcome' })).toBeOnTheScreen();
    expect(screen.getByText('Hello, World!')).toBeOnTheScreen();
  });

  it('renders with props', () => {
    render(<MyComponent name="John" />);

    expect(screen.getByText('Hello, John!')).toBeOnTheScreen();
  });
});
```

### 2. User Interaction Testing

```typescript
import { render, screen, userEvent } from '@testing-library/react-native';

test('user can interact with form', async () => {
  const user = userEvent.setup();
  render(<LoginForm />);

  // Type into inputs using labels (accessible)
  await user.type(screen.getByLabelText('Username'), 'admin');
  await user.type(screen.getByLabelText('Password'), 'password123');

  // Press buttons using role and name
  await user.press(screen.getByRole('button', { name: 'Sign In' }));

  // Wait for async result with findBy*
  expect(await screen.findByRole('header', { name: 'Welcome admin!' })).toBeOnTheScreen();
});
```

### 3. Async Operations Testing

```typescript
import { render, screen, waitFor, waitForElementToBeRemoved } from '@testing-library/react-native';

test('handles async data loading', async () => {
  render(<DataComponent />);

  // Wait for loading to finish
  await waitForElementToBeRemoved(() => screen.getByText('Loading...'));

  // Assert async content appeared
  expect(await screen.findByText('Data loaded!')).toBeOnTheScreen();
});

test('handles async with waitFor', async () => {
  render(<AsyncComponent />);

  await waitFor(() => {
    expect(screen.getByText('Ready')).toBeOnTheScreen();
  });
});
```

### 4. Testing Element Absence

```typescript
test('element is not rendered', () => {
  render(<ConditionalComponent showExtra={false} />);

  // Use queryBy* to check absence (doesn't throw)
  expect(screen.queryByText('Extra Content')).not.toBeOnTheScreen();

  // queryBy* returns null when not found
  expect(screen.queryByTestId('hidden-element')).toBeNull();
});
```

### 5. Testing Form Inputs

```typescript
test('form input interactions', async () => {
  const user = userEvent.setup();
  render(<FormComponent />);

  const input = screen.getByLabelText('Email');

  // Type into input
  await user.type(input, 'test@example.com');

  // Assert display value
  expect(input).toHaveDisplayValue('test@example.com');

  // Clear and type new value
  await user.clear(input);
  await user.type(input, 'new@example.com');
});
```

### 6. Testing Lists and Multiple Elements

```typescript
test('renders list items', () => {
  render(<ItemList items={['Item 1', 'Item 2', 'Item 3']} />);

  // Get all matching elements
  const items = screen.getAllByRole('listitem');
  expect(items).toHaveLength(3);

  // Test specific items
  expect(screen.getByText('Item 1')).toBeOnTheScreen();
  expect(screen.getByText('Item 2')).toBeOnTheScreen();
});
```

## Jest Matchers Reference

### Element Presence

```typescript
// Element is rendered
expect(element).toBeOnTheScreen();

// Element is NOT rendered
expect(element).not.toBeOnTheScreen();
```

### Text Content

```typescript
// Exact text match
expect(element).toHaveTextContent('Hello World');

// Regex match (case-insensitive)
expect(element).toHaveTextContent(/hello/i);

// Partial match
expect(element).toHaveTextContent('Hello', { exact: false });
```

### Form Values

```typescript
// Input display value
expect(input).toHaveDisplayValue('expected value');

// Accessibility value (sliders, progress)
expect(slider).toHaveAccessibilityValue({ now: 50, min: 0, max: 100 });
```

### Element Properties

```typescript
// Element is enabled/disabled
expect(button).toBeEnabled();
expect(button).toBeDisabled();

// Element is visible
expect(element).toBeVisible();

// Element has style
expect(element).toHaveStyle({ backgroundColor: 'red' });

// Element contains another element
expect(parent).toContainElement(child);

// Element is empty (no children)
expect(container).toBeEmptyElement();
```

### Accessibility Properties

```typescript
// Has accessibility state
expect(checkbox).toHaveAccessibilityState({ checked: true });

// Is busy
expect(element).toBeBusy();

// Is expanded/collapsed
expect(accordion).toBeExpanded();
expect(accordion).toBeCollapsed();

// Is selected
expect(tab).toBeSelected();
```

## User Event Methods

### Setup and Basic Usage

```typescript
import { userEvent } from '@testing-library/react-native';

test('user events', async () => {
  const user = userEvent.setup();
  render(<Component />);

  // All user events are async!
});
```

### Available Methods

```typescript
// Press (tap)
await user.press(element);

// Long press
await user.longPress(element, { duration: 500 });

// Type text
await user.type(input, 'Hello World');

// Clear input
await user.clear(input);

// Scroll
await user.scrollTo(scrollView, { y: 100 });

// Focus/Blur
await user.focus(input);
await user.blur(input);
```

## Testing Patterns by Component Type

### 1. Navigation Components

```typescript
test('navigation flow', async () => {
  const user = userEvent.setup();
  render(<App />);

  // Navigate to screen
  await user.press(screen.getByRole('button', { name: 'Go to Details' }));

  // Assert new screen content
  expect(await screen.findByRole('header', { name: 'Details' })).toBeOnTheScreen();
});
```

### 2. Modal/Dialog Components

```typescript
test('modal opens and closes', async () => {
  const user = userEvent.setup();
  render(<ModalComponent />);

  // Open modal
  await user.press(screen.getByRole('button', { name: 'Open Modal' }));

  // Assert modal is visible
  expect(await screen.findByRole('dialog')).toBeOnTheScreen();
  expect(screen.getByText('Modal Content')).toBeOnTheScreen();

  // Close modal
  await user.press(screen.getByRole('button', { name: 'Close' }));

  // Assert modal is gone
  expect(screen.queryByRole('dialog')).not.toBeOnTheScreen();
});
```

### 3. List Components (FlatList, SectionList)

```typescript
test('flatlist renders and scrolls', async () => {
  const user = userEvent.setup();
  render(<ItemList items={generateItems(50)} />);

  // Initial items visible
  expect(screen.getByText('Item 1')).toBeOnTheScreen();

  // Scroll to load more
  const list = screen.getByTestId('item-list');
  await user.scrollTo(list, { y: 1000 });

  // More items now visible
  expect(await screen.findByText('Item 20')).toBeOnTheScreen();
});
```

### 4. Form Validation

```typescript
test('shows validation errors', async () => {
  const user = userEvent.setup();
  render(<RegistrationForm />);

  // Submit empty form
  await user.press(screen.getByRole('button', { name: 'Submit' }));

  // Check for error messages
  expect(await screen.findByRole('alert')).toHaveTextContent('Email is required');

  // Fill invalid email
  await user.type(screen.getByLabelText('Email'), 'invalid-email');
  await user.press(screen.getByRole('button', { name: 'Submit' }));

  expect(await screen.findByRole('alert')).toHaveTextContent('Invalid email format');
});
```

### 5. Async Data Fetching

```typescript
import { server } from './mocks/server';
import { rest } from 'msw';

test('handles successful data fetch', async () => {
  render(<UserProfile userId="123" />);

  await waitForElementToBeRemoved(() => screen.getByText(/loading/i));

  expect(await screen.findByText('Name: John Doe')).toBeOnTheScreen();
  expect(await screen.findByText('Email: john@example.com')).toBeOnTheScreen();
});

test('handles fetch error', async () => {
  server.use(
    rest.get('/api/user/:id', (req, res, ctx) => {
      return res(ctx.status(500), ctx.json({ error: 'Server error' }));
    })
  );

  render(<UserProfile userId="123" />);

  expect(await screen.findByText(/error occurred/i)).toBeOnTheScreen();
});
```

## Test Setup & Configuration

### Jest Configuration

```javascript
// jest.config.js
module.exports = {
  preset: 'react-native',
  setupFilesAfterEnv: ['<rootDir>/jest-setup.ts'],
  transformIgnorePatterns: [
    'node_modules/(?!(react-native|@react-native|@testing-library)/)',
  ],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.test.{ts,tsx}',
  ],
};
```

### Jest Setup File

```typescript
// jest-setup.ts
import '@testing-library/react-native/extend-expect';

// Silence console warnings in tests
jest.spyOn(console, 'warn').mockImplementation(() => {});

// Mock native modules as needed
jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');

// Setup MSW for API mocking (optional)
import { server } from './mocks/server';
beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Custom Render with Providers

```typescript
// test-utils.tsx
import { render, RenderOptions } from '@testing-library/react-native';
import { ThemeProvider } from './providers/theme';
import { AuthProvider } from './providers/auth';

interface CustomRenderOptions extends RenderOptions {
  theme?: 'light' | 'dark';
  user?: User | null;
}

function customRender(
  ui: React.ReactElement,
  { theme = 'light', user = null, ...options }: CustomRenderOptions = {}
) {
  function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <ThemeProvider theme={theme}>
        <AuthProvider user={user}>
          {children}
        </AuthProvider>
      </ThemeProvider>
    );
  }

  return render(ui, { wrapper: Wrapper, ...options });
}

// Re-export everything
export * from '@testing-library/react-native';
export { customRender as render };
```

## Anti-Patterns to Avoid

### 1. Using testID When Accessible Queries Work

```typescript
// Bad - testID doesn't reflect user experience
expect(screen.getByTestId('submit-btn')).toBeOnTheScreen();

// Good - uses accessible role and name
expect(screen.getByRole('button', { name: 'Submit' })).toBeOnTheScreen();
```

### 2. Using fireEvent Instead of userEvent

```typescript
// Bad - fireEvent doesn't simulate real user behavior
fireEvent.press(button);
fireEvent.changeText(input, 'text');

// Good - userEvent simulates actual user interactions
await user.press(button);
await user.type(input, 'text');
```

### 3. Testing Implementation Details

```typescript
// Bad - testing internal state
expect(component.state.isLoading).toBe(false);

// Good - testing what users see
expect(screen.queryByText('Loading...')).not.toBeOnTheScreen();
```

### 4. Using getBy* for Async Content

```typescript
// Bad - getBy* doesn't wait for async content
expect(screen.getByText('Loaded!')).toBeOnTheScreen(); // Might fail!

// Good - findBy* waits for element to appear
expect(await screen.findByText('Loaded!')).toBeOnTheScreen();
```

### 5. Forgetting to Await User Events

```typescript
// Bad - user events are async
user.press(button); // Missing await!

// Good - always await user events
await user.press(button);
```

## Best Practices Summary

### Test Organization
- Group related tests with `describe` blocks
- Use descriptive test names that explain expected behavior
- Follow Arrange-Act-Assert pattern
- Keep tests focused on single behaviors

### Query Selection
- Always prefer accessible queries over testID
- Use semantic queries that match user experience
- Match query variant to test scenario (getBy/queryBy/findBy)

### Async Testing
- Always use `findBy*` for content that appears asynchronously
- Use `waitFor` for complex async conditions
- Use `waitForElementToBeRemoved` for loading states

### User Interactions
- Always use `userEvent.setup()` and await user methods
- Simulate real user flows, not programmatic changes
- Test complete user journeys, not just individual clicks

### Performance
- Use `cleanup` automatically (or call manually if disabled)
- Mock expensive operations (network, animations)
- Keep tests isolated and independent

## Reference Documentation

### Query Strategies
Comprehensive guide in `references/query_strategies.md`:
- Detailed query selection patterns
- Accessibility-first query approaches
- Complex query scenarios
- Performance considerations

### Testing Patterns
Complete patterns in `references/testing_patterns.md`:
- Component testing patterns by type
- Async testing strategies
- State management testing
- Navigation testing

### Best Practices
Technical guide in `references/best_practices.md`:
- Project setup recommendations
- Mock strategies
- CI/CD integration
- Debugging techniques

## Common Commands

```bash
# Run all tests
npm test

# Run tests in watch mode
npm test -- --watch

# Run specific test file
npm test -- MyComponent.test.tsx

# Run with coverage
npm test -- --coverage

# Update snapshots
npm test -- -u

# Run tests matching pattern
npm test -- -t "renders correctly"
```

## Tech Stack Compatibility

**React Native Versions:** 0.73+
**Testing Library:** @testing-library/react-native 12+
**Jest:** 29+
**TypeScript:** 5+
**MSW (optional):** 2+ for API mocking

## Troubleshooting

### Common Issues

**"Unable to find element"**
- Check query is correct (spelling, case sensitivity)
- Use `screen.debug()` to see current render tree
- Ensure element has rendered (use findBy* for async)

**"Multiple elements found"**
- Use more specific query (add name, filter)
- Use `getAllBy*` if testing multiple elements

**"Act() warnings"**
- Wrap state updates in `act()`
- Use `waitFor` or `findBy*` for async updates
- Ensure all promises resolve before assertions

**"Timeout waiting for element"**
- Increase timeout in findBy options
- Check if element is actually rendered
- Verify async operations complete

### Getting Help

- Review reference documentation in `references/`
- Check React Native Testing Library official docs
- Use `screen.debug()` to inspect render output
- Check test script output for detailed errors
