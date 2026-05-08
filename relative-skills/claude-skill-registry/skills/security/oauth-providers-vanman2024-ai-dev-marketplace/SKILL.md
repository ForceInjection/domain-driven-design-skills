---
name: oauth-providers
description: Configure OAuth authentication providers for Clerk (Google, GitHub, Discord, Apple, Microsoft, Facebook, LinkedIn, Twitter, and 11+ more). Use when setting up social login, configuring OAuth providers, implementing authentication flows, generating redirect URLs, testing OAuth connections, or when user mentions Clerk OAuth, social authentication, provider setup, or multi-provider auth.
allowed-tools: Bash, Read, Write, Edit, WebFetch
---

# oauth-providers

## Instructions

This skill provides complete OAuth provider configuration for Clerk-powered applications. It covers all 19+ supported OAuth providers with templates, setup scripts, testing utilities, and integration patterns for Next.js, React, and other frameworks.

### Supported OAuth Providers

**Tier 1 (Most Common):**
- Google - Consumer apps, Google Workspace integration
- GitHub - Developer tools, technical audiences
- Discord - Gaming, community platforms
- Microsoft - Enterprise applications, Microsoft 365 integration

**Tier 2 (Social & Professional):**
- Facebook - Social applications, consumer products
- LinkedIn - Professional networks, B2B applications
- Twitter/X - Social media integration
- Apple - iOS applications, consumer products

**Tier 3 (Specialized):**
- GitLab - Developer platforms, CI/CD tools
- Bitbucket - Atlassian ecosystem integration
- Dropbox - File storage integration
- Notion - Productivity app integration
- Slack - Workspace collaboration
- Linear - Project management tools
- Coinbase - Crypto wallet authentication
- TikTok - Short-form video platforms
- Twitch - Live streaming platforms
- HubSpot - CRM integration
- X/Twitter - Social media (rebranded)

### 1. Provider Setup Script

Configure any OAuth provider with automated setup:

```bash
# Set up single provider
bash scripts/setup-provider.sh google

# Set up multiple providers
bash scripts/setup-provider.sh google github discord

# Interactive setup with prompts
bash scripts/setup-provider.sh --interactive
```

**What the Script Does:**
1. Detects Clerk project configuration
2. Generates provider-specific configuration
3. Creates redirect URLs for all environments (dev, staging, production)
4. Provides step-by-step setup instructions
5. Generates environment variable templates
6. Creates provider testing utilities

**Output:**
- Provider configuration JSON
- Environment variable template
- Setup instructions markdown
- Test credentials configuration

### 2. Generate Redirect URLs

Generate callback URLs for all environments:

```bash
# Generate for specific provider
bash scripts/generate-redirect-urls.sh google

# Generate for all configured providers
bash scripts/generate-redirect-urls.sh --all

# Export to environment file
bash scripts/generate-redirect-urls.sh google --export > .env.oauth
```

**Redirect URL Patterns:**
```
Development:
http://localhost:3000/api/auth/callback/google

Production:
https://yourdomain.com/api/auth/callback/google

Clerk Default:
https://your-clerk-domain.clerk.accounts.dev/v1/oauth_callback
```

### 3. Test OAuth Flow

Validate OAuth configuration end-to-end:

```bash
# Test single provider
bash scripts/test-oauth-flow.sh google

# Test all providers
bash scripts/test-oauth-flow.sh --all

# Generate test report
bash scripts/test-oauth-flow.sh google --report
```

**Tests Performed:**
- Provider configuration validation
- Redirect URL accessibility
- OAuth flow initiation
- Callback handling
- Token exchange validation
- User profile retrieval
- Error handling scenarios

### 4. Provider Templates

Access pre-configured templates for each provider:

**Google OAuth:**
```typescript
// templates/google/clerk-config.ts
import { google } from '@clerk/clerk-sdk-node';

export const googleConfig = {
  clientId: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  redirectUri: process.env.GOOGLE_REDIRECT_URI,
  scopes: ['profile', 'email'],
  // Google-specific options
  accessType: 'offline',
  prompt: 'consent'
};
```

**GitHub OAuth:**
```typescript
// templates/github/clerk-config.ts
export const githubConfig = {
  clientId: process.env.GITHUB_CLIENT_ID,
  clientSecret: process.env.GITHUB_CLIENT_SECRET,
  redirectUri: process.env.GITHUB_REDIRECT_URI,
  scopes: ['read:user', 'user:email'],
  // GitHub-specific options
  allowSignup: true
};
```

**Discord OAuth:**
```typescript
// templates/discord/clerk-config.ts
export const discordConfig = {
  clientId: process.env.DISCORD_CLIENT_ID,
  clientSecret: process.env.DISCORD_CLIENT_SECRET,
  redirectUri: process.env.DISCORD_REDIRECT_URI,
  scopes: ['identify', 'email'],
  // Discord-specific options
  permissions: '0'
};
```

