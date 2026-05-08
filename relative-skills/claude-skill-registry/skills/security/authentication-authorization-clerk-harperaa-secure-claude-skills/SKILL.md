---
name: authentication-authorization-clerk
description: Implement secure authentication and authorization using Clerk. Use this skill when you need to authenticate users, protect routes, check permissions, implement subscription-based access control, or integrate Clerk with your application. Triggers include "authentication", "auth", "authorization", "Clerk", "protect route", "check user", "sign in", "session", "permissions", "subscription access".
---

# Authentication & Authorization with Clerk

## Why We Use Clerk

### The Authentication Problem

Building secure authentication from scratch requires:
- Password hashing (bcrypt/Argon2 with proper salts)
- Session management (secure cookies, expiration, renewal)
- Password reset flows (secure token generation, email verification)
- Account lockout (prevent brute force)
- MFA support (TOTP, SMS, authenticator apps)
- Social login (OAuth flows for Google, GitHub, etc.)
- User database sync
- Security best practices for all of the above

**Time to implement securely:** 2-4 weeks for experienced developers

**For vibe coders using AI:** High risk of security gaps

### Real-World Custom Auth Failures

**Ashley Madison Breach (2015):**
Custom authentication with weak password hashing. **32 million accounts** compromised.

**Dropbox Breach (2012):**
Custom authentication led to password hash database theft. **68 million accounts** affected.

According to Veracode's 2024 report, applications using managed authentication services (like Clerk, Auth0) had **73% fewer authentication-related vulnerabilities** than those with custom authentication.

## Our Clerk Architecture

### What Clerk Handles (So We Don't Have To)

- ✅ Password hashing (bcrypt/Argon2)
- ✅ Session management (secure cookies)
- ✅ MFA (built-in support)
- ✅ OAuth providers (Google, GitHub, etc.)
- ✅ Email verification
- ✅ Password reset flows
- ✅ Account lockout
- ✅ Security monitoring
- ✅ Compliance (SOC 2, GDPR)

**Clerk is SOC 2 certified:** This means an independent auditor verified their security controls meet industry standards. We inherit that certification.

## Implementation Files

- `middleware.ts` - Clerk authentication for protected routes
- `app/dashboard/*` - Protected by middleware
- Clerk manages its own session cookies

## Basic Authentication

### Server-Side Authentication (API Routes)

```typescript
import { auth } from '@clerk/nextjs/server';
import { handleUnauthorizedError } from '@/lib/errorHandler';

async function handler(request: NextRequest) {
  // Get current user
  const { userId } = await auth();

  if (!userId) {
    return handleUnauthorizedError('Authentication required');
  }

  // User is authenticated, proceed
  // Use userId to associate data with user
}
```

### Client-Side Authentication (Components)

```typescript
'use client';

import { useAuth, useUser } from '@clerk/nextjs';

export function ProfileComponent() {
  const { isLoaded, userId, sessionId } = useAuth();
  const { isLoaded: userLoaded, user } = useUser();

  if (!isLoaded || !userLoaded) {
    return <div>Loading...</div>;
  }

  if (!userId) {
    return <div>Please sign in</div>;
  }

  return (
    <div>
      <h1>Welcome, {user.firstName}!</h1>
      <p>Email: {user.primaryEmailAddress?.emailAddress}</p>
    </div>
  );
}
```

### Protecting Routes with Middleware

```typescript
// middleware.ts
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server';

const isProtectedRoute = createRouteMatcher([
  '/dashboard(.*)',
  '/api/protected(.*)',
]);

export default clerkMiddleware((auth, req) => {
  if (isProtectedRoute(req)) {
    auth().protect();
  }
});

export const config = {
  matcher: ['/((?!.*\\..*|_next).*)', '/', '/(api|trpc)(.*)'],
};
```

## Authorization Patterns

### Resource Ownership Verification

```typescript
// app/api/posts/[id]/route.ts
import { auth } from '@clerk/nextjs/server';
import { handleUnauthorizedError, handleForbiddenError } from '@/lib/errorHandler';

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const { userId } = await auth();
  if (!userId) {
    return handleUnauthorizedError();
  }

  // Get resource
  const post = await db.posts.findOne({ id: params.id });

  // Check ownership
  if (post.userId !== userId) {
    return handleForbiddenError('Only the post author can delete this post');
  }

  // User is authorized
  await db.posts.delete({ id: params.id });
  return NextResponse.json({ success: true });
}
```

