---
name: oauth2-authentication
description: Comprehensive OAuth2 authentication skill covering authorization flows, token management, PKCE, OpenID Connect, and security best practices for modern authentication systems
---

# OAuth2 Authentication

A comprehensive skill for implementing secure authentication and authorization using OAuth2 and OpenID Connect. This skill covers all major authorization flows, token management strategies, security best practices, and real-world implementation patterns for web, mobile, and API applications.

## When to Use This Skill

Use this skill when:

- Implementing user authentication in web applications, SPAs, or mobile apps
- Building API authorization with access tokens and refresh tokens
- Integrating social login (Google, GitHub, Facebook, Twitter, etc.)
- Creating secure machine-to-machine (M2M) authentication
- Implementing single sign-on (SSO) across multiple applications
- Building an OAuth2 authorization server or identity provider
- Adding delegated authorization to allow third-party access
- Securing APIs with token-based authentication
- Implementing passwordless authentication flows
- Adding multi-tenant authentication with organization-specific rules
- Migrating from session-based to token-based authentication
- Implementing fine-grained access control with OAuth2 scopes

## Core Concepts

### OAuth2 Fundamentals

OAuth2 is an authorization framework that enables applications to obtain limited access to user accounts on an HTTP service. It works by delegating user authentication to the service that hosts the user account and authorizing third-party applications to access that account.

**Key Terminology:**

- **Resource Owner**: The user who owns the data or resources
- **Client**: The application requesting access to resources (web app, mobile app, SPA)
- **Authorization Server**: Issues access tokens after authenticating the resource owner
- **Resource Server**: Hosts protected resources, accepts and validates access tokens
- **Access Token**: Short-lived credential used to access protected resources
- **Refresh Token**: Long-lived credential used to obtain new access tokens
- **Scope**: Permission granted to access specific resources or perform actions
- **Authorization Code**: Temporary code exchanged for an access token
- **State Parameter**: Prevents CSRF attacks during authorization flow
- **Redirect URI**: Callback URL where the user is redirected after authorization

### OAuth2 Grant Types (Authorization Flows)

OAuth2 defines several grant types for different use cases:

#### 1. Authorization Code Flow

**Most Secure Flow - Recommended for Server-Side Applications**

The authorization code flow is the most secure and widely used OAuth2 flow. It involves exchanging an authorization code for an access token on the server side.

**Flow Steps:**
1. Client redirects user to authorization server with client_id, redirect_uri, scope, and state
2. User authenticates and consents to requested permissions
3. Authorization server redirects back to client with authorization code
4. Client exchanges code for access token using client secret (server-side)
5. Client uses access token to access protected resources

**When to Use:**
- Traditional server-side web applications
- Applications that can securely store client secrets
- When you need maximum security
- When refresh tokens are required

**Security Benefits:**
- Access token never exposed to browser
- Client authentication via client secret
- Authorization code is single-use and short-lived
- State parameter prevents CSRF attacks

#### 2. Authorization Code Flow with PKCE

**Secure Flow for Public Clients (SPAs and Mobile Apps)**

PKCE (Proof Key for Code Exchange, pronounced "pixy") is an extension to the authorization code flow designed for public clients that cannot securely store client secrets.

**Flow Steps:**
1. Client generates code_verifier (random string) and code_challenge (SHA256 hash)
2. Client redirects to authorization server with code_challenge
3. User authenticates and consents
4. Authorization server returns authorization code
5. Client exchanges code + code_verifier for access token
6. Server validates code_verifier matches code_challenge

**When to Use:**
- Single Page Applications (SPAs)
- Mobile applications (iOS, Android)
- Desktop applications
- Any public client that cannot store secrets

**Security Benefits:**
- Prevents authorization code interception attacks
- No client secret required
- Protects against malicious apps intercepting redirect
- Recommended by OAuth2 security best practices (RFC 8252)

#### 3. Client Credentials Flow

**Machine-to-Machine Authentication**

The client credentials flow is used when the client itself is the resource owner, typically for service-to-service communication.

**Flow Steps:**
1. Client authenticates with client_id and client_secret
2. Authorization server validates credentials
3. Authorization server issues access token
4. Client uses token to access protected resources

**When to Use:**
- Backend services communicating with APIs
- Cron jobs or scheduled tasks
- Microservices authentication
- CI/CD pipelines accessing APIs
- System-level operations without user context

**Characteristics:**
- No user involvement
- Client is the resource owner
- No refresh tokens (just request new access token)
- Typically long-lived or cached tokens

#### 4. Implicit Flow (Deprecated)

**Legacy Flow - No Longer Recommended**

The implicit flow returns tokens directly in the URL fragment without an authorization code exchange. This flow is now considered insecure and should be avoided.

**Why Deprecated:**
- Access tokens exposed in browser history
- No client authentication
- No refresh token support
- Vulnerable to token theft
- Use Authorization Code Flow with PKCE instead

#### 5. Resource Owner Password Credentials (ROPC)

**Legacy Flow - Avoid Unless Necessary**

The resource owner password credentials flow allows the client to collect username and password directly, then exchange them for tokens.

**Flow Steps:**
1. User provides username and password to client
2. Client sends credentials to authorization server
3. Authorization server validates and issues tokens

**When to Use (Rarely):**
- First-party mobile apps migrating from legacy authentication
- Trusted first-party applications only
- When no browser/redirect flow is possible

**Why to Avoid:**
- Client handles user credentials directly (security risk)
- No multi-factor authentication support
- Phishing vulnerability
- Violates OAuth2 principle of delegated authorization
- Use Authorization Code Flow with PKCE instead when possible

#### 6. Device Authorization Flow

**For Input-Constrained Devices**

The device flow is designed for devices with limited input capabilities (smart TVs, IoT devices, CLI tools).

**Flow Steps:**
1. Device requests device code and user code from authorization server
2. Device displays user code and instructs user to visit URL
3. User visits URL on another device and enters user code
4. User authenticates and authorizes device
5. Device polls authorization server for access token
6. Authorization server issues access token when user completes authorization

**When to Use:**
- Smart TVs and streaming devices
- IoT devices without keyboards
- CLI tools and command-line applications
- Gaming consoles
- Any device where typing is difficult

### Token Types and Management

#### Access Tokens

**Short-lived credentials for accessing protected resources**

**Characteristics:**
- Typically expire in 15 minutes to 1 hour
- Bearer token format: `Authorization: Bearer <access_token>`
- Can be opaque tokens or JWTs (JSON Web Tokens)
- Should be treated as sensitive credentials
- Never log or expose in URLs
- Validate on every API request

**JWT Structure (when using JWTs):**
```
Header.Payload.Signature
```

**JWT Payload Claims:**
- `sub`: Subject (user ID)
- `iat`: Issued at time
- `exp`: Expiration time
- `iss`: Issuer (authorization server)
- `aud`: Audience (resource server)
- `scope`: Granted permissions
- Custom claims (user metadata, roles, etc.)

**Token Validation:**
- Verify signature using public key
- Check expiration (exp claim)
- Verify issuer (iss claim)
- Validate audience (aud claim)
- Check token has required scopes

#### Refresh Tokens

**Long-lived credentials for obtaining new access tokens**

**Characteristics:**
- Typically expire in days, weeks, or months
- Single-use or reusable (depending on implementation)
- Must be stored securely (never in localStorage in browsers)
- Should be encrypted at rest
- Can be revoked by authorization server
- Subject to rotation policies

**Refresh Token Rotation:**
- Each refresh issues a new refresh token
- Old refresh token is invalidated
- Prevents token replay attacks
- Detects token theft (multiple refresh attempts)
- Recommended security practice

**Token Storage Best Practices:**

**Web Applications:**
- Access tokens: Memory (React context, Vuex, Redux)
- Refresh tokens: HttpOnly, Secure, SameSite cookies
- Alternative: Store refresh token on backend, use session