### 5. Multi-Provider Integration

**React/Next.js Components:**
```typescript
// templates/oauth-shared/AuthButtons.tsx
import { SignIn } from '@clerk/nextjs';

export function AuthButtons() {
  return (
    <div className="auth-providers">
      <SignIn.Root>
        <SignIn.Step name="start">
          <div className="provider-buttons">
            <SignIn.Strategy name="oauth_google">
              <button>Continue with Google</button>
            </SignIn.Strategy>
            <SignIn.Strategy name="oauth_github">
              <button>Continue with GitHub</button>
            </SignIn.Strategy>
            <SignIn.Strategy name="oauth_discord">
              <button>Continue with Discord</button>
            </SignIn.Strategy>
          </div>
        </SignIn.Step>
      </SignIn.Root>
    </div>
  );
}
```

**Clerk Dashboard Configuration:**
```typescript
// templates/oauth-shared/clerk-dashboard-config.ts
export const oauthProviders = [
  {
    provider: 'google',
    enabled: true,
    clientId: 'GOOGLE_CLIENT_ID',
    clientSecret: 'GOOGLE_CLIENT_SECRET',
    scopes: ['profile', 'email']
  },
  {
    provider: 'github',
    enabled: true,
    clientId: 'GITHUB_CLIENT_ID',
    clientSecret: 'GITHUB_CLIENT_SECRET',
    scopes: ['read:user', 'user:email']
  },
  {
    provider: 'discord',
    enabled: true,
    clientId: 'DISCORD_CLIENT_ID',
    clientSecret: 'DISCORD_CLIENT_SECRET',
    scopes: ['identify', 'email']
  }
];
```

## Examples

### Example 1: Google OAuth for SaaS Application

```bash
# 1. Set up Google OAuth
bash scripts/setup-provider.sh google

# Follow prompts:
# - Create OAuth app in Google Cloud Console
# - Configure authorized redirect URIs
# - Copy Client ID and Client Secret
# - Add to Clerk Dashboard

# 2. Generate redirect URLs
bash scripts/generate-redirect-urls.sh google --export > .env.google

# 3. Test OAuth flow
bash scripts/test-oauth-flow.sh google

# 4. Add to React app
cp templates/google/clerk-config.ts ./lib/auth/google.ts
cp templates/oauth-shared/AuthButtons.tsx ./components/auth/
```

**Result:** Fully configured Google OAuth with sign-in button and tested flow

### Example 2: Multi-Provider Authentication (Google + GitHub + Discord)

```bash
# Set up all providers
for provider in google github discord; do
  bash scripts/setup-provider.sh $provider
done

# Generate all redirect URLs
bash scripts/generate-redirect-urls.sh --all --export > .env.oauth

# Test all providers
bash scripts/test-oauth-flow.sh --all --report

# Deploy multi-provider UI
cp templates/oauth-shared/AuthButtons.tsx ./components/auth/
```

**Result:** Users can sign in with Google, GitHub, or Discord

### Example 3: Enterprise Application with Microsoft + LinkedIn

```bash
# Set up enterprise providers
bash scripts/setup-provider.sh microsoft linkedin

# Configure enterprise-specific scopes
# Edit templates/microsoft/clerk-config.ts to add Azure AD scopes
# Edit templates/linkedin/clerk-config.ts for LinkedIn API v2

# Test enterprise flows
bash scripts/test-oauth-flow.sh microsoft --report
bash scripts/test-oauth-flow.sh linkedin --report
```

**Result:** Enterprise authentication with Microsoft 365 and LinkedIn integration

### Example 4: Gaming Platform with Discord + Twitch

```bash
# Set up gaming providers
bash scripts/setup-provider.sh discord twitch

# Configure gaming-specific permissions
# Discord: guild membership, voice state
# Twitch: user:read:email, channel subscriptions

# Test gaming provider flows
bash scripts/test-oauth-flow.sh discord twitch
```

**Result:** Gaming platform authentication with Discord and Twitch integration

## Requirements

**Environment Variables:**
- `CLERK_PUBLISHABLE_KEY` - Clerk public key
- `CLERK_SECRET_KEY` - Clerk secret key
- Provider-specific credentials (e.g., `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`)

**Dependencies:**
- `@clerk/clerk-sdk-node` - Clerk Node.js SDK
- `@clerk/nextjs` - Clerk Next.js integration (for Next.js apps)
- `@clerk/clerk-react` - Clerk React components (for React apps)
- Node.js 18+ or compatible runtime
- jq (for JSON processing in scripts)

**Clerk Project Setup:**
- Active Clerk account (free tier available)
- Clerk application configured
- Development and production instances (optional)

**For Each OAuth Provider:**
- Developer account on provider platform
- OAuth application created
- Client credentials obtained
- Redirect URIs configured

## Security: API Key Handling

