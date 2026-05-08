---
name: e2e-test-plan
description: Create comprehensive E2E test plans with deep application analysis, navigation coverage audit, and browser-testable scenarios
---

# E2E Test Plan Skill

## Overview

This skill creates exhaustive, browser-testable E2E test plans by deeply analyzing Laravel Filament applications. It documents all pages, user roles, critical flows, navigation coverage, and detailed test scenarios that can be executed step-by-step by a QA tester who has never seen the codebase.

## Standard Plan Location

**Default output**: `docs/detailed-test-list.md`

This skill ALWAYS saves the test plan to `docs/detailed-test-list.md` unless a custom path is specified via the `--output` flag.

**Important**:
- Create the `docs/` directory if it doesn't exist
- Use the Write tool to save the plan to the standard location
- In update mode: Merge new discoveries with existing plan content
- Use `--force` flag to completely overwrite existing plan
- Use `--quick` flag for basic plan without deep discovery

## Purpose

Generate structured test plans that ensure:
- All pages are identified and will be tested
- All user roles are mapped with their permissions
- Critical user flows are documented
- Test scenarios cover positive and negative cases
- **100% NAVIGATION COVERAGE**: Every menu item and internal link is tested
- Cross-user interactions are documented
- Every test can be executed by someone who never saw the codebase
- Priority levels guide test execution order

## Review and Update Mode

When `docs/detailed-test-list.md` exists (and no `--force` flag), operate in **review and update mode**:

### Step 0a: Read Existing Plan

1. **Parse Existing Plan Content**
   - Read `docs/detailed-test-list.md`
   - Extract existing pages from navigation registry
   - Extract existing roles from test user accounts
   - Extract existing flows from test sections
   - Extract test credentials
   - Note the previous "Generated" date

### Step 0b: Validate Existing Content

1. **Validate Pages**
   For each page in the existing plan:
   - Check if the route still exists in the codebase
   - For Laravel: Check routes/web.php, Filament resources
   - Mark pages as "deprecated" if route no longer exists

2. **Validate Roles**
   - Check if role definitions still exist
   - Check permission assignments
   - Mark roles that no longer exist

3. **Validate Flows**
   - Check if flow entry points still exist
   - Verify flow steps are still valid

### Step 0c: Discover New Content

Compare current codebase against documented content:
- Find new routes not in existing plan
- Find new Filament resources
- Find new roles/permissions
- Find new navigation items

### Step 0d: Merge and Update

- Keep valid existing content
- Add newly discovered content
- Mark deprecated items
- Generate update report showing changes

## Workflow

### Phase 1: Deep Discovery (Execute All Commands)

You MUST execute these discovery commands to understand the complete application:

#### 1.1 Database Architecture Analysis

```bash
ls -la database/migrations/
cat database/migrations/*.php
```

For each table, document:
- Table name and purpose
- Key columns and types
- Foreign key relationships
- Pivot tables

#### 1.2 Model & Relationship Mapping

```bash
ls -la app/Models/
cat app/Models/*.php
```

For each model, extract:
- Relationships (hasMany, belongsTo, belongsToMany, morphTo)
- Scopes (local and global)
- Casts and attributes
- Traits used (HasRoles, SoftDeletes)

#### 1.3 Authentication & Authorization System

```bash
cat config/auth.php
cat config/permission.php 2>/dev/null
ls -la app/Policies/ 2>/dev/null
cat app/Policies/*.php 2>/dev/null
cat app/Providers/AuthServiceProvider.php 2>/dev/null
ls -la app/Http/Middleware/
cat database/seeders/*.php
grep -A 50 "Role\|Permission" database/seeders/*.php 2>/dev/null
```

Document:
- All roles in the system
- All permissions per role
- Policy rules per resource
- Guard configurations

#### 1.4 Filament Panel Configuration

```bash
cat app/Providers/Filament/*.php 2>/dev/null
ls -la app/Filament/
find app -name "*PanelProvider*" -exec cat {} \; 2>/dev/null
```

Document:
- Number of panels
- Panel URLs and access rules
- Navigation structure
- Multi-tenant configuration

#### 1.5 Filament Resources Deep Dive

```bash
find app/Filament -name "*Resource.php" | head -50
find app/Filament -name "*Resource.php" -exec cat {} \;
```

For each resource, extract:
- Associated model
- Form fields and validation rules
- Table columns and filters
- Actions (table, bulk, header)
- Relation managers
- Authorization methods

#### 1.6 Filament Pages & Widgets

