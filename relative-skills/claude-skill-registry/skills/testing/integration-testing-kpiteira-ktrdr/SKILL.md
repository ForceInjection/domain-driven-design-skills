---
name: integration-testing
description: Use when designing E2E tests for milestones or features, executing integration smoke tests after implementation, validating acceptance criteria requiring system-level testing, or debugging integration failures.
---

# Integration Testing Skill

Load this skill when:
- Designing E2E tests for a milestone or feature
- Executing integration smoke tests after implementation
- Validating acceptance criteria that require system-level testing
- Debugging integration failures

---

## Philosophy

**Unit tests verify components. Integration tests verify the system works.**

A feature isn't done when unit tests pass — it's done when you can trigger it end-to-end and observe the expected behavior. This skill helps you design and execute those tests.

---

## When to Run Integration Tests

| Situation | Action |
|-----------|--------|
| After implementing a milestone | Run the milestone's E2E test scenario |
| After TDD GREEN phase (ktask) | Run integration smoke test |
| Acceptance criteria mentions "integration" | Design and execute appropriate test |
| Something "should work" but doesn't | Use integration test to isolate the issue |

---

## Test Design Process

### Step 1: Identify What to Test

From the feature or milestone, extract:
- **Trigger**: How does a user initiate this? (CLI command, API call, UI action)
- **Flow**: What components are involved? (API → Service → Worker → Database)
- **Observable outcome**: What proves it worked? (Response, logs, state change, file created)

### Step 2: Choose Test Category

| Category | When | Example |
|----------|------|---------|
| **Smoke Test** | Quick validation something works | Start operation, check it completes |
| **Progress Test** | Verify long-running operations | Monitor progress updates over time |
| **Cancellation Test** | Verify cleanup works | Start, wait, cancel, verify stopped |
| **Error Test** | Verify graceful failure | Invalid input, missing dependencies |
| **Integration Test** | Verify cross-service communication | Backend → Worker → Host Service |

### Step 3: Define Test Data

Choose parameters that match the test purpose:

**For smoke tests (fast feedback):**
- Small datasets, short durations
- Example: 1 year daily data (~250 bars), 10 epochs

**For progress monitoring (observe updates):**
- Larger datasets, longer durations (30-90 seconds)
- Example: 2 years 5-minute data, observable progress

**For stress/edge cases:**
- Boundary conditions, large volumes
- Example: Maximum date range, concurrent operations

### Step 4: Write the Test Scenario

Use this template:

```markdown
## Scenario: [Name]

**Category**: [Smoke/Progress/Cancellation/Error/Integration]
**Duration**: ~[X] seconds
**Purpose**: [One sentence]

### Prerequisites
- [Service 1] running
- [Configuration] set
- [Data] available

### Commands

**1. [Action Name]**
```bash
[Command]
```
**Expected**: [What should happen]

**2. [Verification]**
```bash
[Command to check result]
```
**Expected**: [What output proves success]

### Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]
```

---

## Quick Reference: KTRDR Services

### Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Backend API | http://localhost:8000/api/v1 | Main entry point |
| Training Host | http://localhost:5002 | GPU training |
| IB Host | http://localhost:5001 | IB Gateway access |
| Backtest Worker | http://localhost:5003 | Backtesting |

### Health Checks

```bash
# Backend
curl -s http://localhost:8000/health | jq

# Training host
curl -s http://localhost:5002/health | jq

# IB host (check IB Gateway connection)
curl -s http://localhost:5001/health | jq '{status, ib_connected}'

# All services quick check
for port in 8000 5001 5002 5003; do
  echo -n "Port $port: "
  curl -s --max-time 2 http://localhost:$port/health | jq -r '.status // "not responding"'
done
```

---

## Common Test Patterns

### Pattern 1: Start and Verify Completion

