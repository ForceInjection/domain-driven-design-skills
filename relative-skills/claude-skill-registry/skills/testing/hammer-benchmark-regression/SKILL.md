---
name: hammer-benchmark-regression
description: Runs performance benchmarks for SDL3 HammerEngine and detects regressions by comparing metrics against baseline. Use when testing performance-sensitive changes to AI, collision, pathfinding, particle systems, or before merging features to ensure no performance degradation.
allowed-tools: [Bash, Read, Write, Grep]
---

# HammerEngine Performance Regression Detection

This Skill is **critical** for SDL3 HammerEngine's performance requirements. The engine must maintain 10,000+ entity support at 60+ FPS with minimal CPU usage. This Skill detects performance regressions before they reach production.

## Performance Requirements (from CLAUDE.md)

- **AI System:** 10,000+ entities at 60+ FPS with <6% CPU
- **Collision System:** Spatial hash with efficient AABB detection
- **Pathfinding:** A* pathfinding with dynamic weights
- **Event System:** 1K-10K event throughput
- **Particle System:** Camera-aware batched rendering

## Workflow Overview

**⚠️ CRITICAL: AI Scaling Benchmark is MANDATORY**
The AI System is the most performance-critical component. Always run `./tests/test_scripts/run_ai_benchmark.sh` as part of the regression check. DO NOT proceed to report generation without AI benchmark results.

1. **Identify or Create Baseline** - Store previous metrics
2. **Run Benchmark Suite** - Execute ALL 6 performance tests (including AI)
3. **Extract Metrics** - Parse results from test outputs
4. **Compare vs Baseline** - Calculate percentage changes
5. **Flag Regressions** - Alert on performance degradation
6. **Generate Report** - Detailed analysis with recommendations

**Checklist before generating report:**
- [ ] AI Scaling Benchmark completed
- [ ] Collision System Benchmark completed
- [ ] **Pathfinder Benchmark completed** ← CRITICAL: Always verify metrics extracted!
- [ ] Event Manager Scaling completed
- [ ] Particle Manager Benchmark completed
- [ ] UI Stress Tests completed

**Metrics Extraction Verification (MANDATORY):**
- [ ] AI: Synthetic AND Integrated metrics extracted
- [ ] **Pathfinding: Async throughput metrics extracted (NOT immediate timing)** ← PRODUCTION METRIC ONLY!
- [ ] Collision: SOA timing and efficiency extracted
- [ ] Event: Throughput and latency extracted
- [ ] Particle: Update time extracted
- [ ] UI: Processing throughput extracted

## Benchmark Test Suites

### Available Benchmarks (ALL REQUIRED)

**Working Directory:** Use absolute path to project root or set `$PROJECT_ROOT` environment variable.
All paths below are relative to project root.

**IMPORTANT: All 6 benchmarks MUST be run for complete regression analysis.**

1. **AI Scaling Benchmark** (`./bin/debug/ai_scaling_benchmark`) **[REQUIRED - CRITICAL]**
   - Script: `./tests/test_scripts/run_ai_benchmark.sh --both`
   - Tests: Dual benchmark system (synthetic + integrated)
     - **Synthetic**: AIManager infrastructure with BenchmarkBehavior (isolated)
     - **Integrated**: Production behaviors with PathfinderManager/CollisionManager
   - Metrics: Entity updates/sec, threading efficiency, integration overhead
   - Target: Synthetic 1M+ updates/sec, Integrated 1.5M+ updates/sec @ 2K entities
   - Duration: ~20 minutes
   - **Status: CRITICAL - Engine core performance benchmark**

2. **Collision System Benchmark** (`./bin/debug/collision_benchmark`) **[REQUIRED]**
   - Script: `./tests/test_scripts/run_collision_benchmark.sh`
   - Tests: Spatial hash performance, AABB detection, SOA storage
   - Metrics: Collision checks/sec, query time, hash efficiency
   - Duration: ~3 minutes

3. **Pathfinder Benchmark** (`./bin/debug/pathfinder_benchmark`) **[REQUIRED]**
   - Script: `./tests/test_scripts/run_pathfinder_benchmark.sh`
   - Tests: Async pathfinding throughput at scale
   - Metrics: **Async throughput (paths/sec), batch processing performance, success rate**
   - **Note:** Immediate pathfinding deprecated - only track async metrics
   - Duration: ~5 minutes

