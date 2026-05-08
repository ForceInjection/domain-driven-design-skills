---
name: test-auth-wrapper
description: Expert knowledge on CLI testing with auth bypass, automated endpoint testing, and the 3 bypass methods (headers, environment, test headers). Use this skill when user asks about "test endpoint", "cli testing", "auth bypass", "curl", "automated testing", "local development", or "testing without clerk".
allowed-tools: Read, Bash, Grep
---

# Test Auth Wrapper Expert

You are an expert in testing API endpoints locally without full Clerk authentication. This skill provides knowledge about the 3 auth bypass methods and CLI testing patterns.

## When To Use This Skill

This skill activates when users:
- Need to test endpoints from CLI or scripts
- Want to bypass Clerk auth for local development
- Write automated tests for API routes
- Debug endpoints without browser session
- Run scripts that call internal APIs
- Perform integration testing

## Core Knowledge

### The 3 Auth Bypass Methods

**Bypass Resolution (from `/lib/auth/get-auth-or-test.ts`):**

1. **Test Headers** (Highest Priority)
2. **Dev Bypass Header**
3. **Environment Bypass**
4. **Clerk Auth** (Fallback)

### Method 1: Test Headers

**Use Case:** Automated tests, CI/CD

**Headers:**
- `x-test-user-id`: User ID to impersonate
- `x-test-email`: Email (optional)

**Example:**
```bash
curl http://localhost:3000/api/campaigns \
  -H "x-test-user-id: user_2abc123xyz" \
  -H "x-test-email: test@example.com"
```

**Implementation:**
```typescript
// In /lib/auth/get-auth-or-test.ts
const payload = verifyTestAuthHeaders(headerStore);
if (payload?.userId) {
  return {
    userId: payload.userId,
    sessionId: `test_${payload.userId}`,
    sessionClaims: payload.email ? { email: payload.email } : undefined,
  };
}
```

**Advantages:**
- Works in any environment
- Per-request control
- No config files needed
- Easy to test different users

**Disadvantages:**
- Must add headers to every request

### Method 2: Dev Bypass Header

**Use Case:** Manual CLI testing, Postman

**Headers:**
- `x-dev-auth: dev-bypass` (token must match `AUTH_BYPASS_TOKEN`)
- `x-dev-user-id`: User ID (optional, falls back to `AUTH_BYPASS_USER_ID`)
- `x-dev-email`: Email (optional, falls back to `AUTH_BYPASS_EMAIL`)

**Environment Variables:**
```bash
# .env.local
AUTH_BYPASS_TOKEN=dev-bypass  # Default if not set
AUTH_BYPASS_HEADER=x-dev-auth  # Default if not set
AUTH_BYPASS_USER_ID=user_2abc123xyz  # Fallback user
AUTH_BYPASS_EMAIL=dev@example.com  # Fallback email
```

**Example:**
```bash
curl http://localhost:3000/api/campaigns \
  -H "x-dev-auth: dev-bypass"
# Uses AUTH_BYPASS_USER_ID from .env.local

curl http://localhost:3000/api/campaigns \
  -H "x-dev-auth: dev-bypass" \
  -H "x-dev-user-id: user_different123"
# Overrides with specific user
```

**Implementation:**
```typescript
const defaultBypassToken = process.env.AUTH_BYPASS_TOKEN || 'dev-bypass';
const bypassHeaderName = process.env.AUTH_BYPASS_HEADER?.toLowerCase() || 'x-dev-auth';

if (
  process.env.NODE_ENV !== 'production' &&
  headerStore.get(bypassHeaderName) === defaultBypassToken
) {
  const userIdFromHeader = headerStore.get('x-dev-user-id') || process.env.AUTH_BYPASS_USER_ID;
  return {
    userId: userIdFromHeader,
    sessionId: 'bypass',
    sessionClaims: { /* ... */ }
  };
}
```

**Advantages:**
- Configurable token for security
- Default user from .env
- Easy to change user per-request
- Good for Postman collections

**Disadvantages:**
- Requires .env setup
- Only works in non-production

### Method 3: Environment Bypass

**Use Case:** Long dev sessions, scripts

**Environment Variables:**
```bash
# .env.local
ENABLE_AUTH_BYPASS=true
AUTH_BYPASS_USER_ID=user_2abc123xyz
AUTH_BYPASS_EMAIL=dev@example.com  # Optional
```

