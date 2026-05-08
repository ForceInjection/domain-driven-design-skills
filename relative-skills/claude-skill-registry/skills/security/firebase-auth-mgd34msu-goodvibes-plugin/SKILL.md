---
name: firebase-auth
description: Implements Firebase Authentication with email, OAuth, phone auth, and custom tokens. Use when building apps with Firebase, needing flexible auth methods, or integrating with Firebase ecosystem.
---

# Firebase Auth

Firebase Authentication provides backend services and SDKs for user authentication. Supports email/password, OAuth providers, phone, anonymous, and custom token auth.

## Quick Start

### Installation

```bash
npm install firebase
```

### Initialize Firebase

```typescript
// lib/firebase.ts
import { initializeApp, getApps } from 'firebase/app'
import { getAuth } from 'firebase/auth'

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID
}

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0]
export const auth = getAuth(app)
```

## Email/Password Authentication

### Sign Up

```typescript
import { createUserWithEmailAndPassword, updateProfile } from 'firebase/auth'
import { auth } from '@/lib/firebase'

async function signUp(email: string, password: string, displayName: string) {
  try {
    const { user } = await createUserWithEmailAndPassword(auth, email, password)

    await updateProfile(user, { displayName })

    return user
  } catch (error: any) {
    switch (error.code) {
      case 'auth/email-already-in-use':
        throw new Error('Email already registered')
      case 'auth/weak-password':
        throw new Error('Password should be at least 6 characters')
      default:
        throw new Error('Sign up failed')
    }
  }
}
```

### Sign In

```typescript
import { signInWithEmailAndPassword } from 'firebase/auth'

async function signIn(email: string, password: string) {
  try {
    const { user } = await signInWithEmailAndPassword(auth, email, password)
    return user
  } catch (error: any) {
    switch (error.code) {
      case 'auth/invalid-credential':
        throw new Error('Invalid email or password')
      case 'auth/user-disabled':
        throw new Error('Account disabled')
      default:
        throw new Error('Sign in failed')
    }
  }
}
```

### Sign Out

```typescript
import { signOut } from 'firebase/auth'

async function logout() {
  await signOut(auth)
}
```

## Auth State Management

### Listen to Auth Changes

```typescript
import { onAuthStateChanged, User } from 'firebase/auth'

// Subscribe to auth state
const unsubscribe = onAuthStateChanged(auth, (user) => {
  if (user) {
    console.log('Signed in:', user.uid)
  } else {
    console.log('Signed out')
  }
})

// Cleanup
unsubscribe()
```

### React Context

```typescript
// contexts/auth-context.tsx
'use client'
import { createContext, useContext, useEffect, useState } from 'react'
import { onAuthStateChanged, User } from 'firebase/auth'
import { auth } from '@/lib/firebase'

type AuthContextType = {
  user: User | null
  loading: boolean
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  loading: true
})

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user)
      setLoading(false)
    })

    return unsubscribe
  }, [])

  return (
    <AuthContext.Provider value={{ user, loading }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
```

### Usage

```typescript
'use client'
import { useAuth } from '@/contexts/auth-context'

export default function Profile() {
  const { user, loading } = useAuth()

  if (loading) return <div>Loading...</div>
  if (!user) return <div>Please sign in</div>

  return (
    <div>
      <p>Email: {user.email}</p>
      <p>Name: {user.displayName}</p>
      <img src={user.photoURL || ''} alt="Avatar" />
    </div>
  )
}
```

## OAuth Providers

### Google Sign In

```typescript
import { signInWithPopup, GoogleAuthProvider } from 'firebase/auth'

const googleProvider = new GoogleAuthProvider()
googleProvider.addScope('email')
googleProvider.addScope('profile')

async function signInWithGoogle() {
  try {
    const result = await signInWithPopup(auth, googleProvider)
    const credential = GoogleAuthProvider.credentialFromResult(result)
    const token = credential?.accessToken

    return result.user
  } catch (error: any) {
    if (error.code === 'auth/popup-closed-by-user') {
      return null
    }
    throw error
  }
}
```

### GitHub Sign In

```typescript
import { signInWithPopup, GithubAuthProvider } from 'firebase/auth'

const githubProvider = new GithubAuthProvider()
githubProvider.addScope('read:user')

async function signInWithGithub() {
  const result = await signInWithPopup(auth, githubProvider)
  return result.user
}
```

### Sign In with Redirect

For mobile or when popups are blocked:

```typescript
import { signInWithRedirect, getRedirectResult, GoogleAuthProvider } from 'firebase/auth'

// Initiate redirect
async function startGoogleSignIn() {
  await signInWithRedirect(auth, new GoogleAuthProvider())
}

// Handle redirect result (call on page load)
async function handleRedirect() {
  const result = await getRedirectResult(auth)
  if (result) {
    console.log('Signed in:', result.user)
  }
}
```

## Phone Authentication

### Send Verification Code

```typescript
import { signInWithPhoneNumber, RecaptchaVerifier } from 'firebase/auth'

// Setup reCAPTCHA
const recaptchaVerifier = new RecaptchaVerifier(auth, 'recaptcha-container', {
  size: 'invisible',
  callback: () => {
    // reCAPTCHA solved
  }
})

async function sendVerificationCode(phoneNumber: string) {
  try {
    const confirmationResult = await signInWithPhoneNumber(
      auth,
      phoneNumber,
      recaptchaVerifier
    )
    // Store confirmationResult to use in verification step
    return confirmationResult
  } catch (error) {
    console.error('SMS not sent:', error)
    throw error
  }
}
```

### Verify Code

