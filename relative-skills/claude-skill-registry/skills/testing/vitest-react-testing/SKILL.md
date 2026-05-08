---
name: vitest-react-testing
description: Write unit and component tests with Vitest, React Testing Library, and MSW. Use when writing unit tests, component tests, or mocking APIs following TDD workflow.
---

# Vitest React Testing Specialist

Specialized in writing tests for React applications using Vitest, React Testing Library, and MSW.

## When to Use This Skill

- Writing unit tests for functions and utilities
- Testing React components with React Testing Library
- Testing user interactions with userEvent
- Testing custom hooks
- Mocking API requests with MSW
- Writing async tests
- Following TDD (Test-Driven Development) workflow

## Core Principles

- **Test Behavior, Not Implementation**: Test what users see and do
- **Arrange-Act-Assert**: Structure tests clearly
- **Test Isolation**: Each test should be independent
- **User-Centric**: Use queries that match how users interact
- **Avoid Test IDs**: Prefer accessible queries (getByRole, getByLabelText)
- **TDD Workflow**: Write tests first (Red → Green → Refactor)

## Implementation Guidelines

### Vitest Setup

```typescript
// vite.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['**/*.test.{ts,tsx}', '**/test/**'],
    },
  },
})
```

```typescript
// src/test/setup.ts
import { expect, afterEach } from 'vitest'
import { cleanup } from '@testing-library/react'
import * as matchers from '@testing-library/jest-dom/matchers'

expect.extend(matchers)

// WHY: Cleanup after each test to prevent state leakage
afterEach(() => {
  cleanup()
})
```

### Basic Unit Tests

```typescript
import { describe, it, expect } from 'vitest'

// Function to test
function add(a: number, b: number): number {
  return a + b
}

describe('add', () => {
  it('should add two numbers', () => {
    // Arrange
    const a = 2
    const b = 3

    // Act
    const result = add(a, b)

    // Assert
    expect(result).toBe(5)
  })

  it('should handle negative numbers', () => {
    expect(add(-1, -2)).toBe(-3)
  })

  it('should handle zero', () => {
    expect(add(5, 0)).toBe(5)
  })
})

// Utility function tests
function formatCurrency(amount: number): string {
  return `$${amount.toFixed(2)}`
}

describe('formatCurrency', () => {
  it('should format with 2 decimal places', () => {
    expect(formatCurrency(10)).toBe('$10.00')
  })

  it('should round to 2 decimal places', () => {
    expect(formatCurrency(10.567)).toBe('$10.57')
  })
})
```

### Component Testing with React Testing Library

```typescript
import { render, screen } from '@testing-library/react'
import { describe, it, expect } from 'vitest'
import { Button } from './Button'

interface ButtonProps {
  label: string
  onClick: () => void
  disabled?: boolean
}

const Button: FC<ButtonProps> = ({ label, onClick, disabled }) => {
  return (
    <button onClick={onClick} disabled={disabled}>
      {label}
    </button>
  )
}

describe('Button', () => {
  it('should render with label', () => {
    render(<Button label="Click me" onClick={() => {}} />)

    // WHY: getByRole is accessible and matches user perception
    const button = screen.getByRole('button', { name: 'Click me' })
    expect(button).toBeInTheDocument()
  })

  it('should be disabled when disabled prop is true', () => {
    render(<Button label="Click me" onClick={() => {}} disabled />)

    const button = screen.getByRole('button')
    expect(button).toBeDisabled()
  })

  it('should not render when label is empty', () => {
    const { container } = render(<Button label="" onClick={() => {}} />)

    expect(container.firstChild).toBeNull()
  })
})
```

### User Interaction Testing

```typescript
import { render, screen } from '@testing-library/react'
import { userEvent } from '@testing-library/user-event'
import { describe, it, expect, vi } from 'vitest'

describe('Counter', () => {
  it('should increment count when button is clicked', async () => {
    const user = userEvent.setup()
    render(<Counter />)

    const button = screen.getByRole('button', { name: /increment/i })
    const count = screen.getByText('Count: 0')

    // Act
    await user.click(button)

    // Assert
    expect(screen.getByText('Count: 1')).toBeInTheDocument()
  })

  it('should handle multiple clicks', async () => {
    const user = userEvent.setup()
    render(<Counter />)

    const button = screen.getByRole('button', { name: /increment/i })

    await user.click(button)
    await user.click(button)
    await user.click(button)

    expect(screen.getByText('Count: 3')).toBeInTheDocument()
  })
})

// Form interaction testing
describe('LoginForm', () => {
  it('should submit form with email and password', async () => {
    const user = userEvent.setup()
    const handleSubmit = vi.fn()
    render(<LoginForm onSubmit={handleSubmit} />)

    // WHY: getByLabelText matches how users find inputs
    const emailInput = screen.getByLabelText(/email/i)
    const passwordInput = screen.getByLabelText(/password/i)
    const submitButton = screen.getByRole('button', { name: /log in/i })

    // Act
    await user.type(emailInput, 'user@example.com')
    await user.type(passwordInput, 'password123')
    await user.click(submitButton)

    // Assert
    expect(handleSubmit).toHaveBeenCalledWith({
      email: 'user@example.com',
      password: 'password123',
    })
  })

  it('should show validation errors for empty fields', async () => {
    const user = userEvent.setup()
    render(<LoginForm onSubmit={() => {}} />)

    const submitButton = screen.getByRole('button', { name: /log in/i })
    await user.click(submitButton)

    expect(screen.getByText(/email is required/i)).toBeInTheDocument()
    expect(screen.getByText(/password is required/i)).toBeInTheDocument()
  })
})
```