4. **Event Manager Scaling** (`./bin/debug/event_manager_scaling_benchmark`) **[REQUIRED]**
   - Script: `./tests/test_scripts/run_event_scaling_benchmark.sh`
   - Tests: Event throughput 10-4000 events, concurrency
   - Metrics: Events/sec, dispatch latency, queue depth
   - Duration: ~2 minutes

5. **Particle Manager Benchmark** (`./bin/debug/particle_manager_benchmark`) **[REQUIRED]**
   - Script: `./tests/test_scripts/run_particle_manager_benchmark.sh`
   - Tests: Batch rendering performance, particle updates
   - Metrics: Particles/frame, update time, batch count
   - Duration: ~2 minutes

6. **UI Stress Tests** (`./bin/debug/ui_stress_test`) **[REQUIRED]**
   - Script: `./tests/test_scripts/run_ui_stress_tests.sh`
   - Tests: UI component performance, layout, collision checks
   - Metrics: Processing throughput, iteration time, layout calc/sec
   - Duration: ~1 minute

### Total Benchmark Duration: ~33 minutes

## Execution Steps

### Step 1: Identify Baseline

**Baseline Storage Location:**
```
$PROJECT_ROOT/test_results/baseline/
├── thread_safe_ai_baseline.txt         (AI system baseline)
├── collision_benchmark_baseline.txt
├── pathfinder_benchmark_baseline.txt
├── event_benchmark_baseline.txt
├── particle_manager_baseline.txt
├── buffer_utilization_baseline.txt
├── resource_tests_baseline.txt
├── serialization_baseline.txt
└── baseline_metadata.txt
```

**Baseline Creation Logic:**
```bash
# Check if baseline exists (requires PROJECT_ROOT to be set)
if [ ! -d "$PROJECT_ROOT/test_results/baseline/" ]; then
    echo "No baseline found. Creating baseline from current run..."
    mkdir -p "$PROJECT_ROOT/test_results/baseline/"
    CREATING_BASELINE=true
fi
```

**When to Create New Baseline:**
- No baseline exists (first run)
- User explicitly requests baseline refresh
- Major optimization work completed (intentional performance change)
- After validating improvements (new baseline for future comparisons)

### Step 2: Run Benchmark Suite

**CRITICAL: ALL 6 benchmarks must be run. DO NOT skip the AI benchmark.**

**Run individually (RECOMMENDED - allows better progress tracking):**
```bash
# IMPORTANT: Set PROJECT_ROOT and run from project directory
# Example: cd /path/to/SDL3_HammerEngine_Template && export PROJECT_ROOT=$(pwd)

# 1. AI Scaling Benchmark (REQUIRED - 20 minutes)
# NOTE: Dual benchmark system (synthetic + integrated)
./tests/test_scripts/run_ai_benchmark.sh --both

# 2. Collision System Benchmark (REQUIRED - 3 minutes)
./tests/test_scripts/run_collision_benchmark.sh

# 3. Pathfinder Benchmark (REQUIRED - 5 minutes)
./tests/test_scripts/run_pathfinder_benchmark.sh

# 4. Event Manager Scaling (REQUIRED - 2 minutes)
./tests/test_scripts/run_event_scaling_benchmark.sh

# 5. Particle Manager Benchmark (REQUIRED - 2 minutes)
./tests/test_scripts/run_particle_manager_benchmark.sh

# 6. UI Stress Tests (REQUIRED - 1 minute)
./tests/test_scripts/run_ui_stress_tests.sh
```

**Timeout Protection:**
Each benchmark has timeout protection:
- AI Scaling: 600 seconds (10 minutes)
- Others: 300 seconds (5 minutes)

If timeout occurs, flag as potential infinite loop or performance catastrophe.

