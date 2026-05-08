---
name: entitlements-management
description: Use when implementing feature gating, quota enforcement, and plan-based access control. Covers entitlements vs feature flags, quota systems, and integration with subscription tiers.
allowed-tools: Read, Glob, Grep, Task
---

# Entitlements Management

Patterns for controlling feature access and enforcing usage quotas based on subscription plans.

## When to Use This Skill

- Implementing feature gating based on subscription tier
- Enforcing usage quotas (API calls, storage, seats)
- Designing entitlements architecture
- Choosing between feature flags and entitlements
- Building upgrade/upsell triggers

## Entitlements vs Feature Flags

```text
Key Distinction:
┌────────────────────────────────────────────────────────────┐
│                                                            │
│  FEATURE FLAGS                 ENTITLEMENTS                │
│  ─────────────                 ────────────                │
│  Release management            Access control              │
│  A/B testing                   Plan-based gating           │
│  Gradual rollouts              Quota enforcement           │
│  Kill switches                 Subscription features       │
│  Temporary                     Permanent                   │
│  Dev/ops controlled            Business controlled         │
│                                                            │
│  "Is this feature ready?"      "Can this customer use it?" │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Example:                                              │  │
│  │ - Feature Flag: "dark_mode_v2" = true (released)     │  │
│  │ - Entitlement: "dark_mode" = Pro plan only           │  │
│  │                                                       │  │
│  │ Check: featureEnabled && hasEntitlement              │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Entitlements Architecture

### Core Concepts

```text
Entitlements Model:
┌────────────────────────────────────────────────────────────┐
│                                                            │
│  PLAN DEFINITION                                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Plan: Pro                                             │  │
│  │ ├── Features: [analytics, api_access, custom_domain] │  │
│  │ ├── Quotas:                                          │  │
│  │ │   ├── api_calls: 10,000/month                      │  │
│  │ │   ├── storage_gb: 50                               │  │
│  │ │   └── team_members: 10                             │  │
│  │ └── Limits:                                          │  │
│  │     ├── projects: 100                                │  │
│  │     └── integrations: 5                              │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
│  CUSTOMER ENTITLEMENTS                                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Customer: Acme Corp                                   │  │
│  │ Base Plan: Pro                                        │  │
│  │ Overrides:                                            │  │
│  │ ├── storage_gb: 100 (negotiated)                     │  │
│  │ └── api_calls: 50,000 (add-on purchased)             │  │
│  │ Usage:                                                │  │
│  │ ├── api_calls: 8,500 / 50,000 (17%)                  │  │
│  │ └── storage_gb: 42 / 100 (42%)                       │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Data Model

