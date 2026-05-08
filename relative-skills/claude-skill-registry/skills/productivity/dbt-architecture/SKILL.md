---
name: dbt-architecture
description:
  dbt project structure using medallion architecture (bronze/silver/gold layers). Use this skill
  when planning project organization, establishing folder structure, defining naming conventions,
  implementing layer-based configuration, or ensuring proper model dependencies and architectural
  patterns.
---

# dbt Architecture

## Purpose

Transform AI agents into experts on dbt project architecture and medallion layer patterns, providing
guidance on structuring production-grade dbt projects with proper layer separation, naming
conventions, and configuration strategies.

## When to Use This Skill

Activate this skill when users ask about:

- Planning dbt project structure and folder organization
- Implementing medallion architecture (bronze/silver/gold)
- Establishing naming conventions for models and columns
- Configuring folder-level settings in dbt_project.yml
- Ensuring proper model dependencies and data flow
- Understanding layer separation and architectural patterns
- Setting up tag inheritance strategies

## Core Philosophy: Medallion Architecture + Best Practices Integration

Medallion architecture demonstrates how dbt best practices seamlessly integrate with a layered data
approach:

- **Bronze Layer** = **Staging Models** (`stg_`) - One-to-one source relationships
- **Silver Layer** = **Intermediate Models** (`int_`) - Business logic transformations
- **Gold Layer** = **Marts** (`dim_`, `fct_`) - Business-ready data products

Every recommendation follows both architectural principles and dbt best practices simultaneously.

---

## Medallion Architecture Quick Reference

### Three Layers

**Bronze (Staging):**

- Naming: `stg_{source}__{table}`
- Materialization: `ephemeral`
- Purpose: One-to-one source cleaning
- Rules: No joins, no business logic

**Silver (Intermediate):**

- Naming: `int_{entity}__{description}`
- Materialization: `ephemeral` or `table`
- Purpose: Business logic, enrichment
- Rules: No direct source references

**Gold (Marts):**

- Naming: `dim_{entity}` or `fct_{process}`
- Materialization: `table` or `incremental`
- Purpose: Business-ready data products
- Rules: Fully tested, documented, optimized

---

## Critical Architectural Rules

Always enforce these patterns:

1. ✅ **No Direct Joins to Source** - Models reference staging (`ref('stg_*')`), never `source()`
   directly
2. ✅ **One-to-One Staging** - Each source table has exactly ONE staging model
3. ✅ **Proper Layering** - Clear flow: staging → intermediate → marts
4. ✅ **Standardized Naming** - Consistent `stg_`, `int_`, `dim_`, `fct_` prefixes
5. ✅ **Use ref() and source()** - No hard-coded table references
6. ✅ **Folder-Level Configuration** - Set common settings in dbt_project.yml

**Official dbt Documentation**:
[How we structure our dbt projects](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview)

---

## Bronze Layer: Staging Models

**Purpose**: One-to-one relationship with source tables. Light cleaning and standardization only.

**Materialization**: `ephemeral` (compiled as CTEs)

**Naming**: `stg_{source}__{table}.sql`

### Template

```sql
-- models/bronze/stg_tpc_h__customers.sql
{{ config(materialized='ephemeral') }}

select
    -- Primary key (renamed)
    c_custkey as customer_id,

    -- Attributes (cast and renamed)
    c_name as customer_name,
    c_address as customer_address,
    c_phone as phone_number,
    c_acctbal as account_balance,

    -- Metadata
    current_timestamp() as dbt_loaded_at

from {{ source('tpc_h', 'customer') }}
```

### Rules

✅ **DO**:

- One source table → One staging model
- Reference sources using `{{ source() }}`
- Rename columns to standard naming
- Cast data types
- Basic cleaning (trim, upper/lower)

❌ **DON'T**:

- Join between sources
- Add business logic
- Aggregate data
- Hard-code table names

---

## Silver Layer: Intermediate Models

**Purpose**: Reusable business logic and complex transformations. Sits between staging and marts.

**Materialization**: `ephemeral` (reusable logic) or `table` (complex computations)

