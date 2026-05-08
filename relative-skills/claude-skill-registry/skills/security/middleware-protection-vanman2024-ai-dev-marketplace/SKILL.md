---
name: middleware-protection
description: Route protection and authorization patterns for Clerk middleware. Use when implementing route guards, protecting API routes, configuring middleware matchers, setting up role-based access control, creating auth boundaries, or when user mentions middleware, route protection, auth guards, protected routes, public routes, matcher patterns, or authorization middleware.
allowed-tools: Read, Write, Edit, Bash, Glob
---

# Middleware Protection

Comprehensive route protection and authorization patterns for Clerk middleware in Next.js applications. Provides middleware configuration, route matchers, role-based access control, and authentication boundaries.

## Core Concepts

### Middleware Architecture
- **Edge Runtime**: Clerk middleware runs on Cloudflare Workers/Vercel Edge
- **Request Interception**: Middleware executes before route handlers
- **Auth State**: Access to authentication state via `auth()` helper
- **Matcher Patterns**: Configure which routes middleware applies to

### Route Protection Levels
1. **Public Routes**: Accessible without authentication (sign-in, sign-up, landing pages)
2. **Protected Routes**: Require authentication (dashboards, user profiles)
3. **Organization Routes**: Require organization membership
4. **Role-Based Routes**: Require specific roles or permissions

### Security Principles
- **Deny by Default**: All routes protected unless explicitly made public
- **Defense in Depth**: Middleware + server component checks + API route guards
- **Session Validation**: Automatic token validation on every request
- **CSRF Protection**: Built-in protection against cross-site request forgery

## Instructions

### Basic Middleware Setup

1. **Create middleware.ts in project root**
   - Import `clerkMiddleware` from `@clerk/nextjs/server`
   - Export default middleware function
   - Configure matcher for routes to protect

2. **Configure Public Routes**
   - Define routes accessible without authentication
   - Use glob patterns for route matching
   - Include sign-in/sign-up pages as public

3. **Set Protected Routes**
   - Specify which routes require authentication
   - Use route groups for organization
   - Apply different protection levels

### Advanced Patterns

1. **Role-Based Access Control**
   - Check user roles in middleware
   - Redirect based on permissions
   - Implement organization-level permissions

2. **Conditional Route Protection**
   - Apply different rules based on route patterns
   - Check custom metadata
   - Implement feature flags

3. **API Route Protection**
   - Secure API endpoints with middleware
   - Validate session tokens
   - Check permissions before processing

4. **Multi-Tenant Protection**
   - Organization-scoped routes
   - Tenant isolation
   - Cross-organization access prevention

### Testing Protection

1. **Test Authentication Boundaries**
   - Verify unauthenticated redirects
   - Check protected route access
   - Validate role requirements

2. **Test Edge Cases**
   - Token expiration handling
   - Invalid session handling
   - Missing organization membership

## Templates

Use these templates for middleware implementation:

### Core Templates
- `templates/middleware.ts` - Basic middleware configuration
- `templates/route-matchers.ts` - Route matching patterns
- `templates/role-based-middleware.ts` - Role-based access control

### Configuration Templates
- `templates/public-routes-config.ts` - Public route definitions
- `templates/protected-routes-config.ts` - Protected route setup
- `templates/api-middleware-config.ts` - API route protection

### Advanced Templates
- `templates/organization-middleware.ts` - Organization-scoped protection
- `templates/conditional-middleware.ts` - Conditional route logic
- `templates/custom-redirects.ts` - Custom redirect handling

## Scripts

Use these scripts for middleware setup and testing:

- `scripts/generate-middleware.sh` - Generate middleware.ts with configuration
- `scripts/configure-routes.sh` - Setup route protection patterns
- `scripts/test-protection.sh` - Test authentication guards and boundaries
- `scripts/validate-middleware.sh` - Validate middleware configuration

## Examples

See complete examples in the `examples/` directory:

### Basic Examples
- `examples/basic-middleware.ts` - Simple middleware setup
- `examples/public-private-routes.ts` - Public vs protected routes
- `examples/api-middleware.ts` - API route protection

### Advanced Examples
- `examples/role-based-protection.ts` - Role-based access control
- `examples/organization-routes.ts` - Organization-scoped routes
- `examples/conditional-routing.ts` - Conditional protection logic
- `examples/custom-auth-flow.ts` - Custom authentication flows

### Testing Examples
- `examples/middleware-tests.ts` - Middleware unit tests
- `examples/integration-tests.ts` - Full protection integration tests

## Security Best Practices

### API Key Handling
**CRITICAL**: When generating middleware configuration:

- ❌ NEVER hardcode CLERK_SECRET_KEY or NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
- ❌ NEVER include real API keys in examples
- ✅ ALWAYS use placeholders: `your_clerk_secret_key_here`
- ✅ ALWAYS read from environment variables: `process.env.CLERK_SECRET_KEY`
- ✅ ALWAYS add `.env*` to `.gitignore` (except `.env.example`)
- ✅ ALWAYS document where to obtain keys from Clerk Dashboard

### Middleware Security
1. **Validate All Requests**: Don't skip middleware on any protected routes
2. **Check Session Validity**: Always validate session tokens
3. **Implement Rate Limiting**: Protect against brute force attacks
4. **Log Security Events**: Track authentication failures and suspicious activity
5. **Use HTTPS Only**: Never run authentication over HTTP in production

## Requirements

**Next.js Version:**
- Next.js 13.4+ (App Router support)
- Next.js 12+ (Pages Router support)

**Clerk SDK:**
- @clerk/nextjs 4.0+ (latest stable)
- Node.js 16+

**Configuration Files:**
- `.env.local` with Clerk environment variables
- `middleware.ts` in project root
- `.gitignore` protecting secrets

## Common Patterns

### Pattern 1: Public Landing + Protected Dashboard
```typescript
// Public: /, /about, /pricing
// Protected: /dashboard/*, /profile/*
// Matcher: Protect everything except public routes
```

### Pattern 2: API Route Protection
```typescript
// Protect all /api/* except /api/webhooks/clerk
// Validate session tokens on protected endpoints
// Return 401 for unauthenticated requests
```

### Pattern 3: Organization-Scoped Routes
```typescript
// Require organization membership for /org/*
// Check active organization in middleware
// Redirect to organization selection if needed
```

### Pattern 4: Role-Based Access
```typescript
// Check user roles in middleware
// Redirect based on permissions (admin vs user)
// Implement feature-specific access control
```

## Troubleshooting

### Common Issues

1. **Middleware Not Running**
   - Check matcher configuration
   - Verify middleware.ts location (project root)
   - Ensure Next.js version supports middleware

2. **Infinite Redirect Loops**
   - Sign-in page must be public
   - Check redirect logic in middleware
   - Verify afterSignInUrl configuration

3. **Protected Routes Accessible**
   - Verify matcher includes routes
   - Check auth state validation
   - Ensure middleware executes before route

4. **Session Not Found**
   - Check environment variables loaded
   - Verify Clerk keys are correct
   - Ensure cookies not blocked

---

**Purpose**: Provide comprehensive middleware protection patterns for Clerk authentication
**Load when**: Implementing route guards, protecting routes, setting up middleware, configuring auth boundaries