```bash
find app/Filament -name "*Page*.php" -exec cat {} \; 2>/dev/null
find app/Filament -name "*Widget*.php" -exec cat {} \; 2>/dev/null
ls -la app/Livewire/ 2>/dev/null
```

#### 1.7 Business Logic Layer

```bash
ls -la app/Actions/ 2>/dev/null
cat app/Actions/**/*.php 2>/dev/null
ls -la app/Services/ 2>/dev/null
ls -la app/Jobs/ 2>/dev/null
cat app/Jobs/*.php 2>/dev/null
ls -la app/Notifications/ 2>/dev/null
cat app/Notifications/*.php 2>/dev/null
ls -la app/Mail/ 2>/dev/null
```

#### 1.8 Routes & API

```bash
cat routes/web.php
cat routes/api.php 2>/dev/null
php artisan route:list --path=admin 2>/dev/null
php artisan route:list 2>/dev/null | head -100
```

#### 1.9 Subscription/Billing System

```bash
cat composer.json | grep -i "cashier\|stripe\|paddle"
cat config/cashier.php 2>/dev/null
grep -r "subscription\|plan\|billing" database/migrations/
grep -r "Billable\|subscription" app/Models/
```

#### 1.10 Multi-tenancy

```bash
cat composer.json | grep -i "tenancy\|team\|organization"
grep -r "Tenant\|Team\|Organization\|Workspace" app/Models/
```

#### 1.11 Navigation Audit (CRITICAL)

```bash
grep -r "NavigationItem\|navigationItems\|getNavigation\|menu" app/Filament/ --include="*.php"
grep -r "::make\|NavigationGroup\|navigationLabel\|navigationIcon" app/Filament/ --include="*.php" | head -100
grep -r "Action::make\|Tables\\\\Actions\|->url(\|->link(" app/Filament/ --include="*.php" | head -50
```

### Phase 2: Synthesis

Based on Phase 1 analysis, create:

#### 2.1 Application Purpose Statement
Write 2-3 sentences on what this app does and its core value.

#### 2.2 User/Role Matrix
Create detailed table of all user types with permissions:

| User Type/Role | Access Level | Primary Use Cases | Key Permissions |
|---------------|--------------|-------------------|-----------------|
| Super Admin   | Full         | System config     | Everything      |
| Admin         | High         | Manage users      | CRUD users      |
| Member        | Standard     | Core features     | Own resources   |
| Guest         | Limited      | View only         | Read public     |

#### 2.3 Core User Journeys
Identify the 5-10 most important user flows.

#### 2.4 Entity Relationship Map
Document key models and their relationships.

### Phase 3: Generate Test Plan Document

Create `docs/detailed-test-list.md` with ALL required sections:

