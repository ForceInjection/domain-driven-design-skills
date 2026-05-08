---
name: performance-testing-standards
description: >
  Performance testing standards for load, stress, spike, and soak testing.
  Covers k6 and JMeter implementation, SLI/SLO definitions, CI/CD integration,
  and bottleneck analysis. Use when validating system behavior under load,
  establishing baselines, or capacity planning.
---

# Performance Testing Standards

## Level 1: Quick Reference

### Core Concepts

**Performance Test Types:**

1. **Load Testing**: Validate system behavior under expected load
2. **Stress Testing**: Find breaking point and failure modes
3. **Spike Testing**: Validate sudden traffic surge handling
4. **Soak Testing**: Verify stability under sustained load
5. **Breakpoint Testing**: Incrementally increase load to find limits

**Key Metrics:**

- **Latency Percentiles**: p50 (median), p95, p99, p99.9
- **Throughput**: Requests per second (RPS)
- **Error Rate**: Percentage of failed requests
- **Concurrent Users**: Virtual users (VUs) active simultaneously
- **Resource Utilization**: CPU, memory, disk I/O, network

**Critical Success Indicators:**

- p95 latency < SLO threshold
- Error rate < 0.1%
- System stability during sustained load
- Graceful degradation under stress
- Recovery after traffic spikes

### Quick Metrics Reference

| Metric | Good | Warning | Critical |
|--------|------|---------|----------|
| p50 latency | < 100ms | 100-200ms | > 200ms |
| p95 latency | < 500ms | 500-1000ms | > 1000ms |
| p99 latency | < 1s | 1-2s | > 2s |
| Error rate | < 0.1% | 0.1-1% | > 1% |
| CPU usage | < 60% | 60-80% | > 80% |
| Memory usage | < 70% | 70-85% | > 85% |

### Quick Start: k6 Load Test

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 50 },   // Ramp-up
    { duration: '5m', target: 50 },   // Steady state
    { duration: '2m', target: 0 },    // Ramp-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const res = http.get('https://api.example.com/health');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
```

**Run:** `k6 run load-test.js`

---

## Level 2: Implementation Guide

### 1. Test Strategy & Planning

#### Define Performance Requirements

```yaml
# performance-requirements.yaml
service: user-api
environment: production

slis:
  availability:
    target: 99.9%
  latency:
    p50: 100ms
    p95: 500ms
    p99: 1000ms
  throughput:
    target: 1000 rps
  error_rate:
    target: 0.1%

critical_user_journeys:
  - name: user_login
    weight: 30%
    slo_p95: 300ms
  - name: fetch_dashboard
    weight: 40%
    slo_p95: 500ms
  - name: submit_transaction
    weight: 20%
    slo_p95: 1000ms
```

#### Load Profile Patterns

```javascript
// 1. Ramp-Up Pattern
export const rampUpOptions = {
  stages: [
    { duration: '5m', target: 100 },
    { duration: '10m', target: 100 },
    { duration: '5m', target: 200 },
    { duration: '10m', target: 200 },
    { duration: '5m', target: 0 },
  ],
};

// 2. Stress Test Pattern
export const stressOptions = {
  stages: [
    { duration: '2m', target: 200 },
    { duration: '5m', target: 200 },
    { duration: '2m', target: 400 },
    { duration: '5m', target: 400 },
    { duration: '10m', target: 0 },
  ],
};

// 3. Spike Test Pattern
export const spikeOptions = {
  stages: [
    { duration: '1m', target: 50 },
    { duration: '10s', target: 500 },
    { duration: '3m', target: 500 },
    { duration: '10s', target: 50 },
    { duration: '3m', target: 50 },
  ],
};

// 4. Soak Test Pattern
export const soakOptions = {
  stages: [
    { duration: '5m', target: 100 },
    { duration: '4h', target: 100 },
    { duration: '5m', target: 0 },
  ],
};
```

### 2. k6 Implementation

#### Advanced Test Structure

```javascript
import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const customTrend = new Trend('custom_duration');

