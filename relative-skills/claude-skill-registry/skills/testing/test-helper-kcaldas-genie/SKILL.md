---
name: test-helper
description: Write comprehensive, idiomatic tests following best practices and project conventions. Use this when writing unit tests, integration tests, or test fixtures. Helps ensure proper test structure, mocking, assertions, and coverage.
---

# Test Helper Skill

You are an expert at writing high-quality tests that are maintainable, readable, and thorough. Use this skill when:
- Writing new tests
- Improving existing tests
- Setting up test fixtures or mocks
- Debugging failing tests
- Ensuring test coverage

## Testing Philosophy

### Core Principles
1. **Tests are Documentation**: Tests should clearly show how code is intended to be used
2. **Test Behavior, Not Implementation**: Focus on what the code does, not how
3. **Arrange-Act-Assert**: Structure tests with clear setup, execution, and verification
4. **One Concept Per Test**: Each test should verify a single behavior
5. **Fast and Isolated**: Tests should run quickly and independently

## Go Testing Patterns

### Basic Test Structure
```go
func TestFunctionName(t *testing.T) {
    // Arrange: Set up test data and dependencies
    input := "test data"
    expected := "expected result"

    // Act: Execute the function being tested
    result, err := FunctionName(input)

    // Assert: Verify the results
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if result != expected {
        t.Errorf("got %v, want %v", result, expected)
    }
}
```

### Table-Driven Tests
```go
func TestFunctionName(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
        wantErr  bool
    }{
        {
            name:     "valid input",
            input:    "test",
            expected: "result",
            wantErr:  false,
        },
        {
            name:     "invalid input",
            input:    "",
            expected: "",
            wantErr:  true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result, err := FunctionName(tt.input)

            if (err != nil) != tt.wantErr {
                t.Errorf("error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if result != tt.expected {
                t.Errorf("got %v, want %v", result, tt.expected)
            }
        })
    }
}
```

### Mock Interfaces
```go
type MockService struct {
    DoWorkFunc func(input string) (string, error)
}

func (m *MockService) DoWork(input string) (string, error) {
    if m.DoWorkFunc != nil {
        return m.DoWorkFunc(input)
    }
    return "", nil
}
```

### Test Fixtures
```go
func setupTest(t *testing.T) (*Component, func()) {
    // Setup
    component := NewComponent()

    // Return cleanup function
    return component, func() {
        // Cleanup
        component.Close()
    }
}

func TestWithFixture(t *testing.T) {
    component, cleanup := setupTest(t)
    defer cleanup()

    // Use component in test
}
```

## TypeScript/JavaScript Testing Patterns

### Jest/Vitest Structure
```typescript
describe('FunctionName', () => {
    it('should handle valid input', () => {
        // Arrange
        const input = 'test';
        const expected = 'result';

        // Act
        const result = functionName(input);

        // Assert
        expect(result).toBe(expected);
    });

    it('should throw on invalid input', () => {
        expect(() => functionName('')).toThrow();
    });
});
```

### Mocking with Jest
```typescript
jest.mock('../service');

describe('Component', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('should call service', async () => {
        const mockService = jest.fn().mockResolvedValue('result');
        const component = new Component(mockService);

        await component.doWork();

        expect(mockService).toHaveBeenCalledWith(expect.any(String));
    });
});
```

## Best Practices

### Test Organization
1. **Group Related Tests**: Use describe/subtests for related scenarios
2. **Descriptive Names**: Test names should explain what is being tested and expected outcome
3. **Test Files**: Keep test files next to the code they test (`file.go` → `file_test.go`)
4. **Test Packages**: Use `package_test` for integration tests, same package for unit tests

### What to Test
- ✅ **Public API**: All exported functions and methods
- ✅ **Edge Cases**: Empty inputs, nil values, boundaries
- ✅ **Error Paths**: How errors are handled and propagated
- ✅ **Integration**: How components work together
- ❌ **Private Implementation**: Don't test internal details
- ❌ **Third-Party Code**: Mock external dependencies

### Common Patterns to Check

#### Test for Nil/Empty Inputs
```go
func TestHandlesNilInput(t *testing.T) {
    _, err := Process(nil)
    if err == nil {
        t.Error("expected error for nil input")
    }
}
```

#### Test Concurrent Access
```go
func TestConcurrentAccess(t *testing.T) {
    var wg sync.WaitGroup
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            // Concurrent operations
        }()
    }
    wg.Wait()
}
```

#### Test Context Cancellation
```go
func TestContextCancellation(t *testing.T) {
    ctx, cancel := context.WithCancel(context.Background())
    cancel() // Cancel immediately

    err := Operation(ctx)
    if err != context.Canceled {
        t.Errorf("expected Canceled error, got %v", err)
    }
}
```

## Workflow

When asked to write tests:

1. **Understand the Code**
   - Read the function/method being tested
   - Identify inputs, outputs, and side effects
   - Note error conditions and edge cases

2. **Plan Test Cases**
   - Happy path (normal operation)
   - Edge cases (boundaries, special values)
   - Error cases (invalid inputs, failures)
   - Concurrent/async scenarios if applicable

3. **Write Tests**
   - Start with the happy path
   - Add edge cases
   - Cover error scenarios
   - Use table-driven tests for multiple similar cases

4. **Verify Coverage**
   - Run tests: `go test -v`
   - Check coverage: `go test -cover`
   - Detailed report: `go test -coverprofile=coverage.out`

5. **Review and Refactor**
   - Ensure tests are readable
   - Remove duplication
   - Verify test names are descriptive

## Project-Specific Conventions

Check the existing test files to identify:
- Naming conventions (`Test_`, `test`, `should_`)
- Assertion libraries (testify, assert)
- Mock frameworks
- Test helpers and utilities
- Setup/teardown patterns

## Common Gotchas

1. **Test Isolation**: Tests should not depend on each other
2. **Random Data**: Use fixed test data for reproducibility
3. **Time**: Mock time.Now() for time-dependent tests
4. **External Services**: Always mock network calls
5. **Cleanup**: Use defer or cleanup functions to avoid test pollution

When you finish writing tests, invoke the Skill tool with an empty skill name to clear this context.
