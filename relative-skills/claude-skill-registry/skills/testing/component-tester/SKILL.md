---
name: component-tester
description: Write, run, and analyze component tests using Vitest and React Testing Library with coverage analysis and accessibility validation
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Task
---

# Component Tester

Expert skill for testing UI component libraries with Vitest and React Testing Library. Specializes in writing comprehensive tests, analyzing coverage, validating accessibility, and ensuring component quality.

## Core Capabilities

### 1. Test Writing
- Unit tests for individual components
- Integration tests for component interactions
- Snapshot tests for visual regression
- Accessibility tests (a11y)
- User interaction tests (clicks, typing, keyboard nav)
- Async behavior testing (loading states, data fetching)
- Edge case and error state testing

### 2. Testing Tools Mastery
- **Vitest**: Fast test runner with native ESM support
- **React Testing Library**: User-centric testing
- **@testing-library/user-event**: Realistic user interactions
- **@testing-library/jest-dom**: Custom matchers
- **@axe-core/react**: Accessibility testing
- **msw**: API mocking

### 3. Test Patterns
- Arrange-Act-Assert (AAA) pattern
- Test fixtures and factories
- Custom render functions
- Reusable test utilities
- Mock management
- Test data builders

### 4. Coverage Analysis
- Line coverage metrics
- Branch coverage analysis
- Function coverage tracking
- Statement coverage
- Identify untested code paths
- Generate coverage reports (HTML, LCOV, JSON)

### 5. Accessibility Validation
- Screen reader compatibility
- Keyboard navigation testing
- ARIA attribute validation
- Color contrast checks
- Focus management tests
- Semantic HTML validation

### 6. Component Quality Checks
- PropTypes validation
- TypeScript type checking
- Performance testing
- Memory leak detection
- Render efficiency
- Bundle size impact

## Workflow

### Phase 1: Test Planning
1. **Analyze Component**
   - Understand component behavior
   - Identify user interactions
   - List edge cases and error states
   - Determine accessibility requirements
   - Note performance considerations

2. **Define Test Strategy**
   - What to test (user behavior, not implementation)
   - Which interactions to cover
   - Which edge cases matter
   - What NOT to test (implementation details)

3. **Set Up Test Environment**
   - Create test file
   - Import necessary utilities
   - Set up custom render function
   - Prepare mocks and fixtures

### Phase 2: Writing Tests
1. **Basic Rendering Tests**
   - Component renders without errors
   - Default props render correctly
   - Required props are handled

2. **User Interaction Tests**
   - Click events work
   - Keyboard navigation functions
   - Form inputs update correctly
   - Hover/focus states trigger

3. **State Management Tests**
   - Internal state updates correctly
   - Controlled component behavior
   - Uncontrolled component behavior
   - State persistence

4. **Accessibility Tests**
   - ARIA roles and labels present
   - Keyboard navigation works
   - Screen reader announcements
   - Focus management correct

5. **Edge Case Tests**
   - Empty states
   - Loading states
   - Error states
   - Boundary values
   - Invalid inputs

### Phase 3: Running & Analysis
1. **Execute Tests**
   - Run test suite
   - Watch mode for development
   - Generate coverage report
   - Check for failures

2. **Analyze Coverage**
   - Review coverage percentages
   - Identify untested code
   - Prioritize missing tests
   - Set coverage thresholds

3. **Review Results**
   - Fix failing tests
   - Improve test quality
   - Refactor when needed
   - Document findings

## Testing Patterns & Examples

### Custom Render Function
```typescript
// test-utils.tsx
import { render, RenderOptions } from '@testing-library/react'
import { ReactElement } from 'react'
import { ThemeProvider } from './theme-provider'

interface CustomRenderOptions extends Omit<RenderOptions, 'wrapper'> {
  theme?: 'light' | 'dark'
}

function customRender(
  ui: ReactElement,
  { theme = 'light', ...options }: CustomRenderOptions = {}
) {
  function Wrapper({ children }: { children: React.ReactNode }) {
    return <ThemeProvider theme={theme}>{children}</ThemeProvider>
  }

  return render(ui, { wrapper: Wrapper, ...options })
}

export * from '@testing-library/react'
export { customRender as render }
```