```markdown
# [Application Name] - Detailed Test List

> Generated: [Date]
> Application Version: [Version if available]
> Based on analysis of: [Key files analyzed]

## Test Environment Setup

### Prerequisites
- [ ] Application deployed and accessible at: `[URL]`
- [ ] Database seeded with test data
- [ ] Email testing service configured (e.g., Mailtrap)
- [ ] Payment gateway in test mode (if applicable)

### Test User Accounts

| User ID | Email | Password | Role(s) | Plan | Notes |
|---------|-------|----------|---------|------|-------|
| U1 | admin@test.com | TestPass123! | Super Admin | - | Full access |
| U2 | owner@test.com | TestPass123! | Team Owner | Pro | Team owner |
| U3 | member@test.com | TestPass123! | Member | Free | Standard user |
| U4 | viewer@test.com | TestPass123! | Viewer | - | Read-only |
| U5 | (to be created) | TestPass123! | User | - | Created via invitation |

### Initial Data State

| Entity | Count | Key Records |
|--------|-------|-------------|
| Users | 4 | See above |
| Teams | 2 | "Acme Corp" (U2 owner), "Beta Inc" (U3 member) |
| [Resource] | X | [Description] |

---

## Section 0: Navigation & Link Coverage Audit

This section ensures 100% coverage of all navigable elements.

### 0.1 Complete Navigation Registry

#### 0.1.1 Sidebar Menu Items

| Menu Item | URL Path | Visible To | Tested In | Test Actor |
|-----------|----------|------------|-----------|------------|
| Dashboard | /admin | All roles | 1.1.1, 2.1.1 | U1, U2 |
| Users | /admin/users | Admin only | 5.1.1 | U1 |
| Users > Create | /admin/users/create | Admin only | 5.1.2 | U1 |
| Teams | /admin/teams | Owner+ | 3.1.1 | U2 |
| Projects | /admin/projects | All roles | 2.2.1 | U2 |
| [Continue for ALL menu items...] | | | | |

#### 0.1.2 Resource Action Buttons

| Resource | Action | URL/Behavior | Tested In | Test Actor |
|----------|--------|--------------|-----------|------------|
| Projects | View | /admin/projects/{id} | 2.2.3 | U2 |
| Projects | Edit | /admin/projects/{id}/edit | 2.2.3 | U2 |
| Projects | Delete | Modal confirmation | 2.2.4 | U2 |
| [Continue for ALL actions...] | | | | |

#### 0.1.3 Internal Cross-Reference Links

| Source Page | Link Text/Location | Destination | Tested In |
|-------------|-------------------|-------------|-----------|
| Task Detail | "Project: [Name]" | Project detail | 2.3.2 |
| Project Detail | "Owner: [Name]" | User profile | 2.2.3 |
| [Continue for ALL links...] | | | |

#### 0.1.4 Header/Toolbar Elements

| Element | Location | Action | Tested In |
|---------|----------|--------|-----------|
| User dropdown | Top-right | Opens profile menu | 1.1.1 |
| Logout | User dropdown | Logs out, redirects | 1.4.1 |
| Notifications bell | Top-right | Opens notifications | 3.1.2 |
| Global search | Header | Opens search modal | 2.4.1 |

### 0.2 Full Menu Traversal Tests

#### Test 0.2.1: Super Admin - Complete Menu Access
**Actor:** U1 (Super Admin)
**Purpose:** Access every single menu item to verify all pages load without error
**Preconditions:** U1 logged in

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Verify sidebar shows all items | All menu items visible |
| 2 | Click "Dashboard" | Page loads, URL = /admin |
| 3 | Click "Users" | Page loads, URL = /admin/users |
| 4 | Click "Create" on Users | Form loads, URL = /admin/users/create |
| 5 | Click "Users" breadcrumb | Returns to /admin/users |
| [CONTINUE FOR EVERY MENU ITEM] | | |
| N | Click user dropdown > "Logout" | Logged out, redirected to login |

**Postconditions:** All menu items verified accessible

---

#### Test 0.2.2: Team Owner - Menu Access & Restrictions
**Actor:** U2 (Team Owner)
**Purpose:** Verify correct menu visibility and restricted pages return 403
**Preconditions:** U2 logged in

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Verify sidebar items | Shows permitted items only |
| 2 | Verify hidden items | Does NOT show admin-only items |
| 3 | Click each visible menu item | All load successfully |
| 4 | Manually navigate to /admin/users | 403 Forbidden OR redirect |
| [TEST ALL BOUNDARIES] | | |

---

#### Test 0.2.3: Standard Member - Menu Access & Restrictions
**Actor:** U3 (Team Member)
**Purpose:** Verify most restrictive common role
**Preconditions:** U3 logged in

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Verify sidebar items | Shows minimal items |
| 2 | Navigate to restricted URL | 403 Forbidden |
| [TEST ALL BOUNDARIES] | | |

### 0.3 Breadcrumb Navigation Tests

#### Test 0.3.1: Deep Navigation Breadcrumb Trail
**Actor:** U2
**Preconditions:** Project with tasks exists

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to deep nested page | URL loads correctly |
| 2 | Verify breadcrumb trail | Shows full path |
| 3 | Click each breadcrumb level | Navigates correctly |

### 0.4 Relation Manager Navigation

#### Test 0.4.1: Navigate Through Relation Managers
**Actor:** U2
**Preconditions:** Resource with relations exists

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to resource detail | Page loads |
| 2 | Click relation manager tabs | Each tab loads data |
| 3 | Click related item | Navigates or opens modal |

### 0.5 Coverage Verification Checklist

At the end of test execution, verify:

- [ ] Every row in table 0.1.1 (Sidebar Menu) has been executed
- [ ] Every row in table 0.1.2 (Resource Actions) has been executed
- [ ] Every row in table 0.1.3 (Cross-Reference Links) has been executed
- [ ] Every row in table 0.1.4 (Header Elements) has been executed
- [ ] All restricted URLs tested for each role (403 verification)
- [ ] Breadcrumb navigation tested at least 3 levels deep
- [ ] All relation manager tabs accessed

---

## Section 1: Authentication & Access Control

### 1.1 Login Flow

#### Test 1.1.1: Standard Login - Valid Credentials
**Actor:** U1 (Super Admin)
**Preconditions:** User U1 exists and is active

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `[login-url]` | Login page loads |
| 2 | Enter email: `admin@test.com` | Email field populated |
| 3 | Enter password: `TestPass123!` | Password field masked |
| 4 | Click "Sign In" button | - Redirect to dashboard<br>- User name visible |

**Postconditions:** User session active

---

#### Test 1.1.2: Login - Invalid Credentials
**Actor:** Anonymous
**Preconditions:** None

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to login | Login page loads |
| 2 | Enter wrong credentials | Fields populated |
| 3 | Click "Sign In" | - Error message shown<br>- Remain on login |

---

### 1.2 Registration Flow (if applicable)
[Tests...]

### 1.3 Password Reset Flow
[Tests...]

### 1.4 Logout Flow
[Tests...]

---

## Section 2: [Primary User Role] - Core Functionality

### 2.1 Dashboard Verification

#### Test 2.1.1: Dashboard Loads with Correct Data
**Actor:** U2 (Team Owner)
**Preconditions:** U2 logged in, has existing data

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to dashboard | Dashboard page loads |
| 2 | Verify statistics widget | Shows accurate counts |
| 3 | Verify recent activity | Lists recent actions |
| 4 | Verify navigation menu | Permitted items visible |

---

### 2.2 [Primary Resource] Management

#### Test 2.2.1: Create [Resource] - Happy Path
**Actor:** U2 (Team Owner)
**Preconditions:** U2 logged in

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Click "[Resources]" in nav | List page loads |
| 2 | Click "New [Resource]" | Create form opens |
| 3 | Fill required fields | Fields accept input |
| 4 | Click "Create" | - Success notification<br>- Resource in list |

**Postconditions:** New resource exists, owned by U2

---

#### Test 2.2.2: Create [Resource] - Validation Errors
**Actor:** U2 (Team Owner)
**Preconditions:** U2 logged in

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to create form | Form loads |
| 2 | Leave required fields empty | - |
| 3 | Click "Create" | - Validation errors shown<br>- Form does NOT submit |

---

#### Test 2.2.3: View [Resource]
**Actor:** U2
[Tests...]

#### Test 2.2.4: Edit [Resource] - Owner Can Edit
**Actor:** U2
[Tests...]

#### Test 2.2.5: Edit [Resource] - Non-Owner Cannot Edit
**Actor:** U3
**Preconditions:** Resource owned by U2

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Login as U3 | Dashboard loads |
| 2 | Navigate to U2's resource edit URL | 403 Forbidden OR redirect |

---

#### Test 2.2.6: Delete [Resource]
**Actor:** U2
[Tests...]

---

### 2.3 Search & Filtering
[Tests...]

---

## Section 3: Multi-User Interaction Flows

### 3.1 Invitation & Onboarding

#### Test 3.1.1: User Invites Team Member
**Actor:** U2 (Team Owner)
**Preconditions:** U2 owns team

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to Team Settings | Settings page loads |
| 2 | Click "Invite Member" | Modal opens |
| 3 | Enter email: `newuser@test.com` | Email populated |
| 4 | Select role: "Member" | Role selected |
| 5 | Click "Send Invitation" | - Success message<br>- Invitation in list |

**Postconditions:** Invitation record created

---

#### Test 3.1.2: Invitee Accepts Invitation (U5)
**Actor:** U5 (new user)
**Preconditions:** Test 3.1.1 completed

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Check email | Invitation received |
| 2 | Click invitation link | Registration page loads |
| 3 | Complete registration | Account created |
| 4 | Verify team membership | Listed as team member |

**Postconditions:** U5 is team member

---

### 3.2 Resource Sharing & Collaboration

#### Test 3.2.1: Owner Shares Resource with Team
**Actor:** U2 (Owner)
**Preconditions:** U2 owns resource, U5 is team member

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to resource | Detail view loads |
| 2 | Click "Share" | Sharing modal opens |
| 3 | Enable team sharing | Toggle activated |
| 4 | Save | Success, sharing indicator shown |

**Postconditions:** Resource visible to team

---

#### Test 3.2.2: Team Member Views Shared Resource
**Actor:** U5 (Team Member)
**Preconditions:** Test 3.2.1 completed

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Login as U5 | Dashboard loads |
| 2 | Navigate to resources | Shared resource visible |
| 3 | View shared resource | Content accessible |

---

#### Test 3.2.3: Team Member Edits Shared Resource
**Actor:** U5 (Team Member with edit permission)
**Preconditions:** U5 has edit permission

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open shared resource | View loads |
| 2 | Click Edit | Form loads |
| 3 | Make changes | Changes accepted |
| 4 | Save | Success, changes visible |

**Postconditions:** Resource modified by U5

---

#### Test 3.2.4: Owner Sees Changes Made by Team Member
**Actor:** U2 (Owner)
**Preconditions:** Test 3.2.3 completed

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Login as U2 | Dashboard loads |
| 2 | View resource | Changes by U5 visible |
| 3 | Check activity log | Edit by U5 recorded |

---

## Section 4: Subscription & Billing (if applicable)

### 4.1 Plan Restrictions

#### Test 4.1.1: Free User Hits Feature Limit
**Actor:** U3 (Free Plan)
**Preconditions:** U3 at plan limit

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Attempt to exceed limit | Upgrade prompt shown |

---

#### Test 4.1.2: User Upgrades Plan
**Actor:** U3
[Tests...]

---

## Section 5: Admin Panel Functions

### 5.1 User Management

#### Test 5.1.1: Admin Creates User
**Actor:** U1 (Super Admin)
[Tests...]

#### Test 5.1.2: Admin Impersonates User
**Actor:** U1 (Super Admin)
**Preconditions:** U1 logged in, U3 exists

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to Users | User list loads |
| 2 | Click "Impersonate" on U3 | Impersonation banner appears |
| 3 | Verify viewing as U3 | U3's data visible |
| 4 | Click "Stop Impersonating" | Return to admin view |

---

### 5.2 System Settings
[Tests...]

---

## Section 6: Edge Cases & Error Handling

### 6.1 Session Expiry

#### Test 6.1.1: Session Timeout Handling
**Actor:** U2

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Login as U2 | Dashboard loads |
| 2 | Wait for session timeout | - |
| 3 | Attempt action | Prompt to re-login |

---

### 6.2 Concurrent Editing

#### Test 6.2.1: Two Users Edit Same Resource
**Actors:** U2 and U5

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | U2 opens edit form | Form loads |
| 2 | U5 opens same form | Form loads |
| 3 | U2 saves changes | Success |
| 4 | U5 saves changes | Conflict warning OR last write wins |

---

### 6.3 Permission Changes Mid-Session

#### Test 6.3.1: Role Downgrade While Logged In
**Actors:** U1 (Admin) and U2 (target)

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | U1 changes U2's role | Change saved |
| 2 | U2 navigates to now-restricted page | Access denied |

---

## Section 7: Notifications & Emails

### 7.1 Email Triggers

#### Test 7.1.1: Notification Sent on Resource Share
[Tests...]

---

## Appendix A: Test Data Reset Procedure

```bash
php artisan migrate:fresh --seed
# Or specific seeders:
php artisan db:seed --class=TestDataSeeder
```

## Appendix B: Known Issues / Skip Conditions

| Test ID | Issue | Skip Condition |
|---------|-------|----------------|
| 4.1.2 | Stripe test mode only | Production |

## Appendix C: Test Execution Log Template

| Date | Tester | Test ID | Result | Notes |
|------|--------|---------|--------|-------|
| | | | Pass / Fail / Skip | |
```

