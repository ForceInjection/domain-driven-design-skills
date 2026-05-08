---
name: furps-analysis
description: FURPS+ model for categorizing and specifying non-functional requirements
allowed-tools: Read, Glob, Grep, Write, Edit
---

# FURPS+ Analysis Skill

## When to Use This Skill

Use this skill when:

- **Furps Analysis tasks** - Working on furps+ model for categorizing and specifying non-functional requirements
- **Planning or design** - Need guidance on Furps Analysis approaches
- **Best practices** - Want to follow established patterns and standards

## Overview

Apply the FURPS+ model to systematically categorize and specify non-functional requirements.

## MANDATORY: Documentation-First Approach

Before applying FURPS+:

1. **Invoke `docs-management` skill** for requirements categorization patterns
2. **Verify FURPS+ extensions** via MCP servers
3. **Base all guidance on Hewlett-Packard/Rational FURPS+ methodology**

## FURPS+ Model Overview

```text
FURPS+ Categories:

┌─────────────────────────────────────────────────────────────────────────────┐
│                              FURPS (Core)                                    │
├──────────────┬──────────────┬──────────────┬──────────────┬────────────────┤
│ Functionality│   Usability  │  Reliability │ Performance  │ Supportability │
├──────────────┼──────────────┼──────────────┼──────────────┼────────────────┤
│ • Features   │ • Aesthetics │ • Frequency  │ • Speed      │ • Testability  │
│ • Capabilities│ • Consistency│ • Recoverabil│ • Efficiency │ • Extensibility│
│ • Security   │ • Documentation│  ity       │ • Throughput │ • Adaptability │
│              │ • Accessibility│ • Accuracy │ • Resource   │ • Maintainability│
│              │              │              │   Usage      │ • Compatibility│
│              │              │              │              │ • Configurability│
│              │              │              │              │ • Serviceability│
│              │              │              │              │ • Installability│
│              │              │              │              │ • Localizability│
└──────────────┴──────────────┴──────────────┴──────────────┴────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              + (Plus Categories)                             │
├─────────────────┬─────────────────┬─────────────────┬───────────────────────┤
│     Design      │ Implementation  │   Interface     │      Physical         │
│   Constraints   │   Constraints   │  Requirements   │    Constraints        │
├─────────────────┼─────────────────┼─────────────────┼───────────────────────┤
│ • Architecture  │ • Standards     │ • External APIs │ • Hardware           │
│ • Patterns      │ • Languages     │ • Protocols     │ • Deployment         │
│ • Frameworks    │ • Tools         │ • Data formats  │ • Network            │
│ • Reuse         │ • Libraries     │ • Legacy        │ • Environmental      │
└─────────────────┴─────────────────┴─────────────────┴───────────────────────┘
```

## Category Definitions

### F - Functionality

Requirements that specify capabilities the system must have.

```markdown
## Functionality Requirements

### Feature Sets
| ID | Feature | Description | Priority |
|----|---------|-------------|----------|
| F-001 | Order Management | Create, update, cancel orders | Must Have |
| F-002 | Payment Processing | Accept credit cards, PayPal | Must Have |
| F-003 | Reporting | Generate sales reports | Should Have |

### Security Requirements
| ID | Requirement | Rationale |
|----|-------------|-----------|
| F-SEC-001 | All passwords hashed with bcrypt | Protect credentials |
| F-SEC-002 | MFA for admin accounts | Prevent unauthorized access |
| F-SEC-003 | Encrypt PII at rest | Compliance (GDPR) |

### Audit/Logging
| ID | Requirement | Retention |
|----|-------------|-----------|
| F-AUD-001 | Log all authentication attempts | 90 days |
| F-AUD-002 | Log all data modifications | 7 years |
```

### U - Usability

Requirements affecting user experience and accessibility.

```markdown
## Usability Requirements

### Aesthetics
| ID | Requirement | Metric |
|----|-------------|--------|
| U-001 | Consistent branding across UI | Brand guidelines compliance |
| U-002 | Modern, clean interface | User satisfaction >4.0/5.0 |

### Accessibility
| ID | Requirement | Standard |
|----|-------------|----------|
| U-ACC-001 | WCAG 2.1 Level AA compliance | All public pages |
| U-ACC-002 | Keyboard navigation | All interactive elements |
| U-ACC-003 | Screen reader support | ARIA labels complete |

### Learnability
| ID | Requirement | Metric |
|----|-------------|--------|
| U-LRN-001 | New users productive within 1 hour | 80% complete basic tasks |
| U-LRN-002 | Contextual help available | Every form has help text |
| U-LRN-003 | Onboarding tour | First login experience |

### Error Handling
| ID | Requirement | Metric |
|----|-------------|--------|
| U-ERR-001 | Friendly error messages | No stack traces shown |
| U-ERR-002 | Recovery suggestions | All errors suggest action |
```

