---
name: nextjs-integration
description: Complete Next.js integration patterns for Clerk authentication with App Router and Pages Router. Use when setting up Clerk in Next.js, configuring authentication middleware, implementing protected routes, setting up server/client components with auth, or when user mentions Clerk Next.js setup, App Router auth, Pages Router auth, or Next.js authentication integration.
allowed-tools: Bash, Read, Write, Edit, WebFetch
---

# nextjs-integration

## Instructions

This skill provides complete Clerk authentication integration for Next.js applications, supporting both App Router (Next.js 13+) and Pages Router patterns. It covers installation, middleware configuration, authentication helpers, and protected route patterns.

### 1. Clerk Installation & Setup

Install Clerk SDK and configure environment variables:

```bash
# Run automated installation script
bash ./skills/nextjs-integration/scripts/install-clerk.sh

# Or manually install
npm install @clerk/nextjs
```

**Environment Variables:**
```bash
# Create .env.local with Clerk credentials
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_your_key_here
CLERK_SECRET_KEY=sk_test_your_key_here

# Optional: Customize sign-in/sign-up URLs
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/onboarding
```

**What This Does:**
- Installs @clerk/nextjs package
- Creates .env.local with placeholder keys
- Configures redirect URLs for sign-in/sign-up flows
- Sets up authentication endpoints

### 2. App Router Integration

Configure Clerk for Next.js App Router (13.4+):

```bash
# Run App Router setup script
bash ./skills/nextjs-integration/scripts/setup-app-router.sh
```

**Files Created:**
- `middleware.ts` - Route protection at edge
- `app/layout.tsx` - ClerkProvider wrapper
- `app/sign-in/[[...sign-in]]/page.tsx` - Sign-in page
- `app/sign-up/[[...sign-up]]/page.tsx` - Sign-up page

**App Router Features:**
- Server Components with `auth()` helper
- Client Components with `useAuth()` hook
- Edge middleware for route protection
- Automatic session management
- RSC-compatible authentication

**Copy Template Files:**
```bash
# Middleware configuration
cp ./skills/nextjs-integration/templates/app-router/middleware.ts ./middleware.ts

# Root layout with ClerkProvider
cp ./skills/nextjs-integration/templates/app-router/layout.tsx ./app/layout.tsx
```

### 3. Pages Router Integration

Configure Clerk for Next.js Pages Router (12.x and earlier):

```bash
# Run Pages Router setup script
bash ./skills/nextjs-integration/scripts/setup-pages-router.sh
```

**Files Created:**
- `pages/_app.tsx` - ClerkProvider wrapper
- `pages/api/auth.ts` - API route for auth callbacks
- `pages/sign-in/[[...index]].tsx` - Sign-in page
- `pages/sign-up/[[...index]].tsx` - Sign-up page

**Pages Router Features:**
- getServerSideProps with auth
- API routes with auth protection
- Client-side authentication hooks
- Custom sign-in/sign-up components

**Copy Template Files:**
```bash
# _app.tsx with ClerkProvider
cp ./skills/nextjs-integration/templates/pages-router/_app.tsx ./pages/_app.tsx

# Auth API route
cp ./skills/nextjs-integration/templates/pages-router/api/auth.ts ./pages/api/auth.ts
```

### 4. Authentication Middleware

Configure middleware for route protection:

```bash
# Setup auth middleware with route matching
bash ./skills/nextjs-integration/scripts/configure-middleware.sh
```

**Middleware Patterns:**
- Protect specific routes (e.g., `/dashboard/*`)
- Public routes configuration
- API route protection
- Custom redirect logic
- Matcher configuration for edge runtime

**Middleware Configuration:**
```typescript
// middleware.ts - Protects routes at the edge
import { authMiddleware } from "@clerk/nextjs";

export default authMiddleware({
  publicRoutes: ["/", "/api/public"],
  ignoredRoutes: ["/api/webhook"],
});

export const config = {
  matcher: ['/((?!.+\\.[\\w]+$|_next).*)', '/', '/(api|trpc)(.*)'],
};
```

### 5. Server Component Authentication (App Router)

Use `auth()` helper in Server Components:

```typescript
import { auth } from '@clerk/nextjs';

export default async function DashboardPage() {
  const { userId } = auth();

  if (!userId) {
    redirect('/sign-in');
  }

  // Protected server component logic
  const userData = await fetchUserData(userId);

  return <div>Welcome {userData.name}</div>;
}
```

**Server-Side Helpers:**
- `auth()` - Get current user session
- `currentUser()` - Get full user object
- `redirectToSignIn()` - Redirect helper
- `clerkClient` - Server-side Clerk API client

### 6. Client Component Authentication

Use React hooks in Client Components:

```typescript
'use client';
import { useAuth, useUser } from '@clerk/nextjs';

export function UserProfile() {
  const { userId, isLoaded, isSignedIn } = useAuth();
  const { user } = useUser();

  if (!isLoaded) return <div>Loading...</div>;
  if (!isSignedIn) return <div>Please sign in</div>;

  return <div>Hello {user.firstName}</div>;
}
```

**Client-Side Hooks:**
- `useAuth()` - Authentication state
- `useUser()` - Current user data
- `useClerk()` - Clerk instance methods
- `useSignIn()` - Sign-in flow control
- `useSignUp()` - Sign-up flow control

## Examples

### Example 1: Complete App Router Setup

