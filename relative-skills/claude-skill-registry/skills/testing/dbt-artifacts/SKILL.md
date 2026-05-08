---
name: dbt-artifacts
description:
  Monitor dbt execution using the dbt Artifacts package. Use this skill when you need to track test
  and model execution history, analyze run patterns over time, monitor data quality metrics, or
  enable programmatic access to dbt execution metadata across any dbt version or platform.
---

# dbt Artifacts Package - AI Instructions

## Purpose

This skill enables AI agents to help users monitor dbt execution using the
brooklyn-data/dbt_artifacts package. The package captures detailed execution metadata during dbt
runs and stores it in queryable tables for analysis and monitoring.

## When to Use This Skill

Activate this skill when users ask about:

- Tracking test and model execution history
- Analyzing dbt run patterns over time
- Monitoring data quality metrics from dbt tests
- Investigating dbt performance issues or slow models
- Setting up execution logging and observability
- Querying dbt execution metadata programmatically
- Comparing dbt monitoring approaches (Artifacts vs Event Tables)

## What dbt Artifacts Does

The package captures one row per dbt artifact execution (models, tests, seeds, snapshots) with:

- **Execution status**: success, error, skipped, fail, warn
- **Runtime metrics**: Duration, rows affected, compile time
- **Test results**: Failure counts, error messages
- **Run context**: Command, environment, dbt version, threading
- **Dependencies**: Model lineage and relationships

## Core Tables Reference

| Table              | Purpose                   | Key Columns                                                             |
| ------------------ | ------------------------- | ----------------------------------------------------------------------- |
| `invocations`      | One row per dbt run       | `command_invocation_id`, `dbt_command`, `target_name`, `run_started_at` |
| `model_executions` | Model runtime performance | `status`, `total_node_runtime`, `rows_affected`, `materialization`      |
| `test_executions`  | Data quality tracking     | `status`, `failures`, `total_node_runtime`, `message`                   |
| `seeds`            | Seed file execution       | Similar to model_executions                                             |
| `snapshots`        | Snapshot execution        | Similar to model_executions with SCD tracking                           |
| `sources`          | Source freshness          | Freshness check results                                                 |
| `exposures`        | Exposure execution        | Exposure dependencies                                                   |

**Join Pattern**: Always join through `command_invocation_id` (links all executions in a run) and
`node_id` (identifies specific artifact).

## Installation & Setup

When users need to install or configure dbt Artifacts:

### Step 1: Add Package

Add to `packages.yml`:

```yaml
packages:
  - package: brooklyn-data/dbt_artifacts
    version: 2.9.3
```

### Step 2: Configure Hook

Add to `dbt_project.yml`:

```yaml
on-run-end:
  - "{{ dbt_artifacts.upload_results(results) }}"

models:
  dbt_artifacts:
    +database: your_database
    +schema: dbt_artifacts
```

### Step 3: Install and Initialize

```bash
dbt deps
dbt run --select dbt_artifacts
```

After first run, all subsequent dbt invocations automatically log results.

## Helping Users with Queries

### Query Strategy

When users ask for monitoring queries:

1. **Identify the goal**: What are they trying to monitor? (test failures, slow models, run history,
   etc.)
2. **Reference query library**: Point to relevant queries in the `scripts/` directory (see
   **Monitoring Queries** section below)
3. **Customize as needed**: Adjust date ranges, filters, thresholds
4. **Explain results**: Help interpret the output and recommend actions

### Common Query Patterns

All queries are available as individual executable scripts. See the **Monitoring Queries** section
below for detailed descriptions and usage.

### Query Best Practices

**ALWAYS recommend these patterns:**

- ✅ Filter by `run_started_at` with specific date range (performance)
  ```sql
  WHERE run_started_at >= DATEADD(day, -7, CURRENT_TIMESTAMP())
  ```
- ✅ Use `command_invocation_id` to link related executions efficiently
- ✅ Filter `HAVING COUNT(*) >= 5` for meaningful aggregations
- ✅ Join through both `command_invocation_id` AND `node_id` when linking metadata to executions

**NEVER do these:**

- ❌ Query entire table without date filtering

  ```sql
  -- BAD: Scans entire history
  SELECT * FROM test_executions WHERE status = 'fail';

  -- GOOD: Filtered by date
  SELECT * FROM test_executions
  WHERE status = 'fail'
    AND run_started_at >= DATEADD(day, -7, CURRENT_TIMESTAMP());
  ```

- ❌ Create alerts for every single test failure (too noisy)
- ❌ Store more than 6 months without archival strategy

### Storage Management

**Archival Strategy (Quarterly):**