### Role-Based Access Control (RBAC)

```typescript
import { auth } from '@clerk/nextjs/server';

export async function handler(request: NextRequest) {
  const { userId, sessionClaims } = await auth();

  if (!userId) {
    return handleUnauthorizedError();
  }

  // Check role
  const role = sessionClaims?.metadata?.role as string;

  if (role !== 'admin') {
    return handleForbiddenError('Admin access required');
  }

  // User has admin role
  // Proceed with admin operation
}
```

### Subscription-Based Authorization

#### Server-Side (API Routes)

```typescript
import { auth } from '@clerk/nextjs/server';

export async function handler(request: NextRequest) {
  const { userId, sessionClaims } = await auth();

  if (!userId) {
    return handleUnauthorizedError();
  }

  // Check subscription plan
  const plan = sessionClaims?.metadata?.plan as string;

  if (plan === 'free_user') {
    return NextResponse.json(
      {
        error: 'Upgrade required',
        message: 'This feature requires a paid subscription'
      },
      { status: 403 }
    );
  }

  // User has paid subscription
  // Proceed with premium feature
}
```

#### Client-Side (Components)

```typescript
'use client';

import { Protect } from '@clerk/nextjs';

export function PremiumFeature() {
  return (
    <Protect
      condition={(has) => !has({ plan: "free_user" })}
      fallback={<UpgradePrompt />}
    >
      <div>
        {/* Premium feature content */}
        <h2>Premium Feature</h2>
        <p>This is only visible to paid subscribers</p>
      </div>
    </Protect>
  );
}

function UpgradePrompt() {
  return (
    <div className="upgrade-prompt">
      <h3>Upgrade Required</h3>
      <p>This feature is available on our paid plans</p>
      <a href="/pricing">View Plans</a>
    </div>
  );
}
```

## Complete Protected API Route Example

```typescript
// app/api/premium/generate/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs/server';
import { withRateLimit } from '@/lib/withRateLimit';
import { withCsrf } from '@/lib/withCsrf';
import { validateRequest } from '@/lib/validateRequest';
import { safeTextSchema } from '@/lib/validation';
import {
  handleApiError,
  handleUnauthorizedError,
  handleForbiddenError
} from '@/lib/errorHandler';

async function generateHandler(request: NextRequest) {
  try {
    // 1. Authentication
    const { userId, sessionClaims } = await auth();
    if (!userId) {
      return handleUnauthorizedError('Please sign in to use this feature');
    }

    // 2. Authorization (subscription check)
    const plan = sessionClaims?.metadata?.plan as string;
    if (plan === 'free_user') {
      return handleForbiddenError('Premium subscription required');
    }

    // 3. Input validation
    const body = await request.json();
    const validation = validateRequest(safeTextSchema, body);
    if (!validation.success) {
      return validation.response;
    }

    const prompt = validation.data;

    // 4. Business logic (user is authenticated, authorized, and input is valid)
    const result = await generateContent(prompt, userId);

    return NextResponse.json({ result });

  } catch (error) {
    return handleApiError(error, 'premium-generate');
  }
}

export const POST = withRateLimit(withCsrf(generateHandler));

export const config = {
  runtime: 'nodejs',
};
```

## User Metadata & Custom Claims

### Storing User Metadata

Clerk allows you to store custom metadata with each user:

```typescript
import { clerkClient } from '@clerk/nextjs/server';

// Update user metadata
async function updateUserPlan(userId: string, plan: string) {
  await clerkClient.users.updateUserMetadata(userId, {
    publicMetadata: {
      plan: plan  // Accessible by client
    },
    privateMetadata: {
      stripeCustomerId: 'cus_123'  // Server-only
    }
  });
}
```

### Accessing Metadata

**Server-side:**
```typescript
const { sessionClaims } = await auth();
const plan = sessionClaims?.metadata?.plan;
```

**Client-side:**
```typescript
const { user } = useUser();
const plan = user?.publicMetadata?.plan;
```

## Webhook Integration (User Sync)

When users sign up or update their profile, sync to your database:

