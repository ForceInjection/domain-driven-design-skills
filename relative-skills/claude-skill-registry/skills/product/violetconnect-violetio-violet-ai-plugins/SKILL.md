---
name: violetconnect
description: VioletConnect core features - merchant onboarding application architecture
---

# VioletConnect: Core Features

## Overview

VioletConnect is Violet's **merchant onboarding application** that handles OAuth flows for connecting merchant stores to channels through the Violet platform.

**Purpose**: Enable merchants to connect their e-commerce stores (Shopify, BigCommerce, WooCommerce, etc.) to channel applications through a guided onboarding flow.

**Repository**: `VioletConnect`
**Tech Stack**: Next.js 12.2.5, React 17.0.2, Redux Toolkit, SCSS modules
**URL Pattern**: `connect.violet.io/{appAlias}`

**Related Skills**:
- **violetconnect-patterns**: Code patterns for implementing VioletConnect features
- **violetconnect-shopify**: Shopify-specific integration details
- **violetconnect-bigcommerce**: BigCommerce-specific integration details
- **violetconnect-woocommerce**: WooCommerce-specific integration details

---

## Subdomain Routing & AppAlias System

VioletConnect uses **subdomain routing** to support multi-tenancy for channels.

### How It Works

```
URL: connect.violet.io/{appAlias}/...
Example: connect.violet.io/andydev/platforms/shopify
```

**appAlias** identifies the channel (e.g., `andydev`, `testchannel`):
- Maps to an `appId` in the database
- Determines which channel's branding, configuration, and credentials to use
- Enables white-label onboarding experiences per channel

### Dynamic Routing Structure

```
pages/
└── [appAlias]/
    ├── index.tsx                    # Landing page
    ├── platforms/
    │   └── [platform]/
    │       ├── index.tsx            # Platform selection/store URL entry
    │       └── callback.tsx         # OAuth callback handler
    ├── merchant-migration/
    │   └── [platform]/
    │       └── index.tsx            # Migration flow (existing merchants)
    └── [[...catchall]].tsx          # 404 handler
```

### AppAlias Detection

VioletConnect detects `appAlias` from the URL and loads channel configuration:

```typescript
// Detected in AppContext
const appAlias = router.query.appAlias as string;

// Fetches channel config
GET /api/apps/bySubdomain/{appAlias}

Response: {
  appId: number,
  appAlias: string,
  channelName: string,
  supportedPlatforms: string[],
  logoUrl: string,
  // ... channel-specific config
}
```

---

## Session Management & Authentication

### Session Flow

```
1. Merchant lands on VioletConnect with appAlias
2. Merchant enters email
3. VioletConnect creates session (cookie-based)
4. Session persists through OAuth flow
5. Session used to associate merchant with channel
```

### Session Storage

- **Storage**: Redis (session data)
- **Cookie**: `connect.sid` (httpOnly, secure)
- **Lifetime**: 24 hours
- **Contents**: `sessionId`, `appId`, `email`, `merchantId` (after OAuth)

### Authentication States

| State | Description | Next Step |
|-------|-------------|-----------|
| **No Session** | First visit | Prompt for email |
| **Session, No OAuth** | Email entered | Prompt for store URL or platform |
| **Session, OAuth Complete** | Merchant connected | Commission/payout configuration |
| **Session Expired** | 24h timeout | Re-enter email |

---

## The 13-Step Onboarding Wizard

VioletConnect guides merchants through a **13-step onboarding process** from initial contact to fully configured merchant.

### Standard Flow (Email-First)

```
Step 1:  Merchant lands on VioletConnect (via appAlias URL)
Step 2:  Merchant enters email → Creates session
Step 3:  Merchant selects platform (Shopify, BigCommerce, WooCommerce, etc.)
Step 4:  Merchant enters store URL
Step 5:  VioletConnect validates store URL
Step 6:  VioletConnect redirects to platform OAuth
Step 7:  Merchant approves app in platform admin
Step 8:  Platform redirects back to VioletConnect callback
Step 9:  VioletConnect exchanges code for access token (server-side)
Step 10: VioletConnect creates merchant record in MerchantService
Step 11: Merchant enters commission settings
Step 12: Merchant enters payout settings
Step 13: Success - Merchant redirected to dashboard or success page
```

### Merchant Migration Flow (Existing Merchants)

For merchants already on Violet moving to a new channel:

