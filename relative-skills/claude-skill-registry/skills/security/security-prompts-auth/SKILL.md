---
name: security-prompts-auth
description: Authentication and authorization prompt templates for RBAC implementation, permissions systems, ownership verification, and authorization testing. Use when setting up roles, implementing access control, or testing authorization logic. Triggers include "RBAC", "role-based access", "permissions", "ownership", "authorization", "access control", "user roles", "auth testing".
---

# Auth & Authorization Security Templates

## Purpose

This skill provides authentication and authorization prompt templates for implementing secure access control systems. Use these templates to set up role-based access control (RBAC), granular permissions, ownership verification, and comprehensive authorization testing.

## Available Templates

### 01: RBAC Implementation
**File**: `01_rbac_implementation.md`
**When to use**: First time adding roles (user, premium, admin)
**Time**: 60 minutes

**Implementation Coverage**:
- Server-side role storage
- Clerk publicMetadata integration
- Webhook-based role assignment
- Role-based route protection
- Middleware enforcement
- Role checking utilities

**Roles Implemented**:
- **user** (default) - Basic authenticated access
- **premium** (paid) - Enhanced features via Clerk Billing
- **admin** (staff) - Full system access

**Trigger keywords**: "RBAC", "role-based access", "user roles", "implement roles", "setup roles", "add roles", "role system"

**Use case**: Initial authorization setup, multi-tier application, SaaS with subscription tiers

**Output**: Complete RBAC system with Clerk integration

---

### 02: Permissions System
**File**: `02_permissions.md`
**When to use**: Granular permission system beyond basic roles
**Time**: 90 minutes

**Implementation Coverage**:
- Fine-grained permissions
- Permission groups
- Resource-level access
- Permission inheritance
- Dynamic permission checks
- Permission management UI

**Permission Examples**:
- `users.read`, `users.write`, `users.delete`
- `posts.create`, `posts.edit`, `posts.publish`
- `admin.dashboard`, `admin.settings`

**Trigger keywords**: "permissions", "permission system", "granular access", "fine-grained permissions", "permission management", "resource permissions"

**Use case**: Enterprise applications, complex access requirements, team collaboration tools

**Output**: Comprehensive permission system with management interface

---

### 03: Ownership Verification
**File**: `03_ownership.md`
**When to use**: Resource ownership checks (users can only modify their own data)
**Time**: 30 minutes

**Implementation Coverage**:
- Ownership validation
- User-resource relationship checks
- Authorization errors
- Multi-owner scenarios
- Delegation patterns

**Security Focus**:
- Prevent horizontal privilege escalation
- Verify user owns the resource
- Handle shared resources
- Team/organization ownership

**Trigger keywords**: "ownership", "ownership check", "resource ownership", "user owns", "own data only", "verify ownership", "prevent user accessing others data"

**Use case**: Profile editing, document management, any user-specific resources

**Output**: Ownership verification utilities and endpoint protection

---

### 04: Authorization Testing
**File**: `04_auth_testing.md`
**When to use**: Comprehensive authorization testing
**Time**: 60 minutes

**Test Coverage**:
- Role-based access tests
- Permission verification tests
- Ownership check tests
- Negative authorization tests
- Cross-user access prevention
- Privilege escalation tests

**Test Scenarios**:
- User cannot access admin routes
- User cannot modify other users' data
- Premium features blocked for free users
- Unauthenticated requests rejected
- Invalid role assignments rejected

**Trigger keywords**: "auth testing", "authorization tests", "test permissions", "test RBAC", "test access control", "authorization test suite"

**Use case**: Continuous testing, CI/CD integration, security validation

**Output**: Complete authorization test suite

---

## Usage Pattern

### 1. Identify Authorization Need

**First-time setup** (no auth beyond Clerk):
→ 01_rbac_implementation.md

**Need granular control**:
→ 02_permissions.md

**User-specific resources**:
→ 03_ownership.md

**Verify authorization**:
→ 04_auth_testing.md

### 2. Sequential Implementation

**Recommended order**:
```markdown
Step 1: RBAC (Foundation)
→ Use: 01_rbac_implementation.md

Step 2: Ownership (User Resources)
→ Use: 03_ownership.md

Step 3: Permissions (If Needed)
→ Use: 02_permissions.md

Step 4: Testing (Always)
→ Use: 04_auth_testing.md
```

### 3. Load Template

```markdown
Read: .claude/skills/security/security-prompts/auth-authorization/[number]_[name].md
```

### 4. Customize for Application