### Testing with Mock Functions

```typescript
import { vi } from 'vitest'

describe('UserList', () => {
  it('should call onDelete when delete button is clicked', async () => {
    const user = userEvent.setup()
    const handleDelete = vi.fn()

    render(
      <UserList
        users={[{ id: '1', name: 'John' }]}
        onDelete={handleDelete}
      />
    )

    const deleteButton = screen.getByRole('button', { name: /delete/i })
    await user.click(deleteButton)

    // Assert function was called with correct arguments
    expect(handleDelete).toHaveBeenCalledWith('1')
    expect(handleDelete).toHaveBeenCalledTimes(1)
  })

  it('should not call onDelete when disabled', async () => {
    const user = userEvent.setup()
    const handleDelete = vi.fn()

    render(<UserList users={[]} onDelete={handleDelete} disabled />)

    // Assert function was never called
    expect(handleDelete).not.toHaveBeenCalled()
  })
})

// Spy on module functions
import * as api from './api'

describe('DataFetcher', () => {
  it('should fetch data on mount', () => {
    const spy = vi.spyOn(api, 'fetchUsers')
    render(<DataFetcher />)

    expect(spy).toHaveBeenCalled()
  })
})
```

### Custom Hook Testing

```typescript
import { renderHook, waitFor } from '@testing-library/react'
import { describe, it, expect } from 'vitest'

function useCounter(initialValue = 0) {
  const [count, setCount] = useState(initialValue)

  const increment = () => setCount(prev => prev + 1)
  const decrement = () => setCount(prev => prev - 1)
  const reset = () => setCount(initialValue)

  return { count, increment, decrement, reset }
}

describe('useCounter', () => {
  it('should initialize with default value', () => {
    const { result } = renderHook(() => useCounter())

    expect(result.current.count).toBe(0)
  })

  it('should initialize with custom value', () => {
    const { result } = renderHook(() => useCounter(10))

    expect(result.current.count).toBe(10)
  })

  it('should increment count', () => {
    const { result } = renderHook(() => useCounter())

    act(() => {
      result.current.increment()
    })

    expect(result.current.count).toBe(1)
  })

  it('should reset to initial value', () => {
    const { result } = renderHook(() => useCounter(5))

    act(() => {
      result.current.increment()
      result.current.increment()
      result.current.reset()
    })

    expect(result.current.count).toBe(5)
  })
})

// Testing hook with async behavior
function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(setData)
      .finally(() => setLoading(false))
  }, [url])

  return { data, loading }
}

describe('useFetch', () => {
  it('should fetch data', async () => {
    const { result } = renderHook(() => useFetch<User[]>('/api/users'))

    expect(result.current.loading).toBe(true)

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    expect(result.current.data).toBeDefined()
  })
})
```

### Async Testing

```typescript
import { render, screen, waitFor } from '@testing-library/react'

describe('UserProfile', () => {
  it('should show loading state initially', () => {
    render(<UserProfile userId="1" />)

    expect(screen.getByText(/loading/i)).toBeInTheDocument()
  })

  it('should display user data after loading', async () => {
    render(<UserProfile userId="1" />)

    // WHY: Wait for async operation to complete
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument()
    })

    // Loading indicator should be gone
    expect(screen.queryByText(/loading/i)).not.toBeInTheDocument()
  })

  it('should display error on fetch failure', async () => {
    // Mock API to return error
    vi.spyOn(api, 'fetchUser').mockRejectedValue(new Error('Failed'))

    render(<UserProfile userId="1" />)

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument()
    })
  })
})

// Using findBy queries (combines getBy + waitFor)
describe('AsyncComponent', () => {
  it('should find element after async update', async () => {
    render(<AsyncComponent />)

    // WHY: findBy automatically waits for element to appear
    const heading = await screen.findByRole('heading', { name: /welcome/i })
    expect(heading).toBeInTheDocument()
  })
})
```