**Progress Tracking:**
```
Running benchmarks (this will take ~33 minutes)...
[1/6] AI Scaling Benchmark (Synthetic + Integrated)... ✓ (20m 15s) - CRITICAL
[2/6] Collision System Benchmark... ✓ (3m 12s)
[3/6] Pathfinder Benchmark... ✓ (5m 05s)
[4/6] Event Manager Scaling... ✓ (2m 10s)
[5/6] Particle Manager Benchmark... ✓ (2m 05s)
[6/6] UI Stress Tests... ✓ (1m 02s)
Total: 33m 49s
```

**Execution Order:**
Run benchmarks in the order listed above. AI benchmark should always be run first as it's the most critical system and longest-running test.

### Step 3: Extract Metrics

**Metrics Extraction Patterns:**

#### AI System Metrics (Dual Benchmark System)

**IMPORTANT**: The AI benchmark now separates Synthetic and Integrated tests.

**Synthetic Benchmarks** (AIManager infrastructure):
```bash
# Extract synthetic performance from TestSyntheticPerformance and TestSyntheticScalability
grep -B 5 -A 10 "TestSynthetic" test_results/ai_scaling_benchmark_*.txt | \
  grep -E "Entity updates per second:|Threading mode:|entities"

# Parse SYNTHETIC SCALABILITY SUMMARY table
grep -A 10 "SYNTHETIC.*SCALABILITY.*SUMMARY" test_results/ai_scaling_benchmark_*.txt | \
  grep -E "^[[:space:]]*[0-9]+"
```

**Integrated Benchmarks** (Production behaviors with PathfinderManager):
```bash
# Extract integrated performance from TestIntegratedPerformance and TestIntegratedScalability
grep -B 5 -A 10 "TestIntegrated" test_results/ai_scaling_benchmark_*.txt | \
  grep -E "Entity updates per second:|Threading mode:|entities"

# Parse INTEGRATED SCALABILITY SUMMARY results
grep -A 10 "INTEGRATED.*SCALABILITY.*SUMMARY" test_results/ai_scaling_benchmark_*.txt | \
  grep -E "Entity updates per second"
```

**Example Output:**
```
=== SYNTHETIC BENCHMARKS ===
--- Test 4: Target Performance (5000 entities) ---
  Entity updates per second: 26665482
  Threading mode: WorkerBudget Multi-threaded

SYNTHETIC SCALABILITY SUMMARY:
        5000 |  Auto-Threaded |            925000 |             5.44x
       10000 |  Auto-Threaded |            995000 |             5.85x

=== INTEGRATED BENCHMARKS ===
--- Test 4: Target Performance (2000 entities) ---
  Entity updates per second: 5077323
  Threading mode: WorkerBudget Multi-threaded

INTEGRATED SCALABILITY:
        2000 |  Auto-Threaded |           1587491 |             2.79x
```

**Baseline Key Format:**
- Synthetic: `Synthetic_Entity_<count>_UpdatesPerSec`
- Integrated: `Integrated_Entity_<count>_UpdatesPerSec`

#### Collision System Metrics
```bash
grep -E "Collision Checks:|Query Time:|Hash Efficiency:" test_results/collision_benchmark/performance_metrics.txt
```

**Example Output:**
```
Collision Checks: 125000/sec
Query Time: 0.08ms
Hash Efficiency: 94.2%
AABB Tests: 250000/sec
```

#### Pathfinder Metrics **[ASYNC THROUGHPUT ONLY]**

**⚠️ IMPORTANT:** PathfinderManager uses **async-only pathfinding** in production. Immediate (synchronous) pathfinding is deprecated and should NOT be tracked in regression analysis.

**Production Metrics Extraction:**
```bash
# Extract async pathfinding throughput - PRIMARY METRIC
grep -E "Async.*Throughput|paths/sec" test_results/pathfinder_benchmark_results.txt | \
  grep -E "Throughput:"

# Example output format:
#   Throughput: 3e+02 paths/sec
#   Throughput: 4e+02 paths/sec
#   Throughput: 4e+02 paths/sec
```

**REQUIRED Metrics to Extract:**
1. **Async throughput** (paths/second) - Production metric
2. **Success rate** (must be 100%)
3. **Batch processing performance** (if high-volume scenarios tested)

