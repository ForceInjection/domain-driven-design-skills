---
name: billing-system-expert
description: Expert knowledge on Stripe integration, subscription plans (Glow Up, Viral Surge, Fame Flex), trial logic, plan enforcement, webhooks, and billing synchronization. Use this skill when user asks about "subscription", "billing", "stripe", "payment", "plan limits", "trial", "upgrade", "downgrade", "webhook", or "plan enforcement".
allowed-tools: Read, Grep, Glob, Bash
---

# Billing System Expert

You are an expert in the billing and subscription system for this influencer discovery platform. This skill provides comprehensive knowledge about Stripe integration, subscription plans, trial management, plan enforcement, and webhook handling.

## When To Use This Skill

This skill activates when users:
- Ask about subscription plans or pricing
- Need to debug billing issues or sync problems
- Work with Stripe webhooks or payment flows
- Implement plan limit enforcement
- Debug trial period activation or conversion
- Investigate upgrade/downgrade flows
- Need to understand payment method handling
- Troubleshoot stuck onboarding or billing states

## Core Knowledge

### Subscription Plans

The platform offers three paid tiers plus a free tier:

**Plan Structure:**
```typescript
// From /lib/db/schema.ts - subscription_plans table
{
  planKey: 'glow_up' | 'viral_surge' | 'fame_flex' | 'free',
  campaignsLimit: number,  // -1 = unlimited
  creatorsLimit: number,   // -1 = unlimited
  features: jsonb,
  priceMonthly: number,
  priceYearly: number
}
```

**Plan Limits (from /lib/services/plan-enforcement.ts):**

1. **Glow Up** (Entry Level)
   - Campaigns: 3
   - Creators: 1,000/month
   - Stripe Price IDs:
     - Monthly: `process.env.STRIPE_GLOW_UP_MONTHLY_PRICE_ID`
     - Yearly: `process.env.STRIPE_GLOW_UP_YEARLY_PRICE_ID`

2. **Viral Surge** (Pro Level)
   - Campaigns: 10
   - Creators: 10,000/month
   - Stripe Price IDs:
     - Monthly: `process.env.STRIPE_VIRAL_SURGE_MONTHLY_PRICE_ID`
     - Yearly: `process.env.STRIPE_VIRAL_SURGE_YEARLY_PRICE_ID`

3. **Fame Flex** (Unlimited)
   - Campaigns: Unlimited (-1)
   - Creators: Unlimited (-1)
   - Stripe Price IDs:
     - Monthly: `process.env.STRIPE_FAME_FLEX_MONTHLY_PRICE_ID`
     - Yearly: `process.env.STRIPE_FAME_FLEX_YEARLY_PRICE_ID`

4. **Free Tier** (Default)
   - Campaigns: 1 (or 0, check implementation)
   - Creators: 50
   - No Stripe subscription required

### Plan Enforcement Logic

**Service:** `/lib/services/plan-enforcement.ts`

**Key Functions:**

```typescript
class PlanEnforcementService {
  // Get user's plan limits
  static async getPlanLimits(userId: string): Promise<PlanLimits | null>

  // Get current usage
  static async getCurrentUsage(userId: string): Promise<UsageInfo | null>

  // Validate campaign creation
  static async validateCampaignCreation(userId: string): Promise<{
    allowed: boolean;
    reason?: string;
    usage?: UsageInfo;
  }>

  // Validate job creation (creator searches)
  static async validateJobCreation(userId: string, expectedCreators: number): Promise<{
    allowed: boolean;
    reason?: string;
    usage?: UsageInfo;
    adjustedLimit?: number;
  }>

  // Track campaign creation
  static async trackCampaignCreated(userId: string): Promise<void>

  // Track creators found
  static async trackCreatorsFound(userId: string, creatorCount: number): Promise<void>
}
```

**Usage Tracking:**
- **Campaigns**: Total count (not monthly reset)
- **Creators**: Monthly count (resets first day of month)

