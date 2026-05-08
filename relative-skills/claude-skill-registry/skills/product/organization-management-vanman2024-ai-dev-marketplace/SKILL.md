---
name: organization-management
description: Implement Clerk multi-tenant organization features with RBAC, role-based access control, organization switching, member management, and tenant isolation. Use when building multi-tenant SaaS applications, implementing organization hierarchies, configuring custom roles and permissions, setting up organization-scoped data isolation, or when user mentions organizations, RBAC, multi-tenancy, roles, permissions, organization switcher, member management, or tenant isolation.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Organization Management

**Purpose:** Autonomously implement and configure Clerk organization features for multi-tenant applications with RBAC.

**Activation Triggers:**
- Multi-tenant application requirements
- Organization creation/management needs
- Role-based access control (RBAC) implementation
- Organization switcher/profile components
- Member invitation and management
- Organization-scoped data isolation
- Custom role and permission setup
- Tenant-specific features

**Key Resources:**
- `scripts/setup-organizations.sh` - Enable and configure organizations
- `scripts/configure-roles.sh` - Setup RBAC with custom roles
- `scripts/test-org-isolation.sh` - Test tenant data isolation
- `templates/organization-schema.md` - Multi-tenant database schema patterns
- `templates/rbac-policies.ts` - Role and permission definitions
- `templates/organization-switcher.tsx` - Organization switcher component
- `examples/multi-tenant-app.tsx` - Complete multi-tenant application
- `examples/org-admin-dashboard.tsx` - Organization admin interface

## Implementation Workflow

### 1. Enable Organizations in Clerk Dashboard

Before implementing organization features, enable them in your Clerk Dashboard:

```bash
# Run setup script to guide through Clerk Dashboard configuration
./scripts/setup-organizations.sh
```

**Manual steps (documented in script):**
1. Go to Clerk Dashboard → Organization Settings
2. Enable "Organizations" feature
3. Configure organization creation settings
4. Set up default roles (admin, member)
5. Configure organization metadata fields (if needed)

### 2. Configure RBAC (Role-Based Access Control)

```bash
# Setup custom roles and permissions
./scripts/configure-roles.sh [basic|advanced|custom]

# Examples:
./scripts/configure-roles.sh basic       # Admin + Member only
./scripts/configure-roles.sh advanced    # Admin + Manager + Member + Viewer
./scripts/configure-roles.sh custom      # Interactive custom role creation
```

**Outputs:**
- RBAC policy TypeScript file with role definitions
- Permission checking middleware
- Role-based route protection examples
- Clerk Dashboard configuration guide

### 3. Implement Organization Components

Use templates to create organization UI:

**Organization Switcher (for multi-org users):**
```bash
# Copy and customize organization switcher
cp templates/organization-switcher.tsx src/components/OrganizationSwitcher.tsx
```

**Organization Schema (for database integration):**
```bash
# View multi-tenant database schema patterns
cat templates/organization-schema.md
```

**RBAC Policies:**
```bash
# Copy RBAC policy definitions
cp templates/rbac-policies.ts src/lib/rbac.ts
```

### 4. Test Organization Isolation

```bash
# Test tenant data isolation (requires project running)
./scripts/test-org-isolation.sh

# Validates:
# - Data scoped to organization_id
# - Cross-tenant data leakage prevention
# - Role-based access enforcement
# - Organization switching works correctly
```

## Organization Architecture Patterns

### Multi-Tenant Data Isolation

**Row-Level Security (RLS) Pattern:**
```sql
-- Every table includes organization_id
CREATE TABLE projects (
  id UUID PRIMARY KEY,
  organization_id TEXT NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- RLS Policy (Supabase/Postgres)
CREATE POLICY "Users can only access their org's projects"
ON projects FOR ALL
USING (organization_id = current_setting('app.current_organization_id'));
```

**Application-Level Scoping:**
```typescript
// Always filter by organization_id in queries
const projects = await db.projects.findMany({
  where: {
    organizationId: user.organizationId
  }
});
```

### RBAC Implementation Levels

**Level 1: Basic (Admin/Member)**
- Admin: Full organization control
- Member: Limited access to org resources

**Level 2: Advanced (4+ roles)**
- Admin: Full control
- Manager: Team management, no billing
- Member: Regular access
- Viewer: Read-only access

**Level 3: Custom (Granular permissions)**
- Define specific permissions: `project:create`, `billing:manage`, `members:invite`
- Assign permissions to roles
- Check permissions at route/component level

