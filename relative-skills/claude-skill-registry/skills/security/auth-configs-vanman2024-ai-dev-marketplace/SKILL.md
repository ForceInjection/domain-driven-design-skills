---
name: auth-configs
description: Configure Supabase authentication providers (OAuth, JWT, email). Use when setting up authentication, configuring OAuth providers (Google/GitHub/Discord), implementing auth flows, configuring JWT settings, or when user mentions Supabase auth, social login, authentication setup, or auth configuration.
allowed-tools: Bash, Read, Write, Edit, WebFetch
---

# auth-configs

## Instructions

This skill provides complete authentication configuration for Supabase-powered AI applications. It covers OAuth provider setup, JWT configuration, email authentication with PKCE flow, and auth middleware templates.

### 1. OAuth Provider Setup

Configure social login providers for your Supabase project:

**Supported Providers:**
- Google - Best for consumer apps, Google Workspace integration
- GitHub - Ideal for developer tools, technical audiences
- Discord - Perfect for community-driven AI applications
- Facebook, Apple, Microsoft Azure, Twitter, LinkedIn, Slack, and 20+ more

**Setup Process:**
```bash
# Configure OAuth provider (creates config, provides setup instructions)
bash /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/scripts/setup-oauth-provider.sh google

# Or use template directly
cat /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/templates/oauth-providers/google-oauth-config.json
```

**Provider Setup Steps:**
1. Create OAuth application in provider console (Google Cloud, GitHub Settings, etc)
2. Configure authorized redirect URIs (template provides exact URLs)
3. Copy Client ID and Client Secret
4. Update Supabase project auth settings
5. Test authentication flow

### 2. JWT Configuration

Configure JSON Web Token settings for secure session management:

```bash
# Set up JWT signing secrets and configuration
bash /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/scripts/configure-jwt.sh
```

**JWT Settings:**
- Signing algorithm (HS256 recommended for most apps)
- Token expiration times (access and refresh tokens)
- JWT secret rotation
- Custom claims for role-based access

### 3. Email Authentication with PKCE Flow

Configure secure email authentication for server-side rendering:

```bash
# Set up email auth with PKCE flow for SSR applications
bash /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/scripts/setup-email-auth.sh
```

**Email Auth Features:**
- Password-based authentication
- Magic link (passwordless) login
- Email verification templates
- Password reset flow
- PKCE flow for SSR security

### 4. Auth Middleware & Helpers

Use pre-built middleware templates for Next.js and other frameworks:

**Next.js Middleware:**
```typescript
// Copy template and customize
cp /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/templates/middleware/auth-middleware.ts ./middleware.ts
```

**Auth Helper Functions:**
```typescript
// Reusable auth utilities
cp /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/templates/helpers/auth-helpers.ts ./lib/auth.ts
```

### 5. Testing Authentication Flows

Validate your authentication setup end-to-end:

```bash
# Test all configured auth flows
bash /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/scripts/test-auth-flow.sh
```

**Tests Include:**
- OAuth provider redirect flows
- Email/password authentication
- Session persistence
- Token refresh handling
- Protected route access

## Examples

### Example 1: Setting Up Google OAuth for AI Chat Application

```bash
# 1. Run OAuth setup script
bash /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/scripts/setup-oauth-provider.sh google

# 2. Follow prompts to configure:
#    - Google Cloud Console OAuth app
#    - Authorized redirect URIs
#    - Client credentials in Supabase

# 3. Add middleware to Next.js app
cp /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/templates/middleware/auth-middleware.ts ./middleware.ts

# 4. Test the flow
bash /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/scripts/test-auth-flow.sh
```

**Result:** Fully configured Google OAuth with protected routes and session management

### Example 2: Multi-Provider Setup for RAG Application

Configure multiple OAuth providers for user choice:

```bash
# Set up Google, GitHub, and Discord
for provider in google github discord; do
  bash /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/scripts/setup-oauth-provider.sh $provider
done

# Configure email auth as fallback
bash /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/scripts/setup-email-auth.sh

# Test all providers
bash /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/scripts/test-auth-flow.sh --all
```

**Result:** Users can sign in with Google, GitHub, Discord, or email

### Example 3: AI Platform with Role-Based Access

Configure JWT claims for AI model access control:

```bash
# 1. Set up JWT with custom claims
bash /home/vanman2025/Projects/ai-dev-marketplace/plugins/supabase/skills/auth-configs/scripts/configure-jwt.sh

# 2. Add role-based middleware
# Edit middleware.ts to check JWT claims for AI model permissions

# 3. Configure RLS policies in Supabase
# Link JWT claims to database row-level security
```

**Result:** Different user tiers (free, pro, enterprise) with model access control

## Requirements

**Environment Variables:**
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Public anonymous key
- `SUPABASE_SERVICE_ROLE_KEY` - Service role key (for admin operations)
- Provider-specific credentials (Google, GitHub, etc Client IDs and Secrets)

**Dependencies:**
- `@supabase/supabase-js` - Supabase JavaScript client
- `@supabase/ssr` - Server-side rendering support (replaces deprecated auth-helpers)
- Node.js 18+ or compatible runtime
- jq (for JSON processing in scripts)

**Supabase Project Setup:**
- Active Supabase project (free tier works)
- Email authentication enabled in project settings
- Custom SMTP configured (optional, for branded emails)

**For OAuth Providers:**
- Developer accounts on each platform (Google Cloud, GitHub, Discord Developer Portal)
- Ability to create OAuth applications
- Access to configure redirect URIs

## AI Application Patterns

**Multi-User AI Chat:**
- OAuth for quick onboarding
- Session-based conversation history
- User-specific API usage tracking

**RAG Systems:**
- Email auth for document ownership
- JWT claims for data access control
- Secure document storage per user

**AI API Platforms:**
- OAuth for developer authentication
- JWT tokens for API key management
- Rate limiting per user tier

## Security Best Practices

**Never Hardcode Secrets:**
```bash
# ✅ CORRECT - Use environment variables
export GOOGLE_CLIENT_SECRET="your-secret-here"

# ❌ WRONG - Never commit secrets
const secret = "GOCSPX-abc123..." // DON'T DO THIS
```

**Use PKCE Flow for SSR:**
- Required for Next.js, SvelteKit, Remix
- Prevents authorization code interception
- Mandatory for production applications

**Validate Redirect URLs:**
- Whitelist exact redirect URIs in provider console
- Use HTTPS in production (HTTP only for localhost development)
- Never allow wildcard redirects

**Rotate JWT Secrets:**
- Change JWT signing secret periodically
- Use strong random strings (min 32 characters)
- Store in environment variables, never in code

---

**Plugin:** supabase
**Version:** 1.0.0
**Category:** Authentication
**Skill Type:** Configuration
