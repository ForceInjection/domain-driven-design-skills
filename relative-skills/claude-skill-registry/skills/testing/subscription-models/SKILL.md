---
name: subscription-models
description: Use when designing SaaS pricing and subscription models. Covers per-seat, tiered, usage-based, and hybrid pricing patterns with Stripe integration, plan transitions, and revenue optimization.
allowed-tools: Read, Glob, Grep, Task
---

# Subscription and Pricing Models

Patterns for SaaS pricing strategies, subscription management, and billing integration.

## When to Use This Skill

- Designing pricing strategy for a new SaaS product
- Implementing subscription management system
- Integrating with payment providers (Stripe, etc.)
- Managing plan upgrades/downgrades
- Optimizing conversion and revenue

## Pricing Model Spectrum

```text
Fixed                                                Usage-Based
  ◄──────────────────────────────────────────────────────────►

┌──────────────┬──────────────┬──────────────┬──────────────┐
│   Flat-Rate  │   Per-Seat   │    Tiered    │   Metered    │
├──────────────┼──────────────┼──────────────┼──────────────┤
│ $99/month    │ $10/user/mo  │ $99-$999/mo  │ $0.01/API    │
│ All features │ Feature sets │ Feature tiers│ Pay-as-go    │
│ Unlimited use│ Scale w/team │ Upgrade path │ Variable cost│
├──────────────┼──────────────┼──────────────┼──────────────┤
│ Simple       │ Predictable  │ Flexible     │ Aligned      │
│ Low friction │ Team growth  │ Segmentation │ Fair pricing │
└──────────────┴──────────────┴──────────────┴──────────────┘
```

## Model 1: Per-Seat Pricing

### Concept

```text
Per-Seat Model:
┌────────────────────────────────────────────────────────────┐
│ Price = Base Price × Number of Licensed Users              │
│                                                            │
│ Example:                                                   │
│ - $15/user/month                                          │
│ - 10 users = $150/month                                   │
│ - Add user = +$15/month (prorated)                        │
│ - Remove user = -$15/month (credit or next cycle)         │
│                                                            │
│ Variations:                                                │
│ - Banded: First 5 users $20, next 10 users $15           │
│ - Volume: 1-10 users $20, 11-50 users $15, 51+ $10       │
│ - Named vs Concurrent: Different licensing models         │
└────────────────────────────────────────────────────────────┘
```

### User Types

```text
User Classification:
┌────────────────────────────────────────────────────────────┐
│ User Type       │ Description           │ Billing          │
│ ───────────────┼───────────────────────┼─────────────────  │
│ Full User       │ All features          │ Full price       │
│ Light User      │ Limited features      │ Reduced price    │
│ Read-Only       │ View only             │ Free or minimal  │
│ External        │ Guest/client access   │ Often free       │
│ Admin           │ Platform admin        │ May be free      │
│ ───────────────┼───────────────────────┼─────────────────  │
│ Example: Slack                                             │
│ - Full: $8.75/user/month                                  │
│ - Guest: Free (limited channels)                          │
└────────────────────────────────────────────────────────────┘
```

### When to Use

```text
✅ Ideal For:
- Collaboration tools (Slack, Teams, Notion)
- CRM systems (Salesforce, HubSpot)
- Project management (Jira, Asana)
- Clear per-person value
- Team-based products

❌ Avoid When:
- Value not tied to user count
- Automation-heavy (fewer users, same value)
- Consumer apps (too friction-heavy)
- API-first products
```

## Model 2: Tiered Pricing

### Concept

```text
Tiered Model:
┌────────────────────────────────────────────────────────────┐
│                    PRICING TIERS                           │
│                                                            │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │    FREE      │ │    PRO       │ │  ENTERPRISE  │       │
│  │              │ │              │ │              │       │
│  │   $0/month   │ │  $29/month   │ │  $99/month   │       │
│  │              │ │              │ │              │       │
│  │ ✓ 3 projects │ │ ✓ Unlimited  │ │ ✓ Unlimited  │       │
│  │ ✓ 1 GB       │ │ ✓ 50 GB      │ │ ✓ 500 GB     │       │
│  │ ✓ Community  │ │ ✓ Email      │ │ ✓ Priority   │       │
│  │              │ │ ✓ Analytics  │ │ ✓ SSO/SAML   │       │
│  │              │ │              │ │ ✓ API Access │       │
│  │              │ │              │ │ ✓ Audit Log  │       │
│  └──────────────┘ └──────────────┘ └──────────────┘       │
│                                                            │
│  Upgrade triggers:                                         │
│  - Feature needs (SSO, API)                               │
│  - Usage limits (storage, projects)                       │
│  - Support requirements                                   │
└────────────────────────────────────────────────────────────┘
```

