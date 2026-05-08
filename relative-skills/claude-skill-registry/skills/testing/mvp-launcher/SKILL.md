---
name: mvp-launcher
description: Rapid MVP validation and launch framework following Y Combinator and lean startup principles. Use when user wants to validate a business idea, launch an MVP, define product strategy, calculate unit economics, or needs structured approach to test product-market fit. Includes monetization models, metrics frameworks, and execution templates.
---

# MVP Launcher

Framework for rapid MVP validation and launch using proven startup methodologies from Y Combinator, lean startup, and first-principles thinking.

## Core Workflow

### 1. Problem-Solution Validation

**Ask the forcing questions:**
- What specific problem are you solving? (Not a solution in disguise)
- Who has this problem urgently enough to pay?
- How are they solving it now? (Current alternatives = market validation)
- Why will they switch to your solution?

**Output:** One-sentence value proposition that passes the "mom test"

### 2. Market Sizing (Быстрая оценка)

Use `scripts/market_sizer.py` for TAM/SAM/SOM calculation:

```bash
python scripts/market_sizer.py --total-market 1000000 --addressable-percent 10 --obtainable-percent 5
```

**Reality checks:**
- TAM > $1B = maybe real market
- SAM > $100M = venture-scale potential
- SOM (first year) = be honest, usually <1% of SAM

### 3. MVP Scope Definition

**Принцип:** Smallest thing that proves value hypothesis

Use `assets/mvp_canvas.md` template to define:
- Core value proposition (1 sentence)
- Primary user action (1 action)
- Success metric (1 number)
- Time to first value (<5 minutes ideal)

**Anti-pattern:** "But we also need..." → NO. Ship, measure, iterate.

### 4. Monetization Strategy

See `references/monetization-models.md` for quick selection guide.

**Key decisions:**
- Pricing model: subscription / usage-based / transaction / freemium
- Price point: value-based (not cost-plus)
- Payment psychology: annual discounts, tiered pricing, anchor pricing

**Forcing function:** If they won't pay $X for this, the problem isn't urgent enough.

### 5. Unit Economics

Use `scripts/unit_economics.py` for rapid calculation:

```bash
python scripts/unit_economics.py --ltv 1200 --cac 400 --churn-rate 5
```

**Minimum viability:**
- LTV:CAC ratio ≥ 3:1
- CAC payback ≤ 12 months
- Monthly churn ≤ 5% (for SaaS)

If numbers don't work at scale, pivot or kill the idea.

### 6. Build & Launch Strategy

**Week 1-2:** Core feature + payment
**Week 3:** First 10 paying customers (manual sales, no automation yet)
**Week 4:** Measure, learn, decide: iterate / pivot / kill

**Tech principles:**
- No-code/low-code first (n8n, Airtable, Webflow)
- Manual processes behind automated facade
- Don't build what you can integrate
- PostgreSQL + Python API = enough for 100k users

### 7. Metrics Framework

See `references/metrics-framework.md` for stage-specific KPIs.

**MVP stage - track only:**
- Activation rate (signup → first value)
- Retention (D1, D7, D30)
- Revenue per user
- NPS or qualitative feedback

Ignore: total users, page views, social followers (vanity metrics)

### 8. Go-to-Market

**Before product-market fit:**
- Do things that don't scale (Paul Graham)
- Talk to users every day
- Manual sales → learn messaging
- Early adopters ≠ mainstream market

**Channel testing sequence:**
1. Direct outreach (LinkedIn, email, communities)
2. Content/SEO (if long sales cycle)
3. Paid ads (only after LTV:CAC proven)
4. Partnerships/integrations

## Decision Points

### When to iterate:
- Users sign up but don't activate → onboarding problem
- Users try once then churn → not enough value
- Good engagement, won't pay → wrong audience or positioning

### When to pivot:
- No organic growth after 3 months of trying
- LTV:CAC fundamentally broken
- Users love it, but market too small

### When to kill:
- No one cares (not even early adopters)
- You've stopped believing in it
- Better opportunity identified

## Reference Materials

Load as needed:
- **Monetization models**: See `references/monetization-models.md`
- **Metrics frameworks**: See `references/metrics-framework.md`
- **YC startup playbook**: See `references/yc-playbook.md`

## Templates

- **MVP Canvas**: `assets/mvp_canvas.md` - One-page planning template
- **Unit economics sheet**: Generate via scripts
- **Weekly progress template**: In assets/

## Anti-Patterns to Avoid

- Building for 6 months before talking to users
- Perfecting features instead of testing core hypothesis
- Raising money before product-market fit
- Hiring before proving the model works
- Optimizing conversion before understanding why users stay
- "If we build it, they will come"
