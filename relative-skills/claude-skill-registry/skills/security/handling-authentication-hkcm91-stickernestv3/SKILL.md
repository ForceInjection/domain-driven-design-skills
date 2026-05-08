---
name: handling-authentication
description: Handling authentication and authorization in StickerNest. Use when the user asks about login, signup, auth, session, protected routes, user context, JWT, tokens, logout, or permission checks. Covers Supabase Auth, AuthContext, protected routes, and widget auth.
---

# Handling Authentication in StickerNest

This skill covers implementing authentication flows, protecting routes, managing sessions, and providing auth context to widgets.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Supabase Auth                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │   Email     │  │   OAuth     │  │   Magic     │          │
│  │  Password   │  │   (Google)  │  │   Link      │          │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘          │
└─────────┼────────────────┼────────────────┼─────────────────┘
          │                │                │
          └────────────────┼────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                     AuthContext                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │    user     │  │   session   │  │  isLoading  │          │
│  │   profile   │  │   tokens    │  │   isLocal   │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
└─────────────────────────┬───────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
  Components         Widgets          Services
  (useAuth)       (WidgetAuth)      (API calls)
```

---

## AuthContext Implementation

### Location: `src/contexts/AuthContext.tsx`

```typescript
import React, { createContext, useContext, useEffect, useState } from 'react';
import { createClient, SupabaseClient, User, Session } from '@supabase/supabase-js';

interface Profile {
  id: string;
  username: string | null;
  display_name: string | null;
  avatar_url: string | null;
  bio: string | null;
}

interface AuthContextType {
  user: User | null;
  profile: Profile | null;
  session: Session | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  isLocalDevMode: boolean;
  signUp: (email: string, password: string) => Promise<{ error: Error | null }>;
  signIn: (email: string, password: string) => Promise<{ error: Error | null }>;
  signInWithOAuth: (provider: 'google' | 'github') => Promise<void>;
  signOut: () => Promise<void>;
  updateProfile: (updates: Partial<Profile>) => Promise<{ error: Error | null }>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

// Supabase client singleton
let supabaseClient: SupabaseClient | null = null;

export function getSupabaseClient(): SupabaseClient | null {
  if (!supabaseClient && import.meta.env.VITE_SUPABASE_URL) {
    supabaseClient = createClient(
      import.meta.env.VITE_SUPABASE_URL,
      import.meta.env.VITE_SUPABASE_ANON_KEY
    );
  }
  return supabaseClient;
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const isLocalDevMode = !import.meta.env.VITE_SUPABASE_URL;

  useEffect(() => {
    if (isLocalDevMode) {
      // Local dev mode - use demo user
      setUser({ id: 'demo-user', email: 'demo@local.dev' } as User);
      setProfile({
        id: 'demo-user',
        username: 'demo',
        display_name: 'Demo User',
        avatar_url: null,
        bio: 'Local development user',
      });
      setIsLoading(false);
      return;
    }

    const supabase = getSupabaseClient();
    if (!supabase) return;

    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      if (session?.user) {
        fetchProfile(session.user.id);
      }
      setIsLoading(false);
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        setSession(session);
        setUser(session?.user ?? null);

        if (event === 'SIGNED_IN' && session?.user) {
          await fetchProfile(session.user.id);
        } else if (event === 'SIGNED_OUT') {
          setProfile(null);
        }
      }
    );

    return () => subscription.unsubscribe();
  }, [isLocalDevMode]);

  async function fetchProfile(userId: string) {
    const supabase = getSupabaseClient();
    if (!supabase) return;

    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();

    if (!error && data) {
      setProfile(data);
    }
  }

  async function signUp(email: string, password: string) {
    const supabase = getSupabaseClient();
    if (!supabase) return { error: new Error('Supabase not configured') };

    const { error } = await supabase.auth.signUp({ email, password });
    return { error };
  }

  async function signIn(email: string, password: string) {
    const supabase = getSupabaseClient();
    if (!supabase) return { error: new Error('Supabase not configured') };

    const { error } = await supabase.auth.signInWithPassword({ email, password });
    return { error };
  }

  async function signInWithOAuth(provider: 'google' | 'github') {
    const supabase = getSupabaseClient();
    if (!supabase) return;

    await supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    });
  }

  async function signOut() {
    const supabase = getSupabaseClient();
    if (!supabase) return;

    await supabase.auth.signOut();
  }

  async function updateProfile(updates: Partial<Profile>) {
    const supabase = getSupabaseClient();
    if (!supabase || !user) return { error: new Error('Not authenticated') };

    const { error } = await supabase
      .from('profiles')
      .update(updates)
      .eq('id', user.id);

    if (!error) {
      setProfile((prev) => prev ? { ...prev, ...updates } : null);
    }

    return { error };
  }

  const value: AuthContextType = {
    user,
    profile,
    session,
    isLoading,
    isAuthenticated: !!user,
    isLocalDevMode,
    signUp,
    signIn,
    signInWithOAuth,
    signOut,
    updateProfile,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
```

---

## Protected Routes

### ProtectedRoute Component

```typescript
// src/components/ProtectedRoute.tsx

import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requireProfile?: boolean;
}

