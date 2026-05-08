---
name: csharp-unit-testing
description: Expert-level C# unit testing skill based on ISTQB standards and best practices. Use this skill when creating, reviewing, or refactoring unit tests for C# applications (.NET/ASP.NET Core). Applies test design techniques, coverage strategies, and quality assurance principles from ISTQB Foundation and Advanced levels.
license: Complete terms in LICENSE.txt
---

# C# Unit Testing Skill (ISTQB-Compliant)

This skill provides comprehensive guidance for creating high-quality unit tests in C# following ISTQB (International Software Testing Qualifications Board) standards and industry best practices.

## When to Use This Skill

Use this skill when you need to:
- **Create unit tests** for C# classes, methods, and business logic
- **Review test quality** for compliance with ISTQB standards and best practices
- **Design test cases** using systematic test design techniques (equivalence partitioning, boundary value analysis, etc.)
- **Refactor existing tests** to improve maintainability, coverage, and clarity
- **Establish test strategies** for ensuring comprehensive coverage
- **Write integration tests** that bridge unit and system testing levels
- **Debug failing tests** and improve test reliability
- **Set up test fixtures, mocks, and test data** properly

## ISTQB Testing Levels

Unit tests primarily address the **Component Testing** (unit) level, which verifies:
- Individual units of code work as specified
- Interactions between closely related components
- Error handling and boundary conditions
- Performance characteristics at the component level

## Core Testing Principles

### 1. Test Purpose & Scope
Every unit test must have a **single, clear purpose**. Identify:
- **What** is being tested (specific method/behavior)
- **Why** it matters (business value, risk mitigation)
- **How** it will be validated (assertions, exceptions)

### 2. Naming Convention (AAA + Clear Intent)
```
[Public Method Name]_[Scenario]_[Expected Result]
```

Example: `CalculateDiscount_WithValidPercentage_ReturnsCorrectAmount`

Follow these naming rules:
- Use descriptive names (3-5 words minimum)
- Avoid cryptic abbreviations
- Express the expected outcome, not implementation details
- Use PascalCase consistently

### 3. Test Structure (Arrange-Act-Assert)

Every test follows the AAA pattern:

```csharp
[Fact]
public void Method_Scenario_ExpectedResult()
{
    // Arrange: Set up test data and dependencies
    var service = new CalculationService();
    var input = 100m;
    
    // Act: Execute the method being tested
    var result = service.CalculateDiscount(input, 0.10m);
    
    // Assert: Verify the outcome
    Assert.Equal(90m, result);
}
```

### 4. Test Characteristics (ISTQB Standards)

Each test should be:

| Characteristic | Description |
|---|---|
| **Isolated** | No dependencies on other tests; tests can run in any order |
| **Deterministic** | Always passes or fails consistently (no random/time-dependent behavior) |
| **Focused** | Tests one logical concept; multiple assertions only if verifying single behavior |
| **Readable** | Clear intent without requiring code navigation |
| **Fast** | Executes in milliseconds; uses mocks for external dependencies |
| **Maintainable** | Uses DRY principle; minimizes setup complexity |
| **Reliable** | Fails only when actual behavior changes, not due to environmental factors |

## Test Design Techniques (ISTQB)

### Equivalence Partitioning
Divide input domain into classes where behavior should be identical:

```csharp
// For age-based eligibility
// Partition 1: < 18 (invalid)
// Partition 2: 18-65 (eligible)
// Partition 3: > 65 (senior eligible)
```

Create tests for **one valid** representative and **one invalid** representative per partition.

### Boundary Value Analysis
Test at partition boundaries ± 1:

```csharp
[Theory]
[InlineData(17)]  // Just below boundary
[InlineData(18)]  // Boundary
[InlineData(19)]  // Just above boundary
public void IsEligible_AgeAtBoundary_ReturnsExpected(int age)
{
    // Test implementation
}
```

### State Transition Testing
For objects with state machines, test valid transitions:

```
State A --[Valid Trigger]--> State B --[Valid Trigger]--> State C
Invalid transitions from each state should also be tested
```

### Decision Table Testing
For complex logic with multiple conditions:

| Condition A | Condition B | Expected Result |
|---|---|---|
| True | True | X |
| True | False | Y |
| False | True | Z |
| False | False | W |

Create a test for each row.

## Test Coverage Strategy

### Coverage Levels (Hierarchy)

1. **Statement Coverage (Line Coverage)**: 70-80% minimum
   - Every executable line executed at least once
   - Does NOT guarantee logic errors are caught