### Basic Component Test
```typescript
// Button.test.tsx
import { render, screen } from './test-utils'
import { userEvent } from '@testing-library/user-event'
import { Button } from './Button'

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument()
  })

  it('calls onClick when clicked', async () => {
    const handleClick = vi.fn()
    const user = userEvent.setup()

    render(<Button onClick={handleClick}>Click me</Button>)

    await user.click(screen.getByRole('button'))

    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click me</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })

  it('applies variant styles', () => {
    const { rerender } = render(<Button variant="primary">Primary</Button>)
    expect(screen.getByRole('button')).toHaveClass('btn-primary')

    rerender(<Button variant="secondary">Secondary</Button>)
    expect(screen.getByRole('button')).toHaveClass('btn-secondary')
  })
})
```

### Async Testing
```typescript
// DataFetcher.test.tsx
import { render, screen, waitFor } from './test-utils'
import { DataFetcher } from './DataFetcher'
import { server } from './mocks/server'
import { rest } from 'msw'

describe('DataFetcher', () => {
  it('displays loading state initially', () => {
    render(<DataFetcher url="/api/data" />)
    expect(screen.getByText(/loading/i)).toBeInTheDocument()
  })

  it('displays data after successful fetch', async () => {
    render(<DataFetcher url="/api/data" />)

    await waitFor(() => {
      expect(screen.getByText(/data loaded/i)).toBeInTheDocument()
    })
  })

  it('displays error on failed fetch', async () => {
    server.use(
      rest.get('/api/data', (req, res, ctx) => {
        return res(ctx.status(500), ctx.json({ error: 'Server error' }))
      })
    )

    render(<DataFetcher url="/api/data" />)

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument()
    })
  })
})
```

### User Interaction Testing
```typescript
// Form.test.tsx
import { render, screen } from './test-utils'
import { userEvent } from '@testing-library/user-event'
import { Form } from './Form'

describe('Form', () => {
  it('submits form with entered data', async () => {
    const handleSubmit = vi.fn()
    const user = userEvent.setup()

    render(<Form onSubmit={handleSubmit} />)

    // Type in input
    await user.type(screen.getByLabelText(/username/i), 'john_doe')

    // Select option
    await user.selectOptions(screen.getByLabelText(/role/i), 'admin')

    // Check checkbox
    await user.click(screen.getByLabelText(/agree to terms/i))

    // Submit form
    await user.click(screen.getByRole('button', { name: /submit/i }))

    expect(handleSubmit).toHaveBeenCalledWith({
      username: 'john_doe',
      role: 'admin',
      agreedToTerms: true,
    })
  })

  it('validates required fields', async () => {
    const user = userEvent.setup()

    render(<Form />)

    await user.click(screen.getByRole('button', { name: /submit/i }))

    expect(screen.getByText(/username is required/i)).toBeInTheDocument()
  })
})
```

### Keyboard Navigation Testing
```typescript
// Menu.test.tsx
import { render, screen } from './test-utils'
import { userEvent } from '@testing-library/user-event'
import { Menu } from './Menu'

describe('Menu keyboard navigation', () => {
  it('opens menu with Enter key', async () => {
    const user = userEvent.setup()
    render(<Menu />)

    const trigger = screen.getByRole('button', { name: /open menu/i })
    await user.tab() // Focus trigger
    await user.keyboard('{Enter}')

    expect(screen.getByRole('menu')).toBeInTheDocument()
  })

  it('navigates items with arrow keys', async () => {
    const user = userEvent.setup()
    render(<Menu defaultOpen />)

    const items = screen.getAllByRole('menuitem')

    await user.tab() // Focus first item
    expect(items[0]).toHaveFocus()

    await user.keyboard('{ArrowDown}')
    expect(items[1]).toHaveFocus()

    await user.keyboard('{ArrowUp}')
    expect(items[0]).toHaveFocus()
  })

  it('closes menu with Escape key', async () => {
    const user = userEvent.setup()
    render(<Menu defaultOpen />)

    expect(screen.getByRole('menu')).toBeInTheDocument()

    await user.keyboard('{Escape}')

    expect(screen.queryByRole('menu')).not.toBeInTheDocument()
  })
})
```