## Component Examples

### Organization Switcher Component

See `templates/organization-switcher.tsx` for complete component with:
- Organization selection dropdown
- Create new organization option
- Organization settings link
- Active organization indicator
- Keyboard navigation support

### Organization Admin Dashboard

See `examples/org-admin-dashboard.tsx` for:
- Member list with role management
- Pending invitations display
- Role assignment interface
- Organization settings
- Billing integration (if using Clerk Billing)

### Multi-Tenant Application Structure

See `examples/multi-tenant-app.tsx` for:
- Organization context provider
- Organization-scoped routing
- Data isolation patterns
- Permission-based UI rendering
- Organization switching flow

## Common Use Cases

### Use Case 1: SaaS Application with Teams
```bash
# Enable organizations + advanced RBAC
./scripts/setup-organizations.sh
./scripts/configure-roles.sh advanced

# Implement organization switcher
cp templates/organization-switcher.tsx src/components/
```

### Use Case 2: Enterprise Multi-Tenant Platform
```bash
# Enable organizations + custom RBAC with granular permissions
./scripts/setup-organizations.sh
./scripts/configure-roles.sh custom

# Setup database isolation
# Follow templates/organization-schema.md for RLS setup
```

### Use Case 3: Organization-Scoped Data Isolation
```bash
# Test isolation after implementing schema
./scripts/test-org-isolation.sh

# Validates:
# - No cross-tenant data access
# - RLS policies working correctly
# - Organization switching updates context
```

## RBAC Permission Checking

**Middleware Protection:**
```typescript
// Check role in middleware
import { auth } from '@clerk/nextjs/server';

export default async function middleware(req: Request) {
  const { orgRole } = await auth();

  if (orgRole !== 'org:admin') {
    return new Response('Forbidden', { status: 403 });
  }
}
```

**Component-Level Checks:**
```typescript
// Hide UI based on role
import { useOrganization } from '@clerk/nextjs';

function AdminOnlyButton() {
  const { membership } = useOrganization();

  if (membership?.role !== 'org:admin') return null;

  return <button>Admin Action</button>;
}
```

**Custom Permission Checks:**
```typescript
// Check specific permission
import { checkPermission } from '@/lib/rbac';

if (await checkPermission(user, 'billing:manage')) {
  // Allow billing access
}
```

## Database Integration

### Supabase Integration (with RLS)

1. **Add organization_id to all tables**
2. **Enable RLS on tables**
3. **Create RLS policies scoped to organization_id**
4. **Set organization context in Supabase client**

See `templates/organization-schema.md` for complete schema patterns.

### Prisma Integration

```typescript
// Organization-scoped queries
const projects = await prisma.project.findMany({
  where: {
    organizationId: user.organizationId
  }
});

// Middleware to auto-inject organization_id
prisma.$use(async (params, next) => {
  if (params.action === 'create') {
    params.args.data.organizationId = getCurrentOrgId();
  }
  return next(params);
});
```

## Environment Variables

```bash
# .env.example (no real keys!)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_your_clerk_key_here
CLERK_SECRET_KEY=sk_test_your_clerk_secret_here

# Organization feature flags (optional)
NEXT_PUBLIC_ENABLE_ORG_CREATION=true
NEXT_PUBLIC_MAX_ORGS_PER_USER=5
```

## Troubleshooting

**Organizations not appearing:**
- Verify organizations enabled in Clerk Dashboard
- Check environment variables are set correctly
- Ensure user has created/joined an organization

**RBAC not working:**
- Verify custom roles defined in Clerk Dashboard
- Check role assignment in organization settings
- Confirm middleware/permission checks use correct role names

**Data isolation failing:**
- Verify all tables include organization_id column
- Check RLS policies are enabled and correct
- Test with multiple organizations to confirm isolation

## Resources

**Scripts:** All scripts in `scripts/` directory are executable and include detailed usage instructions

**Templates:** `templates/` contains production-ready components and schema patterns

**Examples:** `examples/` contains complete application examples with organization features

---

**Clerk Dashboard Configuration Required:** Organizations must be enabled in your Clerk Dashboard before using this skill

**Framework Support:** Next.js (App Router & Pages Router), React, Remix, Gatsby

**Version:** 1.0.0
**Clerk SDK Compatibility:** @clerk/nextjs 5+, @clerk/clerk-react 5+