2. **Branch Coverage (Decision Coverage)**: 80%+ target
   - Every if/else condition evaluated true AND false
   - Stronger than statement coverage

3. **Path Coverage**: Target for critical paths
   - Every possible execution path tested
   - Often infeasible for complex code (combinatorial explosion)

### Coverage Guidelines

- Aim for **80%+ overall coverage** for business logic
- **100% coverage** for:
  - Security-critical operations
  - Financial calculations
  - Authorization/authentication logic
  - Core business rules
- **Lower coverage acceptable** for:
  - UI boilerplate
  - Framework-generated code
  - Trivial getters/setters
  - Logging-only methods

## Mocking & Test Doubles (ISTQB)

### Test Double Types

| Type | Purpose | When to Use |
|---|---|---|
| **Stub** | Returns predetermined values | External API, database queries |
| **Mock** | Verifies method calls and arguments | Dependency verification |
| **Spy** | Records interactions while calling real method | Partial mocking |
| **Fake** | Lightweight working implementation | In-memory database, file system |

Use `Moq` library for creating test doubles:

```csharp
// Mock a dependency
var mockRepository = new Mock<IUserRepository>();
mockRepository
    .Setup(r => r.GetUser(It.IsAny<int>()))
    .ReturnsAsync(new User { Id = 1, Name = "Test" });

// Verify it was called
mockRepository.Verify(r => r.GetUser(1), Times.Once);
```

### Dependency Injection in Tests

Always inject dependencies to enable testing:

```csharp
// Bad: Hard to test
public class UserService
{
    private readonly IRepository _repo = new Repository();
}

// Good: Testable with mock injection
public class UserService
{
    private readonly IRepository _repo;
    public UserService(IRepository repo) => _repo = repo;
}
```

## Exception Testing

### Testing Expected Exceptions

```csharp
[Fact]
public void Process_WithInvalidInput_ThrowsArgumentException()
{
    var service = new Service();
    
    // Assert that exception is thrown
    var ex = Assert.Throws<ArgumentException>(
        () => service.Process(null)
    );
    
    // Verify exception details
    Assert.Contains("required", ex.Message, StringComparison.OrdinalIgnoreCase);
}

// For async operations
[Fact]
public async Task ProcessAsync_WithInvalidInput_ThrowsArgumentException()
{
    var service = new Service();
    
    await Assert.ThrowsAsync<ArgumentException>(
        () => service.ProcessAsync(null)
    );
}
```

### Exception Validation Strategy

Always verify:
1. **Correct exception type** is thrown
2. **Message contains actionable information**
3. **Inner exception** (if present) provides context
4. **Both happy path AND error paths** are tested

## Parameterized Testing (xUnit)

Use `[Theory]` and `[InlineData]` to test multiple inputs:

```csharp
[Theory]
[InlineData(0, 0)]           // Boundary
[InlineData(1, 1)]           // Single item
[InlineData(100, 100)]       // Large value
[InlineData(-1, null)]       // Invalid
public void Calculate_WithVariousInputs_ReturnsExpected(int input, int? expected)
{
    var result = Calculator.Process(input);
    Assert.Equal(expected, result);
}

// Or using MemberData for complex data
[Theory]
[MemberData(nameof(GetTestData))]
public void Test_WithComplexData(int input, object expected)
{
    // Test implementation
}

public static IEnumerable<object[]> GetTestData()
{
    yield return new object[] { 1, new { Value = 1 } };
    yield return new object[] { 2, new { Value = 2 } };
}
```

## Test Fixtures & Setup

### Fixture Management

```csharp
// Use IAsyncLifetime for async setup/cleanup
public class TestClass : IAsyncLifetime
{
    private readonly IRepository _repository;
    
    public TestClass()
    {
        _repository = new TestRepository();
    }
    
    public async Task InitializeAsync()
    {
        // Async setup (e.g., database initialization)
        await _repository.InitializeAsync();
    }
    
    public async Task DisposeAsync()
    {
        // Cleanup
        await _repository.ClearAsync();
    }
    
    [Fact]
    public async Task Test_WithAsyncSetup()
    {
        // Test body
    }
}
```

### Test Data Builders

Create reusable test data:

```csharp
public class UserBuilder
{
    private string _name = "TestUser";
    private int _age = 25;
    
    public UserBuilder WithName(string name)
    {
        _name = name;
        return this;
    }
    
    public UserBuilder WithAge(int age)
    {
        _age = age;
        return this;
    }
    
    public User Build() => new User { Name = _name, Age = _age };
}

// Usage
var user = new UserBuilder()
    .WithAge(30)
    .Build();
```

