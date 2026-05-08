---
name: firebase-master
description: Comprehensive Firebase skill for TypeScript/Next.js 16 projects. Use when configuring Firebase services (Firestore Client SDK with aggregations/vector search, Authentication, Storage, Cloud Functions v2, FCM push notifications, App Check bot protection), implementing security rules and indexes, troubleshooting Firebase errors, setting up auth providers (email/password, Google Sign-In), configuring VAPID keys for notifications, custom action URLs, reCAPTCHA Enterprise, replay protection, or resolving permission issues. Covers TypeScript patterns, Next.js 16 SSR/App Router integration, and common pain points like CORS, duplicate documents, notification setup, and bot abuse prevention.
---

# Firebase Master

## Overview

This skill provides expert guidance for implementing and troubleshooting Firebase services in TypeScript/Next.js 15 applications. It covers the complete Firebase ecosystem with focus on real-world pain points and production-ready patterns.

**Core Services Covered:**
- Firestore Database (client SDK, security rules, indexes, queries, aggregations, vector search)
- Firebase Authentication (email/password, Google Sign-In, custom action URLs)
- Firebase Storage (upload, download, security rules)
- Cloud Functions v2 (HTTP, callable, Firestore triggers, CORS)
- Firebase Cloud Messaging (push notifications, VAPID configuration)
- Firebase Admin SDK (initialization, custom claims)
- Firebase App Check (bot protection, replay protection, reCAPTCHA Enterprise)

## When to Use This Skill

Use this skill when working with Firebase in TypeScript/Next.js 15 projects, especially for:

1. **Initial Setup & Configuration**
   - "Configure Firebase Authentication with email/password and Google Sign-In"
   - "Set up Firestore security rules for user data"
   - "Initialize Firebase Admin SDK in Next.js API routes"

2. **Security & Rules**
   - "Create Firestore security rules for owner-based access"
   - "Configure Storage rules to allow only authenticated uploads"
   - "Why am I getting 'Missing or insufficient permissions' error?"

3. **Push Notifications**
   - "Configure FCM push notifications with VAPID keys"
   - "Notifications work in dev but not in production"
   - "Set up service worker for background notifications"

4. **Cloud Functions**
   - "Create a Cloud Function v2 for sending notifications"
   - "Configure CORS for HTTP functions"
   - "Why am I getting CORS errors from my function?"

5. **Troubleshooting**
   - "Firestore has duplicate user documents"
   - "Google Sign-In works on web but fails on mobile"
   - "Custom action URLs not working with custom domain"
   - "Token FCM não está sendo gerado"

6. **Data Consistency**
   - "Check if field names in code match Firestore"
   - "Why do I have both 'isActive' and 'active' fields?"
   - "Validate Firestore schema consistency"

7. **Firestore Client Operations**
   - "How do I use aggregation queries (count, sum, average)?"
   - "Implement vector search for AI/ML applications"
   - "Set up real-time listeners with offline cache"
   - "Use Firestore Lite for server-side rendering"

8. **Security & Bot Protection**
   - "Configure Firebase App Check with reCAPTCHA Enterprise"
   - "Implement replay protection for critical endpoints"
   - "Protect Cloud Functions from bot abuse"
   - "Set up App Check with Next.js 16 SSR/App Router"

## Core Capabilities

### 1. Firebase Authentication

Implement secure authentication with email/password and Google Sign-In providers.

**Common Tasks:**
- Set up email/password authentication with email verification
- Configure Google Sign-In (popup and redirect methods)
- Implement password reset flow
- Configure custom action URLs for custom domains
- Link multiple auth providers to same account
- Handle auth state in Next.js App Router

**Reference File:** `references/authentication.md`

**Key Patterns:**
```typescript
// Email/Password Sign Up with verification
const { success, error } = await signUpWithEmail(email, password);
if (success) {
  await sendEmailVerification(user);
}

// Google Sign-In with error handling
const { success, error } = await signInWithGoogle();

// Custom action URLs setup in Firebase Console
// https://meuapp.com/__/auth/action
```

### 2. Firestore Database

Configure security rules, create indexes, and implement type-safe queries with the Client SDK.

