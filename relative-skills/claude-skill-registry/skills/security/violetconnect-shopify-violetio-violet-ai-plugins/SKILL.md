---
name: violetconnect-shopify
description: Shopify OAuth integration patterns for VioletConnect merchant onboarding
---

# VioletConnect: Shopify Integration

## Overview

VioletConnect integrates with **Shopify** via **centralized OAuth 2.0** for merchant onboarding. This skill documents Shopify-specific OAuth flows, pre-registration patterns, and implementation details.

**Integration Type**: Centralized OAuth 2.0
**Store Identifier**: Store URL (`*.myshopify.com`)
**Credential Storage**: `access_token` (long-lived, no refresh)
**Pre-Registration Support**: All flows (A, B, C)

**Related Skills**:
- **violetconnect**: Core VioletConnect features and architecture
- **violetconnect-patterns**: Code patterns (Redux, axiosWrapper, AppContext)
- **v-shopify**: General Shopify API patterns and integration details

---

## Shopify OAuth Flow

### Standard Flow (No Pre-Registration)

```
1. Merchant lands on VioletConnect: connect.violet.io/{appAlias}/platforms/shopify
2. Merchant enters email → Creates session
3. Merchant enters store URL (e.g., "mystore.myshopify.com")
4. VioletConnect validates store URL format
5. VioletConnect redirects to Shopify OAuth:
   - URL: https://{store}.myshopify.com/admin/oauth/authorize
   - Params: client_id, scope, redirect_uri, state
6. Merchant approves app in Shopify admin
7. Shopify redirects back to VioletConnect callback:
   - URL: connect.violet.io/{appAlias}/platforms/shopify/callback
   - Params: code, shop, state
8. VioletConnect exchanges code for access_token (server-side)
9. VioletConnect creates merchant record in MerchantService
10. Merchant completes commission/payout setup
11. Merchant redirected to success page
```

### With Pre-Registration (Flow A)

**Flow A: Direct Install Link** - Shopify-specific pattern

```
1. Channel pre-registers merchant with Shopify credentials
2. Channel sends Shopify install link directly to merchant:
   - URL: https://{store}.myshopify.com/admin/oauth/authorize?client_id={id}&redirect_uri={uri}
3. Merchant clicks install link (bypasses VioletConnect)
4. Merchant approves in Shopify admin
5. Shopify redirects to VioletConnect callback with code
6. VioletConnect detects no active session
7. VioletConnect looks up pre-registration by store_url (from state)
8. If found: Resume flow with pre-stored credentials
9. If not found: Error (no session)
```

**Key Point**: Flow A is **Shopify-only** - Shopify allows direct install links that bypass VioletConnect email/store URL entry.

---

## Shopify OAuth Implementation Details

### Dynamic Routing

**Page Files**:
```
pages/[appAlias]/platforms/shopify/index.tsx
pages/[appAlias]/platforms/shopify/callback.tsx
```

**Key Utility Files**:
```typescript
// utils/shopify/oauth.ts
// OAuth URL construction and token exchange

// utils/shopify/validation.ts
// Store URL validation (.myshopify.com format)
```

### OAuth Parameters

```typescript
interface ShopifyOAuthParams {
  client_id: string;        // Shopify app client ID
  scope: string;            // Permissions (read_products, write_orders, etc.)
  redirect_uri: string;     // VioletConnect callback URL
  state: string;            // CSRF token + session identifier
  grant_options?: string[]; // ['per-user'] for user-level access
}
```

**Example OAuth URL**:
```
https://mystore.myshopify.com/admin/oauth/authorize
  ?client_id=abc123
  &scope=read_products,write_orders,read_customers
  &redirect_uri=https://connect.violet.io/andydev/platforms/shopify/callback
  &state=csrf_token_session_id
```

### Access Token Exchange

**Server-Side Only** (`pages/api/shopify/token-exchange.ts`):

```typescript
POST https://{shop}.myshopify.com/admin/oauth/access_token
Body: {
  client_id: string,
  client_secret: string,
  code: string
}

Response: {
  access_token: string,
  scope: string
}
```

