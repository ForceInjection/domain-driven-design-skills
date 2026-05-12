---
name: ddd-aggregates
description: "Design aggregate boundaries from invariants: aggregate roots, entities, value objects, transaction boundaries, and cross-aggregate consistency strategies."
lang: en
risk: safe
source: self
tags: "[ddd, tactical, aggregates, invariants]"
date_added: "2026-05-08"
---

# DDD Aggregates

> 🌐 中文版本: [Chinese](SKILL.md)

## When to Use

- Bounded Contexts and integration strategies are ready, and you need to design the building blocks within each context.
- You need to answer "which objects must change together to maintain consistency."
- When `ddd-model-review` reports "invariant expression rate < 60%," or `ddd-domain-interactions` reports "events need to carry another aggregate's private data," re-execute this skill as a backtrack target.

## Input Requirements

- **Required**: Event flows and command candidates (from `ddd-discover`), context directory and glossary (from `ddd-contexts`).
- **Optional**: Context mapping and failure modes (from `ddd-context-map`).

## Process

1. **Extract invariants**: From commands and events, extract business rules that "must always hold true" (invariants).
2. **Cluster objects**: Using invariants as the binding force, cluster objects into aggregate candidates; identify the aggregate root (the sole external entry point).
3. **Identify building blocks**: Distinguish entities (with identity and lifecycle) from value objects (no identity, immutable, compared by value) within aggregates.
4. **Define boundary rules**: External consumers hold only aggregate root references; cross-aggregate references use IDs; each aggregate is a transaction boundary.
   - **Foreign reference re-examination**: For every "foreign reference object" in the model, re-ask — do we need to manage its lifecycle (create, modify, terminate)? If yes, it should be promoted to an **internal aggregate** rather than remaining a mere ID reference. Typical trigger: reference data objects (port catalogs, calendars, route catalogs) maintained by our team must be listed as aggregates.
   - **Specification pattern recognition**: When a business rule appears in the predicate form "given X, does X satisfy Y" (e.g., `isSatisfiedBy(Itinerary)`), explicitly extract it as a Specification rather than burying it in if-branches inside factories or services.
5. **Command boundaries**: For each aggregate, define the commands it handles, pre-validations, and side effects.
6. **Cross-aggregate consistency**: Strong consistency within an aggregate; eventual consistency across aggregates — define event-driven / compensation / retry strategies.
7. **Repository interface draft**: For each aggregate, produce a repository interface with semantic definitions (method name + semantics, no code implementation).

## Output

| Artifact                             | Structure Requirements                                                                                           |
| :----------------------------------- | :--------------------------------------------------------------------------------------------------------------- |
| Aggregate Directory                  | Table: aggregate name, aggregate root, contained entities, contained value objects, key invariants, key commands |
| Invariant Table                      | Table: invariant, triggering command, validation location, behavior on violation                                 |
| Entity & Value Object List           | Table: name, type (Entity/VO), owning aggregate, identity strategy / equality definition                         |
| Transaction Boundary Description     | List: default rules, exception conditions, concurrency/locking strategy                                          |
| Cross-Aggregate Consistency Strategy | Table: scenario, triggering event, compensation method, idempotency guarantee, retry strategy                    |
| Repository Interface Draft           | Table: aggregate, method, semantic description, query boundary                                                   |

## Validation Checklist

- [ ] Each aggregate corresponds to at least 1 explicit invariant
- [ ] Aggregate boundaries specify transaction boundaries; default is "one transaction modifies one aggregate"
- [ ] Cross-aggregate consistency has event and compensation strategies
- [ ] No "aggregates defined by foreign keys" anti-pattern (aggregates are not ORM relationship mappings)
- [ ] Entity vs. value object distinction has clear rationale (identity vs. value semantics)
- [ ] Aggregate size is reasonable: a single aggregate should not contain > 5 entities (justification required if exceeded)
- [ ] Every foreign reference has been re-examined for "is its lifecycle managed by us"; those answered yes have been promoted to internal aggregates
- [ ] "Predicate-style business rules" have been scanned and evaluated for the Specification pattern; qualifying ones are listed as first-class building blocks

## Backtrack Triggers

- Invariants span multiple contexts -> backtrack to `ddd-contexts` (consistency requirements are fragmented by boundaries).
- Triggered by `ddd-domain-interactions`: events need to carry another aggregate's private data, indicating aggregate boundaries need adjustment.
- Triggered by `ddd-model-review`: invariant expression rate < 60% (aggregates may be data containers rather than behavioral boundaries).

## Example

```text
@ddd-aggregates
Based on the following context definition and event flows, help me design aggregates within the Booking context:
- Context: Booking (full booking lifecycle)
- Core terms: Booking, TimeSlot, BookingPolicy, CheckIn
- Key events: BookingRequested, BookingConfirmed, BookingCancelled, CheckInRecorded
Please output aggregate directory, invariant table, entity/value object list, and transaction boundary description.
```
