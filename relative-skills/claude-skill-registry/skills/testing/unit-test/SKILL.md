---
name: unit-test
description: Guide for writing unit tests with Vitest. Use when writing tests for service functions, pure logic, or webhook handlers. Covers TDD Red-Green-Refactor cycle, Arrange-Act-Assert pattern, anti-patterns, pure function testing, and mocking at boundaries.
---

# Unit Testing

Test pure business logic in isolation. Mock system boundaries (DB, webhooks, external APIs). Verify calculated values, not side effects.

## TDD Cycle (Non-Negotiable)

**RED → GREEN → REFACTOR**. Every feature. Every bug fix.

- **RED**: Write failing test first. If it passes, your test is wrong.
- **GREEN**: Minimum code to pass. Hardcode if needed.
- **REFACTOR**: Clean up while green. Run tests after every change.

```typescript
// RED
test("calculates score", () => expect(calculateScore({ reps: 10, weight: 135 })).toBe(1350)) // FAILS
// GREEN - hardcode
function calculateScore(data) { return 1350 }
// RED - force real logic
test("different score", () => expect(calculateScore({ reps: 5, weight: 100 })).toBe(500)) // FAILS
// GREEN - implement
function calculateScore(data) { return data.reps * data.weight }
```

## Arrange-Act-Assert Pattern

```typescript
test("applies discount", () => {
  // ARRANGE
  const price = 100, discount = 0.2
  // ACT
  const result = applyDiscount(price, discount)
  // ASSERT
  expect(result).toBe(80)
})
```

**One concept per test**: Multiple assertions OK if testing same concept.

```typescript
// GOOD: One concept
test("returns errors for invalid workout", () => {
  const result = validateWorkout({})
  expect(result.valid).toBe(false)
  expect(result.errors).toContain("name required")
})

// BAD: Multiple concepts
test("validates and saves", () => {
  expect(validateWorkout({}).valid).toBe(false)
  expect(saveWorkout({ name: "Fran" }).id).toBeDefined()
})
```

## Anti-Patterns

**Overspecified Tests** (THE WORST) - Testing HOW instead of WHAT.

```typescript
// BAD: Implementation details
test("processes", () => {
  processor.initialize() // internal
  expect(processor.state).toBe("ready") // internal
})

// GOOD: Behavior
test("processes valid workout", () => {
  expect(processWorkout({ name: "Fran" }).success).toBe(true)
})
```

**Testing State Not Behavior**

```typescript
// BAD
test("sets score", () => {
  scorer.calculate(10, 135)
  expect(scorer.score).toBe(1350) // internal field
})

// GOOD
test("calculates score", () => {
  expect(scorer.calculate(10, 135)).toBe(1350)
})
```

**Multiple Unrelated Assertions**

```typescript
// BAD: Which failed?
test("validation", () => {
  expect(validateName("")).toBe(false)
  expect(validateType("x")).toBe(false)
})

// GOOD: Split tests
test("rejects empty name", () => expect(validateName("")).toBe(false))
test("rejects invalid type", () => expect(validateType("x")).toBe(false))
```

## Pure Function Testing

Separate calculations (pure) from side effects (DB, webhooks).

```typescript
// Bad: mixed
async function processWebhook(event) {
  const score = event.reps * event.weight
  await db.insert(scores).values({ score })
}

// Good: separated
function calculateScore(data) { return data.reps * data.weight } // pure

async function processWebhook(event) {
  const score = calculateScore(event.data) // pure
  await db.insert(scores).values({ score }) // side effect
}

// Test pure function - no mocks
test("calculates score", () => {
  expect(calculateScore({ reps: 10, weight: 135 })).toBe(1350)
})
```

## Mocking at Boundaries

Mock DB, auth, APIs. Test logic between them.

```typescript
vi.mock("@/server/workouts", () => ({
  getWorkoutById: vi.fn(),
  updateWorkout: vi.fn(),
}))

beforeEach(() => {
  vi.clearAllMocks()
  vi.mocked(getWorkoutById).mockResolvedValue({ id: "w-123" })
})

test("updates workout", async () => {
  const [data, err] = await updateWorkoutAction({
    id: "w-123", workout: { name: "Updated" }
  })
  
  expect(err).toBeNull()
  expect(updateWorkout).toHaveBeenCalledWith({
    id: "w-123", workout: { name: "Updated" }
  })
})
```

## What to Test vs Mock

**Test**: Calculations, transformations, validation, business rules
**Mock**: Database, external APIs, auth, webhooks, file system

## Breaking Dependencies

Hard to test? Use dependency-breaking techniques.

**See `testing-patterns` skill**: `skills_use(name="testing-patterns")`
- 25 techniques, seam model, characterization tests

Quick: **Parameterize Constructor**, **Extract Interface**, **Subclass & Override**

```typescript
// Before
class Processor { process() { new ProductionDB().save() } }

// After - inject dependency
class Processor {
  constructor(private db = new ProductionDB()) {}
  process() { this.db.save() }
}

// Test
new Processor(new FakeDB())
```

## Organization & Running

**Structure**: `test/lib/` (pure functions), `test/server/` (services, mock DB), `test/actions/` (actions, mock services)

**Run**: `pnpm test` (all), `pnpm test -- path/to/file.test.ts` (single)

## Principles

1. **RED → GREEN → REFACTOR** - no exceptions
2. **Pure functions** - easier to test, no mocks
3. **Mock boundaries** - DB, auth, APIs
4. **Behavior not state** - what it does, not how
5. **One concept per test** - clear failures
6. **Arrange-Act-Assert** - consistent structure
