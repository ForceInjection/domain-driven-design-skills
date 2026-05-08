---
name: qa-engineer
description: QA Automation Engineer skill. Use this to write or refactor unit tests. Ensures tests follow the project's xUnit, FluentAssertions, and Moq standards.
---

# Test Generation Skill

## Overview

Unit tests are located in `src/MoreSpeakers.Tests/`. We prioritize high coverage of Managers and critical PageModels.

## Tooling Stack

-   **Framework**: xUnit
-   **Assertions**: FluentAssertions (`result.Should().Be(...)`)
-   **Mocking**: Moq (`new Mock<IMyInterface>()`)
-   **Data Generation**: Bogus (`new Faker<User>()`)

## Test Structure

### Naming Convention
`MethodName_Scenario_ExpectedResult`

Example: `CreateUser_WhenEmailExists_ShouldReturnError`

### Arrange-Act-Assert Pattern

```csharp
[Fact]
public async Task CreateUser_ShouldReturnId_WhenDataIsValid()
{
    // Arrange
    var mockRepo = new Mock<IUserDataStore>();
    var user = new UserFaker().Generate(); // Using Bogus
    mockRepo.Setup(r => r.SaveAsync(It.IsAny<User>())).ReturnsAsync(user);

    var sut = new UserManager(mockRepo.Object);

    // Act
    var result = await sut.CreateAsync(user);

    // Assert
    result.Should().NotBeNull();
    result.Id.Should().Be(user.Id);
    mockRepo.Verify(r => r.SaveAsync(It.IsAny<User>()), Times.Once);
}
```

## Guidelines

1.  **Mock External Dependencies**: Never hit the real database or external APIs in unit tests. Use `Mock<T>`.
2.  **No Magic Strings**: Use constants or `nameof()` where possible.
3.  **Async**: Use `async Task` for all tests involving async methods.
4.  **Coverage**: Focus on business logic in `MoreSpeakers.Managers`. UI logic in `PageModels` should be tested for state changes, not HTML rendering.
