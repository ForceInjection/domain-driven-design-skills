---
name: testing-flexible
description: Use when implementing features to write effective tests. Encourages test-first but allows prototyping.
---

# Flexible Testing

## Overview

Write tests for critical paths and complex logic. Test-first is encouraged but not mandatory.

**Core principle:** Tests should give you confidence, not slow you down.

## When to Use

**Strong recommendation (test-first):**
- Complex business logic
- Edge cases and error handling
- Security-critical code
- Bug fixes (test reproduces bug first)
- Public API surfaces

**Optional (test-after or skip):**
- UI/view code that changes frequently
- Prototype/exploration phase
- Configuration and setup
- Generated code
- Simple CRUD operations

## Two Modes

### Production Mode (Default)

Write tests for critical functionality. Test-first encouraged.

```
1. Write failing test for critical behavior
2. Implement minimal code to pass
3. Add tests for edge cases
4. Refactor with confidence
```

### Prototype Mode

Exploring ideas? Skip tests temporarily.

```
1. Build the prototype
2. Get feedback, iterate
3. Once design is stable: write tests
4. Or: throw away prototype, rebuild with tests
```

**To enter prototype mode:** Tell Claude "I'm prototyping" or "skip tests for now"

## What to Test

### Always Test

| Area | Why |
|------|-----|
| Business logic | Core value of your app |
| Data transformations | Easy to get wrong |
| API responses | Contract with clients |
| Auth/permissions | Security critical |
| Error handling | Users will hit edge cases |

### Consider Testing

| Area | When |
|------|------|
| UI components | When logic is complex |
| Integration points | When external APIs involved |
| Performance | When SLAs matter |

### Usually Skip

| Area | Why |
|------|-----|
| UI layout | Changes frequently, hard to test |
| Third-party code | Already tested |
| Trivial getters/setters | No logic to test |
| Generated code | Trust the generator |

## Test-First Pattern

When you do write test-first, follow RED-GREEN-REFACTOR:

### RED - Failing Test
```typescript
test('retries failed operations 3 times', async () => {
  let attempts = 0;
  const operation = () => {
    attempts++;
    if (attempts < 3) throw new Error('fail');
    return 'success';
  };

  const result = await retryOperation(operation);

  expect(result).toBe('success');
  expect(attempts).toBe(3);
});
```

### GREEN - Make It Pass
```typescript
async function retryOperation<T>(fn: () => Promise<T>): Promise<T> {
  for (let i = 0; i < 3; i++) {
    try {
      return await fn();
    } catch (e) {
      if (i === 2) throw e;
    }
  }
  throw new Error('unreachable');
}
```

### REFACTOR - Clean Up
Once tests pass, improve the code while keeping tests green.

## Swift/XCTest Specifics

### Basic Test Structure
```swift
import XCTest
@testable import YourApp

final class GradingServiceTests: XCTestCase {

    func test_gradeReturnsScoreForValidImage() async throws {
        let service = GradingService()
        let result = try await service.grade(image: testImage)

        XCTAssertNotNil(result.score)
        XCTAssertGreaterThan(result.score!, 0)
    }

    func test_gradeThrowsForInvalidImage() async {
        let service = GradingService()

        do {
            _ = try await service.grade(image: Data())
            XCTFail("Expected error")
        } catch {
            // Expected
        }
    }
}
```

### Testing Actors
```swift
func test_actorStateIsolated() async {
    let service = SyncService()

    // Actor methods are async
    await service.sync(item: testItem)

    let synced = await service.pendingItems
    XCTAssertTrue(synced.isEmpty)
}
```

### Testing @Observable
```swift
func test_authStateUpdatesOnSignIn() async throws {
    let authService = AuthService()

    XCTAssertFalse(authService.isAuthenticated)

    try await authService.signIn(with: mockCredentials)

    XCTAssertTrue(authService.isAuthenticated)
}
```

## TypeScript/Vitest Specifics

### Basic Test Structure
```typescript
import { describe, it, expect } from 'vitest'
import { gradeImage } from './grading'

describe('gradeImage', () => {
  it('returns score for valid image', async () => {
    const result = await gradeImage(testImageBase64)

    expect(result.score).toBeDefined()
    expect(result.score).toBeGreaterThan(0)
  })

  it('throws for invalid image', async () => {
    await expect(gradeImage('')).rejects.toThrow()
  })
})
```

### Testing Edge Functions
```typescript
import { createClient } from '@supabase/supabase-js'

describe('process-item function', () => {
  it('returns 401 without auth', async () => {
    const response = await fetch(`${FUNCTION_URL}/process-item`, {
      method: 'POST',
      body: JSON.stringify({ itemId: '123' })
    })

    expect(response.status).toBe(401)
  })
})
```

## Good Tests

| Quality | Good | Bad |
|---------|------|-----|
| **Focused** | One behavior per test | `test('validates, saves, and notifies')` |
| **Readable** | Clear name describes what's tested | `test('test1')` |
| **Independent** | No shared state between tests | Tests fail in isolation |
| **Fast** | Milliseconds, not seconds | Slow tests get skipped |

## When Tests Are Hard

If testing is painful, the design might be the problem:

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Need many mocks | Too coupled | Dependency injection |
| Huge setup | Complex object graph | Simplify design |
| Flaky tests | Hidden state/timing | Make dependencies explicit |
| Can't test in isolation | God objects | Break into smaller units |

## Checklist Before Shipping

```
[ ] Critical paths have tests
[ ] Edge cases covered
[ ] Error cases handled
[ ] Tests pass
[ ] No flaky tests
```

Don't need 100% coverage. Need confidence in critical functionality.