**Mobile Applications:**
- Use platform secure storage
- iOS: Keychain Services
- Android: EncryptedSharedPreferences or Keystore
- Never store in plaintext files

**SPAs:**
- Store access tokens in memory only
- Use BFF (Backend for Frontend) pattern for refresh tokens
- Consider Token Handler pattern
- Avoid localStorage (XSS vulnerability)

#### ID Tokens (OpenID Connect)

**Tokens containing user identity information**

**Characteristics:**
- Always JWT format
- Contains user profile information
- Used for authentication (not authorization)
- Returned alongside access tokens
- Should be validated before use

**Standard Claims:**
- `sub`: Subject (unique user ID)
- `name`: Full name
- `email`: Email address
- `email_verified`: Email verification status
- `picture`: Profile picture URL
- `iat`, `exp`: Issued/expiration times

### OAuth2 Scopes

**Fine-grained permissions for access control**

Scopes define what access the client is requesting and what the access token permits.

**Scope Naming Conventions:**
- `read:users` - Read user data
- `write:users` - Create/update users
- `delete:users` - Delete users
- `admin:all` - Full administrative access
- `openid` - Request OpenID Connect ID token
- `profile` - Access user profile information
- `email` - Access user email address

**Best Practices:**
- Request minimum required scopes (principle of least privilege)
- Separate read and write permissions
- Create resource-specific scopes
- Document all available scopes
- Allow users to see and understand requested permissions
- Implement scope-based access control in APIs

**Dynamic Scopes:**
```
read:organization:{org_id}
write:project:{project_id}
admin:tenant:{tenant_id}
```

### Security Considerations

#### State Parameter

**Prevents Cross-Site Request Forgery (CSRF)**

The state parameter is a random value that the client includes in the authorization request and validates in the callback.

**Implementation:**
1. Generate random state value (cryptographically secure)
2. Store state in session or encrypted cookie
3. Include state in authorization URL
4. Validate state matches when receiving callback
5. Reject mismatched or missing state

**Example State Value:**
```
state: crypto.randomBytes(32).toString('hex')
// "7f8a3d9e2b1c4f5a6d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0"
```

#### PKCE Implementation

**Proof Key for Code Exchange - Prevents Code Interception**

PKCE protects the authorization code flow against authorization code interception attacks.

**Code Verifier:**
- Random string, 43-128 characters
- Characters: A-Z, a-z, 0-9, -, ., _, ~
- Stored securely on client

**Code Challenge:**
- SHA256 hash of code verifier (recommended)
- Or plain code verifier (not recommended)
- Sent in authorization request

**Code Challenge Methods:**
- `S256`: SHA256 hash (use this)
- `plain`: Plaintext verifier (legacy only)

**Implementation Example:**
```javascript
// Generate code verifier
const codeVerifier = generateRandomString(64);

// Generate code challenge
const codeChallenge = base64UrlEncode(
  sha256(codeVerifier)
);

// Store code verifier for token exchange
sessionStorage.setItem('code_verifier', codeVerifier);

// Include in authorization URL
const authUrl = `${authEndpoint}?` +
  `client_id=${clientId}` +
  `&redirect_uri=${redirectUri}` +
  `&response_type=code` +
  `&scope=${scopes}` +
  `&state=${state}` +
  `&code_challenge=${codeChallenge}` +
  `&code_challenge_method=S256`;
```

#### Token Security

**Protecting Access and Refresh Tokens**

**Do:**
- Use HTTPS for all OAuth2 endpoints
- Store refresh tokens in secure storage only
- Implement token rotation
- Set appropriate token expiration times
- Validate tokens on every API request
- Use JWTs with strong signing algorithms (RS256, ES256)
- Implement token revocation
- Monitor for suspicious token usage

**Don't:**
- Store tokens in localStorage (XSS risk)
- Include tokens in URLs or query parameters
- Log tokens in application logs
- Use weak signing algorithms (HS256 with shared secrets)
- Share tokens between applications
- Extend access token lifetime unnecessarily
- Ignore token expiration

#### Redirect URI Validation

**Prevent Open Redirect Vulnerabilities**