**Naming**: `int_{entity}__{description}.sql`

### Template

```sql
-- models/silver/int_customers__with_orders.sql
{{ config(materialized='ephemeral') }}

with customers as (
    select * from {{ ref('stg_tpc_h__customers') }}
),

orders as (
    select * from {{ ref('stg_tpc_h__orders') }}
),

customer_metrics as (
    select
        customer_id,
        count(*) as total_orders,
        sum(order_total) as lifetime_value,
        min(order_date) as first_order_date
    from orders
    group by customer_id
)

select
    c.customer_id,
    c.customer_name,
    coalesce(m.total_orders, 0) as total_orders,
    coalesce(m.lifetime_value, 0) as lifetime_value,
    m.first_order_date
from customers c
left join customer_metrics m on c.customer_id = m.customer_id
```

### Rules

✅ **DO**:

- Reference staging + other intermediate models
- Add business logic and aggregations
- Create reusable components
- Use CTEs for clarity

❌ **DON'T**:

- Reference sources directly
- Add final presentation logic
- Create one-time-use models

---

## Gold Layer: Marts Models

**Purpose**: Business-ready data products optimized for BI tools and end users.

**Materialization**: `table` (dimensions) or `incremental` (large facts)

**Naming**: `dim_{entity}` (dimensions), `fct_{process}` (facts)

### Dimension Template

```sql
-- models/gold/dim_customers.sql
{{ config(materialized='table') }}

with customers as (
    select * from {{ ref('int_customers__with_orders') }}
)

select
    -- Primary key
    customer_id,

    -- Attributes
    customer_name,
    customer_email,

    -- Metrics
    total_orders,
    lifetime_value,
    first_order_date,

    -- Business classification
    case
        when lifetime_value >= 5000 then 'gold'
        when lifetime_value >= 1000 then 'silver'
        else 'bronze'
    end as customer_tier,

    -- Metadata
    current_timestamp() as dbt_updated_at
from customers
```

### Fact Template

```sql
-- models/gold/fct_orders.sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    cluster_by=['order_date', 'customer_id']
) }}

select
    order_id,
    customer_id,
    order_date,
    order_status,
    order_total,
    current_timestamp() as dbt_updated_at
from {{ ref('stg_tpc_h__orders') }}

{% if is_incremental() %}
    where order_date > (select max(order_date) from {{ this }})
{% endif %}
```

### Rules

✅ **DO**:

- Reference staging, intermediate, and other marts
- Add final business logic
- Optimize for query performance (clustering)
- Test comprehensively
- Document for business users

❌ **DON'T**:

- Reference sources directly
- Create unnecessary complexity

---

## Naming Conventions

### Model Naming

| Layer                   | Prefix | Example                      | Purpose           |
| ----------------------- | ------ | ---------------------------- | ----------------- |
| **Bronze/Staging**      | `stg_` | `stg_tpc_h__customers`       | Clean source data |
| **Silver/Intermediate** | `int_` | `int_customers__with_orders` | Business logic    |
| **Gold/Dimensions**     | `dim_` | `dim_customers`              | Business entities |
| **Gold/Facts**          | `fct_` | `fct_orders`                 | Business events   |

### Column Naming Standards

**Primary & Foreign Keys**:

- `{entity}_id` - customer_id, order_id, product_id
- Foreign keys use same naming as primary key in related table

**Boolean Flags**:

- `is_{condition}` - is_active, is_deleted, is_first_order
- `has_{attribute}` - has_orders, has_discount

**Dates & Timestamps**:

- `{event}_date` - order_date, created_date
- `{event}_at` - created_at, updated_at, deleted_at
- Always use UTC timezone suffix if needed - created_at_utc

**Metrics & Aggregates**:

- `{metric}_count` - order_count, customer_count
- `{metric}_amount` - total_amount, discount_amount
- Include currency suffix if applicable - amount_usd, price_eur

**Row Numbers & Sequences**:

- `{entity}_row_number` - order_row_number
- `{entity}_seq_number` - sequence_number

### Consistency Rules

