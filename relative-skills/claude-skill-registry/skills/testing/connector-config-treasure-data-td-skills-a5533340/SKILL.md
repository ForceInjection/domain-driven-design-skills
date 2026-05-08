---
name: connector-config
description: Writes connector_config for segment/journey activations using `tdx connection schema <type>` to discover available fields. Use when configuring activations - always run schema command first to see connector-specific fields.
---

# tdx Connector Config

Configure `connector_config` for activations by discovering fields with `tdx connection schema`.

## Key Commands

```bash
# List connections (shows type and name)
tdx connection list

# Discover connector_config fields (ALWAYS run this first)
tdx connection schema <connector_type>

# List all connector types
tdx connection types
```

**Schema vs Settings**: `schema` shows `connector_config` fields for activations. `settings` shows credentials for creating connections.

## Workflow

```bash
# 1. Find connection type
tdx connection list
#   salesforce_marketing_cloud_v2  salesforce-marketing - Jane Smith

# 2. Get schema
tdx connection schema salesforce_marketing_cloud_v2

# 3. Write connector_config using discovered fields
# 4. Validate: tdx sg push --dry-run
```

## Common Connector Types

### Salesforce Marketing Cloud (salesforce_marketing_cloud_v2)

```yaml
connector_config:
  de_name: CustomerSegment           # Data Extension name (requires primary key)
  shared_data_extension: false
  data_operation: upsert             # upsert | replace
  # For creating new DE:
  create_new_de: true
  folder_path: Segments/Marketing
  primary_column: email
  is_sendable: true
  sendable_rule: Email Address       # "Subscriber Key" | "Email Address"
  sendable_column: email
```

### Salesforce CRM (sfdc_v2)

```yaml
connector_config:
  object: Contact
  mode: update                       # append | truncate | update
  unique: email                      # Key field (when mode=update)
  upsert: true
```

### AWS S3 (s3_v2)

```yaml
connector_config:
  bucket: my-bucket
  path: exports/segments/data.csv
  format: csv                        # csv | tsv | jsonl
  compression: gz                    # none | gz
```

### BigQuery (bigquery_v2)

```yaml
connector_config:
  project: my-gcp-project
  dataset: marketing
  table: segments
  mode: APPEND                       # APPEND | REPLACE | REPLACE_BACKUP | TRUNCATE
  auto_create_table: true
```

### Treasure Data (treasure_data)

```yaml
connector_config:
  database_name: marketing_db
  table_name: exported_segments
  mode: append                       # append | replace
```

## Conditional Fields

Schema output shows when fields apply:

```
unique: Key [text]
  Show when: mode=["update"]
```

Only include `unique` when `mode` is `update`.

## Related Skills

- **segment** - Child segment activations
- **journey** - Journey activations