**Strict Validation Rules:**
- Exact match required (no wildcards)
- Protocol must match exactly (https://)
- Host must match exactly
- Port must match (if specified)
- Path must match (if specified)
- Register all redirect URIs in advance

**Mobile Deep Links:**
- Use custom URL schemes: `com.example.app://callback`
- Or universal links (iOS): `https://example.com/auth/callback`
- Or app links (Android): `https://example.com/auth/callback`
- Register schemes with authorization server

**Localhost Development:**
- Allow http://localhost for development only
- Specify exact port: `http://localhost:3000/callback`
- Use 127.0.0.1 if localhost doesn't work
- Never use localhost redirects in production

### OpenID Connect (OIDC)

**Identity Layer Built on OAuth2**

OpenID Connect adds an identity layer on top of OAuth2, providing authentication in addition to authorization.

**Key Differences from OAuth2:**
- Returns ID token in addition to access token
- ID token contains user identity information
- Standardized user info endpoint
- Standardized discovery endpoint (.well-known/openid-configuration)
- Session management capabilities

**OIDC Flows:**

1. **Authorization Code Flow** (recommended)
   - Same as OAuth2 but returns id_token
   - Most secure for web apps

2. **Implicit Flow** (deprecated)
   - Returns id_token directly
   - Insecure, use Code Flow with PKCE instead

3. **Hybrid Flow**
   - Combines Code and Implicit flows
   - Complex, rarely needed

**OIDC Scopes:**
- `openid` (required) - Enables OIDC
- `profile` - Name, picture, locale, etc.
- `email` - Email address and verification status
- `address` - Physical address
- `phone` - Phone number

**UserInfo Endpoint:**
```
GET /userinfo
Authorization: Bearer <access_token>

Response:
{
  "sub": "248289761001",
  "name": "Jane Doe",
  "email": "jane@example.com",
  "email_verified": true,
  "picture": "https://example.com/photo.jpg"
}
```

**ID Token Validation:**
1. Verify signature using provider's public key
2. Validate issuer (iss claim)
3. Validate audience (aud claim - should match client_id)
4. Check expiration (exp claim)
5. Validate nonce (if provided in request)
6. Check token was issued recently (iat claim)

### Multi-Tenancy Patterns

**Organization-Specific Authentication**

Many SaaS applications require users to authenticate within the context of an organization or tenant.

**Patterns:**

1. **Organization Parameter**
   - Include organization ID in authorization request
   - `scope=openid profile organization:acme-corp`
   - Tokens scoped to specific organization

2. **Organization Selector**
   - User selects organization after initial auth
   - Exchange token for organization-specific token
   - Support switching organizations

3. **Custom Domain per Tenant**
   - `acme.example.com` vs `globex.example.com`
   - Separate OAuth2 configuration per tenant
   - White-label authentication experience

4. **Organization in Token Claims**
   - Include org_id in access token
   - API validates organization access
   - Support users in multiple organizations

## Authorization Code Flow Implementation

### Server-Side Web Application Flow

**Complete implementation for traditional web applications with backend**

#### Step 1: Configuration

```javascript
// OAuth2 Configuration
const oauth2Config = {
  clientId: process.env.OAUTH2_CLIENT_ID,
  clientSecret: process.env.OAUTH2_CLIENT_SECRET,
  authorizationEndpoint: 'https://auth.example.com/oauth/authorize',
  tokenEndpoint: 'https://auth.example.com/oauth/token',
  redirectUri: 'https://yourapp.com/auth/callback',
  scopes: ['openid', 'profile', 'email', 'read:data'],

  // Optional OIDC endpoints
  userInfoEndpoint: 'https://auth.example.com/oauth/userinfo',
  jwksUri: 'https://auth.example.com/.well-known/jwks.json',

  // Security settings
  useStateParameter: true,
  usePKCE: false, // Not needed for confidential clients
};
```

#### Step 2: Generate Authorization URL

```javascript
const crypto = require('crypto');

function generateAuthorizationUrl(req) {
  // Generate and store state for CSRF protection
  const state = crypto.randomBytes(32).toString('hex');
  req.session.oauth2State = state;

  // Build authorization URL
  const params = new URLSearchParams({
    client_id: oauth2Config.clientId,
    redirect_uri: oauth2Config.redirectUri,
    response_type: 'code',
    scope: oauth2Config.scopes.join(' '),
    state: state,
  });

  return `${oauth2Config.authorizationEndpoint}?${params.toString()}`;
}

// Express.js route
app.get('/auth/login', (req, res) => {
  const authUrl = generateAuthorizationUrl(req);
  res.redirect(authUrl);
});
```

#### Step 3: Handle Callback and Exchange Code

```javascript
const axios = require('axios');

async function exchangeCodeForToken(code) {
  const response = await axios.post(
    oauth2Config.tokenEndpoint,
    new URLSearchParams({
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: oauth2Config.redirectUri,
      client_id: oauth2Config.clientId,
      client_secret: oauth2Config.clientSecret,
    }),
    {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    }
  );

  return response.data;
  // Returns: { access_token, refresh_token, token_type, expires_in, id_token }
}

// Callback route
app.get('/auth/callback', async (req, res) => {
  const { code, state, error, error_description } = req.query;

  // Check for authorization errors
  if (error) {
    console.error('Authorization error:', error, error_description);
    return res.redirect('/auth/error?message=' + error_description);
  }

  // Validate state parameter (CSRF protection)
  if (state !== req.session.oauth2State) {
    console.error('State mismatch - possible CSRF attack');
    return res.status(403).send('Invalid state parameter');
  }

  // Clear state from session
  delete req.session.oauth2State;

  try {
    // Exchange authorization code for tokens
    const tokens = await exchangeCodeForToken(code);

    // Store tokens securely in session
    req.session.accessToken = tokens.access_token;
    req.session.refreshToken = tokens.refresh_token;
    req.session.tokenExpiry = Date.now() + (tokens.expires_in * 1000);

    // Optional: Fetch user info
    if (tokens.id_token) {
      const userInfo = await getUserInfo(tokens.access_token);
      req.session.user = userInfo;
    }

    // Redirect to application
    res.redirect('/dashboard');
  } catch (error) {
    console.error('Token exchange failed:', error);
    res.redirect('/auth/error?message=Authentication failed');
  }
});
```

#### Step 4: Use Access Token for API Requests

```javascript
// Middleware to check authentication
function requireAuth(req, res, next) {
  if (!req.session.accessToken) {
    return res.redirect('/auth/login');
  }

  // Check if token is expired
  if (Date.now() > req.session.tokenExpiry) {
    // Token expired, try to refresh
    return refreshAccessToken(req, res, next);
  }

  next();
}

// API request with access token
async function fetchUserData(accessToken) {
  const response = await axios.get('https://api.example.com/user/data', {
    headers: {
      'Authorization': `Bearer ${accessToken}`,
    },
  });

  return response.data;
}

// Protected route
app.get('/dashboard', requireAuth, async (req, res) => {
  try {
    const userData = await fetchUserData(req.session.accessToken);
    res.render('dashboard', { user: req.session.user, data: userData });
  } catch (error) {
    console.error('API request failed:', error);
    res.status(500).send('Failed to fetch data');
  }
});
```

#### Step 5: Implement Token Refresh

```javascript
async function refreshAccessToken(req, res, next) {
  if (!req.session.refreshToken) {
    // No refresh token, require re-authentication
    return res.redirect('/auth/login');
  }

  try {
    const response = await axios.post(
      oauth2Config.tokenEndpoint,
      new URLSearchParams({
        grant_type: 'refresh_token',
        refresh_token: req.session.refreshToken,
        client_id: oauth2Config.clientId,
        client_secret: oauth2Config.clientSecret,
      }),
      {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      }
    );

    // Update tokens in session
    req.session.accessToken = response.data.access_token;
    req.session.tokenExpiry = Date.now() + (response.data.expires_in * 1000);

    // Update refresh token if rotation is enabled
    if (response.data.refresh_token) {
      req.session.refreshToken = response.data.refresh_token;
    }

    next();
  } catch (error) {
    console.error('Token refresh failed:', error);
    // Refresh failed, require re-authentication
    delete req.session.accessToken;
    delete req.session.refreshToken;
    res.redirect('/auth/login');
  }
}
```

#### Step 6: Implement Logout

```javascript
app.post('/auth/logout', async (req, res) => {
  // Optional: Revoke tokens on authorization server
  if (req.session.accessToken) {
    try {
      await revokeToken(req.session.accessToken);
    } catch (error) {
      console.error('Token revocation failed:', error);
    }
  }

  // Clear session
  req.session.destroy((err) => {
    if (err) {
      console.error('Session destruction failed:', err);
    }
    res.redirect('/');
  });
});

async function revokeToken(token) {
  await axios.post(
    'https://auth.example.com/oauth/revoke',
    new URLSearchParams({
      token: token,
      client_id: oauth2Config.clientId,
      client_secret: oauth2Config.clientSecret,
    }),
    {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    }
  );
}
```

## PKCE Implementation (SPAs and Mobile Apps)

### Single Page Application (React)

**Complete OAuth2 with PKCE implementation for React SPAs**

#### Setup and Configuration

```javascript
// src/config/oauth2.js
export const oauth2Config = {
  clientId: process.env.REACT_APP_OAUTH2_CLIENT_ID,
  authorizationEndpoint: 'https://auth.example.com/oauth/authorize',
  tokenEndpoint: 'https://auth.example.com/oauth/token',
  redirectUri: window.location.origin + '/auth/callback',
  scopes: ['openid', 'profile', 'email', 'read:data'],
  audience: 'https://api.example.com',
};

// PKCE utility functions
export function generateRandomString(length) {
  const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  const values = crypto.getRandomValues(new Uint8Array(length));
  return Array.from(values)
    .map(v => charset[v % charset.length])
    .join('');
}

export async function generateCodeChallenge(codeVerifier) {
  const encoder = new TextEncoder();
  const data = encoder.encode(codeVerifier);
  const digest = await crypto.subtle.digest('SHA-256', data);
  return base64UrlEncode(digest);
}

export function base64UrlEncode(buffer) {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary)
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}
```

#### Auth Context Provider

```javascript
// src/contexts/AuthContext.js
import React, { createContext, useState, useContext, useEffect } from 'react';
import { oauth2Config, generateRandomString, generateCodeChallenge } from '../config/oauth2';

const AuthContext = createContext();

export function useAuth() {
  return useContext(AuthContext);
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [accessToken, setAccessToken] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check for existing session
    checkAuth();
  }, []);

  async function checkAuth() {
    // Try to restore access token from memory or refresh
    const storedToken = sessionStorage.getItem('access_token');
    const expiresAt = sessionStorage.getItem('expires_at');

    if (storedToken && expiresAt && Date.now() < parseInt(expiresAt)) {
      setAccessToken(storedToken);
      await fetchUserInfo(storedToken);
    } else {
      // Token expired or doesn't exist, try refresh
      await tryRefresh();
    }

    setLoading(false);
  }

  async function login() {
    // Generate PKCE parameters
    const codeVerifier = generateRandomString(64);
    const codeChallenge = await generateCodeChallenge(codeVerifier);
    const state = generateRandomString(32);

    // Store for callback
    sessionStorage.setItem('code_verifier', codeVerifier);
    sessionStorage.setItem('oauth2_state', state);

    // Build authorization URL
    const params = new URLSearchParams({
      client_id: oauth2Config.clientId,
      redirect_uri: oauth2Config.redirectUri,
      response_type: 'code',
      scope: oauth2Config.scopes.join(' '),
      state: state,
      code_challenge: codeChallenge,
      code_challenge_method: 'S256',
    });

    // Redirect to authorization server
    window.location.href = `${oauth2Config.authorizationEndpoint}?${params}`;
  }

  async function handleCallback(code, state) {
    // Validate state
    const savedState = sessionStorage.getItem('oauth2_state');
    if (state !== savedState) {
      throw new Error('Invalid state parameter - possible CSRF attack');
    }

    // Get code verifier
    const codeVerifier = sessionStorage.getItem('code_verifier');
    if (!codeVerifier) {
      throw new Error('Code verifier not found');
    }

    // Exchange code for tokens
    const response = await fetch(oauth2Config.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: oauth2Config.redirectUri,
        client_id: oauth2Config.clientId,
        code_verifier: codeVerifier,
      }),
    });

    if (!response.ok) {
      throw new Error('Token exchange failed');
    }

    const tokens = await response.json();

    // Store tokens
    setAccessToken(tokens.access_token);
    sessionStorage.setItem('access_token', tokens.access_token);
    sessionStorage.setItem('expires_at', Date.now() + (tokens.expires_in * 1000));

    // Store refresh token in httpOnly cookie via backend
    if (tokens.refresh_token) {
      await storeRefreshToken(tokens.refresh_token);
    }

    // Fetch user info
    await fetchUserInfo(tokens.access_token);

    // Clean up
    sessionStorage.removeItem('code_verifier');
    sessionStorage.removeItem('oauth2_state');
  }

  async function fetchUserInfo(token) {
    const response = await fetch('https://auth.example.com/oauth/userinfo', {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });

    if (response.ok) {
      const userInfo = await response.json();
      setUser(userInfo);
    }
  }

  async function storeRefreshToken(refreshToken) {
    // Store refresh token via backend (httpOnly cookie)
    await fetch('/api/auth/store-refresh-token', {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ refreshToken }),
    });
  }

  async function tryRefresh() {
    try {
      // Call backend to refresh using httpOnly cookie
      const response = await fetch('/api/auth/refresh', {
        method: 'POST',
        credentials: 'include',
      });

      if (response.ok) {
        const tokens = await response.json();
        setAccessToken(tokens.access_token);
        sessionStorage.setItem('access_token', tokens.access_token);
        sessionStorage.setItem('expires_at', Date.now() + (tokens.expires_in * 1000));
        await fetchUserInfo(tokens.access_token);
        return true;
      }
    } catch (error) {
      console.error('Token refresh failed:', error);
    }
    return false;
  }

  async function logout() {
    // Revoke tokens
    await fetch('/api/auth/logout', {
      method: 'POST',
      credentials: 'include',
    });

    // Clear state
    setUser(null);
    setAccessToken(null);
    sessionStorage.clear();
  }

  const value = {
    user,
    accessToken,
    loading,
    login,
    logout,
    handleCallback,
    isAuthenticated: !!accessToken,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
```

#### Callback Component

```javascript
// src/components/AuthCallback.js
import React, { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

export function AuthCallback() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { handleCallback } = useAuth();
  const [error, setError] = useState(null);

  useEffect(() => {
    const code = searchParams.get('code');
    const state = searchParams.get('state');
    const errorParam = searchParams.get('error');
    const errorDescription = searchParams.get('error_description');

    if (errorParam) {
      setError(errorDescription || errorParam);
      return;
    }

    if (code && state) {
      handleCallback(code, state)
        .then(() => {
          navigate('/dashboard');
        })
        .catch((err) => {
          console.error('Authentication failed:', err);
          setError(err.message);
        });
    } else {
      setError('Missing authorization code or state');
    }
  }, [searchParams, handleCallback, navigate]);

  if (error) {
    return (
      <div className="auth-error">
        <h2>Authentication Failed</h2>
        <p>{error}</p>
        <button onClick={() => navigate('/')}>Return Home</button>
      </div>
    );
  }

  return (
    <div className="auth-loading">
      <h2>Completing authentication...</h2>
      <div className="spinner"></div>
    </div>
  );
}
```

#### Protected Route Component

```javascript
// src/components/ProtectedRoute.js
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

export function ProtectedRoute({ children }) {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }

  return children;
}
```

#### API Client with Token Management

```javascript
// src/utils/apiClient.js
import { oauth2Config } from '../config/oauth2';

class ApiClient {
  constructor() {
    this.baseUrl = 'https://api.example.com';
  }

  async request(endpoint, options = {}) {
    const accessToken = sessionStorage.getItem('access_token');
    const expiresAt = sessionStorage.getItem('expires_at');

    // Check if token needs refresh
    if (!accessToken || Date.now() >= parseInt(expiresAt)) {
      await this.refreshToken();
    }

    const token = sessionStorage.getItem('access_token');

    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    });

    if (response.status === 401) {
      // Token invalid, try refresh once
      await this.refreshToken();
      const newToken = sessionStorage.getItem('access_token');

      // Retry request
      const retryResponse = await fetch(`${this.baseUrl}${endpoint}`, {
        ...options,
        headers: {
          ...options.headers,
          'Authorization': `Bearer ${newToken}`,
          'Content-Type': 'application/json',
        },
      });

      if (!retryResponse.ok) {
        throw new Error('API request failed after token refresh');
      }

      return retryResponse.json();
    }

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    return response.json();
  }

  async refreshToken() {
    const response = await fetch('/api/auth/refresh', {
      method: 'POST',
      credentials: 'include',
    });

    if (!response.ok) {
      // Refresh failed, redirect to login
      window.location.href = '/login';
      throw new Error('Token refresh failed');
    }

    const tokens = await response.json();
    sessionStorage.setItem('access_token', tokens.access_token);
    sessionStorage.setItem('expires_at', Date.now() + (tokens.expires_in * 1000));
  }

  async get(endpoint) {
    return this.request(endpoint);
  }

  async post(endpoint, data) {
    return this.request(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async put(endpoint, data) {
    return this.request(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async delete(endpoint) {
    return this.request(endpoint, {
      method: 'DELETE',
    });
  }
}

export const apiClient = new ApiClient();
```

## Client Credentials Flow

### Backend Service Authentication

**Machine-to-machine authentication for services and APIs**

#### Node.js Implementation

```javascript
// Service-to-service authentication
class OAuth2Client {
  constructor(config) {
    this.clientId = config.clientId;
    this.clientSecret = config.clientSecret;
    this.tokenEndpoint = config.tokenEndpoint;
    this.audience = config.audience;
    this.scopes = config.scopes || [];

    this.accessToken = null;
    this.tokenExpiry = null;
  }

  async getAccessToken() {
    // Return cached token if still valid
    if (this.accessToken && Date.now() < this.tokenExpiry - 60000) {
      return this.accessToken;
    }

    // Request new token
    const response = await fetch(this.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'client_credentials',
        client_id: this.clientId,
        client_secret: this.clientSecret,
        audience: this.audience,
        scope: this.scopes.join(' '),
      }),
    });

    if (!response.ok) {
      throw new Error('Failed to obtain access token');
    }

    const data = await response.json();

    // Cache token
    this.accessToken = data.access_token;
    this.tokenExpiry = Date.now() + (data.expires_in * 1000);

    return this.accessToken;
  }

  async callApi(endpoint, options = {}) {
    const token = await this.getAccessToken();

    const response = await fetch(endpoint, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`,
      },
    });

    if (response.status === 401) {
      // Token might be invalid, force refresh and retry
      this.accessToken = null;
      const newToken = await this.getAccessToken();

      const retryResponse = await fetch(endpoint, {
        ...options,
        headers: {
          ...options.headers,
          'Authorization': `Bearer ${newToken}`,
        },
      });

      return retryResponse;
    }

    return response;
  }
}