```bash
# 1. Install Clerk
bash ./skills/nextjs-integration/scripts/install-clerk.sh

# 2. Configure App Router
bash ./skills/nextjs-integration/scripts/setup-app-router.sh

# 3. Setup middleware
bash ./skills/nextjs-integration/scripts/configure-middleware.sh

# 4. Copy protected route example
cp ./skills/nextjs-integration/examples/protected-route.tsx ./app/dashboard/page.tsx

# 5. Copy server component auth example
cp ./skills/nextjs-integration/examples/server-component-auth.tsx ./app/profile/page.tsx

# 6. Start development server
npm run dev
```

**Result:** Fully configured Next.js App Router with Clerk authentication, protected routes, and sign-in/sign-up pages

### Example 2: Pages Router with API Routes

```bash
# 1. Install Clerk
bash ./skills/nextjs-integration/scripts/install-clerk.sh

# 2. Configure Pages Router
bash ./skills/nextjs-integration/scripts/setup-pages-router.sh

# 3. Copy API route template
cp ./skills/nextjs-integration/templates/pages-router/api/auth.ts ./pages/api/auth.ts

# 4. Test authentication
npm run dev
```

**Result:** Pages Router setup with API route authentication and custom auth pages

### Example 3: Multi-Tenant Application

Configure organization-based authentication:

```typescript
// Server Component with organization context
import { auth } from '@clerk/nextjs';

export default async function TeamDashboard() {
  const { orgId, userId } = auth();

  if (!orgId) {
    return <div>Please select an organization</div>;
  }

  const teamData = await fetchTeamData(orgId);
  return <TeamView data={teamData} />;
}
```

**Organization Features:**
- Multi-tenant support
- Organization switching
- Role-based access control
- Team member management

### Example 4: Protected API Routes

```typescript
// App Router API route with auth
import { auth } from '@clerk/nextjs';
import { NextResponse } from 'next/server';

export async function GET() {
  const { userId } = auth();

  if (!userId) {
    return new NextResponse('Unauthorized', { status: 401 });
  }

  const data = await fetchProtectedData(userId);
  return NextResponse.json(data);
}
```

## Requirements

**Dependencies:**
- `@clerk/nextjs` - Clerk Next.js SDK
- Next.js 12.0+ (Pages Router) or 13.4+ (App Router)
- React 18+
- Node.js 18.17+ or 20+

**Clerk Account:**
- Active Clerk application (free tier available)
- Publishable key and secret key from dashboard
- Configured sign-in/sign-up flows in Clerk dashboard

**Project Structure:**
- Next.js project initialized with `create-next-app`
- `app/` directory (App Router) or `pages/` directory (Pages Router)
- TypeScript recommended but not required

**Environment Variables:**
- `.env.local` for local development
- `.env.production` for production (never commit secrets)
- Vercel/deployment platform environment variable configuration

## Security Best Practices

**Never Hardcode API Keys:**
```bash
# ✅ CORRECT - Use environment variables
CLERK_SECRET_KEY=your_clerk_secret_key_here

# ❌ WRONG - Never commit secrets
const clerkSecret = "sk_test_abc123..." // DON'T DO THIS
```

**Protect Sensitive Routes:**
- Use middleware for edge-level protection
- Validate auth in Server Components
- Check authentication in API routes
- Never trust client-side auth alone

**Secure API Routes:**
```typescript
// Always validate auth server-side
const { userId } = auth();
if (!userId) {
  return new NextResponse('Unauthorized', { status: 401 });
}
```

**Environment Variable Management:**
- Use `.env.local` for development (git-ignored)
- Use `.env.example` with placeholders (safe to commit)
- Store production keys in deployment platform
- Rotate keys periodically

## App Router vs Pages Router

**Use App Router When:**
- Building new Next.js 13.4+ applications
- Need Server Components for better performance
- Want edge middleware capabilities
- Require streaming and suspense features

**Use Pages Router When:**
- Maintaining existing Next.js 12.x applications
- Team familiar with traditional Next.js patterns
- Need getServerSideProps/getStaticProps
- Gradual migration from older Next.js versions

**Migration Path:**
- Can mix both routers in same application
- Migrate routes incrementally
- App Router is recommended for new features

## Integration Patterns

**With Supabase:**
- Use Clerk for authentication
- Pass Clerk user ID to Supabase RLS policies
- Sync user data between Clerk and Supabase

**With tRPC:**
- Add Clerk user context to tRPC context
- Protect procedures with auth middleware
- Type-safe authentication in API layer

**With Prisma:**
- Store Clerk user ID as foreign key
- Link user data to Clerk profiles
- Use userId for data isolation

**With Vercel:**
- Automatic environment variable sync
- Edge middleware deployment
- Preview deployments with auth

## Troubleshooting

**Middleware Not Running:**
- Check matcher configuration in middleware.ts
- Ensure middleware.ts is at project root
- Verify Edge Runtime compatibility

**Sign-In Redirect Loop:**
- Check `NEXT_PUBLIC_CLERK_SIGN_IN_URL` matches route
- Verify publicRoutes includes sign-in page
- Ensure middleware doesn't protect auth routes

**Server Component Hydration:**
- Don't use useAuth in Server Components
- Use auth() helper instead
- Ensure ClerkProvider wraps layout

**Environment Variables Not Loading:**
- Restart development server after .env changes
- Use NEXT_PUBLIC_ prefix for client-side vars
- Check .env.local exists and is git-ignored

---

**Plugin:** clerk
**Version:** 1.0.0
**Category:** Authentication
**Skill Type:** Integration & Configuration
