---
name: paddle-integration
description: Use when integrating Paddle payments, setting up subscriptions, configuring webhooks, or debugging billing issues. Covers sandbox testing and production deployment.
---

# Paddle Payment Integration

## Overview

Paddle is a merchant of record for SaaS subscriptions. This skill covers the complete integration: sandbox setup, webhook handling, frontend checkout, and production deployment.

**Core principle:** Always start with sandbox credentials. Test the full flow before touching production.

## When to Use

- Setting up Paddle payments for the first time
- Adding subscription/billing to an app
- Debugging webhook signature verification
- Migrating from sandbox to production
- Understanding Paddle's subscription lifecycle events

## Environment Variables Required

```bash
# Backend (server-side only)
PADDLE_API_KEY=pdl_sdbx_apikey_...       # Sandbox: pdl_sdbx_, Production: pdl_live_
PADDLE_WEBHOOK_SECRET=pdl_ntfset_...     # From webhook creation

# Frontend (NEXT_PUBLIC_ prefix for Next.js)
NEXT_PUBLIC_PADDLE_CLIENT_TOKEN=test_... # Sandbox: test_, Production: live_
NEXT_PUBLIC_PADDLE_PRICE_ID_PRO_MONTHLY=pri_01...
```

## Sandbox Setup

### 1. Get Credentials from Paddle Dashboard

1. Go to https://sandbox-vendors.paddle.com
2. **API Key**: Developer Tools → Authentication → API keys → Generate
3. **Client Token**: Developer Tools → Authentication → Client-side tokens → Generate

### 2. Create Products and Prices

In Paddle Dashboard → Catalog:
1. Create Product (e.g., "Pro Plan")
2. Add Price to product (e.g., $55/month recurring)
3. Copy the Price ID (`pri_01...`)

### 3. Create Webhook via API

```bash
# Create webhook pointing to your endpoint
curl -X POST "https://sandbox-api.paddle.com/webhooks" \
  -H "Authorization: Bearer $PADDLE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "App webhooks",
    "destination": "https://your-domain.com/api/webhooks/paddle",
    "subscribed_events": [
      "subscription.created",
      "subscription.updated",
      "subscription.canceled",
      "subscription.paused",
      "subscription.resumed",
      "transaction.completed",
      "transaction.payment_failed"
    ],
    "active": true
  }'
```

Response includes `secret_key` - this is your `PADDLE_WEBHOOK_SECRET`.

### 4. Add Env Vars to Vercel

```bash
# Add each variable (repeat for each environment as needed)
echo "pdl_sdbx_apikey_..." | vercel env add PADDLE_API_KEY development
echo "pdl_ntfset_..." | vercel env add PADDLE_WEBHOOK_SECRET development
echo "test_..." | vercel env add NEXT_PUBLIC_PADDLE_CLIENT_TOKEN development
echo "pri_01..." | vercel env add NEXT_PUBLIC_PADDLE_PRICE_ID_PRO_MONTHLY development

# Pull to local
vercel env pull .env.local
```

## Database Schema

Add subscription fields to your users table:

```typescript
// Drizzle schema example
export const users = pgTable("user", {
  // ... existing fields
  paddleCustomerId: text("paddleCustomerId"),
  paddleSubscriptionId: text("paddleSubscriptionId"),
  plan: text("plan").$type<"free" | "pro">().notNull().default("free"),
  planStatus: text("planStatus").$type<
    "active" | "canceled" | "past_due" | "paused" | "trialing"
  >(),
  currentPeriodEnd: timestamp("currentPeriodEnd", { mode: "date" }),
});
```

## Webhook Endpoint

```typescript
// app/api/webhooks/paddle/route.ts
import { Paddle, EventName } from "@paddle/paddle-node-sdk";

const paddle = new Paddle(process.env.PADDLE_API_KEY!);

export async function POST(request: Request) {
  const signature = request.headers.get("paddle-signature");
  const rawBody = await request.text();

  // Verify signature
  let event;
  try {
    event = paddle.webhooks.unmarshal(
      rawBody,
      process.env.PADDLE_WEBHOOK_SECRET!,
      signature!
    );
  } catch {
    return new Response("Invalid signature", { status: 401 });
  }

  // Handle events
  switch (event.eventType) {
    case EventName.SubscriptionCreated:
    case EventName.SubscriptionUpdated:
      // Update user's subscription status
      const customerId = event.data.customerId;
      const subscriptionId = event.data.id;
      const status = event.data.status;
      const currentPeriodEnd = event.data.currentBillingPeriod?.endsAt;
      // ... update database
      break;

    case EventName.SubscriptionCanceled:
      // Mark subscription as canceled (still active until period ends)
      break;

    case EventName.TransactionCompleted:
      // Payment succeeded - good for logging/analytics
      break;

    case EventName.TransactionPaymentFailed:
      // Payment failed - may want to notify user
      break;
  }

  return new Response("OK");
}
```

