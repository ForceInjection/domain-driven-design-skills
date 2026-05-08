---
name: qa-scenario-authoring
description: Create well-formed quality attribute scenarios with measurable response criteria
allowed-tools: Read, Glob, Grep, Write, Edit
---

# Quality Attribute Scenario Authoring Skill

## When to Use This Skill

Use this skill when:

- **Qa Scenario Authoring tasks** - Working on create well-formed quality attribute scenarios with measurable response criteria
- **Planning or design** - Need guidance on Qa Scenario Authoring approaches
- **Best practices** - Want to follow established patterns and standards

## Overview

Create well-formed, measurable quality attribute scenarios that drive architectural decisions.

## MANDATORY: Documentation-First Approach

Before authoring scenarios:

1. **Invoke `docs-management` skill** for scenario patterns
2. **Verify SEI scenario methodology** via MCP servers
3. **Base all guidance on SEI/Bass-Clements-Kazman quality attribute methodology**

## Six-Part Scenario Structure

Every quality attribute scenario must include all six parts:

```text
Quality Attribute Scenario Structure:

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│   SOURCE          STIMULUS          ARTIFACT          ENVIRONMENT           │
│   (Who/What)  →   (Event)      →    (Affected)   →   (Conditions)           │
│                                                                              │
│        ↓               ↓                ↓                 ↓                  │
│                                                                              │
│                    ┌─────────────────────────────────┐                       │
│                    │         RESPONSE                │                       │
│                    │    (System Behavior)            │                       │
│                    └─────────────────────────────────┘                       │
│                                      ↓                                       │
│                    ┌─────────────────────────────────┐                       │
│                    │     RESPONSE MEASURE            │                       │
│                    │  (Quantifiable Criteria)        │                       │
│                    └─────────────────────────────────┘                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Scenario Template

```markdown
## QA-[XXX]: [Descriptive Title]

**Quality Attribute:** [Primary attribute]
**Sub-characteristic:** [Specific aspect, e.g., Latency, Availability, Confidentiality]
**Priority:** [Must Have | Should Have | Could Have]
**Source:** [Stakeholder or requirement reference]

### Scenario Definition

| Part | Specification |
|------|---------------|
| **Source** | [Entity generating the stimulus] |
| **Stimulus** | [Condition or event arriving at the system] |
| **Artifact** | [Part of system that is stimulated] |
| **Environment** | [Conditions under which stimulus occurs] |
| **Response** | [Activity that occurs after stimulus arrives] |
| **Response Measure** | [Measure to determine if response is satisfactory] |

### Narrative

[1-2 paragraph description in plain language explaining the scenario
and its business context]

### Acceptance Criteria

- [ ] [Criterion 1 derived from response measure]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

### Architectural Implications

- [Tactic 1 that may address this scenario]
- [Tactic 2]
- [Trade-offs to consider]

### Test Strategy

- **Unit Test:** [How to test at unit level]
- **Integration Test:** [How to test across components]
- **System Test:** [How to test in production-like environment]
```

## Scenarios by Quality Attribute

### Performance Scenarios

#### Latency

```markdown
## QA-PERF-001: Order Submission Latency

**Quality Attribute:** Performance
**Sub-characteristic:** Latency
**Priority:** Must Have
**Source:** Product Owner, SLA Requirements

### Scenario Definition

| Part | Specification |
|------|---------------|
| **Source** | Customer using web browser |
| **Stimulus** | Submits a checkout order |
| **Artifact** | Order Processing API |
| **Environment** | Normal operation (1000 concurrent users) |
| **Response** | Order is validated, persisted, and confirmation returned |
| **Response Measure** | 95th percentile response time ≤ 500ms |

### Narrative

When a customer completes checkout, they expect near-instant confirmation.
Research shows cart abandonment increases 7% for every additional second
of latency. This scenario ensures the order processing path meets
customer expectations under typical load.

### Acceptance Criteria

- [ ] P95 latency ≤ 500ms under normal load (1000 concurrent users)
- [ ] P99 latency ≤ 1 second under normal load
- [ ] No timeouts (> 5 seconds) under normal load

### Architectural Implications

- Synchronous validation only for critical checks
- Async processing for non-critical operations (email, analytics)
- Connection pooling for database access
- Consider caching for product/pricing lookups

### Test Strategy

- **Load Test:** k6 script simulating 1000 concurrent order submissions
- **Baseline:** Establish P50/P95/P99 under controlled conditions
- **Continuous:** Include in CI/CD pipeline with performance gates
```

#### Throughput

```markdown
## QA-PERF-002: Event Processing Throughput

