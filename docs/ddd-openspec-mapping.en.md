# DDD to OpenSpec Mapping Guide: From Domain Model to Engineering Specification

> 🌐 中文版本: [Chinese](ddd-openspec-mapping.md)

This guide defines the standard mapping path for transforming Domain-Driven Design (DDD) deliverables into the OpenSpec standardized workflow. By combining DDD's domain insight with OpenSpec's structured execution, it establishes a highly reliable bridge from model to code.

---

## 1. Strategic Alignment: Organizing Specifications by Domain

In large-scale system design, strategic alignment is key to ensuring architectural cleanliness. By introducing DDD's spatial partitioning methodology into OpenSpec's directory structure, design and specification achieve a natural correspondence.

### 1.1 Mapping Bounded Contexts to Domain Directories

DDD's "Bounded Context" is the core tool for delineating functional boundaries; each boundary contains a self-consistent domain model and Ubiquitous Language. In OpenSpec, this corresponds to subdomain directories under `specs/`. This alignment ensures that every business boundary identified by DDD has a clear home in the engineering specification, preventing fragmentation of domain knowledge.

### 1.2 Panoramic View in the Configuration File

By declaring this mapping in `openspec/config.yaml`, a global architectural context is provided to AI Agents, enabling them to understand the business boundary they're operating within when processing specific changes.

```yaml
# openspec/config.yaml example: Domain-Bounded Context mapping
context: |
  ## Project Domain Mapping
  This system follows DDD design. Core Bounded Contexts include:
  - User Context
  - Order Context
  - Payment Context

  ## Tech Stack & Architectural Constraints
  - Architecture style: Hexagonal Architecture
  - Backend: Java Spring Boot + MyBatis
  - Rule: All aggregate changes must be driven by domain events for eventual consistency
```

---

## 2. Tactical Execution: Implementing DDD Tactical Design

Tactical design determines the quality of code implementation. OpenSpec provides a structured expression system that transforms DDD's building blocks into verifiable, executable task sequences, with **Delta mechanism** support for incremental evolution.

### 2.1 Mapping Building Blocks to OpenSpec Structures

We map DDD deliverables to OpenSpec core components, thereby driving AI to perform precise implementations.

| OpenSpec Structure | Corresponding DDD Deliverable    | Description                                                                                       |
| :----------------- | :------------------------------- | :------------------------------------------------------------------------------------------------ |
| **Domain**         | **Bounded Context**              | One domain directory corresponds to one Bounded Context.                                          |
| **Requirement**    | **Domain Service** / **Command** | Describes a core business capability or operation.                                                |
| **Scenario**       | **Aggregate behavior**           | Uses **Given/When/Then (Gherkin)** format to precisely describe aggregate behavior.               |
| **Design**         | **Application Service**          | Coordinates multiple domain services; manages transactions and security.                          |
| **Tasks**          | **Tactical design backlog**      | Converts entities, value objects, repository interfaces, etc. into concrete implementation tasks. |

> **Fool-proofing convention - Requirement granularity**: Each Requirement should focus on **one independently verifiable business capability** (typically corresponding to one command or one domain service responsibility). When a Requirement requires more than 5 Scenarios, or covers multiple aggregate roots, it should be split into multiple Requirements to prevent AI from losing focus during implementation.

### 2.2 Workflow-Driven Lifecycle

OpenSpec's workflow is highly aligned with DDD's iterative modeling, with particular emphasis on **brownfield-first** refactoring capability:

- **Propose -> Domain Modeling**: Use `/opsx:propose` to quickly initialize changes and capture domain modeling conclusions.
- **Apply -> Specification-Driven Development**: Leverage AI to implement code and perform automated verification (Test to Spec) based on specifications (Requirement + Scenario).
- **Archive -> Knowledge Merge**: Use `openspec archive` to merge Delta Specs into the main specification, ensuring a Single Source of Truth for domain knowledge.

> **Avoiding micro-waterfall**: DDD emphasizes continuous iterative evolution, and OpenSpec inherently has a "specify first, implement second" tendency. When combined, they can easily slide into micro-waterfall. The recommendation is **small, fast steps** — within a single changeset, keep specification fragments and code implementation merging early. Don't wait for the domain model to be "perfect" before entering the Apply phase; each Archive round should be seen as a phase-level solidification of the model, not a final answer.

---

## 3. Core Mechanisms: Enhancing AI Collaboration Certainty

OpenSpec is more than documentation. Through a dynamic directive system and validation mechanisms, it significantly improves the certainty of DDD model implementation.

### 3.1 AI Dynamic Directive System (OPSX)

The OPSX workflow introduced in OpenSpec 1.0+ implements **actions, not phases** as the collaboration paradigm. AI no longer passively receives static instructions but actively queries the CLI to understand the current project state (such as current Bounded Context boundaries and existing aggregate definitions), thereby making decisions more aligned with domain constraints.

### 3.2 Structured Validation and Automated Verification

OpenSpec internally uses structured schemas to validate spec documents. This makes "specification as test" possible:

- **Schema validation**: Ensures Requirement and Scenario formats are correct, preventing non-standard domain logic expression.
- **Automated verification loop**: AI generates integration tests from Specs (Scenario mapping) to verify that code implementation truly conforms to DDD invariant constraints.

---

## 4. Best Practice Recommendations

To achieve effective integration of DDD and OpenSpec, it is recommended to embed the "Ubiquitous Language" throughout the entire workflow and fully leverage its incremental management features.

### 4.1 Ubiquitous Language Enforcement Throughout

