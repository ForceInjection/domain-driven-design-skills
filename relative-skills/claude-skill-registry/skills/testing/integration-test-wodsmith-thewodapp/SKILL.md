---
name: integration-test
description: Guide for writing integration tests with Vitest and Testing Library. Use when testing multi-component workflows, database interactions, React components with context providers, or full user flows. Covers the Testing Trophy philosophy (integration > unit), factory patterns for test data, MSW for network mocking, async testing patterns (waitFor, findBy), and custom render with providers. Use this for tests that cross multiple modules or layers of the application.
---

# Integration Testing

Integration tests verify that multiple parts of the system work together correctly. They provide more confidence than unit tests because they test real interactions with less mocking.

## Testing Trophy Philosophy

Integration tests sit at the sweet spot of the Testing Trophy:

```
    /\
   /  \  E2E (slowest, highest confidence)
  /----\
 / INT  \ Integration (SWEET SPOT)
/--------\
|  UNIT  | Unit (fastest, lowest confidence)
|________|
 STATIC   (lint, types)
```

**Why integration > unit:**

- **Less mocking = more confidence** - Test real interactions, not mocked approximations
- **Refactoring doesn't break tests** - Testing behavior, not implementation details
- **Unit tests can pass while app is broken** - Integration tests catch integration bugs
- **Better ROI** - More coverage per test, catches more bug types

## When to Use Integration Tests

✅ **Use integration tests when:**

- Testing workflows that span multiple components/modules
- Verifying database operations (read → transform → write)
- Testing React components that use context providers
- Testing full user flows (auth, forms, multi-step processes)
- Testing server actions that call multiple services
- Verifying API endpoints with real request/response

❌ **Don't use integration tests when:**

- Testing pure functions (use unit tests - no mocking needed)
- Testing simple utility functions
- Testing isolated business logic calculations

**Decision heuristic:** If you need >3 mocks, it's probably better as an integration test.

## Core Patterns

### 1. Factory Pattern for Test Data

Use factories to create test data with sensible defaults and override support. See `references/factory-patterns.md` for detailed examples.

**Quick example:**

```typescript
const user = createUser() // defaults
const admin = createUser({ role: "admin" }) // override
const session = createTestSession({ userId: user.id, permissions: ["edit_workouts"] })
```

**Benefits:**

- Consistent test data across tests
- Override only what matters for the test
- Self-documenting defaults
- Easy to maintain (change defaults in one place)

### 2. Database Testing with Fake DB

Use `FakeDatabase` from `@repo/test-utils` to test database operations without hitting a real database:

```typescript
import { FakeDatabase } from "@repo/test-utils/fakes/fake-db"
import { createUser, createTeam } from "@repo/test-utils/factories"

const db = new FakeDatabase<{ users: User; teams: Team }>()

// Insert test data
const user = db.insert("users", createUser())
const team = db.insert("teams", createTeam({ ownerId: user.id }))

// Test your code
const result = await yourFunction(db, team.id)

// Verify
const updated = db.findById("teams", team.id)
expect(updated.name).toBe("Updated Name")
```

**FakeDatabase enforces D1's 100 parameter limit** - catches batch query bugs early.

### 3. MSW for Network Mocking

Mock at the **network boundary**, not at the function level. Use Mock Service Worker (MSW) to intercept HTTP requests:

```typescript
import { http, HttpResponse } from "msw"
import { setupServer } from "msw/node"

const server = setupServer(
  http.get("/api/workouts", () => {
    return HttpResponse.json([
      { id: "w1", name: "Fran" },
      { id: "w2", name: "Grace" },
    ])
  })
)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

it("fetches and displays workouts", async () => {
  render(<WorkoutList />)
  
  // Component fetches /api/workouts
  await waitFor(() => {
    expect(screen.getByText("Fran")).toBeInTheDocument()
  })
})
```

**Why MSW > function mocks:**

- Tests real fetch/axios calls
- Catches serialization issues
- Tests error handling (network failures, 500s)
- Same mock setup works for browser and Node.js

### 4. Async Testing Patterns

**NEVER use arbitrary timeouts** (`setTimeout`, `sleep`). Use Testing Library's async utilities:

```typescript
// ❌ BAD - flaky, slow
it("shows success message", async () => {
  submitForm()
  await new Promise(resolve => setTimeout(resolve, 1000))
  expect(screen.getByText("Success")).toBeInTheDocument()
})

// ✅ GOOD - fast, reliable
it("shows success message", async () => {
  submitForm()
  expect(await screen.findByText("Success")).toBeInTheDocument()
})

// ✅ GOOD - with custom condition
it("updates status", async () => {
  submitForm()
  await waitFor(() => {
    expect(screen.getByTestId("status")).toHaveTextContent("Complete")
  })
})
```

