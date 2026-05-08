---
name: state-management-architect
description: Design and implement state management solutions using Context API, XState, Zustand, Jotai, and custom hooks with testing patterns and performance optimization
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Task
---

# State Management Architect

Expert skill for designing and implementing state management solutions for UI libraries and applications. Specializes in React Context, XState state machines, Zustand, Jotai, custom hooks, and state testing patterns.

## Core Capabilities

### 1. State Management Solutions
- **React Context**: Provider patterns, context composition
- **XState**: Finite state machines, statecharts
- **Zustand**: Simple global state management
- **Jotai**: Atomic state management
- **Custom Hooks**: Encapsulated state logic
- **Reducers**: Complex state transitions
- **Middleware**: State change interceptors

### 2. Context Patterns
- **Single Context**: Simple state sharing
- **Multiple Contexts**: Domain separation
- **Context Composition**: Nested providers
- **Context Selectors**: Optimized subscriptions
- **Context with Reducer**: Complex state logic
- **Context Factories**: Reusable context patterns

### 3. State Machines (XState)
- **Finite States**: Explicit state definitions
- **Transitions**: State change logic
- **Guards**: Conditional transitions
- **Actions**: Side effects on transitions
- **Services**: Async operations
- **Actors**: Spawned state machines
- **Visualization**: State machine diagrams

### 4. Global State (Zustand)
- **Store Creation**: Simple store setup
- **Selectors**: Optimized subscriptions
- **Actions**: State mutations
- **Middleware**: Persist, devtools, immer
- **Slices**: Modular store organization
- **Computed Values**: Derived state

### 5. Atomic State (Jotai)
- **Atoms**: Primitive state units
- **Derived Atoms**: Computed state
- **Async Atoms**: Async data fetching
- **Atom Families**: Dynamic atoms
- **Atom Utils**: Reset, update, scope
- **Storage**: Persistence

### 6. Performance Optimization
- **Memoization**: Prevent unnecessary renders
- **Selectors**: Granular subscriptions
- **Code Splitting**: Lazy load state
- **Batching**: Group state updates
- **Immutability**: Structural sharing
- **Devtools**: Performance profiling

## Workflow

### Phase 1: State Analysis
1. **Identify State Types**
   - Local component state?
   - Shared state?
   - Global state?
   - Server state?

2. **Map Data Flow**
   - Who creates state?
   - Who reads state?
   - Who updates state?
   - State lifetime?

3. **Choose Solution**
   - Simple: useState, useReducer
   - Shared: Context, props
   - Global: Zustand, Jotai
   - Complex logic: XState

### Phase 2: Implementation
1. **Set Up State Management**
   - Install dependencies
   - Create stores/contexts
   - Define state shape

2. **Implement Logic**
   - State updates
   - Side effects
   - Error handling
   - Loading states

3. **Optimize Performance**
   - Add selectors
   - Memoize components
   - Split code

### Phase 3: Testing & Documentation
1. **Write Tests**
   - State transitions
   - Side effects
   - Edge cases
   - Performance

2. **Document API**
   - State shape
   - Actions/mutations
   - Usage examples
   - Migration guide

## State Management Patterns

### Context with Reducer Pattern