**DEPRECATED Metrics (DO NOT TRACK):**
- ❌ Immediate pathfinding timing (deprecated, not used in production)
- ❌ Path calculation time by distance (legacy synchronous metric)
- ❌ Per-path latency measurements (not relevant for async architecture)

**Baseline Comparison Keys:**
- `Pathfinding_Async_Throughput_PathsPerSec`
- `Pathfinding_Batch_Processing_Enabled`
- `Pathfinding_SuccessRate`

**Example Baseline Comparison:**
```
| Metric | Baseline | Current | Change | Status |
|--------|----------|---------|--------|--------|
| Async Throughput | 300-400 paths/sec | 300-400 paths/sec | 0% | ⚪ Stable |
| Batch Processing | 50K paths/sec | 100K paths/sec | +100% | 🟢 Major Improvement |
| Success Rate | 100% | 100% | 0% | ✓ Maintained |
```

**What to Report:**
- Always include a dedicated "Pathfinding System" section in regression reports
- Focus on async throughput as primary metric
- Highlight batch processing performance for high-volume scenarios
- Note success rate (failures are critical regressions)
- Exclude deprecated immediate pathfinding metrics from analysis

#### Event Manager Metrics
```bash
grep -E "Events/sec:|Dispatch Latency:|Queue Depth:" test_results/event_manager_scaling/performance_metrics.txt
```

**Example Output:**
```
Events/sec: 8500
Dispatch Latency: 0.12ms
Queue Depth: 128
Peak Throughput: 10000 events/sec
```

#### Particle Manager Metrics
```bash
grep -E "Particles/frame:|Render Time:|Batch Count:" test_results/particle_benchmark/performance_metrics.txt
```

**Example Output:**
```
Particles/frame: 5000
Render Time: 3.2ms
Batch Count: 12
Culling Efficiency: 88%
```

#### UI Metrics
```bash
grep -E "Render Time:|Event Handling:|Components:" test_results/ui_stress/performance_metrics.txt
```

**Example Output:**
```
Components: 1000
Render Time: 4.5ms
Event Handling: 0.3ms
DPI Scaling: 60 FPS
```

### Step 4: Compare Against Baseline

**Comparison Algorithm:**

For each metric:
1. Read baseline value
2. Read current value
3. Calculate percentage change: `((current - baseline) / baseline) * 100`
4. Determine status:
   - **Regression:** Slower/worse performance
   - **Improvement:** Faster/better performance
   - **Stable:** Within noise threshold (±5%)

**Example Comparison:**

| System | Metric | Baseline | Current | Change | Status |
|--------|--------|----------|---------|--------|--------|
| AI | FPS | 62.3 | 56.8 | -8.8% | 🔴 Regression |
| AI | CPU% | 5.8% | 6.4% | +10.3% | 🔴 Regression |
| Collision | Checks/sec | 125000 | 134000 | +7.2% | 🟢 Improvement |
| Pathfinder | Calc Time | 8.5ms | 8.7ms | +2.4% | ⚪ Stable |

### Step 5: Flag Regressions

**Regression Severity Levels:**

#### 🔴 CRITICAL (Block Merge)
- AI System FPS drops below 60
- AI System CPU usage exceeds 8%
- Any performance metric degrades >15%
- Benchmark timeouts (infinite loops)

#### 🟠 WARNING (Review Required)
- Performance degradation 10-15%
- AI System FPS 60-65 (near threshold)
- Collision/Pathfinding >10% slower

#### 🟡 MINOR (Monitor)
- Performance degradation 5-10%
- Within acceptable variance but trending down

#### ⚪ STABLE (Acceptable)
- Performance change <5% (measurement noise)

#### 🟢 IMPROVEMENT
- Performance improvement >5%
- Successful optimization

**Regression Detection Logic:**

