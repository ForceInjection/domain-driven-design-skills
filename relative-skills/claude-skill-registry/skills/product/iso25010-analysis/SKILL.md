---
name: iso25010-analysis
description: ISO/IEC 25010 quality model for software product quality characteristics
allowed-tools: Read, Glob, Grep, Write, Edit
---

# ISO 25010 Analysis Skill

## When to Use This Skill

Use this skill when:

- **Iso25010 Analysis tasks** - Working on iso/iec 25010 quality model for software product quality characteristics
- **Planning or design** - Need guidance on Iso25010 Analysis approaches
- **Best practices** - Want to follow established patterns and standards

## Overview

Apply the ISO/IEC 25010:2023 quality model to systematically assess and specify software product quality.

## MANDATORY: Documentation-First Approach

Before applying ISO 25010:

1. **Invoke `docs-management` skill** for quality model patterns
2. **Verify ISO 25010:2023 updates** via MCP servers (perplexity for latest changes)
3. **Base all guidance on ISO/IEC 25010:2023 standard**

## ISO 25010:2023 Quality Model

### Product Quality Model

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Product Quality Characteristics                       │
├──────────────────┬──────────────────┬──────────────────┬───────────────────┤
│   Functional     │   Performance    │   Compatibility  │    Interaction    │
│   Suitability    │   Efficiency     │                  │    Capability     │
├──────────────────┼──────────────────┼──────────────────┼───────────────────┤
│ • Completeness   │ • Time behavior  │ • Co-existence   │ • Appropriateness │
│ • Correctness    │ • Resource use   │ • Interoperability│   recognizability│
│ • Appropriateness│ • Capacity       │                  │ • Learnability    │
│                  │                  │                  │ • Operability     │
│                  │                  │                  │ • User error      │
│                  │                  │                  │   protection      │
│                  │                  │                  │ • User engagement │
│                  │                  │                  │ • Inclusivity     │
│                  │                  │                  │ • User assistance │
│                  │                  │                  │ • Self-descriptive│
├──────────────────┼──────────────────┼──────────────────┼───────────────────┤
│    Reliability   │     Security     │  Maintainability │    Flexibility    │
├──────────────────┼──────────────────┼──────────────────┼───────────────────┤
│ • Faultlessness  │ • Confidentiality│ • Modularity     │ • Adaptability    │
│ • Availability   │ • Integrity      │ • Reusability    │ • Scalability     │
│ • Fault tolerance│ • Non-repudiation│ • Analysability  │ • Installability  │
│ • Recoverability │ • Accountability │ • Modifiability  │ • Replaceability  │
│                  │ • Authenticity   │ • Testability    │                   │
│                  │ • Resistance     │                  │                   │
└──────────────────┴──────────────────┴──────────────────┴───────────────────┘
```

### Quality in Use Model

```text
┌────────────────────────────────────────────────────────────────────────────┐
│                        Quality in Use Characteristics                       │
├──────────────────┬──────────────────┬──────────────────┬──────────────────┤
│   Effectiveness  │    Efficiency    │   Satisfaction   │  Freedom from    │
│                  │                  │                  │      Risk        │
├──────────────────┼──────────────────┼──────────────────┼──────────────────┤
│ Goals achieved   │ Resources        │ • Usefulness     │ • Economic risk  │
│ with accuracy    │ expended for     │ • Trust          │   mitigation     │
│ and completeness │ effectiveness    │ • Pleasure       │ • Health/safety  │
│                  │                  │ • Comfort        │   risk mitigation│
│                  │                  │                  │ • Environmental  │
│                  │                  │                  │   risk mitigation│
├──────────────────┴──────────────────┴──────────────────┴──────────────────┤
│                           Context Coverage                                  │
├──────────────────┬──────────────────────────────────────────────────────────┤
│ • Context        │ Degree to which product quality enables                  │
│   completeness   │ different users in different contexts                    │
│ • Flexibility    │                                                          │
└──────────────────┴──────────────────────────────────────────────────────────┘
```

## Characteristic Definitions

### Functional Suitability

```csharp
/// <summary>
/// Degree to which a product provides functions that meet stated and
/// implied needs when used under specified conditions.
/// </summary>
public sealed record FunctionalSuitability
{
    /// <summary>
    /// Degree to which the set of functions covers all specified tasks
    /// and user objectives.
    /// </summary>
    public QualityLevel Completeness { get; init; }

    /// <summary>
    /// Degree to which a product provides correct results with needed
    /// degree of precision.
    /// </summary>
    public QualityLevel Correctness { get; init; }