// Usage
const oauth2Client = new OAuth2Client({
  clientId: process.env.CLIENT_ID,
  clientSecret: process.env.CLIENT_SECRET,
  tokenEndpoint: 'https://auth.example.com/oauth/token',
  audience: 'https://api.example.com',
  scopes: ['read:data', 'write:data'],
});

// Make API calls
async function fetchData() {
  const response = await oauth2Client.callApi('https://api.example.com/data');
  return response.json();
}
```

#### Python Implementation

```python
# client_credentials_oauth2.py
import requests
import time
from datetime import datetime, timedelta

class OAuth2Client:
    def __init__(self, client_id, client_secret, token_endpoint, audience=None, scopes=None):
        self.client_id = client_id
        self.client_secret = client_secret
        self.token_endpoint = token_endpoint
        self.audience = audience
        self.scopes = scopes or []

        self.access_token = None
        self.token_expiry = None

    def get_access_token(self):
        """Get cached token or request new one"""
        # Return cached token if valid
        if self.access_token and datetime.now() < self.token_expiry - timedelta(minutes=1):
            return self.access_token

        # Request new token
        data = {
            'grant_type': 'client_credentials',
            'client_id': self.client_id,
            'client_secret': self.client_secret,
        }

        if self.audience:
            data['audience'] = self.audience

        if self.scopes:
            data['scope'] = ' '.join(self.scopes)

        response = requests.post(
            self.token_endpoint,
            data=data,
            headers={'Content-Type': 'application/x-www-form-urlencoded'}
        )

        if not response.ok:
            raise Exception(f'Failed to obtain access token: {response.text}')

        token_data = response.json()

        # Cache token
        self.access_token = token_data['access_token']
        self.token_expiry = datetime.now() + timedelta(seconds=token_data['expires_in'])

        return self.access_token

    def call_api(self, url, method='GET', **kwargs):
        """Make authenticated API request"""
        token = self.get_access_token()

        headers = kwargs.pop('headers', {})
        headers['Authorization'] = f'Bearer {token}'

        response = requests.request(method, url, headers=headers, **kwargs)

        # Handle token expiration
        if response.status_code == 401:
            # Force token refresh and retry
            self.access_token = None
            token = self.get_access_token()
            headers['Authorization'] = f'Bearer {token}'
            response = requests.request(method, url, headers=headers, **kwargs)

        return response

