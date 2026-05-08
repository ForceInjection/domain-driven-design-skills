---
name: e2e-role-test
description: Execute comprehensive role-based E2E testing with Playwright, testing all user flows for each role
---

# E2E Role-Based Testing Skill

## Overview

This skill executes comprehensive role-based E2E testing using Playwright MCP. It tests all pages and flows for each user role, verifying proper access control and role-specific functionality.

## Standard Test Plan Location

**Plan file**: `tests/e2e-test-plan.md`

This skill reads role definitions and test credentials from the test plan at `tests/e2e-test-plan.md`. If the plan file doesn't exist, the calling command should invoke the `e2e-test-plan` skill first to generate it.

## Purpose

Ensure that:
- Each user role can access appropriate resources
- Unauthorized access is properly blocked
- Role-specific features work correctly
- Cross-role security is maintained

## Workflow

### Step 0: Test Plan Verification (REQUIRED FIRST)

**CRITICAL**: Before testing roles, verify the test plan exists.

1. **Check for Test Plan**
   - Look for `tests/e2e-test-plan.md`
   - If the file exists, read the "User Roles" and "Test Credentials" sections
   - If the file does NOT exist, STOP and report that the plan must be generated first

2. **Read Role Information from Plan**
   - Extract role names and descriptions
   - Extract test credentials for each role
   - Extract role-resource access matrix
   - Use this information for testing

### Step 1: Prepare Role Testing

1. **Identify All Roles**
   - List all user roles in the system
   - Note the role hierarchy
   - Map permissions per role

2. **Prepare Test Users**
   - Identify login credentials for each role
   - Ensure test users exist
   - Note any role-switching mechanisms

3. **Map Role-Resource Matrix**
   ```
   | Resource | Guest | User | Admin |
   |----------|-------|------|-------|
   | /home | Yes | Yes | Yes |
   | /dashboard | No | Yes | Yes |
   | /admin | No | No | Yes |
   ```

### Step 2: Guest Role Testing

**Test unauthenticated access:**

1. **Public Pages**
   ```
   browser_navigate to each public page
   browser_snapshot to verify content
   Confirm: Page loads correctly
   ```

2. **Protected Page Blocking**
   ```
   browser_navigate to protected page
   browser_snapshot to check result
   Confirm: Redirect to login OR 403 page
   ```

3. **Guest-Specific Features**
   ```
   Test: Registration form accessible
   Test: Login form accessible
   Test: Password reset accessible
   ```

### Step 3: Authenticated Role Testing

For EACH authenticated role:

1. **Login as Role**
   ```
   browser_navigate to /login
   browser_fill_form with role credentials:
     - fields: [
         { name: "Email", type: "textbox", ref: "[email-input-ref]", value: "role@example.com" },
         { name: "Password", type: "textbox", ref: "[password-input-ref]", value: "password" }
       ]
   browser_click on submit button
   browser_wait_for dashboard or success indicator
   browser_snapshot to verify logged in
   ```

2. **Test Accessible Pages**
   ```
   For each page this role SHOULD access:
     browser_navigate to page URL
     browser_snapshot
     browser_console_messages to check for errors
     Verify: Page content loads correctly
     Verify: Role-specific elements present
   ```

3. **Test Blocked Pages**
   ```
   For each page this role should NOT access:
     browser_navigate to page URL
     browser_snapshot
     Verify: 403 error OR redirect occurs
     Verify: No unauthorized data exposed
   ```

4. **Test Role-Specific Actions**
   ```
   For each action this role can perform:
     Navigate to action page
     Perform the action
     Verify success

   For each action this role CANNOT perform:
     Attempt the action
     Verify it's blocked
   ```

5. **Logout**
   ```
   browser_click logout button
   browser_wait_for login page
   browser_snapshot to confirm logged out
   ```

### Step 4: Role-Specific Flow Testing

#### User Role Flows
```markdown
## User Role Tests

### Profile Management
1. Navigate to /profile
2. Verify can view own profile
3. Edit profile information
4. Save changes
5. Verify changes persisted

### Data Access
1. Navigate to /my-data
2. Verify can see own data only
3. Cannot see other users' data
4. Can create new data
5. Can edit own data
6. Can delete own data

### Restricted Areas
1. Cannot access /admin
2. Cannot access /admin/users
3. Cannot modify other users
```

#### Admin Role Flows
```markdown
## Admin Role Tests

### User Management
1. Navigate to /admin/users
2. View all users list
3. Create new user
4. Edit existing user
5. Delete user (not self)
6. Change user roles

### System Settings
1. Access settings page
2. Modify configurations
3. Save changes
4. Verify persistence

### Admin-Only Features
1. Access reports
2. View audit logs
3. Manage permissions
```