**Implementation Pattern**:
```typescript
// pages/api/shopify/token-exchange.ts
import { NextApiRequest, NextApiResponse } from 'next';
import axios from 'axios';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { code, shop } = req.body;

  try {
    const response = await axios.post(
      `https://${shop}/admin/oauth/access_token`,
      {
        client_id: process.env.SHOPIFY_CLIENT_ID,
        client_secret: process.env.SHOPIFY_CLIENT_SECRET,
        code
      }
    );

    const { access_token, scope } = response.data;

    // Create merchant record in MerchantService
    const merchant = await createMerchant({
      platform: 'shopify',
      storeUrl: shop,
      accessToken: access_token,
      scope
    });

    res.status(200).json({ merchantId: merchant.id });
  } catch (error: any) {
    res.status(error.response?.status || 500).json({
      error: error.response?.data || 'Token exchange failed'
    });
  }
}
```

---

## Store URL Validation

### Required Format

Shopify store URLs must match: `*.myshopify.com`

**Validation Function**:
```typescript
// utils/shopify/validation.ts
export function validateShopifyStoreUrl(url: string): boolean {
  // Remove protocol and trailing slash
  const cleanUrl = url.replace(/^https?:\/\//, '').replace(/\/$/, '');

  // Must end with .myshopify.com
  const shopifyPattern = /^[a-z0-9-]+\.myshopify\.com$/i;

  return shopifyPattern.test(cleanUrl);
}
```

**Handling Custom Domains**:
- Shopify Plus merchants may have custom domains
- Accept custom domains, but verify via Shopify API
- Store canonical `*.myshopify.com` URL in database

**Development Stores**:
- Development stores use same `*.myshopify.com` format
- No special handling needed

---

## Pre-Registration Integration

Shopify supports **all three pre-registration flows**:

### Flow A: Direct Install Link (Shopify-Only)

**Implementation**:
```typescript
// pages/[appAlias]/platforms/shopify/callback.tsx
import { useEffect } from 'react';
import { useRouter } from 'next/router';
import { useDispatch } from 'react-redux';
import { lookupByStoreUrl } from '@/redux/slices/preRegistration';

function ShopifyCallback() {
  const router = useRouter();
  const dispatch = useDispatch();
  const { code, shop, state } = router.query;

  useEffect(() => {
    if (code && shop) {
      handleOAuthCallback();
    }
  }, [code, shop]);

  const handleOAuthCallback = async () => {
    // Check if session exists
    const sessionValid = await checkSession();

    if (!sessionValid) {
      // No session - check for pre-registration (Flow A)
      const preReg = await dispatch(lookupByStoreUrl({
        storeUrl: shop as string,
        appId: getAppIdFromState(state as string)
      })).unwrap();

      if (preReg.found) {
        // Resume with pre-stored credentials
        await completeOAuthWithPreReg(code, shop, preReg.preRegistration);
      } else {
        // No session, no pre-reg - error
        router.push('/error?reason=session_expired');
      }
    } else {
      // Normal flow - session exists
      await completeOAuth(code, shop);
    }
  };

  return <div>Processing...</div>;
}
```

### Flow B: Store URL Lookup

**Implementation**:
```typescript
// pages/[appAlias]/platforms/shopify/index.tsx
import { useDispatch, useSelector } from 'react-redux';
import { lookupByStoreUrl } from '@/redux/slices/preRegistration';

function ShopifyUrlPage() {
  const dispatch = useDispatch();
  const { current, found } = useSelector((state) => state.preRegistration);
  const { appId } = useContext(AppContext);

  const onStoreUrlSubmit = async (data: { storeUrl: string }) => {
    // Validate format first
    if (!validateShopifyStoreUrl(data.storeUrl)) {
      setError('Must be a valid Shopify store URL (*.myshopify.com)');
      return;
    }

    // Check for pre-registration
    const result = await dispatch(lookupByStoreUrl({
      storeUrl: data.storeUrl,
      appId
    })).unwrap();

    if (result.found) {
      // Pre-registration found - show confirmation
      return;
    } else {
      // Not found - continue normal flow
      redirectToShopifyOAuth(data.storeUrl);
    }
  };

  if (found && current) {
    return (
      <PreRegFound
        preRegistration={current}
        onConnect={() => {
          window.location.href = current.installLink;
        }}
      />
    );
  }

  return <StoreUrlForm onSubmit={onStoreUrlSubmit} />;
}
```

### Flow C: MerchantId Link

**Implementation**: Handled by AppContext (see `violetconnect-patterns` skill)

**Shopify-Specific Note**: InstallLink in pre-registration must be full Shopify OAuth URL:
```
https://{store}.myshopify.com/admin/oauth/authorize?client_id={id}&redirect_uri={uri}&state={state}
```

---

## Shopify Components

### StoreUrlInput Component

```typescript
// components/Shopify/StoreUrlInput.tsx
interface StoreUrlInputProps {
  onSubmit: (storeUrl: string) => void;
  loading?: boolean;
}

const StoreUrlInput = ({ onSubmit, loading }: StoreUrlInputProps) => {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: yupResolver(shopifyStoreUrlSchema)
  });

  return (
    <form onSubmit={handleSubmit(({ storeUrl }) => onSubmit(storeUrl))}>
      <label>Shopify Store URL</label>
      <input
        {...register('storeUrl')}
        placeholder="mystore.myshopify.com"
        className={styles.input}
      />
      {errors.storeUrl && (
        <span className={styles.error}>{errors.storeUrl.message}</span>
      )}

      <VioletButton
        type="submit"
        text="Continue"
        loading={loading}
        disabled={loading}
      />

      <p className={styles.helpText}>
        Your store URL is found in your Shopify admin URL.
      </p>
    </form>
  );
};

