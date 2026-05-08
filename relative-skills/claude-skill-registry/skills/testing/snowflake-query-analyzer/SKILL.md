---
name: snowflake-query-analyzer
description: Analyzes Snowflake query performance, identifies optimization opportunities, and provides cost reduction recommendations. Use when user needs to optimize slow queries, reduce Snowflake costs, analyze query profiles, design clustering keys, or troubleshoot performance issues.
allowed-tools: Read, Write, Bash, Grep
---

# Snowflake Query Analyzer

Expert skill for Snowflake query performance analysis and optimization.

## When to Use This Skill

Activate when the user mentions:
- "Optimize this Snowflake query"
- "Why is this query slow"
- "Reduce Snowflake costs"
- "Analyze query performance"
- "Clustering keys"
- "Query profile"
- "Warehouse sizing"
- "Partition pruning"

## Deterministic Analysis Tool

The plugin includes a Python script for direct Snowflake query analysis:

```bash
# Analyze specific query
python ${CLAUDE_PLUGIN_ROOT}/scripts/analyze_snowflake.py --query-id <query_id>

# Find queries for a model
python ${CLAUDE_PLUGIN_ROOT}/scripts/analyze_snowflake.py --model fct_orders

# Find slow queries
python ${CLAUDE_PLUGIN_ROOT}/scripts/analyze_snowflake.py --slow --threshold 60 --limit 20

# Find expensive queries
python ${CLAUDE_PLUGIN_ROOT}/scripts/analyze_snowflake.py --expensive --limit 20

# Get table clustering info
python ${CLAUDE_PLUGIN_ROOT}/scripts/analyze_snowflake.py --table my_table
```

This script:
- Connects directly to Snowflake INFORMATION_SCHEMA
- Extracts query metadata deterministically
- Calculates partition pruning, spilling, and cost metrics
- Provides structured JSON output (reduces token consumption)
- Identifies performance issues automatically

**Requirements**:
- `snowflake-connector-python` installed
- Snowflake credentials in environment or `~/.dbt/profiles.yml`

## Core Capabilities

### 1. Query Profile Analysis

Key metrics to analyze from Snowflake query profiles:

**Execution Time Breakdown**
- Compilation time
- Queuing time
- Execution time per operator
- Network communication time

**Data Processing**
- Bytes scanned
- Bytes written
- Partition pruning percentage
- Micro-partition overlap

**Resource Usage**
- Warehouse size used
- Credits consumed
- Spilling to local disk
- Spilling to remote storage

**Parallelism**
- Number of nodes/threads
- Data distribution skew
- Operator parallelization

### 2. Common Performance Issues

**Issue 1: Poor Partition Pruning**
```
Symptom: Pruning percentage < 50%
Cause: Filters not aligned with clustering keys
Impact: Scanning unnecessary data, slow queries

Example:
Table clustered by (date_column)
Query filters on customer_id
Result: Scans entire table

Fix: Add clustering key for customer_id OR add date filter
```

**Issue 2: Spilling to Disk**
```
Symptom: "Bytes spilled to local/remote storage" > 0
Cause: Insufficient warehouse memory
Impact: 10-100x slower performance

Fix Options:
1. Increase warehouse size (S → M → L)
2. Optimize query to reduce memory (remove unnecessary columns)
3. Break into smaller queries
4. Add filters earlier in query
```

**Issue 3: Exploding Joins**
```
Symptom: Rows output >> rows input
Cause: Cartesian product or many-to-many joins
Impact: Memory issues, timeouts

Detection:
- Look for joins without proper keys
- Check for duplicate keys
- Verify join conditions

Fix:
- Add deduplication before join
- Use window functions instead
- Ensure proper join keys
```

**Issue 4: No Clustering**
```
Symptom: Average clustering depth > 50
Cause: Table not clustered or poorly maintained
Impact: Full table scans

Fix:
ALTER TABLE table_name CLUSTER BY (col1, col2);
```

**Issue 5: Inefficient Aggregations**
```
Symptom: Long execution time on GROUP BY
Cause: High cardinality group by, late aggregation
Impact: Excessive memory and compute

Fix:
- Aggregate earlier in query
- Consider materialized aggregates
- Use approximate aggregations (HLL, APPROX_COUNT_DISTINCT)
```

### 3. Optimization Strategies

**Strategy 1: Clustering Key Design**

Best practices:
```sql
-- Good: Frequently filtered columns, time-based
CLUSTER BY (date_column, category_id)

-- Consider:
- Columns in WHERE clauses
- Columns in JOIN conditions  
- Cardinality: high-to-low (date before ID)
- Limit to 3-4 columns
- Order matters: most selective first

-- Don't cluster on:
- Very high cardinality (IDs with no time component)
- Columns never in WHERE/JOIN
- Frequently updated columns
```

**Strategy 2: Incremental Processing**

