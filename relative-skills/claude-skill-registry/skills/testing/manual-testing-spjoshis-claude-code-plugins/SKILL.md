---
name: manual-testing
description: Master manual testing with exploratory testing, test case execution, bug reporting, and quality validation techniques.
---

# Manual Testing

Execute effective manual testing including exploratory testing, test case execution, and thorough quality validation.

## When to Use This Skill

- Exploratory testing
- New feature validation
- Usability testing
- Regression testing
- Ad-hoc testing
- User acceptance testing
- Cross-browser testing
- Mobile device testing

## Core Concepts

### 1. Test Case Format

```markdown
**Test Case ID**: TC-001
**Title**: Verify successful user login with valid credentials
**Priority**: P0 (Critical)
**Preconditions**: User account exists

**Test Steps**:
1. Navigate to login page
2. Enter valid username: "test@example.com"
3. Enter valid password: "Test123!"
4. Click "Login" button

**Expected Result**:
- User is redirected to dashboard
- Welcome message displays: "Welcome, Test User"
- Session token is created
- User avatar shows in header

**Actual Result**: [To be filled during execution]
**Status**: Pass/Fail
**Notes**: [Any observations]
**Screenshots**: [Attach if failed]
```

### 2. Exploratory Testing Charter

```markdown
**Charter**: Explore checkout flow for data validation issues
**Duration**: 60 minutes
**Tester**: Jane
**Date**: 2024-01-15

**Areas to Explore**:
- Form field validation
- Error messaging
- Data persistence
- Browser back button behavior

**Test Ideas**:
- Submit empty forms
- Enter invalid data formats
- Test boundary values
- Try special characters
- Test concurrent sessions

**Bugs Found**:
1. [BUG-001] Email accepts invalid format
2. [BUG-002] Phone number allows letters

**Notes**:
- Payment form very intuitive
- Error messages could be clearer
- Good handling of session timeout

**Coverage**: 75% of planned areas
**Follow-up**: Need to test mobile browsers
```

### 3. Bug Report Template

```markdown
**Bug ID**: BUG-123
**Title**: Login fails with correct credentials after password reset
**Severity**: Critical
**Priority**: P0
**Environment**: Chrome 120, Windows 11, Staging

**Steps to Reproduce**:
1. Reset password via "Forgot Password"
2. Check email and click reset link
3. Enter new password: "NewPass123!"
4. Confirm new password
5. Click "Save"
6. Go to login page
7. Enter email and new password
8. Click "Login"

**Expected**: User logs in successfully
**Actual**: Error: "Invalid credentials"

**Screenshots**: [Attached: error-screenshot.png]
**Logs**: [Attached: console-errors.log]

**Additional Info**:
- Works fine for regular login (no reset)
- Happens 100% of the time
- Clearing cookies doesn't help
- New password works after 5 minutes

**Suggested Fix**: Check password hash update timing
```

## Best Practices

1. **Follow test cases** - Structured execution
2. **Explore creatively** - Think like user
3. **Document findings** - Clear bug reports
4. **Retest thoroughly** - Verify fixes
5. **Test edge cases** - Boundary values
6. **Cross-browser** - Multiple environments
7. **Mobile testing** - Different devices
8. **Screenshots/videos** - Visual evidence

## Resources

- **Exploratory Testing**: James Bach techniques
- **Bug reporting**: Best practices guides
