---
name: ddd-model-review
description: "Holistic model quality assessment: consistency, completeness, coupling analysis, and feedback loop triggers."
lang: en
risk: safe
source: self
tags: "[ddd, validation, review, feedback-loop]"
date_added: "2026-05-08"
---

# DDD Model Review

> 🌐 中文版本: [Chinese](SKILL.md)

## When to Use

- Tactical modeling is complete, and you need a quality gate check on the overall model.
- Existing modeling artifacts require comprehensive assessment (can be used as a standalone entry point).
- Periodic model health checks: the team wants to quantify model quality and identify degradation trends.

## Input Requirements

- **Required**: At least 3 of the following artifacts:
  - Context directory and glossary (from `ddd-contexts`)
  - Context relationship matrix (from `ddd-context-map`)
  - Aggregate directory and invariant table (from `ddd-aggregates`)
  - Domain event directory and service definitions (from `ddd-domain-interactions`)
- **Optional**: Subdomain classification (from `ddd-subdomains`), event flows (from `ddd-discover`), scope definition (from `ddd-scope`).

## Process

1. **Terminology consistency check**: Scan terminology usage across all artifacts; detect cross-artifact naming conflicts, definition drift, and same-name-different-meaning issues.
   - **Industry benchmarking (optional but recommended)**: If the business domain has mature open-source reference implementations (e.g., Cargo for logistics, Broadleaf for e-commerce, Pyramid for B2B), use them as a comparison reference. List item by item: **semantic merge/split deviations** from the reference; **proactive identification of known limitations** in the reference (e.g., Activity/Status/Event overlap); **unmodeled but consideration-worthy future domains** (e.g., Billing/Customer/Carrier).
2. **Boundary consistency check**: Verify that aggregate boundaries align with context boundaries — invariants should not span contexts.
3. **Completeness check**: Cross-check that every event in the event flow has a formal definition in the event directory; every command has a corresponding aggregate handler.
4. **Coupling analysis**: Evaluate inter-context coupling — dependency direction, shared data volume, synchronous call count.
5. **Scoring**: Score the following dimensions 0-10: terminology consistency, boundary reasonableness, invariant expression rate, event completeness, coupling level; if industry benchmarking is enabled, add a "benchmark deviation" dimension.
6. **Issue list & backtrack triggers**: Output discovered issues with impact, evidence, suggested fixes, and generate backtrack instructions based on trigger conditions.

## Output

| Artifact                  | Structure Requirements                                                                                                                                                   |
| :------------------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Score Summary             | Table: dimension (terminology consistency, boundary reasonableness, invariant expression rate, event completeness, coupling level), score (0-10), main deduction reasons |
| Issue List                | Table: issue, impact, evidence (referencing specific artifacts), suggested fix, priority                                                                                 |
| Industry Benchmark Report | (Only when enabled) Table: comparison item, reference implementation approach, our model approach, merge/split/omission, acceptability, recommendation                   |
| Backtrack Trigger List    | Table: trigger condition, backtrack target skill, explanation                                                                                                            |
| Implementation Readiness  | Conclusion: Ready / Not Ready + blocker list                                                                                                                             |

## Validation Checklist

- [ ] Every deduction item provides reviewable evidence (referencing specific artifacts and entries)
- [ ] Backtrack trigger conditions are clear and actionable
- [ ] Scoring is repeatable (same inputs yield same scores)
- [ ] Implementation readiness has clear pass/fail criteria
- [ ] If the business domain has a recognized open-source reference implementation, at least one round of benchmarking has been conducted; benchmark conclusions have been consolidated into the issue list

## Backtrack Triggers

This skill is the core trigger for the feedback loop. Based on assessment results, it triggers the following backtracks:

| Trigger Condition                                  | Backtrack To              | Explanation                                                           |
| :------------------------------------------------- | :------------------------ | :-------------------------------------------------------------------- |
| Aggregate boundaries contradict context boundaries | `ddd-contexts`            | Contexts need re-partitioning to accommodate consistency requirements |
| Terminology conflict rate > 20%                    | `ddd-contexts`            | Ubiquitous Language definitions are insufficient                      |
| Invariant expression rate < 60%                    | `ddd-aggregates`          | Aggregates may be data containers rather than behavioral boundaries   |
| Integration patterns inconsistent with context map | `ddd-context-map`         | Tactical layer discovered new integration needs                       |
| Event completeness < 70%                           | `ddd-domain-interactions` | Event directory is incomplete or misses critical flows                |

**Infinite loop prevention**: The same backtrack path may be executed at most 3 times. If triggered a 3rd time, it is flagged as "architectural decision requiring human intervention."

## Example

```text
@ddd-model-review
Please perform a holistic quality assessment on the following modeling artifacts:
- Context directory: [paste]
- Aggregate directory: [paste]
- Domain event directory: [paste]
- Context relationship matrix: [paste]
Please output per-dimension scores, issue list, and backtrack recommendations.
```