# Usage
client = OAuth2Client(
    client_id='your_client_id',
    client_secret='your_client_secret',
    token_endpoint='https://auth.example.com/oauth/token',
    audience='https://api.example.com',
    scopes=['read:data', 'write:data']
)

# Make API requests
response = client.call_api('https://api.example.com/data')
data = response.json()
```

## OpenID Connect Implementation

### Complete OIDC Integration

**Authentication with identity verification**

#### ID Token Validation

```javascript
// id-token-validator.js
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

class IDTokenValidator {
  constructor(config) {
    this.issuer = config.issuer;
    this.audience = config.audience;
    this.jwksUri = config.jwksUri;

    // JWKS client for fetching public keys
    this.client = jwksClient({
      jwksUri: this.jwksUri,
      cache: true,
      cacheMaxAge: 86400000, // 24 hours
    });
  }

  async getSigningKey(kid) {
    const key = await this.client.getSigningKey(kid);
    return key.getPublicKey();
  }

  async validate(idToken) {
    try {
      // Decode token header to get key ID
      const decoded = jwt.decode(idToken, { complete: true });

      if (!decoded) {
        throw new Error('Invalid token format');
      }

      // Get public key
      const publicKey = await this.getSigningKey(decoded.header.kid);

      // Verify and decode token
      const payload = jwt.verify(idToken, publicKey, {
        issuer: this.issuer,
        audience: this.audience,
        algorithms: ['RS256', 'ES256'],
      });

      // Additional validations
      this.validateClaims(payload);

      return payload;
    } catch (error) {
      throw new Error(`ID token validation failed: ${error.message}`);
    }
  }

  validateClaims(payload) {
    // Check required claims
    if (!payload.sub) {
      throw new Error('Missing sub claim');
    }

    if (!payload.iat || !payload.exp) {
      throw new Error('Missing iat or exp claim');
    }

    // Check token is not expired (already checked by jwt.verify, but double-check)
    const now = Math.floor(Date.now() / 1000);
    if (payload.exp < now) {
      throw new Error('Token expired');
    }

    // Check token was not issued in the future
    if (payload.iat > now + 60) {
      throw new Error('Token issued in the future');
    }

    // Optional: Check nonce if provided
    // if (payload.nonce && payload.nonce !== expectedNonce) {
    //   throw new Error('Nonce mismatch');
    // }

    return true;
  }
}

// Usage
const validator = new IDTokenValidator({
  issuer: 'https://auth.example.com',
  audience: 'your_client_id',
  jwksUri: 'https://auth.example.com/.well-known/jwks.json',
});

async function validateIDToken(idToken) {
  try {
    const payload = await validator.validate(idToken);
    console.log('User ID:', payload.sub);
    console.log('Email:', payload.email);
    console.log('Name:', payload.name);
    return payload;
  } catch (error) {
    console.error('ID token validation failed:', error);
    throw error;
  }
}
```

#### UserInfo Endpoint Integration

```javascript
// userinfo-client.js
class UserInfoClient {
  constructor(userInfoEndpoint) {
    this.endpoint = userInfoEndpoint;
  }

  async getUserInfo(accessToken) {
    const response = await fetch(this.endpoint, {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Accept': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`UserInfo request failed: ${response.status}`);
    }

    return response.json();
  }

  async getUserInfoWithValidation(accessToken, idTokenPayload) {
    const userInfo = await this.getUserInfo(accessToken);

    // Validate that sub matches ID token
    if (userInfo.sub !== idTokenPayload.sub) {
      throw new Error('UserInfo sub does not match ID token sub');
    }

    return userInfo;
  }
}

// Usage
const userInfoClient = new UserInfoClient('https://auth.example.com/oauth/userinfo');

async function getCompleteUserProfile(accessToken, idToken, validator) {
  // Validate ID token
  const idTokenPayload = await validator.validate(idToken);

  // Fetch additional user info
  const userInfo = await userInfoClient.getUserInfoWithValidation(accessToken, idTokenPayload);

  // Combine information
  return {
    userId: userInfo.sub,
    email: userInfo.email,
    emailVerified: userInfo.email_verified,
    name: userInfo.name,
    givenName: userInfo.given_name,
    familyName: userInfo.family_name,
    picture: userInfo.picture,
    locale: userInfo.locale,
    // Any custom claims
    ...userInfo,
  };
}
```

## Token Management Best Practices

### Secure Token Storage

#### Browser Storage Comparison

```javascript
// Token storage strategies for web applications

// ❌ BAD: localStorage (vulnerable to XSS)
localStorage.setItem('access_token', token); // DON'T DO THIS

// ❌ BAD: sessionStorage (also vulnerable to XSS)
sessionStorage.setItem('access_token', token); // DON'T DO THIS

// ✅ GOOD: In-memory storage (cleared on page refresh)
class TokenStore {
  constructor() {
    this.accessToken = null;
    this.refreshToken = null;
  }

  setTokens(accessToken, refreshToken) {
    this.accessToken = accessToken;
    // Refresh token stored in httpOnly cookie via backend
    // this.refreshToken = refreshToken; // Don't store in memory
  }

  getAccessToken() {
    return this.accessToken;
  }

  clear() {
    this.accessToken = null;
    this.refreshToken = null;
  }
}

// ✅ BEST: Backend For Frontend (BFF) Pattern
// - All tokens stored on backend
// - Session cookie identifies user
// - No tokens exposed to browser
```

#### Mobile Token Storage (React Native)

```javascript
// Secure token storage for React Native
import * as SecureStore from 'expo-secure-store';
// or
// import EncryptedStorage from 'react-native-encrypted-storage';

class MobileTokenStore {
  async saveTokens(accessToken, refreshToken) {
    try {
      await SecureStore.setItemAsync('access_token', accessToken);
      await SecureStore.setItemAsync('refresh_token', refreshToken);
      await SecureStore.setItemAsync('token_expiry', Date.now().toString());
    } catch (error) {
      console.error('Failed to store tokens:', error);
      throw error;
    }
  }

