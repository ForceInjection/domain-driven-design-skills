---
name: violetconnect-patterns
description: Code patterns for implementing VioletConnect features - Redux, axiosWrapper, AppContext, API routes
---

# VioletConnect Code Patterns

## Overview

This skill documents **HOW to write code for VioletConnect** - the mandatory patterns, architectural rules, and implementation approaches for the merchant onboarding application.

**Tech Stack:**
- Next.js 12.2.5 with React 17.0.2
- Redux Toolkit (NOT React Query)
- axios via axiosWrapper (NOT vanilla axios)
- SCSS modules
- React Hook Form + Yup validation

**ALL patterns in this document are MANDATORY when working on VioletConnect.**

**Related Skills:**
- **violetconnect**: Core features documentation (WHAT VioletConnect does)
- **violetconnect-shopify**: Shopify-specific OAuth and integration
- **violetconnect-bigcommerce**: BigCommerce-specific OAuth and embedded app
- **violetconnect-woocommerce**: WooCommerce REST API patterns

---

## Critical Architecture Rules

### 1. Use Redux, NOT Local React State (ADR-002)

❌ **WRONG**:
```typescript
// hooks/usePreRegistration.ts
import { useState } from 'react';
import axios from 'axios';

export function usePreRegistration() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);

  const lookup = async (storeUrl: string) => {
    setLoading(true);
    const response = await axios.get('/api/pre-register/lookup', { params: { storeUrl } });
    setData(response.data);
    setLoading(false);
  };

  return { data, loading, lookup };
}
```

✅ **CORRECT**:
```typescript
// redux/slices/preRegistration.ts
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import axiosWrapper from '@/utils/axiosWrapper';

export const lookupByStoreUrl = createAsyncThunk(
  'preRegistration/lookupByStoreUrl',
  async ({ storeUrl, appId }: { storeUrl: string; appId: number }) => {
    try {
      const response = await axiosWrapper({
        url: '/api/pre-register/lookup',
        method: 'GET',
        params: { storeUrl, appId }
      });
      return { found: true, preRegistration: response.data };
    } catch (error: any) {
      if (error.response?.status === 404) {
        return { found: false, preRegistration: null };
      }
      throw error;
    }
  }
);

const preRegistrationSlice = createSlice({
  name: 'preRegistration',
  initialState: {
    current: null,
    loading: false,
    error: null,
    found: false
  },
  reducers: {
    reset: (state) => {
      state.current = null;
      state.loading = false;
      state.error = null;
      state.found = false;
    }
  },
  extraReducers: (builder) => {
    builder
      .addCase(lookupByStoreUrl.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(lookupByStoreUrl.fulfilled, (state, action) => {
        state.loading = false;
        state.found = action.payload.found;
        state.current = action.payload.preRegistration;
      })
      .addCase(lookupByStoreUrl.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || 'Lookup failed';
      });
  }
});

export const { reset } = preRegistrationSlice.actions;
export default preRegistrationSlice.reducer;
```

**Why**: Redux provides centralized state management, better debugging via DevTools, and persistence capabilities.

---

### 2. Use axiosWrapper, NOT Vanilla Axios (ADR-006)

❌ **WRONG**:
```typescript
import axios from 'axios';

const response = await axios.get('/api/pre-register/lookup', {
  params: { store_url: storeUrl }
});
```

✅ **CORRECT**:
```typescript
import axiosWrapper from '@/utils/axiosWrapper';

const response = await axiosWrapper({
  url: '/api/pre-register/lookup',
  method: 'GET',
  params: { storeUrl }  // camelCase - axiosWrapper converts to snake_case
});
```

**Why axiosWrapper**:
- Automatic camelCase ↔ snake_case conversion
- Standardized error handling
- Authentication header injection
- Consistent request/response format
- Built-in retry logic