### R - Reliability

Requirements for system dependability and fault handling.

```markdown
## Reliability Requirements

### Availability
| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| R-AVL-001 | System availability | 99.9% | Monthly uptime |
| R-AVL-002 | Planned maintenance window | 2 hours/month | Off-peak only |
| R-AVL-003 | Degraded mode operation | Critical functions available | During partial outage |

### Fault Tolerance
| ID | Requirement | Scenario |
|----|-------------|----------|
| R-FLT-001 | Database failover | <30 seconds |
| R-FLT-002 | Service restart | <60 seconds |
| R-FLT-003 | Queue backpressure | 10,000 messages buffered |

### Recoverability
| ID | Requirement | Target |
|----|-------------|--------|
| R-RCV-001 | Recovery Time Objective (RTO) | <1 hour |
| R-RCV-002 | Recovery Point Objective (RPO) | <15 minutes |
| R-RCV-003 | Backup frequency | Every 6 hours |
| R-RCV-004 | Disaster recovery test | Quarterly |

### Data Integrity
| ID | Requirement | Approach |
|----|-------------|----------|
| R-INT-001 | Transaction consistency | ACID guarantees |
| R-INT-002 | Data validation | Schema validation on input |
| R-INT-003 | Corruption detection | Checksums on critical data |
```

### P - Performance

Requirements for speed, efficiency, and capacity.

```markdown
## Performance Requirements

### Response Time
| ID | Operation | Target | Measurement |
|----|-----------|--------|-------------|
| P-RSP-001 | Page load | <2 seconds | Time to interactive |
| P-RSP-002 | API response | <100ms (p95) | Server processing |
| P-RSP-003 | Search results | <500ms | Complex queries |
| P-RSP-004 | Report generation | <10 seconds | Monthly reports |

### Throughput
| ID | Requirement | Target | Sustained |
|----|-------------|--------|-----------|
| P-THR-001 | API requests | 1,000 req/sec | Normal load |
| P-THR-002 | Order processing | 100 orders/sec | Peak periods |
| P-THR-003 | Message processing | 10,000 msg/sec | Async queues |

### Resource Utilization
| ID | Resource | Limit | Condition |
|----|----------|-------|-----------|
| P-RES-001 | CPU utilization | <70% | Normal load |
| P-RES-002 | Memory usage | <80% | All pods |
| P-RES-003 | Database connections | <500 | Connection pool |
| P-RES-004 | Storage growth | <10GB/month | Data retention |

### Scalability
| ID | Dimension | Requirement |
|----|-----------|-------------|
| P-SCL-001 | Horizontal scaling | Add nodes without downtime |
| P-SCL-002 | User capacity | 100,000 concurrent users |
| P-SCL-003 | Data volume | 1TB without degradation |
```

### S - Supportability

Requirements for maintenance, operations, and evolution.

```markdown
## Supportability Requirements

### Testability
| ID | Requirement | Target |
|----|-------------|--------|
| S-TST-001 | Unit test coverage | >80% |
| S-TST-002 | Integration test coverage | All API endpoints |
| S-TST-003 | E2E test coverage | Critical user journeys |
| S-TST-004 | Test execution time | <10 minutes (CI) |

### Maintainability
| ID | Requirement | Approach |
|----|-------------|----------|
| S-MNT-001 | Code quality | Automated linting |
| S-MNT-002 | Documentation | API docs auto-generated |
| S-MNT-003 | Dependency updates | Monthly review |
| S-MNT-004 | Technical debt | <10% backlog |

### Configurability
| ID | Requirement | Scope |
|----|-------------|-------|
| S-CFG-001 | Feature flags | All new features |
| S-CFG-002 | Environment config | External configuration |
| S-CFG-003 | Runtime tuning | Without deployment |

### Observability
| ID | Requirement | Tool |
|----|-------------|------|
| S-OBS-001 | Centralized logging | Application Insights |
| S-OBS-002 | Distributed tracing | OpenTelemetry |
| S-OBS-003 | Metrics dashboards | Grafana |
| S-OBS-004 | Alerting | PagerDuty |

### Installability
| ID | Requirement | Method |
|----|-------------|--------|
| S-INS-001 | Automated deployment | CI/CD pipeline |
| S-INS-002 | Zero-downtime deploy | Blue-green or rolling |
| S-INS-003 | Rollback capability | <5 minutes |
```

