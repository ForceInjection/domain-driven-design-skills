---
name: writing-xcuitests
description: This skill should be used when the user asks to "write XCUITest", "create UI tests", "fix flaky tests", "query XCUIElements", "implement Page Object pattern", or mentions XCUITest, UI testing for iOS/macOS apps. Targets experienced iOS developers who want best practices and efficiency improvements.
---

# Writing XCUITests

Guide for writing robust, maintainable XCUITests for iOS and macOS applications. This skill focuses on practical patterns, element querying strategies, and techniques to reduce test flakiness.

## Quick Start

### Element Queries

Prefer accessibility identifiers for reliable element queries:

```swift
// Best: Accessibility identifier
app.buttons["loginButton"].tap()

// Good: Text matching (fragile to localization)
app.buttons["Log In"].tap()

// Avoid: Index-based queries (brittle to UI changes)
app.buttons.element(boundBy: 0).tap()
```

Set accessibility identifiers in your app code:

```swift
button.accessibilityIdentifier = "loginButton"
```

Query by element type and identifier:

```swift
let emailField = app.textFields["emailField"]
let passwordField = app.secureTextFields["passwordField"]
let submitButton = app.buttons["submitButton"]
let statusLabel = app.staticTexts["statusLabel"]
```

### Common Interactions

**Tap elements:**

```swift
app.buttons["submitButton"].tap()
```

**Type text:**

```swift
app.textFields["emailField"].tap()
app.textFields["emailField"].typeText("user@example.com")
```

**Clear and type (preferred for input fields):**

```swift
let emailField = app.textFields["emailField"]
emailField.tap()
// Clear existing text by typing delete keys
if let value = emailField.value as? String, !value.isEmpty {
    let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue,
                              count: value.count)
    emailField.typeText(deleteString)
}
emailField.typeText("new@example.com")
```

**Toggle switches:**

```swift
let toggleSwitch = app.switches["notificationSwitch"]
if toggleSwitch.value as? String == "0" {
    toggleSwitch.tap()
}
```

### Waiting for Elements

Always wait for elements before interacting:

```swift
let loginButton = app.buttons["loginButton"]
XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
loginButton.tap()
```

Wait for element to disappear (loading indicators):

```swift
// Using expectation-based wait for disappearance
let spinner = app.activityIndicators["loadingSpinner"]
let predicate = NSPredicate(format: "exists == false")
let expectation = expectation(for: predicate, evaluatedWith: spinner)
wait(for: [expectation], timeout: 10)
```

Alternative simpler approach:

```swift
// Wait for element to disappear (simple polling approach)
let spinner = app.activityIndicators["loadingSpinner"]
let timeout: TimeInterval = 10
let startTime = Date()
while spinner.exists && Date().timeIntervalSince(startTime) < timeout {
    Thread.sleep(forTimeInterval: 0.1)
}
XCTAssertFalse(spinner.exists, "Spinner did not disappear within timeout")
```

### Basic Assertions

Check element existence:

```swift
XCTAssertTrue(app.buttons["loginButton"].exists)
```

Check element properties:

```swift
let errorLabel = app.staticTexts["errorLabel"]
XCTAssertTrue(errorLabel.exists)
XCTAssertEqual(errorLabel.label, "Invalid credentials")
```

Check element state:

```swift
let submitButton = app.buttons["submitButton"]
XCTAssertTrue(submitButton.isEnabled)
XCTAssertTrue(submitButton.isHittable)
```

## Test Structure

### Basic XCTestCase Setup

```swift
import XCTest

class LoginTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testSuccessfulLogin() throws {
        // Arrange
        let emailField = app.textFields["emailField"]
        let passwordField = app.secureTextFields["passwordField"]
        let loginButton = app.buttons["loginButton"]

        // Act
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText("user@example.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Assert
        let welcomeLabel = app.staticTexts["welcomeLabel"]
        XCTAssertTrue(welcomeLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(welcomeLabel.label, "Welcome back!")
    }
}
```

### Launch Arguments and Environment Variables

Configure app state for testing:

```swift
override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()

    // Pass launch arguments
    app.launchArguments = ["--uitesting", "--reset-data"]

    // Set environment variables
    app.launchEnvironment = [
        "MOCK_API": "true",
        "ANIMATION_SPEED": "0"
    ]

    app.launch()
}
```

## Reference Documentation

For detailed guidance on specific topics:

| Topic | Reference File |
|-------|---------------|
| Element Query Strategies | [reference/element-queries.md](reference/element-queries.md) |
| Interactions & Gestures | [reference/interactions.md](reference/interactions.md) |
| Waiting & Synchronization | [reference/waiting.md](reference/waiting.md) |
| Assertions & Validation | [reference/assertions.md](reference/assertions.md) |
| Page Object Pattern | [reference/page-objects.md](reference/page-objects.md) |
| Advanced Gestures | [reference/gestures.md](reference/gestures.md) |
| Fixing Flaky Tests | [reference/flaky-tests.md](reference/flaky-tests.md) |
| Complete Examples | [reference/examples.md](reference/examples.md) |

## Key Principles

1. **Use accessibility identifiers** - Most reliable query method
2. **Always wait for elements** - Use `waitForExistence(timeout:)` before interactions
3. **Test behavior, not implementation** - Focus on user-visible outcomes
4. **Keep tests independent** - Each test should run in isolation
5. **Use Page Objects** - Encapsulate screen structure and reduce duplication
6. **Minimize sleeps** - Prefer explicit waits over `sleep()` calls
7. **Handle animations** - Disable or account for UI animations in tests
8. **Verify preconditions** - Assert element state before interactions

## Common Patterns

**Login flow:**

```swift
func login(email: String, password: String) {
    let emailField = app.textFields["emailField"]
    let passwordField = app.secureTextFields["passwordField"]
    let loginButton = app.buttons["loginButton"]

    XCTAssertTrue(emailField.waitForExistence(timeout: 5))

    emailField.tap()
    emailField.typeText(email)

    passwordField.tap()
    passwordField.typeText(password)

    loginButton.tap()
}
```

**Navigate and verify:**

```swift
func testNavigationToSettings() {
    // Navigate
    app.tabBars.buttons["Settings"].tap()

    // Verify arrival
    let settingsTitle = app.navigationBars["Settings"]
    XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))
}
```

**Form submission with validation:**

```swift
func testFormValidation() {
    let nameField = app.textFields["nameField"]
    let submitButton = app.buttons["submitButton"]

    // Submit empty form
    submitButton.tap()

    // Verify validation message
    let errorLabel = app.staticTexts["nameErrorLabel"]
    XCTAssertTrue(errorLabel.waitForExistence(timeout: 2))
    XCTAssertEqual(errorLabel.label, "Name is required")

    // Fix and resubmit
    nameField.tap()
    nameField.typeText("John Doe")
    submitButton.tap()

    // Verify error cleared
    XCTAssertFalse(errorLabel.exists)
}
```

## Next Steps

- Implement Page Objects for complex screens: [reference/page-objects.md](reference/page-objects.md)
- Learn advanced gestures (swipe, pinch, rotate): [reference/gestures.md](reference/gestures.md)
- Debug flaky tests: [reference/flaky-tests.md](reference/flaky-tests.md)
- Review complete test examples: [reference/examples.md](reference/examples.md)