**axiosWrapper Parameters**:
```typescript
interface AxiosWrapperConfig {
  url: string;
  method: 'GET' | 'POST' | 'PUT' | 'DELETE';
  params?: object;  // Query parameters (camelCase)
  data?: object;    // Request body (camelCase)
  headers?: object; // Custom headers
}
```

---

### 3. API Routes are Lightweight Proxies ONLY (ADR-008)

❌ **WRONG** - Business logic in API route:
```typescript
// pages/api/pre-register/lookup.ts
export default async function handler(req, res) {
  const { storeUrl, appId } = req.query;

  try {
    const response = await backendApi.get('/merchants/external/pre-register', {
      params: { store_url: storeUrl, app_id: appId }
    });

    // ❌ NO - Don't transform data here
    const transformed = {
      ...response.data,
      displayName: response.data.merchant_name,
      url: response.data.store_url,
      status: response.data.status === 'pending' ? 'PENDING' : 'ACTIVE'
    };

    res.status(200).json(transformed);
  } catch (error) {
    res.status(500).json({ error: 'Internal error' });
  }
}
```

✅ **CORRECT** - Lightweight proxy:
```typescript
// pages/api/pre-register/lookup.ts
import { NextApiRequest, NextApiResponse } from 'next';
import { getAuthHeaders } from '@/utils/auth';
import backendApi from '@/utils/backendApi';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { storeUrl, appId } = req.query;

  try {
    // Pass through to backend - no transformation
    const response = await backendApi.get('/merchants/external/pre-register', {
      params: { store_url: storeUrl, app_id: appId },
      headers: getAuthHeaders(req)
    });

    // Pass through response directly
    res.status(response.status).json(response.data);
  } catch (error: any) {
    // Pass through error directly
    res.status(error.response?.status || 500).json(
      error.response?.data || { error: 'Internal Server Error' }
    );
  }
}
```

**Why**: API layer should be thin proxy to backend. Business logic belongs in backend or client, not in Node.js API routes.

**Exceptions**: User management and session handling (existing patterns).

---

### 4. Use AppContext for Shared Application State (ADR-007)

AppContext already handles:
- `appId` - Current application ID
- `appAlias` - URL alias for the app
- `merchantId` - Query param detection (**already implemented**)
- `channelName` - Channel display name
- Session and authentication state

❌ **WRONG** - Re-implementing merchantId detection:
```typescript
// pages/[appAlias]/[[...catchall]].tsx
function CatchallPage() {
  const router = useRouter();
  const merchantId = router.query.merchantId;  // ❌ DON'T - Already in AppContext

  useEffect(() => {
    if (merchantId) {
      // This breaks existing functionality
      dispatch(lookupByMerchantId(merchantId));
    }
  }, [merchantId]);
}
```

✅ **CORRECT** - Extend AppContext:
```typescript
// contexts/AppContext.tsx
const AppProvider = ({ children }: AppProviderProps) => {
  const router = useRouter();
  const dispatch = useDispatch();

  // Existing merchantId detection (already exists)
  const merchantId = router.query.merchantId as string;

  // Add pre-registration check
  useEffect(() => {
    if (merchantId && !isNaN(Number(merchantId))) {
      dispatch(lookupByMerchantId(Number(merchantId)));
    }
  }, [merchantId, dispatch]);

  return (
    <AppContext.Provider value={{ /* ...existing values */ }}>
      {children}
    </AppContext.Provider>
  );
};
```

**AppContext Structure**:
```typescript
interface AppContextValue {
  appId: number;
  appAlias: string;
  merchantId?: string;     // From query params
  channelName: string;
  isAuthenticated: boolean;
  // ... other app-wide state
}
```

**When to extend AppContext**:
- Query parameter detection (e.g., merchantId, token)
- Application-wide state changes
- OAuth redirect handling
- Session management

**When NOT to use AppContext**:
- Feature-specific state (use Redux)
- Page-specific data (use component state)
- Form data (use React Hook Form)

---

## Pre-Registration Redux Integration

### State Structure