When writing `proposal.md`, `design.md`, and `spec.md`, the team's Ubiquitous Language must be strictly used. OpenSpec's `config.yaml` ensures these terms are precisely referenced as "context anchors" in every AI planning request.

### 4.2 Scenario-Driven BDD-Style Verification

Leverage OpenSpec scenarios' native support for Given/When/Then to establish rigorous behavioral baselines for aggregate design. Every P0-level aggregate invariant should have a corresponding Scenario, serving as the sole standard for AI implementation and automated testing.

> **Business-rules-first principle**: Scenarios describe only **business rules and invariants**; no technical details (database operations, HTTP interfaces, ORM calls, caching strategies) may leak in. Technical details belong in `design.md` or `tasks.md`. This constraint is equally important for humans and AI: keeping Scenarios domain-pure is the prerequisite for AI correctly generating domain-layer code and tests.

### 4.3 Leveraging Delta and Change Management

OpenSpec allows teams to develop different domain features in parallel under the `changes/` directory. Through the Delta mechanism, teams can focus only on the capabilities affected by the current change, avoiding loss of focus due to document redundancy in large DDD projects.

---

## 5. Minimum Viable Example: "User Registration"

To help teams get started quickly, this section provides an end-to-end micro example showing how the Ubiquitous Language flows from `proposal.md` through to `spec.md`. Assume the Bounded Context is **User Context**, and the new "Email Registration" capability needs to be added.

### 5.1 `proposal.md` Fragment

```markdown
## Why

The current system lacks an independent user registration entry point, preventing new users from creating accounts autonomously.

## What Changes

- Add capability under User Context: Email Registration (EmailRegistration)
- Introduce domain event: UserRegistered
- Ubiquitous Language: Registrant, Email, ActivationLink

## Impact

- Capabilities: user-context/email-registration
- Aggregate changes: Add User aggregate root and its invariants (email uniqueness, activation state machine)

## Goals

- Registration submission success rate >= 99% (excluding business rejections due to email already taken)
- Registration -> Activation conversion rate >= 80%
- End-to-end registration response time P95 <= 500 ms
```

### 5.2 `specs/user-context/email-registration/spec.md` Fragment

```markdown
## Requirement: Email Registration Capability

The system should support registrants creating accounts via email, maintaining Pending status until activation.

### Scenario: Successful registration with an unoccupied email

- **Given** no user with email "alice@example.com" exists in the system
- **When** a registrant submits email "alice@example.com" with a valid password
- **Then** a User aggregate with Pending status is created
- **And** a UserRegistered event is published, carrying UserId and Email

### Scenario: Registration rejected when email is already taken

- **Given** a User with email "alice@example.com" already exists in the system
- **When** another registrant submits the same email
- **Then** registration is rejected, returning an EmailAlreadyRegistered error
- **And** no domain events are published
```

> Note: The Scenarios focus on business rules (email uniqueness, initial state is Pending, successful registration must publish an event), without involving specific databases, HTTP status codes, or ORM implementation — these belong in the technical design of `design.md` and the task breakdown of `tasks.md`.

---

## 6. Summary

The combination of OpenSpec and DDD is a synergy of "philosophy" and "technique." DDD provides the strategic and tactical thinking for analyzing complex business domains, pointing the direction for software development; OpenSpec, through "brownfield-first," "specification-driven," and the "AI dynamic directive system," efficiently and verifiably transforms these domain designs into engineering deliverables.

---

## Appendix A: Implementation Paradigm for Event-Driven Eventual Consistency

The rule declared in `config.yaml` — "All aggregate changes must be driven by domain events for eventual consistency" — requires concrete paradigms to enable accurate AI implementation. Below are two common scenarios.

### A.1 When to Publish Events

- **Cross-aggregate consistency**: When a single user command needs to affect multiple aggregates (e.g., placing an order triggers inventory deduction and account balance changes), only synchronously update state within the **aggregate directly acted upon by the command**, publish a domain event, and let event handlers asynchronously update other aggregates.
- **Cross-context integration**: When external contexts (such as notifications, points, auditing) need to be aware of state changes in this context, publish domain events as contract exits, avoiding downstream systems from directly reading this context's aggregate state.
- **Trigger timing**: Events should be published **after the aggregate state is persisted**, at transaction commit time (Outbox pattern recommended), ensuring consistency between events and state changes.

### A.2 How to Consume Events

- **Idempotent consumption**: Event handlers must carry idempotency keys (typically `AggregateId + Version` or `EventId`) to prevent duplicate delivery from causing aggregate state drift.
- **Failure strategy**: When consumption fails, enter a retry queue or dead-letter queue; do NOT roll back the upstream aggregate. Cross-aggregate compensation logic is completed by publishing compensation events (e.g., `OrderCancelled`).
- **Context translation**: When consuming events across contexts, pass through an Anti-Corruption Layer (ACL) to translate upstream semantics into this context's Ubiquitous Language, preventing upstream model leakage.

### A.3 Order Placement Event Chain Example

```text
PlaceOrderCommand
  -> Order aggregate: Create Order (status = Pending), persist
  -> Publish OrderPlaced(OrderId, Items, TotalAmount)

OrderPlaced
  -> Inventory aggregate: Deduct inventory -> Publish InventoryReserved or InventoryInsufficient
  -> Payment aggregate: Create pending payment -> Publish PaymentRequested

InventoryInsufficient
  -> Order aggregate: Set Order to Cancelled -> Publish OrderCancelled (compensation)
```

> In this chain, each aggregate is responsible only for its local state; cross-aggregate consistency is achieved through events and compensation. When AI implements such flows, it should strictly follow the "one transaction modifies one aggregate" constraint.