**Quality Attribute:** Performance
**Sub-characteristic:** Throughput
**Priority:** Must Have
**Source:** Operations Team

### Scenario Definition

| Part | Specification |
|------|---------------|
| **Source** | IoT devices |
| **Stimulus** | Continuous stream of telemetry events |
| **Artifact** | Event Ingestion Service |
| **Environment** | Peak load (holiday period) |
| **Response** | Events are validated, enriched, and stored |
| **Response Measure** | Sustain 50,000 events/second with < 1% drop rate |

### Architectural Implications

- Horizontal scaling with partitioned consumers
- Backpressure handling with buffering
- Batch writes to data store
- Consider event sampling for non-critical data
```

### Availability Scenarios

```markdown
## QA-AVL-001: Database Failover

**Quality Attribute:** Availability
**Sub-characteristic:** Fault Tolerance
**Priority:** Must Have
**Source:** SLA Agreement (99.9% uptime)

### Scenario Definition

| Part | Specification |
|------|---------------|
| **Source** | Database primary node |
| **Stimulus** | Hardware failure causing primary to become unavailable |
| **Artifact** | Database cluster |
| **Environment** | Normal operation with active transactions |
| **Response** | Automatic failover to replica with transaction recovery |
| **Response Measure** | Failover completes in < 30 seconds with zero data loss |

### Acceptance Criteria

- [ ] Failover triggered automatically on primary failure
- [ ] Failover duration < 30 seconds
- [ ] No committed transactions lost (RPO = 0)
- [ ] Application reconnects transparently

### Architectural Implications

- Synchronous replication for zero data loss
- Connection retry logic with exponential backoff
- Health check endpoints for early failure detection
- Consider multi-region for disaster recovery
```

### Security Scenarios

```markdown
## QA-SEC-001: Authentication Brute Force Protection

**Quality Attribute:** Security
**Sub-characteristic:** Authenticity
**Priority:** Must Have
**Source:** Security Team, OWASP ASVS

### Scenario Definition

| Part | Specification |
|------|---------------|
| **Source** | Malicious actor |
| **Stimulus** | Repeated failed login attempts (> 5 in 1 minute) |
| **Artifact** | Authentication Service |
| **Environment** | Public internet access |
| **Response** | Account is temporarily locked, alert is raised |
| **Response Measure** | Lock activates within 1 second of threshold breach |

### Acceptance Criteria

- [ ] Account locks after 5 failed attempts in 1 minute
- [ ] Lock duration is 15 minutes (configurable)
- [ ] Security team alerted within 30 seconds
- [ ] Legitimate user can unlock via email verification

### Architectural Implications

- Rate limiting at API gateway level
- Distributed rate limiting for multi-instance deployments
- Secure storage of attempt counts (Redis/cache)
- Alert integration with SIEM
```

### Modifiability Scenarios

```markdown
## QA-MOD-001: Payment Provider Addition

**Quality Attribute:** Modifiability
**Sub-characteristic:** Extensibility
**Priority:** Should Have
**Source:** Product Roadmap

### Scenario Definition

| Part | Specification |
|------|---------------|
| **Source** | Development team |
| **Stimulus** | Request to add new payment provider |
| **Artifact** | Payment Processing Module |
| **Environment** | Design time |
| **Response** | New provider implemented without modifying existing providers |
| **Response Measure** | Implementation complete in ≤ 5 developer-days |

### Acceptance Criteria

- [ ] New provider implemented as isolated module
- [ ] No changes to existing payment provider code
- [ ] No changes to core order processing logic
- [ ] Deployed with feature flag for gradual rollout

### Architectural Implications

- Strategy pattern for payment providers
- Provider interface abstraction
- Configuration-driven provider selection
- Integration tests for each provider independently
```

### Testability Scenarios

```markdown
## QA-TST-001: Service Isolation for Testing

**Quality Attribute:** Testability
**Sub-characteristic:** Controllability
**Priority:** Should Have
**Source:** QA Team

### Scenario Definition

| Part | Specification |
|------|---------------|
| **Source** | QA Engineer |
| **Stimulus** | Need to test order service in isolation |
| **Artifact** | Order Service |
| **Environment** | Test environment |
| **Response** | Service runs with mocked dependencies |
| **Response Measure** | Test suite executes in < 5 minutes without external services |

### Architectural Implications

