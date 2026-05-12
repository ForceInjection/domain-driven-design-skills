---
name: ddd-subdomains
description: "Identify business capabilities and classify subdomains (Core/Supporting/Generic), producing core domain declarations and ownership recommendations."
lang: en
risk: safe
source: self
tags: "[ddd, strategic, subdomains]"
date_added: "2026-05-08"
---

# DDD Subdomains

> 🌐 中文版本: [Chinese](SKILL.md)

## When to Use

- Domain discovery is complete (event flows and command/event candidates are ready), and the domain needs to be divided into subdomains.
- A strategic decision is needed on "what is our core competitive advantage and what can be purchased/reused."
- When `ddd-context-map` reports a "god context" or subdomain misclassification, re-execute this skill as a backtrack target.

## Input Requirements

- **Required**: Event flows, command/event candidates, and boundary clues (from `ddd-discover`).
- **Optional**: Current system capability or module inventory, business differentiation hypotheses, competitive advantage description (from `ddd-scope`).

## Process

1. **Extract capability set**: Extract business capabilities from the event flow, deduplicating and merging synonymous capabilities.
2. **Attribute annotation**: For each capability, annotate business value, complexity, change frequency, and external dependency level.
3. **Classification**: Classify by DDD subdomain type — Core (differentiating competitive advantage), Supporting (necessary but non-differentiating), Generic (general-purpose, reusable).
4. **Core domain declaration**: Produce a core domain declaration document — why it is core, measurement indicators, long-term evolution direction.
5. **Ownership recommendation**: Suggest team ownership, aligning language boundaries with consistency boundaries; annotate cross-team collaboration points.
6. **Output boundary candidates**: Provide preliminary subdomain-to-context mapping suggestions for `ddd-contexts`.

## Output

| Artifact                 | Structure Requirements                                                                                        |
| :----------------------- | :------------------------------------------------------------------------------------------------------------ |
| Capability List          | Table: capability, description, related events, upstream/downstream dependencies                              |
| Subdomain Classification | Table: capability/capability group, subdomain type (Core/Supporting/Generic), rationale, suggested investment |
| Core Domain Declaration  | Within 1 page: value, boundary, measurement indicators, risks, evolution direction                            |
| Ownership Recommendation | Table: capability/subdomain, suggested team, dependents, collaboration approach                               |
| Boundary Candidates      | List: preliminary subdomain-to-context mapping suggestions                                                    |

## Validation Checklist

- [ ] Each capability has a classification rationale acceptable to both business and technical stakeholders
- [ ] Core domain declaration includes measurable business indicators
- [ ] At least 3 cross-team collaboration points identified with collaboration suggestions
- [ ] Core subdomain count <= 1/3 of total subdomains (core domains should not be excessive)
- [ ] Boundary candidates can be directly consumed by `ddd-contexts`

## Backtrack Triggers

- Cannot distinguish Core from Supporting (all capabilities appear equally important) -> backtrack to `ddd-scope`; the business value proposition needs re-clarification.
- Triggered by `ddd-context-map`: circular dependencies or a "god context" suggest subdomain classification errors.

## Example

```text
@ddd-subdomains
Based on the following event flows and boundary clues, help me identify and classify subdomains:
[paste event flow table and boundary clues from ddd-discover]
Please output capability list, subdomain classification table, core domain declaration, and ownership recommendations.
```