```sql
-- Archive data older than 90 days
CREATE TABLE dbt_artifacts_archive.model_executions_2024_q4 AS
SELECT *
FROM dbt_artifacts.model_executions
WHERE run_started_at < DATEADD(day, -90, CURRENT_DATE());

-- Delete archived data from active tables
DELETE FROM dbt_artifacts.model_executions
WHERE run_started_at < DATEADD(day, -90, CURRENT_DATE());
```

**Storage Planning:**

- Small project (50 models, 100 tests): ~1-5 MB/week
- Medium project (200 models, 500 tests): ~10-20 MB/week
- Large project (1000+ models, 2000+ tests): ~50-100 MB/week

Plan for **1-2 GB per quarter** for medium projects.

## Comparing Monitoring Approaches

When users ask "Should I use dbt Artifacts or Event Tables?":

### Use dbt Artifacts When:

**Cross-platform compatibility is critical:**

- Running dbt from multiple platforms (dbt Cloud, local CLI, Airflow, etc.)
- Need consistent monitoring across all execution environments
- Team uses mixed deployment strategies

**Historical analysis is primary goal:**

- Analyzing trends over 30+ days
- Long-term performance baseline tracking
- Quarterly or annual reporting on dbt execution
- Compliance or audit trail requirements

**Running dbt outside Snowflake:**

- Using dbt Cloud exclusively
- Executing dbt from Airflow, Azure DevOps, GitHub Actions
- Local development with dbt CLI
- Any non-Snowflake execution environment

**Programmatic access to metadata required:**

- Building custom dashboards in BI tools
- Integrating with existing observability platforms
- Creating custom alerting logic
- Feeding data to data catalogs or lineage tools

**Delayed reporting is acceptable:**

- Runs on `on-run-end` hook (after full execution completes)
- Historical batch analysis vs real-time monitoring
- End-of-run summaries are sufficient

### Avoid dbt Artifacts When:

**Real-time monitoring is critical:**

- Need immediate notification of failures
- Want to see execution progress during runs
- Require detailed trace spans and profiling → **Use**: dbt Projects on Snowflake Event Tables

**Running exclusively in Snowflake:**

- Using dbt PROJECT objects in Snowflake
- Native Snowflake integration preferred
- Want Snowflake-native telemetry → **Use**: dbt Projects Event Tables

**Storage constraints exist:**

- Limited database space for historical data
- Can't maintain growing execution history
- No archival strategy in place → **Use**: Event Tables with shorter retention or external logging

### Use Both for Comprehensive Monitoring:

**Recommended Architecture:**

```
dbt Artifacts (Historical)          Event Tables (Real-time)
        ↓                                    ↓
Long-term trends                   Immediate alerts
Quarterly reports                  Live dashboards
Cross-platform metrics             Trace-level profiling
BI tool integration               Native Snowflake tools
```

**Example:**

1. **Event Tables**: Monitor active runs in real-time, alert on failures immediately
2. **dbt Artifacts**: Analyze historical patterns, track monthly trends, feed BI dashboards

### Comparison Matrix

| Feature                   | dbt Artifacts             | dbt Projects Event Tables     |
| ------------------------- | ------------------------- | ----------------------------- |
| **Execution Environment** | Any (Cloud, CLI, Airflow) | Snowflake native only         |
| **Telemetry Timing**      | On run completion (hook)  | Real-time during execution    |
| **Historical Data**       | User-managed retention    | Configurable retention policy |
| **Platform Integration**  | Cross-platform            | Snowflake-native              |
| **Query Interface**       | Standard SQL tables       | Event table syntax            |
| **Setup Complexity**      | Package + hook config     | dbt PROJECT configuration     |
| **Trace Spans**           | No                        | Yes (detailed profiling)      |
| **Best For**              | Historical analysis       | Real-time monitoring          |

## Monitoring Queries

Individual SQL scripts for common monitoring tasks. Execute with Snowflake CLI:

```bash
snow sql -f scripts/<query_file>.sql -c default
```

### Test Quality Monitoring

**scripts/test_reliability_metrics.sql**

- Calculate pass/fail rates to identify flaky tests
- Shows failure percentages and execution times
- Filters tests with 5+ executions for statistical relevance

**scripts/recent_test_failures.sql**

- Track test failures from last 7 days with full context
- Includes run details, test names, and error messages
- Useful for immediate troubleshooting

**scripts/test_execution_trends.sql**

- Daily test execution counts and pass/fail rates
- Track test suite health over 30-day period
- Identify patterns in test failures

### Model Performance Monitoring

**scripts/slowest_models.sql**

- Identify top 20 slowest models by average runtime
- Shows min/max/avg execution times and row counts
- Filter models with 5+ executions

**scripts/model_execution_errors.sql**

- Recent model failures (last 7 days) with error messages
- Includes model path and execution context
- Helps identify recurring model issues