```typescript
// CounterContext.tsx
import { createContext, useContext, useReducer, ReactNode } from 'react'

// State type
interface CounterState {
  count: number
  loading: boolean
  error: string | null
}

// Actions
type CounterAction =
  | { type: 'INCREMENT' }
  | { type: 'DECREMENT' }
  | { type: 'SET_COUNT'; payload: number }
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'SET_ERROR'; payload: string | null }

// Reducer
function counterReducer(state: CounterState, action: CounterAction): CounterState {
  switch (action.type) {
    case 'INCREMENT':
      return { ...state, count: state.count + 1 }
    case 'DECREMENT':
      return { ...state, count: state.count - 1 }
    case 'SET_COUNT':
      return { ...state, count: action.payload }
    case 'SET_LOADING':
      return { ...state, loading: action.payload }
    case 'SET_ERROR':
      return { ...state, error: action.payload }
    default:
      return state
  }
}

// Context
interface CounterContextType {
  state: CounterState
  dispatch: React.Dispatch<CounterAction>
}

const CounterContext = createContext<CounterContextType | undefined>(undefined)

// Provider
export function CounterProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(counterReducer, {
    count: 0,
    loading: false,
    error: null,
  })

  return (
    <CounterContext.Provider value={{ state, dispatch }}>
      {children}
    </CounterContext.Provider>
  )
}

// Hook
export function useCounter() {
  const context = useContext(CounterContext)
  if (!context) {
    throw new Error('useCounter must be used within CounterProvider')
  }
  return context
}

// Action creators
export const counterActions = {
  increment: (): CounterAction => ({ type: 'INCREMENT' }),
  decrement: (): CounterAction => ({ type: 'DECREMENT' }),
  setCount: (count: number): CounterAction => ({ type: 'SET_COUNT', payload: count }),
  setLoading: (loading: boolean): CounterAction => ({ type: 'SET_LOADING', payload: loading }),
  setError: (error: string | null): CounterAction => ({ type: 'SET_ERROR', payload: error }),
}

// Usage
function Counter() {
  const { state, dispatch } = useCounter()

  return (
    <div>
      <p>Count: {state.count}</p>
      <button onClick={() => dispatch(counterActions.increment())}>+</button>
      <button onClick={() => dispatch(counterActions.decrement())}>-</button>
    </div>
  )
}
```

### XState State Machine

```typescript
// toggleMachine.ts
import { createMachine, assign } from 'xstate'
import { useMachine } from '@xstate/react'

interface ToggleContext {
  count: number
}

type ToggleEvent =
  | { type: 'TOGGLE' }
  | { type: 'RESET' }

export const toggleMachine = createMachine<ToggleContext, ToggleEvent>({
  id: 'toggle',
  initial: 'off',
  context: {
    count: 0,
  },
  states: {
    off: {
      on: {
        TOGGLE: {
          target: 'on',
          actions: assign({
            count: (ctx) => ctx.count + 1,
          }),
        },
      },
    },
    on: {
      on: {
        TOGGLE: {
          target: 'off',
        },
      },
    },
  },
  on: {
    RESET: {
      target: 'off',
      actions: assign({
        count: 0,
      }),
    },
  },
})

// Usage
function Toggle() {
  const [state, send] = useMachine(toggleMachine)

  return (
    <div>
      <p>State: {state.value}</p>
      <p>Toggled {state.context.count} times</p>
      <button onClick={() => send('TOGGLE')}>Toggle</button>
      <button onClick={() => send('RESET')}>Reset</button>
    </div>
  )
}
```

### XState with Async Operations

```typescript
// authMachine.ts
import { createMachine, assign } from 'xstate'

interface AuthContext {
  user: { id: string; name: string } | null
  error: string | null
}

type AuthEvent =
  | { type: 'LOGIN'; credentials: { email: string; password: string } }
  | { type: 'LOGOUT' }

export const authMachine = createMachine<AuthContext, AuthEvent>({
  id: 'auth',
  initial: 'idle',
  context: {
    user: null,
    error: null,
  },
  states: {
    idle: {
      on: {
        LOGIN: 'authenticating',
      },
    },
    authenticating: {
      invoke: {
        src: (context, event) => loginUser(event.credentials),
        onDone: {
          target: 'authenticated',
          actions: assign({
            user: (_, event) => event.data,
            error: null,
          }),
        },
        onError: {
          target: 'idle',
          actions: assign({
            error: (_, event) => event.data.message,
          }),
        },
      },
    },
    authenticated: {
      on: {
        LOGOUT: {
          target: 'idle',
          actions: assign({
            user: null,
            error: null,
          }),
        },
      },
    },
  },
})

async function loginUser(credentials: { email: string; password: string }) {
  const response = await fetch('/api/login', {
    method: 'POST',
    body: JSON.stringify(credentials),
  })
  if (!response.ok) throw new Error('Login failed')
  return response.json()
}
```

### Zustand Store