```sql
-- Instead of full table scan:
SELECT * FROM large_table
WHERE process_date >= CURRENT_DATE - 7

-- Use incremental logic:
{{ config(
    materialized='incremental',
    unique_key='id',
    incremental_strategy='delete+insert'
) }}

SELECT *
FROM {{ source('raw', 'large_table') }}
{% if is_incremental() %}
WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}
```

**Strategy 3: Result Caching**

```sql
-- Enable result cache (24 hour default)
ALTER SESSION SET USE_CACHED_RESULT = TRUE;

-- Same query returns instantly if:
- Query text identical
- Tables unchanged
- Within cache TTL (24 hours)
```

**Strategy 4: Warehouse Sizing**

Decision matrix:
```
Workload Type → Recommended Size

Single large query, lots of data → L or XL
Many concurrent small queries → Multi-cluster S or M
Mixed workload → Separate warehouses
Development/testing → XS or S
ETL/batch processing → M or L
BI dashboards → M with auto-suspend=60s
```

Auto-scaling configuration:
```sql
CREATE WAREHOUSE analytics_wh
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 3
    SCALING_POLICY = 'STANDARD';
```

### 4. Cost Analysis

**Calculate Query Cost**
```sql
-- Get query execution details
SELECT 
    query_id,
    query_text,
    warehouse_size,
    execution_time / 1000 as execution_seconds,
    bytes_scanned,
    -- Estimate cost (approximate)
    (execution_time / 1000.0 / 3600) * 
    CASE warehouse_size
        WHEN 'X-Small' THEN 1
        WHEN 'Small' THEN 2
        WHEN 'Medium' THEN 4
        WHEN 'Large' THEN 8
        WHEN 'X-Large' THEN 16
    END as estimated_credits
FROM table(information_schema.query_history())
WHERE query_id = '<QUERY_ID>'
```

**Cost Optimization Checklist**
- [ ] Appropriate warehouse size (not oversized)
- [ ] Auto-suspend enabled (60-300 seconds)
- [ ] Clustering maintained on large tables
- [ ] Incremental processing where possible
- [ ] No full table scans on large tables (>1M rows)
- [ ] Partition pruning > 80%
- [ ] Result cache utilized
- [ ] No unnecessary column selection (SELECT *)
- [ ] Separate warehouses for different workloads

### 5. Query Rewriting Patterns

**Pattern 1: Push Down Filters**
```sql
-- ❌ Bad: Filter after expensive operations
SELECT customer_id, total
FROM (
    SELECT 
        customer_id,
        SUM(amount) as total
    FROM large_table
    GROUP BY customer_id
)
WHERE customer_id IN (1, 2, 3)

-- ✅ Good: Filter early
SELECT 
    customer_id,
    SUM(amount) as total
FROM large_table
WHERE customer_id IN (1, 2, 3)
GROUP BY customer_id
```

**Pattern 2: Use CTEs for Clarity and Optimization**
```sql
-- ❌ Bad: Repeated subqueries
SELECT a.*, 
    (SELECT COUNT(*) FROM orders WHERE customer_id = a.id) as order_count,
    (SELECT SUM(total) FROM orders WHERE customer_id = a.id) as total_spent
FROM customers a

-- ✅ Good: Single scan with CTE
WITH order_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as order_count,
        SUM(total) as total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT 
    a.*,
    COALESCE(b.order_count, 0) as order_count,
    COALESCE(b.total_spent, 0) as total_spent
FROM customers a
LEFT JOIN order_stats b ON a.id = b.customer_id
```

**Pattern 3: Avoid SELECT ***
```sql
-- ❌ Bad: Unnecessary columns increase data transfer
SELECT * FROM large_table WHERE id = 123

-- ✅ Good: Only needed columns
SELECT id, name, amount, date 
FROM large_table 
WHERE id = 123
```

**Pattern 4: Use QUALIFY for Window Functions**
```sql
-- ❌ Bad: Subquery for window function filter
SELECT * FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY date DESC) as rn
    FROM orders
)
WHERE rn = 1

-- ✅ Good: QUALIFY clause (Snowflake-specific)
SELECT *
FROM orders
QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY date DESC) = 1
```

### 6. Monitoring Queries

**Query for Long-Running Queries**
```sql
SELECT
    query_id,
    user_name,
    warehouse_name,
    execution_status,
    total_elapsed_time / 1000 as seconds,
    bytes_scanned / POWER(1024, 3) as gb_scanned,
    query_text
FROM table(information_schema.query_history(
    dateadd('hours', -24, current_timestamp()),
    current_timestamp()
))
WHERE execution_status = 'SUCCESS'
    AND total_elapsed_time > 60000  -- > 1 minute
ORDER BY total_elapsed_time DESC
LIMIT 20;
```