**Common Tasks:**
- Perform CRUD operations (create, read, update, delete)
- Write security rules with owner-based access
- Create composite indexes for complex queries
- Use aggregation queries (count, sum, average) to save costs
- Implement vector search for AI/ML applications (RAG, recommendations)
- Set up real-time listeners with offline persistence
- Validate data consistency (duplicate fields, wrong field names)
- Implement role-based access control
- Debug "Missing or insufficient permissions" errors
- Use Firestore Lite for SSR and Edge Functions (80% smaller bundle)

**Reference Files:**
- `references/firestore-client.md` - Client SDK operations, queries, aggregations, vector search
- `references/firestore-security-rules.md` - Security rules patterns, indexes, troubleshooting

**Key Patterns:**
```typescript
// CRUD Operations
import { collection, addDoc, getDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore'

// Create with auto ID
const docRef = await addDoc(collection(db, 'users'), { name: 'Alice' })

// Read document
const docSnap = await getDoc(doc(db, 'users', userId))
if (docSnap.exists()) {
  const data = docSnap.data()
}

// Aggregation queries (cost-efficient)
import { getAggregateFromServer, count, sum, average } from 'firebase/firestore'

const snapshot = await getAggregateFromServer(
  collection(db, 'orders'),
  {
    totalOrders: count(),
    totalRevenue: sum('amount'),
    averageOrder: average('amount')
  }
)

// Vector search for AI/ML
const vectorQuery = query(
  collection(db, 'products'),
  {
    findNearest: {
      vectorField: 'embedding',
      queryVector: await generateEmbedding(searchQuery),
      limit: 10,
      distanceMeasure: 'COSINE'
    }
  }
)

// Real-time listener
const unsubscribe = onSnapshot(doc(db, 'users', userId), (doc) => {
  console.log('Current data:', doc.data())
})

// Firestore Lite for SSR (Next.js Server Components)
import { getFirestore, getDocs } from 'firebase/firestore/lite'
const snapshot = await getDocs(collection(db, 'posts'))
```

**Security Rules:**
```javascript
// Owner-based security rule
match /users/{userId} {
  allow read, write: if request.auth != null
                     && request.auth.uid == userId;
}

// Index for complex query (firestore.indexes.json)
{
  "indexes": [{
    "collectionGroup": "posts",
    "queryScope": "COLLECTION",
    "fields": [
      { "fieldPath": "authorId", "order": "ASCENDING" },
      { "fieldPath": "createdAt", "order": "DESCENDING" }
    ]
  }]
}
```

### 3. Firebase Storage

Handle file uploads/downloads with proper security rules.

**Common Tasks:**
- Upload files with progress tracking
- Resize images client-side before upload
- Configure Storage security rules
- Download files or get public URLs
- List files in directories
- Handle CORS errors

**Reference File:** `references/storage.md`

**Key Patterns:**
```typescript
// Upload with progress
const { url, error } = await uploadWithProgress(
  file,
  `users/${userId}/photos/${filename}`,
  (progress) => setProgress(progress)
);

// Storage security rule
match /users/{userId}/{allPaths=**} {
  allow read, write: if request.auth != null
                     && request.auth.uid == userId
                     && request.resource.size < 5 * 1024 * 1024;
}
```

### 4. Cloud Functions v2

Create HTTP functions, callable functions, and Firestore triggers with proper CORS configuration.

**Common Tasks:**
- Create HTTP functions (onRequest) with CORS
- Implement callable functions (onCall) with auth validation
- Set up Firestore triggers (onCreate, onUpdate, onDelete)
- Configure environment variables and secrets
- Debug CORS errors (real vs false positives)
- Handle timeouts and cold starts

**Reference File:** `references/cloud-functions-v2.md`

**Key Patterns:**
```typescript
// HTTP function with CORS
export const api = onRequest(
  { cors: true, region: 'us-central1' },
  async (req, res) => {
    res.json({ message: 'Hello' });
  }
);

// Callable function with validation
export const sendMessage = onCall<SendMessageData>(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Login required');
    }
    // Process request
  }
);
```

### 5. Push Notifications (FCM)

Configure Firebase Cloud Messaging with VAPID keys, service workers, and troubleshoot common issues.

**Common Tasks:**
- Generate and configure VAPID keys
- Set up service worker for background notifications
- Request notification permissions
- Save FCM tokens to Firestore
- Send notifications via Cloud Functions
- Debug "token not generated" errors
- Fix "service worker not found" issues

**Reference File:** `references/push-notifications.md`