  async getAccessToken() {
    try {
      return await SecureStore.getItemAsync('access_token');
    } catch (error) {
      console.error('Failed to retrieve access token:', error);
      return null;
    }
  }

  async getRefreshToken() {
    try {
      return await SecureStore.getItemAsync('refresh_token');
    } catch (error) {
      console.error('Failed to retrieve refresh token:', error);
      return null;
    }
  }

  async clear() {
    try {
      await SecureStore.deleteItemAsync('access_token');
      await SecureStore.deleteItemAsync('refresh_token');
      await SecureStore.deleteItemAsync('token_expiry');
    } catch (error) {
      console.error('Failed to clear tokens:', error);
    }
  }

  async isTokenExpired() {
    try {
      const expiry = await SecureStore.getItemAsync('token_expiry');
      if (!expiry) return true;
      return Date.now() > parseInt(expiry);
    } catch (error) {
      return true;
    }
  }
}

export const tokenStore = new MobileTokenStore();
```

### Token Refresh Strategies

#### Automatic Token Refresh (Proactive)

```javascript
// Proactive token refresh before expiration
class TokenRefreshManager {
  constructor(refreshCallback, expiresIn) {
    this.refreshCallback = refreshCallback;
    this.expiresIn = expiresIn;
    this.refreshTimer = null;
  }

  scheduleRefresh() {
    // Refresh 5 minutes before expiration
    const refreshIn = (this.expiresIn - 300) * 1000;

    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer);
    }

    this.refreshTimer = setTimeout(async () => {
      try {
        await this.refreshCallback();
      } catch (error) {
        console.error('Token refresh failed:', error);
        // Optionally: Redirect to login
      }
    }, refreshIn);
  }

  cancelRefresh() {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer);
      this.refreshTimer = null;
    }
  }
}

// Usage
const refreshManager = new TokenRefreshManager(
  async () => {
    // Refresh token logic
    const newTokens = await refreshTokens();
    setAccessToken(newTokens.access_token);
    refreshManager.expiresIn = newTokens.expires_in;
    refreshManager.scheduleRefresh();
  },
  3600 // Initial expires_in
);

// Start automatic refresh
refreshManager.scheduleRefresh();
```

#### On-Demand Token Refresh (Reactive)

```javascript
// Refresh token only when access token is expired
class ReactiveTokenManager {
  constructor() {
    this.accessToken = null;
    this.expiresAt = null;
    this.refreshPromise = null; // Prevent concurrent refreshes
  }

  async getValidToken() {
    // Check if token is still valid
    if (this.accessToken && Date.now() < this.expiresAt - 60000) {
      return this.accessToken;
    }

    // Token expired, refresh it
    if (!this.refreshPromise) {
      this.refreshPromise = this.refreshToken()
        .finally(() => {
          this.refreshPromise = null;
        });
    }

    await this.refreshPromise;
    return this.accessToken;
  }

  async refreshToken() {
    const response = await fetch('/api/auth/refresh', {
      method: 'POST',
      credentials: 'include', // Send refresh token cookie
    });

    if (!response.ok) {
      throw new Error('Token refresh failed');
    }

    const tokens = await response.json();
    this.accessToken = tokens.access_token;
    this.expiresAt = Date.now() + (tokens.expires_in * 1000);

    return this.accessToken;
  }

  clearTokens() {
    this.accessToken = null;
    this.expiresAt = null;
    this.refreshPromise = null;
  }
}

// Usage in API client
const tokenManager = new ReactiveTokenManager();

async function makeApiRequest(endpoint) {
  const token = await tokenManager.getValidToken();

  const response = await fetch(endpoint, {
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });

  return response;
}
```

### Token Revocation

```javascript
// Implementing token revocation
async function revokeToken(token, tokenTypeHint = 'access_token') {
  const response = await fetch('https://auth.example.com/oauth/revoke', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      token: token,
      token_type_hint: tokenTypeHint, // 'access_token' or 'refresh_token'
      client_id: oauth2Config.clientId,
      client_secret: oauth2Config.clientSecret, // If confidential client
    }),
  });

  if (!response.ok) {
    throw new Error('Token revocation failed');
  }

  return true;
}

// Logout with token revocation
async function logout() {
  try {
    // Revoke access token
    if (accessToken) {
      await revokeToken(accessToken, 'access_token');
    }

    // Revoke refresh token
    if (refreshToken) {
      await revokeToken(refreshToken, 'refresh_token');
    }

    // Clear local state
    clearTokens();

    // Optional: Redirect to logout endpoint for session cleanup
    window.location.href = 'https://auth.example.com/logout?redirect_uri=' +
      encodeURIComponent(window.location.origin);
  } catch (error) {
    console.error('Logout failed:', error);
    // Clear tokens anyway
    clearTokens();
  }
}
```

## OAuth2 Server Implementation

### Building an Authorization Server

**Implementing OAuth2 provider functionality**

#### Authorization Endpoint

```javascript
// Express.js authorization endpoint
const express = require('express');
const crypto = require('crypto');

const router = express.Router();

router.get('/oauth/authorize', async (req, res) => {
  const {
    client_id,
    redirect_uri,
    response_type,
    scope,
    state,
    code_challenge,
    code_challenge_method,
  } = req.query;

  // Validate required parameters
  if (!client_id || !redirect_uri || !response_type) {
    return res.status(400).json({
      error: 'invalid_request',
      error_description: 'Missing required parameters',
    });
  }

  // Validate client_id and redirect_uri
  const client = await getClient(client_id);
  if (!client) {
    return res.status(400).json({
      error: 'invalid_client',
      error_description: 'Unknown client',
    });
  }

  if (!client.redirect_uris.includes(redirect_uri)) {
    return res.status(400).json({
      error: 'invalid_request',
      error_description: 'Invalid redirect_uri',
    });
  }

  // Validate response_type
  if (response_type !== 'code') {
    return redirectWithError(redirect_uri, state, 'unsupported_response_type',
      'Only authorization code flow is supported');
  }

  // Validate PKCE parameters
  if (code_challenge) {
    if (!code_challenge_method) {
      return redirectWithError(redirect_uri, state, 'invalid_request',
        'code_challenge_method is required when using PKCE');
    }
    if (code_challenge_method !== 'S256' && code_challenge_method !== 'plain') {
      return redirectWithError(redirect_uri, state, 'invalid_request',
        'Unsupported code_challenge_method');
    }
  }

  // Check if user is authenticated
  if (!req.session.userId) {
    // Store authorization request and redirect to login
    req.session.authRequest = {
      client_id,
      redirect_uri,
      scope,
      state,
      code_challenge,
      code_challenge_method,
    };
    return res.redirect('/login?continue=' + encodeURIComponent(req.originalUrl));
  }

  // User is authenticated, show consent screen
  res.render('consent', {
    client: client,
    scopes: scope ? scope.split(' ') : [],
    state: state,
  });
});

// Consent endpoint
router.post('/oauth/consent', async (req, res) => {
  const { approved } = req.body;
  const authRequest = req.session.authRequest;

  if (!authRequest) {
    return res.status(400).send('No pending authorization request');
  }

  if (approved !== 'true') {
    // User denied consent
    return redirectWithError(
      authRequest.redirect_uri,
      authRequest.state,
      'access_denied',
      'User denied consent'
    );
  }

  // Generate authorization code
  const authorizationCode = crypto.randomBytes(32).toString('hex');

  // Store authorization code with metadata
  await storeAuthorizationCode(authorizationCode, {
    client_id: authRequest.client_id,
    redirect_uri: authRequest.redirect_uri,
    user_id: req.session.userId,
    scope: authRequest.scope,
    code_challenge: authRequest.code_challenge,
    code_challenge_method: authRequest.code_challenge_method,
    expires_at: Date.now() + 600000, // 10 minutes
  });

  // Clear auth request from session
  delete req.session.authRequest;

  // Redirect to client with authorization code
  const redirectUrl = new URL(authRequest.redirect_uri);
  redirectUrl.searchParams.set('code', authorizationCode);
  if (authRequest.state) {
    redirectUrl.searchParams.set('state', authRequest.state);
  }

  res.redirect(redirectUrl.toString());
});

