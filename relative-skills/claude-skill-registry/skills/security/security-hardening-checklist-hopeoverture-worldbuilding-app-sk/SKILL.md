---
name: security-hardening-checklist
description: This skill should be used when the user requests to audit, check, or improve application security by analyzing security headers, cookie configuration, RLS policies, input sanitization, rate limiting, and other security measures. It generates a comprehensive security audit report with actionable recommendations. Trigger terms include security audit, security check, harden security, security review, vulnerability check, security headers, secure cookies, input validation, rate limiting, security best practices.
allowed-tools: Read, Grep, Glob, Bash
---

# Security Hardening Checklist

To perform a comprehensive security audit and generate hardening recommendations, follow these steps systematically.

## Step 1: Project Discovery

Identify the project structure and tech stack:

1. Use Glob to find key files:
   - `package.json` - Dependencies and scripts
   - `next.config.*` - Next.js configuration
   - `middleware.ts` - Middleware setup
   - `app/**/*.{ts,tsx}` - Application routes
   - `.env.example` - Environment variables

2. Identify authentication provider (Supabase, NextAuth, Clerk, etc.)
3. Identify database type (PostgreSQL, MySQL, MongoDB, etc.)
4. Check for security libraries (helmet, rate-limit, etc.)

## Step 2: Security Headers Audit

Check for security headers configuration.

### Check Next.js Config

Use Grep to search for security headers in `next.config.js/ts`:
```
- "X-Frame-Options"
- "X-Content-Type-Options"
- "X-XSS-Protection"
- "Strict-Transport-Security"
- "Content-Security-Policy"
- "Referrer-Policy"
- "Permissions-Policy"
```

### Generate Missing Headers

Consult `references/security-headers.md` and create configuration:

```typescript
// next.config.ts
const securityHeaders = [
  {
    key: 'X-DNS-Prefetch-Control',
    value: 'on'
  },
  {
    key: 'Strict-Transport-Security',
    value: 'max-age=63072000; includeSubDomains; preload'
  },
  {
    key: 'X-Frame-Options',
    value: 'SAMEORIGIN'
  },
  {
    key: 'X-Content-Type-Options',
    value: 'nosniff'
  },
  {
    key: 'X-XSS-Protection',
    value: '1; mode=block'
  },
  {
    key: 'Referrer-Policy',
    value: 'strict-origin-when-cross-origin'
  },
  {
    key: 'Permissions-Policy',
    value: 'camera=(), microphone=(), geolocation=()'
  }
]

const nextConfig = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: securityHeaders,
      },
    ]
  },
}
```

## Step 3: Cookie Security Audit

Check cookie configuration for auth and session management.

### Check for Insecure Cookie Settings

Use Grep to search for cookie operations:
```
- "setCookie"
- "cookies().set"
- "document.cookie"
- "res.cookie"
```

### Review Cookie Security Attributes

Check for:
- `httpOnly: true` - Prevents JavaScript access
- `secure: true` - HTTPS only
- `sameSite: 'strict'` or `'lax'` - CSRF protection
- Proper expiration times

### Generate Secure Cookie Helper

```typescript
// lib/cookies.ts
import { cookies } from 'next/headers'

export function setSecureCookie(
  name: string,
  value: string,
  maxAge: number = 3600
) {
  cookies().set(name, value, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge,
    path: '/',
  })
}
```

## Step 4: RLS Policy Audit

For Supabase/PostgreSQL projects, audit Row-Level Security.

### Check RLS Status

Search for migration files or schema files:
```sql
-- Check if RLS is enabled
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
```

### Identify Tables Without RLS

Use Grep to find table definitions and check which lack RLS policies.

### Flag Security Gaps

- Tables with user data but no RLS
- Tables with RLS but no policies
- Policies that may be too permissive
- Missing WITH CHECK clauses

Consult `references/rls-checklist.md` for comprehensive checks.

## Step 5: Input Sanitization Audit

Check for unsafe input handling.

### Search for Direct Database Queries

Use Grep to find potential SQL injection risks:
```
- "`.query(`"
- "`${" (template literals in queries)
- "raw("
```

### Check Form Input Validation

Search for form handlers without validation:
```
- "formData.get("
- "request.json()"
- "params."
```

### Validate Zod Usage

Check if forms use Zod or similar validation:
```
- "z.object"
- "safeParse"
- "parse"
```

### Generate Validation Examples

```typescript
// lib/validations/common.ts
import { z } from 'zod'

// Sanitize HTML input
export const sanitizeHtml = (input: string): string => {
  return input
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;')
}

// Common validation schemas
export const emailSchema = z.string().email()
export const urlSchema = z.string().url()
export const uuidSchema = z.string().uuid()
export const slugSchema = z.string().regex(/^[a-z0-9-]+$/)
```

## Step 6: Rate Limiting Audit

Check for rate limiting on API routes and actions.

### Check for Rate Limiting Libraries

Search package.json for:
- `@upstash/ratelimit`
- `express-rate-limit`
- `rate-limiter-flexible`

### Identify Unprotected Endpoints

Use Glob to find all API routes:
```
app/api/**/route.ts
```

Search each for rate limiting code.

### Generate Rate Limiting Implementation

```typescript
// lib/rate-limit.ts
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

export const authRateLimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(5, '1 m'),
  prefix: 'ratelimit:auth',
})

