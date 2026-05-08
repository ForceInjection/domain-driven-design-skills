---
name: monitoring
description: Game server monitoring with metrics, alerting, and performance tracking for production reliability
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: 08-liveops-specialist
bond_type: PRIMARY_BOND

# Parameters
parameters:
  required:
    - metrics_backend
  optional:
    - scrape_interval_s
    - retention_days
  validation:
    metrics_backend:
      type: string
      enum: [prometheus, datadog, cloudwatch, influxdb]
    scrape_interval_s:
      type: integer
      min: 5
      max: 60
      default: 15
    retention_days:
      type: integer
      min: 7
      max: 365
      default: 30

# Retry Configuration
retry_config:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

# Observability
observability:
  logging:
    level: info
    fields: [metric_name, value, labels]
  metrics:
    - name: scrape_duration_seconds
      type: histogram
    - name: metrics_collected
      type: counter
---

# Server Monitoring

Monitor **game server health** with metrics, logs, and alerts.

## Key Game Metrics

```javascript
const prometheus = require('prom-client');

// Player metrics
const activePlayers = new prometheus.Gauge({
  name: 'game_active_players',
  help: 'Currently connected players',
  labelNames: ['region', 'game_mode']
});

const matchesInProgress = new prometheus.Gauge({
  name: 'game_matches_active',
  help: 'Active matches',
  labelNames: ['game_mode']
});

// Performance metrics
const tickDuration = new prometheus.Histogram({
  name: 'game_tick_duration_seconds',
  help: 'Game loop tick duration',
  buckets: [0.001, 0.005, 0.01, 0.016, 0.033]
});

const networkLatency = new prometheus.Histogram({
  name: 'game_network_latency_ms',
  help: 'Player network latency',
  labelNames: ['region'],
  buckets: [10, 25, 50, 75, 100, 150, 200]
});
```

## Alert Rules

```yaml
groups:
- name: game-alerts
  rules:
  - alert: GameServerDown
    expr: up{job="game-servers"} == 0
    for: 1m
    labels:
      severity: critical

  - alert: HighTickLatency
    expr: histogram_quantile(0.99, game_tick_duration_seconds) > 0.02
    for: 5m
    labels:
      severity: high

  - alert: LowPlayerCount
    expr: game_active_players < 10
    for: 10m
    labels:
      severity: warning
```

## Target Thresholds

| Metric | Target | Alert |
|--------|--------|-------|
| Tick Rate | 60 Hz | < 55 Hz |
| Latency P99 | < 100ms | > 200ms |
| Memory | < 80% | > 90% |
| CPU | < 70% | > 85% |

## Troubleshooting

### Common Failure Modes

| Error | Root Cause | Solution |
|-------|------------|----------|
| Missing metrics | Scrape failure | Check targets |
| Alert storms | Too sensitive | Tune thresholds |
| Dashboard slow | Too many queries | Aggregate |
| Gaps in data | Network issues | Add redundancy |

### Debug Checklist

```bash
# Check Prometheus targets
curl localhost:9090/api/v1/targets | jq '.data.activeTargets'

# Check firing alerts
curl localhost:9090/api/v1/alerts | jq '.data.alerts'

# Query metrics
curl 'localhost:9090/api/v1/query?query=game_active_players'
```

## Unit Test Template

```javascript
describe('Metrics', () => {
  test('records tick duration', async () => {
    const end = tickDuration.startTimer();
    await sleep(10);
    end();

    const metrics = await prometheus.register.metrics();
    expect(metrics).toContain('game_tick_duration_seconds');
  });
});
```

## Resources

- `assets/` - Dashboard configs
- `references/` - Alerting guides