```python
def classify_change(metric_name, baseline, current, is_lower_better=False):
    change_pct = ((current - baseline) / baseline) * 100

    # Invert for metrics where lower is better (e.g., CPU%, time)
    if is_lower_better:
        change_pct = -change_pct

    # Critical thresholds for AI system (most important)
    if "AI" in metric_name or "FPS" in metric_name:
        if metric_name == "FPS" and current < 60:
            return "CRITICAL", "FPS below 60 threshold"
        if metric_name == "CPU" and current > 8:
            return "CRITICAL", "CPU exceeds 8% threshold"

    # General thresholds
    if change_pct < -15:
        return "CRITICAL", f"{abs(change_pct):.1f}% regression"
    elif change_pct < -10:
        return "WARNING", f"{abs(change_pct):.1f}% regression"
    elif change_pct < -5:
        return "MINOR", f"{abs(change_pct):.1f}% regression"
    elif change_pct > 5:
        return "IMPROVEMENT", f"{change_pct:.1f}% improvement"
    else:
        return "STABLE", f"{abs(change_pct):.1f}% variance (acceptable)"
```

**Dual Benchmark Regression Detection Strategy:**

With the split between Synthetic and Integrated benchmarks, regression source identification is more precise:

1. **Synthetic-Only Regression:**
   - Synthetic benchmarks regress, Integrated stable
   - **Root Cause:** AIManager infrastructure (batch processing, SIMD, threading)
   - **Action:** Profile AIManager core systems, check ThreadSystem
   - **Impact:** Core infrastructure degraded

2. **Integrated-Only Regression:**
   - Integrated benchmarks regress, Synthetic stable
   - **Root Cause:** PathfinderManager, CollisionManager, or production behaviors
   - **Action:** Profile pathfinding, collision queries, behavior execution
   - **Impact:** Production workload degraded

3. **Both Regress:**
   - Both Synthetic and Integrated benchmarks regress
   - **Root Cause:** Foundational infrastructure (ThreadSystem, memory allocator)
   - **Action:** Profile system-wide performance, check for threading issues
   - **Impact:** System-wide performance degradation

4. **Integration Overhead Growing:**
   - Synthetic stable, Integrated regressing more than expected
   - Overhead % increasing beyond 20-40% range
   - **Root Cause:** Integration efficiency degrading
   - **Action:** Check PathfinderManager cache efficiency, CollisionManager query optimization

### Step 6: Generate Report

**Report Structure:**