**Query for Expensive Queries**
```sql
SELECT
    query_id,
    start_time,
    end_time,
    warehouse_size,
    (execution_time / 1000.0 / 3600) * 
    CASE warehouse_size
        WHEN 'MEDIUM' THEN 4
        WHEN 'LARGE' THEN 8
    END as estimated_credits,
    query_text
FROM table(information_schema.query_history())
WHERE start_time > dateadd('day', -7, current_timestamp())
ORDER BY estimated_credits DESC
LIMIT 20;
```

### 7. Diagnosis Workflow

**Step 1: Identify the Problem**
```
Questions to ask:
- Is it slow (execution time)?
- Is it expensive (credits consumed)?
- Does it timeout?
- Does it produce wrong results?
```

**Step 2: Get Query Profile**
```sql
-- In Snowflake UI: History → Click Query → Query Profile
-- Or use SQL:
SELECT * 
FROM table(information_schema.query_history())
WHERE query_id = '<QUERY_ID>';
```

**Step 3: Analyze Key Metrics**
```
Check:
✓ Partition pruning % (want > 80%)
✓ Bytes spilled (want = 0)
✓ Parallelism (should utilize all nodes)
✓ Operator times (find slowest)
✓ Rows at each stage (detect explosions)
```

**Step 4: Identify Root Cause**
```
Common causes:
- No partition pruning → Add clustering or filters
- Spilling → Increase warehouse size
- Cartesian join → Fix join conditions
- Full table scan → Add indexes/clustering
- High cardinality GROUP BY → Pre-aggregate or sample
```

**Step 5: Implement Fix**
```
Apply optimization:
- Rewrite query
- Add clustering keys
- Change warehouse size
- Use incremental strategy
- Add filters
```

**Step 6: Measure Improvement**
```
Compare before/after:
- Execution time
- Credits consumed
- Bytes scanned
- Partition pruning %
```

## Practical Examples

### Example 1: Optimize Slow Aggregation
```sql
-- Problem: 5 minutes, 20 credits
-- ❌ Original query
SELECT 
    customer_id,
    DATE_TRUNC('month', order_date) as month,
    COUNT(*) as order_count,
    SUM(total_amount) as revenue
FROM orders
GROUP BY customer_id, month

-- Analysis:
-- - Full table scan (1B rows)
-- - No partition pruning
-- - No clustering

-- ✅ Solution 1: Add date filter
SELECT 
    customer_id,
    DATE_TRUNC('month', order_date) as month,
    COUNT(*) as order_count,
    SUM(total_amount) as revenue
FROM orders
WHERE order_date >= '2023-01-01'  -- Last 2 years
GROUP BY customer_id, month

-- ✅ Solution 2: Create incremental mart
{{ config(materialized='incremental') }}
-- Build incrementally, 10x faster
```

### Example 2: Fix Spilling Issue
```
Problem: Query spilling 50GB to remote storage

Analysis from query profile:
- Using SMALL warehouse
- Complex joins with large tables
- Memory exceeded

Fix:
1. Increase warehouse: SMALL → MEDIUM
2. Result: No more spilling, 5x faster
3. Cost: 2x credits but completes vs timing out
```

### Example 3: Optimize with Clustering
```sql
-- Problem: 2-minute query on 100M row table

-- Check current clustering
SELECT SYSTEM$CLUSTERING_INFORMATION(
    'my_table', 
    '(order_date, customer_id)'
);
-- Result: average_depth = 180 (bad)

-- Add clustering
ALTER TABLE my_table 
CLUSTER BY (order_date, customer_id);

-- After clustering:
-- - Query time: 2min → 8sec (15x faster)
-- - Partition pruning: 5% → 95%
-- - Bytes scanned: 50GB → 2.5GB
```

## Output Format

When analyzing a query, provide:

```markdown
# Query Analysis Report

## Query Overview
- Query ID: xxx
- Execution Time: X seconds
- Warehouse: X-SMALL
- Credits Consumed: ~X.XX

## Performance Metrics
- Bytes Scanned: XX GB
- Partition Pruning: XX%
- Bytes Spilled: XX GB
- Parallelism: XX nodes

## Issues Identified
🔴 Critical:
- [Issue with high impact]

🟡 Optimization Opportunities:
- [Improvements available]

## Recommendations

### Immediate Actions
1. [Quick win optimization]
2. [Another easy fix]

### Long-term Improvements
1. [Structural change]
2. [Architecture improvement]

## Estimated Impact
- Time Reduction: XX%
- Cost Reduction: XX%

## Implementation Guide
[Step-by-step fix instructions]
```

## Quality Checklist

- [ ] All key metrics analyzed
- [ ] Root cause identified
- [ ] Specific recommendations provided
- [ ] Before/after comparison included
- [ ] Cost impact estimated
- [ ] Implementation steps clear
- [ ] Prevention strategies mentioned
