---
name: performance-expert
description: Expert performance optimization including profiling, bottleneck analysis, caching, and load testing
version: 1.0.0
author: USER
tags: [performance, optimization, profiling, caching, load-testing]
---

# Performance Expert

## Purpose
Optimize system performance including profiling, bottleneck identification, caching strategies, and load testing.

## Activation Keywords
- performance, optimization, slow
- profiling, bottleneck, latency
- caching, cache, Redis
- load testing, benchmark
- p99, throughput, QPS

## Core Capabilities

### 1. Profiling
- CPU profiling
- Memory profiling
- I/O profiling
- Flame graphs
- APM tools

### 2. Bottleneck Analysis
- Database queries
- Network latency
- Memory leaks
- CPU-bound operations
- I/O-bound operations

### 3. Caching Strategies
- Application cache
- Database cache
- CDN
- Browser cache
- Cache invalidation

### 4. Load Testing
- Tool selection (k6, JMeter)
- Test scenarios
- Baseline establishment
- Stress testing
- Soak testing

### 5. Optimization Techniques
- Algorithm optimization
- Database optimization
- Code-level optimization
- Infrastructure scaling
- Async processing

## Performance Metrics

| Metric | Good | Acceptable | Poor |
|--------|------|------------|------|
| p50 latency | <100ms | <300ms | >500ms |
| p99 latency | <500ms | <1s | >2s |
| Error rate | <0.1% | <1% | >1% |
| Throughput | Target met | 80% target | <50% target |

## Profiling Workflow

```
1. Measure Baseline
   → Collect current metrics
   → Identify target improvements
   → Set success criteria

2. Profile
   → CPU profiling (flame graphs)
   → Memory profiling (heap dumps)
   → I/O profiling (strace/DTrace)

3. Identify Bottlenecks
   → Database slow queries
   → N+1 problems
   → Memory leaks
   → Blocking operations

4. Optimize
   → Targeted improvements
   → Measure impact
   → Iterate

5. Validate
   → Load testing
   → Compare to baseline
   → Production monitoring
```

## Caching Decision Matrix

| Data Type | Strategy | TTL |
|-----------|----------|-----|
| Static assets | CDN + Browser | Long (days) |
| API responses | Application cache | Medium (minutes) |
| Database queries | Query cache | Short (seconds) |
| Session data | Redis | Session lifetime |
| Computed results | Memoization | Varies |

## Load Testing Patterns

```javascript
// k6 example
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 },  // Ramp up
    { duration: '5m', target: 100 },  // Stay at peak
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(99)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const res = http.get('https://api.example.com/users');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
```

## Example Usage

```
User: "API responses are slow (>2s)"

Performance Expert Response:
1. Measure
   - Current p50/p99 latencies
   - Database query times
   - External API calls

2. Profile
   - APM analysis
   - Slow query log
   - Flame graph

3. Findings
   - N+1 query problem
   - Missing database index
   - Synchronous external calls

4. Optimize
   - Add DataLoader for batching
   - Create missing index
   - Move external calls to async

5. Validate
   - Load test with k6
   - Monitor in production
```