```typescript
// useStore.ts
import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'
import { immer } from 'zustand/middleware/immer'

interface Todo {
  id: string
  text: string
  completed: boolean
}

interface TodoStore {
  todos: Todo[]
  filter: 'all' | 'active' | 'completed'

  // Actions
  addTodo: (text: string) => void
  toggleTodo: (id: string) => void
  removeTodo: (id: string) => void
  setFilter: (filter: 'all' | 'active' | 'completed') => void

  // Computed
  filteredTodos: () => Todo[]
}

export const useTodoStore = create<TodoStore>()(
  devtools(
    persist(
      immer((set, get) => ({
        todos: [],
        filter: 'all',

        addTodo: (text) =>
          set((state) => {
            state.todos.push({
              id: Date.now().toString(),
              text,
              completed: false,
            })
          }),

        toggleTodo: (id) =>
          set((state) => {
            const todo = state.todos.find((t) => t.id === id)
            if (todo) {
              todo.completed = !todo.completed
            }
          }),

        removeTodo: (id) =>
          set((state) => {
            state.todos = state.todos.filter((t) => t.id !== id)
          }),

        setFilter: (filter) =>
          set({ filter }),

        filteredTodos: () => {
          const { todos, filter } = get()
          if (filter === 'all') return todos
          if (filter === 'active') return todos.filter((t) => !t.completed)
          return todos.filter((t) => t.completed)
        },
      })),
      {
        name: 'todo-storage',
      }
    )
  )
)

// Usage with selector (optimized)
function TodoList() {
  const filteredTodos = useTodoStore((state) => state.filteredTodos())
  const toggleTodo = useTodoStore((state) => state.toggleTodo)

  return (
    <ul>
      {filteredTodos.map((todo) => (
        <li key={todo.id} onClick={() => toggleTodo(todo.id)}>
          {todo.text} {todo.completed && '✓'}
        </li>
      ))}
    </ul>
  )
}
```

### Zustand with Slices

```typescript
// store.ts
import { create } from 'zustand'

// User slice
interface UserSlice {
  user: { id: string; name: string } | null
  setUser: (user: { id: string; name: string }) => void
  clearUser: () => void
}

const createUserSlice = (set: any): UserSlice => ({
  user: null,
  setUser: (user) => set({ user }),
  clearUser: () => set({ user: null }),
})

// Settings slice
interface SettingsSlice {
  theme: 'light' | 'dark'
  language: string
  setTheme: (theme: 'light' | 'dark') => void
  setLanguage: (language: string) => void
}

const createSettingsSlice = (set: any): SettingsSlice => ({
  theme: 'light',
  language: 'en',
  setTheme: (theme) => set({ theme }),
  setLanguage: (language) => set({ language }),
})

// Combined store
type Store = UserSlice & SettingsSlice

export const useStore = create<Store>()((set, get, api) => ({
  ...createUserSlice(set),
  ...createSettingsSlice(set),
}))
```

### Jotai Atoms

```typescript
// atoms.ts
import { atom } from 'jotai'
import { atomWithStorage } from 'jotai/utils'

// Primitive atom
export const countAtom = atom(0)

// Derived atom (read-only)
export const doubleCountAtom = atom((get) => get(countAtom) * 2)

// Derived atom (read-write)
export const incrementAtom = atom(
  (get) => get(countAtom),
  (get, set) => set(countAtom, get(countAtom) + 1)
)

// Async atom
export const userAtom = atom(async () => {
  const response = await fetch('/api/user')
  return response.json()
})

// Atom with storage (persisted)
export const themeAtom = atomWithStorage<'light' | 'dark'>('theme', 'light')

// Atom family (dynamic atoms)
import { atomFamily } from 'jotai/utils'

export const todoAtomFamily = atomFamily((id: string) =>
  atom({
    id,
    text: '',
    completed: false,
  })
)

// Usage
import { useAtom, useAtomValue, useSetAtom } from 'jotai'

function Counter() {
  const [count, setCount] = useAtom(countAtom)
  const doubleCount = useAtomValue(doubleCountAtom)
  const increment = useSetAtom(incrementAtom)

  return (
    <div>
      <p>Count: {count}</p>
      <p>Double: {doubleCount}</p>
      <button onClick={() => setCount((c) => c + 1)}>+1</button>
      <button onClick={increment}>Increment</button>
    </div>
  )
}
```