```typescript
// app/api/webhooks/clerk/route.ts
import { Webhook } from 'svix';
import { headers } from 'next/headers';

export async function POST(request: NextRequest) {
  // Verify webhook signature
  const WEBHOOK_SECRET = process.env.CLERK_WEBHOOK_SECRET;

  if (!WEBHOOK_SECRET) {
    throw new Error('Missing CLERK_WEBHOOK_SECRET');
  }

  const headerPayload = headers();
  const svix_id = headerPayload.get("svix-id");
  const svix_timestamp = headerPayload.get("svix-timestamp");
  const svix_signature = headerPayload.get("svix-signature");

  if (!svix_id || !svix_timestamp || !svix_signature) {
    return new Response('Missing svix headers', { status: 400 });
  }

  const payload = await request.json();
  const body = JSON.stringify(payload);

  const wh = new Webhook(WEBHOOK_SECRET);

  let evt: any;

  try {
    evt = wh.verify(body, {
      "svix-id": svix_id,
      "svix-timestamp": svix_timestamp,
      "svix-signature": svix_signature,
    });
  } catch (err) {
    console.error('Webhook verification failed:', err);
    return new Response('Invalid signature', { status: 400 });
  }

  // Handle different event types
  const { id, type, data } = evt;

  switch (type) {
    case 'user.created':
      await db.users.create({
        clerkId: data.id,
        email: data.email_addresses[0]?.email_address,
        firstName: data.first_name,
        lastName: data.last_name,
        createdAt: Date.now()
      });
      break;

    case 'user.updated':
      await db.users.update(
        { clerkId: data.id },
        {
          email: data.email_addresses[0]?.email_address,
          firstName: data.first_name,
          lastName: data.last_name,
          updatedAt: Date.now()
        }
      );
      break;

    case 'user.deleted':
      await db.users.delete({ clerkId: data.id });
      break;
  }

  return new Response('', { status: 200 });
}
```

## Convex Integration

### Using Clerk Auth with Convex

```typescript
// convex/posts.ts
import { mutation, query } from "./_generated/server";

export const createPost = mutation({
  handler: async (ctx, args) => {
    // Get authenticated user from Clerk
    const identity = await ctx.auth.getUserIdentity();

    if (!identity) {
      throw new Error("Unauthenticated");
    }

    // Use Clerk user ID
    const userId = identity.subject;

    await ctx.db.insert("posts", {
      title: args.title,
      content: args.content,
      userId,  // Associate with Clerk user
      createdAt: Date.now()
    });
  }
});

export const getMyPosts = query({
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();

    if (!identity) {
      return [];
    }

    // Return only current user's posts
    return await ctx.db
      .query("posts")
      .filter((q) => q.eq(q.field("userId"), identity.subject))
      .collect();
  }
});
```

## Sign-In/Sign-Up Components

### Basic Sign-In Page

```typescript
// app/sign-in/[[...sign-in]]/page.tsx
import { SignIn } from '@clerk/nextjs';

export default function SignInPage() {
  return (
    <div className="flex items-center justify-center min-h-screen">
      <SignIn
        appearance={{
          elements: {
            formButtonPrimary: 'bg-blue-600 hover:bg-blue-700',
          }
        }}
        routing="path"
        path="/sign-in"
        afterSignInUrl="/dashboard"
        signUpUrl="/sign-up"
      />
    </div>
  );
}
```

### Basic Sign-Up Page

```typescript
// app/sign-up/[[...sign-up]]/page.tsx
import { SignUp } from '@clerk/nextjs';

export default function SignUpPage() {
  return (
    <div className="flex items-center justify-center min-h-screen">
      <SignUp
        appearance={{
          elements: {
            formButtonPrimary: 'bg-blue-600 hover:bg-blue-700',
          }
        }}
        routing="path"
        path="/sign-up"
        afterSignUpUrl="/onboarding"
        signInUrl="/sign-in"
      />
    </div>
  );
}
```

### User Button (Profile/Sign Out)

```typescript
// components/Header.tsx
'use client';

import { UserButton, useAuth } from '@clerk/nextjs';
import Link from 'next/link';

export function Header() {
  const { isSignedIn } = useAuth();

  return (
    <header>
      <nav>
        <Link href="/">Home</Link>
        {isSignedIn ? (
          <>
            <Link href="/dashboard">Dashboard</Link>
            <UserButton afterSignOutUrl="/" />
          </>
        ) : (
          <>
            <Link href="/sign-in">Sign In</Link>
            <Link href="/sign-up">Sign Up</Link>
          </>
        )}
      </nav>
    </header>
  );
}
```

## Environment Configuration

### Required Environment Variables