### Accessibility Testing
```typescript
// Button.a11y.test.tsx
import { render } from './test-utils'
import { axe, toHaveNoViolations } from 'jest-axe'
import { Button } from './Button'

expect.extend(toHaveNoViolations)

describe('Button accessibility', () => {
  it('has no accessibility violations', async () => {
    const { container } = render(<Button>Click me</Button>)
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })

  it('has correct ARIA label when icon-only', async () => {
    const { container } = render(
      <Button aria-label="Close dialog">
        <XIcon />
      </Button>
    )
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })
})
```

### Snapshot Testing
```typescript
// Card.test.tsx
import { render } from './test-utils'
import { Card } from './Card'

describe('Card snapshots', () => {
  it('matches snapshot with default props', () => {
    const { container } = render(
      <Card>
        <Card.Header>Title</Card.Header>
        <Card.Content>Content</Card.Content>
      </Card>
    )
    expect(container.firstChild).toMatchSnapshot()
  })

  it('matches snapshot with all variants', () => {
    const variants = ['default', 'bordered', 'elevated'] as const

    variants.forEach((variant) => {
      const { container } = render(
        <Card variant={variant}>
          <Card.Content>Content</Card.Content>
        </Card>
      )
      expect(container.firstChild).toMatchSnapshot()
    })
  })
})
```

### Mock Management
```typescript
// setupTests.ts
import { beforeAll, afterEach, afterAll } from 'vitest'
import { server } from './mocks/server'

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

// mocks/server.ts
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)

// mocks/handlers.ts
import { rest } from 'msw'

export const handlers = [
  rest.get('/api/data', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json({ data: 'Mock data' })
    )
  }),
]
```

## Test Configuration

### Vitest Config
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    css: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.d.ts',
        '**/*.config.*',
        '**/mockData',
        'dist/',
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
  },
})
```

### Setup File
```typescript
// src/test/setup.ts
import '@testing-library/jest-dom'
import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

// Cleanup after each test
afterEach(() => {
  cleanup()
})

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
})

// Mock IntersectionObserver
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  disconnect() {}
  observe() {}
  takeRecords() {
    return []
  }
  unobserve() {}
} as any
```

## Testing Best Practices

### What to Test
✅ **DO Test:**
- User-visible behavior
- Accessibility features
- User interactions (clicks, typing, keyboard nav)
- Different prop combinations
- Edge cases and error states
- Loading and async states
- Integration between components

❌ **DON'T Test:**
- Implementation details
- Internal state directly
- Styling (use visual regression tools instead)
- Third-party libraries
- Framework internals

### Writing Effective Tests

1. **Use Queries in Priority Order**
   ```typescript
   // 1. Accessible to all (best)
   getByRole('button', { name: /submit/i })
   getByLabelText(/username/i)
   getByPlaceholderText(/enter email/i)
   getByText(/welcome/i)

   // 2. Semantic (good)
   getByAltText(/profile picture/i)
   getByTitle(/tooltip/i)

   // 3. Test IDs (last resort)
   getByTestId('submit-button')
   ```

2. **Wait for Async Changes**
   ```typescript
   // Use waitFor for assertions
   await waitFor(() => {
     expect(screen.getByText(/data loaded/i)).toBeInTheDocument()
   })

   // Use findBy for queries (combines getBy + waitFor)
   expect(await screen.findByText(/data loaded/i)).toBeInTheDocument()
   ```

3. **User-Event Over FireEvent**
   ```typescript
   // Prefer userEvent (more realistic)
   await user.click(button)
   await user.type(input, 'hello')

   // Avoid fireEvent when possible
   fireEvent.click(button) // Less realistic
   ```

4. **Descriptive Test Names**
   ```typescript
   // Good
   it('displays error message when email is invalid', () => {})
   it('disables submit button while form is submitting', () => {})

   // Bad
   it('works', () => {})
   it('test button', () => {})
   ```

5. **Arrange-Act-Assert Pattern**
   ```typescript
   it('increments counter on click', async () => {
     // Arrange
     const user = userEvent.setup()
     render(<Counter />)

     // Act
     await user.click(screen.getByRole('button', { name: /increment/i }))

     // Assert
     expect(screen.getByText('Count: 1')).toBeInTheDocument()
   })
   ```

### Coverage Best Practices

1. **Set Realistic Thresholds**
   - Aim for 80%+ coverage
   - 100% coverage doesn't mean bug-free
   - Focus on critical paths

2. **Ignore Appropriate Files**
   - Config files
   - Type definitions
   - Test utilities
   - Generated code
   - Mock data

3. **Review Coverage Reports**
   - Look for untested branches
   - Identify missed edge cases
   - Check critical code paths

## Running Tests

### Common Commands
```bash
# Run all tests
npm test