```bash
# 1. Start operation
RESPONSE=$(curl -s -X POST http://localhost:8000/api/v1/[endpoint] \
  -H "Content-Type: application/json" \
  -d '[JSON payload]')

OP_ID=$(echo "$RESPONSE" | jq -r '.operation_id // .task_id // .data.operation_id')
echo "Operation ID: $OP_ID"

# 2. Wait for completion
sleep [estimated_duration]

# 3. Check status
curl -s "http://localhost:8000/api/v1/operations/$OP_ID" | \
  jq '{status: .data.status, result: .data.result_summary}'
```

### Pattern 2: Poll Progress

```bash
# Poll every N seconds, M times
for i in {1..M}; do
  sleep N
  curl -s "http://localhost:8000/api/v1/operations/$OP_ID" | \
    jq '{poll:'"$i"', status:.data.status, pct:.data.progress.percentage}'
done
```

### Pattern 3: Cancellation

```bash
# 1. Start operation
# 2. Wait until running
sleep 10
curl -s "http://localhost:8000/api/v1/operations/$OP_ID" | jq '.data.status'
# Should be: "running"

# 3. Cancel
curl -s -X DELETE "http://localhost:8000/api/v1/operations/$OP_ID" | jq

# 4. Verify cancelled
sleep 2
curl -s "http://localhost:8000/api/v1/operations/$OP_ID" | jq '.data.status'
```

### Pattern 4: Error Handling

```bash
# Send invalid request
curl -i -s -X POST http://localhost:8000/api/v1/[endpoint] \
  -H "Content-Type: application/json" \
  -d '{"invalid": "payload"}'

# Check:
# - HTTP status code (400, 404, etc.)
# - Error message is clear
# - No stack traces
# - System remains stable
```

### Pattern 5: Log Verification

```bash
# Check for expected log entry
docker compose logs backend --since 60s | grep "[expected pattern]"

# Check for absence of error
docker compose logs backend --since 60s | grep -i "error\|exception"
# Should be empty or only expected errors
```

---

## Key API Endpoints

### Operations (All Types)

```bash
# Get status
curl -s "http://localhost:8000/api/v1/operations/$OP_ID" | jq

# List operations
curl -s "http://localhost:8000/api/v1/operations?status=running&limit=10" | jq

# Cancel
curl -s -X DELETE "http://localhost:8000/api/v1/operations/$OP_ID"
```

### Training

```bash
# Start training
curl -s -X POST http://localhost:8000/api/v1/trainings/start \
  -H "Content-Type: application/json" \
  -d '{
    "symbols": ["EURUSD"],
    "timeframes": ["1d"],
    "strategy_name": "test_e2e_local_pull",
    "start_date": "2024-01-01",
    "end_date": "2024-12-31"
  }'
```

### Data

```bash
# Get cached data info
curl -s "http://localhost:8000/api/v1/data/EURUSD/1h" | jq '.data.dates | length'

# Download from IB (requires IB host running)
curl -s -X POST http://localhost:8000/api/v1/data/acquire/download \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "EURUSD",
    "timeframe": "1h",
    "mode": "tail",
    "start_date": "2024-01-01",
    "end_date": "2024-12-31"
  }'
```

### Backtesting

```bash
# Start backtest
curl -s -X POST http://localhost:8000/api/v1/backtests/start \
  -H "Content-Type: application/json" \
  -d '{
    "model_path": "models/neuro_mean_reversion/1d_v21/model.pt",
    "strategy_name": "neuro_mean_reversion",
    "symbol": "EURUSD",
    "timeframe": "1d",
    "start_date": "2024-01-01",
    "end_date": "2024-01-31"
  }'
```

---

## Test Data Calibration

### Training Tests

| Purpose | Timeframe | Date Range | Samples | Duration |
|---------|-----------|------------|---------|----------|
| Smoke test | 1d | 1 year | ~250 | ~2s |
| Progress monitoring | 5m | 2 years | ~150K | ~60s |
| Cancellation | 5m | 2 years | ~150K | ~30s (cancel at 50%) |

### Data Tests

| Purpose | Timeframe | Date Range | Bars | Duration |
|---------|-----------|------------|------|----------|
| Cache read | 1h | any | ~115K | <1s |
| Small download | 1d | 1 year | ~250 | 10-30s |
| Progress monitoring | 1h | 1 year | ~8760 | 30-90s |