export const options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '2m', target: 0 },
  ],
  thresholds: {
    'http_req_duration': ['p(95)<500', 'p(99)<1000'],
    'http_req_duration{type:api}': ['p(95)<300'],
    'http_req_failed': ['rate<0.01'],
    'errors': ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://api.example.com';

export function setup() {
  const loginRes = http.post(`${BASE_URL}/auth/login`, {
    username: 'test-user',
    password: 'test-password',
  });
  return { token: loginRes.json('token') };
}

export default function (data) {
  const params = {
    headers: {
      'Authorization': `Bearer ${data.token}`,
      'Content-Type': 'application/json',
    },
    tags: { type: 'api' },
  };

  group('Login Flow', () => {
    const res = http.get(`${BASE_URL}/api/user/profile`, params);
    const success = check(res, {
      'status is 200': (r) => r.status === 200,
      'has user data': (r) => r.json('id') !== undefined,
    });
    errorRate.add(!success);
  });

  sleep(1);

  group('Dashboard Load', () => {
    const responses = http.batch([
      ['GET', `${BASE_URL}/api/dashboard/summary`, null, params],
      ['GET', `${BASE_URL}/api/notifications`, null, params],
    ]);
    responses.forEach((res) => {
      check(res, { 'status is 200': (r) => r.status === 200 });
    });
  });

  sleep(2);
}

export function handleSummary(data) {
  return {
    'summary.json': JSON.stringify(data),
  };
}
```

### 3. JMeter Implementation

**Run JMeter from CLI:**

```bash
# Run test plan
jmeter -n -t test-plan.jmx \
  -Jbase_url=https://api.example.com \
  -Jusers=200 \
  -l results.jtl \
  -e -o report/

# Generate HTML report from existing results
jmeter -g results.jtl -o report/
```

See REFERENCE.md for complete JMeter test plan XML structure.

### 4. SLI/SLO Framework

```yaml
# slo-definitions.yaml
service: user-api

slis:
  - name: availability
    query: "sum(rate(http_requests_total{status=~'2..'}[5m])) / sum(rate(http_requests_total[5m]))"
  - name: latency_p95
    query: "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
  - name: error_rate
    query: "sum(rate(http_requests_total{status=~'5..'}[5m])) / sum(rate(http_requests_total[5m]))"

slos:
  - sli: availability
    target: 99.9
    unit: percent
    window: 30d
  - sli: latency_p95
    target: 500
    unit: milliseconds
  - sli: error_rate
    target: 0.1
    unit: percent

error_budget:
  availability_budget: 43.2m  # 99.9% uptime = 43.2 min downtime/month
  burn_rate_alert: 10x
```

### 5. CI/CD Integration

```yaml
# .github/workflows/performance-test.yml
name: Performance Testing

on:
  schedule:
    - cron: '0 2 * * *'
  workflow_dispatch:
    inputs:
      duration:
        description: 'Test duration (minutes)'
        default: '10'
      vus:
        description: 'Virtual users'
        default: '100'

jobs:
  performance-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install k6
        run: |
          sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
          echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
          sudo apt-get update && sudo apt-get install k6

      - name: Run Load Test
        env:
          BASE_URL: ${{ secrets.PERF_TEST_URL }}
        run: |
          k6 run --out json=results.json \
            --summary-export=summary.json \
            tests/performance/load-test.js

      - name: Parse Results
        id: results
        run: |
          p95=$(jq -r '.metrics.http_req_duration.values["p(95)"]' summary.json)
          error_rate=$(jq -r '.metrics.http_req_failed.values.rate' summary.json)
          echo "p95_latency=$p95" >> $GITHUB_OUTPUT
          echo "error_rate=$error_rate" >> $GITHUB_OUTPUT
          if (( $(echo "$p95 > 500" | bc -l) )); then exit 1; fi
          if (( $(echo "$error_rate > 0.01" | bc -l) )); then exit 1; fi

      - name: Upload Results
        uses: actions/upload-artifact@v3
        with:
          name: performance-results
          path: |
            results.json
            summary.json
```

### 6. Profiling & Bottleneck Analysis

```bash
# Node.js profiling with clinic.js
npm install -g clinic
clinic flame -- node server.js
clinic bubbleprof -- node server.js
clinic doctor -- node server.js
```

```sql
-- PostgreSQL: Enable query logging
ALTER DATABASE mydb SET log_min_duration_statement = 100;

-- Identify slow queries
SELECT query, calls, total_time, mean_time, max_time
FROM pg_stat_statements
ORDER BY mean_time DESC LIMIT 20;
```

### Essential Checklists

**Before Testing:**

- Define SLIs/SLOs
- Identify critical user journeys
- Set up monitoring (APM, metrics, logs)
- Establish baseline performance
- Prepare production-like test environment

**During Testing:**

- Monitor system resources in real-time
- Track error logs and exceptions
- Validate data integrity
- Document anomalies and failures

**After Testing:**

- Analyze latency distributions
- Identify performance bottlenecks
- Compare against SLOs
- Generate executive summary
- Create remediation plan

---

## Level 3: Deep Dive Resources

### Official Documentation

- [k6 Documentation](https://k6.io/docs/)
- [Apache JMeter User Manual](https://jmeter.apache.org/usermanual/)
- [Gatling Documentation](https://gatling.io/docs/)
- [Locust Documentation](https://locust.io/)

### Tools

**Load Testing:** k6, Apache JMeter, Gatling, Locust, Artillery

**APM & Monitoring:** Prometheus + Grafana, Datadog APM, New Relic, Elastic APM

**Profiling:** Clinic.js (Node.js), py-spy (Python), pprof (Go)

### Bundled Resources

This skill includes resources in the `templates/` and `config/` directories:

1. **templates/k6-load-test.js** - Production-ready k6 load test
2. **templates/k6-stress-test.js** - k6 stress testing script
3. **config/jmeter-test-plan.jmx** - JMeter test plan template
4. **templates/grafana-dashboard.json** - Performance monitoring dashboard
5. **scripts/run-perf-tests.sh** - Automated test execution script

### Extended Reference

See **REFERENCE.md** for:

- Complete JMeter test plan XML structure
- k6 Prometheus integration example
- Detailed performance metrics definitions
- Full performance report template
- Network trace analysis commands
- Comprehensive SLI/SLO/SLA framework
- Learning path and competency checklist

---

**Last Updated:** 2025-10-17
**Version:** 2.0.0
