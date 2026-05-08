---
name: automation-strategy
description: Plan test automation strategies including ROI analysis, automation candidate selection, framework evaluation, and maintainable automation architecture.
allowed-tools: Read, Write, Glob, Grep, Task, WebSearch, WebFetch
---

# Test Automation Strategy

## When to Use This Skill

Use this skill when:

- **Automation Strategy tasks** - Planning test automation strategies
- **Planning or design** - Need guidance on ROI analysis, candidate selection, framework evaluation
- **Best practices** - Want to follow established patterns and standards

## Overview

A well-planned test automation strategy maximizes ROI by automating the right tests at the right level. Poor automation choices lead to maintenance burden, flaky tests, and wasted effort.

---

## Automation Quadrant

```text
                    High Business Value
                           │
        ┌──────────────────┼──────────────────┐
        │   AUTOMATE       │   AUTOMATE       │
        │   FIRST          │   (careful ROI)  │
        │   (High ROI)     │                  │
  Low   ├──────────────────┼──────────────────┤  High
Effort  │   AUTOMATE       │   CONSIDER       │  Effort
        │   (Low effort)   │   MANUAL         │
        │                  │   (Low ROI)      │
        └──────────────────┼──────────────────┘
                    Low Business Value
```

---

## Selection Criteria Matrix

| Criterion | Weight | Score (1-5) |
|-----------|--------|-------------|
| Execution Frequency | 25% | 5 = Daily, 1 = Quarterly |
| Business Criticality | 25% | 5 = Revenue-critical, 1 = Rarely used |
| Stability (low change) | 20% | 5 = Never changes, 1 = Weekly |
| Complexity to Automate | 15% | 5 = Trivial, 1 = Very complex |
| Data Availability | 15% | 5 = Static, 1 = Unavailable |

**Decision:** Score ≥ 4.0: Prioritize | 3.0-3.9: Defer | < 3.0: Keep manual

---

## Good vs Poor Automation Candidates

| Good Candidates | Poor Candidates |
|-----------------|-----------------|
| Smoke/sanity tests | Exploratory testing |
| Regression tests | Usability testing |
| Data-driven tests | One-time tests |
| API contract tests | Rapidly changing features |
| Performance baselines | Visual design validation |
| Security scans | Edge cases rarely executed |

---

## ROI Quick Estimation

| Factor | Multiply Manual Time By |
|--------|------------------------|
| Simple UI automation | 3-5x |
| Complex UI automation | 8-15x |
| API automation | 1-2x |
| Database automation | 2-3x |
| Performance tests | 5-10x |

**Example:** 30 min manual × 1.5 = 45 min API automation. 52 weekly runs = 26 hrs saved. ROI = 3,367%

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Sleep/Wait hardcoding | Flaky, slow | Use explicit waits |
| XPath over data-testid | Brittle | Use stable selectors |
| Test interdependence | Order-dependent failures | Isolated test setup |
| Shared mutable state | Race conditions | Fresh state per test |
| Too many E2E tests | Slow pipeline | Push to lower pyramid |

---

## Maintenance Metrics

| Metric | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| Pass rate | > 98% | 95-98% | < 95% |
| Flaky test rate | < 2% | 2-5% | > 5% |
| Avg execution time | < 10 min | 10-30 min | > 30 min |
| Maintenance hours/week | < 4 hrs | 4-8 hrs | > 8 hrs |

---

## References

| Reference | Content | When to Load |
| --- | --- | --- |
| [automation-strategy-template.md](references/automation-strategy-template.md) | Full strategy template, framework selection, roadmap | Creating automation strategy |
| [automation-patterns.md](references/automation-patterns.md) | Page Object Model, Fluent Builder, Test Fixture | Implementing .NET Playwright tests |

---

## Integration Points

**Inputs from**:

- `test-strategy-planning` skill → Overall strategy
- `test-pyramid-design` skill → Pyramid ratios
- Requirements → Coverage targets

**Outputs to**:

- CI/CD pipeline → Automation integration
- Team training → Framework usage
- `test-case-design` skill → Automatable test designs

---

## Test Scenarios

### Scenario 1: Planning automation strategy

**Query:** "Help me plan a test automation strategy for our e-commerce platform"

**Expected:** Skill activates, provides strategy template, guides through assessment

### Scenario 2: Evaluating automation candidates

**Query:** "Should I automate this checkout flow test?"

**Expected:** Skill activates, provides selection criteria matrix, helps calculate ROI

### Scenario 3: Implementing patterns

**Query:** "Show me the Page Object Model pattern in Playwright"

**Expected:** Skill activates, loads automation-patterns.md reference, provides code examples

---

**Last Updated:** 2025-12-28

## Version History

- **v1.1.0** (2025-12-28): Refactored to progressive disclosure - extracted template/patterns to references/
- **v1.0.0** (2025-12-26): Initial release