// Validation schema
const shopifyStoreUrlSchema = yup.object({
  storeUrl: yup.string()
    .required('Store URL is required')
    .test('shopify-format', 'Must be a valid Shopify store URL (*.myshopify.com)', (value) => {
      return validateShopifyStoreUrl(value || '');
    })
});
```

### OAuthRedirect Component

```typescript
// components/Shopify/OAuthRedirect.tsx
interface OAuthRedirectProps {
  storeUrl: string;
  clientId: string;
  redirectUri: string;
  state: string;
  scope: string;
}

const OAuthRedirect = ({ storeUrl, clientId, redirectUri, state, scope }: OAuthRedirectProps) => {
  useEffect(() => {
    const oauthUrl = constructShopifyOAuthUrl({
      storeUrl,
      clientId,
      redirectUri,
      state,
      scope
    });

    // Redirect to Shopify OAuth
    window.location.href = oauthUrl;
  }, []);

  return (
    <div className={styles.redirecting}>
      <Spinner />
      <p>Redirecting to Shopify...</p>
    </div>
  );
};

// OAuth URL construction
function constructShopifyOAuthUrl({ storeUrl, clientId, redirectUri, state, scope }: OAuthRedirectProps) {
  const cleanStore = storeUrl.replace(/^https?:\/\//, '').replace(/\/$/, '');
  const params = new URLSearchParams({
    client_id: clientId,
    scope,
    redirect_uri: redirectUri,
    state
  });

  return `https://${cleanStore}/admin/oauth/authorize?${params.toString()}`;
}
```

### CallbackHandler Component

```typescript
// components/Shopify/CallbackHandler.tsx
const CallbackHandler = () => {
  const router = useRouter();
  const { code, shop, state } = router.query;
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (router.query.error) {
      // OAuth denied
      setError(router.query.error as string);
      return;
    }

    if (code && shop && state) {
      handleCallback();
    }
  }, [code, shop, state]);

  const handleCallback = async () => {
    try {
      // Validate state (CSRF protection)
      if (!validateState(state as string)) {
        throw new Error('Invalid state parameter');
      }

      // Exchange code for token
      const response = await axiosWrapper({
        url: '/api/shopify/token-exchange',
        method: 'POST',
        data: { code, shop, state }
      });

      // Redirect to commission setup
      router.push(`/${appAlias}/commission?merchantId=${response.data.merchantId}`);
    } catch (err: any) {
      setError(err.message || 'OAuth callback failed');
    }
  };

  if (error) {
    return <OAuthError error={error} />;
  }

  return (
    <div className={styles.processing}>
      <Spinner />
      <p>Completing setup...</p>
    </div>
  );
};
```

---

## Error Handling

### Shopify-Specific Errors

| Error | Cause | VioletConnect Handling |
|-------|-------|------------------------|
| Invalid store URL | Wrong format | Show inline error: "Must be *.myshopify.com" |
| Store not found | Store doesn't exist | Shopify returns error on OAuth redirect |
| OAuth denied | Merchant clicks "Cancel" | Callback receives `error=access_denied` |
| Invalid credentials | Wrong client_id/secret | Token exchange fails, show error |
| Scope mismatch | Requested scope not granted | Check returned scope, warn merchant |

**Error Component**:
```typescript
// components/Shopify/OAuthError.tsx
interface OAuthErrorProps {
  error: string;
  onRetry?: () => void;
}

