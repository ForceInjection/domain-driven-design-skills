---
name: auth-patterns
# prettier-ignore
description: Better-auth integration for authentication. Use when implementing login, registration, protected routes, or email verification.
---

# Auth Patterns

## Quick Pattern

```typescript
// Login form
export const login = form(schema, async ({ email, password }) => {
	const event = getRequestEvent();
	await auth.api.signInEmail({
		body: { email, password },
		headers: event.request.headers,
	});
	redirect(303, '/dashboard'); // Outside try/catch
});

// Protected query
export const get_data = guarded_query(() => {
	return { message: 'Protected data' };
});
```

## Core Principles

- Use `getRequestEvent()` for headers (cookie access)
- Redirect MUST be outside try/catch (throws error)
- Use `guarded_query/form/command` for protected endpoints
- Email verification required before login
- Commands cannot redirect - use client-side `goto()`

## Reference Files

- [auth-setup.md](references/auth-setup.md) - Complete better-auth
  configuration
- [auth-usage.md](references/auth-usage.md) - All auth patterns and
  examples
- [email-verification.md](references/email-verification.md) - Email
  verification flow
