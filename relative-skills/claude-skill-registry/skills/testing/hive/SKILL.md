---
name: hive
description: TD Hive SQL with TD-specific functions and Hive-only features (lateral view, explode, MAPJOIN hint). Use when Trino memory errors occur or for Hive-specific syntax.
---

# TD Hive SQL

## TD Time Functions

### td_interval (Recommended for relative time)

```sql
where td_interval(time, '-1d', 'JST')      -- Yesterday
where td_interval(time, '-1w', 'JST')      -- Previous week
where td_interval(time, '-1M', 'JST')      -- Previous month
where td_interval(time, '-1d/-1d', 'JST')  -- 2 days ago
```

**Note**: Cannot use `TD_SCHEDULED_TIME()` as first arg. Include `TD_SCHEDULED_TIME()` elsewhere to establish reference date.

### td_time_range (Explicit dates)

```sql
where td_time_range(time, '2024-01-01', '2024-01-31', 'JST')
where td_time_range(time, '2024-01-01', null, 'JST')  -- Open-ended
```

### TD_TIME_FORMAT

```sql
TD_TIME_FORMAT(time, 'yyyy-MM-dd HH:mm:ss', 'JST')
```

### TD_TIME_PARSE

```sql
TD_TIME_PARSE('2024-01-01', 'JST')  -- String to Unix timestamp
```

### TD_DATE_TRUNC

```sql
TD_DATE_TRUNC('day', time, 'JST')
TD_DATE_TRUNC('hour', time, 'UTC')
```

## Hive-Specific Features

### MAPJOIN Hint

```sql
select /*+ MAPJOIN(small_table) */ *
from large_table l
join small_table s on l.id = s.id
where td_time_range(l.time, '2024-01-01')
```

### lateral view with explode

```sql
select user_id, tag
from user_profiles
lateral view explode(tags) tags_table as tag
where td_time_range(time, '2024-01-01')
```

### get_json_object

```sql
select
  get_json_object(json_column, '$.user.id') as user_id,
  get_json_object(json_column, '$.event.type') as event_type
from raw_events
```

### Dynamic Partitioning

```sql
set hive.exec.dynamic.partition = true;
set hive.exec.dynamic.partition.mode = nonstrict;

insert overwrite table target_table partition(dt)
select *, TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') as dt
from source_table
where td_time_range(time, '2024-01-01', '2024-01-31')
```

## Differences from Trino

| Feature | Hive | Trino |
|---------|------|-------|
| Approx distinct | `count(distinct x)` | `approx_distinct(x)` |
| Time format | `TD_TIME_FORMAT()` | `td_time_string()` |
| Small table join | `/*+ MAPJOIN(t) */` | Automatic |
| Flatten array | `lateral view explode()` | `unnest()` |

## Common Errors

| Error | Fix |
|-------|-----|
| OutOfMemoryError | Reduce time range, use MAPJOIN |
| Too many dynamic partitions | Reduce partition count |

## When to Use Hive vs Trino

- **Use Hive**: Memory errors in Trino, batch ETL, Hive-specific UDFs
- **Use Trino**: Interactive queries, faster execution, approx functions

## Resources

- https://cwiki.apache.org/confluence/display/Hive