```
URL: connect.violet.io/{appAlias}/merchant-migration/{platform}

Step 1: Merchant lands with migration URL
Step 2: Email entry (or skip if already logged in)
Step 3: Store URL entry
Step 4: VioletConnect detects existing merchant
Step 5: Merchant approves new channel access
Step 6: Commission/payout settings inherited or updated
Step 7: Success - Merchant connected to new channel
```

**Key Difference**: Skips OAuth (merchant already has credentials), just associates with new channel.

---

## Email-First Flow

The standard onboarding path starts with email entry to create a session **before** OAuth.

### Why Email-First?

1. **Session Creation**: Establishes session before redirecting to external platform
2. **Channel Association**: Links merchant to correct channel from the start
3. **Recovery**: Enables email-based session recovery if OAuth fails
4. **Marketing**: Captures email even if merchant doesn't complete OAuth

### Email Entry Component

```
Page: pages/[appAlias]/index.tsx

UI:
- Channel logo/branding
- "Connect your {platform} store to {channelName}"
- Email input field
- "Continue" button
- Help text: "We'll guide you through connecting your store"

On Submit:
- POST /api/session/create { email, appId }
- Creates session with email + appId
- Redirects to platform selection or direct platform URL
```

---

## Commission & Payout Configuration

After OAuth completes, merchants configure **commission rates** and **payout settings**.

### Commission Configuration

```typescript
interface CommissionSettings {
  rateType: 'percentage' | 'flat';
  rateValue: number;              // e.g., 15 (for 15%) or 5.00 (for $5)
  applyTo: 'order' | 'product';   // Commission on order total or per product
}
```

**UI**: Simple form with:
- Rate type selector (percentage/flat)
- Rate value input
- Apply to selector (order/product)
- "Save & Continue" button

### Payout Configuration

```typescript
interface PayoutSettings {
  method: 'bank_transfer' | 'paypal' | 'check';
  bankDetails?: {
    accountNumber: string;
    routingNumber: string;
    accountName: string;
  };
  paypalEmail?: string;
  mailingAddress?: Address;
  payoutSchedule: 'weekly' | 'biweekly' | 'monthly';
}
```

**UI**: Multi-step form:
1. Select payout method
2. Enter payment details (bank/PayPal/address)
3. Select payout schedule
4. Review & confirm

---

## Channel Configuration & Multi-Tenancy

Each channel has its own configuration that determines VioletConnect behavior.

### Channel Configuration Structure

```typescript
interface ChannelConfig {
  appId: number;
  appAlias: string;
  channelName: string;
  logoUrl: string;
  supportedPlatforms: Platform[];
  defaultCommissionRate?: number;
  requiresCommissionConfig: boolean;
  requiresPayoutConfig: boolean;
  customSuccessUrl?: string;
  brandingColors: {
    primary: string;
    secondary: string;
  };
  shopifyClientId?: string;
  bigcommerceClientId?: string;
  // ... platform-specific credentials
}
```

### How Channels Are Isolated

- **URL**: Each channel gets unique appAlias subdomain
- **Branding**: Logo, colors, channel name per config
- **Credentials**: Platform OAuth credentials stored per channel
- **Features**: Supported platforms, required config steps vary by channel
- **Redirects**: Post-onboarding redirect URLs customizable per channel

---

## AppContext Data Structure

AppContext is VioletConnect's **application-wide context provider**. It manages data available throughout the app.

### What AppContext Provides

```typescript
interface AppContextValue {
  // Channel Information
  appId: number;
  appAlias: string;
  channelName: string;
  channelConfig: ChannelConfig;

  // Session & Authentication
  isAuthenticated: boolean;
  sessionId: string;
  email?: string;

  // Merchant Information
  merchantId?: string;           // From query param or post-OAuth
  merchantData?: Merchant;       // After OAuth completes

  // Platform Selection
  selectedPlatform?: Platform;

  // OAuth State
  oauthInProgress: boolean;
  oauthError?: string;

  // Pre-Registration (if applicable)
  preRegistrationId?: string;
  hasPreRegistration: boolean;
}
```

### When AppContext Is Populated

| Data | When Populated | Source |
|------|----------------|--------|
| `appId`, `appAlias` | App load | URL + API fetch |
| `channelConfig` | App load | GET /api/apps/bySubdomain/{appAlias} |
| `sessionId`, `email` | Email entry | POST /api/session/create |
| `selectedPlatform` | Platform selection | User input or URL |
| `merchantId` | Query param or post-OAuth | URL or MerchantService response |
| `merchantData` | Post-OAuth | MerchantService response |
| `hasPreRegistration` | Pre-reg check | GET /api/pre-register/lookup |

