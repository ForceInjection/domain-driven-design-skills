---
name: production-api-tester
description: Live testing and validation of production research API for strategy optimization loops
allowed-tools: "*"
---

# Production API Tester

Skill for testing the production research API in live environments. Enables optimization loops: create strategy → test in production → analyze with Langfuse → iterate.

## When to Use This Skill

- "Test the daily_news_briefing strategy in production"
- "Create a test task and execute it"
- "Run the full optimization loop for my new legal research strategy"
- "Check if the production API is healthy"
- "Clean up test tasks after experimentation"
- "Monitor execution status and retrieve results"

## What This Skill Does

**5 Core Functions**:

1. **Create Test Tasks** - Subscribe test emails to research topics
2. **Execute Research** - Trigger batch or single task execution
3. **Monitor Status** - Poll for completion and retrieve results
4. **Analyze Results** - Link to Langfuse traces for performance analysis
5. **Cleanup** - Delete test tasks after validation

## Required Setup

### Environment Variables

```bash
# Production API Configuration
export PROD_API_URL="https://webresearchagent.replit.app"  # Production URL
export PROD_API_KEY="your_api_key_here"  # Your API secret key
export CALLBACK_URL="https://webhook.site/your-unique-url"  # Webhook receiver URL

# Optional: Override for local testing
export PROD_API_URL="http://localhost:8000"  # Test locally
```

**Getting Your API Key**:
- User will provide this
- Store in environment or pass via `--api-key` flag