export const apiRateLimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(100, '1 m'),
  prefix: 'ratelimit:api',
})

// Usage in API route
export async function POST(request: Request) {
  const ip = request.headers.get('x-forwarded-for') ?? 'unknown'
  const { success } = await authRateLimit.limit(ip)

  if (!success) {
    return new Response('Rate limit exceeded', { status: 429 })
  }

  // Handle request
}
```

## Step 7: Environment Variables Audit

Check for exposed secrets and proper env var handling.

### Check .env.example

Verify sensitive variables are not committed:
- Database URLs with credentials
- API keys
- JWT secrets

### Search for Hardcoded Secrets

Use Grep to find potential hardcoded secrets:
```
- "password.*=.*['\"]"
- "secret.*=.*['\"]"
- "api[-_]?key.*=.*['\"]"
- "token.*=.*['\"]"
```

### Check Client-Side Exposure

Search for env vars used in client components:
```
- "process.env" in files with "use client"
```

Only `NEXT_PUBLIC_*` vars should be in client code.

## Step 8: HTTPS and Transport Security

Verify HTTPS is enforced.

### Check for HTTP Links

Use Grep to find insecure URLs:
```
- "http://" (not in comments)
```

### Check Middleware for HTTPS Redirect

Look for HTTPS enforcement in middleware.

### Generate HTTPS Enforcement

```typescript
// middleware.ts
export function middleware(request: NextRequest) {
  // Enforce HTTPS in production
  if (
    process.env.NODE_ENV === 'production' &&
    request.headers.get('x-forwarded-proto') !== 'https'
  ) {
    return NextResponse.redirect(
      `https://${request.headers.get('host')}${request.nextUrl.pathname}`,
      301
    )
  }

  // Other middleware logic
}
```

## Step 9: CORS Configuration Audit

Check CORS configuration for API routes.

### Search for CORS Headers

Use Grep to find CORS configuration:
```
- "Access-Control-Allow-Origin"
- "cors("
```

### Verify CORS is Not Too Permissive

Flag `Access-Control-Allow-Origin: *` in production.

### Generate Proper CORS Configuration

```typescript
// lib/cors.ts
export function setCorsHeaders(
  response: NextResponse,
  allowedOrigins: string[]
) {
  const origin = request.headers.get('origin')

  if (origin && allowedOrigins.includes(origin)) {
    response.headers.set('Access-Control-Allow-Origin', origin)
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE')
    response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization')
    response.headers.set('Access-Control-Max-Age', '86400')
  }

  return response
}
```

## Step 10: Dependency Security Audit

Check for vulnerable dependencies.

### Run npm audit

```bash
npm audit --json
```

### Check for Outdated Packages

```bash
npm outdated
```

### Flag Critical Vulnerabilities

Identify packages with known security issues.

## Step 11: Generate Security Report

Create comprehensive security audit report using template from `assets/security-report-template.md`:

```markdown
# Security Audit Report

**Generated**: [timestamp]
**Project**: [project name]

## Executive Summary

**Overall Security Score**: X/100

- Critical Issues: X
- High Priority: X
- Medium Priority: X
- Low Priority: X

## Critical Issues (Fix Immediately)

### 1. Missing Security Headers
**Severity**: Critical
**Impact**: Application vulnerable to XSS, clickjacking
**Fix**: Add security headers to next.config.ts

### 2. No Rate Limiting on Auth Endpoints
**Severity**: Critical
**Impact**: Vulnerable to brute force attacks
**Fix**: Implement rate limiting

[Continue for all issues...]

## Recommendations

1. Security Headers
2. Cookie Security
3. RLS Policies
4. Input Validation
5. Rate Limiting
6. HTTPS Enforcement
7. Environment Variables
8. Dependency Updates

## Implementation Checklist

- [ ] Add security headers
- [ ] Configure secure cookies
- [ ] Enable RLS on all tables
- [ ] Add input validation
- [ ] Implement rate limiting
- [ ] Enforce HTTPS
- [ ] Audit environment variables
- [ ] Update vulnerable dependencies
```

## Step 12: Generate Fix Scripts

Create scripts to automate security improvements:

```typescript
// scripts/add-security-headers.ts
// Automatically adds security headers to next.config
```

```bash
# scripts/enable-rls.sql
# SQL script to enable RLS on all tables
```

## Consulting References

Throughout audit:
- Consult `references/security-headers.md` for header configuration
- Consult `references/rls-checklist.md` for database security
- Consult `references/owasp-top-10.md` for common vulnerabilities
- Use templates from `assets/security-report-template.md`

## Output Format

Generate files:
```
reports/
  security-audit-[timestamp].md
fixes/
  security-headers.ts
  rate-limiting.ts
  input-validation.ts
scripts/
  enable-rls.sql
  fix-cookies.ts
```

## Verification Checklist

Before completing audit:
- [ ] All routes analyzed
- [ ] Security headers reviewed
- [ ] Cookie configuration checked
- [ ] RLS policies audited
- [ ] Input validation verified
- [ ] Rate limiting assessed
- [ ] Environment variables checked
- [ ] Dependencies scanned
- [ ] HTTPS enforcement verified
- [ ] CORS configuration reviewed

## Completion

When finished:
1. Display security score
2. Highlight critical issues
3. Provide prioritized recommendations
4. Offer to implement fixes
5. Generate implementation scripts
