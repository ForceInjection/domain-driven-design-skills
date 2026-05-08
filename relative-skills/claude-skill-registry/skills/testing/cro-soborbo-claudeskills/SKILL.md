---
name: cro
description: Conversion Rate Optimization patterns beyond A/B testing. Heatmaps, session recordings, funnel analysis, form analytics, exit intent. Data-driven optimization.
---

# CRO (Conversion Rate Optimization) Skill

## Purpose

Provides patterns for understanding user behavior and optimizing conversion funnels beyond basic A/B testing. Combines quantitative analytics with qualitative user insights to systematically improve conversion rates across the entire customer journey.

## Core Rules

1. **Measure before optimizing** — Understand current behavior first
2. **Qualitative + Quantitative** — Numbers + user feedback
3. **Funnel thinking** — Optimize the whole journey, not just CTAs
4. **Privacy first** — Anonymize data, respect consent
5. **Continuous process** — CRO is ongoing, not one-time
6. **Track user intent** — Tag sessions by user type and behavior
7. **Mobile matters** — Test on real devices, not just desktop
8. **Context over clicks** — Understand why users behave, not just what they do
9. **Form friction kills** — Monitor field-level analytics
10. **Iterate systematically** — Weekly review cycles, documented insights

## CRO Tool Stack

| Purpose | Tools | Priority |
|---------|-------|----------|
| Heatmaps | Hotjar, Microsoft Clarity, PostHog | P0 |
| Session Recording | Hotjar, FullStory, LogRocket | P0 |
| Funnel Analysis | GA4, Mixpanel, Amplitude | P0 |
| Form Analytics | Hotjar, Formisimo, Zuko | P1 |
| Surveys | Hotjar, Typeform, SurveyMonkey | P1 |
| Exit Intent | OptinMonster, Sleeknote | P2 |
| Social Proof | Fomo, Proof, UseProof | P2 |

## Key Metrics

**Traffic & Engagement**
- Sessions, unique visitors, bounce rate
- Scroll depth (25%, 50%, 75%, 100%)
- Time on page, pages per session

**Conversion Funnel**
- Landing page views → Form starts → Completions
- Conversion rate, drop-off points
- Time from entry to conversion

**Form Performance**
- Average completion time
- Field-level drop-offs and error rates
- Correction counts per field

**Qualitative Insights**
- Exit intent show/conversion rates
- Survey response themes
- Session recording patterns

## References

**Implementation Guides**
- [Heatmaps & Session Recording](./references/heatmaps.md) — Clarity & Hotjar setup
- [Funnel Tracking](./references/funnels.md) — End-to-end funnel analytics
- [Form Analytics](./references/form-analytics.md) — Field-level tracking
- [Exit Intent](./references/exit-intent.md) — Exit intent modal component
- [Scroll & Visibility Tracking](./references/tracking.md) — Engagement tracking
- [User Surveys](./references/surveys.md) — Feedback collection
- [CRO Metrics](./references/metrics.md) — Dashboard metrics interface

## Workflow

1. **Install tracking** — Set up heatmap tool (Clarity recommended for free)
2. **Define funnels** — Map critical conversion paths
3. **Collect baseline** — 1-2 weeks of data before changes
4. **Identify friction** — Watch recordings, review heatmaps
5. **Survey users** — Ask about hesitations/objections
6. **Prioritize fixes** — Impact vs effort matrix
7. **Implement changes** — One variable at a time
8. **Measure impact** — Compare before/after metrics
9. **Document learnings** — Build insight repository
10. **Repeat weekly** — Continuous optimization cycle

## Forbidden

- Recording without consent notice
- Capturing sensitive form fields (passwords, CC)
- Aggressive exit popups
- Tracking PII in analytics
- Making changes without data
- Ignoring mobile users
- Testing multiple changes simultaneously
- Skipping baseline measurement

## Definition of Done

- [ ] Heatmap tool installed (Clarity/Hotjar)
- [ ] Session recording enabled with consent
- [ ] Funnel tracking for main conversion path
- [ ] Form analytics on key forms
- [ ] Scroll depth tracking implemented
- [ ] Exit intent (if appropriate for audience)
- [ ] Key element visibility tracked
- [ ] Weekly CRO review process established
- [ ] Baseline metrics documented
- [ ] Privacy policy updated for tracking
- [ ] Team trained on tool access
- [ ] Insights repository created
