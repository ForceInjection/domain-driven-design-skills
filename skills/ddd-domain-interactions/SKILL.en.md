---
name: ddd-domain-interactions
description: "Design collaboration mechanisms between building blocks: domain events, domain services, repository interfaces, and factories."
lang: en
risk: safe
source: self
tags: "[ddd, tactical, events, services, repositories]"
date_added: "2026-05-08"
---

# DDD Domain Interactions

> 🌐 中文版本: [Chinese](SKILL.md)

## When to Use

- Aggregate boundaries have been designed, and you need to define collaboration mechanisms between aggregates and between aggregates and the outside world.
- You need to answer "how do aggregates communicate, who orchestrates cross-aggregate flows, and what are the persistence contracts."
- As the final step of tactical modeling, this skill completes all "connective tissue."

## Input Requirements

- **Required**: Aggregate directory and invariant table (from `ddd-aggregates`), event candidate list (from `ddd-discover`).
- **Optional**: Context mapping and contract information (from `ddd-context-map`), context directory and glossary (from `ddd-contexts`, for distinguishing domain events from integration events at the boundary).

## Process

1. **Event normalization**: Unify event naming conventions (past tense, business-readable, no technical jargon); for each event, define trigger conditions, source aggregate, key fields, and ordering requirements.
2. **Scope differentiation**: Distinguish domain events (intra-context) from integration events (cross-context / externally published).
3. **Reliability strategy**: For each event, define idempotency keys, replay strategies, deduplication windows, and dead-letter handling.
4. **Domain services**: Identify operations that don't belong to any single aggregate but carry domain logic; define them as domain services — specifying inputs, outputs, and the aggregates and events they use.
5. **Repository interfaces**: For each aggregate, define the repository's semantic interface (load, persist, query) — contracts only, no implementation.
6. **Factories**: Identify complex aggregate creation logic and define factory methods — specifying creation conditions, validation rules, and initial state.
7. **Subscribers & side effects**: For each event, clarify consumers, triggered actions, compensation strategies, and monitoring metrics.

## Output

| Artifact                      | Structure Requirements                                                                                               |
| :---------------------------- | :------------------------------------------------------------------------------------------------------------------- |
| Domain Event Directory        | Table: event name, source aggregate, trigger condition, key fields, scope (Domain/Integration)                       |
| Integration Event Contracts   | Table: event name, publisher, consumers, contract owner, versioning strategy, compatibility window                   |
| Idempotency & Replay Strategy | Table: event, idempotency key, deduplication window, replay rules, exception handling                                |
| Domain Service Definitions    | Table: service name, responsibility, inputs, outputs, dependent aggregates/events, logic that should NOT be included |
| Repository Interface List     | Table: aggregate, method signature (semantic), semantic description, query boundary                                  |
| Factory List                  | Table: factory name/method, creation target, creation conditions, validation rules, initial state                    |
| Subscribers & Side Effects    | Table: event, subscriber, triggered action, compensation strategy, monitoring metrics                                |

## Validation Checklist

- [ ] All events are named in past tense with no technical jargon pollution
- [ ] Cross-context published events have versioning strategies and compatibility windows
- [ ] Critical events provide idempotency keys and replay strategies
- [ ] Domain services do not contain business logic that should belong to aggregates (avoiding anemic models)
- [ ] Repository interfaces define only semantic contracts with no implementation details (SQL, ORM)
- [ ] Every complex creation logic has a corresponding factory (no bare `new` in the application layer)

## Backtrack Triggers

- Events need to carry another aggregate's private data (cannot design a clean event schema) -> backtrack to `ddd-aggregates` (aggregate boundaries need adjustment to ensure events are self-contained).

## Example

```text
@ddd-domain-interactions
Based on the following aggregate design, help me design the domain interaction layer:
- Aggregate: Booking (root: Booking, VOs: TimeSlot, BookingStatus)
- Aggregate: RoomSchedule (root: RoomSchedule, VOs: TimeSlotOccupancy)
- Event candidates: BookingConfirmed, BookingCancelled, CheckInRecorded
Please output domain event directory, domain services, repository interfaces, and subscriber list.
```