**CRITICAL:** When generating any configuration files or code:

- NEVER hardcode actual API keys or secrets
- NEVER include real credentials in examples
- NEVER commit sensitive values to git

- ALWAYS use placeholders: `your_service_key_here`
- ALWAYS create `.env.example` with placeholders only
- ALWAYS add `.env*` to `.gitignore` (except `.env.example`)
- ALWAYS read from environment variables in code
- ALWAYS document where to obtain keys

**Placeholder format:** `{provider}_{env}_your_key_here`

Example:
```bash
# .env.example (safe to commit)
GOOGLE_CLIENT_ID=google_dev_your_client_id_here
GOOGLE_CLIENT_SECRET=google_dev_your_client_secret_here

# .env (NEVER commit)
GOOGLE_CLIENT_ID=actual_client_id_from_google_cloud
GOOGLE_CLIENT_SECRET=actual_secret_from_google_cloud
```

## Provider-Specific Setup Guides

### Google OAuth Setup

**Documentation:** templates/google/SETUP.md

1. Create project in Google Cloud Console
2. Enable Google+ API
3. Configure OAuth consent screen
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs
6. Copy Client ID and Client Secret
7. Add to Clerk Dashboard

**Required Scopes:**
- `profile` - User profile information
- `email` - Email address
- `openid` - OpenID Connect

### GitHub OAuth Setup

**Documentation:** templates/github/SETUP.md

1. Navigate to GitHub Settings > Developer Settings
2. Create new OAuth App
3. Configure application name and homepage URL
4. Add authorization callback URL
5. Generate client secret
6. Add to Clerk Dashboard

**Required Scopes:**
- `read:user` - Read user profile
- `user:email` - Access user email addresses

### Discord OAuth Setup

**Documentation:** templates/discord/SETUP.md

1. Create application in Discord Developer Portal
2. Navigate to OAuth2 section
3. Add redirect URIs
4. Copy Client ID and Client Secret
5. Configure bot permissions (if needed)
6. Add to Clerk Dashboard

**Required Scopes:**
- `identify` - User identity
- `email` - Email address
- `guilds` - Server list (optional)

### Microsoft OAuth Setup

**Documentation:** templates/microsoft/SETUP.md

1. Register application in Azure AD Portal
2. Configure platform settings (Web)
3. Add redirect URIs
4. Generate client secret
5. Configure API permissions
6. Add to Clerk Dashboard

**Required Scopes:**
- `openid` - OpenID Connect
- `profile` - User profile
- `email` - Email address
- `User.Read` - Microsoft Graph API

### Apple OAuth Setup

**Documentation:** templates/apple/SETUP.md

1. Create App ID in Apple Developer Portal
2. Enable Sign in with Apple capability
3. Create Service ID
4. Configure domains and redirect URLs
5. Create private key for authentication
6. Add to Clerk Dashboard

**Required Scopes:**
- `name` - User name
- `email` - Email address

## Best Practices

**Multi-Provider Strategy:**
- Offer 2-3 primary providers (Google, GitHub, Discord)
- Add enterprise providers for B2B apps (Microsoft, LinkedIn)
- Include email/password as fallback option
- Test all providers regularly

**Redirect URL Management:**
- Use environment-specific URLs
- Whitelist exact URLs (no wildcards)
- Use HTTPS in production
- Document all redirect URLs

**Scope Configuration:**
- Request minimum necessary scopes
- Document why each scope is needed
- Handle scope changes gracefully
- Test with restricted scopes

**Error Handling:**
- Handle provider-specific errors
- Provide clear user feedback
- Log authentication failures
- Implement retry logic

**Testing:**
- Test all providers before launch
- Verify redirect URLs in all environments
- Test with fresh user accounts
- Validate token refresh flows

**Security:**
- Store credentials in environment variables
- Use HTTPS for all OAuth flows
- Implement CSRF protection
- Validate state parameter
- Rotate secrets periodically

## Troubleshooting

**Redirect URI Mismatch:**
- Verify exact URL match in provider console
- Check for trailing slashes
- Validate protocol (http vs https)
- Confirm environment configuration

**Invalid Client Credentials:**
- Verify client ID and secret are correct
- Check for whitespace in credentials
- Ensure credentials match environment
- Regenerate if compromised

**Scope Authorization Failed:**
- Verify scopes are supported by provider
- Check provider API version
- Validate scope syntax
- Request app review if needed (some providers)

**Token Exchange Error:**
- Verify authorization code is valid
- Check token endpoint URL
- Validate code verifier (PKCE)
- Ensure timely token exchange

**User Profile Retrieval Failed:**
- Verify access token is valid
- Check profile endpoint permissions
- Validate scope for profile access
- Handle rate limits

---

**Plugin:** clerk
**Version:** 1.0.0
**Category:** Authentication
**Skill Type:** Configuration
**Providers Supported:** 19+