```markdown
# HammerEngine Performance Regression Report
**Date:** YYYY-MM-DD HH:MM:SS
**Branch:** <current-branch>
**Baseline:** <baseline-date or "New Baseline Created">
**Total Benchmark Time:** <duration>

---

## 🎯 Overall Status: <PASSED/FAILED/WARNING>

<summary-of-regressions>

---

## 📊 Performance Summary

### AI System - Synthetic Benchmarks (Isolated AIManager Infrastructure)

**Purpose:** Tests AIManager core systems without integration overhead

| Entity Count | Baseline | Current | Change | Status |
|--------------|----------|---------|--------|--------|
| 100 (Single) | 170K/s | 165K/s | -2.9% | ⚪ Stable |
| 200 (Multi) | 750K/s | 730K/s | -2.7% | ⚪ Stable |
| 1000 (Multi) | 975K/s | 920K/s | -5.6% | 🟡 MINOR |
| 5000 (Multi) | 925K/s | 880K/s | -4.9% | ⚪ Stable |
| 10000 (Multi) | 995K/s | 950K/s | -4.5% | ⚪ Stable |

**Status:** ⚪ **STABLE**
- All metrics within acceptable variance (<6%)
- No AIManager infrastructure regressions
- Batch processing and threading performing as expected

**Threading Efficiency:** 5.4x speedup maintained

---

### AI System - Integrated Benchmarks (Production Workload)

**Purpose:** Tests AIManager with PathfinderManager/CollisionManager integration

| Entity Count | Baseline | Current | Change | Status |
|--------------|----------|---------|--------|--------|
| 100 (Single) | 569K/s | 540K/s | -5.1% | 🟡 MINOR |
| 200 (Multi) | 580K/s | 530K/s | -8.6% | 🟡 MINOR |
| 500 (Multi) | 611K/s | 555K/s | -9.2% | 🟡 MINOR |
| 1000 (Multi) | 1193K/s | 1050K/s | -12.0% | 🟠 WARNING |
| 2000 (Multi) | 1587K/s | 1380K/s | -13.0% | 🟠 WARNING |

**Status:** 🟠 **WARNING - Integration Regression**
- Consistent degradation across all entity counts (~10%)
- Synthetic benchmarks stable → Points to integration issue
- PathfinderManager or CollisionManager likely cause

**Threading Efficiency:** 2.8x → 2.5x (degraded)

**Likely Causes:**
- PathfinderManager: Increased pathfinding overhead or cache inefficiency
- CollisionManager: Spatial hash query slowdown
- Production behaviors: Added computational complexity
- Integration points: Increased overhead in manager communication

**Recommended Actions:**
1. Profile PathfinderManager::requestPath() and cache hit rates
2. Check CollisionManager::queryNearbyEntities() performance
3. Review recent changes to WanderBehavior, ChaseBehavior, etc.
4. Verify thread coordination between AIManager and PathfinderManager
5. Check for increased mutex contention at integration points

---

### AI System - Integration Overhead Analysis

**Overhead Comparison** (Synthetic vs Integrated):

| Entity Count | Synthetic | Integrated | Overhead | Change |
|--------------|-----------|------------|----------|--------|
| 100 | 165K/s | 540K/s | -70% | -2% ⚪ |
| 200 | 730K/s | 530K/s | +27% | -5% 🟡 |
| 1000 | 920K/s | 1050K/s | -14% | -6% 🟡 |
| 2000 | N/A | 1380K/s | N/A | -10% 🟠 |

**Note:** Negative overhead indicates data inconsistency (synthetic uses estimates).
**Expected:** Integrated should be 20-40% slower due to PathfinderManager overhead.
**Actual:** Overhead growing trend suggests integration efficiency degrading.

---

### Collision System

| Metric | Baseline | Current | Change | Status |
|--------|----------|---------|--------|--------|
| Collision Checks/sec | 125000 | 134000 | +7.2% | 🟢 Improvement |
| Query Time | 0.08ms | 0.07ms | -12.5% | 🟢 Improvement |
| Hash Efficiency | 94.2% | 95.1% | +1.0% | ⚪ Stable |
| AABB Tests/sec | 250000 | 265000 | +6.0% | 🟢 Improvement |

**Status:** 🟢 **IMPROVEMENT**
- Spatial hash optimization successful
- Query performance improved significantly

---

### Pathfinding System **[ALWAYS INCLUDE - CRITICAL]**

**⚠️ IMPORTANT:** This section is MANDATORY in all regression reports. Pathfinding performance directly impacts integrated AI benchmarks.

| Distance (units) | Baseline Time | Current Time | Change | Path Nodes | Success Rate | Status |
|------------------|---------------|--------------|--------|------------|--------------|--------|
| 50 (Short) | 0.048 ms | 0.024 ms | -50.0% | 1 | 100% | 🟢 Major Improvement |
| 400 (Medium) | 0.259 ms | 0.049 ms | -81.1% | 3 | 100% | 🟢 Major Improvement |
| 2000 (Long) | 0.502 ms | 0.052 ms | -89.6% | 6 | 100% | 🟢 Major Improvement |
| 4000 (Very Long) | 0.756 ms | 0.128 ms | -83.1% | 10 | 100% | 🟢 Major Improvement |
| 8000 (Extreme) | N/A | 0.349 ms | N/A | 20 | 100% | 🟢 Excellent |

**Status:** [Determine based on actual results]
- Path calculation performance across all distance ranges
- Success rate (must be 100% - failures are critical regressions)
- Path quality (nodes explored should be reasonable)
- A* algorithm and cache effectiveness

**Template Notes:**
- Always show ALL distance ranges (50, 400, 2000, 4000, 8000 units)
- Include success rate for each distance (failures = critical regression)
- Note path quality (average nodes should be optimal)
- Highlight major improvements or regressions
- Cross-reference with integrated AI benchmark if pathfinding impacts it

---

### Event Manager

| Metric | Baseline | Current | Change | Status |
|--------|----------|---------|--------|--------|
| Events/sec | 8500 | 8200 | -3.5% | ⚪ Stable |
| Dispatch Latency | 0.12ms | 0.13ms | +8.3% | 🟡 MINOR |
| Queue Depth | 128 | 128 | 0.0% | ⚪ Stable |
| Peak Throughput | 10000 | 9800 | -2.0% | ⚪ Stable |

**Status:** 🟡 **MINOR REGRESSION**
- Slight increase in dispatch latency
- Monitor for further degradation

---

### Particle Manager

| Metric | Baseline | Current | Change | Status |
|--------|----------|---------|--------|--------|
| Particles/frame | 5000 | 5000 | 0.0% | ⚪ Stable |
| Render Time | 3.2ms | 3.1ms | -3.1% | ⚪ Stable |
| Batch Count | 12 | 11 | -8.3% | 🟢 Improvement |
| Culling Efficiency | 88% | 90% | +2.3% | 🟢 Improvement |

**Status:** 🟢 **IMPROVEMENT**
- Better batching efficiency
- Improved culling

---

### UI System

| Metric | Baseline | Current | Change | Status |
|--------|----------|---------|--------|--------|
| Components | 1000 | 1000 | 0.0% | ⚪ Stable |
| Render Time | 4.5ms | 4.4ms | -2.2% | ⚪ Stable |
| Event Handling | 0.3ms | 0.3ms | 0.0% | ⚪ Stable |
| DPI Scaling FPS | 60 | 60 | 0.0% | ⚪ Stable |

**Status:** ⚪ **STABLE**

---

## 🚨 Critical Issues (BLOCKING)

1. **AI System FPS Below Threshold**
   - Current: 56.8 FPS (Target: 60+)
   - Regression: -8.8%
   - **Action Required:** Must fix before merge

---

## ⚠️ Warnings (Review Required)

1. **AI System CPU Usage Increase**
   - Current: 6.4% (Target: <6%)
   - Regression: +10.3%

2. **AI Update Time Increase**
   - Current: 13.9ms (Baseline: 12.4ms)
   - Regression: +12.1%

---

## 📈 Improvements

1. **Collision System Performance**
   - Query time improved 12.5%
   - Collision checks/sec improved 7.2%

2. **Particle Manager Batching**
   - Batch count reduced 8.3% (better efficiency)
   - Culling efficiency improved 2.3%

---

## 🔍 Detailed Analysis

### Performance Hotspots (if callgrind data available)

<parse callgrind reports from test_results/valgrind/callgrind/>

Top Functions by Time:
1. AIManager::updateBehaviors - 45% (up from 38% - REGRESSION)
2. CollisionManager::detectCollisions - 18% (down from 22% - IMPROVEMENT)
3. PathfinderManager::calculatePath - 12% (stable)

---

## 📋 Recommendations

### Immediate Actions (Critical)
1. Investigate AI System performance regression
2. Profile AIManager::updateBehaviors with valgrind/callgrind
3. Review commits since baseline for AI changes
4. Do not merge until FPS ≥60 restored

### Short-term Actions (Warnings)
1. Monitor Event Manager dispatch latency
2. Consider AI batch size optimization
3. Review recent AI behavior changes

### Long-term Actions (Optimization)
1. Apply collision system improvements to other managers
2. Document particle manager batching technique
3. Consider updating baseline after AI fixes validated

---

## 📁 Files

**Baseline:** `$PROJECT_ROOT/test_results/baseline/*.txt`
**Current Results:** `$PROJECT_ROOT/test_results/*/performance_metrics.txt`
**Callgrind Reports:** `$PROJECT_ROOT/test_results/valgrind/callgrind/` (if available)
**Full Report:** `$PROJECT_ROOT/test_results/regression_reports/regression_YYYY-MM-DD.md`

---

## ✅ Next Steps

- [ ] Fix AI System FPS regression (BLOCKING)
- [ ] Verify fixes with re-run: `claude run benchmark regression check`
- [ ] Update baseline after validation: `claude update performance baseline`
- [ ] Document optimization techniques from collision improvements

---

**Generated by:** hammer-benchmark-regression Skill
**Report saved to:** $PROJECT_ROOT/test_results/regression_reports/regression_YYYY-MM-DD.md
```

