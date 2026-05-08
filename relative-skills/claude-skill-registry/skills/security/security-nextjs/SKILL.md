---
name: security-nextjs
description: |-
  Review Next.js security audit patterns for App Router and Server Actions. Use for auditing NEXT_PUBLIC_* exposure, Server Action auth, and middleware matchers. Use proactively when reviewing Next.js apps.
  Examples:
  - user: "Scan Next.js env vars" → find leaked secrets with NEXT_PUBLIC_ prefix
  - user: "Audit Server Actions" → check for missing auth and input validation
  - user: "Review Next.js middleware" → verify matcher coverage for protected routes
  - user: "Check Next.js API routes" → verify auth in app/api and pages/api
  - user: "Secure Next.js headers" → audit next.config.js for security headers
---

<overview>

Security audit patterns for Next.js applications covering environment variable exposure, Server Actions, middleware auth, API routes, and App Router security.

</overview>

<rules>

## Environment Variable Exposure

### The NEXT_PUBLIC_ Footgun
```
NEXT_PUBLIC_* → Bundled into client JavaScript → Visible to everyone
No prefix     → Server-only → Safe for secrets
```

**Audit steps:**
1. `grep -r "NEXT_PUBLIC_" . -g "*.env*"`
2. For each var, ask: "Would I be OK if this was in view-source?"
3. Common mistakes:
   - `NEXT_PUBLIC_API_KEY` (SHOULD be server-only)
   - `NEXT_PUBLIC_DATABASE_URL` (MUST NOT use)
   - `NEXT_PUBLIC_STRIPE_SECRET_KEY` (use `STRIPE_SECRET_KEY`)

**Safe pattern:**
```typescript
// Server-only (API route, Server Component, Server Action)
const apiKey = process.env.API_KEY; // ✓ No NEXT_PUBLIC_

// Client-safe (truly public)
const publishableKey = process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY; // ✓ Publishable
```

### next.config.js `env` Is Always Bundled

Values set in `next.config.js` under `env` are inlined into the client bundle, even without `NEXT_PUBLIC_`. Treat them as public.

```javascript
// ❌ Sensitive values here are exposed to the browser
module.exports = {
  env: {
    DATABASE_URL: process.env.DATABASE_URL,
  },
};
```

</rules>

<vulnerabilities>

## Server Actions Security

### Missing Auth (Most Common Issue)
```typescript
// ❌ VULNERABLE: No auth check
"use server"
export async function deleteUser(userId: string) {
  await db.user.delete({ where: { id: userId } });
}

// ✓ SECURE: Auth + authorization
"use server"
export async function deleteUser(userId: string) {
  const session = await getServerSession();
  if (!session) throw new Error("Unauthorized");
  if (session.user.id !== userId && !session.user.isAdmin) {
    throw new Error("Forbidden");
  }
  await db.user.delete({ where: { id: userId } });
}
```

### Input Validation
```typescript
// ❌ Trusts client input
"use server"
export async function updateProfile(data: any) {
  await db.user.update({ data });
}

// ✓ Validates with Zod
"use server"
import { z } from "zod";
const schema = z.object({ name: z.string().max(100), bio: z.string().max(500) });
export async function updateProfile(formData: FormData) {
  const data = schema.parse(Object.fromEntries(formData));
  await db.user.update({ data });
}
```

## API Routes Security

### App Router (app/api/*/route.ts)
```typescript
// ❌ No auth
export async function GET(request: Request) {
  return Response.json(await db.users.findMany());
}

// ✓ Auth middleware
import { getServerSession } from "next-auth";
export async function GET(request: Request) {
  const session = await getServerSession();
  if (!session) return new Response("Unauthorized", { status: 401 });
  // ...
}
```

### Pages Router (pages/api/*.ts)
```typescript
// Check for missing auth on all handlers
// Common issue: GET is public but POST has auth (inconsistent)
```

## Middleware Security

### Auth in middleware.ts
```typescript
// middleware.ts
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  const token = request.cookies.get("session");
  
  // ❌ Just checking existence
  if (!token) return NextResponse.redirect("/login");
  
  // ✓ SHOULD verify token
  // But middleware can't do async DB calls easily!
  // Solution: Use next-auth middleware or verify JWT
}

// CRITICAL: Check matcher covers all protected routes
export const config = {
  matcher: ["/dashboard/:path*", "/admin/:path*", "/api/admin/:path*"],
};
```

### Matcher Gaps
```typescript
// ❌ Forgot API routes
matcher: ["/dashboard/:path*"]
// Admin API at /api/admin/* is unprotected!

// ✓ Include API routes
matcher: ["/dashboard/:path*", "/api/admin/:path*"]
```

## Headers & Security Config

### next.config.js
```javascript
// Check for security headers
module.exports = {
  async headers() {
    return [
      {
        source: "/:path*",
        headers: [
          { key: "X-Frame-Options", value: "DENY" },
          { key: "X-Content-Type-Options", value: "nosniff" },
          { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
          // CSP is complex - check if present and not too permissive
        ],
      },
    ];
  },
};
```

</vulnerabilities>

<severity_table>

## Common Vulnerabilities

| Issue | Where to Look | Severity |
|-------|---------------|----------|
| NEXT_PUBLIC_ secrets | `.env*` files | CRITICAL |
| Unauth'd Server Actions | `app/**/actions.ts` | HIGH |
| Unauth'd API routes | `app/api/**/route.ts`, `pages/api/**` | HIGH |
| Middleware matcher gaps | `middleware.ts` | HIGH |
| Missing input validation | Server Actions, API routes | HIGH |
| IDOR in dynamic routes | `[id]` params without ownership check | HIGH |
| dangerouslySetInnerHTML | Components | MEDIUM |
| Missing security headers | `next.config.js` | LOW |

</severity_table>

<commands>

## Quick Grep Commands

```bash
# Find NEXT_PUBLIC_ usage
grep -r "NEXT_PUBLIC_" . -g "*.env*" -g "*.ts" -g "*.tsx"

# Find next.config env usage (always bundled)
rg -n 'env\s*:' next.config.*

# Find Server Actions without auth
rg -l '"use server"' . | xargs rg -L '(getServerSession|auth\(|getSession|currentUser)'

# Find API routes
fd 'route\.(ts|js)' app/api/

# Find dangerouslySetInnerHTML
rg 'dangerouslySetInnerHTML' . -g "*.tsx" -g "*.jsx"
```

</commands>
