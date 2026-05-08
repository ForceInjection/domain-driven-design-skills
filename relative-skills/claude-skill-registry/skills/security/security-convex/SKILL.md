---
name: security-convex
description: |-
  Review Convex security audit patterns for authentication and authorization. Use for auditing query/mutation auth, row-level security, and validators. Use proactively when reviewing Convex apps (convex/ directory present).
  Examples:
  - user: "Audit these Convex mutations" → check for missing ctx.auth and input validators
  - user: "Check for IDOR in Convex queries" → verify ownership checks on document access
  - user: "Review Convex HTTP actions" → check for signature verification on webhooks
  - user: "Secure these Convex queries" → implement custom functions for enforced auth
  - user: "Check for data leaks in subscriptions" → verify filtered result sets
---

<overview>

Security audit patterns for Convex applications covering authentication, authorization, input validation, and Convex-specific vulnerabilities.

</overview>

<rules>

## The #1 Vibecoding Mistake: Unauthenticated Functions

Convex functions are public by default. Every query and mutation is callable from any client unless you add auth checks.

```typescript
// ❌ CRITICAL: Anyone can read all users
export const listUsers = query({
  handler: async (ctx) => {
    return await ctx.db.query("users").collect();
  },
});

// ❌ CRITICAL: Anyone can delete any document
export const deleteNote = mutation({
  args: { noteId: v.id("notes") },
  handler: async (ctx, args) => {
    await ctx.db.delete(args.noteId);
  },
});

// ✓ SECURE: Check auth first
export const listUsers = query({
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Unauthenticated");
    // Now safe to return data
    return await ctx.db.query("users").collect();
  },
});
```

## Authentication Checks

### Using Convex Auth
```typescript
import { getAuthUserId } from "@convex-dev/auth/server";

// ❌ No auth check
export const getMyProfile = query({
  handler: async (ctx) => {
    // Who is "my"? Anyone can call this!
    return await ctx.db.query("users").first();
  },
});

// ✓ Get authenticated user
export const getMyProfile = query({
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Unauthenticated");
    return await ctx.db.get(userId);
  },
});
```

### Using Third-Party Auth (Clerk, Auth0)
```typescript
// ❌ Just checking ctx.auth exists (wrong!)
export const sensitiveData = query({
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    // identity could be null!
    return await ctx.db.query("secrets").collect();
  },
});

// ✓ Properly validate identity
export const sensitiveData = query({
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Unauthenticated");
    // Now identity.tokenIdentifier is available
    return await ctx.db.query("secrets")
      .filter(q => q.eq(q.field("userId"), identity.subject))
      .collect();
  },
});
```

</rules>

<vulnerabilities>

## Authorization: The IDOR Problem

Authentication (who you are) ≠ Authorization (what you can access).

```typescript
// ❌ HIGH: IDOR - Any logged-in user can read any note
export const getNote = query({
  args: { noteId: v.id("notes") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Unauthenticated");
    // Authenticated but no ownership check!
    return await ctx.db.get(args.noteId);
  },
});

// ✓ Check ownership
export const getNote = query({
  args: { noteId: v.id("notes") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Unauthenticated");
    
    const note = await ctx.db.get(args.noteId);
    if (!note || note.userId !== userId) {
      throw new Error("Not found"); // Don't reveal existence
    }
    return note;
  },
});
```

### Team/Org Membership Checks
```typescript
// ❌ Trusts client-provided teamId
export const getTeamData = query({
  args: { teamId: v.id("teams") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Unauthenticated");
    // User says they're on this team - but are they?
    return await ctx.db.query("projects")
      .filter(q => q.eq(q.field("teamId"), args.teamId))
      .collect();
  },
});

// ✓ Verify membership
export const getTeamData = query({
  args: { teamId: v.id("teams") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Unauthenticated");
    
    const membership = await ctx.db.query("teamMembers")
      .withIndex("by_team_user", q => 
        q.eq("teamId", args.teamId).eq("userId", userId)
      ).first();
    
    if (!membership) throw new Error("Not a team member");
    
    return await ctx.db.query("projects")
      .filter(q => q.eq(q.field("teamId"), args.teamId))
      .collect();
  },
});
```

## Custom Functions Pattern (Recommended)

Use convex-helpers to enforce auth by default:

```typescript
// convex/functions.ts
import { customQuery, customMutation } from "convex-helpers/server/customFunctions";
import { getAuthUserId } from "@convex-dev/auth/server";

// All userQuery functions require authentication
export const userQuery = customQuery(query, {
  args: {},
  input: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Unauthenticated");
    const user = await ctx.db.get(userId);
    if (!user) throw new Error("User not found");
    return { ctx: { user }, args: {} };
  },
});

// Usage - ctx.user is guaranteed to exist
export const getMyNotes = userQuery({
  handler: async (ctx) => {
    return await ctx.db.query("notes")
      .filter(q => q.eq(q.field("userId"), ctx.user._id))
      .collect();
  },
});
```

**Audit:** Check if custom functions are used consistently. Search for raw `query(` and `mutation(` usage.

## Input Validation

### Missing Validators
```typescript
// ❌ No validation - args is 'any'
export const createNote = mutation({
  handler: async (ctx, args) => {
    await ctx.db.insert("notes", args); // Could insert anything!
  },
});

// ✓ Strict validators
export const createNote = mutation({
  args: {
    title: v.string(),
    content: v.string(),
    isPublic: v.optional(v.boolean()),
  },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Unauthenticated");
    await ctx.db.insert("notes", {
      ...args,
      userId, // Server sets this, not client
    });
  },
});
```

