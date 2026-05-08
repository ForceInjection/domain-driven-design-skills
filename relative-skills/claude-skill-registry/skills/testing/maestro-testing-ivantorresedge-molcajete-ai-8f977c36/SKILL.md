---
name: maestro-testing
description: Maestro E2E testing patterns for React Native. Use when implementing end-to-end tests.
---

# Maestro Testing Skill

This skill covers Maestro E2E testing for React Native apps.

## When to Use

Use this skill when:
- Writing E2E tests
- Testing user flows
- Automating UI testing
- CI/CD testing

## Core Principle

**YAML SIMPLICITY** - Maestro uses simple YAML syntax for readable, maintainable tests.

## Installation

```bash
# macOS/Linux
curl -Ls "https://get.maestro.mobile.dev" | bash

# Verify installation
maestro -v
```

## Project Structure

```
__tests__/
└── e2e/
    ├── flows/
    │   ├── login.yaml
    │   └── common.yaml
    ├── login_flow.yaml
    ├── signup_flow.yaml
    ├── navigation_flow.yaml
    └── checkout_flow.yaml
```

## Basic Test

```yaml
# __tests__/e2e/login_flow.yaml
appId: com.myapp
---
- launchApp
- tapOn: "Email"
- inputText: "test@example.com"
- tapOn: "Password"
- inputText: "password123"
- tapOn: "Sign In"
- assertVisible: "Welcome"
```

## Common Commands

### App Control

```yaml
# Launch app
- launchApp

# Clear app state and launch
- launchApp:
    clearState: true

# Stop app
- stopApp
```

### Tap Actions

```yaml
# Tap by text
- tapOn: "Button Text"

# Tap by accessibility ID
- tapOn:
    id: "submit-button"

# Tap by index (when multiple matches)
- tapOn:
    text: "Item"
    index: 0

# Long press
- longPressOn: "Delete"
```

### Text Input

```yaml
# Input text
- inputText: "Hello World"

# Clear and input
- clearText
- inputText: "New Text"

# Input in specific field
- tapOn: "Email"
- inputText: "user@example.com"
```

### Assertions

```yaml
# Assert element is visible
- assertVisible: "Success"

# Assert element is not visible
- assertNotVisible: "Error"

# Assert with timeout
- extendedWaitUntil:
    visible: "Loaded"
    timeout: 10000
```

### Scrolling

```yaml
# Scroll down
- scroll

# Scroll until visible
- scrollUntilVisible:
    element: "Target Item"
    direction: DOWN
    timeout: 10000

# Scroll in element
- scroll:
    element:
      id: "scrollable-list"
    direction: DOWN
```

### Swipe Gestures

```yaml
# Swipe left (delete)
- swipe:
    direction: LEFT
    start: "Item to delete"

# Swipe down (refresh)
- swipe:
    direction: DOWN
    start:
      above: "First Item"
```

### Waiting

```yaml
# Wait for animation
- waitForAnimationToEnd

# Wait specific time (ms)
- wait: 2000

# Wait until visible
- extendedWaitUntil:
    visible: "Element"
    timeout: 5000
```

### Screenshots

```yaml
# Take screenshot
- takeScreenshot: screen_name
```

## Flow Composition

### Reusable Flows

```yaml
# flows/login.yaml
- tapOn: "Email"
- inputText: ${email}
- tapOn: "Password"
- inputText: ${password}
- tapOn: "Sign In"
- assertVisible: "Welcome"
```

```yaml
# main_test.yaml
- launchApp
- runFlow:
    file: flows/login.yaml
    env:
      email: "test@example.com"
      password: "password123"
- tapOn: "Profile"
```

### Conditional Flows

```yaml
# Handle optional popups
- runFlow:
    when:
      visible: "Accept Cookies"
    commands:
      - tapOn: "Accept"

- tapOn: "Continue"
```

## Environment Variables

```yaml
# Use environment variables
appId: ${APP_ID}
---
- launchApp
- tapOn: "Email"
- inputText: ${TEST_EMAIL}
```

```bash
# Run with variables
APP_ID=com.myapp TEST_EMAIL=test@test.com maestro test test.yaml
```

## Platform-Specific Tests

```yaml
# iOS-specific
- runFlow:
    when:
      platform: iOS
    commands:
      - tapOn: "iOS Settings"

# Android-specific
- runFlow:
    when:
      platform: Android
    commands:
      - tapOn: "Android Settings"
```

## Complete Test Examples

### Login Flow

```yaml
# __tests__/e2e/login_flow.yaml
appId: com.myapp
---
- launchApp:
    clearState: true

# Navigate to login
- tapOn: "Sign In"

# Enter credentials
- tapOn:
    id: "email-input"
- inputText: "test@example.com"

- tapOn:
    id: "password-input"
- inputText: "password123"

# Submit
- tapOn:
    id: "login-button"

# Wait for navigation
- waitForAnimationToEnd

# Verify success
- assertVisible: "Welcome back"
- assertVisible: "Home"

# Take screenshot
- takeScreenshot: login_success
```

### Form Validation

```yaml
# __tests__/e2e/form_validation.yaml
appId: com.myapp
---
- launchApp

# Test empty submission
- tapOn: "Submit"
- assertVisible: "Email is required"

# Test invalid email
- tapOn: "Email"
- inputText: "invalid"
- tapOn: "Submit"
- assertVisible: "Invalid email"

# Test valid submission
- clearText
- inputText: "valid@example.com"
- tapOn: "Password"
- inputText: "ValidPass123!"
- tapOn: "Submit"
- assertVisible: "Success"
```

### Navigation Flow

```yaml
# __tests__/e2e/navigation_flow.yaml
appId: com.myapp
---
- launchApp

# Test tab navigation
- tapOn:
    id: "tab-home"
- assertVisible: "Home Screen"

- tapOn:
    id: "tab-search"
- assertVisible: "Search"

- tapOn:
    id: "tab-profile"
- assertVisible: "Profile"

# Test back navigation
- tapOn: "Settings"
- assertVisible: "Settings"
- back
- assertVisible: "Profile"
```

## Running Tests

```bash
# Run single test
maestro test __tests__/e2e/login_flow.yaml

# Run all tests
maestro test __tests__/e2e/

# Run on specific platform
maestro test __tests__/e2e/ --platform ios

# Generate JUnit report
maestro test __tests__/e2e/ --format junit --output results/
```

## CI/CD Integration

```yaml
# .github/workflows/e2e.yml
name: E2E Tests

on: [push, pull_request]

jobs:
  e2e:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4

      - name: Install dependencies
        run: npm ci

      - name: Install Maestro
        run: |
          curl -Ls "https://get.maestro.mobile.dev" | bash
          echo "$HOME/.maestro/bin" >> $GITHUB_PATH

      - name: Build app
        run: npx expo prebuild && npx expo run:ios

      - name: Run E2E tests
        run: maestro test __tests__/e2e/

      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: e2e-results
          path: results/
```

## Notes

- Requires simulator/emulator running
- Use accessibility IDs for reliable selection
- Keep tests independent
- Use reusable flows for common actions
- Test on both platforms
- Consider Maestro Cloud for CI