**Setting Up Webhook Receiver**:
- Option 1: Use webhook.site (https://webhook.site) - get instant unique URL
- Option 2: Use Langdock webhook (if using Langdock integration)
- Option 3: Run local webhook receiver (provided in helpers)

## Workflow

### Use Case 1: Test Single Strategy (Quick Test)

**Goal**: Execute a strategy once and check results

#### Step 1: Create Test Task

```bash
cd /home/user/web_research_agent/.claude/skills/production-api-tester/helpers

# Create test task
python3 create_test_task.py \
  --api-key "$PROD_API_KEY" \
  --email "test@example.com" \
  --topic "AI developments in healthcare" \
  --frequency "daily" \
  --output /tmp/api_test/task.json
```

**Output**:
```json
{
  "id": "abc123",
  "email": "test@example.com",
  "research_topic": "AI developments in healthcare",
  "frequency": "daily",
  "schedule_time": "09:00",
  "is_active": true,
  "created_at": "2025-11-09T10:00:00Z",
  "last_run_at": null
}
```

#### Step 2: Execute Research

```bash
# Execute batch (all daily tasks)
python3 execute_batch.py \
  --api-key "$PROD_API_KEY" \
  --frequency "daily" \
  --callback-url "$CALLBACK_URL" \
  --output /tmp/api_test/execution.json
```

**Output**:
```json
{
  "status": "running",
  "frequency": "daily",
  "tasks_found": 1,
  "started_at": "2025-11-09T10:01:00Z"
}
```

#### Step 3: Monitor Results

```bash
# Option A: Poll webhook endpoint
python3 check_webhook.py \
  --webhook-url "$CALLBACK_URL" \
  --wait-for-results \
  --timeout 300

# Option B: Check task status
python3 get_task.py \
  --api-key "$PROD_API_KEY" \
  --task-id "abc123" \
  --output /tmp/api_test/task_status.json
```

#### Step 4: Link to Langfuse

```bash
# Get Langfuse trace for this execution
python3 link_to_langfuse.py \
  --task-id "abc123" \
  --email "test@example.com" \
  --output /tmp/api_test/langfuse_link.json
```

**Output**:
```json
{
  "task_id": "abc123",
  "trace_query": {
    "metadata_filter": {
      "user_email": "test@example.com",
      "research_topic": "AI developments in healthcare"
    },
    "time_range": "last_1_hour"
  },
  "langfuse_url": "https://cloud.langfuse.com/project/.../traces?filter=...",
  "trace_count": 1,
  "latest_trace_id": "xyz789"
}
```

#### Step 5: Cleanup

```bash
# Delete test task
python3 delete_task.py \
  --api-key "$PROD_API_KEY" \
  --task-id "abc123"
```

---

### Use Case 2: Full Optimization Loop (Strategy Development)

**Goal**: Test new strategy → analyze performance → iterate

This combines **strategy-builder** skill with **production-api-tester** skill.

#### Loop Iteration:

```bash
cd /home/user/web_research_agent/.claude/skills/production-api-tester/helpers

# 1. Generate/update strategy (using strategy-builder skill)
python3 ../../strategy-builder/helpers/generate_strategy.py \
  --slug "legal/court_cases_de" \
  --category "legal" \
  --time-window "month" \
  --depth "comprehensive" \
  --output /tmp/optimization_loop/strategy_v1.yaml

# 2. Validate strategy
python3 ../../strategy-builder/helpers/validate_strategy.py \
  --strategy /tmp/optimization_loop/strategy_v1.yaml

# 3. Deploy strategy to database
# (Manual: save to strategies/, add to index.yaml, migrate to DB)

# 4. Create test task for this strategy
python3 create_test_task.py \
  --api-key "$PROD_API_KEY" \
  --email "legal-test@example.com" \
  --topic "Datenschutz DSGVO Verstoß" \
  --frequency "daily" \
  --output /tmp/optimization_loop/task.json

# 5. Execute research
TASK_ID=$(jq -r '.id' /tmp/optimization_loop/task.json)
python3 execute_batch.py \
  --api-key "$PROD_API_KEY" \
  --frequency "daily" \
  --callback-url "$CALLBACK_URL" \
  --output /tmp/optimization_loop/execution.json

# 6. Wait for completion and get results
python3 wait_for_completion.py \
  --task-id "$TASK_ID" \
  --api-key "$PROD_API_KEY" \
  --timeout 600 \
  --output /tmp/optimization_loop/results.json

# 7. Link to Langfuse trace
python3 link_to_langfuse.py \
  --task-id "$TASK_ID" \
  --email "legal-test@example.com" \
  --output /tmp/optimization_loop/langfuse.json

# 8. Retrieve and analyze Langfuse trace
TRACE_ID=$(jq -r '.latest_trace_id' /tmp/optimization_loop/langfuse.json)
python3 ../../langfuse-optimization/helpers/retrieve_single_trace.py \
  "$TRACE_ID" \
  --filter-essential \
  --output /tmp/optimization_loop/trace.json

# 9. Analyze performance
python3 ../../strategy-builder/helpers/analyze_strategy_performance.py \
  --traces /tmp/optimization_loop/trace.json \
  --strategy "legal/court_cases_de" \
  --output /tmp/optimization_loop/performance.json

# 10. Review recommendations and iterate
cat /tmp/optimization_loop/performance.json
# Apply fixes to strategy YAML, repeat from step 1
```

---

### Use Case 3: Batch Testing (Multiple Strategies)

**Goal**: Test multiple strategies in parallel

#### Step 1: Create Multiple Test Tasks

```bash
cd /home/user/web_research_agent/.claude/skills/production-api-tester/helpers

# Create tasks for different strategies
python3 batch_create_tasks.py \
  --api-key "$PROD_API_KEY" \
  --tasks-file /tmp/batch_test/tasks_config.json \
  --output /tmp/batch_test/created_tasks.json
```

**tasks_config.json**:
```json
[
  {
    "email": "test-news@example.com",
    "research_topic": "AI regulation updates",
    "frequency": "daily",
    "strategy_hint": "daily_news_briefing"
  },
  {
    "email": "test-financial@example.com",
    "research_topic": "Tesla stock analysis",
    "frequency": "daily",
    "strategy_hint": "financial_research"
  },
  {
    "email": "test-legal@example.com",
    "research_topic": "GDPR compliance updates",
    "frequency": "daily",
    "strategy_hint": "legal/court_cases_de"
  }
]
```

#### Step 2: Execute All

```bash
# Execute daily batch
python3 execute_batch.py \
  --api-key "$PROD_API_KEY" \
  --frequency "daily" \
  --callback-url "$CALLBACK_URL"
```

#### Step 3: Monitor All

```bash
# Wait for all tasks to complete
python3 monitor_batch.py \
  --api-key "$PROD_API_KEY" \
  --tasks-file /tmp/batch_test/created_tasks.json \
  --timeout 900 \
  --output /tmp/batch_test/batch_results.json
```

#### Step 4: Analyze All

```bash
# Generate comparison report
python3 compare_strategies.py \
  --results /tmp/batch_test/batch_results.json \
  --output /tmp/batch_test/comparison.json
```

**Output**: Comparison of latency, success rate, error types across strategies

#### Step 5: Cleanup All

```bash
# Delete all test tasks
python3 batch_delete_tasks.py \
  --api-key "$PROD_API_KEY" \
  --tasks-file /tmp/batch_test/created_tasks.json
```

---

### Use Case 4: Health Check & Monitoring

**Goal**: Verify production API is healthy

```bash
cd /home/user/web_research_agent/.claude/skills/production-api-tester/helpers

# Quick health check
python3 health_check.py \
  --api-url "$PROD_API_URL"

# Extended monitoring
python3 health_check.py \
  --api-url "$PROD_API_URL" \
  --continuous \
  --interval 60 \
  --duration 3600
```

**Output**:
```
✓ API is healthy
  Status: online
  Database: connected
  Langfuse: enabled
  Response time: 234ms
```

---

## Helper Tools Reference

### 1. create_test_task.py

**Purpose**: Create research task subscription

**Usage**:
```bash
python3 create_test_task.py \
  --api-key "$PROD_API_KEY" \
  [--api-url "$PROD_API_URL"] \
  --email "test@example.com" \
  --topic "Research topic" \
  --frequency daily|weekly|monthly \
  [--schedule-time "09:00"] \
  --output /tmp/task.json
```

**Output**: Task object with ID for tracking

### 2. execute_batch.py

**Purpose**: Trigger batch research execution

**Usage**:
```bash
python3 execute_batch.py \
  --api-key "$PROD_API_KEY" \
  [--api-url "$PROD_API_URL"] \
  --frequency daily|weekly|monthly \
  --callback-url "https://webhook.site/..." \
  --output /tmp/execution.json
```

**Output**: Execution status (running, tasks_found, started_at)

### 3. get_task.py

**Purpose**: Retrieve task details

**Usage**:
```bash
python3 get_task.py \
  --api-key "$PROD_API_KEY" \
  [--api-url "$PROD_API_URL"] \
  --task-id "abc123" \
  --output /tmp/task.json
```

### 4. list_tasks.py

**Purpose**: List all research tasks

**Usage**:
```bash
python3 list_tasks.py \
  --api-key "$PROD_API_KEY" \
  [--api-url "$PROD_API_URL"] \
  [--email "filter@example.com"] \
  [--frequency daily] \
  --output /tmp/tasks.json
```

### 5. delete_task.py

**Purpose**: Delete research task

**Usage**:
```bash
python3 delete_task.py \
  --api-key "$PROD_API_KEY" \
  [--api-url "$PROD_API_URL"] \
  --task-id "abc123"
```

### 6. wait_for_completion.py

**Purpose**: Poll task until completion

**Usage**:
```bash
python3 wait_for_completion.py \
  --api-key "$PROD_API_KEY" \
  --task-id "abc123" \
  [--timeout 600] \
  [--poll-interval 10] \
  --output /tmp/results.json
```

### 7. link_to_langfuse.py

**Purpose**: Find Langfuse trace for task execution

**Usage**:
```bash
python3 link_to_langfuse.py \
  --task-id "abc123" \
  --email "test@example.com" \
  [--time-range "last_1_hour"] \
  --output /tmp/langfuse_link.json
```

**Output**:
- Trace query parameters
- Langfuse dashboard URL
- Latest trace ID

### 8. health_check.py

**Purpose**: Check API health

**Usage**:
```bash
python3 health_check.py \
  [--api-url "$PROD_API_URL"] \
  [--continuous] \
  [--interval 60] \
  [--duration 3600]
```

### 9. webhook_receiver.py (Local Testing)

**Purpose**: Run local webhook receiver for testing

**Usage**:
```bash
# Start local webhook receiver
python3 webhook_receiver.py \
  --port 8080 \
  --output-dir /tmp/webhooks

# Use as callback URL
export CALLBACK_URL="http://localhost:8080/webhook"
```

**Features**:
- Logs all incoming webhooks
- Saves payloads to disk
- Provides ngrok-style public URL (if using tunneling)

---

## Integration with Other Skills

### With strategy-builder Skill

**Optimization Loop**:
```
1. strategy-builder: analyze_research_query.py
   → Determine if new strategy needed

2. strategy-builder: generate_strategy.py
   → Create strategy YAML

3. strategy-builder: validate_strategy.py
   → Validate structure

4. [Manual: Deploy strategy to database]

5. production-api-tester: create_test_task.py
   → Create test subscription

6. production-api-tester: execute_batch.py
   → Run research

7. production-api-tester: wait_for_completion.py
   → Get results

8. production-api-tester: link_to_langfuse.py
   → Find trace

9. strategy-builder: analyze_strategy_performance.py
   → Analyze performance

10. [Iterate: Apply fixes and repeat]
```

### With langfuse-optimization Skill

**Performance Deep Dive**:
```
1. production-api-tester: execute_batch.py
   → Generate new traces

2. langfuse-optimization: retrieve_traces_and_observations.py
   → Get detailed trace data

3. langfuse-optimization: [analyze and fix configs]
   → Optimize style.yaml, template.yaml, tools.yaml
```

### With langfuse-advanced-filters Skill

**Targeted Analysis**:
```
1. production-api-tester: Create multiple test tasks
2. production-api-tester: Execute batch
3. langfuse-advanced-filters: query_with_filters.py
   → Filter by specific criteria (e.g., latency > 10s)
4. langfuse-advanced-filters: analyze_filtered_results.py
   → Identify patterns
```

---

## Common Patterns

### Pattern 1: Rapid Iteration Testing

```bash
# Loop for quick iterations
for i in {1..5}; do
  echo "Iteration $i"

  # Modify strategy (manual or automated)

  # Test
  python3 create_test_task.py ... --output /tmp/test_$i/task.json
  TASK_ID=$(jq -r '.id' /tmp/test_$i/task.json)
  python3 execute_batch.py ...
  python3 wait_for_completion.py --task-id "$TASK_ID" --output /tmp/test_$i/results.json

  # Analyze
  python3 link_to_langfuse.py --task-id "$TASK_ID" --output /tmp/test_$i/trace.json

  # Cleanup
  python3 delete_task.py --task-id "$TASK_ID"

  echo "Iteration $i complete. Review /tmp/test_$i/"
  sleep 5
done
```

### Pattern 2: A/B Testing Strategies

```bash
# Test strategy A
python3 create_test_task.py --email "test-a@example.com" --topic "AI news" --output /tmp/ab_test/task_a.json

# Test strategy B (different strategy slug via topic classification)
python3 create_test_task.py --email "test-b@example.com" --topic "AI regulation detailed analysis" --output /tmp/ab_test/task_b.json

# Execute both
python3 execute_batch.py --frequency daily

# Compare results
python3 compare_tasks.py \
  --task-a /tmp/ab_test/task_a.json \
  --task-b /tmp/ab_test/task_b.json \
  --output /tmp/ab_test/comparison.json
```

### Pattern 3: Regression Testing

```bash
# Before deploying changes to production, test current vs new

# 1. Baseline (current production strategy)
python3 create_test_task.py --email "baseline@example.com" --topic "Test topic" --output /tmp/regression/baseline_task.json
python3 execute_batch.py ...
# Save results

# 2. Make changes to strategy

# 3. Test new version
python3 create_test_task.py --email "new@example.com" --topic "Test topic" --output /tmp/regression/new_task.json
python3 execute_batch.py ...
# Compare results

# 4. Validate no regressions
python3 validate_regression.py \
  --baseline /tmp/regression/baseline_results.json \
  --new /tmp/regression/new_results.json \
  --output /tmp/regression/regression_report.json
```

---

## Tips & Best Practices

### 1. Use Unique Test Emails

Always use identifiable test email addresses:
- `test-strategy-{strategy_name}@example.com`
- `dev-{your_name}@example.com`
- Never use real user emails for testing

### 2. Clean Up Test Tasks

Always delete test tasks after validation:
```bash
# List all test tasks
python3 list_tasks.py --api-key "$PROD_API_KEY" | grep "test-"

# Bulk delete
python3 batch_delete_tasks.py --pattern "test-*"
```

### 3. Use Webhook.site for Quick Tests

For quick tests without setting up infrastructure:
1. Go to https://webhook.site
2. Copy your unique URL
3. Use as `CALLBACK_URL`
4. View results in browser

### 4. Tag Test Executions

When creating test tasks, use descriptive topics:
```bash
# Good
--topic "[TEST] AI news - strategy_v2_iteration_3"

# Bad
--topic "test"
```

This makes Langfuse traces easier to find and filter.

### 5. Automate Full Loop

Create a script for the full optimization loop:
```bash
#!/bin/bash
# optimize_strategy.sh

STRATEGY_SLUG=$1
TEST_TOPIC=$2

# Generate → Validate → Deploy → Test → Analyze → Report
...
```

### 6. Monitor API Rate Limits

Production API may have rate limits:
- Wait between batch executions
- Use `--poll-interval` to avoid overwhelming the API
- Check API response headers for rate limit info

---

## Troubleshooting

**"Authentication failed"**:
- Verify `PROD_API_KEY` is set correctly
- Check API key is active in production database
- Ensure `X-API-Key` header is sent

**"Webhook not receiving results"**:
- Verify `CALLBACK_URL` is publicly accessible
- Check webhook receiver logs
- Use webhook.site for debugging
- Ensure URL doesn't have trailing slash inconsistencies

**"Task execution times out"**:
- Increase `--timeout` parameter
- Check production logs for errors
- Verify strategy is valid and doesn't have infinite loops
- Check Langfuse for ERROR level traces

**"Cannot find Langfuse trace"**:
- Wait 30-60 seconds for trace to be indexed
- Verify metadata fields match (email, topic)
- Check time range is wide enough
- Use `--time-range "last_1_day"` for safety

**"Health check fails"**:
- Verify `PROD_API_URL` is correct
- Check if API is deployed and running
- Verify network connectivity
- Check API logs for startup errors

---

## Security Considerations

### 1. API Key Management

**DO**:
- Store API key in environment variables
- Use separate API keys for testing vs production
- Rotate keys regularly

**DON'T**:
- Commit API keys to git
- Share API keys in logs or screenshots
- Use production API key for automated testing

### 2. Test Data

**DO**:
- Use fake/test email addresses
- Use non-sensitive research topics
- Mark test tasks clearly

**DON'T**:
- Use real user data for testing
- Test with sensitive/confidential topics
- Leave test tasks in production database

### 3. Webhook Security

**DO**:
- Use HTTPS for webhook URLs
- Validate webhook payloads
- Log webhook failures

**DON'T**:
- Expose webhook receiver without authentication
- Trust webhook data without validation
- Store sensitive data in webhook logs

---

## Success Criteria

Good production testing should:
1. ✅ Use isolated test tasks (identifiable emails)
2. ✅ Clean up after completion
3. ✅ Link to Langfuse traces for analysis
4. ✅ Document results for comparison
5. ✅ Enable rapid iteration (< 5 min per cycle)
6. ✅ Validate before deploying to real users

---

**Remember**: This skill is about **safe production testing**, not replacing proper staging environments. Use it for:
- Strategy validation
- Performance profiling
- Regression testing
- Optimization loops

For high-risk changes, always test locally first using `run_daily_briefing.py`.