```text
Entitlements Schema:
┌────────────────────────────────────────────────────────────┐
│                                                            │
│ plans                                                      │
│ ├── id: UUID                                              │
│ ├── name: "Pro"                                           │
│ ├── price_monthly: 99.00                                  │
│ └── is_active: true                                       │
│                                                            │
│ plan_features (many-to-many)                              │
│ ├── plan_id: FK → plans                                   │
│ ├── feature_id: FK → features                            │
│ └── enabled: true                                         │
│                                                            │
│ plan_quotas                                                │
│ ├── plan_id: FK → plans                                   │
│ ├── quota_type: "api_calls"                               │
│ ├── limit_value: 10000                                    │
│ ├── period: "monthly" | "daily" | "unlimited"            │
│ └── enforcement: "hard" | "soft" | "warning"             │
│                                                            │
│ customer_entitlements (per-customer overrides)            │
│ ├── customer_id: FK → customers                          │
│ ├── feature_id: FK → features (nullable)                 │
│ ├── quota_type: string (nullable)                        │
│ ├── override_value: varies                               │
│ └── expires_at: timestamp (nullable)                     │
│                                                            │
│ usage_records                                              │
│ ├── customer_id: FK → customers                          │
│ ├── quota_type: "api_calls"                               │
│ ├── period_start: date                                   │
│ ├── current_usage: 8500                                  │
│ └── last_updated: timestamp                              │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Feature Gating Patterns

### Boolean Feature Access

```text
Simple Feature Check:
┌────────────────────────────────────────────────────────────┐
│ // Service layer                                           │
│ public async Task<bool> CanAccessFeatureAsync(            │
│   string customerId, string featureKey)                   │
│ {                                                          │
│   var entitlements = await _entitlementService            │
│     .GetCustomerEntitlementsAsync(customerId);            │
│                                                            │
│   return entitlements.HasFeature(featureKey);             │
│ }                                                          │
│                                                            │
│ // Usage                                                   │
│ if (await CanAccessFeatureAsync(customerId, "analytics")) │
│ {                                                          │
│   // Show analytics dashboard                              │
│ }                                                          │
│ else                                                       │
│ {                                                          │
│   // Show upgrade prompt                                   │
│ }                                                          │
└────────────────────────────────────────────────────────────┘
```

### Tiered Feature Access

```text
Feature with Tier Levels:
┌────────────────────────────────────────────────────────────┐
│ Feature: "export"                                          │
│ ├── Free:       CSV only                                  │
│ ├── Pro:        CSV, Excel                                │
│ └── Enterprise: CSV, Excel, PDF, API                      │
│                                                            │
│ // Implementation                                          │
│ public async Task<ExportCapabilities> GetExportCapabilities│
│   (string customerId)                                      │
│ {                                                          │
│   var tier = await GetCustomerTier(customerId);           │
│                                                            │
│   return tier switch                                       │
│   {                                                        │
│     "free" => new([ExportFormat.Csv]),                    │
│     "pro" => new([ExportFormat.Csv, ExportFormat.Excel]), │
│     "enterprise" => new([..all formats..]),               │
│     _ => throw new InvalidTierException()                 │
│   };                                                       │
│ }                                                          │
└────────────────────────────────────────────────────────────┘
```

## Quota Enforcement

### Quota Types

```text
Quota Categories:
┌────────────────────────────────────────────────────────────┐
│ Type          │ Examples                │ Reset           │
│ ──────────────┼─────────────────────────┼──────────────── │
│ Rate Limits   │ API calls/minute        │ Rolling window  │
│ Usage Quotas  │ API calls/month         │ Billing cycle   │
│ Storage       │ GB stored               │ Never (current) │
│ Count Limits  │ Projects, team members  │ Never (current) │
│ Bandwidth     │ GB transferred/month    │ Billing cycle   │
└────────────────────────────────────────────────────────────┘
```

### Enforcement Levels

```text
Enforcement Strategies:
┌────────────────────────────────────────────────────────────┐
│                                                            │
│ WARNING (Soft Limit)                                       │
│ ├── Notify user approaching limit                         │
│ ├── Continue allowing usage                               │
│ ├── Log for billing/upsell                               │
│ └── Example: "You've used 80% of your API quota"          │
│                                                            │
│ SOFT LIMIT                                                 │
│ ├── Allow overage with warning                            │
│ ├── May incur overage charges                             │
│ ├── Grace period before hard enforcement                  │
│ └── Example: Storage overage at $0.10/GB                  │
│                                                            │
│ HARD LIMIT                                                 │
│ ├── Block access when limit reached                       │
│ ├── Return 429 Too Many Requests                          │
│ ├── Require upgrade to continue                           │
│ └── Example: "API limit reached. Upgrade to continue."    │
│                                                            │
│ DEGRADED SERVICE                                           │
│ ├── Reduce service quality instead of blocking            │
│ ├── Slower response times                                 │
│ ├── Reduced features                                      │
│ └── Example: Lower priority queue for API requests        │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Quota Check Implementation

