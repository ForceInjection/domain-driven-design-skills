---
name: running-performance-benchmarks
description: Use this skill when running performance benchmarks, measuring API endpoint response times, detecting performance regressions, running load tests, comparing performance before/after changes, analyzing performance trends, or validating optimization improvements. Handles baseline comparisons, historical tracking, and report generation.
---

You are an expert at performance benchmarking for the UFC Pokedex project. You leverage existing benchmark infrastructure while adding regression detection, historical analysis, and comprehensive reporting.

# When to Use This Skill

Invoke this skill when the user wants to:
- Run performance benchmarks
- Measure API endpoint response times
- Detect performance regressions
- Compare performance before/after code changes
- Run load tests with concurrent requests
- Analyze performance trends over time
- Validate optimization improvements
- Generate performance reports

# Existing Benchmark Infrastructure

## Backend Benchmark Script

**Location:** `scripts/benchmark_performance.sh`

**What it tests:**
1. **Fighter List** (first 20) - Tests pagination performance
2. **Search by Division** (Welterweight) - Tests division index
3. **Search by Stance** (Orthodox) - Tests stance index
4. **Search with Win Streak** - Tests computed streak filtering
5. **Fighter Detail** (with fight history) - Tests event_date index

**Baseline Expectations:**
- Fighter List: **< 100ms** (baseline: ~500ms pre-optimization)
- Search by Division: **< 100ms** (baseline: ~500ms)
- Search by Stance: **< 100ms** (baseline: ~500ms)
- Fighter Detail: **< 50ms** (baseline: ~200ms)

## Frontend Benchmark

**Location:** `frontend/scripts/benchmarks/tanstack-query-benchmark.cjs`

**What it tests:**
- TanStack Query caching effectiveness
- Sequential vs cached fetch performance
- Network call reduction

## Results Storage

**Location:** `.benchmarks/` directory

**Format:** Store results as timestamped JSON files
- Example: `.benchmarks/2025-11-05_12-30-45_postgresql.json`

# Benchmark Workflows

## Workflow 1: Quick Benchmark

**User requests:**
- "Run performance benchmarks"
- "Benchmark the API"
- "Check current performance"

**Steps:**
```bash
# 1. Ensure backend is running
if ! lsof -ti :8000 > /dev/null; then
    echo "Backend not running. Starting..."
    make api &
    sleep 5
fi

# 2. Run benchmark script
bash scripts/benchmark_performance.sh

# 3. Save results
# Parse output and save to .benchmarks/YYYY-MM-DD_HH-MM-SS_<backend>.json

# 4. Compare to baseline
# Check if endpoints meet target times (<100ms, <50ms)

# 5. Compare to last run (if exists)
# Find most recent file in .benchmarks/
# Calculate % difference for each endpoint

# 6. Report findings
# Show: Current times, baseline comparison, regression status
```

**Output format:**
```
=== Performance Benchmark Results ===
Date: 2025-11-05 12:30:45
Backend: PostgreSQL
Git commit: abc123def456

Endpoint                  Time (ms)  Target   Status    vs Last Run
---------------------------------------------------------------------------
Fighter List (20)            45      <100ms   ✅ PASS   -5ms (-10%)
Search by Division           82      <100ms   ✅ PASS   +2ms (+2%)
Search by Stance             78      <100ms   ✅ PASS   -1ms (-1%)
Search with Win Streak      125      N/A      ⚠️ SLOW   +15ms (+14%)
Fighter Detail               32      <50ms    ✅ PASS   -3ms (-9%)

Overall: ✅ 4/5 passed baseline targets
Regressions: ⚠️ Win Streak search 14% slower (needs investigation)
```

## Workflow 2: Before/After Comparison

**User requests:**
- "Benchmark before and after my changes"
- "Compare performance before optimization"
- "Tag this as baseline"

**Steps:**
```bash
# 1. Run initial benchmark
bash scripts/benchmark_performance.sh

# 2. Save with "before" tag
# .benchmarks/2025-11-05_12-00-00_before.json

# 3. Wait for user to make changes
# (User makes code changes, database optimizations, etc.)

# 4. Run benchmark again
bash scripts/benchmark_performance.sh

# 5. Save with "after" tag
# .benchmarks/2025-11-05_12-30-00_after.json

# 6. Generate comparison report
# Calculate improvement percentages
# Highlight significant changes (>20% improvement or >10% regression)
```

