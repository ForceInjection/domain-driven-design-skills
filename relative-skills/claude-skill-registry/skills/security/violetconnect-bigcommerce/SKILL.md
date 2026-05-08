---
name: violetconnect-bigcommerce
description: BigCommerce OAuth, embedded app JWT validation, and pre-registration patterns for VioletConnect
---

# VioletConnect: BigCommerce Integration

## Overview

VioletConnect integrates with **BigCommerce** via **centralized OAuth 2.0** for merchant onboarding. BigCommerce uniquely supports **embedded apps** that load within the BigCommerce admin iframe using JWT authentication.

**Integration Type**: Centralized OAuth 2.0 + Embedded App (JWT)
**Store Identifier**: Store Hash (alphanumeric, e.g., `abc123`)
**Credential Storage**: `access_token` + `store_hash` (long-lived, no refresh)
**Pre-Registration Support**: Flows B and C only (no Flow A - BC doesn't support direct install links)

**Related Skills**:
- **violetconnect**: Core VioletConnect features and architecture
- **violetconnect-patterns**: Code patterns (Redux, axiosWrapper, AppContext)
- **v-bigcommerce**: General BigCommerce API patterns and integration details

---

## BigCommerce OAuth Flow

### Standard OAuth Flow (No Pre-Registration)

```
1. Merchant lands on VioletConnect: connect.violet.io/{appAlias}/platforms/bigcommerce
2. Merchant enters email → Creates session
3. Merchant enters store URL (e.g., "https://store-abc123.mybigcommerce.com")
4. VioletConnect validates store URL format
5. VioletConnect redirects to BigCommerce OAuth:
   - URL: https://login.bigcommerce.com/oauth2/authorize
   - Params: client_id, scope, redirect_uri, state
6. Merchant approves app in BigCommerce admin
7. BigCommerce redirects back to VioletConnect callback:
   - URL: connect.violet.io/{appAlias}/platforms/bigcommerce/callback
   - Params: code, scope, context
8. VioletConnect exchanges code for access_token (server-side)
9. VioletConnect creates merchant record with store_hash
10. Merchant completes commission/payout setup
11. Merchant redirected to success page
```

**Key Difference from Shopify**: BigCommerce returns a `context` parameter (format: `"stores/{store_hash}"`) which must be extracted for the merchant record.

---

### BigCommerce Embedded App Flow

**Key Feature**: BigCommerce supports **embedded apps** that load within the BigCommerce admin panel as an iframe.

```
1. Merchant installs app from BigCommerce App Marketplace
2. BigCommerce loads VioletConnect in iframe: /bc-embedded/load
3. BigCommerce sends signed JWT as query parameter: ?signed_payload_jwt={token}
4. VioletConnect validates JWT signature using client_secret
5. JWT contains: store_hash, user.id, user.email, timestamps
6. VioletConnect auto-creates session (no manual login required)
7. Merchant is already authenticated
8. Continue with commission/payout setup
```

**Why Embedded Apps**:
- **Seamless UX**: Merchant never leaves BigCommerce admin
- **Auto-Authentication**: No need for email entry or manual OAuth
- **Single Sign-On**: JWT verification provides instant authentication

**Use Case**: If your channel's app is in the BigCommerce App Marketplace, use embedded app flow for better UX.

---

## OAuth Implementation Details

### Dynamic Routing

**Page Files**:
```
pages/[appAlias]/platforms/bigcommerce/
├── index.tsx         # Store URL entry + OAuth redirect
└── callback.tsx      # OAuth callback handler

pages/bc-embedded/
└── load.tsx          # Embedded app JWT handler
```

**Key Utility Files**:
```typescript
// utils/bigcommerce/oauth.ts
// OAuth URL construction and token exchange

// utils/bigcommerce/validation.ts
// Store URL validation (*.mybigcommerce.com format)

// utils/bigcommerce/jwt.ts
// JWT validation and decoding for embedded apps
```

---

### OAuth Parameters

```typescript
interface BigCommerceOAuthParams {
  client_id: string;        // BigCommerce app client ID
  scope: string;            // Permissions (space-separated, e.g., "store_v2_products store_v2_orders")
  redirect_uri: string;     // VioletConnect callback URL
  state: string;            // CSRF token + session identifier
  response_type: 'code';    // Always 'code' for authorization code flow
  context?: string;         // Optional: "stores/{hash}" for re-authorization
}
```

**Example OAuth URL**:
```
https://login.bigcommerce.com/oauth2/authorize?client_id=abc123&scope=store_v2_products+store_v2_orders&redirect_uri=https://connect.violet.io/testchannel/platforms/bigcommerce/callback&state=csrf_token&response_type=code
```

**Note**: BigCommerce scopes are **space-separated** (different from Shopify's comma-separated scopes).

---

### Access Token Exchange

After OAuth callback with `code`, exchange for `access_token`:

```typescript
POST https://login.bigcommerce.com/oauth2/token
Content-Type: application/json

Body: {
  client_id: string,
  client_secret: string,
  code: string,
  scope: string,            // Same scopes from authorize request
  grant_type: "authorization_code",
  redirect_uri: string,
  context: string           // From callback params: "stores/{hash}"
}

Response: {
  access_token: string,     // Store this for API calls
  scope: string,            // Granted scopes
  user: {
    id: number,
    username: string,
    email: string
  },
  context: string           // "stores/{store_hash}"
}
```

**Critical**: Extract `store_hash` from the `context` field (`"stores/{hash}"`) - this is the primary identifier for the merchant.

---

## Store Hash vs Store URL

### Store Hash as Primary Identifier

BigCommerce uses **store_hash** (not store URL) as the primary identifier for a merchant's store.

**Store Hash Format**: Alphanumeric string (e.g., `"abc123def"`, `"xk4t2p"`)

**Where to Get Store Hash**:
1. From OAuth response `context` field: `"stores/{store_hash}"`
2. From embedded app JWT `sub` field: `"{store_hash}"`
3. From store URL: `https://store-{hash}.mybigcommerce.com`

**Extraction Pattern**:
```typescript
// From context field
function extractStoreHash(context: string): string {
  // context format: "stores/abc123def"
  return context.replace('stores/', '');
}

// From store URL
function getStoreHashFromUrl(storeUrl: string): string | null {
  // URL format: https://store-abc123def.mybigcommerce.com
  const match = storeUrl.match(/store-([a-z0-9]+)\.mybigcommerce\.com/i);
  return match ? match[1] : null;
}
```

---

### API Call Pattern

All BigCommerce API calls use `store_hash`:

```typescript
const apiUrl = `https://api.bigcommerce.com/stores/${store_hash}/v3/catalog/products`;

const response = await axios.get(apiUrl, {
  headers: {
    'X-Auth-Token': access_token,
    'Content-Type': 'application/json'
  }
});
```

**Key Point**: Store `store_hash` in your merchant record, not just the store URL. The store URL can change (custom domains), but `store_hash` is permanent.

---

### Store URL Validation

```typescript
// Validate BigCommerce store URL format
function isValidBCUrl(url: string): boolean {
  return /^https:\/\/store-[a-z0-9]+\.mybigcommerce\.com$/i.test(url);
}

// Example validation in StoreUrlInput component
<StoreUrlForm
  platform="bigcommerce"
  placeholder="https://store-abc123.mybigcommerce.com"
  validation={isValidBCUrl}
  onSubmit={handleStoreUrlSubmit}
  errorMessage="Invalid BigCommerce store URL. Must be https://store-{hash}.mybigcommerce.com"
/>
```

---

## Embedded App JWT Validation

### JWT Structure

When BigCommerce loads your app in an iframe, it sends a signed JWT with this structure:

```typescript
interface BigCommerceJWT {
  aud: string;           // Your client_id
  iss: string;           // "bc" (BigCommerce issuer)
  iat: number;           // Issued at timestamp (Unix epoch)
  nbf: number;           // Not before timestamp
  exp: number;           // Expiration timestamp
  jti: string;           // JWT ID (unique identifier)
  sub: string;           // Store hash (e.g., "abc123def")
  user: {
    id: number;          // BigCommerce user ID
    email: string;       // User email
    locale: string;      // e.g., "en-US"
  };
  owner: {
    id: number;          // Store owner user ID
    email: string;       // Owner email
  };
  url: string;           // Store URL (e.g., "https://store-abc123.mybigcommerce.com")
  channel_id: number | null;  // Channel ID if multi-channel
}
```

---

### JWT Validation Pattern

**CRITICAL**: Always validate the JWT signature before trusting its contents.

```typescript
import jwt from 'jsonwebtoken';

function validateBCJwt(signedPayload: string, clientSecret: string): BigCommerceJWT {
  try {
    // Verify signature and decode
    const decoded = jwt.verify(signedPayload, clientSecret, {
      algorithms: ['HS256', 'HS384', 'HS512']
    }) as BigCommerceJWT;

    // Verify timestamps
    const now = Math.floor(Date.now() / 1000);

    if (decoded.exp < now) {
      throw new Error('JWT expired');
    }

    if (decoded.nbf > now) {
      throw new Error('JWT not yet valid');
    }

    return decoded;
  } catch (error) {
    throw new Error(`JWT validation failed: ${error.message}`);
  }
}
```

**Why Validate**:
- Prevents JWT tampering
- Ensures request came from BigCommerce
- Verifies timestamp validity

---

### Session Creation from JWT

Once JWT is validated, auto-create a session for the merchant:

```typescript
// pages/bc-embedded/load.tsx
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { signed_payload_jwt } = req.query;

  if (!signed_payload_jwt || typeof signed_payload_jwt !== 'string') {
    return res.status(400).json({ error: 'Missing JWT' });
  }

  try {
    // Validate JWT
    const decoded = validateBCJwt(signed_payload_jwt, process.env.BIGCOMMERCE_CLIENT_SECRET);

    // Extract store_hash from JWT
    const storeHash = decoded.sub;  // or extract from decoded.url

    // Create session
    await createSession({
      storeHash,
      userId: decoded.user.id,
      email: decoded.user.email,
      isEmbedded: true,
      channelId: decoded.channel_id
    });

    // Redirect to onboarding flow (skip email/store URL entry)
    res.redirect(`/${appAlias}/commission`);
  } catch (error) {
    console.error('JWT validation error:', error);
    res.status(401).json({ error: 'Invalid JWT' });
  }
}
```

**Benefit**: Merchant is auto-authenticated without entering email or going through OAuth manually.

---

## Pre-Registration Integration

BigCommerce supports **Flow B** (Store URL Lookup) and **Flow C** (MerchantId Link) only.

**No Flow A**: BigCommerce does not support direct install links like Shopify. Merchants must go through VioletConnect.

---

### Flow B: Store URL Lookup

1. Merchant enters BigCommerce store URL on VioletConnect
2. VioletConnect calls `/api/pre-register/lookup?storeUrl={url}&appId={appId}`
3. If found:
   - Show `PreRegFound` component
   - Display merchant name + store URL
   - "Connect to BigCommerce" button → redirects to `installLink` (OAuth URL)
4. If not found: Continue normal email-first flow

**API Endpoint**:
```typescript
// pages/api/pre-register/lookup.ts
GET /api/pre-register/lookup?storeUrl=https://store-abc123.mybigcommerce.com&appId=1

Response (if found): {
  merchantId: 123,
  merchantName: "Test Store",
  storeUrl: "https://store-abc123.mybigcommerce.com",
  platform: "bigcommerce",
  installLink: "https://login.bigcommerce.com/oauth2/authorize?client_id=...",
  status: "pending"
}

Response (if not found): 404
```

**Redux Integration**:
```typescript
// Component usage
const { current, found, loading } = useSelector((state) => state.preRegistration);

useEffect(() => {
  if (storeUrl) {
    dispatch(lookupByStoreUrl({ storeUrl, appId }));
  }
}, [storeUrl]);

if (found && current) {
  return <PreRegFound preRegistration={current} onConnect={handleConnect} />;
}
```

---

### Flow C: MerchantId Link

1. Channel sends link: `connect.violet.io/{appAlias}?merchantId={id}`
2. AppContext detects `merchantId` query param
3. Dispatches `lookupByMerchantId(merchantId)`
4. If found: Redirect to `/pre-registration/confirm`
5. If not found: Show `PreRegError`

**AppContext Integration** (already handled):
```typescript
// contexts/AppContext.tsx
const merchantId = router.query.merchantId as string;

useEffect(() => {
  if (merchantId && !isNaN(Number(merchantId))) {
    dispatch(lookupByMerchantId(Number(merchantId)));
  }
}, [merchantId, dispatch]);
```

**Confirmation Page**:
```typescript
// pages/[appAlias]/pre-registration/confirm.tsx
// Shows merchant details, "Connect to BigCommerce" button
// Redirects to installLink on click
```

---

## BigCommerce Components

### StoreUrlInput (BigCommerce)

```typescript
const bcUrlPattern = /^https:\/\/store-[a-z0-9]+\.mybigcommerce\.com$/i;

<StoreUrlForm
  platform="bigcommerce"
  placeholder="https://store-abc123.mybigcommerce.com"
  validation={bcUrlPattern}
  helpText="Enter your BigCommerce store URL"
  onSubmit={handleStoreUrlSubmit}
  errorMessage="Invalid BigCommerce store URL format"
/>
```

---

### EmbeddedAppLoader

```typescript
// pages/bc-embedded/load.tsx
// Handles BigCommerce iframe load with JWT validation
// Auto-creates session and redirects to onboarding flow
```

---

### OAuthRedirect Component

```typescript
// Constructs BigCommerce OAuth URL with proper scopes
const oauthUrl = `https://login.bigcommerce.com/oauth2/authorize?${new URLSearchParams({
  client_id: clientId,
  scope: 'store_v2_products store_v2_orders store_v2_customers',
  redirect_uri: callbackUrl,
  state: sessionState,
  response_type: 'code'
})}`;

// Redirect to BigCommerce OAuth
window.location.href = oauthUrl;
```

---

## Error Handling

### BigCommerce-Specific Errors

| Error | Trigger | User Message | Recovery |
|-------|---------|--------------|----------|
| **Invalid Store URL** | URL doesn't match BC format | "Invalid BigCommerce store URL. Must be https://store-{hash}.mybigcommerce.com" | Re-enter URL |
| **OAuth Denied** | Merchant cancels in BC admin | "You cancelled the connection. Please try again." | Restart OAuth flow |
| **Store Hash Mismatch** | JWT store_hash doesn't match OAuth context | "Store verification failed. Please try again." | Contact support |
| **JWT Expired** | JWT timestamp > exp | "Your session expired. Please reload the app." | Refresh page in BC admin |
| **JWT Tampering** | Signature validation fails | "Security validation failed. Please reload the app." | Contact support |
| **Missing Context** | OAuth callback missing context param | "Invalid OAuth response from BigCommerce" | Restart OAuth flow |
| **Invalid Scopes** | Requested scopes not granted | "Required permissions were not granted" | Re-authorize with correct scopes |

### Error Component

```typescript
<BCError
  error={error}
  onRetry={() => router.push(`/${appAlias}/platforms/bigcommerce`)}
  supportUrl={channelConfig.supportUrl}
  channelName={channelName}
/>
```

---

## Testing

### Local Setup

1. **Create BigCommerce Sandbox Store**:
   - Visit: https://www.bigcommerce.com/essentials/free-trial/
   - Sign up for a free 15-day trial
   - Note your store URL: `https://store-{hash}.mybigcommerce.com`

2. **Register App in BigCommerce Developer Portal**:
   - Visit: https://developer.bigcommerce.com/
   - Create new app
   - Configure OAuth settings:
     - Callback URL: `http://localhost:3001/{appAlias}/platforms/bigcommerce/callback`
     - Embedded app load URL: `http://localhost:3001/bc-embedded/load`
   - Copy `client_id` and `client_secret`

3. **Set Environment Variables**:
```bash
# .env.local
BIGCOMMERCE_CLIENT_ID=your_client_id_here
BIGCOMMERCE_CLIENT_SECRET=your_client_secret_here
BIGCOMMERCE_CALLBACK_URL=http://localhost:3001/testchannel/platforms/bigcommerce/callback
BIGCOMMERCE_SCOPES="store_v2_products store_v2_orders store_v2_customers"
BIGCOMMERCE_EMBEDDED_LOAD_URL=http://localhost:3001/bc-embedded/load
```

4. **Test OAuth Flow**:
   - Start VioletConnect: `npm run dev`
   - Navigate to: `http://localhost:3001/testchannel/platforms/bigcommerce`
   - Enter your test store URL
   - Complete OAuth authorization

---

### E2E Testing

```typescript
// tests/e2e/bigcommerce-oauth.spec.ts
import { test, expect } from '@playwright/test';

test('BigCommerce OAuth flow with pre-registration', async ({ page }) => {
  // Navigate to BigCommerce platform page
  await page.goto('http://localhost:3001/testchannel/platforms/bigcommerce');

  // Enter store URL
  await page.fill('[name="storeUrl"]', 'https://store-test123.mybigcommerce.com');
  await page.click('button[type="submit"]');

  // Verify pre-registration found
  await expect(page.locator('text=Your store is already set up!')).toBeVisible();
  await expect(page.locator('text=Test Store')).toBeVisible();

  // Click connect button
  await page.click('text=Connect to BigCommerce');

  // Should redirect to BigCommerce OAuth (external page)
  await expect(page).toHaveURL(/login\.bigcommerce\.com/);
});
```

---

### JWT Validation Tests

```typescript
// tests/unit/bigcommerce-jwt.test.ts
import { validateBCJwt } from '@/utils/bigcommerce/jwt';
import jwt from 'jsonwebtoken';

describe('BigCommerce JWT Validation', () => {
  const clientSecret = 'test_secret';
  const storeHash = 'test123';

  function createTestJWT(payload: Partial<BigCommerceJWT>): string {
    const defaultPayload = {
      aud: 'client_id',
      iss: 'bc',
      iat: Math.floor(Date.now() / 1000),
      nbf: Math.floor(Date.now() / 1000),
      exp: Math.floor(Date.now() / 1000) + 3600,
      jti: 'unique_id',
      sub: storeHash,
      user: { id: 1, email: 'test@example.com', locale: 'en-US' },
      owner: { id: 1, email: 'owner@example.com' },
      url: `https://store-${storeHash}.mybigcommerce.com`,
      channel_id: null
    };

    return jwt.sign({ ...defaultPayload, ...payload }, clientSecret);
  }

  test('validates valid JWT', () => {
    const validJwt = createTestJWT({});
    const decoded = validateBCJwt(validJwt, clientSecret);

    expect(decoded.sub).toBe(storeHash);
    expect(decoded.url).toContain(storeHash);
  });

  test('rejects expired JWT', () => {
    const expiredJwt = createTestJWT({ exp: Math.floor(Date.now() / 1000) - 3600 });

    expect(() => validateBCJwt(expiredJwt, clientSecret)).toThrow('JWT expired');
  });

  test('rejects JWT with invalid signature', () => {
    const validJwt = createTestJWT({});

    expect(() => validateBCJwt(validJwt, 'wrong_secret')).toThrow('JWT validation failed');
  });

  test('rejects JWT not yet valid', () => {
    const futureJwt = createTestJWT({ nbf: Math.floor(Date.now() / 1000) + 3600 });

    expect(() => validateBCJwt(futureJwt, clientSecret)).toThrow('JWT not yet valid');
  });
});
```

---

## Configuration

### Environment Variables

```bash
# BigCommerce OAuth Credentials
BIGCOMMERCE_CLIENT_ID=abc123def456          # From BC Developer Portal
BIGCOMMERCE_CLIENT_SECRET=your_secret_here   # From BC Developer Portal