- Dependency injection for all external dependencies
- Interface-based design for mockability
- Test containers for database testing
- Contract tests for integration points
```

## Response Measure Patterns

### Quantifiable Measures

| Quality Attribute | Measure Type | Examples |
|-------------------|--------------|----------|
| **Latency** | Time | P95 < 100ms, P99 < 500ms |
| **Throughput** | Rate | 10,000 req/sec, 1M events/hour |
| **Availability** | Percentage | 99.9%, 99.99% |
| **Failure Recovery** | Time | RTO < 1 hour, failover < 30s |
| **Data Loss** | Volume/Time | RPO < 15 min, zero committed |
| **Scalability** | Ratio | Linear to 10x load |
| **Modifiability** | Effort | < 5 days, < 2 files changed |
| **Testability** | Coverage/Time | 80% coverage, < 10 min suite |

### SMART Response Measures

```text
SMART Criteria for Response Measures:

S - Specific:    Precisely what is being measured
M - Measurable:  Quantifiable with tools/tests
A - Achievable:  Realistic given constraints
R - Relevant:    Matters to stakeholder concerns
T - Time-bound:  Measured within specific timeframe/conditions
```

## C# Implementation

```csharp
// Quality Attribute Scenario Model
public sealed record QualityAttributeScenario
{
    public required ScenarioId Id { get; init; }
    public required string Title { get; init; }
    public required QualityAttribute Attribute { get; init; }
    public required string SubCharacteristic { get; init; }
    public required ScenarioPriority Priority { get; init; }
    public required string SourceStakeholder { get; init; }

    // Six-Part Structure
    public required string StimulusSource { get; init; }
    public required string Stimulus { get; init; }
    public required string Artifact { get; init; }
    public required string Environment { get; init; }
    public required string Response { get; init; }
    public required ResponseMeasure ResponseMeasure { get; init; }

    public string? Narrative { get; init; }
    public IReadOnlyList<string> AcceptanceCriteria { get; init; } = [];
    public IReadOnlyList<string> ArchitecturalImplications { get; init; } = [];
}

public readonly record struct ScenarioId
{
    public required string Category { get; init; }  // PERF, AVL, SEC, MOD, etc.
    public required int Number { get; init; }

    public override string ToString() => $"QA-{Category}-{Number:D3}";
}

public sealed record ResponseMeasure
{
    public required string Metric { get; init; }
    public required string Target { get; init; }
    public required string MeasurementMethod { get; init; }
    public string? Tolerance { get; init; }

    // Examples: "P95 latency", "≤ 500ms", "Load test with k6"
}

public enum QualityAttribute
{
    Performance,
    Availability,
    Security,
    Modifiability,
    Testability,
    Usability,
    Interoperability,
    Portability,
    Reliability,
    Scalability
}

public enum ScenarioPriority
{
    MustHave = 1,
    ShouldHave = 2,
    CouldHave = 3
}

// Scenario Repository
public interface IScenarioRepository
{
    Task<QualityAttributeScenario?> GetByIdAsync(
        ScenarioId id,
        CancellationToken ct = default);

    Task<IReadOnlyList<QualityAttributeScenario>> GetByAttributeAsync(
        QualityAttribute attribute,
        CancellationToken ct = default);

    Task<IReadOnlyList<QualityAttributeScenario>> GetByPriorityAsync(
        ScenarioPriority priority,
        CancellationToken ct = default);

    Task SaveAsync(
        QualityAttributeScenario scenario,
        CancellationToken ct = default);
}
```

## Scenario Validation Checklist

```markdown
## Scenario Quality Checklist

### Completeness
- [ ] All six parts are specified (Source, Stimulus, Artifact, Environment, Response, Measure)
- [ ] Response measure is quantifiable
- [ ] Business context/justification is provided
- [ ] Priority is assigned

### Clarity
- [ ] No ambiguous terms (define "fast", "many", "soon")
- [ ] Environment conditions are explicit
- [ ] Response describes observable behavior
- [ ] Measure includes units and thresholds

### Testability
- [ ] Response measure can be verified with available tools
- [ ] Test strategy is outlined
- [ ] Baseline measurements are feasible

### Traceability
- [ ] Linked to business driver or requirement
- [ ] Stakeholder source identified
- [ ] Architectural implications documented

### Consistency
- [ ] No conflicts with other scenarios
- [ ] Measures align with related scenarios
- [ ] Environment assumptions are compatible
```

## Workflow

When authoring QA scenarios:

1. **Identify**: Determine quality attribute and sub-characteristic
2. **Source**: Identify stimulus source and business context
3. **Specify**: Define all six parts with precision
4. **Quantify**: Create SMART response measure
5. **Validate**: Apply quality checklist
6. **Trace**: Link to requirements and architectural tactics
7. **Test**: Define verification strategy

## References

For detailed guidance:

---

**Last Updated:** 2025-12-26