**Output format:**
```
=== Before/After Performance Comparison ===

Endpoint                  Before    After     Δ Time    Δ %        Verdict
---------------------------------------------------------------------------------
Fighter List (20)         120ms     45ms      -75ms     -62.5%     🚀 IMPROVED
Search by Division        150ms     82ms      -68ms     -45.3%     🚀 IMPROVED
Search by Stance          140ms     78ms      -62ms     -44.3%     🚀 IMPROVED
Search with Win Streak    200ms     125ms     -75ms     -37.5%     🚀 IMPROVED
Fighter Detail            60ms      32ms      -28ms     -46.7%     🚀 IMPROVED

Overall: 🚀 All endpoints improved significantly!
Average improvement: 47.3%

Phase 1 optimization: SUCCESS ✅
- Division/Stance indexes working effectively
- Target metrics achieved on all endpoints
```

## Workflow 3: Load Testing

**User requests:**
- "Run load tests"
- "Test with concurrent requests"
- "How many requests per second can it handle?"

**Steps:**
```bash
# 1. Ensure backend is running with production-like data
# Check fighter count: should be >1000 for realistic testing

# 2. Run Apache Bench tests
# Start with low concurrency, increase gradually

# Test 1: Low concurrency (baseline)
ab -n 100 -c 1 http://localhost:8000/fighters/?limit=20

# Test 2: Moderate concurrency
ab -n 1000 -c 10 http://localhost:8000/fighters/?limit=20

# Test 3: High concurrency
ab -n 1000 -c 50 http://localhost:8000/fighters/?limit=20

# Test 4: Stress test
ab -n 1000 -c 100 http://localhost:8000/fighters/?limit=20

# 3. Parse results
# Extract: Requests/sec, Mean time, 95th percentile, Failed requests

# 4. Test other critical endpoints
# Repeat for search endpoints, fighter detail

# 5. Generate load test report
```

**Output format:**
```
=== Load Test Results ===

Endpoint: /fighters/?limit=20
Database: PostgreSQL (2000 fighters)

Concurrency  Requests  Req/sec  Mean (ms)  95th %ile  Failed
---------------------------------------------------------------
1            100       45.2     22.1       25.0       0
10           1000      234.5    42.7       55.0       0
50           1000      421.8    118.5      145.0      0
100          1000      398.2    251.2      320.0      0

Analysis:
✅ System stable up to 50 concurrent users
⚠️ Performance degrades at 100 concurrent (mean latency >250ms)
✅ No failed requests - error handling robust
💡 Recommendation: Add connection pooling if expecting >50 concurrent users

Breaking point: ~80 concurrent users (estimated)
Recommended max concurrency: 50 users
```

## Workflow 4: Regression Detection

**User requests:**
- "Check for performance regressions"
- "Has performance gotten worse?"
- "Compare to last benchmark"

**Steps:**
```bash
# 1. Find two most recent benchmark results
# .benchmarks/2025-11-05_12-00-00.json (latest)
# .benchmarks/2025-11-04_15-30-00.json (previous)

# 2. Compare all endpoints
# Calculate % difference

# 3. Flag regressions
# Regression = >10% slower
# Warning = 5-10% slower
# Acceptable = <5% change
# Improvement = >20% faster

# 4. Identify potential causes
# Check git commits between benchmarks
# Look for schema changes, query modifications

# 5. Report findings with recommendations
```

**Output format:**
```
=== Regression Detection Report ===

Comparing:
- Latest:   2025-11-05 12:00:00 (commit abc123)
- Previous: 2025-11-04 15:30:00 (commit def456)

Endpoint                  Latest    Previous   Δ        Status
------------------------------------------------------------------------
Fighter List (20)         45ms      43ms       +2ms     ✅ OK (+4.7%)
Search by Division        82ms      80ms       +2ms     ✅ OK (+2.5%)
Search by Stance          78ms      75ms       +3ms     ✅ OK (+4.0%)
Search with Win Streak    145ms     125ms      +20ms    ❌ REGRESSION (+16%)
Fighter Detail            32ms      31ms       +1ms     ✅ OK (+3.2%)

Regressions Found: 1
Warnings: 0
Improvements: 0

🚨 REGRESSION DETECTED: Search with Win Streak
  - 16% slower (145ms vs 125ms)
  - Commits since last benchmark:
    * abc123 - "Add streak computation caching"
    * def123 - "Refactor search filters"

Recommendations:
1. Use performance-investigator sub-agent to analyze Win Streak query
2. Check if streak computation caching is working correctly
3. Run EXPLAIN ANALYZE on the search query
4. Consider reverting commit abc123 if issue persists
```

## Workflow 5: Historical Analysis

**User requests:**
- "Show performance trends over time"
- "How has performance changed?"
- "Performance history for last month"

**Steps:**
```bash
# 1. Read all benchmark files in .benchmarks/
# Sort by timestamp

# 2. Extract data for each endpoint over time
# Build time series for each endpoint

# 3. Calculate statistics
# - Average response time
# - Best/worst times
# - Trend (improving/degrading/stable)
# - Volatility

# 4. Identify inflection points
# When did performance significantly change?

# 5. Generate trend report with visualization
```