    /// <summary>
    /// Degree to which functions facilitate accomplishment of specified
    /// tasks and objectives.
    /// </summary>
    public QualityLevel Appropriateness { get; init; }
}
```

### Performance Efficiency

```csharp
/// <summary>
/// Performance relative to resources used under stated conditions.
/// </summary>
public sealed record PerformanceEfficiency
{
    /// <summary>
    /// Degree to which response and processing times meet requirements.
    /// Example: API responds in <100ms (p95)
    /// </summary>
    public TimeBehavior TimeBehavior { get; init; }

    /// <summary>
    /// Degree to which amounts and types of resources meet requirements.
    /// Example: Memory usage <512MB, CPU <25%
    /// </summary>
    public ResourceUtilization ResourceUtilization { get; init; }

    /// <summary>
    /// Degree to which maximum limits meet requirements.
    /// Example: Supports 10,000 concurrent users
    /// </summary>
    public Capacity Capacity { get; init; }
}

public sealed record TimeBehavior(
    TimeSpan ResponseTimeP50,
    TimeSpan ResponseTimeP95,
    TimeSpan ResponseTimeP99,
    double ThroughputPerSecond);
```

### Reliability

```csharp
/// <summary>
/// Degree to which a system performs specified functions under
/// specified conditions for a specified period of time.
/// </summary>
public sealed record Reliability
{
    /// <summary>
    /// Degree to which a system is free from faults in its operation.
    /// Example: <0.1% error rate
    /// </summary>
    public QualityLevel Faultlessness { get; init; }

    /// <summary>
    /// Degree to which a system is operational and accessible.
    /// Example: 99.9% availability (8.76 hours downtime/year)
    /// </summary>
    public AvailabilityTarget Availability { get; init; }

    /// <summary>
    /// Degree to which a system operates despite faults.
    /// Example: Graceful degradation when database unavailable
    /// </summary>
    public QualityLevel FaultTolerance { get; init; }

    /// <summary>
    /// Degree to which a system can recover from failure.
    /// Example: RTO <1 hour, RPO <15 minutes
    /// </summary>
    public RecoverabilityTarget Recoverability { get; init; }
}

public sealed record AvailabilityTarget(
    double TargetPercentage,
    TimeSpan AllowedDowntimePerYear)
{
    public static AvailabilityTarget TwoNines => new(99.0, TimeSpan.FromDays(3.65));
    public static AvailabilityTarget ThreeNines => new(99.9, TimeSpan.FromHours(8.76));
    public static AvailabilityTarget FourNines => new(99.99, TimeSpan.FromMinutes(52.6));
    public static AvailabilityTarget FiveNines => new(99.999, TimeSpan.FromMinutes(5.26));
}
```

### Security

```csharp
/// <summary>
/// Degree to which a product protects information and data.
/// </summary>
public sealed record Security
{
    /// <summary>
    /// Degree to which data is accessible only to authorized users.
    /// </summary>
    public QualityLevel Confidentiality { get; init; }

    /// <summary>
    /// Degree to which system prevents unauthorized access or modification.
    /// </summary>
    public QualityLevel Integrity { get; init; }

    /// <summary>
    /// Degree to which actions can be proven to have taken place.
    /// </summary>
    public QualityLevel NonRepudiation { get; init; }

    /// <summary>
    /// Degree to which entity actions can be traced uniquely.
    /// </summary>
    public QualityLevel Accountability { get; init; }

    /// <summary>
    /// Degree to which identity can be verified.
    /// </summary>
    public QualityLevel Authenticity { get; init; }

    /// <summary>
    /// Degree to which product resists attacks.
    /// </summary>
    public QualityLevel Resistance { get; init; }
}
```

### Maintainability

```csharp
/// <summary>
/// Degree to which a product can be modified effectively and efficiently.
/// </summary>
public sealed record Maintainability
{
    /// <summary>
    /// Degree to which system is composed of discrete components.
    /// Example: Clear module boundaries, low coupling
    /// </summary>
    public QualityLevel Modularity { get; init; }

    /// <summary>
    /// Degree to which asset can be used in more than one system.
    /// Example: Shared libraries, common components
    /// </summary>
    public QualityLevel Reusability { get; init; }

    /// <summary>
    /// Degree to which impact of change can be assessed.
    /// Example: Clear dependencies, comprehensive logging
    /// </summary>
    public QualityLevel Analysability { get; init; }

