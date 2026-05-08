---
name: trino
description: TD Trino SQL with TD-specific functions (td_interval, td_time_range, td_time_string, td_sessionize). Use for time-based filtering, partition pruning, and TD query patterns.
---

# TD Trino SQL

## TD Time Functions

### td_interval (Recommended for relative time)

```sql
where td_interval(time, '-1d', 'JST')      -- Yesterday (JST)
where td_interval(time, '-1d')             -- Yesterday (UTC)
where td_interval(time, '-1w', 'JST')      -- Previous week
where td_interval(time, '-1M', 'JST')      -- Previous month
where td_interval(time, '-1d/-1d', 'JST')  -- 2 days ago
where td_interval(time, '-1M/-2M', 'JST')  -- 3 months ago
```

Timezone is optional (defaults to UTC).

**Note**: Cannot use `td_scheduled_time()` as first arg. Include `td_scheduled_time()` elsewhere in query to establish reference date.

### td_time_range (Explicit dates)

```sql
where td_time_range(time, '2024-01-01', '2024-01-31')
where td_time_range(time, td_time_add(td_scheduled_time(), '-7d'), td_scheduled_time())
```

### td_time_string (Display formatting)

```sql
td_time_string(time, 'd!')         -- 2024-01-15 (UTC)
td_time_string(time, 'd!', 'JST')  -- 2024-01-15 (JST)
td_time_string(time, 's!', 'JST')  -- 2024-01-15 10:30:45
td_time_string(time, 'M!')         -- 2024-01
td_time_string(time, 'h!')         -- 2024-01-15 10
```

Format codes: `y!`=year, `q!`=quarter, `M!`=month, `w!`=week, `d!`=day, `h!`=hour, `m!`=minute, `s!`=second. Without `!`, includes timezone offset. Timezone is optional (defaults to UTC).

**Critical**: Use for display only, never for filtering:
- Good: `select td_time_string(time, 'd!', 'JST') as date`
- Bad: `where td_time_string(time, 'd!', 'JST') = '2024-01-01'`

### td_time_format (Legacy)

```sql
td_time_format(time, 'yyyy-MM-dd HH:mm:ss', 'JST')
```

### td_sessionize

```sql
select td_sessionize(time, 1800, user_id) as session_id  -- 30min timeout
from events
```

## Table Format

```sql
select * from database_name.table_name
where td_interval(time, '-1d', 'JST')
```

## Performance

Always include time filters for partition pruning:

```sql
-- Good: Partition pruning
where td_time_range(time, '2024-01-01', '2024-01-02')

-- Bad: Full table scan
where event_type = 'click'  -- Missing time filter!
```

Use `approx_distinct()` and `approx_percentile()` for large datasets.

## Common Errors

| Error | Fix |
|-------|-----|
| Query exceeded memory limit | Add time filters, use approx_ functions |
| Partition not found | Verify time range syntax |

## Resources

- https://trino.io/docs/current/
