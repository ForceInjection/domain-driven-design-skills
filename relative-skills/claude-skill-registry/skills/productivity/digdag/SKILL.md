---
name: digdag
description: Treasure Workflow (digdag) for TD. Covers .dig syntax, session variables (session_date, session_date_compact), td> operator, _parallel/_retry/_error directives, and tdx wf commands.
---

# Treasure Workflow (Digdag)

## Basic Structure

```yaml
timezone: Asia/Tokyo

schedule:
  daily>: 02:00:00

_export:
  td:
    database: my_database
    engine: presto

+extract:
  td>: queries/extract.sql
  create_table: raw_data

+transform:
  td>: queries/transform.sql
  create_table: results
```

**Key points:**
- `.dig` extension required; filename becomes workflow name
- Tasks run sequentially with `+task_name:` prefix
- `foo>: bar` is sugar for `_type: foo` and `_command: bar`

## Session Variables

| Variable | Example |
|----------|---------|
| `${session_time}` | `2024-01-30T00:00:00+09:00` |
| `${session_date}` | `2024-01-30` |
| `${session_date_compact}` | `20240130` |
| `${session_unixtime}` | `1706540400` |
| `${last_session_date}` | Previous scheduled date |
| `${next_session_date}` | Next scheduled date |

**Moment.js available:**
```yaml
+tomorrow:
  echo>: ${moment(session_time).add(1, 'days').format("YYYY-MM-DD")}
```

## TD Operator

```yaml
+query:
  td>: queries/analysis.sql
  database: analytics
  engine: presto
  create_table: results      # or insert_into: existing_table
```

**Inline SQL:**
```yaml
+inline:
  td>:
    query: |
      SELECT * FROM events
      WHERE TD_TIME_RANGE(time, '${session_date}', TD_TIME_ADD('${session_date}', '1d'))
```

## Parallel Execution

```yaml
+parallel_tasks:
  _parallel: true

  +task_a:
    td>: queries/a.sql

  +task_b:
    td>: queries/b.sql

+after_parallel:
  echo>: "Runs after all parallel tasks"
```

**Limited concurrency:**
```yaml
+limited:
  _parallel:
    limit: 2
```

## Error Handling

```yaml
+task:
  td>: queries/important.sql
  _retry: 3

  _error:
    +alert:
      sh>: python scripts/alert.py "Task failed"
```

**Retry with backoff:**
```yaml
+task:
  _retry:
    limit: 3
    interval: 10
    interval_type: exponential  # or constant
```

## Variables

```yaml
_export:
  td:
    database: production
  my_param: value
  api_key: ${secret:api_credentials.key}  # TD parameter store

+task:
  py>: scripts.process.main
  param: ${my_param}
```

## Conditional & Loops

```yaml
+check:
  td>: queries/count.sql
  store_last_results: true

+if_data:
  if>: ${td.last_results.cnt > 0}
  _do:
    +process:
      td>: queries/process.sql

+loop:
  for_each>:
    region: [US, EU, ASIA]
  _do:
    +process:
      td>: queries/by_region.sql
```

## Event Triggers

```yaml
# Runs after another workflow succeeds
trigger:
  attempt>:
  dependent_workflow_name: segment_refresh
  dependent_project_name: customer_segments

+activate:
  td>: queries/activate.sql
```

## tdx wf Commands

```bash
# Project sync (recommended workflow)
tdx wf pull my_project               # Pull project to local folder
tdx wf push                          # Push local changes with diff preview
tdx wf clone --name my_project_prod  # Clone to new project name

# Context & discovery
tdx wf use my_project                # Set default project for session
tdx wf projects                      # List all projects
tdx wf workflows                     # List workflows in project

# Running & monitoring
tdx wf run                           # Interactive workflow selector
tdx wf run my_project.my_workflow    # Run specific workflow
tdx wf sessions                      # List runs
tdx wf attempt <id> tasks            # Show task status
tdx wf attempt <id> logs +task_name  # View logs
tdx wf attempt <id> retry            # Retry failed
tdx wf attempt <id> kill             # Stop running

# Secrets
tdx wf secrets list                  # List secret keys
tdx wf secrets set KEY=value         # Set a secret
tdx wf secrets delete KEY            # Delete a secret

# Legacy (digdag-style)
tdx wf upload my_workflow            # Push without sync tracking
```

## Project Structure

```
workflows/
└── my_project/              # Created by tdx wf pull
    ├── tdx.json             # Sync tracking (auto-generated)
    ├── main.dig             # Workflow definition
    ├── queries/
    │   └── analysis.sql
    └── scripts/
        └── process.py
```

## Schedule Options

```yaml
schedule:
  daily>: 02:00:00
  # hourly>: 00:00
  # cron>: "0 */4 * * *"
  # weekly>: "Mon,00:00:00"
```

## Resources

- https://docs.digdag.io/
- https://docs.digdag.io/operators.html
