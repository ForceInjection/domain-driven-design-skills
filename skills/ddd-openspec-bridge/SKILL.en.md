---
name: ddd-openspec-bridge
description: "Map DDD tactical modeling artifacts to OpenSpec structured specifications, enabling smooth transition from domain modeling to engineering implementation."
lang: en
risk: safe
source: self
tags: "[ddd, implementation, openspec, sdd]"
date_added: "2026-05-11"
---

# DDD OpenSpec Bridge

> 🌐 中文版本: [Chinese](SKILL.md)

## When to Use

- Tactical modeling (Stage III) is complete, the model has passed validation (Stage IV), and you are ready to enter the development phase.
- You need to convert the domain model into structured engineering specifications executable by AI Agents or developers.
- You need to establish a "Single Source of Truth" between the business model and code implementation.

## Input Requirements

- **Required**:
  - Problem space definition (from `ddd-scope`)
  - Subdomain classification and core domain declaration (from `ddd-subdomains`)
  - Context directory and ADRs (from `ddd-contexts`)
  - Context mapping and integration patterns (from `ddd-context-map`)
  - Aggregate directory and invariants (from `ddd-aggregates`)
  - Domain interaction definitions: domain events, domain services, repository interfaces, factories (from `ddd-domain-interactions`)
- **Optional**:
  - Discovery-phase event flows and boundary clues (from `ddd-discover`)
  - Model validation report (from `ddd-model-review`)
- **Execution standard**: Mapping logic must follow the standard definitions in [ddd-openspec-mapping.en.md](../../docs/ddd-openspec-mapping.en.md).

## Process

1. **Initialize OpenSpec changeset**: Create a directory under `openspec/changes/<change-id>/` and generate the `.openspec.yaml` for this changeset. Note: this is different from the global `openspec/config.yaml` — the latter is maintained once during the `ddd-contexts` stage to declare domain-to-Bounded Context mappings and architectural constraints.
2. **Generate Proposal (`proposal.md`)**:
   - Map the problem statement from `ddd-scope` to the Why section.
   - Write the capabilities involved in this changeset into What Changes; organize priorities according to `ddd-subdomains` classification: **Core subdomains** require full scenario coverage, **Generic subdomains** may reference existing specifications or external components.
   - List affected capabilities and aggregate changes in the Impact section; define success criteria (SLO / acceptance metrics) in Goals.
3. **Establish Bounded Context directories**: Following the context directory from `ddd-contexts`, create specification files at `specs/<bounded-context>/<capability>/spec.md` for each capability. **Do NOT use a flat `specs/domain-model/` directory** — it would break the strategic alignment between Bounded Contexts and domain directories.
4. **Write Requirements & Scenarios** (strictly following the mapping direction in [ddd-openspec-mapping.en.md §2.1](../../docs/ddd-openspec-mapping.en.md)):
   - **Requirement** <- commands and domain services from `ddd-domain-interactions`; one Requirement corresponds to **one independently verifiable business capability**, with scenario count <= 5 and not spanning aggregate roots.
   - **Scenario** <- aggregate behaviors and invariants from `ddd-aggregates`, described in Given/When/Then format; P0-level invariants must have corresponding Scenarios.
   - **Domain events** are written as side effects in Scenario Then/And clauses (e.g., "And publish OrderPlaced event").
   - **Business rules first**: Scenarios describe only business rules and invariants; no database, HTTP, ORM, caching, or other technical details may leak in.
5. **Ubiquitous Language verification**: Cross-check against the glossary from `ddd-contexts` to ensure all terms in `proposal.md` and `spec.md` files are within the glossary; terms not yet recorded must be backfilled into the glossary or replaced with synonyms.
6. **Design technical approach (`design.md`)**: Integrate integration patterns from `ddd-context-map` and collaboration mechanisms from `ddd-domain-interactions`; describe layered architecture mapping, cross-context translation (ACL), event publish/consume paradigms (Outbox pattern, idempotency keys, one-transaction-one-aggregate constraint — see [ddd-openspec-mapping.en.md Appendix A](../../docs/ddd-openspec-mapping.en.md)).
7. **Break down development tasks (`tasks.md`)**: Decompose tasks by spec dependency order (Domain Model -> Repository -> Application Service -> API/Integration); each task references the corresponding Requirement or Scenario as acceptance criteria.

## Output

| Artifact           | Structure Requirements                                                                             |
| :----------------- | :------------------------------------------------------------------------------------------------- |
| `proposal.md`      | Contains Why, What Changes, Impact (Capabilities / aggregate changes), Goals.                      |
| `design.md`        | Contains architecture design, data model mapping, core data flows, interface protocol definitions. |
| `specs/` directory | Subfolders organized by capability, each containing `spec.md` (Requirement + Scenario format).     |
| `tasks.md`         | Contains task title, task description, associated spec path, acceptance criteria.                  |

## Validation Checklist

- [ ] OpenSpec directory structure conforms to specification (config, specs, changes); `specs/` is organized by Bounded Context subdirectories with no flat `domain-model/` directory.
- [ ] **Requirement granularity is adequate**: Each Requirement corresponds to one independently verifiable business capability, with scenario count <= 5 and not spanning aggregate roots.
- [ ] **Scenarios maintain business-rules-first principle**: No database, HTTP, ORM, caching, or other technical details present; all P0 invariants from `ddd-aggregates` have been converted to Scenarios.
- [ ] **Terminology consistency**: All terms in `proposal.md` and `spec.md` files can be found in the `ddd-contexts` glossary; Capabilities in `proposal.md` are consistent with `ddd-contexts`.
- [ ] **Event-driven paradigm is implemented**: Cross-aggregate scenarios in `design.md` explicitly follow the Outbox pattern, idempotency keys, and "one transaction modifies one aggregate" constraint.
- [ ] **Iteration cadence is manageable (small, fast steps)**: This changeset is scoped to complete specification and code merge within a single Apply phase, avoiding micro-waterfall drift.
- [ ] Tasks in `tasks.md` are actionable, and each task has explicit Requirement/Scenario references as acceptance criteria.
- [ ] Typography follows project conventions (spaces between Chinese and English text, proper nouns in backticks).

## Backtrack Triggers

- Discovering ambiguity or conflicts in domain logic while writing Scenarios -> backtrack to `ddd-aggregates` or `ddd-domain-interactions`.
- Unable to clearly express an integration pattern within the OpenSpec structure -> backtrack to `ddd-context-map`.
- Cannot remove technical details from Scenarios (database / HTTP / ORM, etc.) -> violates the business-rules-first principle; rewrite within this skill first; if semantics still cannot be purified, backtrack to `ddd-aggregates` to redefine aggregate behaviors.
- A single Requirement has more than 5 Scenarios or spans multiple aggregate roots -> violates granularity convention; backtrack to `ddd-domain-interactions` to split commands and domain services.
- Terms not recorded in the `ddd-contexts` glossary -> backtrack to `ddd-contexts` to add or unify terminology.

## Example

```text
@ddd-openspec-bridge
Based on the completed "Meeting Room Booking System" modeling outputs, generate the OpenSpec changeset specification:
- Aggregates: Booking, RoomSchedule
- Key flows: booking request, conflict detection, check-in, cancellation
- Contexts: Booking Context, Room Catalog Context
Please output proposal.md, design.md, and the core Requirements & Scenario snippets for specs/booking-context/booking/spec.md.
```

> For a complete Requirement/Scenario writing example, see [ddd-openspec-mapping.en.md §5](../../docs/ddd-openspec-mapping.en.md) (an end-to-end minimum viable example using "User Registration").
