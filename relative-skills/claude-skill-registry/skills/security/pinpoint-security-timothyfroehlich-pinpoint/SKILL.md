---
name: pinpoint-security
description: Security patterns, CSP nonces, input validation, auth checks, Supabase SSR patterns. Use when implementing authentication, forms, security features, or when user mentions security/validation/auth.
---

# PinPoint Security Guide

## When to Use This Skill

Use this skill when:
- Implementing authentication or authorization
- Creating forms or handling user input
- Setting up security headers (CSP, CORS, etc.)
- Working with Supabase SSR authentication
- User mentions: "security", "auth", "validation", "XSS", "CSRF", "input", "forms"

## Quick Reference

### Critical Security Rules
1. **CSP with nonces**: Dynamic nonces via middleware, static headers via next.config.ts
2. **Validate ALL inputs**: Use Zod for all form data and user inputs
3. **Supabase SSR contract**: Use `~/lib/supabase/server`, call `auth.getUser()` immediately
4. **Host consistency**: Use `localhost` for all auth callbacks, dev server, Playwright, Supabase site_url
5. **No logic between** `createClient()` and `getUser()`

### Common Patterns

**Server Action with Auth**:
```typescript
"use server";
import { createClient } from "~/lib/supabase/server";
import { redirect } from "next/navigation";

export async function protectedAction(formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser(); // Call immediately!
  if (!user) redirect("/login");

  // Validate inputs
  const schema = z.object({
    title: z.string().min(1),
    description: z.string().optional(),
  });
  const validated = schema.parse({
    title: formData.get("title"),
    description: formData.get("description"),
  });

  // Proceed with validated data
}
```

**Form Validation**:
```typescript
import { z } from "zod";

const createIssueSchema = z.object({
  title: z.string().min(1, "Title required"),
  description: z.string().optional(),
  machineId: z.string().uuid("Invalid machine ID"),
  severity: z.enum(["minor", "playable", "unplayable"]),
});

export async function createIssue(formData: FormData) {
  const rawData = {
    title: formData.get("title"),
    description: formData.get("description"),
    machineId: formData.get("machineId"),
    severity: formData.get("severity"),
  };

  const validData = createIssueSchema.parse(rawData);
  // Use validData safely
}
```

## Detailed Documentation

For comprehensive security guidance, read the following documentation files:

```bash
# Security patterns and CSP configuration
cat docs/SECURITY.md

# Security-related non-negotiables
cat docs/NON_NEGOTIABLES.md | grep -A 20 "## Security"
```

### Key Security Constraints (from NON_NEGOTIABLES.md)

**CORE-SEC-001**: Protect APIs and Server Actions
- Verify authentication in all Server Actions
- Check authorization before data access
- Never skip auth checks in protected routes

**CORE-SEC-002**: Validate all inputs
- Use Zod for all form data and user inputs
- Never trust FormData or query params without validation
- Prevent injection attacks (SQL, XSS, command injection)

**CORE-SEC-003**: Security headers via middleware
- CSP with nonces (prevents XSS)
- Set headers in `middleware.ts` (dynamic) and `next.config.ts` (static)
- Don't remove or weaken Content-Security-Policy

**CORE-SEC-004**: Nonce-based CSP
- Generate unique nonce per request using Web Crypto API
- Use 'strict-dynamic' to allow Next.js dynamic imports
- Never use 'unsafe-inline' or 'unsafe-eval' in script-src

**CORE-SEC-005**: No hardcoded hostnames or ports
- Use `NEXT_PUBLIC_SITE_URL` and `PORT` environment variables
- Prevents environment mismatches and "whack-a-mole" bugs

**CORE-SSR-001**: Use SSR wrapper and cookie contract
- Use `~/lib/supabase/server`'s `createClient()` with proper cookies
- Don't import from `@supabase/supabase-js` directly on server

**CORE-SSR-002**: Call `auth.getUser()` immediately
- Workaround for timing issues
- Avoids token invalidation
- No logic between `createClient()` and `getUser()`