## Plus Categories (+)

### Design Constraints

```markdown
## Design Constraints

| ID | Constraint | Rationale |
|----|------------|-----------|
| DC-001 | Microservices architecture | Scalability, team autonomy |
| DC-002 | Event-driven communication | Loose coupling |
| DC-003 | Domain-Driven Design | Complex domain handling |
| DC-004 | CQRS for read-heavy services | Performance optimization |
```

### Implementation Constraints

```markdown
## Implementation Constraints

| ID | Constraint | Requirement |
|----|------------|-------------|
| IC-001 | Language: C# (.NET 10) | Team expertise |
| IC-002 | Cloud: Azure | Enterprise agreement |
| IC-003 | Database: PostgreSQL | Open source, capabilities |
| IC-004 | Message broker: Azure Service Bus | Azure integration |
| IC-005 | Coding standards | Microsoft C# conventions |
```

### Interface Requirements

```markdown
## Interface Requirements

| ID | Interface | Protocol | Format |
|----|-----------|----------|--------|
| IR-001 | Payment gateway | REST/HTTPS | JSON |
| IR-002 | Shipping provider | SOAP | XML |
| IR-003 | Analytics platform | REST | JSON |
| IR-004 | Legacy ERP | File transfer | CSV |
| IR-005 | Mobile app | REST/gRPC | JSON/Protobuf |
```

### Physical Constraints

```markdown
## Physical Constraints

| ID | Constraint | Specification |
|----|------------|---------------|
| PC-001 | Cloud regions | US East, West Europe |
| PC-002 | Network bandwidth | 1Gbps minimum |
| PC-003 | Storage type | SSD for databases |
| PC-004 | Container runtime | Kubernetes (AKS) |
| PC-005 | Minimum instances | 3 (high availability) |
```

## C# Implementation

```csharp
// FURPS+ Requirements Model
public sealed record FurpsRequirements
{
    public FunctionalityRequirements Functionality { get; init; }
    public UsabilityRequirements Usability { get; init; }
    public ReliabilityRequirements Reliability { get; init; }
    public PerformanceRequirements Performance { get; init; }
    public SupportabilityRequirements Supportability { get; init; }
    public PlusConstraints Constraints { get; init; }
}

public sealed record FunctionalityRequirements
{
    public IReadOnlyList<Feature> Features { get; init; }
    public SecurityRequirements Security { get; init; }
    public AuditRequirements Audit { get; init; }
}

public sealed record PerformanceRequirements
{
    public ResponseTimeTargets ResponseTime { get; init; }
    public ThroughputTargets Throughput { get; init; }
    public ResourceLimits Resources { get; init; }
    public ScalabilityTargets Scalability { get; init; }
}

public sealed record ResponseTimeTargets(
    TimeSpan PageLoadTarget,
    TimeSpan ApiResponseP95,
    TimeSpan SearchResultTarget);

public sealed record ReliabilityRequirements
{
    public AvailabilityTarget Availability { get; init; }
    public FaultToleranceRequirements FaultTolerance { get; init; }
    public RecoveryRequirements Recovery { get; init; }
}

public sealed record RecoveryRequirements(
    TimeSpan RecoveryTimeObjective,
    TimeSpan RecoveryPointObjective,
    TimeSpan BackupFrequency);

public sealed record PlusConstraints
{
    public IReadOnlyList<DesignConstraint> Design { get; init; }
    public IReadOnlyList<ImplementationConstraint> Implementation { get; init; }
    public IReadOnlyList<InterfaceRequirement> Interfaces { get; init; }
    public IReadOnlyList<PhysicalConstraint> Physical { get; init; }
}
```

## FURPS+ vs ISO 25010 Mapping

| FURPS+ | ISO 25010 Equivalent |
|--------|---------------------|
| Functionality | Functional Suitability |
| Usability | Interaction Capability |
| Reliability | Reliability |
| Performance | Performance Efficiency |
| Supportability | Maintainability + Flexibility |
| Design Constraints | (Architecture decisions) |
| Implementation | (Technology choices) |
| Interface | Compatibility |
| Physical | (Infrastructure) |

## Workflow

When applying FURPS+:

1. **Gather Requirements**: Collect all known requirements
2. **Categorize**: Sort into FURPS+ categories
3. **Identify Gaps**: Find missing categories
4. **Quantify**: Add measurable targets
5. **Prioritize**: Rank by importance and risk
6. **Validate**: Review with stakeholders
7. **Track**: Monitor implementation progress

## References

For detailed guidance:

---

**Last Updated:** 2025-12-26