Replace in template:
- `[role names]` with your roles
- `[permission names]` with your permissions
- `[resource types]` with your data models
- `[access matrix]` with your requirements

### 5. Present Implementation Plan

```markdown
I'll implement [AUTHORIZATION_TYPE] using the auth template.

**What we'll set up**:
- [List from template]

**How it integrates with Clerk**:
- [Clerk-specific details]

**Testing strategy**:
- [Testing approach]

**Estimated time**: [From template]

Let me customize the template for your application...
```

## Common Authorization Patterns

### Pattern 1: Basic RBAC
```markdown
Application: Blog with user/admin roles

Implementation:
→ 01_rbac_implementation.md

Role Matrix:
- user: Read posts, comment, manage own comments
- admin: All user access + create/edit/delete posts, moderate comments

Testing:
→ 04_auth_testing.md
```

### Pattern 2: SaaS with Tiers
```markdown
Application: SaaS tool with free/premium/enterprise

Implementation:
→ 01_rbac_implementation.md

Role Matrix:
- free: Basic features, 10 projects limit
- premium: Advanced features, unlimited projects
- enterprise: All features + team management

Integration:
→ Clerk Billing webhooks set role based on subscription

Testing:
→ 04_auth_testing.md
```

### Pattern 3: User Resources
```markdown
Application: Profile management

Implementation:
Step 1: RBAC for basic roles
→ 01_rbac_implementation.md

Step 2: Ownership for profile editing
→ 03_ownership.md

Verification:
- User A cannot edit User B's profile
- Admins can edit any profile
- Users can edit their own profile

Testing:
→ 04_auth_testing.md
```

### Pattern 4: Enterprise Permissions
```markdown
Application: Team collaboration tool

Implementation:
Step 1: RBAC for base roles
→ 01_rbac_implementation.md

Step 2: Granular permissions
→ 02_permissions.md

Step 3: Ownership for resources
→ 03_ownership.md

Permission Matrix:
- Owner: All permissions
- Admin: Most permissions, cannot delete workspace
- Member: View and edit, cannot manage team
- Guest: View only

Testing:
→ 04_auth_testing.md
```

## Integration with Feature Templates

### Authenticated Endpoints

```markdown
Step 1: Setup RBAC
→ auth-authorization/01_rbac_implementation.md

Step 2: Implement feature with auth
→ prompt-engineering/02_authenticated_endpoint.md

Step 3: Add ownership checks
→ auth-authorization/03_ownership.md

Step 4: Test authorization
→ auth-authorization/04_auth_testing.md
```

### Admin Features

```markdown
Step 1: Setup RBAC (if not exists)
→ auth-authorization/01_rbac_implementation.md

Step 2: Implement admin endpoints
→ prompt-engineering/04_admin_action.md

Step 3: Test admin access
→ auth-authorization/04_auth_testing.md

Step 4: Review security
→ threat-modeling/04_code_review.md
```

## Clerk Integration

All templates integrate with Clerk:

**Role Storage**: `publicMetadata.role`
```typescript
// Read from session
const { sessionClaims } = auth();
const role = sessionClaims?.publicMetadata?.role;
```

**Webhook Assignment**:
```typescript
// In convex/http.ts or app/api/webhooks/clerk/route.ts
await clerkClient.users.updateUserMetadata(userId, {
  publicMetadata: { role: "user" }
});
```

**Middleware Protection**:
```typescript
// In middleware.ts
const role = auth().sessionClaims?.publicMetadata?.role;
if (role !== "admin" && pathname.startsWith("/admin")) {
  return Response.redirect("/unauthorized");
}
```

**Permission Storage** (if using 02_permissions.md):
```typescript
publicMetadata: {
  role: "user",
  permissions: ["posts.read", "posts.create", "comments.create"]
}
```

## Best Practices

### 1. Server-Side Only

**Always verify on server**:
```typescript
// ✅ Good - server-side check
export async function DELETE(req: Request) {
  const { userId } = auth();
  const role = auth().sessionClaims?.publicMetadata?.role;

  if (role !== "admin") {
    return new Response("Forbidden", { status: 403 });
  }
  // Delete logic
}

// ❌ Bad - client could bypass
if (userRole === "admin") {
  deleteButton.disabled = false;
}
```

### 2. Default Deny

**Require explicit permission**:
```typescript
// ✅ Good - default deny
if (role === "admin" || role === "moderator") {
  // Allow
} else {
  return new Response("Forbidden", { status: 403 });
}

// ❌ Bad - default allow
if (role === "guest") {
  return new Response("Forbidden", { status: 403 });
}
// Continues without check
```

