---
name: performance-test-planning
description: Design performance test strategies including load profiles, capacity planning, SLA validation, and .NET performance testing with NBomber and k6.
allowed-tools: Read, Write, Glob, Grep, Task, WebSearch, WebFetch
---

# Performance Test Planning

## When to Use This Skill

Use this skill when:

- **Performance Test Planning tasks** - Designing load profiles, capacity planning, SLA validation
- **Planning or design** - Need guidance on performance testing approaches
- **Best practices** - Want to follow established patterns and standards

## Overview

Performance testing validates that systems meet non-functional requirements under expected and peak loads. Effective planning identifies critical paths, defines realistic load profiles, and establishes measurable success criteria.

---

## Performance Test Types

| Type | Purpose | Load Pattern | Duration |
|------|---------|--------------|----------|
| **Load Test** | Validate expected load | Normal traffic | 15-60 min |
| **Stress Test** | Find breaking point | Increasing until failure | Until failure |
| **Soak Test** | Find memory leaks | Sustained normal load | 4-24 hours |
| **Spike Test** | Handle sudden bursts | Sharp increase/decrease | 10-30 min |
| **Capacity Test** | Determine max capacity | Incremental increase | Variable |
| **Scalability Test** | Validate horizontal scale | Increasing with resources | Variable |

---

## Load Profile Patterns

### Ramp-Up Pattern

```text
Users
  │
100├────────────────────────●
  │                   ●────
  │              ●────
50├         ●────
  │    ●────
  │●────
 0└─────────────────────────►
   0    1    2    3    4    5 min
```

### Spike Pattern

```text
Users
  │         ●
  │        ╱ ╲
500├──────╱   ╲──────
  │     ╱     ╲
  │    ╱       ╲
100├───●         ●───
  │
 0└─────────────────────────►
   0   5   10  15  20 min
```

---

## Quick Reference: Metrics Targets

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Response Time (p50) | < 100ms | < 200ms |
| Response Time (p95) | < 200ms | < 500ms |
| Response Time (p99) | < 500ms | < 1000ms |
| Throughput | > 1000 RPS | > 500 RPS |
| Error Rate | < 0.1% | < 1% |
| CPU Utilization | < 70% | < 90% |

---

## Key Formulas

**Little's Law:** `L = λ × W` (Concurrent requests = Arrival rate × Response time)

**Throughput:** `Concurrent Users / Average Response Time`

**Apdex:** `(Satisfied + Tolerating/2) / Total`

---

## References

| Reference | Content | When to Load |
| --- | --- | --- |
| [performance-strategy-template.md](references/performance-strategy-template.md) | Full strategy template, scope, environment, scenarios | Planning performance test strategy |
| [nbomber-examples.md](references/nbomber-examples.md) | Basic load test, complex scenarios, data-driven tests | Implementing .NET performance tests |
| [capacity-planning.md](references/capacity-planning.md) | Little's Law, throughput, Apdex, BenchmarkDotNet | Capacity planning calculations |

---

## Integration Points

**Inputs from**:

- Non-functional requirements → SLA targets
- Architecture documents → Component topology
- `test-strategy-planning` skill → Test scope

**Outputs to**:

- CI/CD pipeline → Automated performance gates
- Monitoring systems → Baseline metrics
- Capacity planning → Infrastructure sizing

---

## Test Scenarios

### Scenario 1: Planning performance strategy

**Query:** "Help me create a performance test plan for our API"

**Expected:** Skill activates, provides strategy template, guides through objectives and scope

### Scenario 2: Implementing load tests

**Query:** "Show me how to use NBomber for load testing in .NET"

**Expected:** Skill activates, loads nbomber-examples.md reference, provides code examples

### Scenario 3: Capacity planning

**Query:** "How do I calculate capacity requirements for 10,000 users?"

**Expected:** Skill activates, loads capacity-planning.md reference, provides formulas and templates

---

**Last Updated:** 2025-12-28

## Version History

- **v1.1.0** (2025-12-28): Refactored to progressive disclosure - extracted templates/examples to references/
- **v1.0.0** (2025-12-26): Initial release