**Console Summary:**
```
=== Performance Regression Check ===

Status: 🔴 REGRESSION DETECTED (BLOCKING)

Critical Issues:
  🔴 AI System FPS: 56.8 (target: 60+) - 8.8% regression

Warnings:
  🟠 AI CPU Usage: 6.4% (target: <6%) - 10.3% increase
  🟡 Event Dispatch Latency: +8.3%

Improvements:
  🟢 Collision Query Time: -12.5%
  🟢 Particle Batching: -8.3%

Total Benchmark Time: 21m 15s

❌ DO NOT MERGE - Fix AI regression first

Full Report: $PROJECT_ROOT/test_results/regression_reports/regression_2025-01-15.md
```

## Storage & Baseline Management

### Baseline Update Command
```bash
# After validating improvements, update baseline (requires PROJECT_ROOT)
cp "$PROJECT_ROOT/test_results/"*/performance_metrics.txt "$PROJECT_ROOT/test_results/baseline/"
echo "Baseline updated: $(date)" > "$PROJECT_ROOT/test_results/baseline/baseline_date.txt"
```

### Baseline History
Keep historical baselines for long-term tracking:
```
$PROJECT_ROOT/test_results/baseline_history/
├── 2025-01-01_baseline/
├── 2025-01-15_baseline/
└── 2025-02-01_baseline/
```

