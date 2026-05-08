---
name: instrumentation-planning
description: Plan what to measure in mobile apps. Use when starting observability, prioritizing instrumentation, or asking "what should I track?"
triggers:
  - "planning telemetry"
  - "prioritize instrumentation"
  - "start observability"
  - "what should I track"
  - "what to measure"
  - "where to begin"
priority: 1
---

# Instrumentation Planning

Strategic guidance for what to measure using Jobs-to-be-Done framework.

## Core Question

For each user job, ask:
- **Did it complete?** → completion rate
- **How long?** → duration (p50, p95, p99)
- **What failed?** → error type, context
- **Did they give up?** → drop-off rate

## Priority Tiers

| Tier | Focus | Examples |
|------|-------|----------|
| 1 | Crashes & errors | Crash reporting, error boundaries |
| 2 | User context | User ID, session ID, device info |
| 3 | Performance | App start, screen load, network |
| 4 | Breadcrumbs | Navigation, user actions |
| 5 | Business metrics | Funnels, feature usage |

## Implementation Order

```
Day 1:  Crash reporting + User context
Week 1: Breadcrumbs + Release tracking
Week 2: Performance spans
Month 1: Business metrics
```

## Future-Proofing

Use OTel-compatible span/attribute names now (zero cost, easier migration later):
- `http.request.method` not `method`
- `ui.screen.load` not `screenLoad`
- `app.start.cold` not `coldStart`

See `references/otel-mobile.md` for full naming conventions.

## Anti-Patterns

- Measure everything (noise, battery drain)
- Skip symbolication (unreadable crashes)
- Block main thread for telemetry
- Log PII in breadcrumbs

## Implementation

See `references/instrumentation-patterns.md` for:
- Detailed 5-tier checklist
- Span naming conventions
- Sampling strategies
- Testing checklist

See `references/jtbd.md` for full Jobs-to-be-Done framework.

## Related Skills

- See `skills/user-journey-tracking` for implementing JTBD instrumentation
- See `skills/crash-instrumentation` for Tier 1 (crashes)
- See `skills/symbolication-setup` for Tier 1 (readable stack traces)