```typescript
// redux/slices/preRegistration.ts
interface PreRegistrationState {
  current: IPreRegistration | null;
  loading: boolean;
  error: string | null;
  found: boolean;  // Distinguish 404 from error
}
```

### Thunks

```typescript
// Lookup by store URL (Flow B)
export const lookupByStoreUrl = createAsyncThunk(
  'preRegistration/lookupByStoreUrl',
  async ({ storeUrl, appId }: { storeUrl: string; appId: number }) => {
    try {
      const response = await axiosWrapper({
        url: '/api/pre-register/lookup',
        method: 'GET',
        params: { storeUrl, appId }
      });
      return { found: true, preRegistration: response.data };
    } catch (error: any) {
      if (error.response?.status === 404) {
        return { found: false, preRegistration: null };
      }
      throw error;
    }
  }
);

// Lookup by merchantId (Flow C)
export const lookupByMerchantId = createAsyncThunk(
  'preRegistration/lookupByMerchantId',
  async (merchantId: number) => {
    try {
      const response = await axiosWrapper({
        url: `/api/pre-register/${merchantId}`,
        method: 'GET'
      });
      return { found: true, preRegistration: response.data };
    } catch (error: any) {
      if (error.response?.status === 404) {
        return { found: false, preRegistration: null };
      }
      throw error;
    }
  }
);
```

### Component Integration

```typescript
// pages/[appAlias]/shopify-url.tsx
import { useDispatch, useSelector } from 'react-redux';
import { lookupByStoreUrl } from '@/redux/slices/preRegistration';
import PreRegFound from '@/components/PreRegistration/PreRegFound';

function ShopifyUrlPage() {
  const dispatch = useDispatch();
  const { current, loading, found } = useSelector((state) => state.preRegistration);
  const { appId } = useContext(AppContext);

  const onStoreUrlSubmit = async (data: { storeUrl: string }) => {
    // Check for pre-registration
    const result = await dispatch(lookupByStoreUrl({
      storeUrl: data.storeUrl,
      appId
    })).unwrap();

    if (result.found) {
      // Pre-registration found - component will show confirmation
      return;
    } else {
      // Not found - continue normal flow (email step)
      continueNormalFlow(data.storeUrl);
    }
  };

  if (found && current) {
    return (
      <PreRegFound
        preRegistration={current}
        onConnect={() => {
          window.location.href = current.installLink;
        }}
        loading={loading}
        channelName={channelName}
      />
    );
  }

  // Normal store URL form
  return <StoreUrlForm onSubmit={onStoreUrlSubmit} />;
}
```

---

## OAuth Integration Patterns

### OAuth Redirect Flow

```typescript
// When pre-registration found, redirect to install link
const handleConnect = () => {
  // No need for loading state - navigating away immediately
  window.location.href = preRegistration.installLink;
};
```

### Install Link Format

Backend provides the OAuth URL:
```typescript
interface IPreRegistration {
  merchantId: number;
  merchantName: string;
  storeUrl: string;
  platform: 'shopify' | 'bigcommerce' | 'woocommerce';
  installLink: string;  // Full OAuth URL with state/redirect params
  status: 'pending' | 'active';
}
```

---

## Asset Handling

### SVG Icons - Use SVGR

❌ **WRONG** - Inline SVG in JSX:
```typescript
<div>
  <svg viewBox="0 0 24 24">
    <path d="M8 12l2.5 2.5L16 9" />
  </svg>
</div>
```

✅ **CORRECT** - SVGR Import:
```typescript
// 1. Create SVG file: svg/CheckCircle.svg
// svg/CheckCircle.svg content:
// <svg viewBox="0 0 24 24">
//   <path d="M8 12l2.5 2.5L16 9" />
// </svg>

// 2. Import with SVGR
import CheckCircle from '@/svg/CheckCircle.svg';

function Component() {
  return (
    <div>
      <CheckCircle className={styles.icon} />
    </div>
  );
}
```