# OAuth Configuration
BIGCOMMERCE_CALLBACK_URL=https://connect.violet.io/{appAlias}/platforms/bigcommerce/callback
BIGCOMMERCE_SCOPES="store_v2_products store_v2_orders store_v2_customers"

# Embedded App Configuration
BIGCOMMERCE_EMBEDDED_LOAD_URL=https://connect.violet.io/bc-embedded/load
```

**Scope Format**: Space-separated (NOT comma-separated like Shopify)

**Common Scopes**:
- `store_v2_products` - Read/write products
- `store_v2_orders` - Read/write orders
- `store_v2_customers` - Read/write customers
- `store_v2_content` - Read/write content
- `store_v2_information` - Read store information

---

### Channel-Specific Config

```typescript
interface ChannelConfig {
  bigcommerceClientId: string;
  bigcommerceClientSecret: string;
  bigcommerceScopes: string;           // Space-separated scopes
  supportsBCEmbedded: boolean;         // Enable embedded app flow?
  bigcommerceEmbeddedLoadUrl?: string; // Embedded app load URL
}
```

**Example**:
```typescript
const channelConfig: ChannelConfig = {
  bigcommerceClientId: process.env.BIGCOMMERCE_CLIENT_ID,
  bigcommerceClientSecret: process.env.BIGCOMMERCE_CLIENT_SECRET,
  bigcommerceScopes: 'store_v2_products store_v2_orders',
  supportsBCEmbedded: true,  // Enable iframe loading
  bigcommerceEmbeddedLoadUrl: process.env.BIGCOMMERCE_EMBEDDED_LOAD_URL
};
```

---

## Related Documentation

### System Docs
- **BigCommerce Integration**: `prism-brain/systems/violet-connect/bigcommerce-integration.md`
- **OAuth Patterns**: `prism-brain/systems/violet-connect/oauth-patterns.md`
- **Embedded App Architecture**: `prism-brain/systems/violet-connect/embedded-apps.md`

### Code Patterns
- **violetconnect**: Core features (subdomain routing, session management, 13-step wizard)
- **violetconnect-patterns**: Redux, axiosWrapper, AppContext, API proxy patterns

### Platform Integration
- **v-bigcommerce**: BigCommerce API patterns (products, orders, webhooks, V2 vs V3 APIs)

### Implementation Guides
- **Pre-Registration Implementation**: `prism-brain/product/specs/merchant-pre-registration/guides/violet-connect/`
- **BigCommerce PR Guides**: `prism-brain/product/specs/merchant-pre-registration/guides/violet-connect/pr-*-bigcommerce.md`

### External Resources
- [BigCommerce OAuth Docs](https://developer.bigcommerce.com/api-docs/apps/guide/auth)
- [BigCommerce Embedded Apps](https://developer.bigcommerce.com/api-docs/apps/guide/embedded)
- [BigCommerce JWT Structure](https://developer.bigcommerce.com/api-docs/apps/guide/embedded#user-identity)