### Step 5: Cross-Role Security Tests

1. **Session Hijacking Prevention**
   ```
   Login as User A
   Copy session info
   Try to access User B data
   Verify: Access denied
   ```

2. **Privilege Escalation Prevention**
   ```
   Login as regular user
   Attempt admin actions directly
   Verify: Actions blocked
   ```

3. **IDOR Testing**
   ```
   Login as User A
   Note resource ID
   Try accessing other user's resource by ID
   Verify: Access denied or own data shown
   ```

## Test Patterns

### Role Login Pattern
```javascript
// Using Playwright MCP tools
async function loginAsRole(role, credentials) {
  // Navigate to login
  browser_navigate({ url: "/login" });

  // Fill login form
  browser_fill_form({
    fields: [
      { name: "Email", type: "textbox", ref: "[email-ref]", value: credentials.email },
      { name: "Password", type: "textbox", ref: "[password-ref]", value: credentials.password }
    ]
  });

  // Submit
  browser_click({ element: "Login button", ref: "[submit-ref]" });

  // Wait for dashboard
  browser_wait_for({ text: "Dashboard" });

  // Verify
  browser_snapshot();
}
```

### Access Verification Pattern
```javascript
async function verifyAccess(url, shouldHaveAccess) {
  browser_navigate({ url });
  const snapshot = browser_snapshot();

  if (shouldHaveAccess) {
    // Should see page content
    verify(snapshot.contains(expectedContent));
  } else {
    // Should see 403 or redirect
    verify(snapshot.contains("Access Denied") || currentUrl === "/login");
  }
}
```

### Role Matrix Test Pattern
```javascript
const roleMatrix = {
  guest: {
    canAccess: ["/", "/about", "/login", "/register"],
    cannotAccess: ["/dashboard", "/profile", "/admin"]
  },
  user: {
    canAccess: ["/", "/about", "/dashboard", "/profile"],
    cannotAccess: ["/admin", "/admin/users"]
  },
  admin: {
    canAccess: ["/", "/about", "/dashboard", "/profile", "/admin", "/admin/users"],
    cannotAccess: []
  }
};

for (const [role, permissions] of Object.entries(roleMatrix)) {
  loginAsRole(role);

  for (const url of permissions.canAccess) {
    verifyAccess(url, true);
  }

  for (const url of permissions.cannotAccess) {
    verifyAccess(url, false);
  }

  logout();
}
```

## Output Format

### Role Test Results
```markdown
# Role-Based Test Results

## Guest Role
### Accessible Pages
- [x] Home (/) - Passed
- [x] About (/about) - Passed
- [x] Login (/login) - Passed
- [x] Register (/register) - Passed

### Blocked Pages
- [x] Dashboard (/dashboard) - Correctly redirects to /login
- [x] Profile (/profile) - Correctly redirects to /login
- [x] Admin (/admin) - Correctly redirects to /login

## User Role (test@example.com)
### Login
- [x] Can login successfully
- [x] Redirected to dashboard

### Accessible Pages
- [x] Dashboard (/dashboard) - Passed
- [x] Profile (/profile) - Passed
- [x] Settings (/settings) - Passed

### Blocked Pages
- [x] Admin (/admin) - Correctly shows 403
- [x] User Management (/admin/users) - Correctly shows 403

### Role-Specific Actions
- [x] Can edit own profile
- [x] Can view own data
- [x] Cannot view other users' data
- [x] Cannot access admin features

### Logout
- [x] Logout successful

## Admin Role (admin@example.com)
### Login
- [x] Can login successfully
- [x] Redirected to admin dashboard

### Full Access
- [x] All pages accessible
- [x] Can manage users
- [x] Can access settings
- [x] Can view reports

### Admin Actions
- [x] Can create users
- [x] Can edit users
- [x] Can delete users
- [x] Can change roles

## Security Tests
- [x] Session isolation verified
- [x] No privilege escalation possible
- [x] IDOR protection verified

## Summary
| Role | Pages Tested | Passed | Failed |
|------|--------------|--------|--------|
| Guest | 7 | 7 | 0 |
| User | 10 | 10 | 0 |
| Admin | 15 | 15 | 0 |

Total: 32 tests, 32 passed, 0 failed
```

## Best Practices

1. **Test Every Role** - Never skip a role
2. **Test Both Access and Denial** - Verify can AND cannot access
3. **Clean Session Between Roles** - Logout before testing next role
4. **Document Credentials** - Keep test credentials in the plan
5. **Check Console Errors** - Look for JavaScript errors on each page
6. **Verify Visual Elements** - Use snapshots to verify content
7. **Test Edge Cases** - Empty states, large data, etc.