const OAuthError = ({ error, onRetry }: OAuthErrorProps) => {
  const errorMessages: Record<string, string> = {
    'access_denied': 'You declined to install the app. Please try again to connect your store.',
    'invalid_request': 'Invalid OAuth request. Please contact support.',
    'session_expired': 'Your session has expired. Please start over.'
  };

  return (
    <div className={styles.errorContainer}>
      <AlertIcon className={styles.errorIcon} />
      <h2>Connection Failed</h2>
      <p>{errorMessages[error] || 'An error occurred during setup.'}</p>

      {onRetry && (
        <VioletButton
          text="Try Again"
          onClick={onRetry}
        />
      )}
    </div>
  );
};
```

---

## Testing

### Local Development Setup

```bash
# Shopify development store required
# Create at: partners.shopify.com

# Add to .env.local
SHOPIFY_CLIENT_ID=your_client_id
SHOPIFY_CLIENT_SECRET=your_client_secret
SHOPIFY_SCOPES=read_products,write_orders,read_customers

# Test store URL
TEST_SHOPIFY_STORE=mytest-store.myshopify.com
```

### E2E Testing

```typescript
// __tests__/e2e/shopify-oauth.test.ts
import { test, expect } from '@playwright/test';

test.describe('Shopify OAuth Flow', () => {
  test('should complete OAuth flow successfully', async ({ page }) => {
    // Navigate to Shopify onboarding
    await page.goto('http://localhost:3001/testchannel/platforms/shopify');

    // Enter email
    await page.fill('input[name="email"]', 'test@example.com');
    await page.click('button[type="submit"]');

    // Enter store URL
    await page.fill('input[name="storeUrl"]', 'mytest-store.myshopify.com');
    await page.click('button[type="submit"]');

    // Should redirect to Shopify OAuth
    await expect(page).toHaveURL(/myshopify\.com\/admin\/oauth\/authorize/);
  });

  test('should validate store URL format', async ({ page }) => {
    await page.goto('http://localhost:3001/testchannel/platforms/shopify');

    await page.fill('input[name="email"]', 'test@example.com');
    await page.click('button[type="submit"]');

    // Invalid URL
    await page.fill('input[name="storeUrl"]', 'invalid-url.com');
    await page.click('button[type="submit"]');

    // Should show error
    await expect(page.locator('text=Must be a valid Shopify store URL')).toBeVisible();
  });
});
```

### Unit Testing

```typescript
// __tests__/unit/shopify-validation.test.ts
import { validateShopifyStoreUrl } from '@/utils/shopify/validation';

describe('validateShopifyStoreUrl', () => {
  it('should accept valid myshopify.com URLs', () => {
    expect(validateShopifyStoreUrl('mystore.myshopify.com')).toBe(true);
    expect(validateShopifyStoreUrl('https://mystore.myshopify.com')).toBe(true);
    expect(validateShopifyStoreUrl('https://mystore.myshopify.com/')).toBe(true);
  });

  it('should reject invalid URLs', () => {
    expect(validateShopifyStoreUrl('mystore.com')).toBe(false);
    expect(validateShopifyStoreUrl('mystore.shopify.com')).toBe(false);
    expect(validateShopifyStoreUrl('invalid')).toBe(false);
  });
});
```

---

## Configuration

### Environment Variables

```bash
# Required for Shopify OAuth
SHOPIFY_CLIENT_ID=abc123456
SHOPIFY_CLIENT_SECRET=xyz789012
SHOPIFY_SCOPES=read_products,write_orders,read_customers,read_fulfillments

# Redirect URI (must match Shopify app settings)
SHOPIFY_REDIRECT_URI=https://connect.violet.io/{appAlias}/platforms/shopify/callback

# Optional: Shopify API version
SHOPIFY_API_VERSION=2024-01
```

### Channel-Specific Configuration

```typescript
interface ChannelConfig {
  appId: number;
  appAlias: string;
  supportedPlatforms: ['shopify', ...];
  shopifyClientId: string;     // Per-channel Shopify app
  shopifyClientSecret: string;
  shopifyScopes: string;
}
```

**Note**: Each channel can have its own Shopify app with different scopes.

---

## Related Documentation

- **Core VioletConnect**: `violetconnect` skill
- **Code Patterns**: `violetconnect-patterns` skill
- **Shopify API**: `v-shopify` plugin (general Shopify integration patterns)
- **Pre-Registration Spec**: `prism-brain/product/specs/merchant-pre-registration/`
- **Shopify Integration Brain**: `ecom-integrations-brain/integrations/shopify/`