### How to Access AppContext

```typescript
import { useContext } from 'react';
import { AppContext } from '@/contexts/AppContext';

function MyComponent() {
  const { appId, channelName, merchantId, isAuthenticated } = useContext(AppContext);

  // Use context data...
}
```

---

## MerchantService Integration

VioletConnect integrates with **MerchantService** to create and manage merchant records.

### Key Integration Points

#### 1. Create Merchant (Post-OAuth)

```
POST /merchants/external
Headers: X-Violet-Token, X-Violet-App-Secret, X-Violet-App-Id
Body: {
  email: string,
  platform: string,
  storeUrl: string,
  accessToken: string,  // From OAuth
  shopDomain: string,   // Platform-specific
  appId: number
}

Response: {
  merchantId: number,
  status: 'active',
  dateCreated: string
}
```

#### 2. Pre-Registration Lookup

```
GET /merchants/external/pre-register?store_url={url}&app_id={id}
Headers: X-Violet-Token, X-Violet-App-Secret, X-Violet-App-Id

Response: {
  merchantId: number,
  merchantName: string,
  storeUrl: string,
  platform: string,
  installLink: string,
  status: 'pending'
}
```

#### 3. Update Merchant Settings

```
PUT /merchants/external/{merchantId}
Headers: X-Violet-Token, X-Violet-App-Secret, X-Violet-App-Id
Body: {
  commissionRate: number,
  payoutMethod: string,
  payoutDetails: object
}
```

### Authentication Headers

VioletConnect must include these headers for all MerchantService calls:

- `X-Violet-Token`: Session-based auth token
- `X-Violet-App-Secret`: Channel app secret
- `X-Violet-App-Id`: Channel app ID

---

## Success & Error Patterns

### Success Flow

After merchant completes all steps:

```
Page: pages/[appAlias]/success.tsx

UI:
- Success icon/animation
- "You're all set!"
- Summary of what was configured
- "Go to Dashboard" button (if channel has dashboard)
- Or redirect to channel's custom success URL

Triggers:
- Analytics event: 'merchant_onboarding_complete'
- Email notification to merchant (optional)
- Webhook to channel (optional)
```

### Error Patterns

VioletConnect handles several error scenarios:

#### OAuth Denied

```
URL: callback?error=access_denied

UI:
- "Authorization Cancelled"
- "You declined to connect your store. Please try again."
- "Return to Setup" button → Restart OAuth
```

#### Invalid Store URL

```
Triggered: During store URL validation

UI:
- Inline error below store URL input
- "Invalid store URL format. Must be *.myshopify.com" (platform-specific)
- Input highlighted in red
```

#### Session Expired

```
Triggered: When OAuth callback finds no session

UI:
- "Session Expired"
- "Your session has expired. Please start over."
- "Start Over" button → Return to email entry
```

#### Store Already Connected

```
Triggered: MerchantService returns 409 Conflict

UI:
- "Store Already Connected"
- "This store is already connected to another channel."
- "Contact support if you need help: {supportEmail}"
```

---

## Pre-Registration Integration

VioletConnect supports **merchant pre-registration** to streamline onboarding.

### Pre-Registration Flows

VioletConnect detects pre-registration in three ways:

#### Flow A: Direct Install Link (Shopify Only)
- Channel sends Shopify install link directly to merchant
- Merchant bypasses VioletConnect
- Shopify redirects to VioletConnect callback with no session
- VioletConnect detects pre-registration by store URL
- Resumes flow with pre-stored credentials

#### Flow B: Store URL Lookup
- Merchant enters store URL in VioletConnect
- VioletConnect checks for pre-registration
- If found: Show confirmation, skip email step
- If not found: Continue normal email-first flow

#### Flow C: MerchantId Link
- Channel sends: `connect.violet.io/{appAlias}?merchantId={id}`
- AppContext detects merchantId parameter
- VioletConnect looks up pre-registration
- If found: Show confirmation, skip email + store URL steps
- If not found: Show error (invalid link)

### Pre-Registration Benefits

- **Faster Onboarding**: Skip email and/or store URL entry
- **Pre-Fill Credentials**: OAuth credentials already stored
- **Channel Control**: Channel manages merchant credentials upfront
- **Better UX**: "Your store is already set up!" message