**Critical Setup Checklist:**
- [ ] VAPID key generated in Firebase Console
- [ ] VAPID key added to `.env`
- [ ] Service worker in `public/firebase-messaging-sw.js`
- [ ] Firebase config identical in app and service worker
- [ ] Service worker registered before requesting token
- [ ] Notification permission granted
- [ ] Token saved to Firestore
- [ ] Tested on HTTPS (or localhost for dev)

**Key Patterns:**
```typescript
// Request permission and get token
const token = await getToken(messaging, { vapidKey: VAPID_KEY });
if (token) {
  await saveTokenToFirestore(userId, token);
}

// Service worker (public/firebase-messaging-sw.js)
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({ /* config */ });
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  self.registration.showNotification(payload.notification.title, {
    body: payload.notification.body,
  });
});
```

### 6. Firebase Admin SDK

Initialize Firebase Admin SDK properly in Next.js for server-side operations.

**Common Tasks:**
- Initialize Admin SDK in API routes
- Set custom claims for role-based access
- Send notifications server-side
- Manage users (create, update, delete)
- Verify ID tokens
- Prevent duplicate initialization in dev (hot-reload)

**Reference File:** `references/firebase-admin-sdk.md`

**Key Patterns:**
```typescript
// Initialize Admin SDK (singleton pattern)
import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

if (!getApps().length) {
  initializeApp({
    credential: cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    }),
  });
}

// Set custom claims
await getAuth().setCustomUserClaims(userId, { admin: true });
```

### 7. Firebase App Check

Protect your Firebase resources from bots, scrapers, and abusive traffic with App Check.

**Common Tasks:**
- Configure reCAPTCHA Enterprise for web apps
- Set up App Check with Next.js 16 SSR/App Router
- Implement replay protection (limited-use tokens) for critical operations
- Verify App Check tokens in custom backends (Express, Fastify)
- Monitor App Check metrics and detect anomalies
- Configure enforcement in Firestore/Storage/Functions
- Handle App Check in development environments (debug tokens)

**Reference File:** `references/app-check.md`

**Key Patterns:**
```typescript
// Client-side initialization (Next.js 16 App Router)
'use client'
import { initializeAppCheck, ReCaptchaEnterpriseProvider } from 'firebase/app-check'

export function AppCheckProvider({ children }) {
  useEffect(() => {
    if (typeof window === 'undefined') return

    if (process.env.NODE_ENV === 'development') {
      self.FIREBASE_APPCHECK_DEBUG_TOKEN = process.env.NEXT_PUBLIC_APP_CHECK_DEBUG_TOKEN
    }

    initializeAppCheck(app, {
      provider: new ReCaptchaEnterpriseProvider(SITE_KEY),
      isTokenAutoRefreshEnabled: true, // CRITICAL
    })
  }, [])

  return <>{children}</>
}

// Standard tokens (reusable)
import { getToken } from 'firebase/app-check'
const token = await getToken(appCheck)

// Limited-use tokens (replay protection for payments/critical ops)
import { getLimitedUseToken } from 'firebase/app-check'
const limitedToken = await getLimitedUseToken(appCheck)

// Cloud Functions with replay protection
export const deleteAccount = onCall(
  {
    enforceAppCheck: true,
    consumeAppCheckToken: true, // Prevents replay attacks
  },
  async (request) => {
    if (!request.app) throw new Error('App Check required')
    // Token is consumed - cannot be reused
    return { success: true }
  }
)

// Firestore Security Rules with App Check
match /posts/{postId} {
  allow read: if request.auth != null && request.app != null;
  allow write: if request.auth != null && request.app != null;
}

// Admin SDK verification (custom backends)
import { getAppCheck } from 'firebase-admin/app-check'

const appCheckToken = req.header('X-Firebase-AppCheck')
try {
  const claims = await getAppCheck().verifyToken(appCheckToken)

  // Check for replay attacks
  if (claims.alreadyConsumed) {
    throw new Error('Token replay attack detected!')
  }

  console.log('App ID:', claims.app_id)
} catch (error) {
  // Invalid token
}
```

**Critical Setup Checklist:**
- [ ] reCAPTCHA Enterprise site key created in Google Cloud Console
- [ ] Secret key configured in Firebase Console > App Check
- [ ] App Check initialized in client code with `isTokenAutoRefreshEnabled: true`
- [ ] Debug tokens created for development environments
- [ ] Security Rules updated to check `request.app != null`
- [ ] Cloud Functions configured with `enforceAppCheck: true`
- [ ] Monitoring enabled in Firebase Console > App Check > Metrics