function redirectWithError(redirectUri, state, error, errorDescription) {
  const url = new URL(redirectUri);
  url.searchParams.set('error', error);
  url.searchParams.set('error_description', errorDescription);
  if (state) {
    url.searchParams.set('state', state);
  }
  return res.redirect(url.toString());
}
```

#### Token Endpoint

```javascript
// Token endpoint implementation
router.post('/oauth/token', async (req, res) => {
  const { grant_type } = req.body;

  try {
    let tokens;

    switch (grant_type) {
      case 'authorization_code':
        tokens = await handleAuthorizationCodeGrant(req.body);
        break;
      case 'refresh_token':
        tokens = await handleRefreshTokenGrant(req.body);
        break;
      case 'client_credentials':
        tokens = await handleClientCredentialsGrant(req.body);
        break;
      default:
        return res.status(400).json({
          error: 'unsupported_grant_type',
          error_description: `Grant type '${grant_type}' is not supported`,
        });
    }

    res.json(tokens);
  } catch (error) {
    console.error('Token endpoint error:', error);
    res.status(400).json({
      error: error.code || 'invalid_request',
      error_description: error.message,
    });
  }
});

async function handleAuthorizationCodeGrant(params) {
  const {
    code,
    redirect_uri,
    client_id,
    client_secret,
    code_verifier,
  } = params;

  // Validate required parameters
  if (!code || !redirect_uri || !client_id) {
    throw { code: 'invalid_request', message: 'Missing required parameters' };
  }

  // Retrieve authorization code
  const authCode = await getAuthorizationCode(code);
  if (!authCode) {
    throw { code: 'invalid_grant', message: 'Invalid authorization code' };
  }

  // Check expiration
  if (Date.now() > authCode.expires_at) {
    await deleteAuthorizationCode(code);
    throw { code: 'invalid_grant', message: 'Authorization code expired' };
  }

  // Validate client
  if (authCode.client_id !== client_id) {
    throw { code: 'invalid_grant', message: 'Client mismatch' };
  }

  // Validate redirect URI
  if (authCode.redirect_uri !== redirect_uri) {
    throw { code: 'invalid_grant', message: 'Redirect URI mismatch' };
  }

  // Authenticate client
  const client = await getClient(client_id);
  if (client.client_type === 'confidential') {
    // Confidential client must provide client_secret
    if (client.client_secret !== client_secret) {
      throw { code: 'invalid_client', message: 'Invalid client credentials' };
    }
  }

  // Validate PKCE if used
  if (authCode.code_challenge) {
    if (!code_verifier) {
      throw { code: 'invalid_request', message: 'code_verifier is required' };
    }

    const isValid = validatePKCE(
      code_verifier,
      authCode.code_challenge,
      authCode.code_challenge_method
    );

    if (!isValid) {
      throw { code: 'invalid_grant', message: 'Invalid code_verifier' };
    }
  }

  // Delete authorization code (single use)
  await deleteAuthorizationCode(code);

  // Generate tokens
  const accessToken = await generateAccessToken({
    user_id: authCode.user_id,
    client_id: client_id,
    scope: authCode.scope,
  });

  const refreshToken = await generateRefreshToken({
    user_id: authCode.user_id,
    client_id: client_id,
    scope: authCode.scope,
  });

  // Generate ID token if openid scope was requested
  let idToken = null;
  if (authCode.scope && authCode.scope.includes('openid')) {
    idToken = await generateIDToken({
      user_id: authCode.user_id,
      client_id: client_id,
      scope: authCode.scope,
    });
  }

  const response = {
    access_token: accessToken,
    token_type: 'Bearer',
    expires_in: 3600,
    refresh_token: refreshToken,
  };

  if (idToken) {
    response.id_token = idToken;
  }

  return response;
}

function validatePKCE(codeVerifier, codeChallenge, method) {
  if (method === 'plain') {
    return codeVerifier === codeChallenge;
  }

  if (method === 'S256') {
    const hash = crypto.createHash('sha256').update(codeVerifier).digest();
    const computed = base64UrlEncode(hash);
    return computed === codeChallenge;
  }

  return false;
}

async function handleRefreshTokenGrant(params) {
  const { refresh_token, client_id, client_secret, scope } = params;

  // Validate refresh token
  const storedToken = await getRefreshToken(refresh_token);
  if (!storedToken) {
    throw { code: 'invalid_grant', message: 'Invalid refresh token' };
  }

  // Check if revoked
  if (storedToken.revoked) {
    throw { code: 'invalid_grant', message: 'Refresh token has been revoked' };
  }

  // Validate client
  if (storedToken.client_id !== client_id) {
    throw { code: 'invalid_grant', message: 'Client mismatch' };
  }

  const client = await getClient(client_id);
  if (client.client_type === 'confidential' && client.client_secret !== client_secret) {
    throw { code: 'invalid_client', message: 'Invalid client credentials' };
  }

  // Validate scope (requested scope must be subset of original)
  const requestedScopes = scope ? scope.split(' ') : storedToken.scope.split(' ');
  const originalScopes = storedToken.scope.split(' ');
  const isValidScope = requestedScopes.every(s => originalScopes.includes(s));

  if (!isValidScope) {
    throw { code: 'invalid_scope', message: 'Requested scope exceeds original grant' };
  }

  // Generate new access token
  const accessToken = await generateAccessToken({
    user_id: storedToken.user_id,
    client_id: client_id,
    scope: requestedScopes.join(' '),
  });

  // Optional: Refresh token rotation
  let newRefreshToken = refresh_token;
  if (shouldRotateRefreshToken()) {
    // Revoke old refresh token
    await revokeRefreshToken(refresh_token);

    // Generate new refresh token
    newRefreshToken = await generateRefreshToken({
      user_id: storedToken.user_id,
      client_id: client_id,
      scope: requestedScopes.join(' '),
    });
  }

  return {
    access_token: accessToken,
    token_type: 'Bearer',
    expires_in: 3600,
    refresh_token: newRefreshToken,
    scope: requestedScopes.join(' '),
  };
}

async function handleClientCredentialsGrant(params) {
  const { client_id, client_secret, scope } = params;

  // Authenticate client
  const client = await getClient(client_id);
  if (!client || client.client_secret !== client_secret) {
    throw { code: 'invalid_client', message: 'Invalid client credentials' };
  }

  // Validate scope
  if (scope) {
    const requestedScopes = scope.split(' ');
    const allowedScopes = client.allowed_scopes || [];
    const isValidScope = requestedScopes.every(s => allowedScopes.includes(s));

    if (!isValidScope) {
      throw { code: 'invalid_scope', message: 'Requested scope not allowed for this client' };
    }
  }

  // Generate access token (no refresh token for client credentials)
  const accessToken = await generateAccessToken({
    client_id: client_id,
    scope: scope || client.default_scope,
  });

  return {
    access_token: accessToken,
    token_type: 'Bearer',
    expires_in: 3600,
    scope: scope || client.default_scope,
  };
}
```

#### Token Generation (JWT)

```javascript
// JWT token generation
const jwt = require('jsonwebtoken');
const fs = require('fs');

const privateKey = fs.readFileSync('path/to/private-key.pem');
const publicKey = fs.readFileSync('path/to/public-key.pem');

