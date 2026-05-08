---
name: pricing-tiers
description: ReleaseWatch subscription tiers, pricing strategy, and Pro feature definitions. Use when discussing pricing plans, comparing tiers, implementing tier-gated features, or setting up Polar integration.
---

# Subscription Tiers

## Tier Comparison

| Feature | Free | Pro |
|---------|------|-----|
| Repos tracked | 25 | Unlimited |
| AI summaries | 25/month | Unlimited |
| Channels | Telegram, Discord, Email | All + webhooks |
| Webhooks | 1 | 5 |
| Check frequency | 15 min | 15 min |
| Release type filters | Yes | Yes |
| Notification history | 7 days | 90 days |
| GitHub stars import | - | Yes |

## Pricing Strategy

**Launch (Early Adopters):**
- Monthly: $3/mo (locked in forever)
- Annual: $30/yr (2 months free)

**Regular (After Launch):**
- Monthly: $5/mo
- Annual: $50/yr (2 months free)

## Grandfathering

Polar handles automatically:
1. Create products at launch price
2. After launch period, update prices in Polar dashboard
3. Existing subscribers keep original price forever

## Pro Features

### Notification History
- Store notification events in `notification_history` table
- `GET /notifications/history` endpoint (Pro only)
- 90-day retention
- UI: `/dashboard/history`

### Webhook Integrations
- Free: 1 webhook
- Pro: 5 webhooks
- Store in `user_webhooks` table
- Fire on release notification

### GitHub Stars Import
- Pro-only feature
- Fetch starred repos via GitHub API
- UI: Cherry-pick which repos to import

## Database Schema

```typescript
// packages/database/src/schema/user-limits.ts
export const userLimits = pgTable("user_limits", {
  userId: text().primaryKey().references(() => users.id, { onDelete: "cascade" }),
  tier: text().default("free").notNull(), // 'free' | 'pro'
  aiSummariesUsed: integer().default(0).notNull(),
  aiSummariesResetAt: timestamp(), // Reset monthly
});
```

## Limit Enforcement

```typescript
const TIER_LIMITS = {
  free: { maxRepos: 25, maxAiSummaries: 25, maxWebhooks: 1 },
  pro: { maxRepos: Infinity, maxAiSummaries: Infinity, maxWebhooks: 5 },
};
```

Apply middleware to:
- `POST /repos` - Check repo count vs tier limit
- `POST /webhooks` - Check webhook count vs tier limit
- AI analysis in workflow - Check monthly AI summary usage

## Polar Integration

Environment variables (set per environment):
- `POLAR_SERVER` - `sandbox` or `production`
- `POLAR_PRODUCT_ID_PRO_MONTHLY` - Product ID for monthly plan
- `POLAR_PRODUCT_ID_PRO_ANNUAL` - Product ID for annual plan

Sandbox Product IDs:
- `pro-monthly`: `c43ab049-bafd-45ff-a48c-c6dbc3167411`
- `pro-annual`: `b1bc732e-3bf3-4672-8e0a-e34267202903`

Checkout URLs:
- `/api/auth/checkout/pro-monthly`
- `/api/auth/checkout/pro-annual`

Webhook handlers:
- `onSubscriptionCreated` → Update user tier to 'pro'
- `onSubscriptionCanceled` → Downgrade to 'free'

## UI Touchpoints

1. **Pricing page**: `/app/(marketing)/pricing/page.tsx`
2. **Upgrade prompts**: Show when approaching limits
3. **Settings**: Subscription management via Polar portal
4. **Feature teasers**: "Available with Pro" for gated features
