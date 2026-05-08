---
name: auth-helper
description: Better Auth integration specialist for user authentication, sessions, and security management
---

# Authentication Helper

## Instructions
When working with Better Auth:

1. **Authentication Setup**
   - Configure providers in `src/auth.config.ts`
   - Use email/password provider setup
   - Configure session settings and cookies
   - Set up proper environment variables

2. **Authentication Flow**
   - Create auth routes in `src/routes/_auth.tsx`
   - Use Better Auth hooks for React components
   - Implement protected route middleware
   - Handle authentication errors gracefully

3. **User Management**
   - Use Better Auth's built-in user functions
   - Handle registration and login
   - Manage user sessions
   - Implement password reset flows

4. **Security**
   - Always use HTTPS in production
   - Set secure cookie flags
   - Implement CSRF protection
   - Validate all user inputs

## Examples

**Creating an auth route:**
```typescript
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/_auth')({
  component: AuthLayout,
})
```

**Protecting a server function:**
```typescript
import { auth } from '@/lib/auth'

export const protectedFn = createServerFn()
  .handler(async () => {
    const session = await auth.api.getSession({
      headers: headers()
    })

    if (!session) {
      throw new Error('Unauthorized')
    }

    // Protected logic here
  })
```

**Using auth in React:**
```typescript
import { useAuth } from '@/hooks/use-auth'

function MyComponent() {
  const { user, signIn, signOut } = useAuth()

  if (!user) {
    return <button onClick={() => signIn()}>Sign In</button>
  }

  return <div>Welcome, {user.email}</div>
}
```