## Troubleshooting Common Issues

### Push Notifications Not Working

**Symptoms:** Token not generated, notifications not appearing, service worker errors

**Checklist:**
1. Verify VAPID key is correct in `.env`
2. Check service worker is at `/firebase-messaging-sw.js`
3. Ensure Firebase config is identical in app and SW
4. Confirm notification permission is granted
5. Test on HTTPS (or localhost)
6. Check browser console for errors
7. Verify domain is in "Authorized domains" (Firebase Console)

**Reference:** See detailed troubleshooting in `references/push-notifications.md`

### CORS Errors in Cloud Functions

**Key Point:** Most "CORS errors" are actually JavaScript errors in the function!

**Debug Steps:**
1. Open Firebase Console → Functions → Logs
2. Look for the REAL error (not CORS)
3. Fix the code error
4. If truly CORS: add `cors: true` to function config

**Reference:** See CORS configuration in `references/cloud-functions-v2.md`

### Firestore Permission Denied

**Common Causes:**
- User not authenticated
- Security rules too restrictive
- Wrong field names in rules
- Missing custom claims

**Debug:**
1. Firebase Console → Firestore → Rules
2. Use Rules Playground to test
3. Check `request.auth != null` is first condition
4. Verify field names match document structure

**Reference:** See security rules patterns in `references/firestore-security-rules.md`

### Duplicate Documents / Inconsistent Fields

**Common Issues:**
- Same user document duplicated with different IDs
- Fields like `isActive` and `active` both present
- Variable names in code don't match Firestore field names

**Solution:**
1. Check document creation code for multiple paths
2. Validate field names consistency
3. Add security rules to enforce schema
4. Use TypeScript interfaces for type safety

**Reference:** See validation patterns in `references/firestore-security-rules.md`

### App Check Not Working

**Symptoms:** "App Check token is invalid", high rejection rates, requests blocked

**Checklist:**
1. Verify reCAPTCHA Enterprise site key is correct
2. Check secret key matches in Firebase Console
3. Ensure domains are registered in reCAPTCHA Console
4. Confirm `isTokenAutoRefreshEnabled: true` is set
5. Use debug tokens for development environments
6. Check TTL configuration (recommended: 1 day)
7. Monitor metrics in Firebase Console > App Check

**Common Causes:**
- Token expired (TTL too short or auto-refresh disabled)
- Domain not allowed in reCAPTCHA settings
- Next.js SSR initialization issues (`typeof window === 'undefined'`)
- Debug token not registered in Firebase Console
- Threshold too high (blocking legitimate users)

**Reference:** See complete troubleshooting in `references/app-check.md`

### Firestore Query Performance Issues

**Symptoms:** Slow queries, high read costs, timeout errors

**Solutions:**
1. **Use aggregation queries instead of getDocs():**
   ```typescript
   // ❌ Expensive - reads every document
   const snapshot = await getDocs(collection(db, 'orders'))
   const total = snapshot.docs.reduce((sum, doc) => sum + doc.data().amount, 0)

   // ✅ Cost-efficient - uses index entries
   const snapshot = await getAggregateFromServer(
     collection(db, 'orders'),
     { total: sum('amount') }
   )
   ```

2. **Create composite indexes** for complex queries
3. **Use cursor-based pagination** (not offset)
4. **Enable offline persistence** for better UX
5. **Use Firestore Lite** for SSR to reduce bundle size

**Reference:** See performance optimization in `references/firestore-client.md`

## Best Practices

### TypeScript Type Safety

Always define interfaces for Firestore documents:

```typescript
interface User {
  uid: string;
  email: string;
  displayName: string;
  isActive: boolean;  // NOT 'active' - be consistent!
  createdAt: Date;
}
```

### Environment Variables

Use proper naming for Next.js:

```env
# Client-side (public)
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_PROJECT_ID=...
NEXT_PUBLIC_VAPID_KEY=...

# Server-side only (private)
FIREBASE_PRIVATE_KEY=...
FIREBASE_CLIENT_EMAIL=...
```

### Security First

- Always start security rules with "deny all"
- Validate data types and sizes
- Never trust client input
- Use custom claims for roles
- Test rules in playground before deploy

### Performance