**Why**: SVGR provides type safety, reusability, and smaller bundle size.

---

## Form Handling with React Hook Form

```typescript
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';

const schema = yup.object({
  storeUrl: yup.string()
    .required('Store URL is required')
    .url('Must be a valid URL')
}).required();

function StoreUrlForm({ onSubmit }) {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: yupResolver(schema)
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('storeUrl')} />
      {errors.storeUrl && <span>{errors.storeUrl.message}</span>}
      <button type="submit">Continue</button>
    </form>
  );
}
```

---

## Component Patterns

### PreRegFound Component (Flow B/C Success)

```typescript
interface PreRegFoundProps {
  preRegistration: IPreRegistration;
  onConnect: () => void;
  loading?: boolean;
  channelName?: string;
}

const PreRegFound = ({
  preRegistration,
  onConnect,
  loading = false,
  channelName
}: PreRegFoundProps) => {
  return (
    <div className={styles.container}>
      <CheckCircleIcon className={styles.checkIcon} />

      <h2 className={cx('pageHeader', styles.title)}>
        Your store is already set up!
      </h2>

      <p className={styles.subtitle}>
        We found your pre-registration. Click below to connect your Shopify store.
      </p>

      <div className={styles.storeCard}>
        <StoreIcon className={styles.storeIcon} />
        <div className={styles.storeDetails}>
          <div className={styles.merchantName}>{preRegistration.merchantName}</div>
          <div className={styles.storeUrl}>{preRegistration.storeUrl}</div>
        </div>
      </div>

      <VioletButton
        className={styles.connectButton}
        text="Connect to Shopify"
        onClick={onConnect}
        loading={loading}
        disabled={loading}
        type="button"
      />

      <p className={styles.helpText}>
        Not your store? Contact {channelName || 'your channel partner'} for assistance.
      </p>
    </div>
  );
};
```

### PreRegError Component (Flow C Failure)

```typescript
interface PreRegErrorProps {
  message: string;
  channelName?: string;
}

const PreRegError = ({ message, channelName }: PreRegErrorProps) => {
  return (
    <div className={styles.errorContainer}>
      <AlertIcon className={styles.errorIcon} />

      <h2 className={cx('pageHeader', styles.title)}>
        We couldn't find your registration
      </h2>

      <p className={styles.message}>{message}</p>

      <p className={styles.helpText}>
        Please contact {channelName || 'your channel partner'} for a new registration link.
      </p>
    </div>
  );
};
```

---

## Testing Patterns

### Redux Thunk Testing

```typescript
import { lookupByStoreUrl } from '@/redux/slices/preRegistration';
import axiosWrapper from '@/utils/axiosWrapper';

jest.mock('@/utils/axiosWrapper');

describe('preRegistration thunks', () => {
  it('should handle successful lookup', async () => {
    const mockData = { merchantId: 123, storeUrl: 'test.myshopify.com' };
    (axiosWrapper as jest.Mock).mockResolvedValue({ data: mockData });

    const result = await dispatch(lookupByStoreUrl({
      storeUrl: 'test.myshopify.com',
      appId: 1
    })).unwrap();

    expect(result.found).toBe(true);
    expect(result.preRegistration).toEqual(mockData);
  });

  it('should handle 404 as not found', async () => {
    (axiosWrapper as jest.Mock).mockRejectedValue({
      response: { status: 404 }
    });

    const result = await dispatch(lookupByStoreUrl({
      storeUrl: 'notfound.myshopify.com',
      appId: 1
    })).unwrap();

    expect(result.found).toBe(false);
    expect(result.preRegistration).toBeNull();
  });
});
```

### Component Testing