## Output

The skill produces:
1. A comprehensive test plan at `docs/detailed-test-list.md`
2. 100% navigation coverage through Section 0
3. Structured tests executable by any QA tester
4. Cross-user interaction scenarios
5. Edge cases and error handling tests

**Final Step**: After generating the plan content, you MUST:
1. Ensure the `docs/` directory exists (create if needed)
2. Write the plan to `docs/detailed-test-list.md` using the Write tool
3. Confirm the file was saved successfully

## Best Practices

1. **Be Exhaustive** - Don't skip pages or flows
2. **100% Navigation Coverage** - Every menu item, every link, every action
3. **Document Assumptions** - Note any assumptions made
4. **Include Credentials** - Provide test user info
5. **Prioritize** - Mark critical tests as high priority
6. **Consider Edge Cases** - Include error scenarios
7. **Cross-User Flows** - Test multi-user interactions
8. **Actor Specification** - Every test must specify the actor
9. **Preconditions** - Document what must exist before each test
10. **Postconditions** - Document expected state after each test
11. **One Action Per Step** - Each step = one browser action
12. **Expected Results** - Every action has explicit expected outcome
13. **Dependencies** - Mark test dependencies clearly
14. **Negative Tests** - Include what should NOT happen
15. **Review Mode** - When updating, preserve working content and merge carefully
