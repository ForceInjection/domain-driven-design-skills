---
name: ddd-context-map
description: "Map inter-context relationships and integration strategies: pattern selection, contract ownership, failure modes, and versioning strategy."
lang: en
risk: safe
source: self
tags: "[ddd, strategic, context-map, integration]"
date_added: "2026-05-08"
---

# DDD Context Map

> 🌐 中文版本: [Chinese](SKILL.md)

## When to Use

- Bounded Contexts have been defined, and you need to design their collaboration and integration relationships.
- You need to clarify "who depends on whom, what integration pattern to use, and who owns the contract."
- When `ddd-model-review` reports "integration patterns inconsistent with context mapping," re-execute this skill as a backtrack target.

## Input Requirements

- **Required**: Context directory (from `ddd-contexts`), cross-boundary points from event flow hotspot annotations (from `ddd-discover`).
- **Optional**: Subdomain classification table (from `ddd-subdomains`, for understanding the business weight of contexts), existing interface/messaging/data exchange methods, team collaboration patterns.

## Process

1. **Enumerate relationships**: List all context pairs, annotating dependency direction and data/event flow direction.
2. **Select patterns**: For each relationship pair, select an integration pattern — ACL (Anti-Corruption Layer), OHS (Open Host Service), PL (Published Language), Shared Kernel, Conformist, Customer-Supplier — and explain the rationale.
3. **Define translations**: Specify input translation, output translation, semantic difference handling, and field mapping rules.
4. **Contract ownership**: Clarify the owner, consumers, change process, and release strategy for each contract.
5. **Failure mode analysis**: For each integration point, analyze failure modes such as timeouts, degradation, idempotency, retries, compensation, and data latency.
6. **Versioning strategy**: Define compatibility windows, deprecation policies, contract testing requirements, and release cadence.

## Output

| Artifact                    | Structure Requirements                                                                              |
| :-------------------------- | :-------------------------------------------------------------------------------------------------- |
| Context Relationship Matrix | Table: upstream, downstream, pattern, data/events, risk                                             |
| Contract Ownership Matrix   | Table: contract, owner, consumers, change process, release strategy                                 |
| Translation & ACL Decisions | Table: object/event, translation rules, semantic difference explanation, implementation location    |
| Failure Modes & Mitigation  | Table: failure mode, impact, detection method, mitigation measures, compensation strategy           |
| Versioning Strategy         | List: version naming rules, compatibility window, deprecation policy, contract testing requirements |

## Validation Checklist

- [ ] All cross-context interactions have explicit patterns and ownership
- [ ] Core domain inputs are protected by ACL or equivalent translation boundaries
- [ ] At least 5 failure modes identified with actionable mitigation measures
- [ ] No circular dependencies (if present, must be flagged as a risk with a decoupling plan)
- [ ] Versioning strategy covers backward compatibility windows and deprecation processes

## Backtrack Triggers

- Circular dependencies detected, or a single context bears > 3 upstream relationships -> backtrack to `ddd-subdomains` or `ddd-contexts` (possible "god context" or subdomain misclassification).
- Triggered by `ddd-model-review`: the tactical layer discovered new integration needs inconsistent with the current mapping.

## Example

```text
@ddd-context-map
Based on the following context directory, help me design inter-context integration relationships:
- Booking (full booking lifecycle)
- Room Catalog (meeting room resource management)
- Identity (user authentication & authorization)
Please output relationship matrix, integration pattern selection, contract ownership, and failure mode analysis.
```