```typescript
import { render, screen } from '@testing-library/react';
import PreRegFound from '@/components/PreRegistration/PreRegFound';

describe('PreRegFound', () => {
  const mockPreReg = {
    merchantId: 123,
    merchantName: 'Test Store',
    storeUrl: 'test.myshopify.com',
    platform: 'shopify',
    installLink: 'https://shopify.com/install',
    status: 'pending'
  };

  it('displays merchant name and store URL', () => {
    render(
      <PreRegFound
        preRegistration={mockPreReg}
        onConnect={jest.fn()}
      />
    );

    expect(screen.getByText('Test Store')).toBeInTheDocument();
    expect(screen.getByText('test.myshopify.com')).toBeInTheDocument();
  });

  it('calls onConnect when button clicked', () => {
    const onConnect = jest.fn();
    render(
      <PreRegFound
        preRegistration={mockPreReg}
        onConnect={onConnect}
      />
    );

    screen.getByText('Connect to Shopify').click();
    expect(onConnect).toHaveBeenCalled();
  });
});
```

---

## Common Anti-Patterns

### ❌ DON'T: Modify Catchall Route

```typescript
// pages/[appAlias]/[[...catchall]].tsx
// ❌ NEVER add feature-specific logic here - it breaks existing functionality
function CatchallPage() {
  useEffect(() => {
    // ❌ DON'T - This is for 404 handling only
    if (router.query.merchantId) {
      dispatch(lookupByMerchantId(router.query.merchantId));
    }
  }, []);
}
```

**Why**: The catchall route handles undefined pages. Adding feature logic breaks 404 behavior and graceful fallbacks.

**Instead**: Use AppContext for query param detection.

---

### ❌ DON'T: Set Loading State Before Navigation

```typescript
// ❌ WRONG
const handleConnect = () => {
  setConnecting(true);  // ❌ Unnecessary - page unloads immediately
  window.location.href = installLink;
};
```

**Why**: The page navigates away immediately. The state change has no effect.

---

### ❌ DON'T: Use snake_case in Client Code

```typescript
// ❌ WRONG
const params = { store_url: storeUrl, app_id: appId };
```

✅ **CORRECT**:
```typescript
const params = { storeUrl, appId };  // axiosWrapper converts to snake_case
```

---

## Quick Reference: ADR Summary

| ADR | Rule | Tool/Pattern |
|-----|------|--------------|
| ADR-002 | Use Redux for state management | `createAsyncThunk`, `createSlice` |
| ADR-006 | Use axiosWrapper for HTTP | `axiosWrapper({ url, method, params })` |
| ADR-007 | Use AppContext for app state | Extend `AppContext`, don't modify catchall |
| ADR-008 | API routes are lightweight proxies | Pass through requests/responses only |

---

## File Structure

```
VioletConnect/
├── redux/
│   └── slices/
│       └── preRegistration.ts      # Redux slice + thunks
├── components/
│   └── PreRegistration/
│       ├── PreRegFound.tsx          # Flow B/C success UI
│       ├── PreRegError.tsx          # Flow C failure UI
│       └── PreRegConfirmation.tsx   # Flow C confirmation
├── contexts/
│   └── AppContext.tsx               # App-wide state (extend here)
├── pages/
│   ├── api/
│   │   └── pre-register/
│   │       ├── lookup.ts            # Lookup by store URL
│   │       └── [merchantId].ts      # Lookup by merchantId
│   └── [appAlias]/
│       ├── shopify-url.tsx          # Flow B integration point
│       └── index.tsx                # Flow C integration point (AppContext)
├── utils/
│   ├── axiosWrapper.ts              # HTTP client (use this)
│   └── backendApi.ts                # Backend API client
└── svg/
    ├── CheckCircle.svg              # Success icon
    └── Store.svg                    # Store icon
```

---

## Related Documentation

- **Architecture Spec**: `prism-brain/product/specs/merchant-pre-registration/04-architecture.md`
- **Implementation Plan**: `prism-brain/product/specs/merchant-pre-registration/05-implementation.md`
- **PR Guides**: `prism-brain/product/specs/merchant-pre-registration/guides/violet-connect/`
- **API Documentation**: `prism-brain/systems/merchant-service/pre-registration-api.md`