**Example Enforcement:**
```typescript
// Before creating campaign
const validation = await PlanEnforcementService.validateCampaignCreation(userId);

if (!validation.allowed) {
  return NextResponse.json(
    { error: validation.reason, usage: validation.usage },
    { status: 403 }
  );
}

// Create campaign...

// Track usage
await PlanEnforcementService.trackCampaignCreated(userId);
```

**Dev Bypass (Non-Production Only):**
```typescript
// Environment variable bypass
PLAN_VALIDATION_BYPASS=all  // or "campaigns,creators"

// Request header bypass
headers: {
  'x-plan-bypass': 'all'  // or "campaigns,creators"
}
```

### Stripe Integration

**Stripe Service:** `/lib/stripe/stripe-service.ts`
**Webhook Handler:** `/app/api/stripe/webhook/route.ts`

**Key Webhook Events:**

1. **checkout.session.completed**
   - Triggered after successful checkout
   - Finalizes onboarding
   - Links Stripe customer to user
   - Triggers trial activation

2. **customer.subscription.created**
   - Triggered when subscription is created
   - Updates user plan in database
   - Sets plan limits
   - Activates trial if applicable
   - **CRITICAL**: Must resolve plan from price ID

3. **customer.subscription.updated**
   - Triggered on plan changes or status updates
   - Handles trial → paid conversion
   - Updates plan limits on upgrades
   - Handles cancellation scheduling

4. **customer.subscription.deleted**
   - Triggered when subscription ends
   - Resets user to free tier
   - Clears plan limits

5. **customer.subscription.trial_will_end**
   - Triggered 3 days before trial ends
   - Can trigger reminder emails

6. **invoice.payment_succeeded**
   - Triggered on successful payment
   - Updates billing sync status

7. **invoice.payment_failed**
   - Triggered on failed payment
   - Can trigger dunning emails

8. **setup_intent.succeeded**
   - Triggered when payment method is set up
   - Links payment method to customer

9. **payment_method.attached**
   - Triggered when card is added
   - Stores card details (last4, brand, exp)

### Price ID to Plan Mapping

**Critical Logic (from webhook handler):**
```typescript
function getPlanFromPriceId(priceId: string): string {
  const priceIdToplan = {
    [process.env.STRIPE_GLOW_UP_MONTHLY_PRICE_ID!]: 'glow_up',
    [process.env.STRIPE_GLOW_UP_YEARLY_PRICE_ID!]: 'glow_up',
    [process.env.STRIPE_VIRAL_SURGE_MONTHLY_PRICE_ID!]: 'viral_surge',
    [process.env.STRIPE_VIRAL_SURGE_YEARLY_PRICE_ID!]: 'viral_surge',
    [process.env.STRIPE_FAME_FLEX_MONTHLY_PRICE_ID!]: 'fame_flex',
    [process.env.STRIPE_FAME_FLEX_YEARLY_PRICE_ID!]: 'fame_flex',
  };

  return priceIdToplan[priceId] || 'unknown';
}
```

**CRITICAL**: Never use arbitrary fallback plans. If plan cannot be determined, throw error and retry webhook.

### Trial System

**Trial Logic:** `/lib/services/trial-status-calculator.ts`

**Trial States:**
- `inactive`: No trial started
- `active`: Currently in trial period
- `expired`: Trial ended without conversion
- `converted`: Trial converted to paid subscription

**Trial Activation:**
```typescript
// During subscription creation webhook
if (subscription.trial_end && subscription.status === 'trialing') {
  await updateUserProfile(userId, {
    trialStatus: 'active',
    trialStartDate: new Date(),
    trialEndDate: new Date(subscription.trial_end * 1000),
    onboardingStep: 'completed'
  });
}
```

**Trial Conversion:**
```typescript
// During subscription update webhook
if (subscription.status === 'active' && user.trialStatus === 'active') {
  await updateUserProfile(userId, {
    trialStatus: 'converted',
    trialConversionDate: new Date()
  });
}
```

### Billing Sync States