# Watch mode
npm test -- --watch

# Run specific file
npm test Button.test.tsx

# Run with coverage
npm test -- --coverage

# Run in UI mode
npm test -- --ui

# Run only changed files
npm test -- --changed

# Update snapshots
npm test -- -u
```

### CI/CD Integration
```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test -- --coverage
      - uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

## Common Testing Scenarios

### Testing Controlled Components
```typescript
it('calls onChange when value changes', async () => {
  const handleChange = vi.fn()
  const user = userEvent.setup()

  const { rerender } = render(
    <Input value="" onChange={handleChange} />
  )

  await user.type(screen.getByRole('textbox'), 'hello')

  expect(handleChange).toHaveBeenCalledTimes(5)
  expect(handleChange).toHaveBeenLastCalledWith('hello')
})
```

### Testing Compound Components
```typescript
it('activates tab when clicked', async () => {
  const user = userEvent.setup()

  render(
    <Tabs defaultValue="tab1">
      <TabsList>
        <TabsTrigger value="tab1">Tab 1</TabsTrigger>
        <TabsTrigger value="tab2">Tab 2</TabsTrigger>
      </TabsList>
      <TabsContent value="tab1">Content 1</TabsContent>
      <TabsContent value="tab2">Content 2</TabsContent>
    </Tabs>
  )

  expect(screen.getByText('Content 1')).toBeInTheDocument()
  expect(screen.queryByText('Content 2')).not.toBeInTheDocument()

  await user.click(screen.getByRole('tab', { name: /tab 2/i }))

  expect(screen.queryByText('Content 1')).not.toBeInTheDocument()
  expect(screen.getByText('Content 2')).toBeInTheDocument()
})
```

### Testing Context Providers
```typescript
it('provides theme context to children', () => {
  render(
    <ThemeProvider theme="dark">
      <ComponentUsingTheme />
    </ThemeProvider>
  )

  expect(screen.getByTestId('theme-display')).toHaveTextContent('dark')
})
```

### Testing Custom Hooks
```typescript
// useCounter.test.ts
import { renderHook, act } from '@testing-library/react'
import { useCounter } from './useCounter'

describe('useCounter', () => {
  it('increments counter', () => {
    const { result } = renderHook(() => useCounter())

    expect(result.current.count).toBe(0)

    act(() => {
      result.current.increment()
    })

    expect(result.current.count).toBe(1)
  })
})
```

## Troubleshooting

### Common Issues

**Act Warnings**
```typescript
// Wrap state updates in act()
await act(async () => {
  await someAsyncFunction()
})
```

**Query Not Found**
```typescript
// Use queryBy for assertions about absence
expect(screen.queryByText(/not here/i)).not.toBeInTheDocument()

// Use waitFor for async elements
await waitFor(() => {
  expect(screen.getByText(/async content/i)).toBeInTheDocument()
})
```

**Timer Issues**
```typescript
// Use fake timers when needed
vi.useFakeTimers()

act(() => {
  vi.advanceTimersByTime(1000)
})

vi.useRealTimers()
```

## When to Use This Skill

Activate this skill when you need to:
- Write unit tests for components
- Create integration tests
- Set up test infrastructure
- Analyze test coverage
- Fix failing tests
- Improve test quality
- Add accessibility tests
- Test user interactions
- Mock API calls
- Set up MSW handlers
- Configure Vitest
- Debug test issues

## Output Format

When writing tests, provide:
1. **Complete Test Suite**: All test cases for the component
2. **Coverage Report**: What's tested and what's not
3. **Setup Instructions**: Any configuration needed
4. **Mock Data**: Test fixtures if required
5. **Accessibility Notes**: A11y test results
6. **Next Steps**: Recommendations for additional tests

Always write tests that are maintainable, readable, and focused on user behavior.