✅ **DO:**

- Use snake_case for all column names
- Use consistent entity names across models
- Include currency/units in column names when relevant
- Keep names concise but descriptive

❌ **DON'T:**

- Mix naming styles (camelCase vs snake_case)
- Use abbreviations inconsistently
- Create ambiguous names without context
- Use reserved SQL keywords

---

## Folder Structure

```
models/
├── bronze/          # Staging layer - one-to-one with sources
│   ├── stg_tpc_h__customers.sql
│   ├── stg_tpc_h__orders.sql
│   └── stg_tpc_h__lineitem.sql
├── silver/         # Intermediate layer - business logic
│   ├── int_customers__with_orders.sql
│   ├── int_fx_rates__daily.sql
│   └── customer_segments.sql
└── gold/           # Marts layer - business-ready analytics
    ├── dim_customers.sql
    ├── dim_products.sql
    ├── fct_orders.sql
    └── fct_order_lines.sql
```

---

## Configuration in dbt_project.yml

### Folder-Level Configuration (Reduces Repetition)

Configure common settings at the folder level to minimize model-level overrides:

```yaml
models:
  your_project:
    bronze:
      +materialized: ephemeral
      +tags: ["bronze", "staging"]
      +schema: bronze

    silver:
      +materialized: ephemeral
      +tags: ["silver"]
      +schema: silver

    gold:
      +materialized: table
      +tags: ["gold", "marts"]
      +schema: gold
```

**Model-Level Configuration**: Override folder defaults only for unique requirements (incremental
settings, clustering, etc.)

---

## Tag Inheritance Strategy

✅ **LEVERAGE**: dbt's additive tag inheritance

Tags accumulate hierarchically per the
[dbt documentation](https://docs.getdbt.com/reference/resource-configs/tags). Child folders inherit
all parent tags automatically.

```yaml
# ✅ GOOD: Avoid duplicate tags
bronze:
  +tags: ["bronze", "staging"]
  subfolder:
    +tags: ["subfolder"]  # Inherits: bronze, staging, subfolder

# ❌ BAD: Redundant parent tags
bronze:
  +tags: ["bronze", "staging"]
  subfolder:
    +tags: ["bronze", "staging", "subfolder"]  # Duplicates parent tags
```

**Common Selection Patterns**:

```bash
dbt run --select tag:bronze     # All bronze models
dbt run --select tag:gold       # All gold models
dbt run --select tag:staging    # Alternative to bronze
```

---

## Helping Users with Architecture

### Strategy for Assisting Users

When users ask for architectural guidance:

1. **Identify the layer**: Which medallion layer (bronze/silver/gold)?
2. **Clarify purpose**: What transformation or business logic is needed?
3. **Apply naming conventions**: Follow `stg_`, `int_`, `dim_`, `fct_` patterns
4. **Recommend materialization**: Based on layer and reusability
5. **Provide working examples**: Show complete, tested code patterns
6. **Validate dependencies**: Ensure proper layer flow (staging → intermediate → marts)

### Common User Questions

**"How should I structure my project?"**

- Explain medallion architecture layers
- Show folder organization by layer
- Demonstrate model dependencies flow
- Provide naming convention standards
- Show configuration strategy (folder-level first)

**"Where does this model belong?"**

- Ask: Is it cleaning source data? → Bronze
- Ask: Does it add business logic? → Silver
- Ask: Is it for end-user consumption? → Gold

**"What should I name this model?"**

- Bronze: `stg_{source}__{table}`
- Silver: `int_{entity}__{description}`
- Gold dimensions: `dim_{entity}`
- Gold facts: `fct_{process}`

---

## Related Official Documentation

- [dbt Best Practices: How We Structure Our dbt Projects](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview)
- [dbt Best Practices: Structuring Project](https://docs.getdbt.com/guides/best-practices)
- [dbt Resource Configurations: Tags](https://docs.getdbt.com/reference/resource-configs/tags)

---

**Goal**: Transform AI agents into expert dbt architects who guide users through project structure
with confidence, clarity, and production-ready patterns.