### 3. Test Negative Cases

**Always test rejection**:
```typescript
// Test user cannot access admin
test("non-admin cannot delete posts", async () => {
  const response = await DELETE("/api/posts/123", {
    headers: { Authorization: `Bearer ${userToken}` }
  });
  expect(response.status).toBe(403);
});
```

### 4. Log Authorization Failures

**Audit access attempts**:
```typescript
if (role !== "admin") {
  await logSecurityEvent({
    event: "unauthorized_admin_access_attempt",
    userId,
    resource: pathname,
    timestamp: new Date()
  });
  return new Response("Forbidden", { status: 403 });
}
```

## Agent Usage

### When Implementing Features

```markdown
Agent: "User needs to edit their profile"

Response: "First check if RBAC exists. If not, use:
.claude/skills/security/security-prompts/auth-authorization/01_rbac_implementation.md

Then for the profile endpoint, use:
.claude/skills/security/security-prompts/prompt-engineering/02_authenticated_endpoint.md

Add ownership verification with:
.claude/skills/security/security-prompts/auth-authorization/03_ownership.md"
```

### When Reviewing Security

```markdown
Agent: "Review authorization implementation"

Response: "Check against template:
.claude/skills/security/security-prompts/auth-authorization/04_auth_testing.md

Verify:
- All routes have role checks
- Server-side enforcement
- Default deny pattern
- Negative test cases exist"
```

## Common Pitfalls

### ❌ Client-Side Only Checks

**Problem**: Hiding UI elements without server enforcement
```typescript
// ❌ Bad
{role === "admin" && <DeleteButton />}
```

**Solution**: Always enforce server-side
```typescript
// ✅ Good
{role === "admin" && <DeleteButton />}

// On server
export async function DELETE(req: Request) {
  const role = auth().sessionClaims?.publicMetadata?.role;
  if (role !== "admin") return Response.json({error: "Forbidden"}, {status: 403});
}
```

### ❌ Trusting Client Claims

**Problem**: Reading role from request body
```typescript
// ❌ Bad
const { role } = await req.json();
if (role === "admin") { /* allow */ }
```

**Solution**: Read from server session
```typescript
// ✅ Good
const role = auth().sessionClaims?.publicMetadata?.role;
if (role === "admin") { /* allow */ }
```

### ❌ Missing Ownership Checks

**Problem**: Only checking authentication
```typescript
// ❌ Bad
export async function PATCH(req: Request, { params }: { params: { id: string } }) {
  const { userId } = auth();
  if (!userId) return Response.json({error: "Unauthorized"}, {status: 401});

  // Updates ANY post, even if user doesn't own it
  await db.posts.update(params.id, data);
}
```

**Solution**: Verify ownership
```typescript
// ✅ Good
export async function PATCH(req: Request, { params }: { params: { id: string } }) {
  const { userId } = auth();
  if (!userId) return Response.json({error: "Unauthorized"}, {status: 401});

  const post = await db.posts.get(params.id);
  if (post.authorId !== userId) {
    return Response.json({error: "Forbidden"}, {status: 403});
  }

  await db.posts.update(params.id, data);
}
```

## Testing Strategy

### Unit Tests

**Role checks**:
```typescript
describe("Role-based access", () => {
  test("admin can access admin routes", async () => {
    // Test with admin token
  });

  test("user cannot access admin routes", async () => {
    // Test with user token, expect 403
  });
});
```

### Integration Tests

**Full flow**:
```typescript
describe("Profile editing", () => {
  test("user can edit own profile", async () => {
    // Create user, edit profile, verify success
  });

  test("user cannot edit other user profile", async () => {
    // User A tries to edit User B, expect 403
  });
});
```

### E2E Tests

**Real scenarios**:
- Sign up → assigned user role → verify limited access
- Subscribe → role changes to premium → verify enhanced access
- Admin promotes user → verify role change → verify new access

## Related Skills

**Parent Skill**:
- **security-prompts** - Main directory with all template categories (engineering, threat-modeling, controls, auth)

**Implementation Skills** (referenced by templates):
- **auth-security** - Clerk authentication implementation
- **clerk** - Clerk integration patterns

**Note**: For other template categories (implementation, threat modeling, simple controls), see the parent `security-prompts` skill

## Version History

**v1.0** (2025-10-23): Initial skill creation
- Converted 4 auth/authorization templates
- Added Clerk integration guidance
- Added common pitfalls and best practices
- Integration patterns with other templates

---

**Note**: Authentication (who you are) is handled by Clerk. These templates focus on authorization (what you can do). Always implement both.
