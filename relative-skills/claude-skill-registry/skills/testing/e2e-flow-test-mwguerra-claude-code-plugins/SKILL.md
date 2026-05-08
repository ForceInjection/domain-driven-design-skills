---
name: e2e-flow-test
description: Execute complete user flow testing with Playwright MCP, testing end-to-end journeys through the application
---

# E2E Flow Testing Skill

## Overview

This skill executes complete user flow testing using Playwright MCP. It tests end-to-end journeys through the application, from start to finish, verifying that multi-step processes work correctly.

## Standard Test Plan Location

**Plan file**: `tests/e2e-test-plan.md`

This skill reads flow definitions from the test plan at `tests/e2e-test-plan.md`. If the plan file doesn't exist, the calling command should invoke the `e2e-test-plan` skill first to generate it.

## Purpose

Ensure that:
- Complete user journeys work from start to finish
- State persists correctly between steps
- Error handling works throughout flows
- Edge cases in flows are handled
- Business logic executes correctly

## Workflow

### Step 0: Test Plan Verification (REQUIRED FIRST)

**CRITICAL**: Before testing flows, verify the test plan exists.

1. **Check for Test Plan**
   - Look for `tests/e2e-test-plan.md`
   - If the file exists, read the "Critical Flows" section
   - If the file does NOT exist, STOP and report that the plan must be generated first

2. **Read Flow Definitions from Plan**
   - Extract authentication flows
   - Extract core business flows
   - Extract administrative flows
   - Use this list for testing

### Step 1: Identify Critical Flows

1. **Authentication Flows**
   - User registration
   - User login
   - Password reset
   - Logout

2. **Core Business Flows**
   - Main feature workflows
   - CRUD operations
   - Transactions/checkouts
   - Data processing

3. **Administrative Flows**
   - User management
   - Configuration changes
   - Reporting

### Step 2: Flow Documentation

For each flow, document:

```markdown
## Flow: User Registration

### Overview
Complete user registration from signup to verified account

### Steps
1. Navigate to registration page
2. Fill registration form
3. Submit form
4. Receive confirmation
5. Verify email (if applicable)
6. Complete profile (if applicable)
7. Access dashboard

### Prerequisites
- No existing account
- Valid email address

### Expected Outcomes
- User account created
- Verification email sent
- User can login
- Profile accessible

### Error Cases
- Duplicate email
- Weak password
- Invalid email format
- Required fields missing
```

### Step 3: Execute Flow Tests

For EACH flow:

1. **Setup**
   - Clear any previous state
   - Prepare test data
   - Set initial conditions

2. **Execute Steps**
   - Perform each step
   - Verify state after each step
   - Capture snapshots

3. **Verify Outcome**
   - Check final state
   - Verify data persistence
   - Check side effects

4. **Test Error Cases**
   - Repeat flow with error conditions
   - Verify proper error handling

## Common Flow Patterns

### Registration Flow
```
Step 1: Navigate to Registration
  browser_navigate({ url: "/register" })
  browser_snapshot()
  Verify: Registration form visible

Step 2: Fill Registration Form
  browser_fill_form({
    fields: [
      { name: "Name", type: "textbox", ref: "[name-ref]", value: "Test User" },
      { name: "Email", type: "textbox", ref: "[email-ref]", value: "test@example.com" },
      { name: "Password", type: "textbox", ref: "[password-ref]", value: "SecurePass123!" },
      { name: "Confirm Password", type: "textbox", ref: "[confirm-ref]", value: "SecurePass123!" }
    ]
  })
  browser_snapshot()
  Verify: All fields filled

Step 3: Submit Form
  browser_click({ element: "Register button", ref: "[submit-ref]" })
  browser_wait_for({ text: "Account created" OR redirect to dashboard })
  browser_snapshot()
  browser_console_messages({ level: "error" })
  Verify: No errors, success message or redirect

Step 4: Verify Account
  If email verification required:
    Check for verification message
  Else:
    browser_snapshot()
    Verify: Dashboard or profile accessible

Step 5: Verify Can Login
  browser_navigate({ url: "/logout" })
  browser_navigate({ url: "/login" })
  browser_fill_form with credentials
  browser_click submit
  browser_wait_for dashboard
  Verify: Successfully logged in
```