---

## Log Patterns to Watch

### Success Indicators

```bash
# Local bridge registered (training in backend)
grep "Registered local training bridge" 

# Remote proxy registered (training on host)
grep "Registered remote proxy"

# Data saved to cache
grep "Saved.*rows to cache"
```

### Error Indicators

```bash
# Event loop error (architecture bug)
grep -i "no running event loop"
# Should be EMPTY

# Connection errors
grep -i "connection refused\|timeout"

# General errors
grep -i "error\|exception\|failed"
```

---

## Troubleshooting

### Operation completes instantly (no progress)

**Cause**: Dataset too small
**Fix**: Use larger date range or finer timeframe

### Download uses cache instead of IB

**Cause**: Missing `"mode":"tail"` parameter
**Fix**: Add `"mode":"tail"` to request body

### Cannot connect to service

**Cause**: Service not running
**Fix**: 
```bash
# Check what's running
docker ps
curl http://localhost:8000/health

# Start services
docker compose up -d
```

### IB download fails

**Cause**: IB Gateway not connected
**Fix**:
1. Check IB host: `curl http://localhost:5001/health`
2. Start IB Gateway TWS application
3. Log in to paper trading account

---

## Integration with Workflow

### From `/kdesign-impl-plan`

Each milestone has an E2E test scenario. After implementing all tasks in a milestone:

1. Read the milestone's E2E test from the plan
2. Design the test using this skill's patterns
3. Execute and verify all success criteria

### From `/ktask`

After TDD passes (unit tests green), run integration smoke test:

1. Start the system: `docker compose up -d`
2. Execute the modified flow (API call, CLI command)
3. Verify end-to-end behavior
4. Check logs for errors
5. Report: "✅ Integration test passed" or "❌ Issue: [description]"

---

## Example: Designing a New Test

**Feature**: User can cancel a running training operation

**Step 1: Identify**
- Trigger: DELETE /api/v1/operations/{id}
- Flow: API → OperationsService → Worker
- Outcome: Status changes to "cancelled", training stops

**Step 2: Category**
Cancellation test (~30 seconds)

**Step 3: Test Data**
- 2 years 5m data (long enough to cancel mid-operation)
- Strategy: test_e2e_local_pull

**Step 4: Scenario**

```markdown
## Scenario: Training Cancellation

**Category**: Cancellation
**Duration**: ~30 seconds
**Purpose**: Verify training can be cancelled mid-operation

### Prerequisites
- Backend running
- Local training mode

### Commands

**1. Start long-running training**
```bash
RESPONSE=$(curl -s -X POST http://localhost:8000/api/v1/trainings/start \
  -H "Content-Type: application/json" \
  -d '{"symbols":["EURUSD"],"timeframes":["5m"],"strategy_name":"test_e2e_local_pull","start_date":"2023-01-01","end_date":"2025-01-01"}')
TASK_ID=$(echo "$RESPONSE" | jq -r '.task_id')
```

**2. Wait and verify running**
```bash
sleep 15
curl -s "http://localhost:8000/api/v1/operations/$TASK_ID" | \
  jq '{status:.data.status, pct:.data.progress.percentage}'
```
**Expected**: status: "running", progress > 0%

**3. Cancel**
```bash
curl -s -X DELETE "http://localhost:8000/api/v1/operations/$TASK_ID" | jq
```
**Expected**: Cancellation acknowledged

**4. Verify cancelled**
```bash
sleep 3
curl -s "http://localhost:8000/api/v1/operations/$TASK_ID" | jq '.data.status'
```
**Expected**: "cancelled" or "failed" (known quirk)

### Success Criteria
- [ ] Operation starts and shows progress
- [ ] Cancel request succeeds
- [ ] Status reflects cancellation
- [ ] System remains stable (can start new operations)
```

---

## Full Documentation

For comprehensive scenario library:
- `docs/testing/SCENARIOS.md` — All test scenarios with results
- `docs/testing/TESTING_GUIDE.md` — Complete API reference and troubleshooting
