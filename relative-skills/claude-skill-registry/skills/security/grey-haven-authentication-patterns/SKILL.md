---
name: grey-haven-authentication-patterns
description: Grey Haven's authentication patterns using better-auth - magic links, passkeys, OAuth providers, session management with Redis, JWT claims with tenant_id, and Doppler for auth secrets. Use when implementing authentication features.
# v2.0.43: Skills to auto-load for auth implementation
skills:
  - grey-haven-code-style
  - grey-haven-security-practices
  - grey-haven-api-design-standards
# v2.0.74: Tools for authentication implementation
allowed-tools:
  - Read
  - Write
  - MultiEdit
  - Bash
  - Grep
  - Glob
  - TodoWrite
---

# Grey Haven Authentication Patterns

Follow Grey Haven Studio's authentication patterns using better-auth for TanStack Start projects with multi-tenant support.

## Stack

- **better-auth**: Authentication library for TanStack Start
- **Drizzle ORM**: Database adapter for better-auth
- **Doppler**: Secret management (BETTER_AUTH_SECRET, OAuth keys)
- **Redis**: Session storage (via Upstash)
- **PostgreSQL**: User and session data with RLS

## Critical Requirements

### Multi-Tenant Authentication
**ALWAYS include tenant_id in auth tables**:
```typescript
export const users = pgTable("users", {
  id: uuid("id").primaryKey().defaultRandom(),
  tenant_id: uuid("tenant_id").notNull(), // CRITICAL!
  email_address: text("email_address").notNull().unique(),
  // ... other fields
});

export const sessions = pgTable("sessions", {
  id: uuid("id").primaryKey().defaultRandom(),
  user_id: uuid("user_id").references(() => users.id),
  tenant_id: uuid("tenant_id").notNull(), // CRITICAL!
  // ... other fields
});
```

### Doppler for Secrets
**NEVER commit auth secrets**:
```bash
# Doppler provides these at runtime
BETTER_AUTH_SECRET=<generated-secret>
BETTER_AUTH_URL=https://app.example.com
GOOGLE_CLIENT_ID=<from-google-console>
GOOGLE_CLIENT_SECRET=<from-google-console>
```

## Basic Configuration

```typescript
// lib/server/auth.ts
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "@better-auth/drizzle";
import { db } from "~/lib/server/db";

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: "pg",
    schema,
  }),
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true,
  },
  secret: process.env.BETTER_AUTH_SECRET!,
  baseURL: process.env.BETTER_AUTH_URL!,
  trustedOrigins: [process.env.BETTER_AUTH_URL!],
});
```

## Authentication Methods

### 1. Email & Password

```typescript
// Sign up with email verification
await auth.signUp.email({
  email: "user@example.com",
  password: "secure-password",
  name: "John Doe",
  data: {
    tenant_id: tenantId, // Include tenant context
  },
});

// Sign in
await auth.signIn.email({
  email: "user@example.com",
  password: "secure-password",
});
```

### 2. Magic Links

```typescript
// Send magic link
await auth.magicLink.send({
  email: "user@example.com",
  callbackURL: "/auth/verify",
});

// Verify magic link token
await auth.magicLink.verify({
  token: tokenFromEmail,
});
```

### 3. OAuth Providers

```typescript
// Google OAuth
export const auth = betterAuth({
  // ... other config
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
      scopes: ["email", "profile"],
    },
  },
});

// Redirect to Google
await auth.signIn.social({
  provider: "google",
  callbackURL: "/auth/callback",
});
```

### 4. Passkeys (WebAuthn)

```typescript
// Enable passkeys
export const auth = betterAuth({
  // ... other config
  passkey: {
    enabled: true,
  },
});

// Register passkey
await auth.passkey.register({
  name: "My MacBook",
});

// Authenticate with passkey
await auth.passkey.authenticate();
```

## Session Management

### JWT Claims with tenant_id

```typescript
// Middleware to extract tenant from JWT
export async function getTenantFromSession() {
  const session = await auth.api.getSession();
  
  if (!session) {
    throw new Error("Not authenticated");
  }

  return {
    userId: session.user.id,
    tenantId: session.user.tenant_id, // From JWT claims
    user: session.user,
  };
}
```

### Session Storage with Redis

```typescript
// Use Upstash Redis for sessions
export const auth = betterAuth({
  // ... other config
  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7 days
    updateAge: 60 * 60 * 24, // Refresh daily
    cookieCache: {
      enabled: true,
      maxAge: 5 * 60, // 5 minutes
    },
  },
});
```

## Protected Routes

### TanStack Router beforeLoad

```typescript
// routes/_authenticated/_layout.tsx
import { createFileRoute, redirect } from "@tanstack/react-router";
import { getTenantFromSession } from "~/lib/server/auth";

export const Route = createFileRoute("/_authenticated/_layout")({
  beforeLoad: async () => {
    try {
      const { userId, tenantId, user } = await getTenantFromSession();
      return { session: { userId, tenantId, user } };
    } catch {
      throw redirect({
        to: "/auth/login",
        search: { redirect: location.href },
      });
    }
  },
});
```

## Supporting Documentation

All supporting files are under 500 lines per Anthropic best practices:

- **[examples/](examples/)** - Complete auth examples
  - [magic-link.md](examples/magic-link.md) - Magic link implementation
  - [oauth.md](examples/oauth.md) - OAuth provider setup
  - [passkeys.md](examples/passkeys.md) - Passkey authentication
  - [multi-tenant.md](examples/multi-tenant.md) - Multi-tenant patterns
  - [INDEX.md](examples/INDEX.md) - Examples navigation

- **[reference/](reference/)** - Auth references
  - [better-auth-config.md](reference/better-auth-config.md) - Configuration options
  - [session-management.md](reference/session-management.md) - Session patterns
  - [doppler-setup.md](reference/doppler-setup.md) - Secret management
  - [INDEX.md](reference/INDEX.md) - Reference navigation

- **[templates/](templates/)** - Copy-paste ready templates
  - [auth-config.ts](templates/auth-config.ts) - better-auth configuration
  - [auth-schema.ts](templates/auth-schema.ts) - Drizzle auth schema
  - [protected-route.tsx](templates/protected-route.tsx) - Protected route layout

- **[checklists/](checklists/)** - Security checklists
  - [auth-checklist.md](checklists/auth-checklist.md) - Authentication security

## When to Apply This Skill

Use this skill when:
- Implementing user authentication
- Adding OAuth providers (Google, GitHub)
- Setting up magic link authentication
- Configuring passkey support
- Managing user sessions
- Implementing multi-tenant auth
- Securing API endpoints
- Setting up protected routes

## Template Reference

These patterns are from Grey Haven's production templates:
- **cvi-template**: TanStack Start + better-auth + multi-tenant

## Critical Reminders

1. **tenant_id**: Always include in users and sessions tables
2. **Doppler**: Use for all auth secrets (never commit!)
3. **Email verification**: Required for email/password signup
4. **JWT claims**: Include tenant_id in session data
5. **Protected routes**: Use beforeLoad for auth checks
6. **Redis sessions**: Use Upstash for distributed sessions
7. **OAuth secrets**: Store in Doppler (Google, GitHub, etc.)
8. **RLS policies**: Create for users and sessions tables
9. **Session expiry**: 7 days default, refresh daily
10. **Magic links**: 15-minute expiry, single-use tokens