### MSW (Mock Service Worker) for API Mocking

```typescript
// src/test/mocks/handlers.ts
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: '1', name: 'John Doe', email: 'john@example.com' },
      { id: '2', name: 'Jane Smith', email: 'jane@example.com' },
    ])
  }),

  http.get('/api/users/:id', ({ params }) => {
    const { id } = params
    return HttpResponse.json({
      id,
      name: 'John Doe',
      email: 'john@example.com',
    })
  }),

  http.post('/api/users', async ({ request }) => {
    const body = await request.json()
    return HttpResponse.json(
      { id: '3', ...body },
      { status: 201 }
    )
  }),

  http.delete('/api/users/:id', () => {
    return new HttpResponse(null, { status: 204 })
  }),
]

// src/test/mocks/server.ts
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)

// src/test/setup.ts
import { beforeAll, afterEach, afterAll } from 'vitest'
import { server } from './mocks/server'

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

```typescript
// Using MSW in tests
import { server } from './test/mocks/server'
import { http, HttpResponse } from 'msw'

describe('UserList', () => {
  it('should display users from API', async () => {
    render(<UserList />)

    // WHY: Wait for async data to load
    expect(await screen.findByText('John Doe')).toBeInTheDocument()
    expect(await screen.findByText('Jane Smith')).toBeInTheDocument()
  })

  it('should handle API error', async () => {
    // Override handler for this test
    server.use(
      http.get('/api/users', () => {
        return new HttpResponse(null, { status: 500 })
      })
    )

    render(<UserList />)

    expect(await screen.findByText(/error/i)).toBeInTheDocument()
  })

  it('should handle empty response', async () => {
    server.use(
      http.get('/api/users', () => {
        return HttpResponse.json([])
      })
    )

    render(<UserList />)

    expect(await screen.findByText(/no users/i)).toBeInTheDocument()
  })
})
```

### Testing Context Providers

```typescript
import { render, screen } from '@testing-library/react'

// Helper to render with providers
function renderWithProviders(ui: React.ReactElement) {
  return render(
    <ThemeProvider>
      <AuthProvider>
        {ui}
      </AuthProvider>
    </ThemeProvider>
  )
}

describe('ThemedButton', () => {
  it('should apply theme from context', () => {
    renderWithProviders(<ThemedButton />)

    const button = screen.getByRole('button')
    expect(button).toHaveClass('dark-theme')
  })
})

// Testing with custom wrapper
describe('UserDashboard', () => {
  it('should display user from auth context', () => {
    const wrapper = ({ children }: { children: React.ReactNode }) => (
      <AuthProvider value={{ user: mockUser }}>
        {children}
      </AuthProvider>
    )

    render(<UserDashboard />, { wrapper })

    expect(screen.getByText(mockUser.name)).toBeInTheDocument()
  })
})
```

## Tools to Use

- `Read`: Read component and hook files
- `Write`: Create test files
- `Edit`: Update existing tests
- `Bash`: Run tests and coverage

### Bash Commands

```bash
# Run all tests
vitest

# Run in watch mode
vitest --watch

# Run specific test file
vitest src/components/Button.test.tsx

# Run tests with coverage
vitest --coverage

# Run tests in UI mode
vitest --ui

# Run only changed tests
vitest --changed
```

## Workflow

1. **Write Test First**: Start with failing test (Red)
2. **Run Test**: Confirm it fails for the right reason
3. **Write Minimal Code**: Make test pass (Green)
4. **Run Test**: Ensure it passes
5. **Refactor**: Improve code while keeping tests green
6. **Run All Tests**: Ensure no regressions
7. **Commit**: Create atomic commit

## Related Skills

- `typescript-core-development`: For type-safe test code
- `react-component-development`: For components being tested
- `react-state-management`: For testing state logic

## Testing Fundamentals

See [Vitest Fundamentals](../_shared/vitest-fundamentals.md)

## TDD Workflow

Follow [Frontend TDD Workflow](../_shared/frontend-tdd-workflow.md)

## Key Reminders

- Write tests before implementation (TDD)
- Test behavior, not implementation details
- Use accessible queries (getByRole, getByLabelText) over test IDs
- Clean up after each test to prevent state leakage
- Use userEvent for user interactions
- Use MSW for mocking API requests
- Use waitFor and findBy for async operations
- Mock at the network layer, not the component layer
- Test what users see and do, not internal state
- Keep tests simple and focused
- Run tests frequently during development
- Aim for high coverage but focus on critical paths
- Write comments explaining WHY when testing complex scenarios