## Assertion Best Practices

### Use Specific Assertions

```csharp
// Bad: Generic
Assert.True(result == expected);

// Good: Specific
Assert.Equal(expected, result);
Assert.NotNull(user);
Assert.Empty(list);
Assert.Contains("text", result);
```

### Multiple Assertions (When Appropriate)

Only when testing a single cohesive behavior:

```csharp
[Fact]
public void User_Created_IsInitializedCorrectly()
{
    var user = new User("John", 30);
    
    // All assertions verify the SAME behavior: proper initialization
    Assert.Equal("John", user.Name);
    Assert.Equal(30, user.Age);
    Assert.False(user.IsActive);
}
```

## Async Testing

### Testing Async Methods

```csharp
[Fact]
public async Task GetUser_WithValidId_ReturnsUser()
{
    // Setup
    var repository = new UserRepository();
    
    // Act
    var user = await repository.GetUserAsync(1);
    
    // Assert
    Assert.NotNull(user);
    Assert.Equal(1, user.Id);
}

// Avoid .Result (causes deadlocks)
[Fact]
public void BadAsyncTest()
{
    // WRONG: This can deadlock
    var result = _service.GetDataAsync().Result;
}
```

### Testing Cancellation

```csharp
[Fact]
public async Task Operation_WithCancellation_ThrowsOperationCanceledException()
{
    var cts = new CancellationTokenSource();
    cts.CancelAfter(100);
    
    await Assert.ThrowsAsync<OperationCanceledException>(
        () => _service.LongOperationAsync(cts.Token)
    );
}
```

## Code Review Checklist for Unit Tests

When reviewing C# unit tests, verify:

- [ ] **Test name** clearly describes scenario and expected result
- [ ] **AAA structure** is evident (Arrange, Act, Assert)
- [ ] **Single responsibility** (one logical concept per test)
- [ ] **No test interdependencies** (can run in any order, isolated)
- [ ] **Appropriate use of mocks** (external dependencies mocked, internal logic real)
- [ ] **Assertions are specific** (not generic True/False checks)
- [ ] **Exception cases tested** (both happy path and error paths)
- [ ] **Boundary values tested** (if applicable via equivalence partitioning)
- [ ] **Setup/teardown is minimal** (only essential initialization)
- [ ] **No hardcoded delays** (no Thread.Sleep or Task.Delay)
- [ ] **Async/await used correctly** (no .Result/.Wait())
- [ ] **Test data is realistic** (represents real-world scenarios)
- [ ] **Coverage is adequate** (80%+ for business logic)
- [ ] **Tests are deterministic** (no time/random dependencies)
- [ ] **Documentation is clear** (comments for non-obvious logic)

## Common Pitfalls to Avoid

| Pitfall | Issue | Solution |
|---|---|---|
| **Magic values** | Hard to understand test intent | Use named variables: `const int ValidAge = 25;` |
| **Test interdependency** | One failing test breaks others | Ensure each test is completely independent |
| **Over-mocking** | Tests pass but integration fails | Mock only external dependencies, test real logic |
| **Brittle assertions** | Fails on unrelated changes | Assert on behavior, not implementation details |
| **Ignored tests** | Dead code accumulates | Remove or fix; never use [Ignore] long-term |
| **Excessive setup** | Tests hard to understand | Extract to helper methods or builders |
| **Testing implementation** | Tests break during refactoring | Test behavior/contracts, not internal details |
| **No negative tests** | Missing error scenarios | Always test error cases and boundaries |
| **Async antipatterns** | Deadlocks or race conditions | Use async/await, avoid .Result/.Wait() |

## Links to Reference Files

For detailed guidance on specific topics, see:
- `references/istqb-standards-summary.md` - ISTQB Foundation concepts
- `references/test-design-techniques.md` - Equivalence partitioning, boundary analysis, decision tables
- `references/xunit-framework-guide.md` - xUnit framework features and best practices
- `references/mocking-patterns.md` - Moq library patterns and anti-patterns
- `references/async-testing-guide.md` - Comprehensive async/await testing strategies

## Example Tests

See `examples/` directory for annotated example tests:
- `calculator-service.tests.cs` - Basic arithmetic with boundary testing
- `user-repository.tests.cs` - Data access with mocking
- `authorization-service.tests.cs` - Business logic with decision tables
- `async-api-service.tests.cs` - Async operations and exception handling

## Keywords

unit testing, C#, .NET, ASP.NET Core, xUnit, Moq, ISTQB, test design, TDD, test coverage, mocking, assertions, async testing
