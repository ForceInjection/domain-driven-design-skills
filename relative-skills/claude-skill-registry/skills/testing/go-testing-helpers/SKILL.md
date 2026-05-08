---
name: go-testing-helpers
description: Test helper patterns with t.Helper()
---

# Test Helpers

Extract common test logic into helper functions with t.Helper().

## CORRECT

```go
func assertEqual(t *testing.T, got, want interface{}) {
    t.Helper()  // Reports caller line, not helper line
    if got != want {
        t.Errorf("got %v, want %v", got, want)
    }
}

func assertNoError(t *testing.T, err error) {
    t.Helper()
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}

func Test_Process(t *testing.T) {
    result, err := Process("input")
    assertNoError(t, err)
    assertEqual(t, result, "expected")
}
```

**Why:**
- t.Helper() marks function as helper
- Error reports show caller line, not helper line
- Reduces test boilerplate
- Consistent assertion patterns

## WRONG

```go
func assertEqual(t *testing.T, got, want interface{}) {
    // Missing t.Helper()
    if got != want {
        t.Errorf("got %v, want %v", got, want)
    }
}
```

**Problems:**
- Errors point to helper line
- Hard to find actual test failure
- Confusing stack traces
