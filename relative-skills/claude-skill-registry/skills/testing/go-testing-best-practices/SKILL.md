---
name: Go Testing Best Practices
description: This skill should be used when the user asks about "Go test conventions", "ADR-008", "test naming", "table-driven tests", "go testing patterns", "testify", "how to write go tests", or needs guidance on Go testing methodology. Provides comprehensive guidance on high-quality Go testing following established conventions.
---

# Go Testing Best Practices

## Overview

This skill provides guidance on writing high-quality Go tests that catch regressions, document behavior, and enable safe refactoring.

## Core Philosophy

Coverage is a discovery metric, not the goal. The real goals are:

1. **Catch regressions** - tests fail when behavior breaks
2. **Document behavior** - tests show how code should be used
3. **Enable safe refactoring** - tests don't break when internals change

**10 tests that assert invariants > 100 tests that check magic strings.**

## ADR-008 Naming Convention

All test functions must follow this format:

```
Test[Component]_[ExpectedBehaviour]_When_[StateUnderTest]
```

### Examples

| Test Name | Component | Expected Behaviour | State Under Test |
|-----------|-----------|-------------------|------------------|
| `TestValidator_RejectsInput_When_SchemaIsInvalid` | Validator | RejectsInput | SchemaIsInvalid |
| `TestCache_ReturnsStaleValue_When_RefreshFails` | Cache | ReturnsStaleValue | RefreshFails |
| `TestParser_ParsesEmptyInput_When_InputIsNil` | Parser | ParsesEmptyInput | InputIsNil |

### Anti-patterns

Avoid vague names:
- `TestFoo` - unclear what's being tested
- `TestSuccess` - doesn't describe behavior
- `TestError` - which error?

## Test Package Strategy

### Black-box Testing (Preferred)

```go
package foo_test  // External test package

import "your/module/foo"

func TestFoo_DoesX_When_Y(t *testing.T) {
    // Tests only the public API
    result := foo.Process(input)
}
```

**Why:** Tests survive refactoring. If internals change but behavior stays the same, tests still pass.

### White-box Testing (When Necessary)

```go
package foo  // Same package

func TestInternalState_UpdatesCorrectly_When_Modified(t *testing.T) {
    // Has access to unexported fields/functions
}
```

**When:** Only when testing unexported state is essential (e.g., verifying internal cleanup).

## Table-Driven Tests

Always use table-driven tests with `t.Run` subtests:

```go
func TestComponent_Behaviour_When_State(t *testing.T) {
    t.Parallel()

    tests := []struct {
        name    string
        input   Input
        want    Output
        wantErr error
        inspect func(*testing.T, Output)  // Optional invariant checks
    }{
        {
            name:    "error: nil input",
            input:   nil,
            wantErr: ErrNilInput,
        },
        {
            name:  "success: valid input",
            input: validInput,
            want:  expectedOutput,
            inspect: func(t *testing.T, out Output) {
                assert.True(t, out.Count >= 0, "count invariant")
            },
        },
    }

    for _, tc := range tests {
        tc := tc  // Capture for parallel
        t.Run(tc.name, func(t *testing.T) {
            t.Parallel()

            got, err := Process(tc.input)

            if tc.wantErr != nil {
                require.ErrorIs(t, err, tc.wantErr)
                return
            }
            require.NoError(t, err)

            if diff := cmp.Diff(tc.want, got); diff != "" {
                t.Errorf("mismatch (-want +got):\n%s", diff)
            }

            if tc.inspect != nil {
                tc.inspect(t, got)
            }
        })
    }
}
```

## Assertion Libraries

### require vs assert

- **`require`**: Fails immediately. Use for setup/preconditions.
- **`assert`**: Continues after failure. Use for verifications.

```go
// Setup - use require (fail fast)
conn, err := db.Connect()
require.NoError(t, err)

// Verification - use assert (see all failures)
assert.Equal(t, expected, got)
assert.True(t, result.IsValid())
```

### cmp.Diff for Structs

For complex struct comparisons, use `github.com/google/go-cmp/cmp`:

```go
if diff := cmp.Diff(want, got); diff != "" {
    t.Errorf("mismatch (-want +got):\n%s", diff)
}
```

## Prioritization

### What to Test First

**Tier 1 - Critical paths:**
- Packages with <50% coverage
- Functions that mutate state
- Parsers and marshalers
- Security/auth logic
- Database operations

**Tier 2 - Complex logic:**
- Functions with high cyclomatic complexity
- Error handling wrappers
- Orchestration code

**Tier 3 - Supporting utilities:**
- Well-understood helpers
- Stable code with good coverage

### Risk Identification

Look for these patterns in code:
- Functions >50 lines
- Multiple error returns
- Concurrency (goroutines, mutexes, channels)
- File/network I/O
- JSON parsing
- External process execution

## Common Anti-patterns

| Anti-pattern | Problem | Fix |
|--------------|---------|-----|
| `time.Sleep` in tests | Flaky, slow | Use channels or test clocks |
| Testing private fields | Breaks on refactor | Test through public API |
| Mocking third-party libs | Brittle | Wrap in interface you own |
| Only happy path | Misses bugs | Test error paths first |
| `err != nil` check only | Doesn't verify error type | Use `require.ErrorIs` |

## Test Fixtures

Use `testdata/` directory for test fixtures:

```
package/
  foo.go
  foo_test.go
  testdata/
    valid_input.json
    invalid_input.json
    expected_output.golden
```

Access in tests:
```go
data, err := os.ReadFile("testdata/valid_input.json")
```

## Validation Commands

```bash
# Run all tests with race detector
go test -race ./...

# Run with coverage
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out | sort -k3n

# Find uncovered packages
go tool cover -func=coverage.out | awk '$3 < 50.0 {print}'
```