---

## Platform Support

VioletConnect supports **43 platforms** via the `Merchant.Platform` enum.

### Primary Platforms (Full OAuth Support)

| Platform | OAuth Type | Identifier |
|----------|------------|------------|
| Shopify | Centralized OAuth 2.0 | Store URL (*.myshopify.com) |
| BigCommerce | Centralized OAuth 2.0 | Store Hash (abc123) |
| WooCommerce | REST API Keys | Store URL (any domain) |

### Secondary Platforms (Basic Support)

- Magento 2
- Salesforce Commerce Cloud
- Adobe Commerce
- Wix
- Squarespace
- And 35+ more...

**Note**: See platform-specific skills for integration details:
- `violetconnect-shopify`
- `violetconnect-bigcommerce`
- `violetconnect-woocommerce`

---

## Testing & Development

### Local Development

```bash
# Start VioletConnect locally
cd VioletConnect
npm install
npm run dev  # Port 3001

# Configure /etc/hosts for subdomain testing
127.0.0.1 appname.localhost

# Access: http://appname.localhost:3001
```

### Environment Variables

```bash
# Required for local development
VIOLET_API_URL=http://localhost:8080
REDIS_URL=redis://localhost:6379
SESSION_SECRET=your-secret-key

# Platform OAuth credentials (per channel)
SHOPIFY_CLIENT_ID=...
SHOPIFY_CLIENT_SECRET=...
BIGCOMMERCE_CLIENT_ID=...
BIGCOMMERCE_CLIENT_SECRET=...
```

### E2E Testing

```bash
# Run Playwright E2E tests
npm run test:e2e

# Test specific flow
npm run test:e2e -- --grep "Shopify onboarding"
```

---

## File Structure Overview

```
VioletConnect/
├── pages/
│   ├── [appAlias]/
│   │   ├── index.tsx                      # Landing page (email entry)
│   │   ├── platforms/
│   │   │   └── [platform]/
│   │   │       ├── index.tsx              # Store URL entry + OAuth redirect
│   │   │       └── callback.tsx           # OAuth callback handler
│   │   ├── merchant-migration/
│   │   │   └── [platform]/
│   │   │       └── index.tsx              # Migration flow
│   │   ├── commission.tsx                 # Commission config
│   │   ├── payout.tsx                     # Payout config
│   │   ├── success.tsx                    # Success page
│   │   └── [[...catchall]].tsx            # 404 handler
│   └── api/
│       ├── apps/
│       │   └── bySubdomain/[subdomain]/
│       │       └── index.ts               # Fetch channel config
│       ├── session/
│       │   ├── create.ts                  # Create session
│       │   └── validate.ts                # Validate session
│       ├── merchants/
│       │   └── create.ts                  # Create merchant (post-OAuth)
│       └── pre-register/
│           ├── lookup.ts                  # Pre-reg lookup by store URL
│           └── [merchantId].ts            # Pre-reg lookup by merchantId
├── contexts/
│   └── AppContext.tsx                     # Application-wide context
├── components/
│   ├── EmailEntry/                        # Email entry form
│   ├── StoreUrlInput/                     # Store URL input (platform-specific)
│   ├── CommissionForm/                    # Commission configuration
│   ├── PayoutForm/                        # Payout configuration
│   ├── PreRegistration/                   # Pre-reg confirmation UI
│   └── SuccessPage/                       # Success page components
├── redux/
│   └── slices/
│       ├── session.ts                     # Session state
│       ├── merchant.ts                    # Merchant data
│       └── preRegistration.ts             # Pre-reg state
└── utils/
    ├── axiosWrapper.ts                    # HTTP client
    └── validation/                        # Store URL validators
```

---

## Related Documentation

### System Docs
- **Merchant Onboarding Flow**: `prism-brain/systems/violet-connect/merchant-onboarding-flow.md`
- **Component Inventory**: `prism-brain/systems/violet-connect/component-inventory.md`
- **Test Coverage**: `prism-brain/systems/violet-connect/test-coverage.md`

### Implementation
- **violetconnect-patterns**: Code patterns for implementing VioletConnect features
- **Implementation Specs**: `prism-brain/product/specs/merchant-pre-registration/`

### Platform Integration
- **violetconnect-shopify**: Shopify OAuth and integration details
- **violetconnect-bigcommerce**: BigCommerce OAuth and embedded app details
- **violetconnect-woocommerce**: WooCommerce REST API details
