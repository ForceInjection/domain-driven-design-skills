---
name: enterprise-patterns
description: Apply enterprise architecture patterns for integration and governance
version: "2.0.0"
sasmp_version: "1.3.0"
bonded_agent: 03-enterprise-architecture
bond_type: PRIMARY_BOND
last_updated: "2025-01"
---

# Enterprise Patterns Skill

## Purpose
Apply enterprise architecture patterns including TOGAF, integration patterns, governance frameworks, and portfolio management for large-scale systems.

---

## Parameters

| Parameter | Type | Required | Validation | Default |
|-----------|------|----------|------------|---------|
| `context` | string | ✅ | min: 50 chars | - |
| `pattern_type` | enum | ⚪ | integration\|governance\|portfolio\|togaf | `integration` |
| `scope` | enum | ⚪ | enterprise\|domain\|capability | `enterprise` |
| `current_state` | object | ⚪ | valid JSON | `{}` |
| `output_format` | enum | ⚪ | pattern\|roadmap\|governance | `pattern` |

---

## Execution Flow

```
┌──────────────────────────────────────────────────────────┐
│ 1. VALIDATE: Check context and pattern type              │
│ 2. ASSESS: Current state and maturity                    │
│ 3. SELECT: Appropriate enterprise pattern                │
│ 4. APPLY: Pattern to context                             │
│ 5. MAP: To TOGAF phases if applicable                    │
│ 6. ROADMAP: Create transition plan                       │
│ 7. DOCUMENT: Return pattern application                  │
└──────────────────────────────────────────────────────────┘
```

---

## Retry Logic

| Error | Retry | Backoff | Max Attempts |
|-------|-------|---------|--------------|
| `VALIDATION_ERROR` | No | - | 1 |
| `PATTERN_MISMATCH` | Yes | 1s | 2 |
| `SCOPE_UNCLEAR` | Yes | - | 2 |

---

## Logging & Observability

```yaml
log_points:
  - event: pattern_requested
    level: info
    data: [pattern_type, scope]
  - event: pattern_applied
    level: info
    data: [pattern_name, maturity_level]
  - event: roadmap_generated
    level: info
    data: [phases_count, timeline]

metrics:
  - name: patterns_applied
    type: counter
    labels: [pattern_type]
  - name: application_time_ms
    type: histogram
  - name: maturity_score
    type: gauge
```

---

## Error Handling

| Error Code | Description | Recovery |
|------------|-------------|----------|
| `E601` | Missing enterprise context | Request org structure |
| `E602` | Pattern not applicable | Suggest alternatives |
| `E603` | Scope too broad | Narrow to domain |
| `E604` | TOGAF phase unclear | Clarify ADM phase |

---

## Unit Test Template

```yaml
test_cases:
  - name: "Integration pattern selection"
    input:
      context: "E-commerce integrating with ERP for inventory"
      pattern_type: "integration"
      scope: "enterprise"
    expected:
      has_pattern: true
      pattern_includes: ["Event-Driven", "CDC"]
      has_rationale: true

  - name: "Governance model"
    input:
      context: "5 business units, 200+ applications"
      pattern_type: "governance"
    expected:
      has_governance_model: true
      has_decision_rights: true
      has_review_process: true

  - name: "Portfolio rationalization"
    input:
      context: "Legacy modernization initiative"
      pattern_type: "portfolio"
    expected:
      has_time_analysis: true
      categories_include: ["Tolerate", "Invest", "Migrate", "Eliminate"]
```

---

## Troubleshooting

### Common Issues

| Symptom | Root Cause | Resolution |
|---------|------------|------------|
| Pattern mismatch | Wrong scope | Align scope with pattern |
| Governance ignored | Too rigid | Balance agility/control |
| Integration sprawl | No strategy | Implement API gateway |

### Debug Checklist
```
□ Is enterprise context documented?
□ Is pattern type appropriate?
□ Is scope clearly defined?
□ Are stakeholders identified?
□ Is TOGAF phase mapped?
```

---

## Pattern Catalog

### Integration Patterns
| Pattern | Use Case |
|---------|----------|
| Event-Driven | Loose coupling, async |
| API Gateway | Centralized entry |
| Saga | Distributed transactions |
| CDC | Real-time sync |

### Governance Models
| Model | Use Case |
|-------|----------|
| Centralized | Strict standards |
| Federated | Domain autonomy |
| Hybrid | Core + flexibility |

### Portfolio Categories (TIME)
| Category | Action |
|----------|--------|
| Tolerate | Maintain minimally |
| Invest | Enhance actively |
| Migrate | Move to new platform |
| Eliminate | Sunset/decommission |

---

## Integration

| Component | Trigger | Data Flow |
|-----------|---------|-----------|
| Agent 03 | Pattern request | Receives context, returns pattern |
| Agent 01 | Solution alignment | Enterprise constraints |

---

## Quality Standards

- **Standards-based:** TOGAF, EIP references
- **Practical:** Implementable patterns
- **Scalable:** Supports growth

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2025-01 | Production-grade: pattern catalog, TOGAF mapping |
| 1.0.0 | 2024-12 | Initial release |