### Custom Hook Pattern

```typescript
// useLocalStorage.ts
import { useState, useEffect } from 'react'

export function useLocalStorage<T>(key: string, initialValue: T) {
  // State to store our value
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch (error) {
      console.error(error)
      return initialValue
    }
  })

  // Update localStorage when state changes
  useEffect(() => {
    try {
      window.localStorage.setItem(key, JSON.stringify(storedValue))
    } catch (error) {
      console.error(error)
    }
  }, [key, storedValue])

  return [storedValue, setStoredValue] as const
}

// useAsync.ts
import { useState, useEffect } from 'react'

interface UseAsyncState<T> {
  data: T | null
  loading: boolean
  error: Error | null
}

export function useAsync<T>(asyncFunction: () => Promise<T>, dependencies: any[] = []) {
  const [state, setState] = useState<UseAsyncState<T>>({
    data: null,
    loading: true,
    error: null,
  })

  useEffect(() => {
    let cancelled = false

    setState({ data: null, loading: true, error: null })

    asyncFunction()
      .then((data) => {
        if (!cancelled) {
          setState({ data, loading: false, error: null })
        }
      })
      .catch((error) => {
        if (!cancelled) {
          setState({ data: null, loading: false, error })
        }
      })

    return () => {
      cancelled = true
    }
  }, dependencies)

  return state
}

// useDebounce.ts
import { useState, useEffect } from 'react'

export function useDebounce<T>(value: T, delay: number = 500): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => {
      clearTimeout(handler)
    }
  }, [value, delay])

  return debouncedValue
}
```

## State Testing Patterns

### Testing Context

```typescript
// CounterContext.test.tsx
import { render, screen } from '@testing-library/react'
import { userEvent } from '@testing-library/user-event'
import { CounterProvider, useCounter, counterActions } from './CounterContext'

function TestComponent() {
  const { state, dispatch } = useCounter()

  return (
    <div>
      <span data-testid="count">{state.count}</span>
      <button onClick={() => dispatch(counterActions.increment())}>+</button>
      <button onClick={() => dispatch(counterActions.decrement())}>-</button>
    </div>
  )
}

describe('CounterContext', () => {
  it('increments count', async () => {
    const user = userEvent.setup()

    render(
      <CounterProvider>
        <TestComponent />
      </CounterProvider>
    )

    expect(screen.getByTestId('count')).toHaveTextContent('0')

    await user.click(screen.getByRole('button', { name: '+' }))

    expect(screen.getByTestId('count')).toHaveTextContent('1')
  })

  it('decrements count', async () => {
    const user = userEvent.setup()

    render(
      <CounterProvider>
        <TestComponent />
      </CounterProvider>
    )

    await user.click(screen.getByRole('button', { name: '-' }))

    expect(screen.getByTestId('count')).toHaveTextContent('-1')
  })
})
```

### Testing XState

```typescript
// toggleMachine.test.ts
import { interpret } from 'xstate'
import { toggleMachine } from './toggleMachine'

describe('toggleMachine', () => {
  it('toggles between on and off', () => {
    const service = interpret(toggleMachine).start()

    expect(service.state.value).toBe('off')
    expect(service.state.context.count).toBe(0)

    service.send('TOGGLE')
    expect(service.state.value).toBe('on')
    expect(service.state.context.count).toBe(1)

    service.send('TOGGLE')
    expect(service.state.value).toBe('off')
    expect(service.state.context.count).toBe(1)

    service.stop()
  })

  it('resets to initial state', () => {
    const service = interpret(toggleMachine).start()

    service.send('TOGGLE')
    service.send('TOGGLE')
    service.send('RESET')

    expect(service.state.value).toBe('off')
    expect(service.state.context.count).toBe(0)

    service.stop()
  })
})
```

### Testing Zustand