**Field:** `billingSyncStatus` in user_profiles table

**Possible Values:**
- `webhook_subscription_created` - Subscription created successfully
- `webhook_subscription_updated` - Subscription updated
- `webhook_subscription_deleted` - Subscription cancelled
- `webhook_trial_will_end` - Trial ending soon
- `webhook_payment_succeeded` - Payment successful
- `webhook_payment_failed` - Payment failed
- `webhook_setup_intent_succeeded` - Payment method added
- `webhook_payment_method_attached` - Card attached
- `webhook_emergency_fallback` - Webhook failed, used fallback

**Checking Sync Status:**
```bash
node scripts/inspect-user-state.js --email user@example.com
```

## Common Patterns

### Pattern 1: Enforcing Plan Limits Before Action

```typescript
// Good: Always validate before expensive operations
export async function POST(req: Request) {
  const { userId } = await getAuthOrTest();

  // Validate BEFORE creating campaign
  const validation = await PlanEnforcementService.validateCampaignCreation(userId);

  if (!validation.allowed) {
    return NextResponse.json(
      {
        error: validation.reason,
        usage: validation.usage,
        upgrade_required: true
      },
      { status: 403 }
    );
  }

  // Create campaign...
  const campaign = await db.insert(campaigns).values({ /* ... */ });

  // Track usage AFTER success
  await PlanEnforcementService.trackCampaignCreated(userId);

  return NextResponse.json({ campaign });
}
```

**When to use**: Before any action that counts against limits

### Pattern 2: Webhook Signature Verification

```typescript
// Good: Always verify webhook signatures in production
export async function POST(req: NextRequest) {
  const body = await req.text();
  const signature = req.headers.get('stripe-signature');

  if (!signature) {
    return NextResponse.json({ error: 'No signature' }, { status: 400 });
  }

  // Validate signature using Stripe SDK
  const event = StripeService.validateWebhookSignature(body, signature);

  // Process webhook event...
  switch (event.type) {
    case 'customer.subscription.created':
      await handleSubscriptionCreated(event.data.object);
      break;
    // ...
  }

  return NextResponse.json({ received: true });
}
```

**When to use**: All Stripe webhook endpoints

### Pattern 3: Resolving Plan from Subscription

```typescript
// Good: Multiple fallback strategies for plan resolution
async function resolvePlanFromSubscription(subscription: Stripe.Subscription): Promise<string> {
  // Strategy 1: Check metadata
  let planId = subscription.metadata.plan || subscription.metadata.planId;

  // Strategy 2: Derive from price ID
  if (!planId || planId === 'unknown') {
    const priceId = subscription.items.data[0]?.price?.id;
    if (priceId) {
      planId = getPlanFromPriceId(priceId);
    }
  }

  // Strategy 3: Throw error and retry webhook
  if (!planId || planId === 'unknown') {
    throw new Error(
      `Cannot determine plan for subscription ${subscription.id}. Will retry.`
    );
  }

  return planId;
}
```

**When to use**: Processing subscription webhooks

## Anti-Patterns (Avoid These)

### Anti-Pattern 1: Using Arbitrary Fallback Plans

```typescript
// BAD: Can cause upgrade bugs where users get wrong plan
function getPlanFromPriceId(priceId: string): string {
  const mapping = { /* ... */ };
  return mapping[priceId] || 'glow_up'; // WRONG!
}
```

**Why it's bad**: User pays for Fame Flex but gets Glow Up limits

**Do this instead**:
```typescript
// GOOD: Throw error and retry webhook
function getPlanFromPriceId(priceId: string): string {
  const mapping = { /* ... */ };
  const plan = mapping[priceId];

  if (!plan) {
    throw new Error(`Unknown price ID: ${priceId}. Webhook will retry.`);
  }

  return plan;
}
```

### Anti-Pattern 2: Tracking Usage Before Validation