    /// <summary>
    /// Degree to which product can be modified without defects.
    /// Example: SOLID principles, clean code
    /// </summary>
    public QualityLevel Modifiability { get; init; }

    /// <summary>
    /// Degree to which test criteria can be established and tests performed.
    /// Example: High test coverage, testable architecture
    /// </summary>
    public QualityLevel Testability { get; init; }
}
```

## Quality Assessment Template

```markdown
# ISO 25010 Quality Assessment

**System:** [System Name]
**Version:** [Version]
**Date:** [Date]
**Assessor:** [Name]

## 1. Functional Suitability

### 1.1 Completeness
**Rating:** [1-5] | **Target:** [1-5]
**Evidence:**
- [ ] All specified features implemented
- [ ] User story acceptance criteria met
- [ ] Edge cases handled

### 1.2 Correctness
**Rating:** [1-5] | **Target:** [1-5]
**Evidence:**
- [ ] Calculation accuracy verified
- [ ] Data transformations validated
- [ ] Business rules correctly applied

### 1.3 Appropriateness
**Rating:** [1-5] | **Target:** [1-5]
**Evidence:**
- [ ] Functions support user workflows
- [ ] No unnecessary complexity
- [ ] Automation of repetitive tasks

## 2. Performance Efficiency

### 2.1 Time Behavior
**Rating:** [1-5] | **Target:** [1-5]
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Response Time (p50) | <50ms | | |
| Response Time (p95) | <100ms | | |
| Response Time (p99) | <500ms | | |
| Throughput | >1000 req/s | | |

### 2.2 Resource Utilization
**Rating:** [1-5] | **Target:** [1-5]
| Resource | Limit | Actual | Status |
|----------|-------|--------|--------|
| CPU | <50% | | |
| Memory | <512MB | | |
| Network | <100Mbps | | |
| Storage IOPS | <1000 | | |

### 2.3 Capacity
**Rating:** [1-5] | **Target:** [1-5]
| Metric | Target | Tested | Status |
|--------|--------|--------|--------|
| Concurrent Users | 10,000 | | |
| Records per Table | 10M | | |
| File Size | 100MB | | |

## 3. Reliability

### 3.1 Availability
**Target:** 99.9% (3 nines)
**Allowed Downtime:** 8.76 hours/year
**Current Status:** [Measured availability]

### 3.2 Fault Tolerance
- [ ] Circuit breakers implemented
- [ ] Retry with backoff
- [ ] Graceful degradation
- [ ] Bulkhead isolation

### 3.3 Recoverability
| Metric | Target | Tested |
|--------|--------|--------|
| RTO | <1 hour | |
| RPO | <15 minutes | |
| Backup frequency | Daily | |
| Recovery tested | Monthly | |

## 4. Security

| Sub-characteristic | Rating | Evidence |
|--------------------|--------|----------|
| Confidentiality | | Encryption at rest/transit |
| Integrity | | Input validation, checksums |
| Non-repudiation | | Audit logging |
| Accountability | | User tracking |
| Authenticity | | Strong authentication |
| Resistance | | Penetration testing |

## 5. Maintainability

| Sub-characteristic | Metric | Value |
|--------------------|--------|-------|
| Modularity | Coupling | |
| Reusability | Shared components | |
| Analysability | Documentation coverage | |
| Modifiability | Change failure rate | |
| Testability | Code coverage | |

## 6. Summary

### Strengths
- [List major strengths]

### Areas for Improvement
- [List areas needing attention]

### Recommendations
1. [Priority recommendation]
2. [Secondary recommendation]
```

## Mapping to Architecture Tactics

| Characteristic | Common Tactics |
|----------------|----------------|
| Performance | Caching, CDN, async processing, load balancing |
| Reliability | Redundancy, failover, circuit breakers, retries |
| Security | Encryption, authentication, authorization, auditing |
| Maintainability | Modularization, documentation, CI/CD, monitoring |
| Scalability | Horizontal scaling, sharding, queuing |

## Workflow

When applying ISO 25010:

1. **Identify Stakeholders**: Who cares about which qualities?
2. **Prioritize Characteristics**: Which matter most for this system?
3. **Define Targets**: Quantify where possible
4. **Assess Current State**: Rate each sub-characteristic
5. **Gap Analysis**: Compare current vs target
6. **Plan Improvements**: Architecture tactics to close gaps
7. **Monitor**: Track quality metrics over time

## References

For detailed guidance:

---

**Last Updated:** 2025-12-26
