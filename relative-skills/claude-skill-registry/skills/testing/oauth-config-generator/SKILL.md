---
name: oauth-config-generator
description: Generate OAuth 2.0 configuration for social login providers (Google, GitHub, etc.). Triggers on "create oauth config", "generate oauth setup", "social login config", "oauth2 integration".
---

# OAuth Config Generator

Generate OAuth 2.0 configuration for social authentication providers.

## Output Requirements

**File Output:** `oauth.ts` with provider configurations
**Format:** Valid TypeScript
**Standards:** OAuth 2.0, Passport.js

## When Invoked

Immediately generate complete OAuth configuration for specified providers.

## Example Invocations

**Prompt:** "Create OAuth config for Google and GitHub"
**Output:** Complete OAuth setup with both providers.