### Tier Design Best Practices

```text
Tier Structure Guidelines:
┌────────────────────────────────────────────────────────────┐
│ 1. Three Tiers (Good-Better-Best)                          │
│    - Free/Starter: Lead generation, self-qualification    │
│    - Pro/Growth: Core paying customers                    │
│    - Enterprise: High-value, sales-assisted               │
│                                                            │
│ 2. Clear Upgrade Triggers                                  │
│    - Usage limits that grow with success                  │
│    - Features that unlock as needs mature                 │
│    - Not artificial restrictions                          │
│                                                            │
│ 3. 10x Value Gap Rule                                      │
│    - Each tier should provide 10x more value              │
│    - Justifies 2-3x price increase                        │
│                                                            │
│ 4. Anchor Pricing                                          │
│    - Middle tier is most popular (position it)            │
│    - Enterprise tier makes Pro look reasonable            │
└────────────────────────────────────────────────────────────┘
```

### When to Use

```text
✅ Ideal For:
- Products with clear feature segmentation
- SMB to Enterprise sales motion
- Self-serve + sales-assisted mix
- Clear upgrade path based on growth

❌ Avoid When:
- Hard to differentiate features
- Continuous value spectrum (use usage-based)
- Very small market (custom pricing better)
```

## Model 3: Usage-Based Pricing

### Concept

```text
Usage-Based (Metered) Model:
┌────────────────────────────────────────────────────────────┐
│ Price = Unit Price × Units Consumed                        │
│                                                            │
│ Examples:                                                  │
│ ┌─────────────────┬────────────────────────────────────┐  │
│ │ Product         │ Unit                               │  │
│ ├─────────────────┼────────────────────────────────────┤  │
│ │ AWS             │ Compute hours, storage GB          │  │
│ │ Twilio          │ SMS sent, minutes used             │  │
│ │ Stripe          │ Transactions processed             │  │
│ │ Snowflake       │ Compute credits                    │  │
│ │ OpenAI          │ Tokens processed                   │  │
│ │ SendGrid        │ Emails sent                        │  │
│ └─────────────────┴────────────────────────────────────┘  │
│                                                            │
│ Billing Models:                                            │
│ - Pay-as-you-go: Bill for exact usage                     │
│ - Prepaid credits: Buy credits upfront (discount)         │
│ - Committed use: Commit to minimum (bigger discount)      │
└────────────────────────────────────────────────────────────┘
```

### Metering Implementation

```text
Usage Metering Architecture:
┌────────────────────────────────────────────────────────────┐
│                                                            │
│   Application                                              │
│       │                                                    │
│       ▼                                                    │
│   ┌─────────────────────────────────────────────────────┐  │
│   │ Usage Event Publisher                               │  │
│   │ - tenant_id, metric_id, quantity, timestamp        │  │
│   └───────────────────────┬─────────────────────────────┘  │
│                           │                                │
│                           ▼                                │
│   ┌─────────────────────────────────────────────────────┐  │
│   │ Event Queue (Kafka, SQS, EventHub)                  │  │
│   └───────────────────────┬─────────────────────────────┘  │
│                           │                                │
│                           ▼                                │
│   ┌─────────────────────────────────────────────────────┐  │
│   │ Aggregation Service                                 │  │
│   │ - Hourly/daily roll-ups                            │  │
│   │ - Deduplication                                    │  │
│   │ - Tenant isolation                                  │  │
│   └───────────────────────┬─────────────────────────────┘  │
│                           │                                │
│                           ▼                                │
│   ┌─────────────────────────────────────────────────────┐  │
│   │ Billing Integration (Stripe Metered Billing)        │  │
│   │ - Report usage to Stripe                           │  │
│   │ - Generate invoices                                │  │
│   └─────────────────────────────────────────────────────┘  │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### When to Use

```text
✅ Ideal For:
- API-first products
- Infrastructure/platform services
- Highly variable workloads
- Value scales with consumption
- Transparent, fair pricing