```typescript
async function verifyCode(confirmationResult: any, code: string) {
  try {
    const result = await confirmationResult.confirm(code)
    return result.user
  } catch (error) {
    throw new Error('Invalid verification code')
  }
}
```

## Anonymous Authentication

```typescript
import { signInAnonymously, linkWithCredential, EmailAuthProvider } from 'firebase/auth'

// Sign in anonymously
async function signInAnon() {
  const { user } = await signInAnonymously(auth)
  return user
}

// Convert to permanent account
async function convertToEmailAccount(email: string, password: string) {
  const user = auth.currentUser
  if (!user) throw new Error('No user')

  const credential = EmailAuthProvider.credential(email, password)
  await linkWithCredential(user, credential)
}
```

## Password Management

### Reset Password

```typescript
import { sendPasswordResetEmail } from 'firebase/auth'

async function resetPassword(email: string) {
  await sendPasswordResetEmail(auth, email, {
    url: 'https://myapp.com/login'
  })
}
```

### Update Password

```typescript
import { updatePassword, reauthenticateWithCredential, EmailAuthProvider } from 'firebase/auth'

async function changePassword(currentPassword: string, newPassword: string) {
  const user = auth.currentUser
  if (!user || !user.email) throw new Error('No user')

  // Re-authenticate first
  const credential = EmailAuthProvider.credential(user.email, currentPassword)
  await reauthenticateWithCredential(user, credential)

  // Update password
  await updatePassword(user, newPassword)
}
```

## Email Verification

```typescript
import { sendEmailVerification } from 'firebase/auth'

async function verifyEmail() {
  const user = auth.currentUser
  if (!user) throw new Error('No user')

  await sendEmailVerification(user, {
    url: 'https://myapp.com/verified'
  })
}

// Check if verified
const isVerified = auth.currentUser?.emailVerified
```

## Update Profile

```typescript
import { updateProfile, updateEmail } from 'firebase/auth'

async function updateUserProfile(displayName: string, photoURL: string) {
  const user = auth.currentUser
  if (!user) throw new Error('No user')

  await updateProfile(user, { displayName, photoURL })
}

async function changeEmail(newEmail: string) {
  const user = auth.currentUser
  if (!user) throw new Error('No user')

  await updateEmail(user, newEmail)
  // Sends verification email automatically
}
```

## ID Tokens

### Get ID Token

```typescript
async function getIdToken() {
  const user = auth.currentUser
  if (!user) throw new Error('No user')

  const token = await user.getIdToken()
  return token
}

// Force refresh
const token = await user.getIdToken(true)
```

### Verify on Server

```typescript
// Server-side (Firebase Admin SDK)
import { getAuth } from 'firebase-admin/auth'

async function verifyToken(idToken: string) {
  try {
    const decodedToken = await getAuth().verifyIdToken(idToken)
    return decodedToken
  } catch (error) {
    throw new Error('Invalid token')
  }
}
```

## Custom Claims

### Set Claims (Admin SDK)

```typescript
import { getAuth } from 'firebase-admin/auth'

async function setUserRole(uid: string, role: string) {
  await getAuth().setCustomUserClaims(uid, { role })
}
```

### Read Claims (Client)

```typescript
async function getUserRole() {
  const user = auth.currentUser
  if (!user) return null

  const tokenResult = await user.getIdTokenResult()
  return tokenResult.claims.role
}
```

## Protected Routes (Next.js)

### Middleware

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const session = request.cookies.get('session')

  if (!session && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*']
}
```

### Session Cookie

```typescript
// app/api/session/route.ts
import { getAuth } from 'firebase-admin/auth'
import { cookies } from 'next/headers'

export async function POST(request: Request) {
  const { idToken } = await request.json()

  const expiresIn = 60 * 60 * 24 * 5 * 1000 // 5 days

  try {
    const sessionCookie = await getAuth().createSessionCookie(idToken, {
      expiresIn
    })

    cookies().set('session', sessionCookie, {
      maxAge: expiresIn / 1000,
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      path: '/'
    })

    return Response.json({ status: 'success' })
  } catch (error) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 })
  }
}
```

## Link Multiple Providers

```typescript
import { linkWithPopup, GoogleAuthProvider } from 'firebase/auth'

async function linkGoogle() {
  const user = auth.currentUser
  if (!user) throw new Error('No user')

  const result = await linkWithPopup(user, new GoogleAuthProvider())
  return result.user
}

// Unlink provider
import { unlink } from 'firebase/auth'

async function unlinkGoogle() {
  const user = auth.currentUser
  if (!user) throw new Error('No user')

  await unlink(user, 'google.com')
}
```

## Error Handling

```typescript
import { AuthError } from 'firebase/auth'

function handleAuthError(error: AuthError) {
  switch (error.code) {
    case 'auth/email-already-in-use':
      return 'Email already registered'
    case 'auth/invalid-email':
      return 'Invalid email address'
    case 'auth/weak-password':
      return 'Password too weak'
    case 'auth/user-not-found':
      return 'User not found'
    case 'auth/wrong-password':
      return 'Incorrect password'
    case 'auth/too-many-requests':
      return 'Too many attempts. Try again later'
    case 'auth/network-request-failed':
      return 'Network error'
    default:
      return 'Authentication error'
  }
}
```

## Best Practices

1. **Use context for auth state** - Single source of truth
2. **Handle all error codes** - User-friendly messages
3. **Verify tokens server-side** - Never trust client
4. **Use session cookies** - For server-side apps
5. **Enable email verification** - For sensitive apps
6. **Implement re-auth** - Before sensitive operations

## References

- [Admin SDK Setup](references/admin-sdk.md)
- [Security Rules](references/security-rules.md)