## Frontend Checkout

```typescript
// components/pricing-cards.tsx
"use client";

import { useEffect } from "react";
import { initializePaddle, Paddle } from "@paddle/paddle-js";

let paddleInstance: Paddle | null = null;

export function PricingCards({ userEmail }: { userEmail?: string }) {
  useEffect(() => {
    initializePaddle({
      environment: "sandbox", // Change to "production" for live
      token: process.env.NEXT_PUBLIC_PADDLE_CLIENT_TOKEN!,
    }).then((paddle) => {
      paddleInstance = paddle ?? null;
    });
  }, []);

  const handleCheckout = () => {
    paddleInstance?.Checkout.open({
      items: [{ priceId: process.env.NEXT_PUBLIC_PADDLE_PRICE_ID_PRO_MONTHLY! }],
      customer: userEmail ? { email: userEmail } : undefined,
      customData: { userId: "user_123" }, // Passed to webhooks
    });
  };

  return <button onClick={handleCheckout}>Subscribe</button>;
}
```

## Production Deployment

### Checklist

| Step | Sandbox | Production |
|------|---------|------------|
| Dashboard URL | sandbox-vendors.paddle.com | vendors.paddle.com |
| API URL | sandbox-api.paddle.com | api.paddle.com |
| API Key prefix | `pdl_sdbx_` | `pdl_live_` |
| Client token prefix | `test_` | `live_` |
| Paddle.js environment | `"sandbox"` | `"production"` |

### Steps

1. **Get production credentials** from https://vendors.paddle.com (same locations as sandbox)

2. **Create production webhook** (same API call but to production URL):
```bash
curl -X POST "https://api.paddle.com/webhooks" \
  -H "Authorization: Bearer $PADDLE_LIVE_API_KEY" \
  ...
```

3. **Update Vercel env vars for production only**:
```bash
echo "pdl_live_apikey_..." | vercel env add PADDLE_API_KEY production
echo "pdl_ntfset_..." | vercel env add PADDLE_WEBHOOK_SECRET production
echo "live_..." | vercel env add NEXT_PUBLIC_PADDLE_CLIENT_TOKEN production
```

4. **Update frontend environment detection** (if not using env vars):
```typescript
environment: process.env.NODE_ENV === "production" ? "production" : "sandbox"
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Webhook returns 401 | Check `PADDLE_WEBHOOK_SECRET` matches the secret from webhook creation |
| Checkout doesn't open | Verify `NEXT_PUBLIC_PADDLE_CLIENT_TOKEN` is set and Paddle.js initialized |
| Wrong price in checkout | Confirm Price ID matches your Paddle dashboard |
| Events not received | Check webhook URL is publicly accessible, not localhost |
| Sandbox works, prod fails | Ensure you created a NEW webhook for production (different secret) |

## Testing Sandbox Checkout

Paddle sandbox accepts test cards:
- **Success**: `4242 4242 4242 4242` (any future expiry, any CVC)
- **Decline**: `4000 0000 0000 0002`

## Quick Reference

```bash
# List webhooks
curl "https://sandbox-api.paddle.com/webhooks" \
  -H "Authorization: Bearer $PADDLE_API_KEY"

# Get webhook details
curl "https://sandbox-api.paddle.com/webhooks/ntfset_01..." \
  -H "Authorization: Bearer $PADDLE_API_KEY"

# List subscriptions for a customer
curl "https://sandbox-api.paddle.com/subscriptions?customer_id=ctm_01..." \
  -H "Authorization: Bearer $PADDLE_API_KEY"

# Cancel subscription
curl -X POST "https://sandbox-api.paddle.com/subscriptions/sub_01.../cancel" \
  -H "Authorization: Bearer $PADDLE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"effective_from": "next_billing_period"}'
```

## Dependencies

```bash
# Backend SDK (webhook verification)
yarn add @paddle/paddle-node-sdk

# Frontend SDK (checkout)
yarn add @paddle/paddle-js
```