**Output format:**
```
=== Performance Trend Analysis ===
Period: Last 30 days (15 benchmark runs)

Fighter List (/fighters/?limit=20):
  Average: 52ms
  Best: 38ms (2025-11-01)
  Worst: 120ms (2025-10-15 - before Phase 1 optimization)
  Trend: ⬇️ IMPROVING (-62% since Oct 15)
  Volatility: LOW (±5ms)

Search by Division:
  Average: 85ms
  Best: 75ms (2025-11-03)
  Worst: 150ms (2025-10-15 - before Phase 1 optimization)
  Trend: ⬇️ IMPROVING (-43% since Oct 15)
  Volatility: LOW (±8ms)

Fighter Detail:
  Average: 34ms
  Best: 28ms (2025-11-02)
  Worst: 60ms (2025-10-15 - before Phase 1 optimization)
  Trend: ⬇️ IMPROVING (-43% since Oct 15)
  Volatility: LOW (±4ms)

Key Events:
📈 Oct 15: Baseline measurements (before optimization)
🚀 Oct 18: Phase 1 indexes deployed (685cededf16b)
✅ Oct 20: Performance targets achieved
📊 Oct 25-Nov 5: Stable performance maintained

Overall Verdict: ✅ HEALTHY
- All endpoints consistently meet targets
- Low volatility indicates stable performance
- Phase 1 optimizations effective and sustained
```

# Database Backend Considerations

## PostgreSQL vs SQLite

The UFC Pokedex supports both backends with different performance characteristics:

### PostgreSQL (Production)
- **Dataset:** 2000+ fighters, 50,000+ fights
- **Indexes:** Full index suite (division, stance, event_date, etc.)
- **Concurrency:** High (multiple concurrent requests)
- **Performance:** Optimized with indexes and caching

**Benchmark with:**
```bash
# Ensure PostgreSQL is running
docker-compose up -d
make api

# Run benchmarks
bash scripts/benchmark_performance.sh
```

### SQLite (Development)
- **Dataset:** Limited (8-100 fighters recommended)
- **Indexes:** Same schema but smaller dataset
- **Concurrency:** Low (single-writer limitations)
- **Performance:** Fast for small datasets, not representative of production

**Benchmark with:**
```bash
# Use SQLite mode
USE_SQLITE=1 make api:dev

# Run benchmarks
API_BASE=http://localhost:8000 bash scripts/benchmark_performance.sh
```

**Note:** SQLite benchmarks are useful for development but don't represent production performance. Always validate optimizations on PostgreSQL with production-sized data.

# Result Storage Format

Store benchmark results as JSON in `.benchmarks/` directory:

**Filename format:** `YYYY-MM-DD_HH-MM-SS_<backend>_<tag>.json`

Examples:
- `.benchmarks/2025-11-05_12-30-45_postgresql.json`
- `.benchmarks/2025-11-05_12-00-00_before.json`
- `.benchmarks/2025-11-05_12-30-00_after.json`

**JSON structure:**
```json
{
  "timestamp": "2025-11-05T12:30:45Z",
  "backend": "postgresql",
  "git_commit": "abc123def456",
  "fighter_count": 2000,
  "fight_count": 50000,
  "endpoints": [
    {
      "name": "fighter_list",
      "url": "/fighters/?limit=20&offset=0",
      "time_ms": 45.2,
      "status_code": 200,
      "baseline_target_ms": 100,
      "passed": true
    },
    {
      "name": "search_division",
      "url": "/search/?q=&division=Welterweight",
      "time_ms": 82.1,
      "status_code": 200,
      "baseline_target_ms": 100,
      "passed": true
    }
  ],
  "load_tests": [
    {
      "endpoint": "/fighters/?limit=20",
      "concurrency": 10,
      "total_requests": 1000,
      "requests_per_second": 234.5,
      "mean_time_ms": 42.7,
      "percentile_95_ms": 55.0,
      "failed_requests": 0
    }
  ],
  "summary": {
    "endpoints_tested": 5,
    "endpoints_passed": 4,
    "endpoints_failed": 1,
    "average_time_ms": 76.4,
    "regressions_detected": 1
  }
}
```

# Integration with Other Tools

## performance-investigator Sub-Agent

When benchmarks reveal issues, delegate to `performance-investigator`:

**Workflow:**
1. **Benchmark detects regression** - "Search with Win Streak is 16% slower"
2. **Suggest investigation** - "Use performance-investigator to analyze"
3. **User invokes sub-agent** - Deep dive into query performance
4. **Apply fixes** - Add index, optimize query, enable caching
5. **Re-benchmark** - Validate improvement

