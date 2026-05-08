---
name: unit-test-specialist
description: Expert guidance on unit testing for the Pomodoro Time Tracker. Activates when working with tests, test coverage, or testable code patterns.
allowed-tools:
  - Read
  - Glob
  - Grep
---

# Unit Test Specialist

**Activates when:** Tests, unit tests, test coverage, or testable code mentioned.

## Shared Testing Guidelines

@~/.claude/prompts/dotnet/testing/aaa-pattern.md
@~/.claude/prompts/dotnet/testing/test-naming.md
@~/.claude/prompts/dotnet/testing/moq-cheatsheet.md
@~/.claude/prompts/dotnet/testing/fluentassertions.md

---

## Project-Specific

### Framework Stack
- **xUnit** - Primary test framework (.NET 9)
- **Moq** - Mocking for interfaces
- **FluentAssertions** - Readable assertions
- **EF Core InMemory** - Repository testing

### Test Structure (377 tests)
```
PomodoroTimeTracker.Tests/
├── ViewModels/                    (158 tests)
│   ├── PomodoroViewModelTests.cs     (60)
│   ├── RegularTimerViewModelTests.cs (40)
│   ├── StopWatchViewModelTests.cs    (30)
│   └── ...
├── Application/Services/          (148 tests)
│   ├── PomodoroSessionServiceTests.cs
│   ├── AudioServiceTests.cs          (35)
│   └── ...
└── Infrastructure/Repositories/   (71 tests)
```

### ViewModel Test Pattern

```csharp
public class ViewModelTests
{
    private readonly Mock<IService> _service;
    private readonly Mock<IDispatcherTimer> _timer;
    private readonly ViewModel _viewModel;

    public ViewModelTests()
    {
        _service = new Mock<IService>();
        _timer = new Mock<IDispatcherTimer>();
        _viewModel = new ViewModel(_service.Object, _timer.Object);
    }

    [Fact]
    public void Property_WhenChanged_UpdatesDependentProperties()
    {
        // Arrange
        var propertyChanges = new List<string>();
        _viewModel.PropertyChanged += (s, e) => propertyChanges.Add(e.PropertyName!);

        // Act
        _viewModel.SomeProperty = "value";

        // Assert
        propertyChanges.Should().Contain("DependentProperty");
    }
}
```

### Service Test Pattern

```csharp
public class ServiceTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly Service _service;

    public ServiceTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        _context = new ApplicationDbContext(options);
        _service = new Service(new UnitOfWork(_context));
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }
}
```

### Coverage Targets

- 5-8 tests per public method
- Happy path + validation + edge cases
- 100% pass rate required

### Update TEST_SUMMARY.md

When tests are added/modified, update TEST_SUMMARY.md with current counts.
