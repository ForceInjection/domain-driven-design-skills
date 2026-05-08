---
name: convex-patterns
description: Convex backend patterns with security, validation, and performance best practices
---

# Convex Patterns

**Purpose**: Enforce secure, performant Convex backend (validation, auth, race prevention, rate limiting)

- Keywords: convex, mutation, query, action, schema, database, ctx.db, defineSchema, internalMutation, webhook, httpAction, http, stripe, CONVEX_SITE_URL, callback, api

## Quick Reference

| Pattern | ✅ DO | ❌ AVOID |
|---------|-------|----------|
| Files | `snake_case.ts` | `kebab-case.ts` (deploy fails) |
| Fields | `snake_case` | `camelCase` |
| Validation | `args: v.object({...})` | No validators (insecure!) |
| Auth | Check every mutation | Trust client |
| Queries | `.withIndex()` | Table scans |

## CRITICAL Security

⚠️ **ALL functions PUBLIC by default**

Always:
1. Use validators on all functions
2. Check authentication (`ctx.auth.getUserIdentity()`)
3. Verify ownership before operations
4. Validate beyond schema

⚠️ **NEVER share CONVEX_URL publicly** (GitHub, docs, screenshots)

## Mutation Structure

```ts
import { mutation } from "./_generated/server"
import { v } from "convex/values"

export const createOrder = mutation({
  args: {
    amount: v.number(),
    customer_name: v.optional(v.string())
  },
  returns: v.id("orders"),
  handler: async (ctx, { amount, customer_name }) => {
    // 1. Auth
    const identity = await ctx.auth.getUserIdentity()
    if (!identity) throw new Error('Unauthorized')

    // 2. Validate beyond schema
    if (amount <= 0 || amount > 1000000) {
      throw new Error('Invalid amount')
    }

    // 3. Insert
    return await ctx.db.insert("orders", {
      amount,
      customer_name: customer_name ?? null,
      user_id: identity.subject,
      status: "pending"
    })
  }
})
```

## Authorization Pattern

```ts
export const updateOrder = mutation({
  args: { order_id: v.id("orders"), status: v.string() },
  handler: async (ctx, { order_id, status }) => {
    // 1. Auth
    const identity = await ctx.auth.getUserIdentity()
    if (!identity) throw new Error('Unauthorized')

    // 2. Fetch
    const order = await ctx.db.get(order_id)
    if (!order) throw new Error('Not found')

    // 3. Verify ownership BEFORE update
    if (order.user_id !== identity.subject) {
      throw new Error('Access denied')
    }

    // 4. Update
    await ctx.db.patch(order_id, { status })
  }
})
```

## Performant Queries

```ts
// Schema with indexes
export default defineSchema({
  users: defineTable({
    email: v.string(),
    status: v.string()
  })
    .index("by_email", ["email"])
    .index("by_status", ["status"])
})

// ✅ Use index (O(log n))
const user = await ctx.db
  .query('users')
  .withIndex('by_email', q => q.eq('email', email))
  .first()

// ❌ Table scan (O(n))
const user = await ctx.db
  .query('users')
  .filter(q => q.eq(q.field('email'), email))
  .first()
```

## Idempotency

**Pattern 1: Check-Before-Insert**

```ts
// Schema with composite index
defineTable({
  user_id: v.string(),
  session_id: v.id('sessions'),
  data: v.string()
}).index('by_user_session', ['user_id', 'session_id'])

// Mutation (safe to retry)
const existing = await ctx.db
  .query('entries')
  .withIndex('by_user_session', q =>
    q.eq('user_id', userId).eq('session_id', session_id)
  )
  .first()

if (existing) return existing._id  // Idempotent

return await ctx.db.insert('entries', { user_id: userId, session_id, data })
```

**Pattern 2: Idempotency Keys (Actions)**

```ts
// Schema
defineTable({
  key: v.string(),
  result: v.any(),
  created_at: v.number()
}).index('by_key', ['key'])

// Action with key
export const createPayment = action({
  args: { idempotency_key: v.string(), amount: v.number() },
  handler: async (ctx, { idempotency_key, amount }) => {
    // Check if processed
    const existing = await ctx.runMutation(api.payments.checkKey, {
      key: idempotency_key
    })
    if (existing) return existing

    // Process (side effect)
    const charge = await stripe.charges.create({ amount })
    const orderId = await ctx.runMutation(api.orders.create, { amount })

    const result = { orderId, chargeId: charge.id }

    // Store result
    await ctx.runMutation(api.payments.storeResult, {
      key: idempotency_key,
      result
    })

    return result
  }
})
```

**Client**: Generate key once, safe to retry

```tsx
const [key] = useState(() => uuid())
await createPayment({ idempotency_key: key, amount: 1000 })
```