export function ProtectedRoute({ children, requireProfile = false }: ProtectedRouteProps) {
  const { isAuthenticated, isLoading, profile, isLocalDevMode } = useAuth();
  const location = useLocation();

  // Show loading while checking auth
  if (isLoading) {
    return <LoadingSpinner />;
  }

  // Local dev mode - always authenticated
  if (isLocalDevMode) {
    return <>{children}</>;
  }

  // Not authenticated - redirect to login
  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // Need profile but don't have one - redirect to onboarding
  if (requireProfile && !profile?.username) {
    return <Navigate to="/onboarding" state={{ from: location }} replace />;
  }

  return <>{children}</>;
}
```

### Route Setup

```typescript
// src/App.tsx or routes.tsx

import { Routes, Route } from 'react-router-dom';
import { ProtectedRoute } from '@/components/ProtectedRoute';

function AppRoutes() {
  return (
    <Routes>
      {/* Public routes */}
      <Route path="/login" element={<LoginPage />} />
      <Route path="/signup" element={<SignupPage />} />
      <Route path="/auth/callback" element={<AuthCallback />} />

      {/* Protected routes */}
      <Route
        path="/dashboard"
        element={
          <ProtectedRoute>
            <DashboardPage />
          </ProtectedRoute>
        }
      />

      {/* Protected + requires profile */}
      <Route
        path="/canvas/:id"
        element={
          <ProtectedRoute requireProfile>
            <EditorPage />
          </ProtectedRoute>
        }
      />

      {/* Public canvas viewing */}
      <Route path="/c/:slug" element={<PublicCanvasPage />} />
    </Routes>
  );
}
```

---

## Auth Components

### Login Form

```typescript
// src/components/auth/LoginForm.tsx

import { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { useNavigate, useLocation } from 'react-router-dom';

export function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const { signIn, signInWithOAuth } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const from = location.state?.from?.pathname || '/dashboard';

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    setIsSubmitting(true);

    const { error } = await signIn(email, password);

    if (error) {
      setError(error.message);
      setIsSubmitting(false);
    } else {
      navigate(from, { replace: true });
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      {error && <div className="error">{error}</div>}

      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
        required
      />

      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
        required
      />

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Signing in...' : 'Sign In'}
      </button>

      <div className="oauth-buttons">
        <button type="button" onClick={() => signInWithOAuth('google')}>
          Continue with Google
        </button>
        <button type="button" onClick={() => signInWithOAuth('github')}>
          Continue with GitHub
        </button>
      </div>
    </form>
  );
}
```

### OAuth Callback Handler

```typescript
// src/pages/AuthCallback.tsx

import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { getSupabaseClient } from '@/contexts/AuthContext';

export function AuthCallback() {
  const navigate = useNavigate();

  useEffect(() => {
    const supabase = getSupabaseClient();
    if (!supabase) {
      navigate('/login');
      return;
    }

    // Handle OAuth callback
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session) {
        // Check if profile exists
        supabase
          .from('profiles')
          .select('username')
          .eq('id', session.user.id)
          .single()
          .then(({ data }) => {
            if (data?.username) {
              navigate('/dashboard');
            } else {
              navigate('/onboarding');
            }
          });
      } else {
        navigate('/login');
      }
    });
  }, [navigate]);

  return <LoadingSpinner />;
}
```

---

## Widget Authentication

### Providing Auth to Widgets

```typescript
// src/runtime/WidgetHost.ts

class WidgetHost {
  private sendAuthInfo() {
    const { user, profile, isAuthenticated } = this.authContext;

    // Only send safe, read-only info to widget
    this.sendMessage('widget:auth', {
      isAuthenticated,
      userId: user?.id || null,
      username: profile?.username || null,
      displayName: profile?.display_name || null,
      avatarUrl: profile?.avatar_url || null,
      // Never send: email, tokens, session
    });
  }