**Firestore Optimization:**
- Use **aggregation queries** instead of getDocs() for counting/summing (saves ~99% of read costs)
- Create indexes for complex queries
- Use **cursor-based pagination** with `limit()` and `startAfter()` (NOT offset)
- Enable **offline persistence** with `persistentLocalCache()` for better UX
- Use **Firestore Lite** for SSR/Edge Functions (80% smaller bundle size)
- Implement proper caching strategies
- Denormalize data strategically to avoid multiple queries

**General Firebase:**
- Resize images before upload (client-side or Cloud Functions)
- Use Cloud Functions for heavy operations
- Batch writes when possible (up to 500 operations)
- Leverage real-time listeners instead of polling

### Security Layers

Firebase security works best with **multiple layers**:

```
┌────────────────────────────────┐
│   1. App Check (bot/device)    │  ← Validates app authenticity
├────────────────────────────────┤
│   2. Firebase Auth (user)      │  ← Validates user identity
├────────────────────────────────┤
│   3. Security Rules (data)     │  ← Validates permissions
├────────────────────────────────┤
│   4. Rate Limiting (abuse)     │  ← Prevents abuse
├────────────────────────────────┤
│   5. Cloud Armor (DDoS)        │  ← Infrastructure protection
└────────────────────────────────┘
```

**Implementation:**
```typescript
// Firestore Rules - ALL layers
match /users/{userId} {
  allow read, write: if request.auth != null        // Layer 2: Auth
                     && request.auth.uid == userId  // Layer 3: Authorization
                     && request.app != null;        // Layer 1: App Check
}

// Cloud Functions - Replay protection for critical ops
export const processPayment = onCall(
  {
    enforceAppCheck: true,        // Layer 1
    consumeAppCheckToken: true,   // Replay protection
  },
  async (request) => {
    if (!request.auth) throw new Error('Unauthorized') // Layer 2
    // Process payment...
  }
)
```

## Resources

### references/

The skill includes comprehensive reference documentation for each Firebase service:

- **authentication.md** - Email/password, Google Sign-In, custom action URLs
- **firestore-client.md** - Client SDK CRUD, queries, aggregations, vector search, real-time listeners, Firestore Lite
- **firestore-security-rules.md** - Security rules patterns, indexes, troubleshooting
- **cloud-functions-v2.md** - HTTP/callable functions, CORS, secrets, triggers
- **push-notifications.md** - FCM setup, VAPID, service workers, debugging
- **storage.md** - Upload/download, security rules, metadata
- **firebase-admin-sdk.md** - Admin SDK initialization, custom claims, Next.js integration
- **app-check.md** - Bot protection, reCAPTCHA Enterprise, replay protection, Next.js 16 SSR, monitoring

Load these references as needed when implementing specific features or debugging issues.

### Quick Reference: When to Use Which File

| Task | Reference File |
|------|---------------|
| Login/signup implementation | `authentication.md` |
| Custom domain for email links | `authentication.md` |
| CRUD operations in Firestore | `firestore-client.md` |
| Aggregation queries (count, sum, avg) | `firestore-client.md` |
| Vector search / AI embeddings | `firestore-client.md` |
| Real-time listeners / offline cache | `firestore-client.md` |
| Firestore Lite for SSR | `firestore-client.md` |
| Firestore security rules or indexes | `firestore-security-rules.md` |
| Permission denied errors | `firestore-security-rules.md` |
| File upload/download | `storage.md` |
| Cloud Function creation | `cloud-functions-v2.md` |
| CORS errors | `cloud-functions-v2.md` |
| Push notifications setup | `push-notifications.md` |
| VAPID configuration | `push-notifications.md` |
| Server-side operations | `firebase-admin-sdk.md` |
| Custom claims/roles | `firebase-admin-sdk.md` |
| Bot protection / App Check setup | `app-check.md` |
| reCAPTCHA Enterprise configuration | `app-check.md` |
| Replay protection (limited-use tokens) | `app-check.md` |
| App Check with Next.js 16 SSR | `app-check.md` |
| App Check monitoring and metrics | `app-check.md` |

## Integration with Other Skills

This Firebase skill works alongside:

- **firebase-genkit** - For AI-powered flows with Firebase Genkit
- **firebase-ai-logic** - For Gemini AI integration with Firebase AI Logic SDK
- **firebase-app-hosting** - For deploying Next.js apps on Firebase App Hosting
- **nextjs-firebase** - For Next.js 15 + Firebase integration patterns

When a task involves both Firebase services AND one of these specialized areas, use both skills together.