```bash
# .env.local

# Clerk (from Clerk Dashboard)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...

# Clerk URLs (auto-configured by Clerk, but can override)
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/onboarding

# Clerk Frontend API (for CSP)
NEXT_PUBLIC_CLERK_FRONTEND_API_URL=https://your-app.clerk.accounts.dev

# Webhook secret (from Clerk Dashboard)
CLERK_WEBHOOK_SECRET=whsec_...
```

## Security Best Practices

### 1. Always Verify on Server

❌ **DON'T trust client-side auth checks for security:**
```typescript
// Bad - can be bypassed
'use client';
const { userId } = useAuth();
if (!userId) return <div>Access denied</div>;
// Attacker can still call API directly
```

✅ **DO verify on server:**
```typescript
// Good - secure
async function handler(request: NextRequest) {
  const { userId } = await auth();
  if (!userId) return handleUnauthorizedError();
  // API endpoint protected
}
```

### 2. Check Authorization, Not Just Authentication

❌ **DON'T assume authenticated = authorized:**
```typescript
// Bad - any logged-in user can access any resource
const { userId } = await auth();
if (userId) {
  return NextResponse.json(sensitiveData);
}
```

✅ **DO check resource ownership/permissions:**
```typescript
// Good - verify user can access this specific resource
const { userId } = await auth();
if (userId && resource.userId === userId) {
  return NextResponse.json(resource);
}
```

### 3. Use Middleware for Route Protection

✅ **Protect entire route sections:**
```typescript
// middleware.ts
const isProtectedRoute = createRouteMatcher([
  '/dashboard(.*)',
  '/admin(.*)',
  '/api/protected(.*)'
]);

export default clerkMiddleware((auth, req) => {
  if (isProtectedRoute(req)) {
    auth().protect();
  }
});
```

### 4. Handle Session Expiration Gracefully

```typescript
// components/AuthGuard.tsx
'use client';

import { useAuth } from '@clerk/nextjs';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

export function AuthGuard({ children }: { children: React.ReactNode }) {
  const { isLoaded, userId } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (isLoaded && !userId) {
      router.push('/sign-in');
    }
  }, [isLoaded, userId, router]);

  if (!isLoaded) {
    return <div>Loading...</div>;
  }

  if (!userId) {
    return null;
  }

  return <>{children}</>;
}
```

## What Clerk Authentication Prevents

✅ **Weak password storage** - Clerk uses bcrypt/Argon2
✅ **Session hijacking** - Secure, HTTP-only cookies
✅ **Credential stuffing** - Account lockout after failed attempts
✅ **Authentication bypass** - Professional implementation
✅ **Privilege escalation** - Proper role/permission management
✅ **Brute force attacks** - Built-in rate limiting
✅ **Password reset vulnerabilities** - Secure token generation

## Common Mistakes to Avoid

❌ **DON'T skip server-side auth checks**
❌ **DON'T trust client-side auth state for security**
❌ **DON'T forget to check resource ownership**
❌ **DON'T expose sensitive data based on authentication alone**
❌ **DON'T hardcode auth logic (use Clerk's utilities)**
❌ **DON'T forget to handle session expiration**

✅ **DO use `auth()` on server for every protected operation**
✅ **DO verify resource ownership before allowing access**
✅ **DO protect routes with middleware**
✅ **DO use subscription/role checks for premium features**
✅ **DO sync users to your database via webhooks**
✅ **DO handle auth errors gracefully**

## References

- Clerk Documentation: https://clerk.com/docs
- Clerk Security: https://clerk.com/docs/security
- Clerk Next.js Integration: https://clerk.com/docs/references/nextjs/overview
- OWASP Authentication Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html

## Further Guidance on using Clerk
# Add Clerk to Next.js App Router