  // Handle auth-requiring requests from widgets
  private handleWidgetRequest(action: string, data: any) {
    if (!this.authContext.isAuthenticated) {
      return { error: 'Not authenticated' };
    }

    switch (action) {
      case 'social:follow':
        return SocialGraphService.followUser(data.userId);
      case 'social:sendMessage':
        return ChatService.sendMessage(data.channelId, data.content);
      // ... other authenticated actions
    }
  }
}
```

### Widget-Side Auth Handling

```javascript
// In widget code
const WidgetAPI = {
  auth: null,

  handleMessage(event) {
    if (event.data.type === 'widget:auth') {
      this.auth = event.data.payload;
      this.onAuthChange?.(this.auth);
    }
  },

  isAuthenticated() {
    return this.auth?.isAuthenticated ?? false;
  },

  getCurrentUser() {
    return this.auth;
  },

  // Request that requires auth
  async sendMessage(content) {
    if (!this.isAuthenticated()) {
      throw new Error('Authentication required');
    }
    return this.request('social:sendMessage', { content });
  }
};
```

---

## Session Management

### Token Refresh

```typescript
// Supabase handles token refresh automatically
// But you can listen for refresh events:

supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'TOKEN_REFRESHED') {
    console.log('Token refreshed');
    // Update any cached tokens
  }
});
```

### Session Persistence

```typescript
// Configure session persistence (default is localStorage)
const supabase = createClient(url, key, {
  auth: {
    persistSession: true,
    storageKey: 'stickernest-auth',
    storage: window.localStorage,
  },
});
```

---

## Permission Checks

### Service-Level Authorization

```typescript
// In services, always verify user can perform action

export async function deleteCanvas(canvasId: string): Promise<void> {
  const supabase = getSupabaseClient();
  const user = (await supabase.auth.getUser()).data.user;

  if (!user) {
    throw new Error('Not authenticated');
  }

  // RLS will also enforce this, but explicit check is good practice
  const { data: canvas } = await supabase
    .from('canvases')
    .select('user_id')
    .eq('id', canvasId)
    .single();

  if (canvas?.user_id !== user.id) {
    throw new Error('Not authorized');
  }

  await supabase.from('canvases').delete().eq('id', canvasId);
}
```

### Hook for Permission Checks

```typescript
// src/hooks/usePermission.ts

export function usePermission() {
  const { user, profile } = useAuth();

  return {
    canEditCanvas: (canvas: Canvas) => canvas.user_id === user?.id,
    canDeleteWidget: (widget: Widget, canvas: Canvas) => canvas.user_id === user?.id,
    canFollow: (targetUserId: string) => user?.id !== targetUserId,
    canSendDM: (targetUserId: string) => user?.id !== targetUserId,
    isOwner: (resource: { user_id: string }) => resource.user_id === user?.id,
  };
}
```

---

## Local Development Mode

### Demo User Setup

```typescript
// When VITE_SUPABASE_URL is not set, use local mode

const isLocalDevMode = !import.meta.env.VITE_SUPABASE_URL;

if (isLocalDevMode) {
  // Use demo user
  const demoUser = {
    id: 'demo-user-id',
    email: 'demo@local.dev',
  };

  const demoProfile = {
    id: 'demo-user-id',
    username: 'demo',
    display_name: 'Demo User',
    avatar_url: null,
  };

  // Store in localStorage
  localStorage.setItem('demo-user', JSON.stringify(demoUser));
  localStorage.setItem('demo-profile', JSON.stringify(demoProfile));
}
```

---

## Error Handling

### Auth Error Types

```typescript
type AuthError =
  | 'invalid_credentials'
  | 'email_not_confirmed'
  | 'user_not_found'
  | 'email_taken'
  | 'weak_password'
  | 'rate_limited'
  | 'network_error';

function getAuthErrorMessage(error: any): string {
  const message = error?.message?.toLowerCase() || '';

  if (message.includes('invalid login')) return 'Invalid email or password';
  if (message.includes('email not confirmed')) return 'Please confirm your email';
  if (message.includes('already registered')) return 'Email already registered';
  if (message.includes('password')) return 'Password must be at least 6 characters';
  if (message.includes('rate limit')) return 'Too many attempts. Please wait.';

  return 'An error occurred. Please try again.';
}
```

---

## Reference Files

| File | Purpose |
|------|---------|
| `src/contexts/AuthContext.tsx` | Auth provider and hooks |
| `src/components/ProtectedRoute.tsx` | Route protection |
| `src/pages/Login.tsx` | Login page |
| `src/pages/Signup.tsx` | Signup page |
| `src/pages/AuthCallback.tsx` | OAuth callback handler |
| `src/runtime/WidgetHost.ts` | Widget auth integration |

---

## Best Practices

1. **Never expose tokens to widgets** - Only send user ID and profile info
2. **Use RLS as primary security** - Service checks are secondary
3. **Handle loading states** - Show spinners during auth checks
4. **Redirect after login** - Return to original destination
5. **Support local dev mode** - Demo user for offline development
6. **Validate on server** - Never trust client-side checks alone
7. **Use secure cookies** - For session persistence in production
8. **Implement rate limiting** - Prevent brute force attacks