**Example:**
```bash
# No headers needed!
curl http://localhost:3000/api/campaigns

curl -X POST http://localhost:3000/api/campaigns \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","searchType":"instagram-reels"}'
```

**Implementation:**
```typescript
const bypassEnabled = process.env.ENABLE_AUTH_BYPASS === 'true';
const bypassUserId = process.env.AUTH_BYPASS_USER_ID;

if (bypassEnabled && bypassUserId && process.env.NODE_ENV !== 'production') {
  return {
    userId: bypassUserId,
    sessionId: 'bypass',
    sessionClaims: { /* ... */ }
  };
}
```

**Advantages:**
- No headers needed
- Fastest for dev
- Works for all requests automatically

**Disadvantages:**
- Can't test different users without restart
- Easy to forget it's enabled
- Must disable for Clerk testing

## Common Patterns

### Pattern 1: Testing Endpoint with curl

```bash
# Quick test with dev bypass
curl http://localhost:3000/api/billing/status \
  -H "x-dev-auth: dev-bypass"

# Test specific user
curl http://localhost:3000/api/billing/status \
  -H "x-test-user-id: user_2abc123xyz"

# POST with JSON body
curl -X POST http://localhost:3000/api/campaigns \
  -H "x-dev-auth: dev-bypass" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Campaign","searchType":"instagram-reels","keywords":["fitness"]}'

# DELETE endpoint
curl -X DELETE http://localhost:3000/api/campaigns/xxx-xxx-xxx \
  -H "x-dev-auth: dev-bypass"
```

### Pattern 2: Node Script Testing

```javascript
// scripts/test-endpoint.js
require('dotenv').config({ path: '.env.local' });

async function testEndpoint() {
  const response = await fetch('http://localhost:3000/api/campaigns', {
    headers: {
      'x-dev-auth': 'dev-bypass',
      'x-dev-user-id': 'user_2abc123xyz'
    }
  });

  const data = await response.json();
  console.log('Response:', data);
}

testEndpoint();
```

Run: `node scripts/test-endpoint.js`

### Pattern 3: Automated Test Suite

```typescript
// tests/api/campaigns.test.ts
import { describe, it, expect } from 'vitest';

const BASE_URL = 'http://localhost:3000';
const TEST_USER_ID = 'user_test123';

describe('Campaigns API', () => {
  it('should create campaign', async () => {
    const response = await fetch(`${BASE_URL}/api/campaigns`, {
      method: 'POST',
      headers: {
        'x-test-user-id': TEST_USER_ID,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        name: 'Test Campaign',
        searchType: 'instagram-reels',
        keywords: ['fitness']
      })
    });

    expect(response.status).toBe(201);
    const data = await response.json();
    expect(data.success).toBe(true);
    expect(data.data.name).toBe('Test Campaign');
  });

  it('should enforce plan limits', async () => {
    // Create user with limit of 3 campaigns
    // ... create 3 campaigns ...

    // 4th should fail
    const response = await fetch(`${BASE_URL}/api/campaigns`, {
      method: 'POST',
      headers: {
        'x-test-user-id': TEST_USER_ID,
        'x-plan-bypass': 'none', // Don't bypass plan limits
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        name: 'Campaign 4',
        searchType: 'instagram-reels'
      })
    });

    expect(response.status).toBe(403);
    const data = await response.json();
    expect(data.error).toContain('limit');
  });
});
```

### Pattern 4: Plan Bypass (Testing Without Limits)

```bash
# Bypass campaign limits
curl -X POST http://localhost:3000/api/campaigns \
  -H "x-dev-auth: dev-bypass" \
  -H "x-plan-bypass: campaigns" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","searchType":"instagram-reels"}'

# Bypass all limits
curl -X POST http://localhost:3000/api/campaigns \
  -H "x-dev-auth: dev-bypass" \
  -H "x-plan-bypass: all"

# Via environment (for scripts)
# .env.local
PLAN_VALIDATION_BYPASS=all  # or "campaigns,creators"
```

## Anti-Patterns (Avoid These)

### Anti-Pattern 1: Hardcoding User IDs in Code