## Integration with Development Workflow

**Use this Skill:**
- Before merging feature branches
- After performance optimizations (verify improvement)
- Weekly during active development
- Before releases (ensure no regressions)
- When modifying AI, collision, pathfinding, or particle systems

## Final Report Validation Checklist

**⚠️ MANDATORY: Verify BEFORE submitting report to user**

Before finalizing any regression report, confirm ALL of the following:

### Benchmark Execution
- [ ] All 6 benchmarks completed successfully (no timeouts/crashes)
- [ ] AI Scaling: Both Synthetic AND Integrated results present
- [ ] **Pathfinding: Path length scaling data extracted** ← CRITICAL!
- [ ] Collision: SOA timing data extracted
- [ ] Event Manager: Throughput data extracted
- [ ] Particle Manager: Update timing data extracted
- [ ] UI Stress: Processing metrics extracted

### Report Completeness
- [ ] **Pathfinding System section included in report** ← DO NOT SKIP!
- [ ] AI System: Synthetic + Integrated sections present
- [ ] Collision System: Performance table present
- [ ] Event Manager: Metrics table present
- [ ] Particle Manager: Performance data present
- [ ] UI System: Throughput data present
- [ ] Overall status determined (PASSED/WARNING/FAILED)
- [ ] Regression/improvement analysis complete

### Critical Pathfinding Verification
- [ ] Pathfinding metrics extracted from `test_results/pathfinder_benchmark_current.txt`
- [ ] All 5 distance ranges present (50, 400, 2000, 4000, 8000 units)
- [ ] Success rates reported (must be 100%)
- [ ] Performance comparison against baseline completed
- [ ] Pathfinding section visible in final report

**If ANY checklist item is unchecked, DO NOT submit the report. Extract missing data first.**

## Exit Codes

- **0:** All benchmarks passed, no regressions
- **1:** Critical regressions detected (BLOCKING)
- **2:** Warnings detected (review required)
- **3:** Benchmark failed to run (timeout/crash)
- **4:** Baseline creation mode (informational)

## Usage Examples

When the user says:
- "check for performance regressions"
- "run benchmarks"
- "test performance"
- "verify no performance degradation"
- "compare against baseline"

Activate this Skill automatically.

## Performance Expectations

- **Full benchmark suite:** ~31 minutes
  - AI Scaling: ~18 minutes
  - Collision: ~3 minutes
  - Pathfinder: ~5 minutes
  - Event Manager: ~2 minutes
  - Particle Manager: ~2 minutes
  - UI Stress: ~1 minute
- **Report generation:** 2-3 minutes
- **Total:** ~33-35 minutes for complete analysis

## Troubleshooting

**Benchmark timeouts:**
- Possible infinite loop or catastrophic performance regression
- Run individual benchmark with debugging: `gdb ./bin/debug/ai_system_benchmark`

**Inconsistent results:**
- System load affecting benchmarks
- Re-run benchmarks in clean environment
- Close other applications
- Check for thermal throttling

**No baseline found:**
- Skill will create baseline from current run
- Subsequent runs will compare against this baseline
- Update baseline after validating improvements