### Login Flow
```
Step 1: Navigate to Login
  browser_navigate({ url: "/login" })
  browser_snapshot()
  Verify: Login form visible

Step 2: Enter Credentials
  browser_fill_form({
    fields: [
      { name: "Email", type: "textbox", ref: "[email-ref]", value: "user@example.com" },
      { name: "Password", type: "textbox", ref: "[password-ref]", value: "password" }
    ]
  })

Step 3: Submit
  browser_click({ element: "Login button", ref: "[submit-ref]" })
  browser_wait_for({ text: "Dashboard" OR text: "Welcome" })
  browser_snapshot()
  Verify: Logged in state, user menu visible

Step 4: Verify Session
  browser_navigate({ url: "/profile" })
  browser_snapshot()
  Verify: User profile accessible

  browser_navigate({ url: "/protected-page" })
  browser_snapshot()
  Verify: Protected content accessible
```

### Password Reset Flow
```
Step 1: Navigate to Forgot Password
  browser_navigate({ url: "/forgot-password" })
  browser_snapshot()
  Verify: Email input form visible

Step 2: Request Reset
  browser_type({
    element: "Email field",
    ref: "[email-ref]",
    text: "user@example.com"
  })
  browser_click({ element: "Send reset link", ref: "[submit-ref]" })
  browser_wait_for({ text: "email sent" OR text: "check your email" })
  browser_snapshot()
  Verify: Success message

Step 3: (Simulated) Click Reset Link
  browser_navigate({ url: "/reset-password?token=TEST_TOKEN" })
  browser_snapshot()
  Verify: Password reset form visible

Step 4: Set New Password
  browser_fill_form({
    fields: [
      { name: "New Password", type: "textbox", ref: "[password-ref]", value: "NewPass123!" },
      { name: "Confirm Password", type: "textbox", ref: "[confirm-ref]", value: "NewPass123!" }
    ]
  })
  browser_click({ element: "Reset Password", ref: "[submit-ref]" })
  browser_wait_for({ text: "Password updated" OR redirect to login })
  browser_snapshot()
  Verify: Success message or login page
```

### CRUD Flow (Create-Read-Update-Delete)
```
Step 1: Navigate to List
  browser_navigate({ url: "/items" })
  browser_snapshot()
  Note: Initial item count

Step 2: Create Item
  browser_click({ element: "Create new", ref: "[create-ref]" })
  browser_snapshot()
  Verify: Create form visible

  browser_fill_form({
    fields: [
      { name: "Title", type: "textbox", ref: "[title-ref]", value: "Test Item" },
      { name: "Description", type: "textbox", ref: "[desc-ref]", value: "Test description" }
    ]
  })
  browser_click({ element: "Save", ref: "[save-ref]" })
  browser_wait_for({ text: "created" OR redirect to list })
  browser_snapshot()
  Verify: Item created, appears in list

Step 3: Read Item
  browser_click({ element: "View item", ref: "[view-ref]" })
  browser_snapshot()
  Verify: Item details displayed correctly

Step 4: Update Item
  browser_click({ element: "Edit", ref: "[edit-ref]" })
  browser_snapshot()
  Verify: Edit form with current values

  browser_type({
    element: "Title field",
    ref: "[title-ref]",
    text: "Updated Title"
  })
  browser_click({ element: "Save", ref: "[save-ref]" })
  browser_wait_for({ text: "updated" })
  browser_snapshot()
  Verify: Changes saved

Step 5: Delete Item
  browser_click({ element: "Delete", ref: "[delete-ref]" })

  If confirmation dialog:
    browser_handle_dialog({ accept: true })

  browser_wait_for({ textGone: "Updated Title" })
  browser_snapshot()
  Verify: Item removed from list
```