```text
Quota Checking Pattern:
┌────────────────────────────────────────────────────────────┐
│ public record QuotaCheckResult(                           │
│   bool IsAllowed,                                         │
│   long CurrentUsage,                                      │
│   long Limit,                                             │
│   QuotaStatus Status,                                     │
│   string? Message);                                       │
│                                                            │
│ public async Task<QuotaCheckResult> CheckQuotaAsync(      │
│   string customerId,                                       │
│   string quotaType,                                        │
│   int requestedAmount = 1)                                │
│ {                                                          │
│   var quota = await GetQuotaAsync(customerId, quotaType); │
│   var usage = await GetUsageAsync(customerId, quotaType); │
│                                                            │
│   var newUsage = usage.Current + requestedAmount;         │
│   var percentUsed = (newUsage * 100) / quota.Limit;       │
│                                                            │
│   if (newUsage > quota.Limit)                             │
│   {                                                        │
│     return new(false, usage.Current, quota.Limit,         │
│       QuotaStatus.Exceeded,                               │
│       $"Quota exceeded. Limit: {quota.Limit}");          │
│   }                                                        │
│                                                            │
│   if (percentUsed >= 90)                                  │
│   {                                                        │
│     return new(true, newUsage, quota.Limit,               │
│       QuotaStatus.Warning,                                │
│       $"Approaching limit: {percentUsed}% used");        │
│   }                                                        │
│                                                            │
│   return new(true, newUsage, quota.Limit,                 │
│     QuotaStatus.Ok, null);                                │
│ }                                                          │
└────────────────────────────────────────────────────────────┘
```

### Usage Recording

```text
Increment Usage Pattern:
┌────────────────────────────────────────────────────────────┐
│ // High-performance: Async increment with eventual sync    │
│                                                            │
│ 1. Request comes in                                        │
│    │                                                       │
│ 2. Check quota (from cache)                               │
│    │                                                       │
│ 3. Allow request (optimistic)                             │
│    │                                                       │
│ 4. Increment local counter                                │
│    │                                                       │
│ 5. Async: Batch sync to database                          │
│    - Every N requests, or                                 │
│    - Every M seconds                                      │
│                                                            │
│ Trade-off:                                                 │
│ - Fast: No DB write per request                           │
│ - Risk: Slight over-quota before sync                     │
│ - Mitigation: Conservative thresholds (95% hard limit)   │
└────────────────────────────────────────────────────────────┘
```

## Upgrade Triggers

### Limit-Based Upsells

```text
Upgrade Trigger Points:
┌────────────────────────────────────────────────────────────┐
│ Trigger                   │ Action                         │
│ ──────────────────────────┼─────────────────────────────── │
│ 80% quota used            │ In-app warning banner          │
│ 100% quota reached        │ Block + upgrade modal          │
│ Feature attempted (gated) │ "Upgrade for X" dialog        │
│ Limit reached (projects)  │ "Upgrade for more projects"   │
│ High-tier feature preview │ "Available on Pro" overlay    │
└────────────────────────────────────────────────────────────┘

UX Best Practices:
┌────────────────────────────────────────────────────────────┐
│ ✓ Show value, not just restriction                        │
│   "Unlock analytics to understand your customers"         │
│   NOT "This feature is not available"                     │
│                                                            │
│ ✓ Provide clear path forward                              │
│   "Upgrade to Pro for $29/month"                          │
│   NOT "Contact sales"                                     │
│                                                            │
│ ✓ Be transparent about limits                             │
│   Progress bars showing usage                             │
│   Clear limit displays in settings                        │
│                                                            │
│ ✓ Offer alternatives                                      │
│   "Delete old projects" OR "Upgrade for unlimited"        │
└────────────────────────────────────────────────────────────┘
```

## Third-Party Entitlement Services

### Service Comparison

```text
Entitlement Platforms:
┌────────────────────────────────────────────────────────────┐
│ Service       │ Strengths                │ Best For        │
│ ──────────────┼──────────────────────────┼──────────────── │
│ LaunchDarkly  │ Feature flags + basic    │ Flag-heavy apps │
│               │ targeting                │                 │
│ ──────────────┼──────────────────────────┼──────────────── │
│ Stigg         │ Full entitlements +      │ SaaS billing    │
│               │ metering                 │                 │
│ ──────────────┼──────────────────────────┼──────────────── │
│ Schematic     │ Entitlements-first      │ Enterprise SaaS │
│ ──────────────┼──────────────────────────┼──────────────── │
│ Custom        │ Full control             │ Complex needs   │
└────────────────────────────────────────────────────────────┘
```

### Integration Pattern