**CORE-SSR-003**: Middleware is required
- Enables token refresh and SSR session continuity
- Don't remove or bypass middleware

**CORE-SSR-006**: Database trigger for auto-profile creation
- OAuth-proof (works for Google/GitHub login)
- Atomic transaction via `handle_new_user()` trigger
- Don't create profiles manually in signup Server Actions

## Code Examples

### CSP with Nonces (Middleware)

See `src/middleware.ts` for implementation:
- Generates unique nonce per request
- Uses Web Crypto API (Edge Runtime compatible)
- Sets CSP header with nonce for scripts
- Passes nonce to Next.js pages via headers

### Auth Protection Pattern

```typescript
// Server Component
export default async function ProtectedPage() {
  const supabase = await createClient();
  const { data: { user }, error } = await supabase.auth.getUser();

  if (error || !user) {
    redirect("/login");
  }

  return <DashboardContent user={user} />;
}

// Server Action
"use server";
export async function updateSetting(formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  // Validate and process
}
```

### Input Sanitization

```typescript
import sanitizeHtml from "sanitize-html";

export async function createComment(formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const rawContent = formData.get("content");
  if (typeof rawContent !== "string") {
    throw new Error("Invalid content");
  }

  // Sanitize HTML to prevent XSS
  const sanitizedContent = sanitizeHtml(rawContent, {
    allowedTags: ["b", "i", "em", "strong", "a", "p"],
    allowedAttributes: {
      a: ["href"],
    },
  });

  await db.insert(comments).values({
    userId: user.id,
    content: sanitizedContent,
  });
}
```

## Security Checklist

Before deploying or merging security-related code:

- [ ] All Server Actions have auth checks (`auth.getUser()` called immediately)
- [ ] All form inputs validated with Zod
- [ ] No hardcoded `localhost:3000` or specific ports (use env vars)
- [ ] CSP nonces generated in middleware
- [ ] No 'unsafe-inline' or 'unsafe-eval' in CSP
- [ ] Supabase SSR wrapper used (`~/lib/supabase/server`)
- [ ] No logic between `createClient()` and `getUser()`
- [ ] User-generated content sanitized before rendering
- [ ] OAuth callback route present at `app/auth/callback/route.ts`
- [ ] Database trigger `handle_new_user()` exists for profile creation

## Testing Security

### Auth Protection Tests

```typescript
// Test unauthorized access
it("redirects unauthenticated users", async () => {
  // Mock unauthenticated session
  const result = await protectedAction(formData);
  expect(result).toRedirect("/login");
});

// Test authorized access
it("allows authenticated users", async () => {
  // Mock authenticated session
  const result = await protectedAction(formData);
  expect(result).toSucceed();
});
```

### Input Validation Tests

```typescript
it("rejects invalid input", () => {
  const invalidData = { title: "" }; // Empty title
  expect(() => createIssueSchema.parse(invalidData)).toThrow();
});

it("accepts valid input", () => {
  const validData = {
    title: "Broken flipper",
    machineId: "uuid-here",
    severity: "playable",
  };
  expect(() => createIssueSchema.parse(validData)).not.toThrow();
});
```

## Common Security Mistakes to Avoid

1. **Skipping auth checks**: Every Server Action needs auth verification
2. **Trusting user input**: Always validate with Zod
3. **Modifying Supabase response**: Return response object as-is from middleware
4. **Wrong Supabase import**: Use `~/lib/supabase/server`, not direct imports
5. **Logic before getUser()**: Call `auth.getUser()` immediately after `createClient()`
6. **Hardcoded URLs**: Use environment variables for hosts/ports
7. **Weakening CSP**: Don't add 'unsafe-inline' or remove nonce requirements
8. **Manual profile creation**: Use database trigger, not signup Server Actions (OAuth won't work)

## Additional Resources

- Security documentation: `docs/SECURITY.md`
- Non-negotiables: `docs/NON_NEGOTIABLES.md` (CORE-SEC-* and CORE-SSR-* rules)
- Supabase SSR guide: Use Context7 MCP for latest patterns
