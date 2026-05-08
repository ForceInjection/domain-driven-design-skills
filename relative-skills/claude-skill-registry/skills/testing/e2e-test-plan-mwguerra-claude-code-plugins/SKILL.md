---
name: e2e-test-plan
description: Create comprehensive E2E test plans with all major flows, pages, roles, and test scenarios
---

# E2E Test Plan Skill

## Overview

This skill creates detailed E2E test plans that document all pages, user roles, critical flows, and test scenarios for comprehensive Playwright-based testing.

## Standard Plan Location

**Default output**: `tests/e2e-test-plan.md`

This skill ALWAYS saves the test plan to `tests/e2e-test-plan.md` unless a custom path is specified via the `--output` flag. This standard location allows all E2E testing commands to automatically find and use the plan.

**Important**:
- Create the `tests/` directory if it doesn't exist
- Use the Write tool to save the plan to the standard location
- Overwrite any existing plan at that location

## Purpose

Generate structured test plans that ensure:
- All pages are identified and will be tested
- All user roles are mapped with their permissions
- Critical user flows are documented
- Test scenarios cover positive and negative cases
- Priority levels guide test execution order
- Plan is saved to standard location for other commands to use

## Workflow

### Step 1: Discover Application Structure

1. **Identify Project Type**
   - Analyze package.json, composer.json, etc.
   - Determine framework (Laravel, Next.js, Vue, React, etc.)
   - Identify routing mechanism

2. **Map Routes/Pages**
   - Find route definitions
   - List all accessible URLs
   - Note dynamic routes with parameters

3. **Identify Authentication**
   - Find auth configuration
   - Map login/logout URLs
   - Identify auth middleware

### Step 2: Analyze User Roles

1. **Find Role Definitions**
   - Check database seeders
   - Look at role/permission tables
   - Find auth guards and policies

2. **Map Role Permissions**
   - Which pages each role can access
   - Which actions each role can perform
   - Role hierarchy if exists

3. **Identify Test Users**
   - Credentials for each role
   - Test user creation if needed

### Step 3: Map Critical Flows

1. **Authentication Flows**
   - Login flow
   - Registration flow
   - Password reset flow
   - Logout flow

2. **Core Business Flows**
   - Main user journeys
   - CRUD operations
   - Checkout/purchase flows
   - Data import/export

3. **Administrative Flows**
   - User management
   - Settings configuration
   - Reporting

### Step 4: Define Test Scenarios

For each page/flow:

1. **Happy Path**
   - Normal expected behavior
   - Valid inputs
   - Successful completion

2. **Error Cases**
   - Invalid inputs
   - Validation failures
   - Server errors

3. **Edge Cases**
   - Empty states
   - Large data sets
   - Concurrent actions

4. **Authorization Tests**
   - Access with wrong role
   - Unauthenticated access
   - Cross-resource access

### Step 5: Generate Test Plan Document

Create a structured markdown document:

```markdown
# E2E Test Plan

## Application Information
- **Name**: [Application Name]
- **Base URL**: [Base URL]
- **Framework**: [Framework]
- **Generated**: [Date]

## User Roles

| Role | Description | Can Access | Cannot Access |
|------|-------------|------------|---------------|
| guest | Unauthenticated user | public pages | protected pages |
| user | Basic authenticated user | user pages | admin pages |
| admin | Administrator | all pages | - |

### Test Credentials
| Role | Email | Password |
|------|-------|----------|
| admin | admin@example.com | password |
| user | user@example.com | password |

## Pages to Test

### Public Pages
| Page | Route | Priority | Actions |
|------|-------|----------|---------|
| Home | / | High | load, navigation |
| About | /about | Medium | load, links |
| Contact | /contact | Medium | load, form submit |

### Protected Pages (User)
| Page | Route | Priority | Actions |
|------|-------|----------|---------|
| Dashboard | /dashboard | High | load, widgets |
| Profile | /profile | High | view, edit, save |

### Protected Pages (Admin)
| Page | Route | Priority | Actions |
|------|-------|----------|---------|
| Admin Dashboard | /admin | High | load, stats |
| User Management | /admin/users | High | list, create, edit, delete |

## Critical Flows

### Flow 1: User Registration
**Priority**: High
**Roles**: guest

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to /register | Registration form displayed |
| 2 | Fill required fields | Fields accept input |
| 3 | Submit form | Account created, redirect to dashboard |
| 4 | Check email | Verification email received |

### Flow 2: User Login
**Priority**: High
**Roles**: guest → user

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to /login | Login form displayed |
| 2 | Enter credentials | Fields accept input |
| 3 | Click login button | Redirected to dashboard |
| 4 | Verify session | User menu shows name |

### Flow 3: [Business Critical Flow]
**Priority**: High
**Roles**: user

| Step | Action | Expected Result |
|------|--------|-----------------|
| ... | ... | ... |

## Test Scenarios

### Page Load Tests
For each page:
- [ ] Page loads without errors
- [ ] All expected elements present
- [ ] No console errors
- [ ] No failed network requests
- [ ] Proper title and meta

### Form Validation Tests
For each form:
- [ ] Empty submission shows errors
- [ ] Invalid data shows specific errors
- [ ] Valid data submits successfully
- [ ] Confirmation shown on success

### Authorization Tests
For each protected resource:
- [ ] Guest redirected to login
- [ ] Wrong role gets 403 or redirect
- [ ] Correct role has access
- [ ] Actions restricted by permission

### Responsive Tests
For each critical page:
- [ ] Desktop (1920x1080)
- [ ] Tablet (768x1024)
- [ ] Mobile (375x812)

## Test Execution Order

1. **Setup**
   - Verify application is running
   - Check test users exist
   - Clear any test data

2. **Public Pages** (no auth required)
   - Test all public pages load correctly

3. **Authentication Flows**
   - Test login, logout, registration

4. **Authenticated Pages by Role**
   - For each role, test accessible pages

5. **Critical Business Flows**
   - Test main user journeys

6. **Edge Cases and Error Handling**
   - Test error scenarios

7. **Cleanup**
   - Remove test data if needed
   - Close browser

## Success Criteria

- All pages load without errors
- All forms validate correctly
- All roles can access appropriate resources
- All critical flows complete successfully
- No JavaScript errors in console
- All API calls succeed (or fail gracefully)
- Response times are acceptable
```

## Output

The skill produces:
1. A comprehensive test plan markdown document saved to `tests/e2e-test-plan.md`
2. A structured list of all tests to execute
3. Priority ordering for test execution
4. Test credentials and setup requirements

**Final Step**: After generating the plan content, you MUST:
1. Ensure the `tests/` directory exists (create if needed)
2. Write the plan to `tests/e2e-test-plan.md` using the Write tool
3. Confirm the file was saved successfully

## Best Practices

1. **Be Exhaustive** - Don't skip pages or flows
2. **Document Assumptions** - Note any assumptions made
3. **Include Credentials** - Provide test user info
4. **Prioritize** - Mark critical tests as high priority
5. **Consider Edge Cases** - Include error scenarios
6. **Viewport Testing** - Include responsive tests