### Trusting Client-Provided IDs for Ownership
```typescript
// ❌ Client provides userId - can impersonate anyone
export const createNote = mutation({
  args: {
    title: v.string(),
    userId: v.id("users"), // Client-controlled!
  },
  handler: async (ctx, args) => {
    await ctx.db.insert("notes", args);
  },
});

// ✓ Server determines userId
export const createNote = mutation({
  args: { title: v.string() },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Unauthenticated");
    await ctx.db.insert("notes", {
      title: args.title,
      userId, // From auth, not args
    });
  },
});
```

## Internal Functions

```typescript
// ❌ Sensitive logic in public mutation
export const processPayment = mutation({
  args: { amount: v.number() },
  handler: async (ctx, args) => {
    // Anyone can call this!
    await chargeCard(args.amount);
  },
});

// ✓ Use internalMutation for sensitive operations
export const processPayment = internalMutation({
  args: { userId: v.id("users"), amount: v.number() },
  handler: async (ctx, args) => {
    // Only callable from other server functions
    await chargeCard(args.amount);
  },
});

// Public function validates then calls internal
export const purchaseItem = mutation({
  args: { itemId: v.id("items") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Unauthenticated");
    
    const item = await ctx.db.get(args.itemId);
    // Validate, then call internal
    await ctx.runMutation(internal.payments.processPayment, {
      userId,
      amount: item.price,
    });
  },
});
```

## HTTP Actions

```typescript
// ❌ No auth on HTTP endpoint
export const webhook = httpAction(async (ctx, request) => {
  const body = await request.json();
  await ctx.runMutation(api.data.processWebhook, body);
  return new Response("OK");
});

// ✓ Verify webhook signature
export const webhook = httpAction(async (ctx, request) => {
  const signature = request.headers.get("x-webhook-signature");
  const body = await request.text();
  
  if (!verifySignature(body, signature, process.env.WEBHOOK_SECRET)) {
    return new Response("Unauthorized", { status: 401 });
  }
  
  await ctx.runMutation(api.data.processWebhook, JSON.parse(body));
  return new Response("OK");
});
```

## Real-Time Subscription Leakage

```typescript
// ❌ Subscription returns all messages (data leak)
export const allMessages = query({
  handler: async (ctx) => {
    return await ctx.db.query("messages").collect();
  },
});

// ✓ Filter by user's access
export const myMessages = query({
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return []; // Or throw
    
    // Only messages user has access to
    const myChannels = await ctx.db.query("channelMembers")
      .filter(q => q.eq(q.field("userId"), userId))
      .collect();
    
    const channelIds = myChannels.map(m => m.channelId);
    return await ctx.db.query("messages")
      .filter(q => q.or(...channelIds.map(id => 
        q.eq(q.field("channelId"), id)
      )))
      .collect();
  },
});
```

## Environment Variables

```typescript
// ❌ Accessing env vars that don't exist (undefined behavior)
const apiKey = process.env.STRIPE_SECRET_KEY;

// ✓ Use Convex environment variables properly
// Set via: npx convex env set STRIPE_SECRET_KEY sk_live_...
// Access in actions only (not queries/mutations for determinism)
export const callStripe = action({
  handler: async (ctx) => {
    const apiKey = process.env.STRIPE_SECRET_KEY;
    if (!apiKey) throw new Error("STRIPE_SECRET_KEY not configured");
    // ...
  },
});
```

**Note:** Environment variables are only available in actions, not queries/mutations.

</vulnerabilities>

<severity_table>

## Common Vulnerabilities Summary

| Issue | Where to Look | Severity |
|-------|---------------|----------|
| No auth check in query/mutation | All `query({` and `mutation({` | CRITICAL |
| IDOR (no ownership check) | Functions with document IDs in args | HIGH |
| Client-provided userId | Args with `v.id("users")` | HIGH |
| Missing validators | Functions without `args: {}` | HIGH |
| Public function for internal logic | Sensitive business logic | HIGH |
| HTTP action without auth | `httpAction(` | HIGH |
| Subscription data leak | Queries returning collections | MEDIUM |
| Raw query/mutation (no custom fn) | Not using userQuery/userMutation | MEDIUM |

</severity_table>

<commands>

## Quick Audit Commands

```bash
# Find all public queries and mutations
rg "export const .* = query\(" convex/
rg "export const .* = mutation\(" convex/

# Find functions without auth checks
rg -l "export const .* = (query|mutation)\(" convex/ | \
  xargs rg -L "(getAuthUserId|getUserIdentity)"

# Find client-provided userId (potential IDOR)
rg 'userId: v\.id\("users"\)' convex/

# Find functions without validators
rg "handler: async \(ctx\)" convex/ -g "*.ts"

# Find HTTP actions
rg "httpAction" convex/

# Find internal vs public function usage
rg "internalMutation|internalQuery|internalAction" convex/
```

</commands>

<checklist>

## Hardening Checklist

- [ ] All queries/mutations have auth checks (or use custom functions)
- [ ] Document access includes ownership/membership verification
- [ ] userId comes from auth context, not client args
- [ ] All functions have proper validators
- [ ] Sensitive operations use internalMutation/internalAction
- [ ] HTTP actions verify signatures/tokens
- [ ] Real-time subscriptions filter by user access
- [ ] Custom functions (userQuery/userMutation) used consistently
- [ ] ESLint rules prevent importing raw query/mutation

</checklist>