```text
LaunchDarkly with Entitlements:
┌────────────────────────────────────────────────────────────┐
│ // Combine feature flags with entitlements                 │
│                                                            │
│ public async Task<bool> IsFeatureEnabled(                 │
│   string customerId, string featureKey)                   │
│ {                                                          │
│   // Check feature flag (is it released?)                 │
│   var flagEnabled = await _launchDarkly                   │
│     .BoolVariation(featureKey, user, false);              │
│                                                            │
│   if (!flagEnabled) return false;                         │
│                                                            │
│   // Check entitlement (can this customer use it?)        │
│   var hasEntitlement = await _entitlementService          │
│     .HasFeatureAsync(customerId, featureKey);             │
│                                                            │
│   return hasEntitlement;                                   │
│ }                                                          │
└────────────────────────────────────────────────────────────┘
```

## Caching Strategy

### Entitlements Caching

```text
Cache Architecture:
┌────────────────────────────────────────────────────────────┐
│                                                            │
│ Request → Check Cache → Cache Hit? → Return               │
│              │                                             │
│              └──→ Cache Miss → Load from DB → Cache       │
│                                                            │
│ Cache Configuration:                                       │
│ ├── Key: entitlements:{customer_id}                       │
│ ├── TTL: 5 minutes (balance freshness vs load)            │
│ ├── Invalidation: On plan change, purchase, override     │
│ └── Type: Distributed (Redis) for multi-instance         │
│                                                            │
│ Invalidation Triggers:                                     │
│ ├── Subscription upgraded/downgraded                      │
│ ├── Add-on purchased                                      │
│ ├── Trial started/ended                                   │
│ ├── Custom override applied                               │
│ └── Billing period changed                                │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Testing Entitlements

### Test Scenarios

```text
Critical Test Cases:
┌────────────────────────────────────────────────────────────┐
│ Feature Access:                                            │
│ ✓ User on Free cannot access Pro feature                  │
│ ✓ User on Pro can access Pro feature                      │
│ ✓ Downgrade removes feature access                        │
│ ✓ Upgrade grants feature access                           │
│ ✓ Trial grants temporary access                           │
│ ✓ Expired trial removes access                            │
│                                                            │
│ Quota Enforcement:                                         │
│ ✓ Usage below limit allowed                               │
│ ✓ Usage at limit shows warning                            │
│ ✓ Usage over limit blocked (hard limit)                   │
│ ✓ Usage over limit logged (soft limit)                    │
│ ✓ Quota reset at billing cycle                            │
│ ✓ Upgrade increases quota                                 │
│                                                            │
│ Edge Cases:                                                │
│ ✓ Concurrent requests near limit                          │
│ ✓ Plan change mid-billing cycle                           │
│ ✓ Multiple overrides (most permissive wins?)              │
│ ✓ Expired override reverts to plan                        │
└────────────────────────────────────────────────────────────┘
```

## Best Practices

```text
Entitlements Best Practices:
┌────────────────────────────────────────────────────────────┐
│ 1. Separation of Concerns                                  │
│    - Feature flags: Release management                    │
│    - Entitlements: Access control                         │
│    - Don't mix them                                       │
│                                                            │
│ 2. Fail Open or Closed?                                   │
│    - Critical features: Fail closed (deny on error)      │
│    - Nice-to-have: Fail open (allow on error)            │
│    - Always log failures for investigation               │
│                                                            │
│ 3. Graceful Degradation                                   │
│    - Show what they can't access (with upgrade CTA)       │
│    - Don't hide features entirely                        │
│    - Preview mode for gated features                     │
│                                                            │
│ 4. Transparency                                            │
│    - Clear usage dashboards                               │
│    - Proactive limit warnings                             │
│    - Self-serve upgrade paths                             │
│                                                            │
│ 5. Performance                                             │
│    - Cache aggressively, invalidate precisely             │
│    - Batch usage updates                                  │
│    - Check entitlements once per request                  │
└────────────────────────────────────────────────────────────┘
```

## Related Skills

- `subscription-models` - Pricing tier design
- `usage-metering` - Event-driven usage tracking
- `billing-integration` - Stripe entitlements sync

## References

- Load  for feature gating patterns
- Load  for quota system design

---

**Last Updated:** 2025-12-26
