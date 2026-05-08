---
name: ab-testing
description: A/B testing patterns for lead generation sites. Client-side experiments, Google Optimize alternative, analytics integration. Use for conversion optimization.
---

# A/B Testing Skill

## Purpose

Enables experimentation on lead generation sites to optimize conversion rates through simple, privacy-friendly client-side testing with statistical rigor.

## Core Rules

1. **One test at a time** — Per page, avoid interaction effects
2. **Statistical significance** — Don't call winners too early (p < 0.05)
3. **Track conversions** — Not just clicks or exposures
4. **Minimize flicker** — Apply variants before paint using visibility hidden
5. **Respect privacy** — No PII in experiments, localStorage only
6. **Minimum duration** — Never less than 1 week (day-of-week effects)
7. **Sample size first** — Calculate required n before starting
8. **Persist assignments** — User sees same variant across sessions
9. **Track exposures** — Log every variant view to GA4
10. **Conversion-focused** — Optimize for business metrics, not vanity metrics

## Test Duration Guidelines

| Traffic/Day | Min Duration | Sample Size |
|-------------|--------------|-------------|
| 100 | 8+ weeks | ~400 per variant |
| 500 | 2 weeks | ~400 per variant |
| 1000+ | 1 week | ~400 per variant |

**Never call a test in less than 1 week** — Day-of-week effects matter.

## Common Tests for Lead Gen

| Test | Variants |
|------|----------|
| CTA Text | "Get Quote" vs "Get Free Quote" vs "Start Now" |
| CTA Color | Primary vs Accent vs Contrasting |
| Form Length | 3 fields vs 5 fields |
| Social Proof | With reviews vs Without |
| Urgency | None vs "Limited slots" |
| Hero Image | Photo A vs Photo B |
| Headline | Benefit-focused vs Problem-focused |

## GA4 Custom Dimensions

Set up in GA4 for tracking:

| Dimension | Scope | Description |
|-----------|-------|-------------|
| `ab_test_id` | Event | Test identifier |
| `ab_variant` | Event | Variant name |

## References

Detailed implementation guides and code examples:

- **[Variant System](./references/variant-system.md)** — ABTest and ABVariant components, usage examples
- **[GA4 Integration](./references/ga4-integration.md)** — Conversion tracking, GTM configuration, custom dimensions
- **[Statistics](./references/statistics.md)** — Sample size calculator, results analysis, significance testing

## Forbidden

- ❌ Calling winners without significance (p < 0.05)
- ❌ Running less than 1 week
- ❌ Multiple tests on same element
- ❌ Changing tests mid-run
- ❌ Not tracking actual conversions
- ❌ Flicker (variant change visible to user)
- ❌ Storing PII in localStorage or events
- ❌ Skipping sample size calculation

## Definition of Done

- [ ] A/B test component implemented (ABTest.astro)
- [ ] Variant content component implemented (ABVariant.astro)
- [ ] Variant assignment persisted in localStorage
- [ ] Exposures tracked in GA4 (ab_test_exposure event)
- [ ] Conversions tracked in GA4 (ab_test_conversion event)
- [ ] No visible flicker (visibility: hidden until variant applied)
- [ ] Sample size calculated based on baseline conversion rate
- [ ] Test runs minimum 1 week before analysis
- [ ] GA4 custom dimensions configured (ab_test_id, ab_variant)
- [ ] Statistical significance verified (p < 0.05) before declaring winner