```typescript
// BAD: Hardcoded test user
export async function POST(req: Request) {
  const userId = 'user_2abc123xyz'; // WRONG!
  // ...
}
```

**Why it's bad**: Breaks production, not flexible

**Do this instead:**
```typescript
// GOOD: Use auth resolver
const auth = await getAuthOrTest();
if (!auth?.userId) {
  return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
}
```

### Anti-Pattern 2: Leaving Bypass Enabled in Production

```typescript
// BAD: No environment check
if (process.env.ENABLE_AUTH_BYPASS === 'true') {
  return { userId: process.env.AUTH_BYPASS_USER_ID };
}
```

**Why it's bad**: Massive security hole in production

**Do this instead:**
```typescript
// GOOD: Environment check
if (
  process.env.ENABLE_AUTH_BYPASS === 'true' &&
  process.env.NODE_ENV !== 'production'
) {
  return { userId: process.env.AUTH_BYPASS_USER_ID };
}
```

### Anti-Pattern 3: Using Bypass for Real User Actions

```bash
# BAD: Using bypass to modify production data
curl https://production.com/api/campaigns/delete-all \
  -H "x-dev-auth: dev-bypass"
# This should NEVER work in production!
```

**Why it's bad**: Bypasses should only work locally

## Troubleshooting Guide

### Problem: Auth Bypass Not Working

**Symptoms:**
- Endpoint returns 401 Unauthorized
- Headers seem correct
- Environment variables set

**Diagnosis:**
1. Check if in production (bypass disabled)
2. Verify header names match exactly
3. Check token matches `AUTH_BYPASS_TOKEN`
4. Look for typos in environment variables

**Solution:**
```bash
# 1. Verify environment
echo $NODE_ENV  # Should be "development" or empty

# 2. Check .env.local
cat .env.local | grep AUTH_BYPASS

# 3. Test with exact headers
curl http://localhost:3000/api/debug/whoami \
  -H "x-dev-auth: dev-bypass" \
  -H "x-dev-user-id: user_2abc123xyz" \
  -v  # Verbose mode to see headers

# 4. Restart dev server (to reload .env.local)
```

### Problem: Can't Test Different Users

**Symptoms:**
- Stuck with same user for all requests
- Want to test multi-user scenarios

**Solution:**
Use test headers (Method 1) instead of environment bypass:

```bash
# User 1
curl http://localhost:3000/api/campaigns \
  -H "x-test-user-id: user_1"

# User 2
curl http://localhost:3000/api/campaigns \
  -H "x-test-user-id: user_2"
```

## Related Files

- `/lib/auth/get-auth-or-test.ts` - Auth resolver with bypass logic
- `/lib/auth/testable-auth.ts` - Test header verification
- `/app/api/debug/whoami/route.ts` - Debug endpoint for testing auth
- `/app/api/test/auth-echo/route.ts` - Echo auth context

## Quick Reference

**Headers:**
```bash
# Test headers (highest priority)
x-test-user-id: user_xxx
x-test-email: test@example.com

# Dev bypass headers
x-dev-auth: dev-bypass
x-dev-user-id: user_xxx  # Optional override
x-dev-email: dev@example.com  # Optional

# Plan bypass (for testing without limits)
x-plan-bypass: all  # or "campaigns" or "creators"
```

**Environment:**
```bash
# Auth bypass
ENABLE_AUTH_BYPASS=true
AUTH_BYPASS_USER_ID=user_xxx
AUTH_BYPASS_EMAIL=dev@example.com
AUTH_BYPASS_TOKEN=dev-bypass
AUTH_BYPASS_HEADER=x-dev-auth

# Plan bypass
PLAN_VALIDATION_BYPASS=all  # or "campaigns,creators"
```

**Testing Commands:**
```bash
# Simple GET
curl http://localhost:3000/api/endpoint \
  -H "x-dev-auth: dev-bypass"

# POST with JSON
curl -X POST http://localhost:3000/api/endpoint \
  -H "x-dev-auth: dev-bypass" \
  -H "Content-Type: application/json" \
  -d '{"key":"value"}'

# Different user
curl http://localhost:3000/api/endpoint \
  -H "x-test-user-id: user_different"

# With plan bypass
curl http://localhost:3000/api/endpoint \
  -H "x-dev-auth: dev-bypass" \
  -H "x-plan-bypass: all"
```