**Example:**
```
Benchmark shows: Search with Win Streak: 145ms (was 125ms)

Recommendation:
"Use the performance-investigator sub-agent to analyze the Win Streak search query:

  Use performance-investigator to analyze why /search/?q=&streak_type=win&min_streak_count=3 is slow

Then re-run benchmarks to validate the fix."
```

## Makefile Integration

Add benchmark targets to Makefile:

```makefile
benchmark: ## Run performance benchmarks
	bash scripts/benchmark_performance.sh

benchmark-save: ## Run benchmarks and save results
	# (Invoke this skill to handle saving and analysis)

benchmark-load: ## Run load tests
	# (Invoke this skill with load testing workflow)
```

# Best Practices

## When to Benchmark

1. **Before/After Optimizations** - Validate improvements
2. **Before Releases** - Ensure no regressions
3. **After Schema Changes** - Check index effectiveness
4. **After Dependency Updates** - Catch framework regressions
5. **Weekly** - Track trends and catch gradual degradation

## Benchmarking Guidelines

1. **Consistent Environment**
   - Use same dataset size
   - Use same backend (PostgreSQL for production comparisons)
   - Close unnecessary applications
   - Run during low system load

2. **Multiple Runs**
   - Run benchmark 3 times, take median
   - Discard outliers (first run may be cold cache)
   - Look for consistency (low variance)

3. **Production-Like Data**
   - Use full dataset (2000+ fighters)
   - Include fight history (50,000+ fights)
   - Test with realistic query patterns

4. **Document Context**
   - Record git commit
   - Note system changes (OS updates, etc.)
   - Tag significant benchmarks ("before Phase 1", "after cache")

## Interpreting Results

**Good Performance:**
- All endpoints meet baseline targets
- Low variance across runs (<10%)
- No regressions vs previous runs
- Load tests show stable behavior up to expected concurrency

**Warning Signs:**
- Endpoints close to baseline limits (within 10%)
- High variance (>20% difference between runs)
- Small regressions (5-10% slower)
- Load tests show degradation at moderate concurrency

**Critical Issues:**
- Endpoints exceed baseline by >20%
- Regressions >15%
- Failed requests in load tests
- Performance degrades at low concurrency (<10 users)

# Common Scenarios

## Scenario 1: Validating Index Addition

**Context:** Added index on `fighters.division`

**Steps:**
```bash
# 1. Benchmark before migration
# Tag as "before_division_index"

# 2. Run migration
make db-upgrade

# 3. Benchmark after migration
# Tag as "after_division_index"

# 4. Compare
# Expect: Search by Division 40-60% faster
```

**Expected improvement:** Search by Division from ~150ms to <100ms

## Scenario 2: Detecting Query Regression

**Context:** Refactored search logic

**Steps:**
```bash
# 1. Run benchmark after changes

# 2. Compare to last run
# Notice: Search endpoints 20% slower

# 3. Investigate with performance-investigator

# 4. Identify issue: Missing eager loading

# 5. Fix and re-benchmark
```

## Scenario 3: Load Testing for Deployment

**Context:** Preparing for production deploy

**Steps:**
```bash
# 1. Benchmark with production data size

# 2. Run load tests with expected concurrency
# Expected: 20-50 concurrent users

# 3. Identify breaking points

# 4. Adjust connection pool if needed

# 5. Re-test and validate
```

# Quick Reference

```bash
# Run basic benchmark
bash scripts/benchmark_performance.sh

# Run with custom API base
API_BASE=https://api.ufc.wolfgangschoenberger.com bash scripts/benchmark_performance.sh

# Run load test (1000 requests, 10 concurrent)
ab -n 1000 -c 10 http://localhost:8000/fighters/?limit=20

# Run load test (silent, just summary)
ab -q -n 1000 -c 10 http://localhost:8000/fighters/?limit=20

# Check stored benchmarks
ls -lh .benchmarks/

# View latest benchmark
cat .benchmarks/$(ls -t .benchmarks/ | head -1)

# Count benchmarks
ls .benchmarks/ | wc -l

# Get current git commit
git rev-parse --short HEAD
```

# Limitations

- **Manual script execution** - Benchmark script is shell-based, not automated
- **No CI/CD integration** - Results not automatically tracked in CI
- **Limited load testing** - Apache Bench only (no distributed load testing)
- **No frontend benchmarks** - TanStack Query benchmark exists but not integrated
- **No alerting** - No automatic alerts on regressions
- **No visualization** - Results are text-based (no charts/graphs)

# Future Enhancements

- Automated benchmark runs in GitHub Actions
- Slack/email alerts on regressions
- Web-based dashboard with charts
- Distributed load testing with k6 or Locust
- Frontend performance benchmarks (Lighthouse, WebPageTest)
- Database query profiling integration
- Memory usage tracking
- API response size tracking

---

**Remember:** Performance benchmarking is most valuable when done consistently over time. Run benchmarks regularly and track trends to catch regressions early!