**scripts/performance_regression_detection.sql**

- Compare recent (7-day) vs baseline (30-day) performance
- Alert on models with 20%+ slowdown
- Calculate performance degradation percentage

### Execution History

**scripts/dbt_run_summary.sql**

- High-level overview of all dbt runs (last 30 days)
- Shows commands, targets, versions, and refresh flags
- Useful for audit trails and pattern analysis

## Common User Tasks

### Task 1: "Show me recent test failures"

1. Run: `snow sql -f scripts/recent_test_failures.sql -c default`
2. Adjust date range if needed (default: last 7 days)
3. Explain how to interpret `failures` column (0 = pass, >0 = fail)
4. Suggest filtering by specific test names or models if needed

### Task 2: "Which models are slowest?"

1. Run: `snow sql -f scripts/slowest_models.sql -c default`
2. Help identify if slowness is consistent (avg) or intermittent (max)
3. Suggest investigating models > 5 minutes or 2x baseline
4. Recommend materialization changes or optimization strategies

### Task 3: "Track test reliability over time"

1. Run: `snow sql -f scripts/test_reliability_metrics.sql -c default`
2. Help identify flaky tests (failure_rate_pct between 10-90%)
3. Recommend investigating tests with 100% failure rate
4. Suggest baseline: < 5% failure rate for healthy tests

### Task 4: "Set up dbt Artifacts"

1. Walk through 3-step installation (packages.yml → dbt_project.yml → dbt deps)
2. Verify installation: `dbt run --select dbt_artifacts`
3. Test logging: `dbt run` (any command) then query `invocations` table
4. Recommend dedicated schema and archival strategy

## Troubleshooting Common Issues

| Issue                | Solution                                                                      |
| -------------------- | ----------------------------------------------------------------------------- |
| "No data in tables"  | Verify `on-run-end` hook in dbt_project.yml; run `dbt run` to trigger logging |
| "Tables not created" | Run `dbt run --select dbt_artifacts` explicitly first                         |
| "Permission denied"  | Ensure dbt user has CREATE/INSERT rights in target database/schema            |
| "Missing columns"    | Update package: `dbt deps --upgrade` to latest version                        |
| "Slow queries"       | Add date filter on `run_started_at`; consider archiving old data              |

## Related Skills

**Complementary Observability:**

- `dbt-projects-on-snowflake` skill - For native Snowflake deployment with real-time event table
  monitoring

**When to use both together:**

- **dbt Artifacts** for cross-platform monitoring and historical analysis across all dbt
  environments
- **dbt Projects on Snowflake** for real-time Snowflake-native monitoring with OpenTelemetry tracing

**When to use one vs the other:**

- Use **dbt Artifacts** alone if you run dbt outside Snowflake (dbt Cloud, Airflow, local)
- Use **dbt Projects on Snowflake** alone if you exclusively run dbt within Snowflake
- Use **both** for comprehensive enterprise monitoring (historical + real-time)

---

## Monitoring Best Practices

### Test Quality Monitoring

**Establish baselines:**

- **Healthy**: Test failure rate < 5%
- **Warning**: Test failure rate 5-10%
- **Critical**: Test failure rate > 10%

**Identify flaky tests:**

- Failure rate between 10-90% (inconsistent results)
- Recommend investigation or test refactoring

**Alert on patterns:**

- New test with 100% failure rate (incorrect test logic)
- Previously stable test suddenly failing
- Test execution time 2x+ baseline

### Model Performance Monitoring

**Performance thresholds:**

- **Investigate**: Models consistently > 5 minutes
- **Critical**: Runtime increase > 2x historical average
- **Optimize**: Models in top 20 slowest

**Alert strategies:**

- High priority: Models with `status = 'error'`
- Medium priority: Runtime increase > 50% from baseline
- Low priority: Slow model trending (track over time)

### Alerting Best Practices

**High Priority (Immediate Action):**

- Test status = 'fail' or 'error'
- Model status = 'error'
- Critical model runtime > 2x baseline
- Production environment failures

**Medium Priority (Investigation Within 24h):**

- Test status = 'warn'
- Model skipped > 10% of runs
- Runtime increase > 50% from baseline
- Unusual invocation patterns

**Low Priority (Track Trends):**

- Slow model performance (not critical path)
- Test success rate slowly declining
- Incremental drift in execution duration

---

## Additional Resources

- **SQL Scripts**: `scripts/` - Individual query files ready to execute with Snowflake CLI
- **Package Documentation**:
  [brooklyn-data.github.io/dbt_artifacts](https://brooklyn-data.github.io/dbt_artifacts)
- **GitHub Repository**:
  [github.com/brooklyn-data/dbt_artifacts](https://github.com/brooklyn-data/dbt_artifacts)