### Checkout Flow (E-commerce)
```
Step 1: Add to Cart
  browser_navigate({ url: "/products/1" })
  browser_click({ element: "Add to cart", ref: "[add-ref]" })
  browser_wait_for({ text: "Added" OR cart count update })
  browser_snapshot()
  Verify: Item in cart

Step 2: View Cart
  browser_navigate({ url: "/cart" })
  browser_snapshot()
  Verify: Cart shows item, correct price

Step 3: Proceed to Checkout
  browser_click({ element: "Checkout", ref: "[checkout-ref]" })
  browser_snapshot()
  Verify: Checkout form visible

Step 4: Fill Shipping
  browser_fill_form({
    fields: [
      { name: "Address", type: "textbox", ref: "[address-ref]", value: "123 Test St" },
      { name: "City", type: "textbox", ref: "[city-ref]", value: "Test City" },
      { name: "Zip", type: "textbox", ref: "[zip-ref]", value: "12345" }
    ]
  })
  browser_click({ element: "Continue", ref: "[continue-ref]" })
  browser_snapshot()

Step 5: Payment
  browser_fill_form({
    fields: [
      { name: "Card Number", type: "textbox", ref: "[card-ref]", value: "4242424242424242" },
      { name: "Expiry", type: "textbox", ref: "[expiry-ref]", value: "12/25" },
      { name: "CVV", type: "textbox", ref: "[cvv-ref]", value: "123" }
    ]
  })
  browser_click({ element: "Pay Now", ref: "[pay-ref]" })
  browser_wait_for({ text: "Order confirmed" })
  browser_snapshot()
  Verify: Order confirmation page

Step 6: Verify Order
  browser_navigate({ url: "/orders" })
  browser_snapshot()
  Verify: Order appears in order history
```

## Error Case Testing

### Invalid Input Errors
```
Step 1: Navigate to form
Step 2: Fill with invalid data
Step 3: Submit
Step 4: Verify: Error messages displayed
Step 5: Verify: Form not submitted
Step 6: Verify: User can correct and retry
```

### Network Error Simulation
```
Step 1: Start flow normally
Step 2: Introduce network issue (if possible)
Step 3: Attempt action
Step 4: Verify: Error handled gracefully
Step 5: Verify: User informed of issue
Step 6: Verify: Can retry action
```

### Session Timeout
```
Step 1: Login
Step 2: Navigate to protected page
Step 3: Clear session (if possible)
Step 4: Attempt action
Step 5: Verify: Redirect to login
Step 6: Verify: Action can be completed after re-login
```

## Output Format

### Flow Test Results
```markdown
# Flow Test Results

## Summary
- Total Flows: 8
- Passed: 7
- Failed: 1
- Skipped: 0

## Detailed Results

### Flow: User Registration
- Status: PASSED
- Duration: 12.5s

| Step | Action | Status | Notes |
|------|--------|--------|-------|
| 1 | Navigate to /register | OK | Form visible |
| 2 | Fill registration form | OK | All fields filled |
| 3 | Submit form | OK | No errors |
| 4 | Verify account | OK | Dashboard accessible |
| 5 | Verify can login | OK | Login successful |

### Flow: User Login
- Status: PASSED
- Duration: 5.2s

| Step | Action | Status | Notes |
|------|--------|--------|-------|
| 1 | Navigate to /login | OK | Form visible |
| 2 | Enter credentials | OK | Fields filled |
| 3 | Submit | OK | Redirect to dashboard |
| 4 | Verify session | OK | Protected pages accessible |

### Flow: Checkout
- Status: FAILED
- Duration: 18.7s

| Step | Action | Status | Notes |
|------|--------|--------|-------|
| 1 | Add to cart | OK | Item added |
| 2 | View cart | OK | Cart displayed |
| 3 | Proceed to checkout | OK | Form visible |
| 4 | Fill shipping | OK | Address saved |
| 5 | Payment | FAILED | Payment gateway timeout |
| 6 | Verify order | SKIPPED | Previous step failed |

Error Details:
- Location: Payment step
- Error: NetworkError - Payment gateway timeout after 30s
- Console: "Error: Payment processing failed"

## Error Cases Tested

### Registration - Duplicate Email
- Status: PASSED
- Verified: Error message shown
- Verified: Form not submitted

### Login - Invalid Password
- Status: PASSED
- Verified: Error message shown
- Verified: Still on login page

### Checkout - Empty Cart
- Status: PASSED
- Verified: Cannot proceed to checkout
- Verified: Message shown

## Recommendations

1. **Payment Timeout**: Increase gateway timeout or add retry logic
2. **Add Loading States**: Some actions lack visual feedback
3. **Error Recovery**: Consider saving cart state for failed checkouts
```

## Best Practices

1. **Test Happy Path First** - Ensure normal flow works
2. **Test Every Step** - Don't skip intermediate states
3. **Verify State** - Check data persists between steps
4. **Test Error Cases** - Include failure scenarios
5. **Document Dependencies** - Note flow prerequisites
6. **Check Side Effects** - Emails, notifications, etc.
7. **Clean Up** - Reset state between flow tests
8. **Capture Evidence** - Take snapshots at each step