```typescript
// useStore.test.ts
import { renderHook, act } from '@testing-library/react'
import { useTodoStore } from './useStore'

describe('useTodoStore', () => {
  beforeEach(() => {
    // Reset store before each test
    useTodoStore.setState({ todos: [], filter: 'all' })
  })

  it('adds a todo', () => {
    const { result } = renderHook(() => useTodoStore())

    act(() => {
      result.current.addTodo('Test todo')
    })

    expect(result.current.todos).toHaveLength(1)
    expect(result.current.todos[0].text).toBe('Test todo')
    expect(result.current.todos[0].completed).toBe(false)
  })

  it('toggles a todo', () => {
    const { result } = renderHook(() => useTodoStore())

    act(() => {
      result.current.addTodo('Test todo')
    })

    const todoId = result.current.todos[0].id

    act(() => {
      result.current.toggleTodo(todoId)
    })

    expect(result.current.todos[0].completed).toBe(true)
  })

  it('filters todos', () => {
    const { result } = renderHook(() => useTodoStore())

    act(() => {
      result.current.addTodo('Todo 1')
      result.current.addTodo('Todo 2')
      result.current.toggleTodo(result.current.todos[0].id)
    })

    act(() => {
      result.current.setFilter('active')
    })

    expect(result.current.filteredTodos()).toHaveLength(1)
    expect(result.current.filteredTodos()[0].text).toBe('Todo 2')
  })
})
```

### Testing Custom Hooks

```typescript
// useLocalStorage.test.ts
import { renderHook, act } from '@testing-library/react'
import { useLocalStorage } from './useLocalStorage'

describe('useLocalStorage', () => {
  beforeEach(() => {
    localStorage.clear()
  })

  it('returns initial value', () => {
    const { result } = renderHook(() => useLocalStorage('key', 'initial'))

    expect(result.current[0]).toBe('initial')
  })

  it('updates value', () => {
    const { result } = renderHook(() => useLocalStorage('key', 'initial'))

    act(() => {
      result.current[1]('updated')
    })

    expect(result.current[0]).toBe('updated')
    expect(localStorage.getItem('key')).toBe(JSON.stringify('updated'))
  })

  it('loads from localStorage', () => {
    localStorage.setItem('key', JSON.stringify('stored'))

    const { result } = renderHook(() => useLocalStorage('key', 'initial'))

    expect(result.current[0]).toBe('stored')
  })
})
```

## Best Practices

### State Design
1. **Co-location**: Keep state close to where it's used
2. **Single Source of Truth**: Don't duplicate state
3. **Derived State**: Compute from existing state
4. **Normalized State**: Flat structures for relational data
5. **Immutability**: Never mutate state directly

### Performance
1. **Selectors**: Subscribe to specific slices
2. **Memoization**: Use useMemo, React.memo
3. **Lazy Initialization**: Defer expensive computations
4. **Batching**: Group state updates
5. **Code Splitting**: Lazy load state modules

### Architecture
1. **Separation of Concerns**: UI vs state logic
2. **Type Safety**: TypeScript for all state
3. **Testability**: Pure functions, isolated logic
4. **Scalability**: Modular state organization
5. **Debugging**: DevTools integration

### When to Use What

**Local State (useState, useReducer)**
- UI state (open/closed, hover)
- Form inputs
- Single component only

**Context**
- Theme, language
- User authentication
- Shared across tree
- Infrequent updates

**Zustand**
- Global app state
- Simple API needed
- Good DevTools
- Middleware support

**Jotai**
- Atomic state needs
- Bottom-up architecture
- Granular updates
- TypeScript-first

**XState**
- Complex workflows
- Explicit states matter
- Visual diagrams needed
- Finite state machines

## When to Use This Skill

Activate this skill when you need to:
- Design state architecture for components
- Implement React Context patterns
- Create XState state machines
- Set up Zustand or Jotai stores
- Build custom state hooks
- Optimize state performance
- Test state management logic
- Document state APIs
- Migrate between state solutions
- Debug state issues

## Output Format

When implementing state management, provide:
1. **Complete State Solution**: Production-ready code
2. **Type Definitions**: TypeScript types for all state
3. **API Documentation**: How to use the state
4. **Test Suite**: Comprehensive state tests
5. **Performance Notes**: Optimization strategies
6. **Usage Examples**: Real-world integration

Always build state management that is predictable, testable, performant, and maintainable.
