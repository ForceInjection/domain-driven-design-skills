---
name: unit-testing
description: Use when working with unit tests in any capacity - reading, writing, updating, planning, evaluating, or reviewing tests - applies TDD principles with focused test coverage, filtering out redundant tests while ensuring critical paths, edge cases, and state changes are verified
---

# Unit Testing

## Overview

Write meaningful unit tests following TDD principles. Focus on critical behavior verification while automatically filtering out redundant, implementation-detail, and implicitly-covered tests.

**Core principle:** Test behavior (what code does), not configuration (how it's set up). Each test should verify distinct, important behavior. If a test feels redundant, skip it.

**How to invoke:**
```
Skill({ skill: "unit-testing" })
```

**When to invoke:** ANY time you're working with unit tests - reading, writing, updating, planning, evaluating, reviewing, or discussing test strategies.

## Behavior vs Configuration

**❌ Configuration Testing (Don't Do This)**
- Verifying object properties are set correctly
- Checking that dependencies were injected
- Testing that config objects have expected structure
- Verifying method calls happen in specific order (unless order affects behavior)

**✅ Behavior Testing (Do This)**
- Verifying outcomes of operations
- Testing state changes from actions
- Validating transformations of data
- Checking responses to different inputs

### Real Examples

**Scenario: User Authentication Service**

```typescript
// ❌ Configuration Test - SKIP THIS
test('should have bcrypt hasher configured', () => {
  expect(authService.hasher).toBeInstanceOf(BcryptHasher)
})

// ✅ Behavior Test - DO THIS
test('should return false when password is incorrect', () => {
  const result = authService.login('user@example.com', 'wrongpass')
  expect(result.success).toBe(false)
})
```

**Scenario: Shopping Cart**

```typescript
// ❌ Configuration Test - SKIP THIS
test('should initialize with empty items array', () => {
  const cart = new ShoppingCart()
  expect(cart.items).toEqual([])
  expect(cart.items.length).toBe(0)
})

// ✅ Behavior Test - DO THIS
test('should calculate correct total when items are added', () => {
  const cart = new ShoppingCart()
  cart.add({ price: 10.00, quantity: 2 })
  cart.add({ price: 5.00, quantity: 1 })

  expect(cart.getTotal()).toBe(25.00)
})
```

**Scenario: Email Notification Service**

```typescript
// ❌ Configuration Test - SKIP THIS
test('should have email provider injected', () => {
  expect(notificationService.emailProvider).toBeDefined()
})

// ✅ Behavior Test - DO THIS
test('should send email when order is confirmed', () => {
  notificationService.onOrderConfirmed({ orderId: 123, email: 'test@example.com' })

  expect(mockEmailProvider.send).toHaveBeenCalledWith(
    expect.objectContaining({ to: 'test@example.com' })
  )
})
```

**The Key Question:**
> "If this test passes, does it prove the feature actually works?"

- If yes → It's testing behavior ✅
- If no → It's testing configuration ❌

## When to Use This Skill

**INVOKE THIS SKILL whenever you're working with unit tests in ANY capacity:**

### Always Invoke For
- **Writing** tests for new functionality
- **Updating** tests for modified code
- **Reading** test files to understand coverage
- **Planning** test strategies or test cases
- **Evaluating** whether tests are sufficient
- **Reviewing** test quality or completeness
- **Refactoring** existing test suites
- **Discussing** testing approaches or edge cases
- **Analyzing** test failures or coverage gaps

### The Rule
If unit tests are involved in any way → invoke `unit-testing` skill

### Do NOT Use For
- Integration tests (use integration-testing skill if available)
- E2E tests (use e2e-testing skill if available)
- Performance tests

## Test Selection Criteria

### Write Tests For

**Observable behavior and outcomes**
- What happens when methods are called (return values, state changes)
- How data is transformed (input → processing → output)
- What side effects occur (events, external calls, mutations)
- How the system responds to different inputs

**Critical edge cases**
- Null/undefined inputs and their outcomes
- Empty data structures ([], {}, "") and how they're handled
- Boundary conditions (min/max values, array bounds) and responses
- Invalid input handling and error behavior

**State changes visible to consumers**
- Public state mutations that affect behavior
- Observable side effects (events emitted, calls made)
- Changes that future operations depend on
- Behavior changes in response to state

**Examples:**
```typescript
// ✅ Test behavior - what the code DOES
test('should return sorted users when sort() is called', () => {
  userManager.add({ name: 'Charlie' })
  userManager.add({ name: 'Alice' })

  const result = userManager.sort()

  expect(result[0].name).toBe('Alice')  // Verifies sorting behavior
})

// ❌ Test configuration - how the code IS SET UP
test('should have users array initialized', () => {
  expect(userManager.users).toBeDefined()  // Just checks property exists
  expect(Array.isArray(userManager.users)).toBe(true)  // Just checks type
})

// ✅ Test behavior - state changes
test('should increase count when user is added', () => {
  const initialCount = userManager.getCount()

  userManager.add({ name: 'Bob' })

  expect(userManager.getCount()).toBe(initialCount + 1)  // Verifies behavior
})

// ❌ Test configuration - dependency injection
test('should have logger injected', () => {
  expect(userManager.logger).toBe(mockLogger)  // Just verifies wiring
})
```

### Automatically Skip Tests For

**Configuration and setup (CRITICAL TO SKIP)**
- Testing that object properties exist or have correct types
- Verifying dependency injection worked correctly
- Checking that config objects match expected structure
- Testing that constructors set fields (unless logic involved)
- Verifying method call order (unless order affects observable behavior)

**Implementation details**
- Code formatting or whitespace
- Private methods (test through public API)
- Internal variable naming
- Method ordering
- How something is implemented vs what it does

**Redundant scenarios**
- Testing same logic with different enum values unless behavior differs
- Multiple positions in arrays when logic is position-agnostic
- Duplicate assertions of identical behavior
- Tests that only differ in input values but not logic paths

**Implicitly covered behavior**
- Functionality verified by other tests
- Simple getters/setters without logic
- Trivial delegations to other tested methods
- Behavior already proven by integration tests

**Multiple assertions of same behavior**
- Don't test string formatting 5 different ways
- Don't test each field separately if they use same mechanism
- Don't verify same outcome through different assertion styles

## Test Quality Standards

### Structure
Follow the Arrange-Act-Assert (AAA) pattern:

```
test 'should [expected behavior] when [condition]':
  // Arrange: Set up test data and mocks
  input = createTestInput()
  mock = createMock(expected)

  // Act: Execute the behavior
  result = method(input)

  // Assert: Verify outcomes
  assert result equals expected
  assert mock was called with input
```

### Naming Convention
- Use `should [expected behavior] when [condition]` format
- Be specific: "should return empty array when input is null"
- Not vague: "should work correctly"

### Test Independence
- Each test must be runnable in isolation
- No shared state between tests
- Use setup hooks for common initialization
- Clean up in teardown hooks if needed

### Mock Usage
- Mock external dependencies
- Don't mock the system under test
- Follow existing mocking patterns from codebase
- Verify mock interactions when they represent important behavior

## Target Coverage

**Focus on quality over quantity** - write only tests that verify distinct, important behavior.

Coverage goals:
- 100% of public API surface
- 100% of critical paths
- Representative edge cases (not exhaustive)
- Key error conditions

**Warning signs of over-testing:**
- Testing implementation details
- Being redundant
- Testing too granularly
- Each test doesn't add new confidence

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| **Testing configuration instead of behavior** | **Test what code does, not how it's set up** |
| Testing that properties were set | Test operations that use those properties |
| Verifying dependency injection | Test behavior that depends on dependencies |
| Testing private methods directly | Test through public API |
| Tests coupled to implementation | Test behavior, not structure |
| One assertion per test (too granular) | Group related assertions logically |
| Testing framework code | Only test your code |
| No arrange-act-assert structure | Follow AAA pattern |
| Brittle tests (break on refactor) | Test interface, not implementation |
| Conditionals in tests (if/else, switch) | Write separate tests for each case |

## NO CONDITIONALS IN TESTS (CRITICAL)

**Tests must NOT contain conditional logic (if/else, switch, ternary, loops with conditions).**

### Why Conditionals Are Banned

1. **Hidden failures**: Wrong branch executes silently, test "passes" but proves nothing
2. **Non-deterministic**: Test behavior depends on runtime state
3. **Hard to understand**: Reader can't tell which path was tested
4. **Debugging nightmare**: When test fails, unclear which branch caused it
5. **False confidence**: Test may never execute the assertion you think it does

### ❌ BAD: Tests with Conditionals

```typescript
// ❌ NEVER DO THIS - conditional in test
test('should handle user status', () => {
  const user = getUser()

  if (user.isActive) {
    expect(user.canLogin()).toBe(true)
  } else {
    expect(user.canLogin()).toBe(false)
  }
})

// ❌ NEVER DO THIS - ternary in assertion
test('should return correct value', () => {
  const result = calculate(input)
  const expected = isSpecialCase ? 10 : 20
  expect(result).toBe(expected)
})

// ❌ NEVER DO THIS - loop with conditional
test('should process all items', () => {
  for (const item of items) {
    if (item.type === 'special') {
      expect(process(item)).toBe('special-result')
    }
  }
})
```

### ✅ GOOD: Separate Tests for Each Case

```typescript
// ✅ DO THIS - separate test for active user
test('should allow login when user is active', () => {
  const user = createUser({ isActive: true })

  expect(user.canLogin()).toBe(true)
})

// ✅ DO THIS - separate test for inactive user
test('should deny login when user is inactive', () => {
  const user = createUser({ isActive: false })

  expect(user.canLogin()).toBe(false)
})

// ✅ DO THIS - explicit test data, no conditionals
test('should return 10 for special case', () => {
  const result = calculate(specialInput)
  expect(result).toBe(10)
})

test('should return 20 for normal case', () => {
  const result = calculate(normalInput)
  expect(result).toBe(20)
})

// ✅ DO THIS - test specific items explicitly
test('should process special items correctly', () => {
  const specialItem = createItem({ type: 'special' })

  expect(process(specialItem)).toBe('special-result')
})
```

### Parameterized Tests (Acceptable Alternative)

If you have many similar cases, use parameterized tests instead of conditionals:

```typescript
// ✅ OK - parameterized test (no runtime conditionals)
test.each([
  { input: 0, expected: 'zero' },
  { input: 1, expected: 'one' },
  { input: -1, expected: 'negative' },
])('should return $expected when input is $input', ({ input, expected }) => {
  expect(classify(input)).toBe(expected)
})
```

### The Rule

> **If you're tempted to write `if` in a test, write two tests instead.**

Each test should have exactly ONE path through it. The test name should tell you exactly what scenario is being tested, and the test body should prove that scenario works.

## TDD Workflow Integration

When adding tests:
1. **RED**: Write failing test for missing/changed behavior
2. **GREEN**: Verify test passes with current implementation
3. **VERIFY**: Comment out functionality, confirm test fails
4. **RESTORE**: Uncomment functionality, confirm test passes again
5. **REFACTOR**: Improve test clarity if needed

## Quick Reference

### Test Categories by Priority

| Priority | Category | Examples |
|----------|----------|----------|
| 1 | Happy path | Valid inputs → expected outputs |
| 2 | Critical edges | null, undefined, empty, boundaries |
| 3 | Error handling | Invalid inputs, exceptions |
| 4 | State changes | Mutations, side effects |
| 5 | Integration points | Service calls, data transforms |

### When Uncertain

Ask yourself:
1. **Does this test verify behavior (what it does) or configuration (how it's set up)?** → Behavior: Keep it, Configuration: Skip it
2. **Does this test verify distinct, observable outcomes?** → Keep it
3. **Would this test catch a real bug in behavior?** → Keep it
4. **Is this behavior already tested elsewhere?** → Skip it
5. **Am I testing implementation details or wiring?** → Skip it
6. **Would this test pass even if the feature was broken?** → Skip it (it's testing configuration)
7. **Would I write this test if I had to justify each one?** → Be honest
8. **Does this test contain if/else/switch/ternary?** → Split into separate tests

## Real-World Impact

**Before filtering (lots of configuration tests):**
- 47 tests for a module (20 were configuration tests)
- 30-minute test suite runtime
- Tests break on every refactor
- Hard to identify real failures
- False confidence from tests that don't verify behavior

**After filtering (behavior-only tests):**
- 12 focused behavior tests for same module
- 5-minute test suite runtime
- Tests survive refactoring
- Failures indicate real issues
- True confidence from tests that verify actual functionality

**Example Impact:**
```typescript
// Before: 8 tests that all passed but didn't catch bug
test('cart has items array')
test('cart items is array type')
test('cart total is number')
test('cart has addItem method')
// ... bug in total calculation logic went undetected

// After: 1 test that would have caught the bug
test('calculates correct total when items added')
// ✅ This would have failed when total calculation was broken
```

Fewer, better tests = higher confidence, faster feedback, real bug detection.