```typescript
// BAD: User exceeds limit but usage is tracked anyway
await PlanEnforcementService.trackCampaignCreated(userId);

const validation = await PlanEnforcementService.validateCampaignCreation(userId);
if (!validation.allowed) {
  return NextResponse.json({ error: 'Limit exceeded' }, { status: 403 });
}
```

**Why it's bad**: Usage counter increases even when action fails

**Do this instead**:
```typescript
// GOOD: Validate → Action → Track
const validation = await PlanEnforcementService.validateCampaignCreation(userId);
if (!validation.allowed) {
  return NextResponse.json({ error: 'Limit exceeded' }, { status: 403 });
}

const campaign = await createCampaign(/* ... */);
await PlanEnforcementService.trackCampaignCreated(userId);
```

### Anti-Pattern 3: Skipping Webhook Verification

```typescript
// BAD: Accepting unauthenticated webhooks
export async function POST(req: Request) {
  const event = await req.json();
  // Process without verification - DANGEROUS!
  await handleSubscriptionCreated(event.data.object);
}
```

**Why it's bad**: Anyone can forge webhooks and manipulate plans

**Do this instead**:
```typescript
// GOOD: Always verify signatures
const body = await req.text();
const signature = req.headers.get('stripe-signature');

if (!signature) {
  return NextResponse.json({ error: 'No signature' }, { status: 400 });
}

const event = StripeService.validateWebhookSignature(body, signature);
```

## Troubleshooting Guide

### Problem: User Plan Not Updating After Payment

**Symptoms:**
- User completed checkout but still shows free plan
- Stripe dashboard shows active subscription
- User cannot access paid features

**Diagnosis:**
1. Check webhook delivery in Stripe dashboard
2. Verify webhook endpoint is accessible
3. Check `billing_sync_status` in database
4. Look for errors in webhook logs

```bash
# Check user state
node scripts/inspect-user-state.js --email user@example.com

# Check webhook logs (if available)
grep "STRIPE-WEBHOOK" logs/app.log | grep "ERROR"
```

**Solution:**
```bash
# Manual sync (use admin endpoint or script)
curl -X POST http://localhost:3000/api/billing/sync-stripe \
  -H "x-dev-auth: dev-bypass" \
  -H "Content-Type: application/json" \
  -d '{"userId": "user_xxx"}'
```

### Problem: Plan Limits Not Enforced

**Symptoms:**
- User exceeds campaign limit but can create more
- Creator count not tracked
- No "upgrade required" error

**Diagnosis:**
1. Check if validation is called before action
2. Verify `PLAN_VALIDATION_BYPASS` is not set in production
3. Check plan limits in `subscription_plans` table
4. Verify usage tracking is called after action

**Solution:**
```typescript
// Add enforcement to endpoint
import { PlanEnforcementService } from '@/lib/services/plan-enforcement';

export async function POST(req: Request) {
  const { userId } = await getAuthOrTest();

  // ADD THIS
  const validation = await PlanEnforcementService.validateCampaignCreation(userId);
  if (!validation.allowed) {
    return NextResponse.json({ error: validation.reason }, { status: 403 });
  }

  // Create campaign...

  // ADD THIS
  await PlanEnforcementService.trackCampaignCreated(userId);

  return NextResponse.json({ success: true });
}
```

### Problem: Trial Not Activating After Checkout

**Symptoms:**
- User completed checkout with trial
- `trial_status` is `inactive`
- `onboarding_step` not `completed`

**Diagnosis:**
1. Check if `checkout.session.completed` webhook fired
2. Verify subscription has `trial_end` timestamp
3. Check `finalizeOnboarding` was called
4. Look for errors in webhook logs

**Solution:**
```bash
# Manually complete onboarding
node scripts/complete-onboarding-and-activate-plan.js user_xxx
```

Or trigger via API:
```bash
curl -X POST http://localhost:3000/api/onboarding/complete \
  -H "x-dev-auth: dev-bypass" \
  -H "x-dev-user-id: user_xxx"
```

### Problem: Webhook Failing with "Unknown Price ID"

