---
name: WiseWhisper
description: Real-time interview assistant SaaS product context. USE WHEN wisewhisper, interview assistant, product metrics, feature planning, activation gap, onboarding, conversion rate, stripe metrics.
---

# WiseWhisper

Real-time interview assistant SaaS - your first production product (launched June 2025). Currently focused on reaching first 100 paying customers (G1 from TELOS).

## Quick Facts

- **Launch Date:** June 1, 2025
- **Current Status:** Product-Market Fit confirmed (7.4% conversion rate)
- **Current MRR:** €229.33 (104.6% growth rate)
- **Paying Customers:** 27 / 100 goal
- **Main Challenge:** Activation gap (onboarding UX friction)

## Context Files

| File | Purpose |
|------|---------|
| `ProductOverview.md` | Product details, target users, value proposition |
| `TechStack.md` | Desktop app (Python), backend (Python), landing page (Python with Tailwind css) |
| `Metrics.md` | Stripe MRR, conversion rates, growth data |
| `Repos.md` | Repository locations and specialist agents |

## Workflows

| Workflow | Trigger | File |
|----------|---------|------|
| **AnalyzeMetrics** | "check metrics", "how's wisewhisper doing", "growth analysis" | `Workflows/AnalyzeMetrics.md` |
| **PlanFeature** | "add feature", "improve wisewhisper", "feature planning" | `Workflows/PlanFeature.md` |
| **FixActivation** | "improve onboarding", "reduce friction", "activation gap" | `Workflows/FixActivation.md` |
| **CreateContent** | "post about wisewhisper", "build in public update" | `Workflows/CreateContent.md` |

## Examples

**Example 1: Growth analysis**
```
User: "How's WiseWhisper doing this month?"
→ Invokes AnalyzeMetrics workflow
→ Reads Metrics.md for current data
→ Provides growth analysis and recommendations
```

**Example 2: Feature planning**
```
User: "Users want Slack integration in WiseWhisper"
→ Invokes PlanFeature workflow
→ Reads TechStack.md and Repos.md
→ Creates implementation plan for specialist agents
```

**Example 3: Onboarding improvement**
```
User: "How do we fix the activation gap?"
→ Invokes FixActivation workflow
→ Analyzes friction points
→ Proposes UX improvements
```