**Pattern 3: Webhook Deduplication**

```ts
// Schema
defineTable({
  event_id: v.string(),  // External event ID
  event_type: v.string(),
  processed_at: v.number()
}).index('by_event_id', ['event_id'])

// Mutation
const existing = await ctx.db
  .query('webhook_events')
  .withIndex('by_event_id', q => q.eq('event_id', event_id))
  .first()

if (existing) return { processed: false, reason: 'duplicate' }

// Process event...

await ctx.db.insert('webhook_events', { event_id, event_type, processed_at: Date.now() })
```

## HTTP Actions (Webhooks)

**Use for**: Webhooks, public API endpoints, external integrations

**Critical**: HTTP Actions use **CONVEX_SITE_URL** (not CONVEX_URL)

| Use Case | URL | Why |
|----------|-----|-----|
| Mutations/Queries (client SDK) | `CONVEX_URL` | Internal app communication |
| HTTP Actions (webhooks) | `CONVEX_SITE_URL` | Public HTTP endpoints |

### Setup HTTP Router

```ts
// convex/http.ts
import { httpRouter } from "convex/server"
import { httpAction } from "./_generated/server"

const http = httpRouter()

http.route({
  path: "/stripe/webhook",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const signature = request.headers.get("stripe-signature")
    const body = await request.text()

    // 1. Verify signature BEFORE processing
    if (!verifyStripeSignature(body, signature, STRIPE_WEBHOOK_SECRET)) {
      return new Response("Invalid signature", { status: 401 })
    }

    // 2. Check timestamp (replay attack prevention)
    const event = JSON.parse(body)
    const eventTime = event.created * 1000
    if (Date.now() - eventTime > 5 * 60 * 1000) {
      return new Response("Timestamp too old", { status: 400 })
    }

    // 3. Process idempotently using event ID
    await ctx.runMutation(api.webhooks.processWebhookEvent, {
      event_id: event.id,
      event_type: event.type,
      data: event.data.object
    })

    // Always return 200 (even for duplicates)
    return new Response("OK", { status: 200 })
  })
})

export default http
```

**Why this matters**:
- Webhook providers retry failed requests
- Network issues cause duplicate deliveries
- Event ID ensures exactly-once processing
- Return 200 for duplicates prevents unnecessary retries

**Webhook URL**: `https://YOUR_SITE.convex.site/stripe/webhook` (uses CONVEX_SITE_URL)

## Rate Limiting

```ts
import { RateLimiter } from '@convex-dev/ratelimiter'

const limiter = new RateLimiter(components.rateLimiter, {
  createOrder: { kind: 'token bucket', rate: 10, period: 60_000 }
})

export const createOrder = mutation({
  handler: async (ctx, { amount }) => {
    const identity = await ctx.auth.getUserIdentity()
    if (!identity) throw new Error('Unauthorized')

    await limiter.limit(ctx, 'createOrder', { key: identity.subject })

    return await ctx.db.insert("orders", { amount, user_id: identity.subject })
  }
})
```

**Common limits**:
- Registration: 3/user/24h
- Login: 10/email/5min
- Orders: 10/user/min
- API: 100/user/hour

## File Naming

⚠️ **CRITICAL**: Convex requires `snake_case` for files in `convex/`

```
✅ convex/stripe_webhook.ts
✅ convex/user_queries.ts
❌ convex/stripe-webhook.ts  (deploy fails)
```

**Error**: "Path component X can only contain alphanumeric, underscores, periods"

## Field Naming

Always `snake_case`:

```ts
await ctx.db.insert("orders", {
  transaction_id: "abc",     // ✅
  customer_name: "John",     // ✅
  _creationTime: Date.now(), // ✅ System field
  userId: identity.subject   // ❌ Should be user_id
})
```

## Validators

| Type | Usage |
|------|-------|
| Primitives | `v.string()`, `v.number()`, `v.boolean()`, `v.null()` |
| ID | `v.id("table_name")` |
| Optional | `v.optional(v.string())`, `v.nullable(v.number())` |
| Object | `v.object({ name: v.string(), age: v.number() })` |
| Array | `v.array(v.string())` |
| Union | `v.union(v.literal("a"), v.literal("b"))` |
| Any | `v.any()` (use sparingly) |

## Resources

Progressive disclosure for deep dives:

- `resources/schema-design.md` - Table design, index patterns
- `resources/auth-patterns.md` - Comprehensive auth
- `resources/performance.md` - Query optimization, caching

## Docs

- [Convex Docs](https://docs.convex.dev)
- [Best Practices](https://docs.convex.dev/production/best-practices)
- [Rate Limiter](https://docs.convex.dev/production/rate-limiting)