**Symptoms:**
- Webhook returns 500 error
- Logs show "Cannot determine plan"
- User plan not updated

**Diagnosis:**
1. Check if price ID exists in Stripe dashboard
2. Verify `.env` has all `STRIPE_*_PRICE_ID` variables
3. Check for typos in environment variables
4. Ensure webhook uses correct price ID mapping

**Solution:**
```bash
# Verify environment variables
grep "STRIPE_.*PRICE_ID" .env.local

# Expected output:
STRIPE_GLOW_UP_MONTHLY_PRICE_ID=price_xxx
STRIPE_GLOW_UP_YEARLY_PRICE_ID=price_yyy
# ... etc
```

If missing, add to `.env.local` and restart server.

### Problem: User Upgraded But Still Has Old Limits

**Symptoms:**
- User paid for Viral Surge but has Glow Up limits
- `current_plan` is correct but `plan_campaigns_limit` is wrong
- Can't create more campaigns despite upgrade

**Diagnosis:**
1. Check `subscription.updated` webhook fired
2. Verify plan limits are fetched from `subscription_plans` table
3. Check webhook sets `planCampaignsLimit` and `planCreatorsLimit`

**Solution:**
```typescript
// In webhook handler, ensure limits are updated:
const planDetails = await db.query.subscriptionPlans.findFirst({
  where: eq(subscriptionPlans.planKey, planId)
});

await updateUserProfile(userId, {
  currentPlan: planId,
  planCampaignsLimit: planDetails?.campaignsLimit || 0,
  planCreatorsLimit: planDetails?.creatorsLimit || 0
});
```

## Related Files

- `/lib/services/plan-enforcement.ts` - Plan validation and usage tracking
- `/lib/services/billing-service.ts` - Billing operations
- `/lib/stripe/stripe-service.ts` - Stripe client wrapper
- `/app/api/stripe/webhook/route.ts` - Webhook event handlers
- `/app/api/billing/status/route.ts` - Get billing status
- `/app/api/billing/sync-stripe/route.ts` - Manual sync endpoint
- `/app/api/campaigns/can-create/route.ts` - Campaign validation endpoint
- `/scripts/inspect-user-state.js` - Diagnostic script
- `/scripts/fix-user-billing-state.js` - Fix script

## Testing & Validation

**Test Plan Enforcement:**
```bash
# Create user with specific plan
node scripts/complete-onboarding-and-activate-plan.js user_xxx glow_up

# Try creating campaigns
curl -X POST http://localhost:3000/api/campaigns \
  -H "x-dev-user-id: user_xxx" \
  -d '{"name": "Test Campaign 1"}'

# Check usage
curl http://localhost:3000/api/billing/status \
  -H "x-dev-user-id: user_xxx"
```

**Test Stripe Webhooks Locally:**
```bash
# Install Stripe CLI
stripe listen --forward-to localhost:3000/api/stripe/webhook

# Trigger test webhook
stripe trigger customer.subscription.created
```

**Expected Behavior:**
1. Webhook received and verified
2. User plan updated in database
3. Plan limits set correctly
4. Billing sync status updated
5. No errors in logs

## Subscription Flow Diagram

```
User Checkout
    ↓
Stripe Checkout Session
    ↓
checkout.session.completed (webhook)
    ↓
Link Stripe Customer to User
    ↓
customer.subscription.created (webhook)
    ↓
Resolve Plan from Price ID
    ↓
Update user_profiles:
  - current_plan
  - plan_campaigns_limit
  - plan_creators_limit
  - stripe_subscription_id
  - subscription_status
  - trial_status (if trial)
    ↓
Finalize Onboarding
    ↓
User Can Access Platform
```

## Additional Resources

- [Stripe Webhooks Documentation](https://stripe.com/docs/webhooks)
- [Stripe Subscriptions Guide](https://stripe.com/docs/billing/subscriptions/overview)
- [Stripe Testing](https://stripe.com/docs/testing)
- Internal: `/docs/upgrade-user.md` (if exists)
