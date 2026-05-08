---
name: cloudflare-worker-base
description: |
  Set up Cloudflare Workers with Hono routing, Vite plugin, and Static Assets using production-tested patterns.
  Prevents 8 errors: export syntax, routing conflicts, HMR crashes, gradual rollout asset mismatches, and free tier 429s.

  Use when: creating Workers projects, configuring Hono or Vite for Workers, deploying with Wrangler,
  adding Static Assets with SPA fallback, or troubleshooting export syntax, API route conflicts, scheduled
  handlers, or HMR race conditions.

  Keywords: Cloudflare Workers, CF Workers, Hono, wrangler, Vite, Static Assets, @cloudflare/vite-plugin,
  wrangler.jsonc, ES Module, run_worker_first, SPA fallback, API routes, serverless, edge computing,
  "Cannot read properties of undefined", "Static Assets 404", "A hanging Promise was canceled",
  "Handler does not export", deployment fails, routing not working, HMR crashes
---

# Cloudflare Worker Base Stack

**Production-tested**: cloudflare-worker-base-test (https://cloudflare-worker-base-test.webfonts.workers.dev)
**Last Updated**: 2026-01-03
**Status**: Production Ready ✅
**Latest Versions**: hono@4.11.3, @cloudflare/vite-plugin@1.17.1, vite@7.2.4, wrangler@4.54.0

**Recent Updates (2025-2026)**:
- **Wrangler 4.55+**: Auto-config for frameworks (`wrangler deploy --x-autoconfig`)
- **Wrangler 4.45+**: Auto-provisioning for R2, D1, KV bindings (enabled by default)
- **Workers RPC**: JavaScript-native RPC via `WorkerEntrypoint` class for service bindings
- **March 2025**: Wrangler v4 release (minimal breaking changes, v3 supported until Q1 2027)
- **June 2025**: Native Integrations removed from dashboard (CLI-based approach with wrangler secrets)
- **2025 Platform**: Workers VPC Services, Durable Objects Data Studio, 64 env vars (5KB each), unlimited Cron Triggers per Worker, WebSocket 32 MiB messages, node:fs/Web File System APIs
- **2025 Static Assets**: Gradual rollout asset mismatch issue, free tier 429 errors with run_worker_first, Vite plugin auto-detection
- **Hono 4.11.x**: Enhanced TypeScript RPC type inference, cloneRawRequest utility, JWT aud validation, auth middleware improvements

---

## Quick Start (5 Minutes)

```bash
# 1. Scaffold project
npm create cloudflare@latest my-worker -- --type hello-world --ts --git --deploy false --framework none

# 2. Install dependencies
cd my-worker
npm install hono@4.11.3
npm install -D @cloudflare/vite-plugin@1.17.1 vite@7.2.4

# 3. Create wrangler.jsonc
{
  "name": "my-worker",
  "main": "src/index.ts",
  "account_id": "YOUR_ACCOUNT_ID",
  "compatibility_date": "2025-11-11",
  "assets": {
    "directory": "./public/",
    "binding": "ASSETS",
    "not_found_handling": "single-page-application",
    "run_worker_first": ["/api/*"]  // CRITICAL: Prevents SPA fallback from intercepting API routes
  }
}

# 4. Create vite.config.ts
import { defineConfig } from 'vite'
import { cloudflare } from '@cloudflare/vite-plugin'
export default defineConfig({ plugins: [cloudflare()] })

# 5. Create src/index.ts
import { Hono } from 'hono'
type Bindings = { ASSETS: Fetcher }
const app = new Hono<{ Bindings: Bindings }>()
app.get('/api/hello', (c) => c.json({ message: 'Hello!' }))
app.all('*', (c) => c.env.ASSETS.fetch(c.req.raw))
export default app  // CRITICAL: Use this pattern (NOT { fetch: app.fetch })

# 6. Deploy
npm run dev              # Local: http://localhost:8787
wrangler deploy          # Production
```

**Critical Configuration**:
- `run_worker_first: ["/api/*"]` - Without this, SPA fallback intercepts API routes returning `index.html` instead of JSON ([workers-sdk #8879](https://github.com/cloudflare/workers-sdk/issues/8879))
- `export default app` - Using `{ fetch: app.fetch }` causes "Cannot read properties of undefined" ([honojs/hono #3955](https://github.com/honojs/hono/issues/3955))


## Known Issues Prevention

This skill prevents **8 documented issues**:

### Issue #1: Export Syntax Error
**Error**: "Cannot read properties of undefined (reading 'map')"
**Source**: [honojs/hono #3955](https://github.com/honojs/hono/issues/3955)
**Prevention**: Use `export default app` (NOT `{ fetch: app.fetch }`)

### Issue #2: Static Assets Routing Conflicts
**Error**: API routes return `index.html` instead of JSON
**Source**: [workers-sdk #8879](https://github.com/cloudflare/workers-sdk/issues/8879)
**Prevention**: Add `"run_worker_first": ["/api/*"]` to wrangler.jsonc

### Issue #3: Scheduled/Cron Not Exported
**Error**: "Handler does not export a scheduled() function"
**Source**: [honojs/vite-plugins #275](https://github.com/honojs/vite-plugins/issues/275)
**Prevention**: Use Module Worker format when needed:
```typescript
export default {
  fetch: app.fetch,
  scheduled: async (event, env, ctx) => { /* ... */ }
}
```

### Issue #4: HMR Race Condition
**Error**: "A hanging Promise was canceled" during development
**Source**: [workers-sdk #9518](https://github.com/cloudflare/workers-sdk/issues/9518)
**Prevention**: Use `@cloudflare/vite-plugin@1.13.13` or later

### Issue #5: Static Assets Upload Race
**Error**: Non-deterministic deployment failures in CI/CD
**Source**: [workers-sdk #7555](https://github.com/cloudflare/workers-sdk/issues/7555)
**Prevention**: Use Wrangler 4.x+ with retry logic (fixed in recent versions)

### Issue #6: Service Worker Format Confusion
**Error**: Using deprecated Service Worker format
**Source**: Cloudflare migration guide
**Prevention**: Always use ES Module format

### Issue #7: Gradual Rollouts Asset Mismatch (2025)
**Error**: 404 errors for fingerprinted assets during gradual deployments
**Source**: [Cloudflare Static Assets Docs](https://developers.cloudflare.com/workers/static-assets/routing/advanced/gradual-rollouts)
**Why It Happens**: Modern frameworks (React/Vue/Angular with Vite) generate fingerprinted filenames (e.g., `index-a1b2c3d4.js`). During gradual rollouts between versions, a user's initial request may go to Version A (HTML references `index-a1b2c3d4.js`), but subsequent asset requests route to Version B (only has `index-m3n4o5p6.js`), causing 404s
**Prevention**:
- Avoid gradual deployments with fingerprinted assets
- Use instant cutover deployments for static sites
- Or implement version-aware routing with custom logic

### Issue #8: Free Tier 429 Errors with run_worker_first (2025)
**Error**: 429 (Too Many Requests) responses on asset requests when exceeding free tier limits
**Source**: [Cloudflare Static Assets Billing Docs](https://developers.cloudflare.com/workers/static-assets/billing-and-limitations)
**Why It Happens**: When using `run_worker_first`, requests matching specified patterns ALWAYS invoke your Worker script (counted toward free tier limits). After exceeding limits, these requests receive 429 instead of falling back to free static asset serving
**Prevention**:
- Upgrade to Workers Paid plan ($5/month) for unlimited requests
- Use negative patterns (`!/pattern`) to exclude paths from Worker invocation
- Minimize `run_worker_first` patterns to only essential API routes



## Route Priority with run_worker_first

**Critical Understanding**: `"not_found_handling": "single-page-application"` returns `index.html` for unknown routes (enables React Router, Vue Router). Without `run_worker_first`, this intercepts API routes!

**Request Routing with `run_worker_first: ["/api/*"]`**:
1. `/api/hello` → Worker handles (returns JSON)
2. `/` → Static Assets serve `index.html`
3. `/styles.css` → Static Assets serve `styles.css`
4. `/unknown` → Static Assets serve `index.html` (SPA fallback)

**Static Assets Caching**: Automatic edge caching. Cache bust with query strings: `<link href="/styles.css?v=1.0.0">`

**Free Tier Warning** (2025): `run_worker_first` patterns count toward free tier limits. After exceeding, requests get 429 instead of falling back to free static assets. Use negative patterns (`!/pattern`) or upgrade to Paid plan.


## Auto-Provisioning (Wrangler 4.45+)

**Default Behavior**: Wrangler automatically provisions R2 buckets, D1 databases, and KV namespaces when deploying. This eliminates manual resource creation steps.

**How It Works**:
```jsonc
// wrangler.jsonc - Just define bindings, resources auto-create on deploy
{
  "d1_databases": [{ "binding": "DB", "database_name": "my-app-db" }],
  "r2_buckets": [{ "binding": "STORAGE", "bucket_name": "my-app-files" }],
  "kv_namespaces": [{ "binding": "CACHE", "title": "my-app-cache" }]
}
```

```bash
# Deploy - resources auto-provisioned if they don't exist
wrangler deploy

# Disable auto-provisioning (use existing resources only)
wrangler deploy --no-x-provision
```

**Benefits**:
- No separate `wrangler d1 create` / `wrangler r2 create` steps needed
- Idempotent - existing resources are used, not recreated
- Works with local dev (`wrangler dev` creates local emulated resources)


## Workers RPC (Service Bindings)

**What It Is**: JavaScript-native RPC system for calling methods between Workers. Uses Cap'n Proto under the hood for zero-copy message passing.

**Use Case**: Split your application into multiple Workers (e.g., API Worker + Auth Worker + Email Worker) that call each other with type-safe methods.

**Defining an RPC Service**:
```typescript
import { WorkerEntrypoint } from 'cloudflare:workers'

export class AuthService extends WorkerEntrypoint<Env> {
  async verifyToken(token: string): Promise<{ userId: string; valid: boolean }> {
    // Access bindings via this.env
    const session = await this.env.SESSIONS.get(token)
    return session ? { userId: session.userId, valid: true } : { userId: '', valid: false }
  }

  async createSession(userId: string): Promise<string> {
    const token = crypto.randomUUID()
    await this.env.SESSIONS.put(token, JSON.stringify({ userId }), { expirationTtl: 3600 })
    return token
  }
}

// Default export still handles HTTP requests
export default { fetch: ... }
```

**Calling from Another Worker**:
```typescript
// wrangler.jsonc
{
  "services": [
    { "binding": "AUTH", "service": "auth-worker", "entrypoint": "AuthService" }
  ]
}

// In your main Worker
const { valid, userId } = await env.AUTH.verifyToken(authHeader)
```

**Key Points**:
- **Zero latency**: Workers on same account typically run in same thread
- **Type-safe**: Full TypeScript support for method signatures
- **32 MiB limit**: Max serialized RPC message size
- **Self-bindings**: In `wrangler dev`, shows as `[connected]` for same-Worker calls


## Bundled Resources

**Templates**: Complete setup files in `templates/` directory (wrangler.jsonc, vite.config.ts, package.json, tsconfig.json, src/index.ts, public/index.html, styles.css, script.js)


## Official Documentation

- **Cloudflare Workers**: https://developers.cloudflare.com/workers/
- **Static Assets**: https://developers.cloudflare.com/workers/static-assets/
- **Vite Plugin**: https://developers.cloudflare.com/workers/vite-plugin/
- **Wrangler**: https://developers.cloudflare.com/workers/wrangler/
- **Hono**: https://hono.dev/docs/getting-started/cloudflare-workers
- **MCP Tool**: Use `mcp__cloudflare-docs__search_cloudflare_documentation` for latest docs

---

## Dependencies (Latest Verified 2026-01-03)

```json
{
  "dependencies": {
    "hono": "^4.11.3"
  },
  "devDependencies": {
    "@cloudflare/vite-plugin": "^1.17.1",
    "@cloudflare/workers-types": "^4.20260103.0",
    "vite": "^7.2.4",
    "wrangler": "^4.54.0",
    "typescript": "^5.9.3"
  }
}
```

---

## Production Validation

**Live Example**: https://cloudflare-worker-base-test.webfonts.workers.dev (build time: 45 min, 0 errors, all 8 issues prevented)

