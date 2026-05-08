---
name: redis-performance
description: Master Redis performance - memory optimization, slow log analysis, benchmarking, monitoring, and tuning strategies
sasmp_version: "1.3.0"
bonded_agent: 08-redis-production
bond_type: PRIMARY_BOND

# Production Configuration
version: "2.1.0"
last_updated: "2025-01"

# Parameters
parameters:
  analysis_type:
    type: string
    required: true
    enum: [memory, latency, throughput, slow_queries]

# Retry Configuration
retry_config:
  max_retries: 3
  backoff_strategy: exponential
  backoff_base_ms: 100

# Observability
observability:
  metrics:
    - memory_used_bytes
    - memory_fragmentation_ratio
    - instantaneous_ops_per_sec
    - slowlog_length
---

# Redis Performance Skill

## Memory Management

```conf
maxmemory 4gb
maxmemory-policy allkeys-lru
maxmemory-samples 10
```

### Eviction Policies
| Policy | Description | Use Case |
|--------|-------------|----------|
| noeviction | Error on full | Critical data |
| allkeys-lru | Evict LRU | General cache |
| volatile-lru | Evict LRU with TTL | Session cache |
| allkeys-lfu | Evict LFU | Frequency-based |

### Memory Analysis
```redis
INFO memory
MEMORY DOCTOR
MEMORY USAGE key
MEMORY STATS
redis-cli --bigkeys
```

## Slow Log

```redis
CONFIG SET slowlog-log-slower-than 10000  # 10ms
CONFIG SET slowlog-max-len 128

SLOWLOG GET 10
SLOWLOG LEN
SLOWLOG RESET
```

### Common Slow Commands
| Command | Fix |
|---------|-----|
| KEYS * | Use SCAN |
| SMEMBERS | Use SSCAN |
| HGETALL | Use HMGET |

## Benchmarking

```bash
# Basic
redis-benchmark -q -n 100000

# With pipelining
redis-benchmark -q -n 100000 -P 16

# Specific commands
redis-benchmark -t set,get -n 100000 -q
```

## Latency Monitoring

```redis
CONFIG SET latency-monitor-threshold 100
LATENCY DOCTOR
LATENCY HISTORY command
```

## Key Metrics

| Metric | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| Memory | <75% | 75-90% | >90% |
| Ops/sec | Baseline | +50% | +100% |
| Latency | <1ms | 1-10ms | >10ms |
| Hit ratio | >95% | 90-95% | <90% |

## Assets
- `performance-config.conf` - Optimized config

## References
- `PERFORMANCE_GUIDE.md` - Tuning guide

---

## Troubleshooting

### High Memory
```redis
INFO memory
redis-cli --bigkeys
```
**Fix:** Set eviction policy, add TTL

### High Latency
```redis
SLOWLOG GET 10
LATENCY DOCTOR
```
**Fix:** Optimize slow commands

---

## Error Codes

| Code | Name | Recovery |
|------|------|----------|
| PERF001 | OOM | Increase maxmemory or evict |
| PERF002 | HIGH_LAT | Check slow log |
| PERF003 | FRAG | MEMORY PURGE or restart |