❌ Avoid When:
- Customers need budget predictability
- Hard to measure meaningful units
- Low-volume, high-value interactions
- Consumer products (prefer flat rate)
```

## Model 4: Hybrid Pricing

### Concept

```text
Hybrid Model (Base + Usage):
┌────────────────────────────────────────────────────────────┐
│ Price = Base Platform Fee + Usage Charges                  │
│                                                            │
│ Example: HubSpot                                           │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ Professional Plan: $800/month (base)                   │ │
│ │ + $50/month per 1,000 additional contacts              │ │
│ │ = Predictable base + scales with usage                 │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                            │
│ Benefits:                                                  │
│ - Predictable revenue floor                               │
│ - Grows with customer success                             │
│ - Easier to budget than pure usage                        │
│ - Captures value at scale                                 │
└────────────────────────────────────────────────────────────┘
```

### Tier + Usage Combination

```text
Tiered Features + Usage Metering:
┌────────────────────────────────────────────────────────────┐
│           │ Starter      │ Pro          │ Enterprise      │
│ ──────────┼──────────────┼──────────────┼─────────────────│
│ Base      │ $0           │ $99/mo       │ $499/mo         │
│ ──────────┼──────────────┼──────────────┼─────────────────│
│ API Calls │ 1K free      │ 10K included │ 100K included   │
│ Overage   │ $0.01/call   │ $0.005/call  │ $0.002/call     │
│ ──────────┼──────────────┼──────────────┼─────────────────│
│ Storage   │ 1 GB         │ 50 GB        │ 500 GB          │
│ Overage   │ $0.10/GB     │ $0.05/GB     │ $0.02/GB        │
│ ──────────┼──────────────┼──────────────┼─────────────────│
│ Features  │ Basic        │ + Analytics  │ + SSO, API Keys │
└────────────────────────────────────────────────────────────┘
```

## Plan Transitions

### Upgrade Flow

```text
Upgrade Handling:
┌────────────────────────────────────────────────────────────┐
│ 1. Immediate Upgrade (Recommended)                         │
│    - Prorate remaining time on current plan               │
│    - Apply as credit to new plan                          │
│    - Start billing new plan immediately                   │
│    - Unlock features instantly                            │
│                                                            │
│ 2. Next Cycle Upgrade                                      │
│    - Schedule upgrade for next billing date               │
│    - Continue current plan until then                     │
│    - Simpler billing, delayed value                       │
│                                                            │
│ Proration Example:                                         │
│ - Current: Pro $100/mo, used 15 days                      │
│ - Upgrade to: Enterprise $300/mo                          │
│ - Credit: $100 × (15/30) = $50 unused                     │
│ - New charge: $300 - $50 = $250 today                     │
│ - Next month: Full $300                                   │
└────────────────────────────────────────────────────────────┘
```

### Downgrade Flow

```text
Downgrade Handling:
┌────────────────────────────────────────────────────────────┐
│ 1. End of Cycle Downgrade (Recommended)                    │
│    - Continue current plan until period ends              │
│    - Apply new plan on next billing date                  │
│    - Preserve paid value, reduce churn                    │
│                                                            │
│ 2. Immediate Downgrade                                     │
│    - Apply credit for unused time (optional)              │
│    - May trigger data/feature loss                        │
│    - Handle gracefully (warning, export data)             │
│                                                            │
│ Feature Loss Handling:                                     │
│ - Warn user about features that will be lost              │
│ - Provide data export before downgrade                    │
│ - Grace period for critical features                      │
│ - Consider "soft" downgrade (hide, don't delete)          │
└────────────────────────────────────────────────────────────┘
```

## Trial and Freemium

### Trial Strategies

```text
Trial Models:
┌────────────────────────────────────────────────────────────┐
│ Time-Limited Trial:                                        │
│ - 14/30-day full access                                   │
│ - No payment required upfront                             │
│ - Converts or loses access                                │
│ - Best for: Products with learning curve                  │
│                                                            │
│ Credit Card Required Trial:                                │
│ - 7/14-day trial with card on file                        │
│ - Auto-converts unless canceled                           │
│ - Higher conversion, lower volume                         │
│ - Best for: High-intent customers                         │
│                                                            │
│ Freemium (Permanent Free Tier):                            │
│ - Limited free tier forever                               │
│ - Upgrade for more features/usage                         │
│ - Lead generation + virality                              │
│ - Best for: Products with network effects                 │
│                                                            │
│ Reverse Trial:                                             │
│ - Start on premium, downgrade to free                     │
│ - Experience full value first                             │
│ - Best for: Feature-rich products                         │
└────────────────────────────────────────────────────────────┘
```

### Conversion Optimization

```text
Trial-to-Paid Conversion:
┌────────────────────────────────────────────────────────────┐
│ Key Metrics:                                               │
│ - Trial start rate (visitors → trials)                    │
│ - Activation rate (trials → active use)                   │
│ - Conversion rate (trials → paid)                         │
│ - Time to value (days to first value moment)              │
│                                                            │
│ Optimization Tactics:                                      │
│ ───────────────────────────────────────────────────────── │
│ 1. Reduce time-to-value                                   │
│    - Onboarding flows                                     │
│    - Templates and presets                                │
│    - Quick-start guides                                   │
│                                                            │
│ 2. Demonstrate premium value                              │
│    - Feature previews (locked but visible)                │
│    - Usage limit warnings                                 │
│    - "You're using a Pro feature" nudges                  │
│                                                            │
│ 3. Timely conversion prompts                              │
│    - Email sequences (day 1, 7, 12, 14)                   │
│    - In-app reminders before expiry                       │
│    - Extension offers for engaged users                   │
└────────────────────────────────────────────────────────────┘
```

## Revenue Metrics

### Key SaaS Metrics

```text
Revenue Metrics:
┌────────────────────────────────────────────────────────────┐
│ MRR (Monthly Recurring Revenue):                           │
│ = Sum of all monthly subscription fees                    │
│                                                            │
│ ARR (Annual Recurring Revenue):                            │
│ = MRR × 12                                                │
│                                                            │
│ MRR Movement:                                              │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ New MRR          +$10,000  (new customers)             │ │
│ │ Expansion MRR    +$3,000   (upgrades, add-ons)         │ │
│ │ Contraction MRR  -$1,000   (downgrades)                │ │
│ │ Churned MRR      -$2,000   (cancellations)             │ │
│ │ ────────────────────────────────────────────────────── │ │
│ │ Net New MRR      +$10,000                              │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                            │
│ ARPU (Average Revenue Per User):                           │
│ = Total Revenue / Total Customers                         │
│                                                            │
│ LTV (Customer Lifetime Value):                             │
│ = ARPU × Average Customer Lifespan                        │
│ = ARPU / Churn Rate                                       │
│                                                            │
│ CAC (Customer Acquisition Cost):                           │
│ = Total Sales & Marketing / New Customers                 │
│                                                            │
│ LTV:CAC Ratio (Target: 3:1+):                             │
│ = LTV / CAC                                               │
└────────────────────────────────────────────────────────────┘
```

## Decision Framework

### Choosing Your Model

```text
Model Selection Guide:
┌────────────────────────────────────────────────────────────┐
│ Question                          → Recommendation         │
│ ─────────────────────────────────────────────────────────  │
│ Value scales with team size?      → Per-seat              │
│ Clear feature differentiation?    → Tiered                │
│ Value scales with consumption?    → Usage-based           │
│ Need predictable + variable?      → Hybrid                │
│                                                            │
│ Market Considerations:                                     │
│ ─────────────────────────────────────────────────────────  │
│ Enterprise B2B: Tiered + Per-seat                         │
│ SMB B2B: Tiered (simple, self-serve)                      │
│ Developer/API: Usage-based or Hybrid                      │
│ Consumer: Freemium + Tiered                               │
│ Infrastructure: Usage-based                               │
└────────────────────────────────────────────────────────────┘
```

## Related Skills

- `usage-metering` - Event-driven metering implementation
- `entitlements-management` - Feature gating and quotas
- `billing-integration` - Stripe and payment provider patterns
- `trial-conversion` - Trial optimization tactics

## References

- Load  for tier design patterns
- Load  for upgrade/downgrade handling

---

**Last Updated:** 2025-12-26
