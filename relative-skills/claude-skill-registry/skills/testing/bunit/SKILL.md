---
name: bunit
description: Blazor component testing with bUnit. Use when writing unit tests for Blazor components, testing user interactions, mocking services/dependencies, testing MudBlazor components, testing components with Neatoo domain objects, or debugging component rendering issues.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(dotnet:*), WebFetch
---

# bUnit - Blazor Component Testing

## Overview

bUnit is a testing library for Blazor components that enables testing without a browser. It provides:

- **Component rendering** in a test environment
- **DOM assertions** and markup verification
- **User interaction simulation** (clicks, inputs, form submissions)
- **Service mocking** and dependency injection
- **Async testing** with waiting utilities
- **Blazor lifecycle** testing

## Installation

```bash
# Add bUnit with xUnit support
dotnet add package bunit

# Or individual packages
dotnet add package bunit.core
dotnet add package bunit.web
dotnet add package bunit.xunit   # For xUnit integration
```

## Quick Start

### Basic Component Test

```csharp
public class CounterTests : TestContext
{
    [Fact]
    public void Counter_InitialCount_IsZero()
    {
        // Arrange & Act
        var cut = RenderComponent<Counter>();

        // Assert
        cut.Find("p").MarkupMatches("<p>Current count: 0</p>");
    }

    [Fact]
    public void Counter_ClickButton_IncrementsCount()
    {
        // Arrange
        var cut = RenderComponent<Counter>();

        // Act
        cut.Find("button").Click();

        // Assert
        cut.Find("p").MarkupMatches("<p>Current count: 1</p>");
    }
}
```

## Additional Resources

For detailed guidance, see:
- [Getting Started](getting-started.md) - Project setup, global usings
- [Core Concepts](core-concepts.md) - TestContext, assertions, interactions
- [Best Practices](best-practices.md) - Testing patterns, AAA, semantic matching
- [Running Tests](running-tests.md) - CLI commands, filtering, CI integration
- [Component Testing Patterns](component-testing.md) - Parameters, templates, child components
- [Service Mocking](service-mocking.md) - DI, KnockOff stubs, Moq patterns, HttpClient
- [MudBlazor Testing](mudblazor-testing.md) - Testing MudBlazor components
- [Async Testing](async-testing.md) - WaitForState, WaitForAssertion, timers
- [Neatoo Testing](neatoo-testing.md) - Testing with Neatoo domain objects

## Official Documentation

- [bUnit Documentation](https://bunit.dev/docs/getting-started/)
- [bUnit GitHub](https://github.com/bUnit-dev/bUnit)
- [Blazor Testing Best Practices](https://docs.microsoft.com/aspnet/core/blazor/test)