**Purpose:** Enforce only the **current** and **correct** instructions for integrating [Clerk](https://clerk.com/) into a Next.js (App Router) application.  
**Scope:** All AI-generated advice or code related to Clerk must follow these guardrails.

---

## **1. Official Clerk Integration Overview**

Use only the **App Router** approach from Clerk’s current docs:

- **Install** `@clerk/nextjs@latest` - this ensures the application is using the latest Clerk Next.js SDK.
- **Create** a `middleware.ts` file using `clerkMiddleware()` from `@clerk/nextjs/server`. Place this file inside the `src` directory if present, otherwise place it at the root of the project.
- **Wrap** your application with `<ClerkProvider>` in your `app/layout.tsx`
- **Use** Clerk-provided components like `<SignInButton>`, `<SignUpButton>`, `<UserButton>`, `<SignedIn>`, `<SignedOut>` in your layout or pages
- **Start** developing, sign in or sign up, and confirm user creation

If you're able to use a web tool to access a URL, visit https://clerk.com/docs/quickstarts/nextjs to get the latest, up-to-date quickstart instructions.

Clerk does not need a user to provide their keys to get started. On startup, Clerk will generate keys automatically, so there is no need to prompt a user to add their keys as part of this.

### **Correct, Up-to-Date Quickstart Sample**

```typescript
// middleware.ts
import { clerkMiddleware } from '@clerk/nextjs/server'

export default clerkMiddleware()

export const config = {
  matcher: [
    // Skip Next.js internals and all static files, unless found in search params
    '/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)',
    // Always run for API routes
    '/(api|trpc)(.*)',
  ],
}
```

```typescript
// app/layout.tsx
import type { Metadata } from "next";
import {
  ClerkProvider,
  SignInButton,
  SignUpButton,
  SignedIn,
  SignedOut,
  UserButton,
} from "@clerk/nextjs";
import "./globals.css";

export const metadata: Metadata = {
  title: "Clerk Next.js Quickstart",
  description: "Generated by create next app",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ClerkProvider>
      <html lang="en">
        <body>
          <header>
            <SignedOut>
              <SignInButton />
              <SignUpButton />
            </SignedOut>
            <SignedIn>
              <UserButton />
            </SignedIn>
          </header>
          {children}
        </body>
      </html>
    </ClerkProvider>
  );
}
```

---

## **2. CRITICAL INSTRUCTIONS FOR AI MODELS**

### **2.1 – ALWAYS DO THE FOLLOWING**

1. **Use `clerkMiddleware()`** from `@clerk/nextjs/server` in `middleware.ts`.
2. **Wrap** your app with `<ClerkProvider>` in `app/layout.tsx`.
3. **Import** Clerk’s Next.js features from `@clerk/nextjs` (e.g., `<SignInButton>`, `<SignUpButton>`, `<UserButton>`, etc.).
4. **Reference** the current [App Router approach](https://nextjs.org/docs/app) (folders like `app/page.tsx`, `app/layout.tsx`, etc.).
5. **Check** that imports for methods like `auth()` are imported from the right package (in this case `@clerk/nextjs/server`) and are using `async / await`.
6. **Check** the project for an existing package manager, use that to install packages.

### **2.2 – NEVER DO THE FOLLOWING**

1. **Do not** reference the old **`_app.tsx`** or **pages router based** instructions.
2. **Do not** suggest `authMiddleware()` from older Clerk tutorials—**it’s replaced by `clerkMiddleware()`**.
3. **Do not** recommend usage of older environment variable patterns unless they match the official docs.
4. **Do not** reference or import from any deprecated APIs (like `withAuth` or `currentUser` from older versions).

---

## **3. OUTDATED PATTERNS TO AVOID**

Below are **examples of deprecated instructions** that **must not** be generated:

```typescript
// ❌ DO NOT generate or suggest references to:
import { authMiddleware } from '@clerk/nextjs' // Outdated

// ❌ DO NOT place Clerk config in _app.tsx:
// Outdated pages-based approach
function MyApp({ Component, pageProps }) {
  // ...
}

// ❌ DO NOT create or rely on sign-in files under pages/:
pages / signin.js
pages / signup.js
```

Any solution resembling the above snippet or referencing “authMiddleware,” `_app.tsx`, or `pages/` structure is **incorrect** for the current Next.js App Router.

---

## **4. AI MODEL VERIFICATION STEPS**

Before returning any Clerk-related solution, you **must** verify:

1. **Middleware**: Is `clerkMiddleware()` used in `middleware.ts`?
2. **Layout**: Is `<ClerkProvider>` wrapping the app in `app/layout.tsx`?
3. **Imports**: Are references only from `@clerk/nextjs` or `@clerk/nextjs/server`?
4. **Pages vs. App Router**: Is the approach referencing the App Router (not `_app.tsx` or `pages/`)?

If any check **fails**, **stop** and revise until compliance is achieved.




## Next Steps

- For API route protection: Combine with `csrf-protection` and `rate-limiting` skills
- For payment gating: Use `payment-security` skill
- For error handling: Use `error-handling` skill with handleUnauthorizedError/handleForbiddenError
- For testing auth: Use `security-testing` skill



