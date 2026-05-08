---
name: playwright-blazor-e2e
description: End-to-end testing for Blazor applications using Playwright for .NET. Use when writing E2E tests, creating test infrastructure, testing MudBlazor components, handling Blazor WebAssembly loading, debugging test failures, or setting up CI/CD test pipelines.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(dotnet:*), Bash(pwsh:*), WebFetch
---

# Playwright E2E Testing for Blazor

## Overview

Playwright for .NET provides cross-browser automation for testing Blazor applications. It handles Blazor's asynchronous rendering, WebAssembly loading, and SignalR connections with robust auto-waiting and retry mechanisms.

### Key Capabilities

- Cross-browser testing (Chromium, Firefox, WebKit)
- Auto-waiting for elements and network requests
- Trace viewer for debugging failed tests
- Parallel test execution
- Full support for Blazor WebAssembly and Server

## CRITICAL: Blazor-Specific Considerations

| Challenge | Solution |
|-----------|----------|
| WASM loading delay | Wait for Blazor to initialize before interacting |
| Component re-renders | Use auto-retrying assertions, not `Thread.Sleep` |
| MudBlazor components | Use role/label locators, not CSS selectors |
| Async operations | Wait for loading indicators to disappear |
| SignalR reconnection | Handle connection state changes gracefully |

## Quick Start

### 1. Create Test Project

```bash
# MSTest (recommended for .NET projects)
dotnet new mstest -n MyApp.E2E
cd MyApp.E2E

# Add Playwright
dotnet add package Microsoft.Playwright.MSTest

# Build to generate playwright.ps1
dotnet build

# Install browsers
pwsh bin/Debug/net8.0/playwright.ps1 install
```

### 2. Basic Blazor Test

```csharp
using Microsoft.Playwright;
using Microsoft.Playwright.MSTest;

namespace MyApp.E2E;

[TestClass]
public class HomePageTests : PageTest
{
    [TestMethod]
    public async Task HomePage_DisplaysWelcomeMessage()
    {
        // Navigate and wait for Blazor to load
        await Page.GotoAsync("https://localhost:5001/");
        await WaitForBlazorAsync();

        // Use role-based locator (accessibility-first)
        var heading = Page.GetByRole(AriaRole.Heading, new() { Name = "Welcome" });
        await Expect(heading).ToBeVisibleAsync();
    }

    private async Task WaitForBlazorAsync()
    {
        // Wait for Blazor WebAssembly to finish loading
        await Page.WaitForFunctionAsync("window.Blazor !== undefined");

        // Wait for any initial loading indicators to disappear
        var loader = Page.GetByTestId("app-loading");
        await Expect(loader).ToBeHiddenAsync(new() { Timeout = 30000 });
    }
}
```

### 3. Configure Base URL

Override `ContextOptions` to set a base URL:

```csharp
[TestClass]
public class BlazorTestBase : PageTest
{
    public override BrowserNewContextOptions ContextOptions => new()
    {
        BaseURL = "https://localhost:5001",
        IgnoreHTTPSErrors = true // For dev certificates
    };
}
```

## Locator Strategy (Priority Order)

Always prefer user-facing locators for resilient tests:

| Priority | Method | Example | Use When |
|----------|--------|---------|----------|
| 1 | `GetByRole()` | `GetByRole(AriaRole.Button, new() { Name = "Submit" })` | Interactive elements |
| 2 | `GetByLabel()` | `GetByLabel("Email")` | Form inputs |
| 3 | `GetByPlaceholder()` | `GetByPlaceholder("Search...")` | Inputs with placeholder |
| 4 | `GetByText()` | `GetByText("Welcome")` | Static text content |
| 5 | `GetByTestId()` | `GetByTestId("submit-button")` | When other locators fail |
| 6 | `Locator()` | `Locator(".mud-button")` | Last resort only |

### MudBlazor Component Locators

```csharp
// MudButton - use role and accessible name
var saveButton = Page.GetByRole(AriaRole.Button, new() { Name = "Save" });

// MudTextField - use label
var emailField = Page.GetByLabel("Email");

// MudSelect - use label then interact
var categorySelect = Page.GetByLabel("Category");
await categorySelect.ClickAsync();
await Page.GetByRole(AriaRole.Option, new() { Name = "Electronics" }).ClickAsync();

// MudDataGrid row - use text content
var row = Page.GetByRole(AriaRole.Row).Filter(new() { HasText = "Product ABC" });

// MudDialog - use role
var dialog = Page.GetByRole(AriaRole.Dialog);
await Expect(dialog).ToBeVisibleAsync();
```

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Correct Approach |
|--------------|---------|------------------|
| `Thread.Sleep(2000)` | Slow, flaky | Use auto-waiting assertions |
| `Locator(".css-class")` | Brittle selectors | Use role/label locators |
| Hard-coded waits | Race conditions | Use `Expect()` assertions |
| Testing implementation | Breaks on refactor | Test user-visible behavior |
| No base URL | Duplicate URLs | Configure in `ContextOptions` |
| Ignoring loading states | Flaky tests | Wait for loaders to disappear |

## Additional Resources

For detailed guidance, see:
- [Test Patterns](test-patterns.md) - Form submission, dialogs, grids, auth flows
- [Configuration](configuration.md) - Project structure, .runsettings, CI/CD
- [Project Setup](project-setup.md) - Full project configuration
- [Blazor Patterns](blazor-patterns.md) - Blazor-specific testing patterns, assertions, and actionability
- [MudBlazor Selectors](mudblazor-selectors.md) - Finding MudBlazor components
- [Debugging](debugging.md) - Trace viewer, headed mode, Inspector, and debugging techniques

## External Documentation

- [Playwright .NET Docs](https://playwright.dev/dotnet/docs/intro)
- [Playwright Locators](https://playwright.dev/dotnet/docs/locators)
- [Playwright Assertions](https://playwright.dev/dotnet/docs/test-assertions)
- [Playwright Trace Viewer](https://playwright.dev/dotnet/docs/trace-viewer)