async function generateAccessToken(payload) {
  const token = jwt.sign(
    {
      sub: payload.user_id || payload.client_id,
      client_id: payload.client_id,
      scope: payload.scope,
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(Date.now() / 1000) + 3600, // 1 hour
      iss: 'https://auth.example.com',
      aud: 'https://api.example.com',
    },
    privateKey,
    {
      algorithm: 'RS256',
      keyid: 'key-id-1',
    }
  );

  return token;
}

async function generateRefreshToken(payload) {
  const refreshToken = crypto.randomBytes(32).toString('hex');

  // Store refresh token in database
  await storeRefreshToken(refreshToken, {
    user_id: payload.user_id,
    client_id: payload.client_id,
    scope: payload.scope,
    created_at: Date.now(),
    expires_at: Date.now() + (30 * 24 * 60 * 60 * 1000), // 30 days
    revoked: false,
  });

  return refreshToken;
}

async function generateIDToken(payload) {
  const user = await getUser(payload.user_id);

  const idToken = jwt.sign(
    {
      iss: 'https://auth.example.com',
      sub: payload.user_id,
      aud: payload.client_id,
      exp: Math.floor(Date.now() / 1000) + 3600,
      iat: Math.floor(Date.now() / 1000),
      // Standard claims
      name: user.name,
      email: user.email,
      email_verified: user.email_verified,
      picture: user.picture,
      // Custom claims based on scope
      ...getScopedClaims(user, payload.scope),
    },
    privateKey,
    {
      algorithm: 'RS256',
      keyid: 'key-id-1',
    }
  );

  return idToken;
}

function getScopedClaims(user, scope) {
  const claims = {};
  const scopes = scope ? scope.split(' ') : [];

  if (scopes.includes('profile')) {
    claims.given_name = user.given_name;
    claims.family_name = user.family_name;
    claims.locale = user.locale;
    claims.updated_at = user.updated_at;
  }

  if (scopes.includes('phone')) {
    claims.phone_number = user.phone_number;
    claims.phone_number_verified = user.phone_number_verified;
  }

  return claims;
}
```

## Best Practices and Security

### Security Best Practices

1. **Always Use HTTPS**
   - All OAuth2 endpoints must use HTTPS
   - Tokens transmitted over encrypted connections only
   - No OAuth2 over HTTP (except localhost development)

2. **Validate Redirect URIs Strictly**
   - Exact match required (no wildcards)
   - Register all redirect URIs in advance
   - Validate on every authorization request

3. **Use PKCE for Public Clients**
   - Required for SPAs and mobile apps
   - Use S256 code challenge method (not plain)
   - Prevents authorization code interception

4. **Implement State Parameter**
   - Prevents CSRF attacks
   - Generate cryptographically secure random value
   - Validate on callback

5. **Short-Lived Access Tokens**
   - Typically 15 minutes to 1 hour
   - Reduces impact of token theft
   - Use refresh tokens for long-lived sessions

6. **Secure Token Storage**
   - Never store tokens in localStorage (XSS risk)
   - Use httpOnly cookies for refresh tokens
   - Mobile: Use platform secure storage (Keychain, Keystore)

7. **Implement Token Rotation**
   - Rotate refresh tokens on each use
   - Detect token theft through multiple refresh attempts
   - Revoke all tokens for compromised refresh token

8. **Validate All Tokens**
   - Verify JWT signatures
   - Check expiration
   - Validate issuer and audience
   - Verify required scopes

9. **Scope-Based Access Control**
   - Request minimum required scopes
   - Validate scopes on API requests
   - Document all available scopes

10. **Monitor and Log**
    - Log all authentication attempts
    - Monitor for suspicious patterns
    - Alert on multiple failed attempts
    - Track token usage and revocations

### Common Pitfalls to Avoid

1. **Using Implicit Flow**
   - Deprecated and insecure
   - Use Authorization Code Flow with PKCE instead

2. **Storing Tokens in localStorage**
   - Vulnerable to XSS attacks
   - Use memory or secure storage instead

3. **Not Validating Redirect URIs**
   - Enables open redirect attacks
   - Always validate against registered URIs

4. **Ignoring Token Expiration**
   - Expired tokens should be rejected
   - Implement proper refresh logic

5. **Not Using State Parameter**
   - Vulnerable to CSRF attacks
   - Always generate and validate state

6. **Long-Lived Access Tokens**
   - Increases security risk
   - Keep access tokens short-lived (15-60 minutes)

7. **Sharing Tokens Between Applications**
   - Tokens should be application-specific
   - Each app should have its own client_id

8. **Weak Code Verifiers (PKCE)**
   - Use cryptographically secure random generation
   - Minimum 43 characters

9. **Not Implementing Token Revocation**
   - Users can't revoke access
   - Compromised tokens remain valid

10. **Insufficient Logging**
    - Can't detect or investigate security incidents
    - Log all authentication and authorization events

## Performance Optimization

### Token Caching

```javascript
// Efficient token caching with automatic refresh
class OptimizedTokenManager {
  constructor() {
    this.tokenCache = new Map();
    this.refreshPromises = new Map();
  }

  async getToken(cacheKey, fetchCallback) {
    // Check cache
    const cached = this.tokenCache.get(cacheKey);
    if (cached && Date.now() < cached.expiresAt - 60000) {
      return cached.token;
    }

    // Check if refresh is in progress
    if (this.refreshPromises.has(cacheKey)) {
      return this.refreshPromises.get(cacheKey);
    }

    // Fetch new token
    const promise = fetchCallback()
      .then(({ token, expiresIn }) => {
        this.tokenCache.set(cacheKey, {
          token,
          expiresAt: Date.now() + (expiresIn * 1000),
        });
        this.refreshPromises.delete(cacheKey);
        return token;
      })
      .catch(error => {
        this.refreshPromises.delete(cacheKey);
        throw error;
      });

    this.refreshPromises.set(cacheKey, promise);
    return promise;
  }

  clearCache(cacheKey) {
    if (cacheKey) {
      this.tokenCache.delete(cacheKey);
    } else {
      this.tokenCache.clear();
    }
  }
}
```

### Connection Pooling

```javascript
// Reuse HTTP connections for token requests
const https = require('https');
const axios = require('axios');

const httpsAgent = new https.Agent({
  keepAlive: true,
  maxSockets: 50,
  maxFreeSockets: 10,
  timeout: 60000,
});

const apiClient = axios.create({
  httpsAgent,
  timeout: 30000,
});

// Use for all OAuth2 requests
async function fetchTokens(params) {
  const response = await apiClient.post(tokenEndpoint, params);
  return response.data;
}
```

## Resources and References

### Official Specifications

- [RFC 6749 - OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749)
- [RFC 7636 - PKCE](https://tools.ietf.org/html/rfc7636)
- [RFC 8252 - OAuth 2.0 for Native Apps](https://tools.ietf.org/html/rfc8252)
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)
- [OAuth 2.0 Security Best Practices](https://tools.ietf.org/html/draft-ietf-oauth-security-topics)

### Popular OAuth2 Libraries

**JavaScript/Node.js:**
- `passport` - Authentication middleware
- `oauth4webapi` - Modern OAuth2 client
- `node-oauth2-server` - OAuth2 server implementation
- `jsonwebtoken` - JWT creation and validation
- `jwks-rsa` - JWKS key retrieval

**Python:**
- `authlib` - Comprehensive OAuth library
- `python-oauth2` - OAuth2 provider toolkit
- `PyJWT` - JWT implementation

**PHP:**
- `league/oauth2-client` - OAuth2 client
- `league/oauth2-server` - OAuth2 server

**Java:**
- Spring Security OAuth
- Apache Oltu

### OAuth2 Providers

- Auth0
- Okta
- Amazon Cognito
- Google Identity Platform
- Azure Active Directory
- Keycloak (open source)
- ORY Hydra (open source)

---

**Skill Version**: 1.0.0
**Last Updated**: October 2025
**Skill Category**: Authentication, Authorization, Security
**Compatible With**: Web Applications, Mobile Apps, APIs, Microservices