**Async query variants:**

| Query Type | Returns Immediately | Waits for Element | Use When |
|------------|---------------------|-------------------|----------|
| `getBy*` | ✅ throws if not found | ❌ No | Element should be there |
| `queryBy*` | ✅ returns null | ❌ No | Checking absence |
| `findBy*` | ❌ Promise | ✅ Yes (default 1s) | Async rendering |

**Prefer `findBy*` for async content:**

```typescript
// Automatically waits up to 1s, retries every 50ms
const element = await screen.findByRole("button", { name: "Submit" })
```

### 5. Testing React Components with Providers

Use a custom render function to wrap components in necessary providers:

```typescript
import { render } from "@testing-library/react"
import { SessionProvider } from "@/components/session-provider"
import { createTestSession } from "@repo/test-utils/factories"

function renderWithSession(ui: React.ReactElement, session = createTestSession()) {
  return render(
    <SessionProvider session={session}>
      {ui}
    </SessionProvider>
  )
}

it("shows user name when logged in", () => {
  const session = createTestSession({ user: { firstName: "Alice" } })
  renderWithSession(<Dashboard />, session)
  
  expect(screen.getByText("Welcome, Alice")).toBeInTheDocument()
})
```

**Common providers to wrap:**

- `SessionProvider` - auth state
- `QueryClientProvider` - React Query
- `ThemeProvider` - styling
- Custom context providers

## Multi-Component Testing Example

```typescript
import { describe, it, expect, beforeEach } from "vitest"
import { render, screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { FakeDatabase } from "@repo/test-utils/fakes/fake-db"
import { createTestSession, createWorkout } from "@repo/test-utils/factories"

describe("Workout Subscription Flow", () => {
  let db: FakeDatabase<{ workouts: Workout; subscriptions: Subscription }>
  let session: SessionWithMeta
  
  beforeEach(() => {
    db = new FakeDatabase()
    session = createTestSession({ permissions: ["subscribe_to_workouts"] })
    
    // Seed test data
    const workout = db.insert("workouts", createWorkout({ name: "CrossFit Open 24.1" }))
  })
  
  it("allows user to subscribe to a workout", async () => {
    const user = userEvent.setup()
    render(<WorkoutCatalog db={db} />, { wrapper: SessionProvider })
    
    // Step 1: Find workout
    expect(await screen.findByText("CrossFit Open 24.1")).toBeInTheDocument()
    
    // Step 2: Click subscribe
    await user.click(screen.getByRole("button", { name: "Subscribe" }))
    
    // Step 3: Verify subscription created
    await waitFor(() => {
      const subscriptions = db.findAll("subscriptions")
      expect(subscriptions).toHaveLength(1)
      expect(subscriptions[0].workoutId).toBe(workout.id)
    })
    
    // Step 4: UI updates
    expect(screen.getByText("Subscribed")).toBeInTheDocument()
  })
})
```

## File Organization

```
test/
├── integration/         # Multi-component/multi-layer tests
│   ├── programming-subscription.test.ts
│   ├── auth-flow.test.ts
│   └── checkout-flow.test.ts
├── actions/             # Server action tests (mock services)
│   └── workout-actions.test.ts
├── server/              # Service tests (mock DB)
│   └── workouts.test.ts
└── lib/                 # Pure function tests (no mocks)
    └── scoring/
        └── validate.test.ts
```

**Integration tests go in `test/integration/`** when they cross boundaries (UI + server + DB).

## Running Tests

```bash
pnpm test                                      # all tests
pnpm test test/integration/                   # integration tests only
pnpm test -- programming-subscription.test.ts # single file
```

## Key Principles

1. **Mock at boundaries, not internals** - Network (MSW), DB (FakeDatabase), external APIs
2. **Test behavior, not implementation** - User actions → expected outcomes
3. **Use factories for consistent data** - Override only what matters
4. **Async utilities over timeouts** - `findBy*`, `waitFor`, never `setTimeout`
5. **Custom render for providers** - Wrap components in necessary context
6. **Enforce real constraints** - FakeDatabase enforces D1's parameter limits

## Additional Resources

- **Factory Patterns** - See `references/factory-patterns.md` for detailed factory examples
- **Testing Library Docs** - https://testing-library.com/docs/queries/about
- **MSW Docs** - https://mswjs.io/docs/
- **Vitest Docs** - https://vitest.dev/
